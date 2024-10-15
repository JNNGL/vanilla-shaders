#version 150

#moj_import <fov.glsl>

in vec3 Position;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;

void main() {
    gl_Position = changeFov(ProjMat) * ModelViewMat * vec4(Position, 1.0);
}
