#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D PreviousDataSampler;

out vec2 texCoord;
flat out mat4 invProjMat;
flat out mat3 invViewMat;
flat out mat4 prevProjMat;
flat out mat3 prevViewMat;
flat out vec3 cameraOffset;

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
    
    mat4 projection;

    for (int i = 0; i < 16; i++) {
        vec4 color = texelFetch(DiffuseSampler, ivec2(i, 0), 0);
        projection[i / 4][i % 4] = decodeFloat(color.rgb);
    }

    projection[0][0] = tan(projection[0][0]);
    projection[1][1] = tan(projection[1][1]);
    projection[3][0] = 0.0;
    projection[3][1] = 0.0;

    for (int i = 0; i < 9; i++) {
        vec4 color = texelFetch(DiffuseSampler, ivec2(i + 16, 0), 0);
        invViewMat[i / 3][i % 3] = decodeFloat(color.rgb);
    }

    invProjMat = inverse(projection);

    for (int i = 0; i < 16; i++) {
        vec4 color = texelFetch(PreviousDataSampler, ivec2(i, 0), 0);
        prevProjMat[i / 4][i % 4] = decodeFloat(color.rgb);
    }

    prevProjMat[0][0] = tan(prevProjMat[0][0]);
    prevProjMat[1][1] = tan(prevProjMat[1][1]);
    prevProjMat[3][0] = 0.0;
    prevProjMat[3][1] = 0.0;

    for (int i = 0; i < 9; i++) {
        vec4 color = texelFetch(PreviousDataSampler, ivec2(i + 16, 0), 0);
        prevViewMat[i / 3][i % 3] = decodeFloat(color.rgb);
    }

    prevViewMat = transpose(prevViewMat);

    vec3 position;
    vec3 prevPosition;

    for (int i = 0; i < 3; i++) {
        vec4 color = texelFetch(DiffuseSampler, ivec2(25 + i, 0), 0);
        position[i] = decodeFloat1024(color.rgb);
    }

    for (int i = 0; i < 3; i++) {
        vec4 color = texelFetch(PreviousDataSampler, ivec2(25 + i, 0), 0);
        prevPosition[i] = decodeFloat1024(color.rgb);
    }

    cameraOffset = position - prevPosition;
    texCoord = outPos.xy * 0.5 + 0.5;
}
