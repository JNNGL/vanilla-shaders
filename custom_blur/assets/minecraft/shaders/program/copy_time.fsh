#version 330

uniform float Time;

out vec4 fragColor;

void main() {
    uint bits = floatBitsToUint(Time);
    fragColor = vec4(bits >> 24, (bits >> 16) & 0xFFu, (bits >> 8) & 0xFFu, bits & 0xFFu) / 255.0;
}