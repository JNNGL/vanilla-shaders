#version 330

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;
uniform sampler2D PreviousDataSampler;

uniform vec2 OutSize;

in vec2 texCoord;
flat in mat4 invProjMat;
flat in mat3 invViewMat;
flat in mat4 prevProjMat;
flat in mat3 prevViewMat;
flat in vec3 cameraOffset;

out vec4 fragColor;

vec3 toWorldSpace(vec2 uv, float z) {
    vec4 clip = vec4(uv, z, 1.0) * 2.0 - 1.0;
    vec4 position = invProjMat * clip;
    return invViewMat * (position.xyz / position.w);
}

vec2 toScreenSpace(vec3 position) {
    vec4 clip = prevProjMat * vec4(prevViewMat * position, 1.0);
    return clip.xy / clip.w * 0.5 + 0.5;
}

void main() {
    const int numSamples = 12;
    const float strength = 0.03;

    uvec4 depthData = uvec4(texture(DiffuseDepthSampler, texCoord) * 255.0);
    uint bits = (depthData.r << 24) | (depthData.g << 16) | (depthData.b << 8) | depthData.a;
    float depth = uintBitsToFloat(bits);

    vec3 worldSpace = toWorldSpace(texCoord, depth);
    vec2 prevPos = toScreenSpace(worldSpace - cameraOffset);

    vec2 velocity = texCoord - prevPos;
    velocity /= 1.0 + length(velocity);
    velocity *= strength;

    vec3 color = vec3(0.0);
    vec2 sampleCoord = texCoord - velocity * 0.5 * float(numSamples);

    vec2 markerCutoff = vec2(0.0, 1.5 / OutSize.y);
    for (int i = 0; i < numSamples; ++i, sampleCoord += velocity) {
        vec2 currentCoord = clamp(sampleCoord, markerCutoff, vec2(1.0));
        vec4 currentColor = texture(DiffuseSampler, currentCoord);
        color += currentColor.rgb;
    }

    fragColor = vec4(color / float(numSamples), 1.0);
}
