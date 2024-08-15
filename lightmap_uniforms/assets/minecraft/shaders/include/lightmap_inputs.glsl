#version 330

uint readPackedByte(sampler2D lightMap, ivec2 coord) {
    return uint(round(texelFetch(lightMap, coord, 0).a * 255.0));
}

float decodePackedFloat(sampler2D lightMap, int index) {
    int x = index % 4;
    int y = index / 4;
    uint b0 = readPackedByte(lightMap, ivec2(x * 4 + 0, y));
    uint b1 = readPackedByte(lightMap, ivec2(x * 4 + 1, y));
    uint b2 = readPackedByte(lightMap, ivec2(x * 4 + 2, y));
    uint b3 = readPackedByte(lightMap, ivec2(x * 4 + 3, y));
    uint bits = (b3 << 24u) | (b2 << 16u) | (b1 << 8u) | b0;
    return uintBitsToFloat(bits);
}

float getAmbientLightFactor(sampler2D lightMap) {
    return decodePackedFloat(lightMap, 0);
}

float getSkyFactor(sampler2D lightMap) {
    return decodePackedFloat(lightMap, 1);
}

float getBlockFactor(sampler2D lightMap) {
    return decodePackedFloat(lightMap, 2);
}

float getUseBrightLightmap(sampler2D lightMap) {
    return decodePackedFloat(lightMap, 3);
}

vec3 getSkyLightColor(sampler2D lightMap) {
    return vec3(decodePackedFloat(lightMap, 4), decodePackedFloat(lightMap, 5), decodePackedFloat(lightMap, 6));
}

float getNightVisionFactor(sampler2D lightMap) {
    return decodePackedFloat(lightMap, 7);
}

float getDarknessScale(sampler2D lightMap) {
    return decodePackedFloat(lightMap, 8);
}

float getDarkenWorldFactor(sampler2D lightMap) {
    return decodePackedFloat(lightMap, 9);
}

float getBrightnessFactor(sampler2D lightMap) {
    return decodePackedFloat(lightMap, 10);
}