#version 330

#ifndef _SCREENQUAD_GLSL
#define _SCREENQUAD_GLSL

const vec4[] screenquad = vec4[](
    vec4(-1.0, -1.0, 0.0, 1.0),
    vec4(1.0, -1.0, 0.0, 1.0),
    vec4(1.0, 1.0, 0.0, 1.0),
    vec4(-1.0, 1.0, 0.0, 1.0)
);

vec2 sqTexCoord(vec4 glPos) {
    return glPos.xy * 0.5 + 0.5;
}

vec4 sqPointOnNearPlane(mat4 invMat, vec4 glPos) {
    return invMat * vec4(glPos.xy, -1.0, 1.0);
}

vec4 sqPointOnFarPlane(mat4 invMat, vec4 glPos) {
    return invMat * vec4(glPos.xy, 1.0, 1.0);
}

#endif // _SCREENQUAD_GLSL