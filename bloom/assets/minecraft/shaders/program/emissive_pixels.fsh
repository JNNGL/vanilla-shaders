#version 150

uniform sampler2D DiffuseSampler;

in vec2 texCoord;

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

void main() {
    vec4 col = texture(DiffuseSampler, texCoord);

    fragColor = vec4(0.0);
    int alpha = int(round(col.a * 255.0));
    if (alpha >= 230 && alpha <= 250) {
        fragColor = encodeHdr(pow(col.rgb, vec3(2.2)) * float(alpha - 229));
    }
}
