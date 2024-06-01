#version 150

uniform sampler2D DiffuseSampler;

uniform vec2 OutSize;
uniform float Time;

in vec2 texCoord;

out vec4 fragColor;
flat in mat4 projection;
flat in mat4 projInv;
flat in mat3 tbn;

#define AXIS_X 0
#define AXIS_Y 1
#define AXIS_Z 2

mat3 mat3_rotate(float radians, const int axis) {
    float cr = cos(radians);
    float sr = sin(radians);
    if (axis == AXIS_Z) {
        return mat3(
            cr, -sr, 0,
            sr, cr, 0,
            0, 0, 1
        );
    } else if (axis == AXIS_Y) {
        return mat3(
            cr, 0, sr,
            0, 1, 0,
            -sr, 0, cr
        );
    } else if (axis == AXIS_X) {
        return mat3(
            1, 0, 0,
            0, cr, -sr,
            0, sr, cr
        );
    } else {
        return mat3(1.0);
    }
}

void main() {
    const float zoom = 0.8; // lower values = higher rotation angles, but lower fov and quality
    vec2 transformed = texCoord * zoom;

    vec4 homog = projInv * vec4(transformed, -1.0, 1.0);
    vec3 near = homog.xyz / homog.w;

    //near = near * mat3_rotate(sin(Time * 2 * 3.14159) * 0.1, AXIS_X);
    //near = near * mat3_rotate(cos(Time * 2 * 3.14159) * 0.1, AXIS_Y);
    //near = near * mat3_rotate(sin(Time * 2 * 3.14159) * 0.1, AXIS_Z);
    near = tbn * near;

    homog = projection * vec4(near, 1.0);
    transformed = homog.xy / homog.w;

    transformed = transformed * 0.5 + 0.5;
    if (transformed.y <= 1.0 / OutSize.y) {
        transformed.y = 1.0 / OutSize.y;
    }

    fragColor = texture(DiffuseSampler, transformed);
}