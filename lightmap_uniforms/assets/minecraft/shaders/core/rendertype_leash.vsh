#version 150

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:light.glsl>

in vec3 Position;
in vec4 Color;
in ivec2 UV2;

uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform vec4 ColorModulator;
uniform int FogShape;

out float vertexDistance;
flat out vec4 vertexColor;

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    vertexDistance = fog_distance(Position, FogShape);
    vertexColor = Color * ColorModulator * minecraft_fetch_lightmap(Sampler2, UV2);
}
