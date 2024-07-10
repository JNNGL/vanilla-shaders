#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;

out vec4 fragColor;

const ivec3 lookup[] = ivec3[128](
        ivec3(89, 125, 39),   ivec3(109, 153, 48),  ivec3(127, 178, 56),  ivec3(67, 94, 29),
        ivec3(174, 164, 115), ivec3(213, 201, 140), ivec3(247, 233, 163), ivec3(130, 123, 86),
        ivec3(140, 140, 140), ivec3(171, 171, 171), ivec3(199, 199, 199), ivec3(105, 105, 105),
        ivec3(180, 0, 0),     ivec3(220, 0, 0),     ivec3(255, 0, 0),     ivec3(135, 0, 0),
        ivec3(112, 112, 180), ivec3(138, 138, 220), ivec3(160, 160, 255), ivec3(84, 84, 135),
        ivec3(117, 117, 117), ivec3(144, 144, 144), ivec3(167, 167, 167), ivec3(88, 88, 88),
        ivec3(0, 87, 0),      ivec3(0, 106, 0),     ivec3(0, 124, 0),     ivec3(0, 65, 0),
        ivec3(180, 180, 180), ivec3(220, 220, 220), ivec3(255, 255, 255), ivec3(135, 135, 135),
        ivec3(115, 118, 129), ivec3(141, 144, 158), ivec3(164, 168, 184), ivec3(86, 88, 97),
        ivec3(106, 76, 54),   ivec3(130, 94, 66),   ivec3(151, 109, 77),  ivec3(79, 57, 40),
        ivec3(79, 79, 79),    ivec3(96, 96, 96),    ivec3(112, 112, 112), ivec3(59, 59, 59),
        ivec3(45, 45, 180),   ivec3(55, 55, 220),   ivec3(64, 64, 255),   ivec3(33, 33, 135),
        ivec3(100, 84, 50),   ivec3(123, 102, 62),  ivec3(143, 119, 72),  ivec3(75, 63, 38),
        ivec3(180, 177, 172), ivec3(220, 217, 211), ivec3(255, 252, 245), ivec3(135, 133, 129),
        ivec3(152, 89, 36),   ivec3(186, 109, 44),  ivec3(216, 127, 51),  ivec3(114, 67, 27),
        ivec3(125, 53, 152),  ivec3(153, 65, 186),  ivec3(178, 76, 216),  ivec3(94, 40, 114),
        ivec3(72, 108, 152),  ivec3(88, 132, 186),  ivec3(102, 153, 216), ivec3(54, 81, 114),
        ivec3(161, 161, 36),  ivec3(197, 197, 44),  ivec3(229, 229, 51),  ivec3(121, 121, 27),
        ivec3(89, 144, 17),   ivec3(109, 176, 21),  ivec3(127, 204, 25),  ivec3(67, 108, 13),
        ivec3(170, 89, 116),  ivec3(208, 109, 142), ivec3(242, 127, 165), ivec3(128, 67, 87),
        ivec3(53, 53, 53),    ivec3(65, 65, 65),    ivec3(76, 76, 76),    ivec3(40, 40, 40),
        ivec3(108, 108, 108), ivec3(132, 132, 132), ivec3(153, 153, 153), ivec3(81, 81, 81),
        ivec3(53, 89, 108),   ivec3(65, 109, 132),  ivec3(76, 127, 153),  ivec3(40, 67, 81),
        ivec3(89, 44, 125),   ivec3(109, 54, 153),  ivec3(127, 63, 178),  ivec3(67, 33, 94),
        ivec3(36, 53, 125),   ivec3(44, 65, 153),   ivec3(51, 76, 178),   ivec3(27, 40, 94),
        ivec3(72, 53, 36),    ivec3(88, 65, 44),    ivec3(102, 76, 51),   ivec3(54, 40, 27),
        ivec3(72, 89, 36),    ivec3(88, 109, 44),   ivec3(102, 127, 51),  ivec3(54, 67, 27),
        ivec3(108, 36, 36),   ivec3(132, 44, 44),   ivec3(153, 51, 51),   ivec3(81, 27, 27),
        ivec3(17, 17, 17),    ivec3(21, 21, 21),    ivec3(25, 25, 25),    ivec3(13, 13, 13),
        ivec3(176, 168, 54),  ivec3(215, 205, 66),  ivec3(250, 238, 77),  ivec3(132, 126, 40),
        ivec3(64, 154, 150),  ivec3(79, 188, 183),  ivec3(92, 219, 213),  ivec3(48, 115, 112),
        ivec3(52, 90, 180),   ivec3(63, 110, 220),  ivec3(74, 128, 255),  ivec3(39, 67, 135)
);

int decode7u(vec3 color) {
    ivec3 d = ivec3(color * 255.0);
    for (int i = 0; i < 128; i++) {
        if (lookup[i] == d) {
            return i;
        }
    }

    return 0;
}

void main() {
    vec4 color = texture(Sampler0, texCoord0);
    ivec2 texSize = textureSize(Sampler0, 0).xy;
    if (texSize == ivec2(128, 128)) {
        ivec2 coord = (ivec2(floor(texCoord0 * vec2(texSize))) / 2) * 2;
        int b1 = decode7u(texelFetch(Sampler0, coord, 0).rgb);
        int b2 = decode7u(texelFetch(Sampler0, coord + ivec2(1, 0), 0).rgb);
        int b3 = decode7u(texelFetch(Sampler0, coord + ivec2(0, 1), 0).rgb);
        int b4 = decode7u(texelFetch(Sampler0, coord + ivec2(1, 1), 0).rgb);
        b1 |= (b4 & 1) << 7; b2 |= (b4 & 2) << 6; b3 |= (b4 & 4) << 5;
        //int u24 = (b3 << 16) | (b2 << 8) | b1;

        color = vec4(vec3(b3, b2, b1) / 255.0, 1.0);
    }
    color *= vertexColor * ColorModulator;
    if (color.a < 0.1) {
        discard;
    }
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}