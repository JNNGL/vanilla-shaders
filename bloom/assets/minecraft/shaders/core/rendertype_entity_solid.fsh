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
    bool notEmissive = color.a < 230.0 / 255.0 || color.a > 250.0 / 255.0;
    if (notEmissive) color *= vertexColor;
    color *= ColorModulator;
    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
    if (notEmissive) color *= lightMapColor;
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}
