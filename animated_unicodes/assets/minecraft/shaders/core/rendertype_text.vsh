#version 150

#moj_import <fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;

uniform sampler2D Sampler0;
uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat3 IViewRotMat;
uniform int FogShape;
uniform float GameTime;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec2 texCoord1;
out float isAnimated;

bool validateProperty2(vec4 data) {
    return data.zw == vec2(75.0 / 255.0, 1.0 / 255.0);
}

bool decodeProperties0(in vec2 uv, out ivec2 dim, out int frame_dim,
                       out int nframes, out float time, out ivec2 size) {
    vec4 magic = texture(Sampler0, uv);
    if (magic != vec4(149.0 / 255.0, 213.0 / 255.0, 75.0 / 255.0, 1.0 / 255.0)) {
        return false;
    }

    ivec2 texsize = textureSize(Sampler0, 0);
    float x1 = 1.0 / float(texsize.x);

    size = texsize;

    vec4 dim_in = texture(Sampler0, uv + vec2(x1, 0.0));
    if (!validateProperty2(dim_in)) {
        return false;
    }

    dim = ivec2(round(dim_in.xy * 255.0));

    vec4 frame_data = texture(Sampler0, uv + vec2(x1 * 2.0, 0.0));
    if (!validateProperty2(frame_data)) {
        return false;
    }

    frame_dim = int(round(frame_data.x * 255.0));
    nframes = int(round(frame_data.y * 255.0));

    vec4 packed_time = texture(Sampler0, uv + vec2(x1 * 3.0, 0.0));
    if (!validateProperty2(packed_time)) {
        return false;
    }

    time = packed_time.x * 255.0 + packed_time.y;
    return true;
}

bool decodeProperties(in vec2 uv, out ivec2 dim, out int frame_dim, out int nframes,
                      out float time, out ivec2 size, out vec2 origin) {
    if (decodeProperties0(uv, dim, frame_dim, nframes, time, size)) {
        origin = uv;
        return true;
    }

    vec4 uv_offset = texture(Sampler0, uv);
    if (!validateProperty2(uv_offset)) {
        return false;
    }

    vec2 pointing = uv - uv_offset.xy * (vec2(255.0) / vec2(textureSize(Sampler0, 0)));
    origin = pointing;

    return decodeProperties0(pointing, dim, frame_dim, nframes, time, size);
}

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    isAnimated = 0.0;
    vec2 uv = UV0;

    ivec2 dim;
    int frame_dim;
    int nframes;
    float loop_time;
    ivec2 size;
    vec2 origin;
    if (decodeProperties(UV0, dim, frame_dim, nframes, loop_time, size, origin)) {
        isAnimated = 1.0;
        float time = fract(GameTime * 1200.0 / loop_time);
        int frame = int(time * nframes);
        int uframes = (dim.x - 2) / frame_dim;
        int u = frame % uframes;
        int v = frame / uframes;
        uv = vec2((uv.x - origin.x) / float(dim.x) * float(frame_dim) + origin.x, (uv.y - origin.y) / float(dim.y) * float(frame_dim) + origin.y);
        uv += (vec2(u, v) * vec2(frame_dim) + 1.0) / vec2(size);
    }

    vertexDistance = fog_distance(ModelViewMat, IViewRotMat * Position, FogShape);
    vertexColor = Color * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0;
    texCoord1 = uv;
}
