#version 330

// #extension GL_MC_moj_import : enable
#moj_import <minecraft:screenquad.glsl>
#moj_import <minecraft:datamarker.glsl>
#moj_import <minecraft:voxelization.glsl>

uniform sampler2D DataSampler;

uniform mat4 ModelViewMat;
uniform vec2 DataSize;

out vec2 texCoord;
flat out mat4 invProjView;
flat out vec3 blockOffset;
flat out ivec2 voxelizeDist;

void main() {
    gl_Position = screenquad[gl_VertexID];
    texCoord = sqTexCoord(gl_Position);

    mat4 projection = decodeProjectionMatrix(DataSampler);
    invProjView = inverse(projection * ModelViewMat);
    blockOffset = fract(decodeChunkOffset(DataSampler));
    voxelizeDist = getVoxelizationRadius(ivec2(DataSize));
}