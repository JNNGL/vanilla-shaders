#version 150

in vec4 Position;

uniform sampler2D DiffuseSampler;

uniform mat4 ProjMat;
uniform vec2 OutSize;

out vec2 texCoord;
flat out mat4 projection;
flat out mat4 projInv;
flat out mat3 tbn;

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
        projection[i / 4][i % 4] = decodeFloat(color.rgb);
    }

    projection[3][0] = 0.0;
    projection[3][1] = 0.0;

    projInv = inverse(projection);

    float tx = decodeFloat(texelFetch(DiffuseSampler, ivec2(35, 0), 0).rgb);
    float ty = decodeFloat(texelFetch(DiffuseSampler, ivec2(36, 0), 0).rgb);
    float tz = decodeFloat(texelFetch(DiffuseSampler, ivec2(37, 0), 0).rgb);
    float bx = decodeFloat(texelFetch(DiffuseSampler, ivec2(38, 0), 0).rgb);
    float by = decodeFloat(texelFetch(DiffuseSampler, ivec2(39, 0), 0).rgb);
    float bz = decodeFloat(texelFetch(DiffuseSampler, ivec2(40, 0), 0).rgb);
    vec3 tangent = normalize(vec3(tx, ty, tz));
    vec3 bitangent = normalize(vec3(bx, by, bz));
    tbn = mat3(tangent, bitangent, normalize(cross(bitangent, tangent)));

    texCoord = outPos.xy;
}