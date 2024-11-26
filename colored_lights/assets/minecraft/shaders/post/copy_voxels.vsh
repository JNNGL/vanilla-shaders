#version 330

// #extension GL_MC_moj_import : enable
#moj_import <minecraft:screenquad.glsl>
#moj_import <minecraft:datamarker.glsl>
#moj_import <minecraft:voxelization.glsl>

uniform sampler2D HistorySampler;
uniform sampler2D DataSampler;
uniform sampler2D PreviousDataSampler;

uniform vec2 InSize;

out vec2 texCoord;
flat out int hasHistory;
flat out ivec2 voxelizeDist;
flat out ivec3 blockOffset;

void main() {
    gl_Position = screenquad[gl_VertexID];
    texCoord = sqTexCoord(gl_Position);

    ivec4 marker = ivec4(round(texelFetch(HistorySampler, ivec2(0, 0), 0) * 255.0));
    hasHistory = int(marker == ivec4(123, 123, 123, 123));

    vec3 position = decodeChunkOffset(DataSampler);
    vec3 prevPosition = decodeChunkOffset(PreviousDataSampler);
    blockOffset = ivec3(mod(floor(position) - floor(prevPosition) + 8.0, 16.0) - 8.0);

    voxelizeDist = getVoxelizationRadius(ivec2(InSize));
}