#version 150

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

#endif // _SCREENQUAD_GLSL