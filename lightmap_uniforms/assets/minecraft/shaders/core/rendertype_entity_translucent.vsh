#version 150

#moj_import <light.glsl>
#moj_import <fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler1;
uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform int FogShape;
uniform float FogStart;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

out float vertexDistance;
out vec4 vertexColor;
out vec4 lightMapColor;
out vec4 overlayColor;
out vec2 texCoord0;
out float renderInfo;
out vec4 glPos;

const vec4[] corners = vec4[](
    vec4(-1, 0, 1, 1),
    vec4(0.7, 0, 1, 1),
    vec4(0.7, 1, 1, 1),
    vec4(-1, 1, 1, 1)
);

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    vertexDistance = fog_distance(Position, FogShape);
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color);
    lightMapColor = vec4(texelFetch(Sampler2, UV2 / 16, 0).rgb, 1.0);
    overlayColor = texelFetch(Sampler1, UV1, 0);
    texCoord0 = UV0;

    renderInfo = 0.0;
    if (FogStart > 3e38 && (mat3(ModelViewMat) * Normal).z < -0.5) {
        gl_Position = corners[gl_VertexID % 4];
        renderInfo = 1.0;
        
        texCoord0 = gl_Position.xy * 0.5 + 0.5;
        texCoord0.y = 1.0 - texCoord0.y;
    }

    glPos = gl_Position;
}