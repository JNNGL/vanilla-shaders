#version 150

#define X_RESOLUTION 512
#define Y_RESOLUTION 512

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
out vec4 normal;
out vec3 position;
out float minimapQuad;
out vec3 minimapData;
out vec4 glPos;
flat out vec2 voxelCoord;
out float dataQuad;

void main() {
    vec3 pos = Position + ChunkOffset;
    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);

    vec4 col = texture(Sampler0, UV0);
    minimapQuad = col.a == 250.0 / 255.0 ? 1.0 : 0.0;
    minimapData = col.rgb;

    vertexDistance = fog_distance(ModelViewMat, pos, FogShape);
    vertexColor = Color * minecraft_sample_lightmap(Sampler2, UV2);
    texCoord0 = UV0;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);

    position = pos;
    dataQuad = 0;

    if (minimapQuad > 0.0) {
        ivec3 blockPos = ivec3(floor(Position + floor(ChunkOffset)));
        int cX = X_RESOLUTION / 2;
        int cY = Y_RESOLUTION / 2;
        if (blockPos.x < -cX || blockPos.x >= cX || blockPos.z < -cY || blockPos.z >= cY) {
            gl_Position = vec4(10.0);
            return;
        }

        vec2 screenSize = vec2(X_RESOLUTION * 2, Y_RESOLUTION + 1);
        ivec2 screenPos = blockPos.xz + ivec2(cX, cY + 1);
        screenPos.x = screenPos.x * 2 + screenPos.y % 2;

        vec2 bottomLeftCorner = (screenPos - 0.0) / screenSize * 2.0 - 1.0;
        vec2 topRightCorner = (screenPos + 1.0) / screenSize * 2.0 - 1.0;
        if (gl_VertexID / 4 == 0) {
            dataQuad = 1;
            bottomLeftCorner = vec2(-1.0);
        }

        switch (gl_VertexID % 4) {
            case 0: gl_Position = vec4(bottomLeftCorner.x, topRightCorner.y,   -float(blockPos.y + 386) / 1024, 1); break;
            case 1: gl_Position = vec4(bottomLeftCorner.x, bottomLeftCorner.y, -float(blockPos.y + 386) / 1024, 1); break;
            case 2: gl_Position = vec4(topRightCorner.x,   bottomLeftCorner.y, -float(blockPos.y + 386) / 1024, 1); break;
            case 3: gl_Position = vec4(topRightCorner.x,   topRightCorner.y,   -float(blockPos.y + 386) / 1024, 1); break;
        }

        voxelCoord = vec2(screenPos) / screenSize;
    }

    glPos = gl_Position;
}