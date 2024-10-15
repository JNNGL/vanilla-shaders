#version 150

#moj_import <fov.glsl>

in vec3 Position;
in vec2 UV0;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;

out vec2 texCoord0;

void main() {
    gl_Position = changeFov(ProjMat) * ModelViewMat * vec4(Position, 1.0);

    texCoord0 = UV0;
}