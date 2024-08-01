#version 330

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;
uniform sampler2D NormalSampler;
uniform sampler2D FrameSampler;
uniform sampler2D NoiseSampler;

uniform vec2 InSize;
uniform float Time;

in vec2 texCoord;
flat in mat4 viewProj;
flat in mat4 invViewProj;
flat in float time;

out vec4 fragColor;

vec3 random(float v) {
    ivec2 coord = ivec2(mod(gl_FragCoord.xy + vec2(0.75487762, 0.56984027) * 512 * v, 512));
    return texelFetch(NoiseSampler, coord, 0).xyz;
}

vec3 getPosition(vec2 uv, float z) {
    vec4 position_s = vec4(uv, z, 1.0) * 2.0 - 1.0;
    vec4 position_v = invViewProj * position_s;
    return position_v.xyz / position_v.w;
}

vec3 getNormal(vec2 uv) {
    return normalize(texture(NormalSampler, uv, 0.).xyz * 2.0 - 1.0);
}

const vec3 sampleVectors[] = vec3[](
    vec3(0.20784318, -0.23137254, 0.3019608), vec3(0.427451, 0.27843142, 0.60784316), 
    vec3(-0.16862744, 0.28627455, 0.18431373), vec3(0.3803922, 0.082352996, 0.27058825), 
    vec3(-0.29411763, 0.07450986, 0.043137256), vec3(-0.035294116, -0.18431371, 0.12156863), 
    vec3(0.13725495, 0.30196083, 0.16862746), vec3(-0.0039215684, -0.0039215684, 0.003921569),
    vec3(-0.27843136, 0.27058828, 0.007843138), vec3(-0.4588235, 0.12941182, 0.02745098), 
    vec3(-0.19215685, -0.0745098, 0.4), vec3(-0.019607842, 0.035294175, 0.003921569),
    vec3(0.06666672, 0.19215691, 0.4862745), vec3(0.019607902, 0.09803927, 0.38039216), 
    vec3(0.035294175, -0.0039215684, 0.0627451), vec3(0.019607902, -0.082352936, 0.06666667)
);

void main() {
    if (int(floor(gl_FragCoord.y)) == 0) {
        fragColor = texelFetch(DiffuseSampler, ivec2(gl_FragCoord.xy), 0);
        return;
    }

    float depth = texture(DiffuseDepthSampler, texCoord).r;
    if (depth == 1.0) {
        fragColor = vec4(1.0);
        return;
    }

    vec3 position = getPosition(texCoord, depth);
    vec3 normal = getNormal(texCoord);

    vec3 rndVec = vec3(random(time).xy * 2.0 - 1.0, 0.0);
    vec3 tangent = normalize(rndVec - normal * dot(rndVec, normal));
    vec3 bitangent = cross(normal, tangent);
    mat3 tbn = mat3(tangent, bitangent, normal);

    const float radius = 1.0;
    const int samples = 16;

    float markerCutoff = 1.5 / InSize.y;

    float occlusion = 0.0;
    for (int i = 0; i < samples; i++) {
        vec3 sample = sampleVectors[i];

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