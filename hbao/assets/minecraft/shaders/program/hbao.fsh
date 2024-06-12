#version 330

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;
uniform sampler2D NormalSampler;
uniform sampler2D VectorSampler;

uniform vec2 InSize;

in vec2 texCoord;
flat in mat4 viewProj;
flat in mat4 invViewProj;
flat in float time;

out vec4 fragColor;

const float aoRadius = 1.0;
const float aoRadiusSq = aoRadius * aoRadius;
const float nInvRadiusSq = - 1.0 / aoRadiusSq;
const float angleBias = 6.0;
const float tanAngleBias = tan(radians(angleBias));
const int numRays = 6;
const int numSamples = 4;
const float maxRadiusPixels = 50.0;

uint hash(uint x) {
    x += (x << 10u);
    x ^= (x >> 6u);
    x += (x << 3u);
    x ^= (x >> 11u);
    x += (x << 15u);
    return x;
}

uint hash(uvec3 v) {
    return hash(v.x ^ hash(v.y) ^ hash(v.z));
}

float floatConstruct(uint m) {
    const uint ieeeMantissa = 0x007FFFFFu;
    const uint ieeeOne = 0x3F800000u;

    m &= ieeeMantissa;
    m |= ieeeOne;

    float f = uintBitsToFloat(m);
    return f - 1.0;
}

float random(inout vec3 v) {
    return floatConstruct(hash(floatBitsToUint(v += 1.0)));
}

vec3 getPosition(vec2 uv, float z) {
    vec4 position_s = vec4(uv, z, 1.0) * 2.0 - 1.0;
    vec4 position_v = invViewProj * position_s;
    return position_v.xyz / position_v.w;
}

vec3 getPosition(vec2 uv) {
    return getPosition(uv, texture(DiffuseDepthSampler, uv).r);
}

float tanToSin(float x) {
    return x * inversesqrt(x * x + 1.0);
}

float invLength(vec2 v) {
    return inversesqrt(dot(v, v));
}

float tangent(vec3 t) {
    return t.z * invLength(t.xy);
}

float biasedTangent(vec3 t) {
    return t.z * invLength(t.xy) + tanAngleBias;
}

float tangent(vec3 p, vec3 s) {
    return -(p.z - s.z) * invLength(s.xy - p.xy);
}

float lengthSquared(vec3 v) {
    return dot(v, v);
}

vec3 minDiff(vec3 p, vec3 pr, vec3 pl) {
    vec3 v1 = pr - p;
    vec3 v2 = p - pl;
    return (lengthSquared(v1) < lengthSquared(v2)) ? v1 : v2;
}

vec2 snapOffset(vec2 uv) {
    return round(uv * InSize) / InSize;
}

float falloff(float d2) {
    return d2 * nInvRadiusSq + 1.0f;
}

vec2 rotateDirections(vec2 dir, vec2 cosSin) {
    return vec2(dir.x * cosSin.x - dir.y * cosSin.y, dir.x * cosSin.y + dir.y * cosSin.x);
}

void computeSteps(inout vec2 stepSizeUv, inout float numSteps, float rayRadiusPix, float rand) {
    numSteps = min(numSamples, rayRadiusPix);
    float stepSizePix = rayRadiusPix / (numSteps + 1.0);
    float maxNumSteps = maxRadiusPixels / stepSizePix;
    if (maxNumSteps < numSteps) {
        numSteps = floor(maxNumSteps + rand);
        numSteps = max(numSteps, 1.0);
        stepSizePix = maxRadiusPixels / numSteps;
    }

    stepSizeUv = stepSizePix / InSize;
}

float horizonOcclusion(vec2 deltaUV, vec3 p, float numSamples, 
                       float randstep, vec3 dPdu, vec3 dPdv) {
    float ao = 0;

    vec2 uv = texCoord + snapOffset(randstep * deltaUV);
    deltaUV = snapOffset(deltaUV);

    vec3 tg = deltaUV.x * dPdu + deltaUV.y * dPdv;

    float tanH = biasedTangent(tg);
    float sinH = tanToSin(tanH);

    for (float i = 1.0; i <= numSamples; ++i) {
        uv += deltaUV;
        vec3 s = getPosition(uv);
        float tanS = tangent(p, s);
        float d2 = lengthSquared(s - p);

        if (d2 < aoRadiusSq && tanS > tanH) {
            float sinS = tanToSin(tanS);
            ao += falloff(d2) * (sinS - sinH);

            tanH = tanS;
            sinH = sinS;
        }
    }
    
    return ao;
}

void main() {
    if (int(floor(gl_FragCoord.y)) == 0) {
        fragColor = texelFetch(DiffuseSampler, ivec2(gl_FragCoord.xy), 0);
        return;
    }

    vec3 p = getPosition(texCoord);
    vec3 pr = getPosition(texCoord + vec2(1, 0) / InSize);
    vec3 pl = getPosition(texCoord + vec2(-1, 0) / InSize);
    vec3 pt = getPosition(texCoord + vec2(0, 1) / InSize);
    vec3 pb = getPosition(texCoord + vec2(0, -1) / InSize);

    vec3 dPdu = minDiff(p, pr, pl);
    vec3 dPdv = minDiff(p, pt, pb);

    vec3 seed = vec3(gl_FragCoord.xy, time);
    vec3 random = vec3(random(seed), random(seed), random(seed));

    vec2 rayRadiusUV = 0.5 * aoRadius * vec2(viewProj[0][0], viewProj[1][1]) / -p.z;
    float rayRadiusPix = rayRadiusUV.x * InSize.x;

    float ao = 1.0;

    if (rayRadiusPix > 1.0) {
        ao = 0.0;
        float numSteps;
        vec2 stepSizeUV;

        computeSteps(stepSizeUV, numSteps, rayRadiusPix, random.z);

        float alpha = 2.0 * 3.14159 / numRays;
        for (float d = 0; d < numRays; ++d) {
            float theta = alpha * d;
            vec2 dir = rotateDirections(vec2(cos(theta), sin(theta)), random.xy);
            vec2 deltaUV = dir * stepSizeUV;
            ao += horizonOcclusion(deltaUV, p, numSteps, random.z, dPdu, dPdv);
        }

        ao = 1.0 - ao / numRays;
    }

    fragColor = vec4(ao, ao, ao, 1.0);
}
