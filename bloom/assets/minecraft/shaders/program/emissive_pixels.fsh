#version 150

uniform sampler2D DiffuseSampler;

in vec2 texCoord;

out vec4 fragColor;

void main() {
    vec4 col = texture(DiffuseSampler, texCoord);

    fragColor = vec4(0.0);
    if (int(round(col.a * 255.0)) == 251) {
        fragColor = vec4(col.rgb, 1.0);
    }
}
