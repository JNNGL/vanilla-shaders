// custom blur
// https://github.com/JNNGL/vanilla-shaders

#version 330

uniform sampler2D DiffuseSampler;
uniform sampler2D TimeSampler;
uniform float Time;

in vec2 texCoord;

out vec4 fragColor;

float decodeFloat(sampler2D s) {
    uvec4 data = uvec4(texelFetch(s, ivec2(0, 0), 0) * 255.0);
    uint bits = (data.r << 24) | (data.g << 16) | (data.b << 8) | data.a;
    return uintBitsToFloat(bits);
}

vec3 saturate(vec3 rgb, float adj) {
    vec3 intensity = vec3(dot(rgb, vec3(0.2125, 0.7154, 0.0721)));
    return mix(intensity, rgb, adj);
}

float easing(float time) {
    float x = clamp(time, 0.0, 1.0);
    return 1 - pow(1 - x, 4);
}

void main() {
    float time = decodeFloat(TimeSampler);
    time = easing(time);

    vec4 color = texture(DiffuseSampler, texCoord);
    color.rgb = saturate(color.rgb, 1.0 - time);
    color.rgb *= mix(1.0, 0.6, time);

    fragColor = color;
}