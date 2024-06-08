#version 330

uniform sampler2D DepthSampler0;
uniform sampler2D DepthSampler1;
uniform sampler2D DepthSampler2;
uniform sampler2D DepthSampler3;
uniform sampler2D DepthSampler4;
uniform sampler2D DepthSampler5;

in vec2 texCoord;

out vec4 fragColor;

void main() {
    float depth = 1.0;
    depth = min(depth, texture(DepthSampler0, texCoord).r);
    depth = min(depth, texture(DepthSampler1, texCoord).r);
    depth = min(depth, texture(DepthSampler2, texCoord).r);
    depth = min(depth, texture(DepthSampler3, texCoord).r);
    depth = min(depth, texture(DepthSampler4, texCoord).r);
    depth = min(depth, texture(DepthSampler5, texCoord).r);

    uint bits = floatBitsToUint(depth);
    // fragColor = unpackUnorm4x8(bits);
    fragColor = vec4(bits >> 24, (bits >> 16) & 0xFFu, (bits >> 8) & 0xFFu, bits & 0xFFu) / 255.0;
}
