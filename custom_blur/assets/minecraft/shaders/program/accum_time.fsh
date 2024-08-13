// custom blur
// https://github.com/JNNGL/vanilla-shaders

#version 330

uniform sampler2D DiffuseSampler;
uniform sampler2D PrevAccumSampler;
uniform sampler2D MainSampler;
uniform sampler2D PrevMainSampler;

uniform float Time;

out vec4 fragColor;

float decodeFloat(sampler2D s) {
    uvec4 data = uvec4(texelFetch(s, ivec2(0, 0), 0) * 255.0);
    uint bits = (data.r << 24) | (data.g << 16) | (data.b << 8) | data.a;
    return uintBitsToFloat(bits);
}

void main() {
    if (int(gl_FragCoord.x) == 1) {
        fragColor = vec4(1, 0, 1, 127.0 / 255.0);
        return;
    }

    float prevTime = decodeFloat(DiffuseSampler);
    float deltaTime = Time;
    if (deltaTime < prevTime) deltaTime += 1.0;
    deltaTime -= prevTime;

    float accumTime = decodeFloat(PrevAccumSampler);
    accumTime += deltaTime;

    if (texelFetch(PrevMainSampler, ivec2(0, 0), 0).rgb != texelFetch(MainSampler, ivec2(0, 0), 0).rgb) 
        accumTime = 0.0;
    
    if (texelFetch(PrevAccumSampler, ivec2(1, 0), 0) != vec4(1, 0, 1, 127.0 / 255.0)) 
        accumTime = 0.0;

    uint bits = floatBitsToUint(accumTime);
    fragColor = vec4(bits >> 24, (bits >> 16) & 0xFFu, (bits >> 8) & 0xFFu, bits & 0xFFu) / 255.0;
}