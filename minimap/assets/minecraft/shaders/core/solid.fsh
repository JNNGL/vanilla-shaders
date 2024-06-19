#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;
uniform mat4 ModelViewMat;
uniform vec3 ChunkOffset;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec4 normal;
in vec3 position;
in float minimapQuad;
in vec3 minimapData;
in vec4 glPos;
flat in vec2 voxelCoord;
in float dataQuad;

out vec4 fragColor;

vec4 encodeInt(int i) {
    int s = int(i < 0) * 128;
    i = abs(i);
    int r = i % 256;
    i = i / 256;
    int g = i % 256;
    i = i / 256;
    int b = i % 256;
    return vec4(float(r) / 255.0, float(g) / 255.0, float(b + s) / 255.0, 1.0);
}

vec4 encodeFloat1024(float v) {
    v *= 1024.0;
    v = floor(v);
    return encodeInt(int(v));
}

vec4 encodeFloat(float v) {
    v *= 40000.0;
    v = floor(v);
    return encodeInt(int(v));
}

void main() {
    gl_FragDepth = gl_FragCoord.z;

    if (dataQuad == 1.0) {
        gl_FragDepth = 0.0;
        ivec2 coord = ivec2(gl_FragCoord.xy);

        if (coord.y == 0) {
            if (coord.x >= 16 && coord.x < 25) {
                int index = coord.x - 16;
                mat3 viewMat = transpose(mat3(ModelViewMat));
                fragColor = encodeFloat(viewMat[index / 3][index % 3]);
                return;
            } else if (coord.x >= 25 && coord.x < 28) {
                int index = coord.x - 25;
                fragColor = encodeFloat(mod(ChunkOffset[index], 16.0) / 16.0);
                return;
            }
        }

        discard;
    }

    if (minimapQuad > 0.0) {
        ivec2 screenSize = ivec2(round(gl_FragCoord.xy / (glPos.xy / glPos.w * 0.5 + 0.5)));
        ivec2 coord = ivec2(round(voxelCoord * screenSize));
        ivec2 fragCoord = ivec2(gl_FragCoord.xy);
        if (fragCoord == coord) {
            fragColor = vec4(minimapData, 249.0 / 255.0);
        } else {
            discard;
        }

        return;
    }

    vec4 color = texture(Sampler0, texCoord0);
    if (color.a < 0.1) {
        discard;
    }

    color *= vertexColor * ColorModulator;
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}