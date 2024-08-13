// gui avatars
// https://github.com/JNNGL/vanilla-shaders

#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec4 lightMapColor;
in vec4 overlayColor;
in vec2 texCoord0;
in vec3 normal;
flat in int quadId;
flat in int renderAvatar;

out vec4 fragColor;

#define OUTLINE_COLOR (vec4(0.0, 0.0, 0.0, 1.0))

bool rect(ivec2 coord, int x1, int x2, int y1, int y2) {
    return coord.x >= x1 && coord.x < x2 && coord.y >= y1 && coord.y < y2;
}

vec4 renderHead(ivec2 pixelReset) {
    vec4 fragColor = vec4(0.0);
    ivec2 pixel = pixelReset;

    if (rect(pixel, 0, 16, 0, 18)) { // Overlay Front
        if (pixel.y > 1) pixel.y--;
        if (pixel.y > 15) pixel.y--;
        ivec2 coord = pixel / 2 + ivec2(40, 8);
        fragColor = texelFetch(Sampler0, coord, 0);
        pixel = pixelReset;
    } else if (rect(pixel, 16, 24, 0, 18)) { // Overlay Right
        pixel.x -= 16;
        if (pixel.y > 0) pixel.y--;
        if (pixel.y > 15) pixel.y--;
        ivec2 coord = pixel / ivec2(1, 2) + ivec2(48, 8);
        fragColor = texelFetch(Sampler0, coord, 0);
        pixel = pixelReset;
        fragColor.rgb *= 0.6;
    }

    if (fragColor.a < 1.0) {
        if (rect(pixel, 1, 16, 1, 17)) { // Front
            pixel--;
            if (pixel.x > 6) pixel.x++;
            ivec2 coord = pixel / 2 + 8;
            vec4 tex = texelFetch(Sampler0, coord, 0);
            if (tex.a > 0.1) {
                fragColor.rgb = mix(tex.rgb, fragColor.rgb, fragColor.a);
                fragColor.a = 1.0;
            }
        } else if (rect(pixel, 16, 24, 1, 17)) { // Side
            pixel--;
            ivec2 coord = (pixel - ivec2(15, 0)) / ivec2(1, 2) + ivec2(16, 8);
            vec4 tex = texelFetch(Sampler0, coord, 0);
            if (tex.a > 0.1) {
                fragColor.rgb = mix(tex.rgb * 0.6, fragColor.rgb, fragColor.a);
                fragColor.a = 1.0;
            }
        }
        pixel = pixelReset;
    }

    if (rect(pixel, 8, 23, 0, 1)) { // Overlay Back
        pixel.x -= 8;
        ivec2 coord = pixel / 2 + ivec2(56, 8);
        vec4 tex = texelFetch(Sampler0, coord, 0);
        if (tex.a > 0.0 && texelFetch(Sampler0, coord + ivec2(0, 1), 0).a > 0.1) {
            fragColor = tex;
        }
        pixel = pixelReset;
    }

    if (fragColor.a > 0.1 && fragColor.a < 1.0) {
        fragColor.rgb = mix(vec3(0.0), fragColor.rgb, fragColor.a);
        fragColor.a = 1.0;
    }

    return fragColor;
}

vec4 renderBody(ivec2 pixelReset) {
    vec4 fragColor = vec4(0.0);
    ivec2 pixel = pixelReset;

    if (rect(pixel, 3, 18, 17, 31)) { // Front
        pixel -= ivec2(3, 17);
        if (pixel.x > 6) pixel.x++;
        ivec2 coord = pixel / 2 + ivec2(20, 36); // Overlay
        fragColor = texelFetch(Sampler0, coord, 0);
        if (fragColor.a < 0.1) {
            ivec2 coord = pixel / 2 + 20; // Body
            fragColor = texelFetch(Sampler0, coord, 0);
        }
        pixel = pixelReset;
    }

    return fragColor;
}

vec4 renderArmRight(ivec2 pixelReset) {
    vec4 fragColor = vec4(0.0);
    ivec2 pixel = pixelReset;

    if (rect(pixel, 19, 25, 17, 31)) { // Front
        pixel -= ivec2(19, 17);
        ivec2 coord = pixel / 2 + ivec2(52, 52); // Overlay
        fragColor = texelFetch(Sampler0, coord, 0);
        if (fragColor.a < 0.1) {
            ivec2 coord = pixel / 2 + ivec2(36, 52); // Arm
            fragColor = texelFetch(Sampler0, coord, 0);
        }
        pixel = pixelReset;
    } else if (rect(pixel, 25, 28, 17, 31)) { // Side
        pixel -= ivec2(25, 17);
        if (pixel == ivec2(2, 0)) return vec4(0.0);
        ivec2 coord = pixel / ivec2(1, 2) + ivec2(56, 52); // Overlay
        fragColor = texelFetch(Sampler0, coord, 0);
        if (fragColor.a < 0.1) {
            ivec2 coord = pixel / ivec2(1, 2) + ivec2(40, 52); // Arm
            fragColor = texelFetch(Sampler0, coord, 0);
        }
        fragColor.rgb *= 0.6;
        pixel = pixelReset;
    }

    return fragColor;
}

vec4 renderArmLeft(ivec2 pixelReset) {
    vec4 fragColor = vec4(0.0);
    ivec2 pixel = pixelReset;

    if (rect(pixel, 0, 6, 17, 31)) {
        pixel -= ivec2(0, 17);
        ivec2 coord = pixel / 2 + ivec2(44, 36); // Overlay
        fragColor = texelFetch(Sampler0, coord, 0);
        if (fragColor.a < 0.1) {
            ivec2 coord = pixel / 2 + ivec2(44, 20); // Arm
            fragColor = texelFetch(Sampler0, coord, 0);
        }
        pixel = pixelReset;
    }

    return fragColor;
}

vec4 render(ivec2 pixelReset) {
    const ivec2 outlineOffsets[] = ivec2[](ivec2(-1, 1), ivec2(0, 1), ivec2(1, 1), ivec2(1, 0), ivec2(1, -1), ivec2(0, -1), ivec2(-1, -1), ivec2(-1, 0));

    vec4 fragColor = vec4(0.0);

    fragColor = renderArmRight(pixelReset - 1 - ivec2(3, 0));
    if (fragColor.a < 0.1) { // Right arm outline
        for (int i = 0; i < 8; i++) {
            if (renderArmRight(pixelReset - 1 - ivec2(3, 0) + outlineOffsets[i]).a >= 0.1) {
                fragColor = OUTLINE_COLOR;
                break;
            }
        }
    }

    if (fragColor.a < 0.1) {
        fragColor = renderHead(pixelReset - 1 - ivec2(3, 0));
        if (fragColor.a < 0.1) { // Head outline
            for (int i = 0; i < 8; i++) {
                if (renderHead(pixelReset - 1 - ivec2(3, 0) + outlineOffsets[i]).a >= 0.1) {
                    fragColor = OUTLINE_COLOR;
                    break;
                }
            }
        }
    }

    if (fragColor.a < 0.1) {
        fragColor = renderBody(pixelReset - 1 - ivec2(3, 0));
        if (fragColor.a < 0.1) { // Body outline
            for (int i = 0; i < 8; i++) {
                if (renderBody(pixelReset - 1 - ivec2(3, 0) + outlineOffsets[i]).a >= 0.1) {
                    fragColor = OUTLINE_COLOR;
                    break;
                }
            }
        }
    }

    if (fragColor.a < 0.1) {
        fragColor = renderArmLeft(pixelReset - 1);
        if (fragColor.a < 0.1) { // Left arm outline
            for (int i = 0; i < 8; i++) {
                if (renderArmLeft(pixelReset - 1 + outlineOffsets[i]).a >= 0.1) {
                    fragColor = OUTLINE_COLOR;
                    break;
                }
            }
        }
    }

    return fragColor;
}

vec4 renderOutlined(ivec2 pixelReset) {
    vec4 fragColor = render(pixelReset - 1);
    if (fragColor.a < 0.1) {
        const ivec2 outlineOffsets[] = ivec2[](ivec2(-1, 0), ivec2(1, 0), ivec2(0, 1));
        for (int i = 0; i < 3; i++) {
            if (render(pixelReset - 1 + outlineOffsets[i]).a >= 0.1) {
                fragColor = OUTLINE_COLOR;
                break;
            }
        }
    }

    return fragColor;
}

void main() {
    if (renderAvatar > 0) {
        if (quadId != 3) discard;

        ivec2 pixelReset = ivec2(round(texCoord0 * 37.0 - 0.5));
        fragColor = renderOutlined(pixelReset);

        if (fragColor.a < 0.1) discard;
        fragColor.a = 1.0;
    } else {
        vec4 color = texture(Sampler0, texCoord0);
        if (color.a < 0.1) {
            discard;
        }
        color *= vertexColor * ColorModulator;
        color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
        color *= lightMapColor;
        fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
    }
}
