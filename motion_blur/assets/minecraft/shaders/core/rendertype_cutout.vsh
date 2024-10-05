// motion blur
// https://github.com/JNNGL/vanilla-shaders

#version 150

#moj_import <light.glsl>
#moj_import <fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler0;
uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform vec3 ChunkOffset;
uniform int FogShape;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
flat out int dataQuad;

void main() {
    vec3 pos = Position + ChunkOffset;
    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);

    ivec4 col = ivec4(round(texture(Sampler0, UV0) * 255.0));
    dataQuad = col.rgb == ivec3(76, 195, 86) ? 1 : 0;

    vertexDistance = fog_distance(pos, FogShape);
    vertexColor = Color * minecraft_sample_lightmap(Sampler2, UV2);
    texCoord0 = UV0;

    if (dataQuad > 0) {
        if (ChunkOffset == vec3(0.0)) {
            gl_Position = vec4(10.0, 10.0, 10.0, 1.0);
            return;
        }

        vec4 corner = vec4(-1.0, -1.0, -0.9, -0.995);

        switch (gl_VertexID % 4) {
            case 0: gl_Position = vec4(corner.xw, -1.0, 1.0); break;
            case 1: gl_Position = vec4(corner.xy, -1.0, 1.0); break;
            case 2: gl_Position = vec4(corner.zy, -1.0, 1.0); break;
            case 3: gl_Position = vec4(corner.zw, -1.0, 1.0); break;
        }
    }
}
