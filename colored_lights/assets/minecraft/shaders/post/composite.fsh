#version 330

uniform sampler2D InSampler;
uniform sampler2D DataSampler;
uniform sampler2D DepthSampler;

in vec2 texCoord;

out vec4 fragColor;

void main() {
    fragColor = texture(InSampler, texCoord);
    if (int(round(texture(DataSampler, texCoord).a * 255.0)) != 100) {
        return;
    }

    float centerDepth = texelFetch(DepthSampler, ivec2(gl_FragCoord.xy) + ivec2(1, 0), 0).r;
    float leftDepth = texelFetch(DepthSampler, ivec2(gl_FragCoord.xy) + ivec2(-1, 0), 0).r;
    float upDepth = texelFetch(DepthSampler, ivec2(gl_FragCoord.xy) + ivec2(0, 1), 0).r;
    float downDepth = texelFetch(DepthSampler, ivec2(gl_FragCoord.xy) + ivec2(0, -1), 0).r;

    vec4 leftColor = texelFetch(InSampler, ivec2(gl_FragCoord.xy) + ivec2(-1, 0), 0);
    vec4 upColor = texelFetch(InSampler, ivec2(gl_FragCoord.xy) + ivec2(0, 1), 0);
    vec4 downColor = texelFetch(InSampler, ivec2(gl_FragCoord.xy) + ivec2(0, -1), 0);

    if (leftDepth < centerDepth) {
        centerDepth = leftDepth;
        fragColor = leftColor;
    }
    if (upDepth < centerDepth) {
        centerDepth = upDepth;
        fragColor = upColor;
    }
    if (downDepth < centerDepth) {
        fragColor = downColor;
    }
}