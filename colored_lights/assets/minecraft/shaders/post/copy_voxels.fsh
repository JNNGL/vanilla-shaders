#version 330

// #extension GL_MC_moj_import : enable
#moj_import <minecraft:encodings.glsl>
#moj_import <minecraft:voxelization.glsl>

uniform sampler2D InSampler;
uniform sampler2D DepthSampler;
uniform sampler2D HistorySampler;

uniform vec2 InSize;

in vec2 texCoord;
flat in int hasHistory;
flat in ivec2 voxelizeDist;
flat in ivec3 blockOffset;

out vec4 fragColor;

void main() {
    if (int(gl_FragCoord.y) == 0) {
        fragColor = vec4(0.0);
        return;
    }

    vec4 history = encodeLogLuv(vec3(0.0));
    if (hasHistory > 0) {
        ivec2 pixelPos = ivec2(gl_FragCoord.xy);
        if (blockOffset != ivec3(0, 0, 0)) {
            ivec3 voxelPos = pixelToVoxel(pixelPos, ivec2(InSize), voxelizeDist);
            voxelPos -= blockOffset;
            pixelPos = voxelToPixel(voxelPos, ivec2(InSize), voxelizeDist);
        }
        if (clamp(pixelPos, ivec2(0, 1), ivec2(InSize) - 1) == pixelPos) {
            history = texelFetch(HistorySampler, pixelPos, 0);
        }
    }
    vec3 historyColor = vec3(0.0);
    if (history != vec4(1.0)) {
        historyColor = decodeLogLuv(history);
    }

    vec4 color = texture(InSampler, texCoord);
    int alpha = int(round(color.a * 255.0));
    if (alpha != 100 || texture(DepthSampler, texCoord).r == 1.0) {
        fragColor = encodeLogLuv(vec3(0.0));
        if (history != vec4(1.0)) fragColor = history;
        return;
    }

    if (color.rgb == vec3(0.0)) {
        fragColor = vec4(1.0);
        return;
    }

    uint lightLevel;
    vec3 lightColor = decodeYCoCg776(color.rgb, lightLevel);
    lightColor *= lightColor * (float(lightLevel * lightLevel) + 0.5);
    
    fragColor = encodeLogLuv(lightColor);
}