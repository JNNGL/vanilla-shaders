#version 330

// #extension GL_MC_moj_import : enable
#moj_import <minecraft:encodings.glsl>

uniform sampler2D InSampler;
uniform sampler2D TranslucentSampler;

in vec2 texCoord;

out vec4 fragColor;

void main() {
    fragColor = vec4(0.0);
    if (int(gl_FragCoord.y) == 0) {
        return;
    }

    vec4 sample = texture(TranslucentSampler, texCoord);
    ivec4 color = ivec4(round(sample * 255.0));
    if (color.a == 255 && color.b > 239) {
        uint t;
        fragColor = vec4(decodeYCoCg776(sample.rgb, t), 1.0);
    }
}