#version 330

#ifndef _DATAMARKER_GLSL
#define _DATAMARKER_GLSL

// #extension GL_MC_moj_import : enable
#moj_import <encodings.glsl>

// layout
// 0-15 - projection matrix
// 16 - fog start
// 17 - fog end
// 18-20 - chunk offset
// 21-22 - game time
// 23-31 - view matrix
// 32-34 - sun direction
// 35-36 - sky factor

vec2 markerSize() {
    return vec2(39.0, 1.0);
}

bool discardDataMarker(ivec2 pixel) {
    return pixel.y >= 1.0 || pixel.x >= 39.0;
}

vec4 writeDataMarker(ivec2 pixel, mat4 projMat, float fogStart, float fogEnd, vec3 chunkOffset, float gameTime, mat3 viewMat, vec2 projUnjitter) {
    if (pixel.x <= 15) { // projection matrix
        int index = int(pixel.x);
        return vec4(packFPtoF8x3(projMat[index / 4][index % 4], FP_PRECISION_HIGH), 1.0);
    } else if (pixel.x == 16) { // fog start
        return vec4(packFPtoF8x3(fogStart, FP_PRECISION_LOW), 1.0);
    } else if (pixel.x == 17) { // fog end
        return vec4(packFPtoF8x3(fogEnd, FP_PRECISION_LOW), 1.0);
    } else if (pixel.x <= 20) { // chunk offset
        int index = int(pixel.x) - 18;
        return vec4(packFPtoF8x3(mod(chunkOffset[index], 16.0) / 16.0, FP_PRECISION_HIGH), 1.0);
    } else if (pixel.x <= 22) { // game time
        int index = int(pixel.x) - 21;
        vec4 data = packF32toF8x4(gameTime);
        return vec4(data[index * 2], data[index * 2 + 1], 0.0, 1.0);
    } else if (pixel.x <= 31) { // view matrix
        int index = int(pixel.x) - 23;
        return vec4(packFPtoF8x3(viewMat[index / 3][index % 3], FP_PRECISION_HIGH), 1.0); 
    } else if (pixel.x <= 36) { // <...>
        return vec4(0.0);
    } else if (pixel.x <= 38) { // proj unjitter
        int index = int(pixel.x) - 37;
        return vec4(packFPtoF8x3(projUnjitter[index], FP_PRECISION_HIGH), 1.0);
    }

    return vec4(0.0);
}

mat4 decodeProjectionMatrix(sampler2D dataSampler) {
    mat4 projection;
    
    for (int i = 0; i < 16; i++) {
        vec3 color = texelFetch(dataSampler, ivec2(i, 0), 0).rgb;
        projection[i / 4][i % 4] = unpackFPfromF8x3(color, FP_PRECISION_HIGH);
    }

    return projection;
}

float decodeFogStart(sampler2D dataSampler) {
    vec3 color = texelFetch(dataSampler, ivec2(16, 0), 0).rgb;
    return unpackFPfromF8x3(color, FP_PRECISION_LOW);
}

float decodeFogEnd(sampler2D dataSampler) {
    vec3 color = texelFetch(dataSampler, ivec2(17, 0), 0).rgb;
    return unpackFPfromF8x3(color, FP_PRECISION_LOW);
}

vec3 decodeChunkOffset(sampler2D dataSampler) {
    vec3 chunkOffset;

    for (int i = 0; i < 3; i++) {
        vec3 color = texelFetch(dataSampler, ivec2(18 + i, 0), 0).rgb;
        chunkOffset[i] = unpackFPfromF8x3(color, FP_PRECISION_HIGH) * 16.0;
    }

    return chunkOffset;
}

float decodeGameTime(sampler2D dataSampler) {
    vec4 data;
    data.xy = texelFetch(dataSampler, ivec2(21, 0), 0).rg;
    data.zw = texelFetch(dataSampler, ivec2(22, 0), 0).rg;
    return unpackF32fromF8x4(data);
}

mat3 decodeModelViewMatrix(sampler2D dataSampler) {
    mat3 modelView;
    
    for (int i = 0; i < 9; i++) {
        vec3 color = texelFetch(dataSampler, ivec2(23 + i, 0), 0).rgb;
        modelView[i / 3][i % 3] = unpackFPfromF8x3(color, FP_PRECISION_HIGH);
    }

    return modelView;
}

vec3 decodeSunDirection(sampler2D dataSampler) {
    vec3 sunDirection;

    for (int i = 0; i < 3; i++) {
        vec3 color = texelFetch(dataSampler, ivec2(32 + i, 0), 0).rgb;
        sunDirection[i] = unpackFPfromF8x3(color, FP_PRECISION_HIGH);
    }

    return normalize(sunDirection);
}

float decodeSkyFactor(sampler2D dataSampler) {
    vec4 data;
    data.xy = texelFetch(dataSampler, ivec2(35, 0), 0).rg;
    data.zw = texelFetch(dataSampler, ivec2(36, 0), 0).rg;
    return unpackF32fromF8x4(data);
}

mat4 decodeUnjitteredProjection(sampler2D dataSampler) {
    mat4 projection = decodeProjectionMatrix(dataSampler);

    vec2 unjitter;
    for (int i = 0; i < 2; i++) {
        vec3 color = texelFetch(dataSampler, ivec2(37 + i, 0), 0).rgb;
        unjitter[i] = unpackFPfromF8x3(color, FP_PRECISION_HIGH);
    }

    projection[2].xy = unjitter;
    return projection;
}

#endif // _DATAMARKER_GLSL