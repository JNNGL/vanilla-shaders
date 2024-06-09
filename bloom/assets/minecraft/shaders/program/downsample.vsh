#version 150

in vec4 Position;

uniform vec2 OutSize;
uniform float Iteration;

out vec2 texCoord;
flat out ivec2 inRes;
flat out ivec2 outRes;
flat out float scale;
flat out float prevScale;

const vec4[] corners = vec4[](
    vec4(-1, -1, 0, 1),
    vec4(1, -1, 0, 1),
    vec4(1, 1, 0, 1),
    vec4(-1, 1, 0, 1)
);

void main() {
    vec4 outPos = corners[gl_VertexID];
    gl_Position = outPos;

    scale = pow(0.5, round(Iteration));
    prevScale = pow(0.5, round(Iteration - 1.0));
    inRes = ivec2(round(OutSize * prevScale));
    outRes = ivec2(round(OutSize * scale));

    texCoord = (outPos.xy * 0.5 + 0.5) / scale;
}