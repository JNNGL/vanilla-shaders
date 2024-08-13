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
in vec2 texCoord0;
in vec2 texCoord1;
in vec4 normal;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0);
    vec4 lodColor = textureLod(Sampler0, texCoord0, 0);
    if (lodColor.a < 230.0 / 255.0 || lodColor.a > 250.0 / 255.0) {
        color *= vertexColor;
        if (color.a >= 229.0 / 255.0 && color.a <= 251 / 255.0)
            color.a = color.a > 240.0 / 255.0 ? 251.0 / 255.0 : 229.0 / 255.0;
    }
    color *= ColorModulator;
    if (color.a < 0.1) {
        discard;
    }
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}
