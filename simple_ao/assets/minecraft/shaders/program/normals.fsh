// simple ao
// https://github.com/JNNGL/vanilla-shaders

#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;

uniform vec2 InSize;

in vec2 texCoord;
flat in mat4 mvpInverse;

out vec4 fragColor;

vec3 reconstructPosition(in vec2 uv, in float z) {
  vec4 position_s = vec4(uv, z, 1.0) * 2.0 - 1.0;
  vec4 position_v = mvpInverse * position_s;
  return position_v.xyz / position_v.w;
}

vec3 getNormal(sampler2D s, vec2 uv) {
    vec2 uv0 = uv;
    float depth0 = texture(s, uv0, 0).r;
    if (depth0 == 1.0) {
        return vec3(0.0);
    }

    vec2 uv1 = uv + vec2(1, 0) / InSize;
    vec2 uv2 = uv + vec2(0, 1) / InSize;
    vec2 uv3 = uv + vec2(-1, 0) / InSize;
    vec2 uv4 = uv + vec2(0, -1) / InSize;

    float depth1 = texture(s, uv1, 0).r;
    float depth2 = texture(s, uv2, 0).r;
    float depth3 = texture(s, uv3, 0).r;
    float depth4 = texture(s, uv4, 0).r;

    float sgn = 1.0;
    vec3 p0 = reconstructPosition(uv0, depth0);
    vec3 p1, p2;
    if (abs(depth1 - depth0) < abs(depth3 - depth0)) {
        p1 = reconstructPosition(uv1, depth1);
    } else {
        p1 = reconstructPosition(uv3, depth3);
        sgn = -1.0;
    }
    if (abs(depth2 - depth0) < abs(depth4 - depth0)) {
        p2 = reconstructPosition(uv2, depth2);
        sgn *= -1.0;
    } else {
        p2 = reconstructPosition(uv4, depth4);
    }

    return sgn * normalize(cross(p2 - p0, p1 - p0));
}

void main() {
    vec3 worldNormal = getNormal(DiffuseDepthSampler, texCoord);
    fragColor = vec4(worldNormal * 0.5 + 0.5, 1.0);
}