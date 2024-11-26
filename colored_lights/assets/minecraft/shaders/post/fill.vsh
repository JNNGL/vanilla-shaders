#version 330

// #extension GL_MC_moj_import : enable
#moj_import <minecraft:screenquad.glsl>
#moj_import <minecraft:datamarker.glsl>
#moj_import <minecraft:voxelization.glsl>

uniform vec2 InSize;

out vec2 texCoord;
flat out ivec2 voxelizeDist;

void main() {
    gl_Position = screenquad[gl_VertexID];
    texCoord = sqTexCoord(gl_Position);

    voxelizeDist = getVoxelizationRadius(ivec2(InSize));
}