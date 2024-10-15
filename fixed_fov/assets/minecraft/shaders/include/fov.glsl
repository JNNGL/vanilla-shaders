// fixed fov
// https://github.com/JNNGL/vanilla-shaders

const float FOV = 45.0;
const float invTanHF = 1.0 / tan(radians(FOV * 0.5));

mat4 changeFov(mat4 projection) {
    if (projection[2][3] != 0.0) {
        float aspectInv = projection[0][0] / projection[1][1];
        projection[0][0] = invTanHF * aspectInv;
        projection[1][1] = invTanHF;
    }
    return projection;
}

mat4 changeFov(float fogStart, mat4 projection) {
    if (fogStart > 3e38 && projection[2][3] != 0) {
        return projection;
    }
    return changeFov(projection);
}
