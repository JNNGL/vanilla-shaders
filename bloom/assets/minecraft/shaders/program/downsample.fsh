#version 150

uniform sampler2D DiffuseSampler;
uniform vec2 OutSize;

in vec2 texCoord;
flat in ivec2 inRes;
flat in ivec2 outRes;
flat in float scale;
flat in float prevScale;

out vec4 fragColor;

vec4 bilinear(sampler2D s, vec2 tex) {
    tex = clamp(tex, 0.0, 1.0);
    tex *= inRes;
    tex -= 0.5;

    ivec2 coord = ivec2(floor(tex));
    vec2 frac = fract(tex);

    return mix(
        mix(texelFetch(s, coord + ivec2(0, 0), 0), texelFetch(s, coord + ivec2(1, 0), 0), frac.x),
        mix(texelFetch(s, coord + ivec2(0, 1), 0), texelFetch(s, coord + ivec2(1, 1), 0), frac.x),
        frac.y);
}

void main() {
    ivec2 coord = ivec2(gl_FragCoord.xy);
    if (any(greaterThanEqual(coord, outRes))) {
        fragColor = vec4(0.0);
        return;
    }

    vec2 srcTexelSize = 1.0 / inRes;
    float x = srcTexelSize.x;
    float y = srcTexelSize.y;

    vec3 a = bilinear(DiffuseSampler, vec2(texCoord.x - 2 * x, texCoord.y + 2 * y)).rgb;
    vec3 b = bilinear(DiffuseSampler, vec2(texCoord.x,         texCoord.y + 2 * y)).rgb;
    vec3 c = bilinear(DiffuseSampler, vec2(texCoord.x + 2 * x, texCoord.y + 2 * y)).rgb;

    vec3 d = bilinear(DiffuseSampler, vec2(texCoord.x - 2 * x, texCoord.y)).rgb;
    vec3 e = bilinear(DiffuseSampler, vec2(texCoord.x,         texCoord.y)).rgb;
    vec3 f = bilinear(DiffuseSampler, vec2(texCoord.x + 2 * x, texCoord.y)).rgb;

    vec3 g = bilinear(DiffuseSampler, vec2(texCoord.x - 2 * x, texCoord.y - 2 * y)).rgb;
    vec3 h = bilinear(DiffuseSampler, vec2(texCoord.x,         texCoord.y - 2 * y)).rgb;
    vec3 i = bilinear(DiffuseSampler, vec2(texCoord.x + 2 * x, texCoord.y - 2 * y)).rgb;

    vec3 j = bilinear(DiffuseSampler, vec2(texCoord.x - x, texCoord.y + y)).rgb;
    vec3 k = bilinear(DiffuseSampler, vec2(texCoord.x + x, texCoord.y + y)).rgb;
    vec3 l = bilinear(DiffuseSampler, vec2(texCoord.x - x, texCoord.y - y)).rgb;
    vec3 m = bilinear(DiffuseSampler, vec2(texCoord.x + x, texCoord.y - y)).rgb;

    vec3 color = e * 0.125;
    color += (a + c + g + i) * 0.03125;
    color += (b + d + f + h) * 0.0625;
    color += (j + k + l + m) * 0.125;

    fragColor = vec4(color, 1.0);
}
