// Fancy Player Models
// https://github.com/JNNGL/vanilla-shaders

#version 150

#moj_import <fog.glsl>
#moj_import <light.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler0;
uniform sampler2D Sampler1;
uniform sampler2D Sampler2;
uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

out float vertexDistance;
out vec4 vertexColor;
out vec4 lightMapColor;
out vec4 overlayColor;
out vec2 texCoord0;
out vec3 normal;
flat out int quadId;
flat out int renderModel;

void main() {
    vec3 position = Position;

    renderModel = int(ProjMat[2][3] == 0.0 && max(abs(Normal.x), max(abs(Normal.y), abs(Normal.z))) == 1.0);
    quadId = (gl_VertexID / 4) % 24;

    const vec2 uvs[] = vec2[](vec2(1, 0), vec2(0, 0), vec2(0, 1), vec2(1, 1));

    vertexDistance = length(Position);
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color);
    lightMapColor = texelFetch(Sampler2, UV2 / 16, 0);
    overlayColor = texelFetch(Sampler1, UV1, 0);
    texCoord0 = UV0;
    normal = Normal;

    if (renderModel > 0) {
        texCoord0 = uvs[gl_VertexID % 4];
        position.xy += (texCoord0 * 2.0 - 1.0) * 27;
    }

    gl_Position = ProjMat * ModelViewMat * vec4(position, 1.0);
}
