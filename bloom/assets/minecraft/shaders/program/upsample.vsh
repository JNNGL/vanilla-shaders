#version 150

in vec4 Position;

uniform vec2 OutSize;
uniform float Iteration;

flat out ivec2 inRes;
flat out ivec2 outRes;

const vec4[] corners = vec4[](
    vec4(-1, -1, 0, 1),
    vec4(1, -1, 0, 1),
    vec4(1, 1, 0, 1),
    vec4(-1, 1, 0, 1)
);

void main() {
    vec4 outPos = corners[gl_VertexID];
    gl_Position = outPos;

    ivec2 size = ivec2(OutSize) >> int(Iteration - 1);
    inRes = size / 2;
    outRes = size;
}