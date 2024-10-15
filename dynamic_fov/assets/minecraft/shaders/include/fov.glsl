// dynamic fov
// https://github.com/JNNGL/vanilla-shaders

uniform float GameTime;

float getFov() {
    return floor(GameTime * 180.0F);
}

mat4 changeFov(mat4 projection) {
    float fov = getFov();
    if (projection[2][3] != 0.0 && fov >= 1.0F) {
        float invTanHF = 1.0 / tan(radians(fov * 0.5));
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
