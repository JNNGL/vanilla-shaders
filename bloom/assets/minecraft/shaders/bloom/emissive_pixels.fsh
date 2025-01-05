// bloom
// https://github.com/JNNGL/vanilla-shaders

#version 150

#moj_import <minecraft:hdr.glsl>

uniform sampler2D InSampler;
uniform sampler2D DepthSampler;

in vec2 texCoord;

out vec4 fragColor;

void main() {
    fragColor = encodeLogLuv(vec3(0.0));
    
    vec4 col = texture(InSampler, texCoord);
    if (texture(DepthSampler, texCoord).r == 1.0) {
        return;
    }
    
    int alpha = int(round(col.a * 255.0));
    if (alpha >= 230 && alpha <= 250) {
        fragColor = encodeLogLuv(pow(col.rgb, vec3(2.2)) * float(alpha - 229));
    }
}
