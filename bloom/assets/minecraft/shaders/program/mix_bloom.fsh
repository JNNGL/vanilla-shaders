// bloom
// https://github.com/JNNGL/vanilla-shaders

#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D BloomSampler;
uniform sampler2D EmissiveSampler;

in vec2 texCoord;

out vec4 fragColor;

vec3 decodeHdr(vec4 color) {
    if (color.a == 0.0) return vec3(0.0);
    return color.rgb * (1.0 / color.a);
}

vec4 encodeHdr(vec3 color) {
    float m = min(max(color.r, max(color.g, color.b)), 255);
    if (m <= 0.0) return vec4(0.0);
    if (m < 1.0) return vec4(color, 1.0);
    return vec4(color / m, 1.0 / m);
}

vec3 acesFilm(vec3 x) {
    return clamp((x * (2.51 * x + 0.03)) / (x * (2.43 * x + 0.59) + 0.14), 0.0, 1.0);
}

vec3 acesInverse(vec3 x) {
    return (sqrt(-10127.0 * x * x + 13702.0 * x + 9.0) + 59.0 * x - 3.0) / (502.0 - 486.0 * x);
}

void main() {
    vec4 color = texture(DiffuseSampler, texCoord);
    vec4 emission = texture(EmissiveSampler, texCoord);
    vec3 bloom = decodeHdr(texture(BloomSampler, texCoord));
    color.rgb = pow(color.rgb, vec3(2.2));
    color.rgb = acesInverse(color.rgb);
    if (emission.a != 0.0) color.rgb = decodeHdr(emission);
    color.rgb = mix(color.rgb, bloom, 0.04);
    color.rgb = acesFilm(color.rgb);
    color.rgb = pow(color.rgb, vec3(1.0 / 2.2));
    fragColor = color;
}
