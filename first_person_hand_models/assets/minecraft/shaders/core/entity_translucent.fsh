#version 150

#moj_import <minecraft:fog.glsl>

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
in vec2 texCoord1;
in vec4 corner0;
in vec4 corner1;

out vec4 fragColor;

const vec3 HAND_MODEL_SCALE = vec3(0.471, 0.515, 1.515);

const vec3 modelScaleF = 0.5 * HAND_MODEL_SCALE;
const vec3 modelScaleS = modelScaleF + (0.25 / 8.0) * HAND_MODEL_SCALE;
const vec3 hRefF = vec3(length(modelScaleF.xz), length(modelScaleF.yz), length(modelScaleF.xy));
const vec3 hRefS = vec3(length(modelScaleS.xz), length(modelScaleS.yz), length(modelScaleS.xy));

bool testDim(float h, float hRef) {
    return abs(h - hRef) < 0.001;
}
bool testDims(float h, vec3 hRef) {
    return testDim(h, hRef.x) || testDim(h, hRef.y) || testDim(h, hRef.z);
}

void main() {
    vec2 texCoord = texCoord0;

    if (corner0.w != 0.0 && corner1.w != 0.0) {
        float h = length(corner0.xyz / corner0.w - corner1.xyz / corner1.w);
        if (testDims(h, hRefF) || testDims(h, hRefS)) {
            texCoord = texCoord1;
        }
    }

    vec4 color = texture(Sampler0, texCoord);

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
