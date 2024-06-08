#version 150

#moj_import <fog.glsl>
#moj_import <light.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

uniform mat4 ProjMat;
uniform mat3 IViewRotMat;
uniform mat4 ModelViewMat;

in float vertexDistance;
in vec4 vertexColor;
in vec4 lightMapColor;
in vec4 overlayColor;
in vec2 texCoord0;
in vec4 normal;
in float marker;
in vec4 position0;
in vec4 position1;
in vec4 position2;
in vec4 position3;

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
    if (marker == 1.0) {
        vec2 pixel = floor(gl_FragCoord.xy);
        if (pixel.y >= 1.0 || pixel.x >= 28.0) {
            discard;
        }

        vec3 pos0 = position0.xyz / position0.w;
        vec3 pos1 = position1.xyz / position1.w;
        vec3 pos2 = position2.xyz / position2.w;
        vec3 pos3 = position3.xyz / position3.w;
        vec3 pos = pos0 * 0.5 + pos2 * 0.5;

        vec3 pPos = gl_PrimitiveID % 2 == 0 ? pos1 : pos3;
        vec3 tangent = normalize(gl_PrimitiveID % 2 == 1 ? pPos - pos0 : pos2 - pPos);
        vec3 bitangent = normalize(gl_PrimitiveID % 2 == 0 ? pPos - pos0 : pos2 - pPos);

        // Data
        // 0-15 - projection matrix
        // 16-24 - view matrix
        // 25-27 - position
        if (pixel.x < 16) {
            mat4 mvp = ProjMat;
            int index = int(pixel.x);
            int c = index / 4;
            int r = index % 4;
            float value = mvp[c][r];
            if (c == r && c < 2) value = atan(value);
            fragColor = encodeFloat(value);
        } else if (pixel.x < 25) {
            int index = int(pixel.x) - 16;
            float value = IViewRotMat[index / 3][index % 3];
            fragColor = encodeFloat(value);
        } else if (pixel.x < 28) {
            fragColor = encodeFloat1024(pos[int(pixel.x) - 25]);
        }
        return;
    }

    vec4 color = texture(Sampler0, texCoord0);
    if (color.a < 0.1) {
        discard;
    }
    color *= vertexColor * ColorModulator;
    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
    color *= lightMapColor;
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}