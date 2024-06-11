#version 330

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;
uniform sampler2D NormalSampler;
uniform sampler2D VectorSampler;

uniform vec2 InSize;

in vec2 texCoord;
flat in mat4 viewProj;
flat in mat4 invViewProj;

out vec4 fragColor;

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

vec3 getNormal(vec2 uv) {
    return normalize(texture(NormalSampler, uv, 0.).xyz * 2.0 - 1.0);
}

void main() {
    float depth = texture(DiffuseDepthSampler, texCoord).r;
    if (depth == 1.0) {
        fragColor = vec4(1.0);
        return;
    }

    vec3 position = getPosition(texCoord, depth);
    vec3 normal = getNormal(texCoord);

    vec3 seed = floor(position * 1024) / 1024;

    vec3 rndVec = vec3(random(seed) * 2.0 - 1.0, random(seed) * 2.0 - 1.0, 0.0);
    vec3 tangent = normalize(rndVec - normal * dot(rndVec, normal));
    vec3 bitangent = cross(normal, tangent);
    mat3 tbn = mat3(tangent, bitangent, normal);

    const float radius = 1.0;
    const int samples = 16;

    float markerCutoff = 1.5 / InSize.y;

    float occlusion = 0.0;
    for (int i = 0; i < samples; i++) {
        // TODO: Better sampling.
        vec3 sample = texelFetch(VectorSampler, ivec2(i, 0), 0).rgb;
        sample.xy = sample.xy * 2.0 - 1.0;

        vec3 pos = tbn * sample;
        pos = position + pos * radius;

        vec4 offset = viewProj * vec4(pos, 1.0);
        offset = offset / offset.w * 0.5 + 0.5;
        offset.y = max(offset.y, markerCutoff);

        float z = texture(DiffuseDepthSampler, offset.xy).r;
        if (z == 1.0) {
            continue;
        }

        float currentDepth = getPosition(offset.xy, z).z;

        float dist = smoothstep(0.0, 1.0, radius / abs(position.z - currentDepth));
        occlusion += (currentDepth >= pos.z + 0.05 ? 1.0 : 0.0) * dist;
    }

    occlusion = 1.0 - (occlusion / float(samples));

    fragColor = vec4(vec3(occlusion), 1.0);    
}
