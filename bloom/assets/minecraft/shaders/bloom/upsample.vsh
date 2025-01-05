#version 150

#moj_import <minecraft:screenquad.glsl>

uniform vec2 OutSize;
uniform float Iteration;

flat out ivec2 inRes;
flat out ivec2 outRes;

void main() {
    gl_Position = screenquad[gl_VertexID];
    
    ivec2 size = ivec2(OutSize) >> int(Iteration - 1);
    inRes = size / 2;
    outRes = size;

    vec2 corner = (vec2(outRes) / OutSize) * 2.0 - 1.0;
    if (gl_Position.x > 0.0) gl_Position.x = corner.x;
    if (gl_Position.y > 0.0) gl_Position.y = corner.y;
}