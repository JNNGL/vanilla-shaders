#version 330

// #extension GL_MC_moj_import : enable
#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:datamarker.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

uniform mat4 ProjMat;
uniform mat4 ModelViewMat;
uniform vec3 ModelOffset;
uniform float GameTime;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;

flat in int isVoxel;
flat in vec3 voxelData;

flat in int dataQuad;

out vec4 fragColor;

void main() {
    if (dataQuad > 0) {
        ivec2 pixel = ivec2(floor(gl_FragCoord.xy));
        if (discardDataMarker(pixel)) {
            discard;
        }

        fragColor = writeDataMarker(pixel, /*jitteredProj*/ ProjMat, FogStart, FogEnd, ModelOffset, GameTime, mat3(ModelViewMat), ProjMat[2].xy);
        return;
    }

    if (isVoxel > 0) {
        fragColor = vec4(voxelData, 100.0 / 255.0);
// #ifdef TRANSLUCENT
//         fragColor.a = 1.0;
// #endif // TRANSLUCENT
        return;
    }

    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
#ifdef ALPHA_CUTOUT
    if (color.a < ALPHA_CUTOUT) {
        discard;
    }
#endif
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
#ifndef TRANSLUCENT
    fragColor.a = 1.0;
// #else
//     fragColor.b = min(fragColor.b, 239.0 / 255.0);
#endif // TRANSLUCENT
}
