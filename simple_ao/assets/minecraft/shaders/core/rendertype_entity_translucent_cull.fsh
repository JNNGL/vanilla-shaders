// simple ao
// https://github.com/JNNGL/vanilla-shaders

#version 150

#moj_import <fog.glsl>
#moj_import <light.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;
uniform float GameTime;

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
        if (pixel.y >= 1.0 || pixel.x >= 38.0) {
            discard;
        }

        vec3 pos0 = position0.xyz / position0.w;
        vec3 pos1 = position1.xyz / position1.w;
        vec3 pos2 = position2.xyz / position2.w;
        vec3 pos3 = position3.xyz / position3.w;
        vec3 pos = mix(pos0, pos2, 0.5);

        // Data
        // 0-15 - projection matrix
        // 16 - fog start
        // 17 - fog end
        // 18-33 - view matrix
        // 34-36 - position
        // 37 - game time
        if (pixel.x < 16) {
            int index = int(pixel.x);
            float value = ProjMat[index / 4][index % 4];
            fragColor = encodeFloat(value);
        } else if (pixel.x == 16) {
            fragColor = encodeFloat1024(FogStart);
        } else if (pixel.x == 17) {
            fragColor = encodeFloat1024(FogEnd);
        } else if (pixel.x < 34) {
            int index = int(pixel.x - 18);
            float value = ModelViewMat[index / 4][index % 4];
            fragColor = encodeFloat(value);
        } else if (pixel.x < 37) {
            fragColor = encodeFloat1024(pos[int(pixel.x - 34)]);
        } else if (pixel.x == 37) {
            fragColor = encodeFloat(GameTime * 2400);
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
