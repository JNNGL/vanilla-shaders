#version 150

#moj_import <fov.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;

out vec4 vertexColor;
out vec2 texCoord2;

void main() {
    gl_Position = changeFov(ProjMat) * ModelViewMat * vec4(Position, 1.0);

    vertexColor = Color;
    texCoord2 = UV2;
}
