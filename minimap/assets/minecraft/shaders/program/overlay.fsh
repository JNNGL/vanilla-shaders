// minimap
// https://github.com/JNNGL/vanilla-shaders

#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D MapSampler;
uniform sampler2D CursorSampler;
uniform vec2 OutSize;

in vec2 subBlock;
in vec2 texCoord;
in float yaw;

out vec4 fragColor;

mat2 mat2_rotate_z(float radians) {
    return mat2(
        cos(radians), -sin(radians),
        sin(radians), cos(radians)
    );
}

void main() {
    float ratio = OutSize.x / OutSize.y;
    float vratio = OutSize.y / OutSize.x;
    if (vratio < ratio) ratio = 1;
    else vratio = 1;

    vec2 mapTc0 = vec2(-1 + 0.04 * vratio, 1 - 0.7 * ratio) * 0.5 + 0.5;
    vec2 mapTc1 = vec2(-1 + 0.7 * vratio, 1 - 0.04 * ratio) * 0.5 + 0.5;
    
    vec2 mapped = texCoord - mapTc0;
    mapped /= (mapTc1 - mapTc0);

    fragColor = texture(DiffuseSampler, texCoord);
    fragColor.a = 1.0;

    if (clamp(mapped, 0, 1) != mapped) {
        return;
    }

    vec4 cursor = texture(CursorSampler, 1.0 - mapped);
    if (cursor.a > 0.1) {
        fragColor = cursor;
        return;
    }

    vec2 uvn11 = mapped * 2.0 - 1.0;
    float dist = dot(uvn11, uvn11);
    if (dist < 0.87) {
        mapped = ((mapped - 0.5) * mat2_rotate_z(-yaw)).yx / 4.0 + 0.5;
        fragColor = texture(MapSampler, mapped - subBlock / 512.0);
    } else if (dist < 0.93) {
        fragColor = vec4(17. / 255.);
        if (dist > 0.89 && dist < 0.92) {
            fragColor = vec4(40. / 255.);
            if (dist > 0.9) {
                fragColor = vec4(70. / 255.);
            }
        }
        fragColor.a = 1.0;
    }
}
