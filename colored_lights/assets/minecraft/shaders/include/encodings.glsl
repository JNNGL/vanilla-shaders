#version 330

#ifndef _ENCODINGS_GLSL
#define _ENCODINGS_GLSL

vec3 packSI24toF8x3(int i) {
    int sgn = int(i < 0);
    i = abs(i);
    return vec3(i & 0xFF, (i >> 8) & 0xFF, ((i >> 16) & 0x7F) | (sgn << 7)) / 255.0;
}

int unpackSI24fromF8x3(vec3 v) {
    ivec3 data = ivec3(v * 255.0);
    int sgn = data.b >> 7;
    int n = data.r | (data.g << 8) | ((data.b & 0x7F) << 16);
    return (sgn > 0 ? -1 : 1) * (n);
}

vec3 packUI24toF8x3(uint u) {
    return vec3(u & 0xFFu, (u >> 8u) & 0xFFu, (u >> 16u) & 0xFFu) / 255.0;
}

uint unpackUI24fromF8x3(vec3 v) {
    uvec3 data = uvec3(v * 255.0);
    return data.r | (data.g << 8u) | (data.b << 16u);
}

#define FP_PRECISION_UNIT   8388607.0
#define FP_PRECISION_HIGH   400000.0
#define FP_PRECISION_MEDIUM 10000.0
#define FP_PRECISION_LOW    1000.0

vec3 packFPtoF8x3(float x, float fpPrecision) {
    int i = int(round(x * fpPrecision));
    return packSI24toF8x3(i);
}

float unpackFPfromF8x3(vec3 v, float fpPrecision) {
    return float(unpackSI24fromF8x3(v)) / fpPrecision;
}

vec4 packUI32toF8x4(uint u) {
    return vec4(u >> 24u, (u >> 16u) & 0xFFu, (u >> 8u) & 0xFFu, u & 0xFFu) / 255.0;
}

uint unpackUI32fromF8x4(vec4 v) {
    uvec4 data = uvec4(v * 255.0);
    return (data.r << 24u) | (data.g << 16u) | (data.b << 8u) | data.a;
}

vec4 packSI32toF8x4(int i) {
    return vec4(i >> 24, (i >> 16) & 0xFF, (i >> 8) & 0xFF, i & 0xFF) / 255.0;
}

int unpackSI32fromF8x4(vec4 v) {
    ivec4 data = ivec4(v * 255.0);
    return (data.r << 24) | (data.g << 16) | (data.b << 8) | data.a;
}

float unpackF32fromF8x4(vec4 v) {
    uint bits = unpackUI32fromF8x4(v);
    return uintBitsToFloat(bits);
}

vec4 packF32toF8x4(float f) {
    uint bits = floatBitsToUint(f);
    return packUI32toF8x4(bits);
}

vec2 packF01U16toF8x2(float f) {
    f = clamp(f, 0.0, 1.0);
    int bits = int(f * 65535.0);
    return vec2(bits >> 8, bits & 0xFF) / 255.0;
}

const mat3 RGB2YCoCg = mat3(0.25, 0.5, -0.25, 0.5, 0.0, 0.5, 0.25, -0.5, -0.25);
const mat3 YCoCg2RGB = mat3(1.0, 1.0, 1.0, 1.0, 0.0, -1.0, -1.0, 1.0, -1.0);

vec3 rgb2YCoCg(vec3 rgb) {
    return RGB2YCoCg * rgb;
}

vec3 YCoCg2rgb(vec3 ycocg) {
    float t = ycocg.r - ycocg.b;
    return vec3(t + ycocg.g, ycocg.r + ycocg.b, t - ycocg.g);
}

vec4 encodeYCoCg1688(vec3 rgb) {
    vec3 YCoCg = rgb2YCoCg(rgb);

    float Y = YCoCg.x * 255.0;
    return vec4(vec2(floor(Y), int(Y * 256.0) & 0xFF) / 255.0, YCoCg.yz + 0.5);
}

vec3 decodeYCoCg1688(vec4 ycocg1688) {
    float Y = ycocg1688.x + ycocg1688.y / 256.0;
    vec3 YCoCg = vec3(Y, ycocg1688.zw - 0.5);
    return YCoCg2rgb(YCoCg);
}

vec2 encodeYCoCg844(vec3 rgb) {
    vec3 YCoCg = rgb2YCoCg(rgb);
    vec2 CoCg = round((YCoCg.yz + 0.5) * 15.0);

    return vec2(YCoCg.x, (CoCg.x * 16.0 + CoCg.y) / 255.0);
}

vec3 decodeYCoCg844(vec2 YCoCg) {
    YCoCg.y *= 255.0;
    vec2 CoCg = vec2(floor(YCoCg.y / 16.0), mod(YCoCg.y, 16.0));

    return YCoCg2rgb(vec3(YCoCg.x, CoCg / 15.0 - 0.5));
}

vec3 encodeYCoCg776(vec3 rgb, uint lowerBits) {
    vec3 YCoCg = rgb2YCoCg(clamp(rgb, 0.0, 1.0));
    YCoCg.yz += 0.5;

    uint bits = (lowerBits & 15u) << 4u;
    bits |= uint(YCoCg.x * 127.0) << 17u;
    bits |= uint(YCoCg.y * 127.0) << 10u;
    bits |= (uint(YCoCg.z * 63.0) >> 4u) << 8u;
    bits |= (uint(YCoCg.z * 63.0) & 15u);

    return vec3(bits >> 16u, (bits >> 8u) & 0xFFu, bits & 0xFFu) / 255.0;
}

vec3 decodeYCoCg776(vec3 v, out uint lowerBits) {
    uvec3 data = uvec3(v * 255.0);
    uint bits = (data.r << 16u) | (data.g << 8u) | data.b;
    lowerBits = (bits >> 4u) & 15u;

    float Y = float(bits >> 17u) / 127.0;
    float Co = float((bits >> 10u) & 127u) / 127.0;
    float Cg = float((bits & 15u) | (((bits >> 8u) & 3u) << 4u)) / 63.0;
    
    vec3 YCoCg = vec3(Y, Co - 0.5, Cg - 0.5);
    return YCoCg2rgb(YCoCg);
}

// LogLuv encoding from https://therealmjp.github.io/posts/logluv-encoding-for-hdr/
const mat3 LOGLUV_M = mat3(
    0.2209, 0.1138, 0.0102,
    0.3390, 0.6780, 0.1130,
    0.4184, 0.7319, 0.2969
);

const mat3 LOGLUV_INV_M = mat3(
    6.0013, -1.332, 0.3007,
    -2.700, 3.1029, -1.088,
    -1.7995, -5.7720, 5.6268
);

vec4 encodeLogLuv(vec3 rgb) {
    vec4 result;
    vec3 Xp_Y_XYZp = rgb * LOGLUV_M;
    Xp_Y_XYZp = max(Xp_Y_XYZp, vec3(1.0e-6));
    result.xy = Xp_Y_XYZp.xy / Xp_Y_XYZp.z;
    float Le = 2.0 * log2(Xp_Y_XYZp.y) + 127.0;
    result.w = fract(Le);
    result.z = (Le - (floor(result.w * 255.0)) / 255.0) / 255.0;
    return result;
}

vec3 decodeLogLuv(vec4 logLuv) {
    float Le = logLuv.z * 255.0 + logLuv.w;
    vec3 Xp_Y_XYZp;
    Xp_Y_XYZp.y = exp2((Le - 127.0) / 2.0);
    Xp_Y_XYZp.z = Xp_Y_XYZp.y / logLuv.y;
    Xp_Y_XYZp.x = logLuv.x * Xp_Y_XYZp.z;
    vec3 rgb = Xp_Y_XYZp * LOGLUV_INV_M;
    return max(rgb, 0.0);
}

#endif // _ENCODINGS_GLSL