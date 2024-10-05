// motion blur
// https://github.com/JNNGL/vanilla-shaders

#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;
uniform float GameTime;
uniform mat4 ProjMat;
uniform mat4 ModelViewMat;
uniform vec3 ChunkOffset;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
flat in int dataQuad;

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

vec4 encodeFloat(float v) {
    v *= 40000.0;
    v = floor(v);
    return encodeInt(int(v));
}

vec4 encodeFloat1024(float v) {
    v *= 1024.0;
    v = floor(v);
    return encodeInt(int(v));
}

void main() {
    if (dataQuad > 0) {
        vec2 pixel = floor(gl_FragCoord.xy);
        if (pixel.y >= 1.0 || pixel.x >= 28.0) {
            discard;
        }

        // Data
        // 0-15 - projection matrix
        // 16-24 - view matrix
        // 25-27 - position
        if (pixel.x < 16) {
            int index = int(pixel.x);
            int c = index / 4;
            int r = index % 4;
            float value = ProjMat[c][r];
            if (c == r && c < 2) value = atan(value);
            fragColor = encodeFloat(value);
        } else if (pixel.x < 25) {
            int index = int(pixel.x) - 16;
            float value = transpose(mat3(ModelViewMat))[index / 3][index % 3];
            fragColor = encodeFloat(value);
        } else if (pixel.x < 28) {
            fragColor = encodeFloat1024(mod(ChunkOffset[int(pixel.x) - 25], 16.0));
        }
        return;
    }

    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    if (color.a < 0.1) {
        discard;
    }
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}
