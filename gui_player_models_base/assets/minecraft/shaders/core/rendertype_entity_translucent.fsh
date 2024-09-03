// GUI Player Models Base
// https://github.com/JNNGL/vanilla-shaders

#version 330

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;
uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;
uniform float GameTime;

in float vertexDistance;
in vec4 vertexColor;
in vec4 lightMapColor;
in vec4 overlayColor;
in vec2 texCoord0;
in vec3 normal;
flat in int quadId;
flat in int renderModel;

out vec4 fragColor;

const float FAR = 1024.0;

struct intersection {
    float t, t2;
    bool inside;
    vec3 position;
    vec3 normal, normal2;
    vec2 uv;
    vec4 albedo;
};

void boxTexCoord(inout intersection it, vec3 origin, vec3 size, const vec4 uvs[12], int offset) {
    vec3 t = it.position - origin;
    vec3 mask = abs(it.normal);
    vec2 uv = mask.x * t.zy + mask.y * t.xz + mask.z * t.xy;
    vec2 dim = mask.x * size.zy + mask.y * size.xz + mask.z * size.xy;
    uv = mod(uv / (dim * 2.0) + 0.5, 1.0);

    vec4 uvmap;
    vec3 normal = it.normal * (it.t == it.t2 ? -1 : 1);
    if (normal.x == 1) uvmap = uvs[offset];
    else if (normal.x == -1) uvmap = uvs[offset + 1];
    else if (normal.y == 1) uvmap = uvs[offset + 2];
    else if (normal.y == -1) uvmap = uvs[offset + 3];
    else if (normal.z == 1) uvmap = uvs[offset + 4];
    else if (normal.z == -1) uvmap = uvs[offset + 5];

    it.uv = floor(mix(uvmap.xy, uvmap.zw, uv));
}

bool boxIntersect(inout intersection it, vec3 origin, vec3 direction, vec3 position, vec3 size) {
    vec3 invDir = 1.0 / direction;
    vec3 ext = abs(invDir) * size;
    vec3 tMin = -invDir * (origin - position) - ext;
    vec3 tMax = tMin + ext * 2;
    float near = max(max(tMin.x, tMin.y), tMin.z);
    float far = min(min(tMax.x, tMax.y), tMax.z);
    if (near > far || far < 0.0 || near > it.t) return false;
    it.inside = near <= 0.0;
    it.t = it.inside ? far : near;
    it.t2 = far;
    it.normal = (it.inside ? step(tMax, vec3(far)) : step(vec3(near), tMin)) * -sign(direction);
    it.normal2 = step(tMax, vec3(far));
    it.position = direction * it.t + origin;
    return true;
}

void box(inout intersection it, vec3 origin, vec3 direction, mat3 transform, vec3 position, vec3 size, const vec4 uvs[12], int layer) {
    intersection temp = it;
    vec3 originT = transform * origin;
    vec3 directionT = transform * direction;
    if (!boxIntersect(temp, originT, directionT, position, size)) return;
    boxTexCoord(temp, position, size, uvs, layer * 6);
    temp.albedo = texelFetch(Sampler0, ivec2(temp.uv), 0);
    if (temp.albedo.a < 0.1) {
        if (temp.t == temp.t2 || temp.t2 >= FAR) return;
        temp.t = temp.t2;
        temp.normal = temp.normal2;
        temp.position = directionT * temp.t + originT;
        boxTexCoord(temp, position, size, uvs, layer * 6);
        temp.albedo = texelFetch(Sampler0, ivec2(temp.uv), 0);
        if (temp.albedo.a < 0.1) return;
    }
    temp.normal = temp.normal * transform;
    temp.position = direction * temp.t + origin;
    it = temp;
}

intersection rayTrace(vec3 origin, vec3 direction, float far) {
    const vec4 headUV[12] = vec4[](
        vec4(0, 16, 8, 8),
        vec4(24, 16, 16, 8),
        vec4(16, 0, 8, 8),
        vec4(24, 0, 16, 8),
        vec4(16, 16, 8, 8),
        vec4(24, 16, 32, 8),

        vec4(24, 16, 16, 8) + vec4(32, 0, 32, 0),
        vec4(0, 16, 8, 8) + vec4(32, 0, 32, 0),
        vec4(16, 0, 8, 8) + vec4(32, 0, 32, 0),
        vec4(24, 0, 16, 8) + vec4(32, 0, 32, 0),
        vec4(16, 16, 8, 8) + vec4(32, 0, 32, 0),
        vec4(24, 16, 32, 8) + vec4(32, 0, 32, 0)
    );

    const vec4 bodyUV[12] = vec4[](
        vec4(28, 32, 32, 20),
        vec4(20, 32, 16, 20),
        vec4(28, 16, 20, 20),
        vec4(36, 16, 28, 20),
        vec4(28, 32, 20, 20),
        vec4(32, 32, 40, 20),

        vec4(28, 32, 32, 20) + vec4(0, 16, 0, 16),
        vec4(20, 32, 16, 20) + vec4(0, 16, 0, 16),
        vec4(28, 16, 20, 20) + vec4(0, 16, 0, 16),
        vec4(36, 16, 28, 20) + vec4(0, 16, 0, 16),
        vec4(28, 32, 20, 20) + vec4(0, 16, 0, 16),
        vec4(32, 32, 40, 20) + vec4(0, 16, 0, 16)
    );

    const vec4 rightArmUV[12] = vec4[](
        vec4(40, 32, 44, 20),
        vec4(51, 32, 47, 20),
        vec4(47, 16, 44, 20),
        vec4(50, 16, 47, 20),
        vec4(47, 32, 44, 20),
        vec4(51, 32, 54, 20),

        vec4(40, 32, 44, 20) + vec4(0, 16, 0, 16),
        vec4(51, 32, 47, 20) + vec4(0, 16, 0, 16),
        vec4(47, 16, 44, 20) + vec4(0, 16, 0, 16),
        vec4(50, 16, 47, 20) + vec4(0, 16, 0, 16),
        vec4(47, 32, 44, 20) + vec4(0, 16, 0, 16),
        vec4(51, 32, 54, 20) + vec4(0, 16, 0, 16)
    );

    const vec4 leftArmUV[12] = vec4[](
        vec4(32, 64, 36, 52),
        vec4(43, 64, 39, 52),
        vec4(39, 48, 36, 52),
        vec4(42, 48, 39, 52),
        vec4(39, 64, 36, 52),
        vec4(43, 64, 46, 52),

        vec4(32, 64, 36, 52) + vec4(16, 0, 16, 0),
        vec4(43, 64, 39, 52) + vec4(16, 0, 16, 0),
        vec4(39, 48, 36, 52) + vec4(16, 0, 16, 0),
        vec4(42, 48, 39, 52) + vec4(16, 0, 16, 0),
        vec4(39, 64, 36, 52) + vec4(16, 0, 16, 0),
        vec4(43, 64, 46, 52) + vec4(16, 0, 16, 0)
    );

    /*
    const vec4 rightLegUV[12] = vec4[](
        vec4(0, 32, 4, 20),
        vec4(12, 32, 8, 20),
        vec4(8, 16, 4, 20),
        vec4(12, 16, 8, 20),
        vec4(8, 32, 4, 20),
        vec4(12, 32, 16, 20),

        vec4(0, 32, 4, 20) + vec4(0, 16, 0, 16),
        vec4(12, 32, 8, 20) + vec4(0, 16, 0, 16),
        vec4(8, 16, 4, 20 + vec4(0, 16, 0, 16)),
        vec4(12, 16, 8, 20) + vec4(0, 16, 0, 16),
        vec4(8, 32, 4, 20) + vec4(0, 16, 0, 16),
        vec4(12, 32, 16, 20) + vec4(0, 16, 0, 16)
    );

    const vec4 leftLegUV[12] = vec4[](
        vec4(16, 64, 20, 52),
        vec4(28, 64, 24, 52),
        vec4(24, 48, 20, 52),
        vec4(28, 48, 24, 52),
        vec4(24, 64, 20, 52),
        vec4(28, 64, 32, 52),

        vec4(16, 64, 20, 52) + vec4(-16, 0, -16, 0),
        vec4(28, 64, 24, 52) + vec4(-16, 0, -16, 0),
        vec4(24, 48, 20, 52) + vec4(-16, 0, -16, 0),
        vec4(28, 48, 24, 52) + vec4(-16, 0, -16, 0),
        vec4(24, 64, 20, 52) + vec4(-16, 0, -16, 0),
        vec4(28, 64, 32, 52) + vec4(-16, 0, -16, 0)
    );
    */

    const mat3 rightArmT = mat3(cos(radians(5.0)), -sin(radians(5.0)), 0, sin(radians(5.0)), cos(radians(5.0)), 0, 0, 0, 1);
    const mat3 leftArmT = mat3(cos(radians(-5.0)), -sin(radians(-5.0)), 0, sin(radians(-5.0)), cos(radians(-5.0)), 0, 0, 0, 1);

    intersection it = intersection(far, far, false, vec3(0.0), vec3(0.0), vec3(0.0), vec2(0.0), vec4(1.0, 1.0, 1.0, 0.0));

    // overlay
    box(it, origin, direction, mat3(1.0), vec3(0, 6, 0), vec3(4, 6, 2) + 0.25, bodyUV, 1);
    box(it, origin, direction, leftArmT, vec3(-6.5, 5.5, 0), vec3(1.5, 6, 2) + 0.25, leftArmUV, 1);
    box(it, origin, direction, rightArmT, vec3(6.5, 5.5, 0), vec3(1.5, 6, 2) + 0.25, rightArmUV, 1);
    box(it, origin, direction, mat3(1.0), vec3(0, 16, 0), vec3(4, 4, 4) + 0.5, headUV, 1);

    // base layer
    box(it, origin, direction, mat3(1.0), vec3(0, 6, 0), vec3(4, 6, 2), bodyUV, 0);
    box(it, origin, direction, leftArmT, vec3(-6.5, 5.5, 0), vec3(1.5, 6, 2), leftArmUV, 0);
    box(it, origin, direction, rightArmT, vec3(6.5, 5.5, 0), vec3(1.5, 6, 2), rightArmUV, 0);
    box(it, origin, direction, mat3(1.0), vec3(0, 16, 0), vec3(4, 4, 4), headUV, 0);
    
    return it;
}

mat3 rotateY(float rad) {
    float cosT = cos(rad);
    float sinT = sin(rad);
    return mat3(cosT, 0, sinT, 0, 1, 0, -sinT, 0, cosT);
}

vec3 blend(vec3 dst, vec4 src) {
    return (dst * (1.0 - src.a)) + src.rgb * src.a;
}

void main() {
    if (renderModel > 0) {
        if (quadId != 3) discard;

        const float rotationSpeed = 0.0;
        mat3 cameraRot = rotateY(GameTime * rotationSpeed);
        vec3 direction = cameraRot * normalize(vec3(-1.0));
        vec3 side = normalize(cross(vec3(0, 1, 0), direction));
        vec3 up = cross(direction, side);

        vec2 clip = texCoord0 * 2.0 - 1.0;
        vec3 origin = cameraRot * vec3(1.0, 1.75, 1.0) * 20.0 + 10.0 * (side * clip.x - up * clip.y);

        intersection it = rayTrace(origin, direction, FAR);
        if (it.t >= FAR) {
            discard;
        }

        vec3 lightDir = cameraRot * normalize(vec3(0.0, 1.0, 0.5));

        float directional = dot(it.normal, lightDir) * 0.4 + 0.6;
        fragColor = vec4(it.albedo.rgb * directional, it.albedo.a);

        for (int i = 0; i < 4 && fragColor.a < 1.0; i++) {
            it = rayTrace(it.position + direction * 0.01, direction, FAR);
            if (it.t < FAR) {
                directional = dot(it.normal, lightDir) * 0.4 + 0.6;
                fragColor = vec4(blend(it.albedo.rgb * directional, fragColor), it.albedo.a);
            }
        }
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
