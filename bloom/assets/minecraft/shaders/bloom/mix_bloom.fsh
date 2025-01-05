// bloom
// https://github.com/JNNGL/vanilla-shaders

#version 150

#moj_import <minecraft:hdr.glsl>

uniform sampler2D InSampler;
uniform sampler2D BloomSampler;
uniform sampler2D EmissiveSampler;

in vec2 texCoord;

out vec4 fragColor;

vec3 acesFilm(vec3 x) {
    return clamp((x * (2.51 * x + 0.03)) / (x * (2.43 * x + 0.59) + 0.14), 0.0, 1.0);
}

vec3 acesInverse(vec3 x) {
    return (sqrt(-10127.0 * x * x + 13702.0 * x + 9.0) + 59.0 * x - 3.0) / (502.0 - 486.0 * x);
}

#define BLOOM_STRENGTH 0.05

void main() {
    vec4 color = texture(InSampler, texCoord);
    vec3 bloom = decodeLogLuv(texture(BloomSampler, texCoord));

    color.rgb = pow(color.rgb, vec3(2.2));
    color.rgb = acesInverse(color.rgb);
    vec4 emission = texture(EmissiveSampler, texCoord);
    color.rgb = max(color.rgb, decodeLogLuv(emission));

    color.rgb = mix(color.rgb, bloom, BLOOM_STRENGTH);

    color.rgb = acesFilm(color.rgb);
    color.rgb = pow(color.rgb, vec3(1.0 / 2.2));

    fragColor = color;
}
