#version 150

#moj_import <fov.glsl>

in vec3 Position;
in vec4 Color;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;

out vec4 vertexColor;

void main() {
    gl_Position = changeFov(ProjMat) * ModelViewMat * vec4(Position, 1.0);

    vertexColor = Color;
}
