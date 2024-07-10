#version 150

in vec3 Position;
in vec2 UV0;

uniform sampler2D Sampler0;
uniform mat4 ModelViewMat;
uniform mat4 ProjMat;

out float pauseMenu;
out vec2 texCoord0;

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    pauseMenu = 0.0;
    if (max(abs(gl_Position.x), abs(gl_Position.y)) > 0.999) pauseMenu = 1.0;

    texCoord0 = UV0;
}