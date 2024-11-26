#version 330

// #extension GL_MC_moj_import : enable
#moj_import <minecraft:light.glsl>
#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:voxelization.glsl>
#moj_import <minecraft:encodings.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler2;
uniform sampler2D Sampler0;
uniform vec2 ScreenSize;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform vec3 ModelOffset;
uniform int FogShape;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;

flat out int isVoxel;
flat out vec3 voxelData;

flat out int dataQuad;

void main() {
    vec3 pos = Position + ModelOffset;
    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);

    isVoxel = 0;
    voxelData = vec3(0.0);

    vec4 sample = textureLod(Sampler0, UV0, -4);
    ivec4 color = ivec4(round(sample * 255.0));
#ifndef TRANSLUCENT
    if (color == ivec4(46, 212, 93, 146) || (color.a > 200 && color.a < 216)) {
        ivec3 blockPos = ivec3(floor(Position + floor(ModelOffset)));
        gl_Position = placeVoxel(blockPos, ivec2(ScreenSize), gl_VertexID);

        isVoxel = 1;
        if (color.a > 200) {
            // light
            uint lightLevel = uint(color.a - 200);
            voxelData = encodeYCoCg776(sample.rgb, lightLevel);
        } else {
            // block
            voxelData = vec3(0.0);
        }
    }
// #else
//     if (color.a == 200) {
//         ivec3 blockPos = ivec3(floor(Position + floor(ModelOffset)));
//         gl_Position = placeVoxel(blockPos, ivec2(ScreenSize), gl_VertexID);

//         isVoxel = 1;
//         voxelData = encodeYCoCg776(sample.rgb, 15u);
//     }
#endif // TRANSLUCENT

    dataQuad = color.rgb == ivec3(76, 195, 86) ? 1 : 0;

    vertexDistance = fog_distance(pos, FogShape);
    vertexColor = Color * minecraft_sample_lightmap(Sampler2, UV2);
    texCoord0 = UV0;

    if (dataQuad > 0) {
        if (ModelOffset == vec3(0.0)) {
            gl_Position = vec4(-10.0, -10.0, -10.0, 1.0);
            return;
        }

        vec2 bottomLeftCorner = vec2(-1.0, -1.0);
        vec2 topRightCorner = vec2(-0.9, -0.99); // TODO: We have ScreenSize

        switch (gl_VertexID % 4) {
            case 0: gl_Position = vec4(bottomLeftCorner.x, topRightCorner.y,   -1.0, 1.0); break;
            case 1: gl_Position = vec4(bottomLeftCorner.x, bottomLeftCorner.y, -1.0, 1.0); break;
            case 2: gl_Position = vec4(topRightCorner.x,   bottomLeftCorner.y, -1.0, 1.0); break;
            case 3: gl_Position = vec4(topRightCorner.x,   topRightCorner.y,   -1.0, 1.0); break;
        }
    }
}
