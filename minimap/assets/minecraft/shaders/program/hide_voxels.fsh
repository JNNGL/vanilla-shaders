#version 150

uniform sampler2D DiffuseSampler;

in vec2 texCoord;

out vec4 fragColor;

void main() {
    ivec2 coord = ivec2(gl_FragCoord.xy);
    vec4 sample = texelFetch(DiffuseSampler, coord, 0);
    if (int(sample.a * 255.0) == 249) {
        sample = texelFetch(DiffuseSampler, coord + ivec2(1, 0), 0);
        sample += texelFetch(DiffuseSampler, coord + ivec2(-1, 0), 0);
        sample += texelFetch(DiffuseSampler, coord + ivec2(0, 1), 0);
        sample += texelFetch(DiffuseSampler, coord + ivec2(0, -1), 0);
        fragColor = sample / 4;
    } else {
        fragColor = sample;
    }
}