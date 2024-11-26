#ifndef _TONEMAPPING_GLSL
#define _TONEMAPPING_GLSL

// https://www.shadertoy.com/view/NtXyD8
vec3 acesFilm(vec3 x) {
    return clamp((x * (2.51 * x + 0.03)) / (x * (2.43 * x + 0.59) + 0.14), 0.0, 1.0);
}

vec3 acesInverse(vec3 x) {
    return (sqrt(-10127.0 * x * x + 13702.0 * x + 9.0) + 59.0 * x - 3.0) / (502.0 - 486.0 * x);
}


#endif // _TONEMAPPING_GLSL