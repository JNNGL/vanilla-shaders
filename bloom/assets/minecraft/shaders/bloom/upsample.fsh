// bloom
// https://github.com/JNNGL/vanilla-shaders

#version 150

#moj_import <minecraft:hdr.glsl>

uniform sampler2D InSampler;
uniform sampler2D DownsampledSampler;
uniform vec2 OutSize;

flat in ivec2 inRes;
flat in ivec2 outRes;

out vec4 fragColor;

vec3 bilinear(sampler2D s, vec2 tex) {
    tex *= inRes;
    tex -= 0.5;

    ivec2 coord = ivec2(floor(tex));
    vec2 frac = fract(tex);

    return mix(
        mix(decodeLogLuv(texelFetch(s, coord + ivec2(0, 0), 0)), decodeLogLuv(texelFetch(s, coord + ivec2(1, 0), 0)), frac.x),
        mix(decodeLogLuv(texelFetch(s, coord + ivec2(0, 1), 0)), decodeLogLuv(texelFetch(s, coord + ivec2(1, 1), 0)), frac.x),
        frac.y);
}

void main() {
    ivec2 coord = ivec2(gl_FragCoord.xy);
    if (any(greaterThanEqual(coord, outRes))) {
        fragColor = vec4(0.0);
        return;
    }

    vec2 texCoord = gl_FragCoord.xy / vec2(outRes);

    float x = 1.0 / inRes.x;
    float y = 1.0 / inRes.y;
    
    vec3 a = bilinear(InSampler, vec2(texCoord.x - x, texCoord.y + y));
    vec3 b = bilinear(InSampler, vec2(texCoord.x,     texCoord.y + y));
    vec3 c = bilinear(InSampler, vec2(texCoord.x + x, texCoord.y + y));

    vec3 d = bilinear(InSampler, vec2(texCoord.x - x, texCoord.y));
    vec3 e = bilinear(InSampler, vec2(texCoord.x,     texCoord.y));
    vec3 f = bilinear(InSampler, vec2(texCoord.x + x, texCoord.y));

    vec3 g = bilinear(InSampler, vec2(texCoord.x - x, texCoord.y - y));
    vec3 h = bilinear(InSampler, vec2(texCoord.x,     texCoord.y - y));
    vec3 i = bilinear(InSampler, vec2(texCoord.x + x, texCoord.y - y));

    vec3 color = e * 4.0;
    color += (b + d + f + h)*2.0;
    color += (a + c + g + i);
    color *= 1.0 / 16.0;

    color += bilinear(DownsampledSampler, texCoord * (vec2(outRes) / vec2(inRes)));

    fragColor = encodeLogLuv(color);
}
