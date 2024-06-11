#version 150

in vec4 Position;

uniform sampler2D DiffuseSampler;

uniform mat4 ProjMat;
uniform vec2 OutSize;

out vec2 texCoord;
flat out mat4 invProj;
flat out float fogStart;
flat out float fogEnd;

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

const vec4[] corners = vec4[](
    vec4(-1, -1, 0, 1),
    vec4(1, -1, 0, 1),
    vec4(1, 1, 0, 1),
    vec4(-1, 1, 0, 1)
);

void main() {
    vec4 outPos = corners[gl_VertexID];
    gl_Position = outPos;

    for (int i = 0; i < 16; i++) {
        vec4 color = texelFetch(DiffuseSampler, ivec2(i, 0), 0);
        invProj[i / 4][i % 4] = decodeFloat(color.rgb);
    }

    invProj = inverse(invProj);

    fogStart = decodeFloat1024(texelFetch(DiffuseSampler, ivec2(16, 0), 0).rgb);
    fogEnd = decodeFloat1024(texelFetch(DiffuseSampler, ivec2(17, 0), 0).rgb);

    texCoord = outPos.xy * 0.5 + 0.5;
}