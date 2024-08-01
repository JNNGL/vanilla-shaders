#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;
uniform sampler2D NormalSampler;
uniform sampler2D AmbientOcclusionSampler;

in vec2 texCoord;
flat in mat4 invProj;
flat in float fogStart;
flat in float fogEnd;

out vec4 fragColor;

float ao_fog(float ao, float vertexDistance) {
    if (vertexDistance <= fogStart) {
        return ao;
    }

    float fogValue = vertexDistance < fogEnd ? 1.0 - smoothstep(fogStart, fogEnd, vertexDistance) : 0.0;
    return mix(1.0, ao, fogValue * fogValue);
}


vec3 getPosition(vec2 uv, float z) {
    vec4 position_s = vec4(uv, z, 1.0) * 2.0 - 1.0;
    vec4 position_v = invProj * position_s;
    return position_v.xyz / position_v.w;
}

void main() {
    fragColor = texture(DiffuseSampler, texCoord);

    float depth = texture(DiffuseDepthSampler, texCoord).r;
    if (depth == 1.0) {
        return;
    }

    float ao = texture(AmbientOcclusionSampler, texCoord, 0).r;
    float wSum = 1.0;

    vec3 centerNormal = texture(NormalSampler, texCoord).rgb * 2.0 - 1.0;
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            if (x == 0 && y == 0) continue;
            vec2 offset = vec2(float(x), float(y));
            ivec2 coord = ivec2(gl_FragCoord.xy + offset);
            vec3 normal = texelFetch(NormalSampler, coord, 0).rgb * 2.0 - 1.0;
            float sample = texelFetch(AmbientOcclusionSampler, coord, 0).r;
            if (dot(normal, centerNormal) < 0.8) continue;
            ao += sample;
            wSum += 1.0;
        }
    }

    vec3 position = getPosition(texCoord, depth);
    float dist = length(position);

    fragColor *= ao_fog(ao / wSum, dist);
}