#version 330

// #extension GL_MC_moj_import : enable
#moj_import <minecraft:encodings.glsl>
#moj_import <minecraft:projections.glsl>
#moj_import <minecraft:voxelization.glsl>

uniform sampler2D InSampler;

uniform vec2 InSize;

in vec2 texCoord;
flat in ivec2 voxelizeDist;

out vec4 fragColor;

void main() {
    if (int(gl_FragCoord.y) == 0) {
        fragColor = vec4(123.0 / 255.0);
        return;
    }

    fragColor = texture(InSampler, texCoord);
    if (fragColor == vec4(1.0)) {
        return; // block
    }

    const ivec3 neighbourOffsets[] = ivec3[](
        ivec3(1, 0, 0), ivec3(-1, 0, 0),
        ivec3(0, 1, 0), ivec3(0, -1, 0),
        ivec3(0, 0, 1), ivec3(0, 0, -1)
    );

    vec3 lightColor = decodeLogLuv(fragColor);

    ivec3 voxelPos = pixelToVoxel(ivec2(gl_FragCoord.xy), ivec2(InSize), voxelizeDist);
    for (int i = 0; i < 6; i++) {
        ivec3 neighbourPos = voxelPos + neighbourOffsets[i];
        ivec2 pixelPos = voxelToPixel(neighbourPos, ivec2(InSize), voxelizeDist);
        if (clamp(pixelPos, ivec2(0, 1), ivec2(InSize) - 1) != pixelPos) continue;

        vec4 nData = texelFetch(InSampler, pixelPos, 0);

        if (nData != vec4(1.0)) {
            vec3 light = decodeLogLuv(nData);
            lightColor += light;
        }
    }

    lightColor /= 7.0;
    lightColor *= 0.99;
    
    fragColor = encodeLogLuv(lightColor);
}