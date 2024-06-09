#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D BloomSampler;
uniform sampler2D EmissiveSampler;

in vec2 texCoord;

out vec4 fragColor;

vec3 acesFilm(vec3 x) {
    return clamp((x * (2.51 * x + 0.03)) / (x * (2.43 * x + 0.59) + 0.14), 0., 1.);
}

void main() {
    vec4 color = texture(DiffuseSampler, texCoord);
    vec3 bloom = texture(BloomSampler, texCoord).rgb;
    color.rgb += bloom;
    fragColor = color;
}
