#version 150

#moj_import <minecraft:fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0);
    vec4 lodColor = textureLod(Sampler0, texCoord0, -4);

#ifdef ALPHA_CUTOUT
    if (color.a < ALPHA_CUTOUT) {
        discard;
    }
#endif

#ifndef TRANSLUCENT
    int alpha = int(round(lodColor.a * 255.0));
    if (alpha < 230 || alpha > 250) {
        color *= vertexColor * ColorModulator;
        color.a = 1.0;
    } else {
        color.a = lodColor.a;
    }
#else
    color *= vertexColor * ColorModulator;
#endif

    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
#ifndef TRANSLUCENT
    fragColor.a = color.a;
#endif
}
