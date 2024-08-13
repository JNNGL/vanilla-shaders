// bloom
// https://github.com/JNNGL/vanilla-shaders

#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec4 lightMapColor;
in vec4 overlayColor;
in vec2 texCoord0;
in vec4 normal;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0);
    if (color.a < 0.1) {
        discard;
    }
    vec4 lodColor = textureLod(Sampler0, texCoord0, 0);
    bool notEmissive = lodColor.a < 230.0 / 255.0 || lodColor.a > 250.0 / 255.0;
    if (notEmissive) {
        color *= vertexColor;
        if (color.a >= 229.0 / 255.0 && color.a <= 251 / 255.0)
            color.a = color.a > 240.0 / 255.0 ? 251.0 / 255.0 : 229.0 / 255.0;
    }
    color *= ColorModulator;
    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
    if (notEmissive) color *= lightMapColor;
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}
