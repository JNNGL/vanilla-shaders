#version 150

#moj_import <minecraft:light.glsl>
#moj_import <minecraft:fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler0;
uniform sampler2D Sampler1;
uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat4 TextureMat;
uniform int FogShape;
uniform float FogStart;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

out float vertexDistance;
out vec4 vertexColor;
out vec4 lightMapColor;
out vec4 overlayColor;
out vec2 texCoord0;
out vec2 texCoord1;
out vec4 corner0;
out vec4 corner1;

const ivec4 armUV[] = ivec4[](
    ivec4(40, 52, 36, 64), // Front
    ivec4(44, 64, 48, 52), // Back
    ivec4(36, 64, 32, 52), // Outer Side
    ivec4(44, 52, 40, 48), // Bottom
    ivec4(40, 52, 44, 64), // Inner Side
    ivec4(36, 52, 40, 48)  // Top
);
const ivec4 slimArmUV[] = ivec4[]( // 40 -> 39 ; 48 -> 46 ; 44 -> 43
    ivec4(39, 52, 36, 64), // Front
    ivec4(43, 64, 46, 52), // Back
    ivec4(36, 64, 32, 52), // Outer Side
    ivec4(42, 52, 39, 48), // Bottom
    ivec4(39, 52, 43, 64), // Inner Side
    ivec4(36, 52, 39, 48)  // Top
);
const bool armRotateUV[] = bool[](
    false, false, true, false, true, false
);

bool isSlim() {
    // from stable_player_display
    vec4 samp1 = texture(Sampler0, vec2(54.0 / 64.0, 20.0 / 64.0));
    vec4 samp2 = texture(Sampler0, vec2(55.0 / 64.0, 20.0 / 64.0));
    return samp1.a == 0.0 || (((samp1.r + samp1.g + samp1.b) == 0.0) && ((samp2.r + samp2.g + samp2.b) == 0.0) && samp1.a == 1.0 && samp2.a == 1.0);
}

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    int part = gl_VertexID / 48 % 2;
    int face = (gl_VertexID % 48) / 4;
    int vertex = gl_VertexID % 4;
    bool slim = isSlim();

    vertexDistance = fog_distance(Position, FogShape);
#ifdef NO_CARDINAL_LIGHTING
    vertexColor = Color;
#else
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color);
#endif
    lightMapColor = texelFetch(Sampler2, UV2 / 16, 0);
    overlayColor = texelFetch(Sampler1, UV1, 0);

    texCoord0 = UV0;
#ifdef APPLY_TEXTURE_MATRIX
    texCoord0 = (TextureMat * vec4(UV0, 0.0, 1.0)).xy;
#endif

    texCoord1 = texCoord0;
    if (FogStart > 3e38 && ProjMat[2][3] != 0) {
        ivec4 uvData = slim ? slimArmUV[face % 6] : armUV[face % 6];
        bool rotate = armRotateUV[face % 6];
        if (part == 0) {
            if (face >= 6) uvData.xz += 16;
        } else if (part == 1) {
            uvData += ivec4(8, -32, 8, -32);
            if (face >= 6) uvData.yw += 16;
        }

        if (uvData.x != -1) {
            ivec2 uv;
            switch (vertex) {
                case 0: uv = uvData.xy; break;
                case 1: uv = rotate ? uvData.xw : uvData.zy; break;
                case 2: uv = uvData.zw; break;
                case 3: uv = rotate ? uvData.zy : uvData.xw; break;
            }

            texCoord1 = vec2(uv) / 64.0;
        }
    }

    corner0 = corner1 = vec4(0.0);
    switch (gl_VertexID % 4) {
        case 0: corner0 = vec4(Position, 1.0); break;
        case 2: corner1 = vec4(Position, 1.0); break;
    }
}
