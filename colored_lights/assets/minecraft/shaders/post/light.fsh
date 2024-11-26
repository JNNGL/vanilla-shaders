#version 330

// #extension GL_MC_moj_import : enable
#moj_import <minecraft:encodings.glsl>
#moj_import <minecraft:projections.glsl>
#moj_import <minecraft:voxelization.glsl>
#moj_import <minecraft:tonemapping.glsl>
#moj_import <settings:settings.glsl>

uniform sampler2D InSampler;
uniform sampler2D VoxelSampler;
uniform sampler2D DepthSampler;
uniform sampler2D NoiseSampler;
uniform sampler2D DataSampler;

uniform vec2 DataSize;

in vec2 texCoord;
flat in mat4 invProjView;
flat in vec3 blockOffset;
flat in ivec2 voxelizeDist;

out vec4 fragColor;

vec3 fetchLightData(ivec3 voxelPos) {
    ivec2 pixelPos = voxelToPixel(voxelPos, ivec2(DataSize), voxelizeDist);
    if (clamp(pixelPos, ivec2(0, 1), ivec2(DataSize) - 1) != pixelPos) return vec3(0.0);
    vec4 lightData = texelFetch(VoxelSampler, pixelPos, 0);
    if (lightData == vec4(1.0)) return vec3(0.0);
    return decodeLogLuv(lightData);
}

void main() {
    vec2 texCoord0 = texCoord;
    if (int(gl_FragCoord.y) == 0) {
        texCoord0.y += 1.0 / DataSize.y;
    }

    vec4 data = texture(DataSampler, texCoord0);
    if (int(round(data.a * 255.0)) == 100) {
        texCoord0.x += 1.0 / DataSize.x;
    }

    fragColor = texture(InSampler, texCoord0);

    float depth = texture(DepthSampler, texCoord0).r;
    if (depth == 1.0) {
        return;
    }

    vec3 fragPos = unprojectScreenSpace(invProjView, texCoord0, depth);
    vec3 direction = normalize(fragPos);
    fragPos -= blockOffset + sign(direction) * 0.005;

    ivec2 noiseCoord = ivec2(gl_FragCoord.xy) % 512;
    vec3 dither = texelFetch(NoiseSampler, noiseCoord, 0).rgb;

#if (ENABLE_INTERPOLATION == yes)
    fragPos -= 1.0;
#endif // ENABLE_INTERPOLATION

#if (ENABLE_LIGHT_DITHERING == yes)
    fragPos += dither - direction * 0.5;
#endif // ENABLE_LIGHT_DITHERING

    ivec3 voxelPos = ivec3(fragPos);
    voxelPos -= ivec3(lessThan(fragPos, vec3(0.0)));

#if (ENABLE_INTERPOLATION == yes)
    vec3 fractPos = fract(fragPos);

    vec3 t000 = fetchLightData(voxelPos + ivec3(0, 0, 0));
    vec3 t100 = fetchLightData(voxelPos + ivec3(1, 0, 0));
    vec3 t001 = fetchLightData(voxelPos + ivec3(0, 0, 1));
    vec3 t101 = fetchLightData(voxelPos + ivec3(1, 0, 1));
    vec3 t010 = fetchLightData(voxelPos + ivec3(0, 1, 0));
    vec3 t110 = fetchLightData(voxelPos + ivec3(1, 1, 0));
    vec3 t011 = fetchLightData(voxelPos + ivec3(0, 1, 1));
    vec3 t111 = fetchLightData(voxelPos + ivec3(1, 1, 1));

    vec3 lightData = (1.0 - fractPos.x) * (1.0 - fractPos.y) * (1.0 - fractPos.z) * t000 + 
            fractPos.x * (1.0 - fractPos.y) * (1.0 - fractPos.z) * t100 + 
            (1.0 - fractPos.x) * fractPos.y * (1.0 - fractPos.z) * t010 + 
            fractPos.x * fractPos.y * (1.0 - fractPos.z) * t110 + 
            (1.0 - fractPos.x) * (1.0 - fractPos.y) * fractPos.z * t001 + 
            fractPos.x * (1.0 - fractPos.y) * fractPos.z * t101 + 
            (1.0 - fractPos.x) * fractPos.y * fractPos.z * t011 + 
            fractPos.x * fractPos.y * fractPos.z * t111;
#else
    vec3 lightData = fetchLightData(voxelPos);
#endif

    fragColor.rgb += dither / 256.0;
    fragColor.rgb = acesInverse(fragColor.rgb);
    fragColor.rgb *= (1.0 + sqrt(lightData / (1.0 + lightData)));
    fragColor.rgb = acesFilm(fragColor.rgb);

#if (VISUALIZE_LIGHT_COLOR == yes)
    fragColor.rgb = sqrt(lightData / (1.0 + lightData * lightData));
#endif
}