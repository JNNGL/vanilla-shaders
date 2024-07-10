#include <string.h>
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

#define make_color(r, g, b) (((uint32_t) r) | ((uint32_t) g << 8) | ((uint32_t) b << 16) | (255u << 24))

uint32_t map_color_palette[] = {
        make_color(89, 125, 39),   make_color(109, 153, 48),  make_color(127, 178, 56),  make_color(67, 94, 29),
        make_color(174, 164, 115), make_color(213, 201, 140), make_color(247, 233, 163), make_color(130, 123, 86),
        make_color(140, 140, 140), make_color(171, 171, 171), make_color(199, 199, 199), make_color(105, 105, 105),
        make_color(180, 0, 0),     make_color(220, 0, 0),     make_color(255, 0, 0),     make_color(135, 0, 0),
        make_color(112, 112, 180), make_color(138, 138, 220), make_color(160, 160, 255), make_color(84, 84, 135),
        make_color(117, 117, 117), make_color(144, 144, 144), make_color(167, 167, 167), make_color(88, 88, 88),
        make_color(0, 87, 0),      make_color(0, 106, 0),     make_color(0, 124, 0),     make_color(0, 65, 0),
        make_color(180, 180, 180), make_color(220, 220, 220), make_color(255, 255, 255), make_color(135, 135, 135),
        make_color(115, 118, 129), make_color(141, 144, 158), make_color(164, 168, 184), make_color(86, 88, 97),
        make_color(106, 76, 54),   make_color(130, 94, 66),   make_color(151, 109, 77),  make_color(79, 57, 40),
        make_color(79, 79, 79),    make_color(96, 96, 96),    make_color(112, 112, 112), make_color(59, 59, 59),
        make_color(45, 45, 180),   make_color(55, 55, 220),   make_color(64, 64, 255),   make_color(33, 33, 135),
        make_color(100, 84, 50),   make_color(123, 102, 62),  make_color(143, 119, 72),  make_color(75, 63, 38),
        make_color(180, 177, 172), make_color(220, 217, 211), make_color(255, 252, 245), make_color(135, 133, 129),
        make_color(152, 89, 36),   make_color(186, 109, 44),  make_color(216, 127, 51),  make_color(114, 67, 27),
        make_color(125, 53, 152),  make_color(153, 65, 186),  make_color(178, 76, 216),  make_color(94, 40, 114),
        make_color(72, 108, 152),  make_color(88, 132, 186),  make_color(102, 153, 216), make_color(54, 81, 114),
        make_color(161, 161, 36),  make_color(197, 197, 44),  make_color(229, 229, 51),  make_color(121, 121, 27),
        make_color(89, 144, 17),   make_color(109, 176, 21),  make_color(127, 204, 25),  make_color(67, 108, 13),
        make_color(170, 89, 116),  make_color(208, 109, 142), make_color(242, 127, 165), make_color(128, 67, 87),
        make_color(53, 53, 53),    make_color(65, 65, 65),    make_color(76, 76, 76),    make_color(40, 40, 40),
        make_color(108, 108, 108), make_color(132, 132, 132), make_color(153, 153, 153), make_color(81, 81, 81),
        make_color(53, 89, 108),   make_color(65, 109, 132),  make_color(76, 127, 153),  make_color(40, 67, 81),
        make_color(89, 44, 125),   make_color(109, 54, 153),  make_color(127, 63, 178),  make_color(67, 33, 94),
        make_color(36, 53, 125),   make_color(44, 65, 153),   make_color(51, 76, 178),   make_color(27, 40, 94),
        make_color(72, 53, 36),    make_color(88, 65, 44),    make_color(102, 76, 51),   make_color(54, 40, 27),
        make_color(72, 89, 36),    make_color(88, 109, 44),   make_color(102, 127, 51),  make_color(54, 67, 27),
        make_color(108, 36, 36),   make_color(132, 44, 44),   make_color(153, 51, 51),   make_color(81, 27, 27),
        make_color(17, 17, 17),    make_color(21, 21, 21),    make_color(25, 25, 25),    make_color(13, 13, 13),
        make_color(176, 168, 54),  make_color(215, 205, 66),  make_color(250, 238, 77),  make_color(132, 126, 40),
        make_color(64, 154, 150),  make_color(79, 188, 183),  make_color(92, 219, 213),  make_color(48, 115, 112),
        make_color(52, 90, 180),   make_color(63, 110, 220),  make_color(74, 128, 255),  make_color(39, 67, 135),
        make_color(0, 153, 40),    make_color(0, 187, 50),    make_color(0, 217, 58),    make_color(0, 114, 30),
        make_color(91, 60, 34),    make_color(111, 74, 42),   make_color(129, 86, 49),   make_color(68, 45, 25),
        make_color(79, 1, 0),      make_color(96, 1, 0),      make_color(112, 2, 0),     make_color(59, 1, 0),
        make_color(147, 124, 113), make_color(180, 152, 138), make_color(209, 177, 161), make_color(110, 93, 85),
        make_color(112, 57, 25),   make_color(137, 70, 31),   make_color(159, 82, 36),   make_color(84, 43, 19),
        make_color(105, 61, 76),   make_color(128, 75, 93),   make_color(149, 87, 108),  make_color(78, 46, 57),
        make_color(79, 76, 97),    make_color(96, 93, 119),   make_color(112, 108, 138), make_color(59, 57, 73),
        make_color(131, 93, 25),   make_color(160, 114, 31),  make_color(186, 133, 36),  make_color(98, 70, 19),
        make_color(72, 82, 37),    make_color(88, 100, 45),   make_color(103, 117, 53),  make_color(54, 61, 28),
        make_color(112, 54, 55),   make_color(138, 66, 67),   make_color(160, 77, 78),   make_color(84, 40, 41),
        make_color(40, 28, 24),    make_color(49, 35, 30),    make_color(57, 41, 35),    make_color(30, 21, 18),
        make_color(95, 75, 69),    make_color(116, 92, 84),   make_color(135, 107, 98),  make_color(71, 56, 51),
        make_color(61, 64, 64),    make_color(75, 79, 79),    make_color(87, 92, 92),    make_color(46, 48, 48),
        make_color(86, 51, 62),    make_color(105, 62, 75),   make_color(122, 73, 88),   make_color(64, 38, 46),
        make_color(53, 43, 64),    make_color(65, 53, 79),    make_color(76, 62, 92),    make_color(40, 32, 48),
        make_color(53, 35, 24),    make_color(65, 43, 30),    make_color(76, 50, 35),    make_color(40, 26, 18),
        make_color(53, 57, 29),    make_color(65, 70, 36),    make_color(76, 82, 42),    make_color(40, 43, 22),
        make_color(100, 42, 32),   make_color(122, 51, 39),   make_color(142, 60, 46),   make_color(75, 31, 24),
        make_color(26, 15, 11),    make_color(31, 18, 13),    make_color(37, 22, 16),    make_color(19, 11, 8),
        make_color(133, 33, 34),   make_color(163, 41, 42),   make_color(189, 48, 49),   make_color(100, 25, 25),
        make_color(104, 44, 68),   make_color(127, 54, 83),   make_color(148, 63, 97),   make_color(78, 33, 51),
        make_color(64, 17, 20),    make_color(79, 21, 25),    make_color(92, 25, 29),    make_color(48, 13, 15),
        make_color(15, 88, 94),    make_color(18, 108, 115),  make_color(22, 126, 134),  make_color(11, 66, 70),
        make_color(40, 100, 98),   make_color(50, 122, 120),  make_color(58, 142, 140),  make_color(30, 75, 74),
        make_color(60, 31, 43),    make_color(74, 37, 53),    make_color(86, 44, 62),    make_color(45, 23, 32),
        make_color(14, 127, 93),   make_color(17, 155, 114),  make_color(20, 180, 133),  make_color(10, 95, 70),
        make_color(70, 70, 70),    make_color(86, 86, 86),    make_color(100, 100, 100), make_color(52, 52, 52),
        make_color(152, 123, 103), make_color(186, 150, 126), make_color(216, 175, 147), make_color(114, 92, 77),
        make_color(89, 117, 105),  make_color(109, 144, 129), make_color(127, 167, 150), make_color(67, 88, 79)
};

struct map_data {
    uint32_t data[128][128];
    uint8_t indexes[128][128];
};

struct arb_data {
    uint32_t data[4096];
};

uint32_t base_color(int base_index) {
    return map_color_palette[base_index * 4 + 2];
}

void encode_arb(struct map_data* out, struct arb_data* in) {
    for (int x = 0; x < 64; x++) {
        for (int y = 0; y < 64; y++) {
            uint32_t d = in->data[y * 64 + x];
            uint8_t b1 = d & 0xFF; uint8_t msb1 = b1 >> 7;
            uint8_t b2 = (d >> 8) & 0xFF; uint8_t msb2 = b2 >> 7;
            uint8_t b3 = (d >> 16) & 0xFF; uint8_t msb3 = b3 >> 7;
            uint8_t b4 = (msb3 << 2) | (msb2 << 1) | msb1;
            b1 &= 0x7F; b2 &= 0x7F; b3 &= 0x7F;
            out->data[y * 2][x * 2] = map_color_palette[out->indexes[y * 2][x * 2] = b1];
            out->data[y * 2][x * 2 + 1] = map_color_palette[out->indexes[y * 2][x * 2 + 1] = b2];
            out->data[y * 2 + 1][x * 2] = map_color_palette[out->indexes[y * 2 + 1][x * 2] = b3];
            out->data[y * 2 + 1][x * 2 + 1] = map_color_palette[out->indexes[y * 2 + 1][x * 2 + 1] = b4];
        }
    }
}

uint8_t decode7u(struct map_data* in, int x, int y) {
    /*
    int color = in->data[y][x];
    for (int i = 0; i < 128; i++) {
        if (map_color_palette[i] == color) {
            return i;
        }
    }

    return 0;
     */

    return in->indexes[y][x];
}

void decode_arb(struct map_data* in, struct arb_data* out) {
    for (int x = 0; x < 64; x++) {
        for (int y = 0; y < 64; y++) {
            uint8_t b1 = decode7u(in, x * 2, y * 2);
            uint8_t b2 = decode7u(in, x * 2 + 1, y * 2);
            uint8_t b3 = decode7u(in, x * 2, y * 2 + 1);
            uint8_t b4 = decode7u(in, x * 2 + 1, y * 2 + 1);
            b1 |= (b4 & 1) << 7; b2 |= (b4 & 2) << 6; b3 |= (b4 & 4) << 5;
            uint32_t u24 = ((uint32_t) b3 << 16) | ((uint32_t) b2 << 8) | b1;
            out->data[y * 64 + x] = u24;
        }
    }
}

void save_map(struct map_data* map) {
    stbi_write_png("output.png", 128, 128, 4, map->data, 0);
}

int main() {
    struct arb_data arb_in, arb_out;
    struct map_data map;

    bzero(&arb_in, sizeof(arb_in));
    bzero(&arb_out, sizeof(arb_out));
    bzero(&map, sizeof(map));

    for (int x = 0; x < 4096; x++) {
        arb_in.data[x] = x;
    }

    encode_arb(&map, &arb_in);
    decode_arb(&map, &arb_out);

    save_map(&map);

    printf("%d\n", memcmp(arb_in.data, arb_out.data, sizeof(arb_in.data)));

    return 0;
}
