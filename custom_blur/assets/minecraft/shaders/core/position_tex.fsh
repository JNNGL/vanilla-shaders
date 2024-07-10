#version 150

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;

in float pauseMenu;
in vec2 texCoord0;

out vec4 fragColor;

void main() {
    vec4 c = texture(Sampler0, texCoord0);
    if (pauseMenu == 1.0 && c.r == c.g && c.g == c.b && c.a < 1.0) discard;
    if (c.a == 0.0) {
        discard;
    }
    fragColor = c * ColorModulator;
}