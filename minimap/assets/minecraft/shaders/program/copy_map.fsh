// minimap
// https://github.com/JNNGL/vanilla-shaders

#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;
uniform sampler2D PreviousSampler;
uniform vec2 InSize;
uniform vec2 OutSize;

in vec3 offset;

out vec4 fragColor;

void main() {
    ivec2 screenPos = ivec2(floor(gl_FragCoord.xy + vec2(0, 1)));
    screenPos.x = screenPos.x * 2 + screenPos.y % 2;
    ivec2 coord = ivec2(round(vec2(screenPos) / (OutSize + vec2(OutSize.x, 1)) * InSize));
    vec4 color = texelFetch(DiffuseSampler, coord, 0);
    float depth = texelFetch(DiffuseDepthSampler, coord, 0).r;
    int height = int(-(depth * 2.0 - 1.0) * 1024);

    ivec3 blockOff = ivec3(offset);
    ivec2 prevCoord = ivec2(gl_FragCoord.xy) - blockOff.xz;
    fragColor = texelFetch(PreviousSampler, prevCoord, 0);

    int prevHeight = int(fragColor.g * 255.0) << 8 | int(fragColor.b * 255.0);
    prevHeight += blockOff.y;

    fragColor.gb = vec2(float(prevHeight >> 8) / 255.0, float(prevHeight & 0xFF) / 255.0);

    if (color.a == 249.0 / 255.0 && (height >= prevHeight || fragColor.a < 1.0)) {
        fragColor = vec4(color.r, float(height >> 8) / 255.0, float(height & 0xFF) / 255.0, 1.0);
    }
}
