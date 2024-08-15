#version 150

// Font from https://github.com/bradleyq/mc_vanilla_shaders/blob/c865af504a06f124b7ad472b7741f2c1216e9985/resourcepack-shaders/assets/minecraft/shaders/core/position_color.fsh
#define  _SPACE  0u
#define      _A  488621617u
#define      _B  1025459774u
#define      _C  488129070u
#define      _D  1025033790u
#define      _E  1057964575u
#define      _F  1057964560u
#define      _G  488132142u
#define      _H  589284913u
#define      _I  474091662u
#define      _J  237046348u
#define      _K  589982257u
#define      _L  554189343u
#define      _M  599442993u
#define      _N  597347889u
#define      _O  488162862u
#define      _P  1025458704u
#define      _Q  488166989u
#define      _R  1025459761u
#define      _S  520553534u
#define      _T  1044516996u
#define      _U  588826158u
#define      _V  588818756u
#define      _W  588830378u
#define      _X  581052977u
#define      _Y  581046404u
#define      _Z  1042424351u
#define _PARENL  142876932u
#define _PARENR  136382532u
#define _RSLASH  35787024u
#define _LSLASH  545394753u
#define    _DOT  4u
#define  _COMMA  68u
#define   _HASH  368389098u
#define      _1  147460255u
#define      _2  487657759u
#define      _3  487654958u
#define      _4  73747426u
#define      _5  1057949230u
#define      _6  487540270u
#define      _7  1041305732u
#define      _8  488064558u
#define      _9  488080942u
#define      _0  490399278u
#define _USCORE  31u
#define   _DASH  1015808u
#define   _PLUS  139432064u

#define TEXT_SCALE 2

const uint _DIGITS[] = uint[](
    _0, _1, _2, _3, _4, _5, _6, _7, _8, _9
);

bool getPixel(uint character, int x, int y) {
    return ((character >> (4 - x + (5 - y) * 5)) & 1u) == 1u;
}

vec4 _text_color;
ivec2 _text_coord;
ivec2 _frag_coord;
vec4 _frag_color;

void resetText(ivec2 coord) {
    _text_coord = ivec2(1, 1);
    _frag_coord = coord / TEXT_SCALE;
    _frag_color = vec4(0.0);
    _text_color = vec4(1.0);
}

void setTextColor(vec4 textColor) {
    _text_color = textColor;
}

void c(uint character) {
    ivec2 localCoord = _frag_coord - _text_coord;
    if (clamp(localCoord, ivec2(0, 0), ivec2(4, 5)) == localCoord) {
        _frag_color = getPixel(character, localCoord.x, localCoord.y) ? _text_color : vec4(0.0);
    }
    _text_coord.x += 6;
}

void d(int digit) {
    c(_DIGITS[digit]);
}

void f(float value) {
    if (value < 0.0) {
        value *= -1.0;
        c(_DASH);
    }

    if (floor(value) == 0.0) {
        d(0);
    } else {
        int j = int(floor(log(floor(value))) + 1.0);
        for (int i = 0; i < j; i++) {        
            float magnitude = pow(10.0, j - 1.0 - i);
            float digit = floor(value / magnitude);
            d(int(digit));
            value -= digit * magnitude;
        }
    }

    c(_DOT);

    const int N = 5;
    if (floor(value * pow(10.0, N)) == 0.0) {
        d(0);
        return;
    }

    for (int i = 0; i < N; i++) {
        value *= 10.0;
        d(int(floor(value)) % 10);
        if (floor(fract(value) * pow(10.0, N - 1 - i)) == 0.0) {
            break;
        }
    }
}

void cb(vec3 color) {
    ivec2 localCoord = _frag_coord - _text_coord;
    if (clamp(localCoord, ivec2(0, 0), ivec2(5, 5)) == localCoord) {
        _frag_color = vec4(0.0, 0.0, 0.0, 1.0);
        if (clamp(localCoord, ivec2(1, 1), ivec2(4, 4)) == localCoord) {
            _frag_color = vec4(color, 1.0);
        }
    }
    _text_coord.x += 7;
    c(_PARENL);
    f(color[0]);
    c(_COMMA);c(_SPACE);
    f(color[1]);
    c(_COMMA);c(_SPACE);
    f(color[2]);
    c(_PARENR);
}

void nl() {
    _text_coord.y += 7;
    _text_coord.x = 1;
}

vec4 getTextPixelColor() {
    return _frag_color;
}