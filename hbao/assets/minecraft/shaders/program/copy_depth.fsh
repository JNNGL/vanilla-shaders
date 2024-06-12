#version 330

uniform sampler2D DiffuseDepthSampler;

in vec2 texCoord;

out vec4 fragColor;

void main() {
    float depth = texture(DiffuseDepthSampler, texCoord).r;
    uint bits = floatBitsToUint(depth);
    fragColor = vec4(bits >> 24, (bits >> 16) & 0xFFu, (bits >> 8) & 0xFFu, bits & 0xFFu) / 255.0;
}