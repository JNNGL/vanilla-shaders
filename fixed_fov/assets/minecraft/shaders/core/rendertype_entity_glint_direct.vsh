#version 150

#moj_import <fog.glsl>

#moj_import <fov.glsl>

in vec3 Position;
in vec2 UV0;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat4 TextureMat;
uniform int FogShape;
uniform float FogStart;

out float vertexDistance;
out vec2 texCoord0;

void main() {
    gl_Position = changeFov(FogStart, ProjMat) * ModelViewMat * vec4(Position, 1.0);

    vertexDistance = fog_distance(Position, FogShape);
    texCoord0 = (TextureMat * vec4(UV0, 0.0, 1.0)).xy;
}
