#version 150

uniform sampler2D DiffuseSampler;
uniform vec2 OutSize;

flat in ivec2 inRes;
flat in ivec2 outRes;

out vec4 fragColor;

vec3 decodeHdr(vec4 color) {
    if (color.a == 0.0) return vec3(0.0);
    return color.rgb * (1.0 / color.a);
}

vec4 encodeHdr(vec3 color) {
    float m = min(max(color.r, max(color.g, color.b)), 255);
    if (m <= 0.0) return vec4(0.0);
    if (m < 1.0) return vec4(color, 1.0);
    return vec4(color / m, 1.0 / m);
}

vec3 bilinear(sampler2D s, vec2 tex) {
    tex = clamp(tex, 0.0, 1.0);
    tex *= inRes;
    tex -= 0.5;

    ivec2 coord = ivec2(floor(tex));
    vec2 frac = fract(tex);

    return mix(
        mix(decodeHdr(texelFetch(s, coord + ivec2(0, 0), 0)), decodeHdr(texelFetch(s, coord + ivec2(1, 0), 0)), frac.x),
        mix(decodeHdr(texelFetch(s, coord + ivec2(0, 1), 0)), decodeHdr(texelFetch(s, coord + ivec2(1, 1), 0)), frac.x),
        frac.y);
}

void main() {
    ivec2 coord = ivec2(gl_FragCoord.xy);
    if (any(greaterThanEqual(coord, outRes))) {
        fragColor = vec4(0.0);
        return;
    }

    vec2 texCoord = gl_FragCoord.xy / vec2(outRes);

    vec2 srcTexelSize = 1.0 / inRes;
    float x = srcTexelSize.x;
    float y = srcTexelSize.y;

    vec3 a = bilinear(DiffuseSampler, vec2(texCoord.x - 2 * x, texCoord.y + 2 * y));
    vec3 b = bilinear(DiffuseSampler, vec2(texCoord.x,         texCoord.y + 2 * y));
    vec3 c = bilinear(DiffuseSampler, vec2(texCoord.x + 2 * x, texCoord.y + 2 * y));

    vec3 d = bilinear(DiffuseSampler, vec2(texCoord.x - 2 * x, texCoord.y));
    vec3 e = bilinear(DiffuseSampler, vec2(texCoord.x,         texCoord.y));
    vec3 f = bilinear(DiffuseSampler, vec2(texCoord.x + 2 * x, texCoord.y));

    vec3 g = bilinear(DiffuseSampler, vec2(texCoord.x - 2 * x, texCoord.y - 2 * y));
    vec3 h = bilinear(DiffuseSampler, vec2(texCoord.x,         texCoord.y - 2 * y));
    vec3 i = bilinear(DiffuseSampler, vec2(texCoord.x + 2 * x, texCoord.y - 2 * y));

    vec3 j = bilinear(DiffuseSampler, vec2(texCoord.x - x, texCoord.y + y));
    vec3 k = bilinear(DiffuseSampler, vec2(texCoord.x + x, texCoord.y + y));
    vec3 l = bilinear(DiffuseSampler, vec2(texCoord.x - x, texCoord.y - y));
    vec3 m = bilinear(DiffuseSampler, vec2(texCoord.x + x, texCoord.y - y));

    vec3 color = e * 0.125;
    color += (a + c + g + i) * 0.03125;
    color += (b + d + f + h) * 0.0625;
    color += (j + k + l + m) * 0.125;

    fragColor = encodeHdr(color);
}
