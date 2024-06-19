#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D PreviousDataSampler;

const vec4[] corners = vec4[](
    vec4(-1, -1, 0, 1),
    vec4(1, -1, 0, 1),
    vec4(1, 1, 0, 1),
    vec4(-1, 1, 0, 1)
);

out vec3 offset;

int decodeInt(vec3 ivec) {
    ivec *= 255.0;
    int s = ivec.b >= 128.0 ? -1 : 1;
    return s * (int(ivec.r) + int(ivec.g) * 256 + (int(ivec.b) - 64 + s * 64) * 256 * 256);
}

float decodeFloat(vec3 ivec) {
    int v = decodeInt(ivec);
    return float(v) / 40000.0;
}

float decodeFloat1024(vec3 ivec) {
    int v = decodeInt(ivec);
    return float(v) / 1024.0;
}

void main() {
    vec4 outPos = corners[gl_VertexID];
    gl_Position = outPos;

    vec3 position;
    vec3 prevPosition;

    for (int i = 0; i < 3; i++) {
        vec4 color = texelFetch(DiffuseSampler, ivec2(25 + i, 0), 0);
        position[i] = decodeFloat(color.rgb) * 16;
    }

    for (int i = 0; i < 3; i++) {
        vec4 color = texelFetch(PreviousDataSampler, ivec2(25 + i, 0), 0);
        prevPosition[i] = decodeFloat(color.rgb) * 16;
    }

    offset = mod(floor(position) - floor(prevPosition) + 8.0, 16.0) - 8.0;
}