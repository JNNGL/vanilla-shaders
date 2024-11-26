#version 330

#ifndef _PROJECTION_GLSL
#define _PROJECTION_GLSL

vec3 projectAndDivide(mat4 mat, vec4 vector) {
    vec4 homog = mat * vector;
    return homog.xyz / homog.w;
}

vec3 projectAndDivide(mat4 mat, vec3 v) {
    return projectAndDivide(mat, vec4(v, 1.0));
}

vec3 unprojectNdc(mat4 invProj, vec3 ndc) {
    return projectAndDivide(invProj, ndc);
}

vec3 unprojectScreenSpace(mat4 invProj, vec3 screenSpace) {
    return unprojectNdc(invProj, screenSpace * 2.0 - 1.0);
}

vec3 unprojectScreenSpace(mat4 invProj, vec2 uv, float z) {
    return unprojectScreenSpace(invProj, vec3(uv, z));
}

vec4 getPointOnNearPlane(mat4 invProj, vec2 ndc) {
    return invProj * vec4(ndc, -1.0, 1.0);
}

vec4 getPointOnFarPlane(mat4 invProj, vec2 ndc) {
    return invProj * vec4(ndc, 1.0, 1.0);
}

vec2 getPlanes(mat4 proj) {
    const float near = 0.05;
    float far = proj[3][2] * near / (proj[3][2] + 2.0 * near);
    return vec2(near, far);
}

// non-linear [-1.0,1.0] -> linear [near,far]
float linearizeDepth(float depth, vec2 planes) {
    return (2.0 * planes.x * planes.y) / (planes.y + planes.x - depth * (planes.y - planes.x));
}

// linear [near,far] -> non-linear [-1.0,1.0]
float unlinearizeDepth(float linearDepth, vec2 planes) {
    return ((2.0 * planes.x * planes.y) / linearDepth - planes.y - planes.x) / (planes.x - planes.y);
}

#endif // _PROJECTION_GLSL