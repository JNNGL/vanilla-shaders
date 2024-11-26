#version 330

#ifndef _VOXELIZATION_GLSL
#define _VOXELIZATION_GLSL

ivec2 getVoxelizationRadius(ivec2 screenSize) {
    int pixels = (screenSize.x >> 1) * (screenSize.y - 1);
    int voxelizeDist = int(pow(float(pixels), 1.0 / 3.0));
    
    int voxelizeExt = voxelizeDist / 2;
    voxelizeDist = voxelizeExt * 2;

    return ivec2(voxelizeExt, voxelizeDist);
}

ivec2 voxelToPixel(ivec3 blockPos, ivec2 screenSize, ivec2 voxelizeExtDist) {
    screenSize.x >>= 1;

    blockPos += voxelizeExtDist.x;
    int linearIndex = blockPos.y * voxelizeExtDist.y * voxelizeExtDist.y + blockPos.z * voxelizeExtDist.y + blockPos.x;
    ivec2 pixelPos = ivec2(linearIndex % screenSize.x, linearIndex / screenSize.x);
    pixelPos.x = pixelPos.x * 2 + (pixelPos.y & 1);
    
    pixelPos.y += 1;
    return pixelPos;
}
ivec2 voxelToPixel(ivec3 blockPos, ivec2 screenSize) {
    return voxelToPixel(blockPos, screenSize, getVoxelizationRadius(screenSize));
}

ivec3 pixelToVoxel(ivec2 pixelPos, ivec2 screenSize, ivec2 voxelizeExtDist) {
    screenSize.x >>= 1; pixelPos.x >>= 1;

    pixelPos.y -= 1;
    int linearIndex = pixelPos.y * screenSize.x + pixelPos.x;

    ivec3 blockPos;
    blockPos.x = linearIndex % voxelizeExtDist.y;
    blockPos.z = (linearIndex / voxelizeExtDist.y) % voxelizeExtDist.y;
    blockPos.y = (linearIndex / voxelizeExtDist.y) / voxelizeExtDist.y;
    return blockPos - voxelizeExtDist.x;
}
ivec3 pixelToVoxel(ivec2 pixelPos, ivec2 screenSize) {
    return pixelToVoxel(pixelPos, screenSize, getVoxelizationRadius(screenSize));
}

vec4 placeVoxel(ivec3 blockPos, ivec2 screenSize, int vertexId) {
    ivec2 voxelizeExtDist = getVoxelizationRadius(screenSize);

    if (any(greaterThanEqual(abs(blockPos), ivec3(voxelizeExtDist.x)))) {
        return vec4(-10.0, -10.0, -10.0, 1.0);
    }

    ivec2 pixelPos = voxelToPixel(blockPos, screenSize, voxelizeExtDist);

    vec2 lowerLeft = vec2(pixelPos) / vec2(screenSize);
    vec2 upperRight = lowerLeft + 1.0 / vec2(screenSize);

    vec2 vertex;
    switch (vertexId % 4) {
        case 0: vertex = vec2(lowerLeft.x, upperRight.y); break;
        case 1: vertex = vec2(lowerLeft.x, lowerLeft.y); break;
        case 2: vertex = vec2(upperRight.x, lowerLeft.y); break;
        case 3: vertex = vec2(upperRight.x, upperRight.y); break;
    }

    return vec4(vertex * 2.0 - 1.0, -1.0, 1.0);
}

#endif // _VOXELIZATION_GLSL