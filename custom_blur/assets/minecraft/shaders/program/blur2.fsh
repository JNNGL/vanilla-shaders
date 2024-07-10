#version 330

uniform sampler2D DiffuseSampler;
uniform sampler2D TimeSampler;

uniform vec2 OutSize;
uniform vec2 Direction;
uniform float Radius;

in vec2 texCoord;

out vec4 fragColor;

float decodeFloat(sampler2D s) {
    uvec4 data = uvec4(texelFetch(s, ivec2(0, 0), 0) * 255.0);
    uint bits = (data.r << 24) | (data.g << 16) | (data.b << 8) | data.a;
    return uintBitsToFloat(bits);
}

vec4 blur(vec2 uv, vec2 direction) {
    vec2 s1 = 1.41 * direction;
    vec2 s2 = 3.29 * direction;
    vec2 s3 = 5.17 * direction;

    vec4 accum = vec4(0.0);
    accum += texture(DiffuseSampler, uv     ) * 0.196;
    accum += texture(DiffuseSampler, uv + s1) * 0.298;
    accum += texture(DiffuseSampler, uv - s1) * 0.298;
    accum += texture(DiffuseSampler, uv + s2) * 0.094;
    accum += texture(DiffuseSampler, uv - s2) * 0.094;
    accum += texture(DiffuseSampler, uv + s3) * 0.010;
    accum += texture(DiffuseSampler, uv - s3) * 0.010;
    return accum;
}

float easing(float time) {
    float x = clamp(time * 1.1, 0.0, 1.0);
    return 1 - pow(1 - x, 4);
}

void main() {
    float time = decodeFloat(TimeSampler);
    time = easing(time);

    fragColor = blur(texCoord, (Direction / OutSize) * (Radius / 10.0) * time);
}