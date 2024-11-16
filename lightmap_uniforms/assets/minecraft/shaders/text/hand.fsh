#version 150

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:lightmap_inputs.glsl>
#moj_import <minecraft:text.glsl>

uniform sampler2D Sampler0;
uniform sampler2D Sampler2;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec4 lightMapColor;
in vec4 overlayColor;
in vec2 texCoord0;

in float renderInfo;
in vec4 glPos;

out vec4 fragColor;

void main() {
    ivec2 screenSize = ivec2(gl_FragCoord.xy / (glPos.xy / glPos.w * 0.5 + 0.5));
    ivec2 fragCoord = ivec2(gl_FragCoord.x, screenSize.y - 1 - floor(gl_FragCoord.y));

    if (renderInfo > 0.0) {
        resetText(fragCoord);
        vec4 color1 = vec4(0.7, 0.7, 0.7, 1.0);
        vec4 color2 = vec4(0.5, 0.5, 0.5, 1.0);

        setTextColor(color1);
        c(_A);c(_M);c(_B);c(_I);c(_E);c(_N);c(_T);c(_L);c(_I);c(_G);c(_H);c(_T);c(_F);c(_A);c(_C);c(_T);c(_O);c(_R);c(_SPACE);
        setTextColor(color2);
        f(getAmbientLightFactor(Sampler2));
        nl();

        setTextColor(color1);
        c(_S);c(_K);c(_Y);c(_F);c(_A);c(_C);c(_T);c(_O);c(_R);c(_SPACE);
        setTextColor(color2);
        f(getSkyFactor(Sampler2));
        nl();

        setTextColor(color1);
        c(_B);c(_L);c(_O);c(_C);c(_K);c(_F);c(_A);c(_C);c(_T);c(_O);c(_R);c(_SPACE);
        setTextColor(color2);
        f(getBlockFactor(Sampler2));
        nl();
        
        setTextColor(color1);
        c(_B);c(_R);c(_I);c(_G);c(_H);c(_T);c(_L);c(_I);c(_G);c(_H);c(_T);c(_M);c(_A);c(_P);c(_SPACE);
        setTextColor(color2);
        f(getUseBrightLightmap(Sampler2));
        nl();

        setTextColor(color1);
        c(_S);c(_K);c(_Y);c(_L);c(_I);c(_G);c(_H);c(_T);c(_C);c(_O);c(_L);c(_O);c(_R);c(_SPACE);
        setTextColor(color2);
        cb(getSkyLightColor(Sampler2));
        nl();

        setTextColor(color1);
        c(_N);c(_I);c(_G);c(_H);c(_T);c(_V);c(_I);c(_S);c(_I);c(_O);c(_N);c(_SPACE);
        setTextColor(color2);
        f(getNightVisionFactor(Sampler2));
        nl();

        setTextColor(color1);
        c(_D);c(_A);c(_R);c(_K);c(_N);c(_E);c(_S);c(_S);c(_S);c(_C);c(_A);c(_L);c(_E);c(_SPACE);
        setTextColor(color2);
        f(getDarknessScale(Sampler2));
        nl();

        setTextColor(color1);
        c(_D);c(_A);c(_R);c(_K);c(_E);c(_N);c(_W);c(_O);c(_R);c(_L);c(_D);c(_SPACE);
        setTextColor(color2);
        f(getDarkenWorldFactor(Sampler2));
        nl();

        setTextColor(color1);
        c(_B);c(_R);c(_I);c(_G);c(_H);c(_T);c(_N);c(_E);c(_S);c(_S);c(_SPACE);
        setTextColor(color2);
        f(getBrightnessFactor(Sampler2));
        nl();

        fragColor = getTextPixelColor();
        if (fragColor.a < 0.1) discard;
        return;
    }

    vec4 color = texture(Sampler0, texCoord0);
#ifdef ALPHA_CUTOUT
    if (color.a < ALPHA_CUTOUT) {
        discard;
    }
#endif
    color *= vertexColor * ColorModulator;
#ifndef NO_OVERLAY
    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
#endif
#ifndef EMISSIVE
    color *= lightMapColor;
#endif
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}
