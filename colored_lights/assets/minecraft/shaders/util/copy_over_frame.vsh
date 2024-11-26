#version 330

// #extension GL_MC_moj_import : enable
#moj_import <minecraft:screenquad.glsl>

uniform vec2 InSize;
uniform vec2 OutSize;

void main() {
    vec2 size = min(OutSize, InSize + 1.0);
    vec2 topRight = (size / OutSize) * 2.0 - 1.0;

    gl_Position = screenquad[gl_VertexID];
    if (gl_Position.x > 0.0) gl_Position.x = topRight.x;
    if (gl_Position.y > 0.0) gl_Position.y = topRight.y;
}