#version 330

// #extension GL_MC_moj_import : enable
#moj_import <minecraft:screenquad.glsl>

out vec2 texCoord;

void main() {
    gl_Position = screenquad[gl_VertexID];
    texCoord = sqTexCoord(gl_Position);
}