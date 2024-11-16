#version 150

uniform sampler2D Sampler2;

uniform vec4 ColorModulator;

in vec4 vertexColor;
in vec2 texCoord2;

out vec4 fragColor;

void main() {
    vec4 color = vec4(texture(Sampler2, texCoord2).rgb, 1.0) * vertexColor;
    fragColor = color * ColorModulator;
}
