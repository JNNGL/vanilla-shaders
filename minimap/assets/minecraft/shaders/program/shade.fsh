#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D PaletteSampler;
uniform vec2 InSize;
uniform vec2 OutSize;

in vec2 ditherOffset;

out vec4 fragColor;

#define MAP(v, t) case ((int(v.r)<<16) + (int(v.g)<<8) + int(v.b)): color.rgb = t/255.; break; case ((int(v.r*220./255.)<<16) + (int(v.g*220./255.)<<8) + int(v.b*220./255.)): color.rgb = t/255.*220./255.; break; case ((int(v.r*180./255.)<<16) + (int(v.g*180./255.)<<8) + int(v.b*180./255.)): color.rgb = t/255.*180./255.; break; case ((int(v.r*135./255.)<<16) + (int(v.g*135./255.)<<8) + int(v.b*135./255.)): color.rgb = t/255.*135./255.; break;

// TODO: Remap palette
void remapColor(inout vec4 color) {
    // Godlander's map colors
    // https://github.com/Godlander/vpp/blob/main/assets/minecraft/shaders/core/render/text.fsh
    ivec3 i = ivec3(color.rgb * 255.5);
    switch ((i.r << 16) + (i.g << 8) + i.b) {
        MAP(vec3(127.,178.,56.) ,   vec3(94.,123.,57.))
        MAP(vec3(247.,233.,163.),   vec3(248.,235.,186.))
        MAP(vec3(160.,160.,255.),   vec3(132.,171.,244.))
        MAP(vec3(167.,167.,167.),   vec3(200.,200.,200.))
        MAP(vec3(0.,124.,0.)    ,   vec3(58.,86.,39.))
        MAP(vec3(164.,168.,184.),   vec3(182.,189.,204.))
        MAP(vec3(151.,109.,77.) ,   vec3(157.,113.,80.))
        MAP(vec3(112.,112.,112.),   vec3(143.,143.,143.))
        MAP(vec3(64.,64.,255.)  ,   vec3(41.,71.,130.))
        MAP(vec3(143.,119.,72.) ,   vec3(187.,152.,93.))
        MAP(vec3(250.,238.,77.) ,   vec3(255.,239.,79.))
        MAP(vec3(74.,128.,255.) ,   vec3(37.,79.,160.))
        MAP(vec3(0.,217.,58.)   ,   vec3(66.,233.,113.))
        MAP(vec3(129.,86.,49.)  ,   vec3(108.,75.,29.))
        MAP(vec3(127.,63.,178.) ,   vec3(133.,107.,153))
        MAP(vec3(112.,2.,0.)    ,   vec3(113.,47.,47.))
        MAP(vec3(255.,0.,0.)    ,   vec3(215.,53.,2.))
    }
}

struct map_fragment {
    int index;
    int height;
};

map_fragment decodeFragment(ivec2 coord) {
    ivec4 data = ivec4(texelFetch(DiffuseSampler, coord, 0) * 255.0);
    int index = data.r;
    int height = data.g << 8 | data.b;
    return map_fragment(index, height - 386);
}

vec4 paletteColor(int index, int brightness) {
    return texelFetch(PaletteSampler, ivec2(brightness, index), 0);
}

void main() {
    map_fragment center = decodeFragment(ivec2(gl_FragCoord.xy));
    map_fragment neigh = decodeFragment(ivec2(gl_FragCoord.xy) - ivec2(0, 1));
    
    float d2 = (center.height - neigh.height) * 4.0 / 5.0 + (float(int(0) & 1) - 0.5) * 0.4;

    int brightness = 0;
    if (d2 > 0.6) {
        brightness = 2;
      } else if (d2 < -0.6) {
        brightness = 0;
      } else {
        brightness = 1;
      }

    fragColor = paletteColor(center.index, brightness);
    remapColor(fragColor);
}