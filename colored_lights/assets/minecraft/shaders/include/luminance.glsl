#version 330

#ifndef _LUMINANCE_GLSL
#define _LUMINANCE_GLSL

float luminance(vec3 rgb) {
    return dot(rgb, vec3(0.2125, 0.7154, 0.0721));
}

#endif // _LUMINANCE_GLSL