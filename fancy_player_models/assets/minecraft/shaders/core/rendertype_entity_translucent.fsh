// Fancy Player Models
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
    it.normal2 = step(tMax, vec3(far)) * -sign(direction);
    it.position = direction * it.t + origin;
    return true;
}

const float FAR = 1024.0;

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
    temp.albedo.rgb *= temp.albedo.rgb;
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
    box(it, origin, direction, mat3(1.0), vec3(0, 6, 0), vec3(4, 6, 2) + 0.25, bodyUV, 1);
    box(it, origin, direction, leftArmT, vec3(-6.5, 5.5, 0), vec3(1.5, 6, 2) + 0.25, leftArmUV, 1);
    box(it, origin, direction, rightArmT, vec3(6.5, 5.5, 0), vec3(1.5, 6, 2) + 0.25, rightArmUV, 1);
    box(it, origin, direction, mat3(1.0), vec3(0, 16, 0), vec3(4, 4, 4) + 0.5, headUV, 1);
    box(it, origin, direction, mat3(1.0), vec3(0, 6, 0), vec3(4, 6, 2), bodyUV, 0);
    box(it, origin, direction, leftArmT, vec3(-6.5, 5.5, 0), vec3(1.5, 6, 2), leftArmUV, 0);
    box(it, origin, direction, rightArmT, vec3(6.5, 5.5, 0), vec3(1.5, 6, 2), rightArmUV, 0);
    box(it, origin, direction, mat3(1.0), vec3(0, 16, 0), vec3(4, 4, 4), headUV, 0);
    return it;
}

const vec3 blueNoise[] = vec3[](
    vec3(-0.78039217, 0.43529415, 0.43529412), vec3(-0.41176468, 0.81960785, 0.02745098), vec3(0.22352946, 0.17647064, 0.20392157), vec3(0.8509804, 0.9764706, 0.40392157), vec3(0.7019608, 0.5058824, 0.8862745), vec3(0.27843142, -0.019607842, 0.33333334), vec3(0.94509804, 0.09803927, 0.9882353), vec3(-0.99215686, 0.5921569, 0.7254902), vec3(-0.5058824, -0.49019605, 0.13333334), vec3(0.035294175, 0.69411767, 0.9019608), vec3(-0.20784312, -0.30196077, 0.7490196), vec3(-0.8117647, 0.37254906, 0.08235294), vec3(0.5137255, -0.23137254, 0.88235295), vec3(0.75686276, -0.84313726, 0.5176471), vec3(-0.5137255, -0.3490196, 0.2784314), vec3(-0.18431371, -0.12941176, 0.85882354), vec3(0.011764765, -0.4823529, 0.63529414), vec3(0.78039217, -0.0039215684, 0.9529412), vec3(-0.7019608, -0.827451, 0.74509805), vec3(-0.9372549, -0.16862744, 0.27058825), vec3(-0.47450978, -0.5294118, 0.67058825), vec3(-0.043137252, -0.8745098, 0.56078434), vec3(0.5294118, 0.8901961, 0.05882353), vec3(-0.6392157, -0.38039213, 0.39607844), vec3(0.43529415, 0.41176474, 0.21568628), vec3(0.26274514, 0.27843142, 0.8117647), vec3(0.6392157, 0.082352996, 0.36078432), vec3(-0.60784316, 0.8509804, 0.44705883), vec3(0.20000005, -0.46666664, 0.23137255), vec3(0.105882406, 0.47450984, 0.12156863), vec3(-0.3098039, 0.13725495, 0.57254905), vec3(0.9372549, 0.7019608, 0.16862746), vec3(0.47450984, -0.23921567, 0.3019608), vec3(-0.06666666, 0.60784316, 0.49019608), vec3(0.54509807, -0.654902, 0.60784316), vec3(-0.21568626, 0.39607847, 0.84705883), vec3(0.35686278, 0.26274514, 0.0), vec3(0.06666672, 0.78039217, 0.16470589), vec3(-0.31764704, -0.62352943, 0.78039217), vec3(-0.17647058, -0.77254903, 0.85490197), vec3(0.8666667, -0.082352936, 0.52156866), vec3(-0.88235295, -0.90588236, 0.5921569), vec3(-0.4352941, -0.60784316, 0.03137255), 
    vec3(0.99215686, -0.7411765, 0.6627451), vec3(-0.7176471, 0.58431375, 0.96862745), vec3(-0.12156862, 0.24705887, 0.83137256), vec3(-0.9764706, -0.6784314, 0.69803923), vec3(0.28627455, -0.79607844, 0.9254902), vec3(-0.84313726, 0.3176471, 0.043137256), vec3(-0.5921569, 0.90588236, 0.79607844), vec3(-0.34117645, 0.06666672, 0.12941177), vec3(0.9764706, -0.35686272, 0.45882353), vec3(-0.75686276, 0.6862745, 0.9647059), vec3(0.8117647, -0.27058822, 0.30980393), vec3(-0.85882354, 0.15294123, 0.6313726), vec3(0.19215691, 0.4666667, 0.42745098), vec3(0.69411767, 0.9529412, 0.27450982), vec3(-0.05098039, 0.7647059, 0.9490196), vec3(-0.27843136, 0.20784318, 0.1764706), vec3(0.30196083, -0.14509803, 0.30588236), vec3(0.45098042, 0.003921628, 0.4862745), vec3(0.81960785, 0.99215686, 0.40784314), vec3(0.5921569, -0.5529412, 0.07450981), vec3(-0.45098037, 0.7882353, 0.3529412), vec3(0.73333335, -0.96862745, 0.6745098), vec3(0.082352996, -0.42745095, 0.19607843), vec3(0.654902, 0.52156866, 0.3882353), vec3(0.16078436, -0.8901961, 0.24705882), vec3(-0.5294118, -0.73333335, 0.70980394), vec3(0.45882356, -0.035294116, 0.5058824), vec3(0.6, 0.56078434, 0.92156863), vec3(-0.69411767, -0.18431371, 0.11764706), vec3(-0.56078434, -0.5058824, 0.07058824), vec3(0.09019613, -0.3098039, 0.6862745), vec3(0.56078434, 0.64705884, 0.7921569), vec3(-0.92941177, -0.41176468, 0.90588236), vec3(-0.0039215684, -0.94509804, 0.6117647), vec3(-0.5529412, 0.4039216, 0.20784314), vec3(-0.23137254, -0.3333333, 0.77254903), vec3(0.36470592, -0.043137252, 0.5254902), vec3(0.9137255, 0.1686275, 0.8627451), vec3(-0.9137255, -0.11372548, 0.58431375), vec3(-0.16862744, 0.7490196, 0.9137255), vec3(0.32549024, 0.22352946, 0.08627451), vec3(-0.9607843, 0.92941177, 0.81960785), vec3(-0.09803921, -0.45098037, 0.35686275), 
    vec3(-0.40392154, -0.99215686, 0.21176471), vec3(0.9529412, 0.30980396, 0.7411765), vec3(0.3803922, -0.7019608, 0.4745098), vec3(-0.77254903, 0.05098045, 0.37254903), vec3(0.7490196, 0.34901965, 0.5411765), vec3(-0.3490196, -0.8039216, 0.13725491), vec3(0.8901961, 0.84313726, 0.011764706), vec3(-0.81960785, -0.19999999, 0.72156864), vec3(0.1686275, 0.654902, 0.25882354), vec3(-0.6784314, 0.49803925, 0.99215686), vec3(-0.09019607, -0.5921569, 0.32156864), vec3(0.4431373, -0.70980394, 0.42352942), vec3(-0.42745095, -0.21568626, 0.75686276), vec3(-0.6627451, -0.54509807, 0.5372549), vec3(0.77254903, 0.4431373, 0.654902), vec3(0.019607902, 0.09019613, 0.039215688), vec3(0.24705887, 0.827451, 0.5764706), vec3(-0.24705881, 0.62352943, 0.8784314), vec3(-0.1372549, -0.85882354, 0.99607843), vec3(-0.4588235, -0.06666666, 0.23529412), vec3(0.15294123, 0.9137255, 0.7647059), vec3(-0.6313726, 0.54509807, 0.32941177), vec3(-0.1607843, -0.6313726, 0.87058824), vec3(0.6627451, 0.21568632, 0.5647059), vec3(0.043137312, 0.035294175, 0.45490196), vec3(-0.36470586, -0.8666667, 0.10980392), vec3(-0.7647059, 0.9607843, 0.6509804), vec3(0.20784318, 0.28627455, 0.019607844), vec3(0.6313726, 0.6156863, 0.28627452), vec3(0.85882354, 0.011764765, 0.17254902), vec3(-0.2862745, -0.7882353, 0.9764706), vec3(0.5529412, -0.15294117, 0.41568628), vec3(-0.8509804, -0.6, 0.14117648), vec3(0.7176471, 0.18431377, 0.29803923), vec3(-0.9843137, -0.372549, 0.62352943), vec3(0.5058824, 0.7411765, 0.05490196), vec3(0.827451, -0.56078434, 0.4392157), vec3(0.41176474, 0.105882406, 0.6431373), vec3(0.254902, -0.27843136, 0.9372549), vec3(-0.4823529, -0.7490196, 0.38039216), vec3(0.52156866, -0.47450978, 0.8156863), vec3(0.79607844, 0.8117647, 0.15686275), vec3(-0.29411763, 0.36470592, 0.73333335), vec3(-0.5686275, -0.2862745, 0.95686275), 
    vec3(-0.019607842, -0.9372549, 0.47058824), vec3(-0.8039216, 0.88235295, 0.8509804), vec3(0.11372554, 0.6784314, 0.34117648), vec3(-0.49019605, -0.31764704, 0.7764706), vec3(-0.6156863, 0.38823533, 0.6901961), vec3(0.3411765, 1.0, 0.8235294), vec3(0.8745098, -0.2235294, 0.5294118), vec3(-0.035294116, 0.4901961, 0.1882353), vec3(-0.73333335, -0.92156863, 0.8392157), vec3(-0.27058822, -0.10588235, 0.101960786), vec3(-0.94509804, 0.30196083, 0.28235295), vec3(0.9843137, 0.7254902, 0.047058824), vec3(-0.8666667, 0.5686275, 0.50980395), vec3(0.3176471, -0.36470586, 0.89411765), vec3(0.5764706, -0.8352941, 0.34509805), vec3(0.92156863, -0.0745098, 0.078431375), vec3(-0.92156863, 0.48235297, 0.6), vec3(0.38823533, -0.40392154, 0.22745098), vec3(0.4901961, 0.16078436, 0.105882354), vec3(1.0, -0.88235295, 0.49411765), vec3(-0.7490196, -0.67058825, 0.25490198), vec3(0.17647064, -0.027450979, 0.007843138), vec3(-0.3333333, -0.7647059, 0.38431373), vec3(0.058823586, 0.23921573, 0.7137255), vec3(-0.5372549, -0.41960782, 0.9607843), vec3(0.62352943, 0.427451, 0.48235294), vec3(0.12156868, 0.8666667, 0.6784314), vec3(-0.058823526, -0.9843137, 0.2), vec3(-0.654902, -0.1607843, 0.6156863), vec3(-0.19999999, 0.12941182, 0.23921569), vec3(-0.4980392, 0.027451038, 0.7019608), vec3(0.70980394, 0.75686276, 0.5529412), vec3(0.23921573, -0.4980392, 0.8039216), vec3(-0.2235294, -0.64705884, 0.68235296), vec3(-0.38039213, 0.32549024, 0.8901961), vec3(-0.082352936, 0.79607844, 0.61960787), vec3(0.6862745, 0.5294118, 0.94509804), vec3(-0.19215685, 0.7176471, 0.4509804), vec3(0.58431375, -0.5137255, 0.9098039), vec3(-0.90588236, 0.6, 0.5686275), vec3(0.92941177, 0.8980392, 0.14509805), vec3(0.2941177, -0.6627451, 0.34901962), vec3(-0.38823527, -0.011764705, 0.7529412), vec3(0.7411765, -0.52156866, 0.9843137), vec3(0.4039216, 0.45098042, 0.7882353), 
    vec3(0.027451038, -0.69411767, 0.4), vec3(0.14509809, -0.5764706, 0.93333334), vec3(-0.7254902, 0.2313726, 0.18039216), vec3(-0.11372548, 0.9372549, 0.41960785), vec3(-0.62352943, 0.5764706, 0.023529412), vec3(0.8352941, -0.24705881, 0.39215687), vec3(0.07450986, -0.09803921, 0.16078432), vec3(-0.8352941, -0.4588235, 0.7372549), vec3(0.41960788, 0.11372554, 0.09019608), vec3(-0.41960782, -0.9529412, 0.21960784), vec3(-0.67058825, -0.1372549, 0.3137255), vec3(0.4666667, 0.07450986, 0.8), vec3(-0.14509803, -0.8509804, 0.0627451), vec3(-0.7882353, -0.32549018, 0.5803922), vec3(-0.5764706, 0.20000005, 0.43137255), vec3(0.88235295, 0.9843137, 0.003921569), vec3(-1.0, 0.67058825, 0.1254902), vec3(0.7882353, 0.3803922, 0.49803922), vec3(0.34901965, -0.8117647, 0.26666668), vec3(-0.44313723, -0.17647058, 0.84313726), vec3(0.64705884, -0.9607843, 0.31764707), vec3(-0.96862745, 0.058823586, 0.972549), vec3(0.30980396, -0.78039217, 0.53333336), vec3(-0.52156866, 0.2941177, 0.2901961), vec3(0.7647059, 0.94509804, 0.5882353), vec3(-0.011764705, -0.25490195, 0.8745098), vec3(0.2313726, 0.35686278, 0.6666667), vec3(0.8039216, 0.6627451, 0.5137255), vec3(-0.23921567, 0.8039216, 0.2509804), vec3(0.6784314, -0.19215685, 0.8980392), vec3(0.21568632, 0.5529412, 0.29411766), vec3(0.49803925, -0.8980392, 0.54901963), vec3(-0.35686272, -0.26274508, 0.8666667), vec3(-0.827451, 0.85882354, 0.65882355), vec3(-0.027450979, -0.38823527, 0.06666667), vec3(0.5372549, 0.14509809, 0.7607843), vec3(0.96862745, 0.41960788, 0.46666667), vec3(0.18431377, 0.8745098, 0.64705884), vec3(-0.6862745, -0.5686275, 0.050980393), vec3(-0.25490195, -0.34117645, 0.827451), vec3(0.90588236, 0.45882356, 0.36862746), vec3(-0.8745098, -0.81960785, 0.76862746), vec3(-0.58431375, -0.6156863, 0.11372549), vec3(0.09803927, -0.3960784, 0.4117647), vec3(-0.9529412, 0.254902, 0.8352941), 
    vec3(-0.46666664, -0.75686276, 0.6392157), vec3(-0.70980394, 0.3411765, 0.15294118), vec3(-0.10588235, -0.44313723, 0.7294118), vec3(-0.26274508, -0.09019607, 0.3372549), vec3(0.8980392, 0.5372549, 1.0), vec3(-0.54509807, -0.7254902, 0.59607846), vec3(-0.8901961, 0.70980394, 0.14901961), vec3(-0.30196077, -0.058823526, 0.91764706), vec3(0.003921628, 0.6392157, 0.24313726), vec3(0.48235297, -0.6862745, 0.7058824), vec3(0.6156863, 0.73333335, 0.18431373), vec3(-0.12941176, 0.19215691, 0.92941177), vec3(0.37254906, 0.8352941, 0.015686275), vec3(-0.32549018, 0.019607902, 0.47843137), vec3(0.5686275, 0.5137255, 0.98039216), vec3(0.33333337, -0.5372549, 0.19215687), vec3(0.9607843, 0.12156868, 0.03529412), vec3(0.05098045, 0.77254903, 0.9411765), vec3(0.60784316, -0.6392157, 0.4627451), vec3(0.27058828, 0.043137312, 0.22352941), vec3(0.67058825, 0.27058828, 0.7176471), vec3(0.12941182, -0.58431375, 0.3647059), vec3(0.427451, -0.29411763, 0.54509807), vec3(-0.15294117, -0.9137255, 0.80784315), vec3(-0.6, -0.4352941, 0.09803922), vec3(-0.79607844, 0.33333337, 0.5019608), vec3(-0.3960784, -0.20784312, 0.44313726), vec3(0.13725495, -0.9764706, 0.627451), vec3(0.7254902, -0.12156862, 0.2627451), vec3(-0.7411765, -0.7176471, 0.5568628), vec3(0.84313726, 0.96862745, 0.3254902), vec3(-0.0745098, -0.92941177, 0.69411767), vec3(-0.372549, -0.05098039, 0.6039216), vec3(-0.8980392, 0.6313726, 0.3764706), vec3(0.39607847, 0.92156863, 0.78431374), vec3(-0.64705884, -1.0, 0.09411765)
);

vec3 random(inout float v) {
    ivec2 coord = ivec2(mod(gl_FragCoord.xy + vec2(cos(v * 2.399963), sin(v * 2.399963)) * (v += 1.0), 16.0));
    vec3 noise = blueNoise[(coord.y * 16 + coord.x) % 256];
    return mod(noise, 1.0);
}

vec3 cosineSampleHemisphere(vec3 n, inout float seed) {
    vec2 u = random(seed).xy;
    float r = sqrt(u.x);
    float theta = 2.0 * 3.141592 * u.y;
    vec3 b = normalize(cross(n, vec3(0.0, 1.0, 1.0)));
	vec3 t = cross(b, n);
    return normalize(r * sin(theta) * b + sqrt(1.0 - u.x) * n + r * cos(theta) * t);
}

mat3 rotateY(float rad) {
    float cosT = cos(rad);
    float sinT = sin(rad);
    return mat3(cosT, 0, sinT, 0, 1, 0, -sinT, 0, cosT);
}

void sample(vec2 uv, vec3 origin, vec3 side, vec3 up, vec3 direction, inout intersection its[4], inout float hits, inout float total) {
    total += 1.0;
    origin += 10.0 * (side * uv.x - up * uv.y);
    intersection it = rayTrace(origin, direction, FAR);
    if (it.t < FAR) {
        its[int(hits)] = it;
        hits += 1.0;
    }
}

vec3 directional(vec3 n, vec3 l) {
    return vec3((dot(n, l) * 0.6 + 0.4) * 1.1);
}

void main() {
    if (renderModel > 0) {
        if (quadId != 3) discard;

        const float rotationSpeed = 0.0;
        mat3 cameraRot = rotateY(GameTime * rotationSpeed);
        vec3 direction = cameraRot * normalize(vec3(-1.0));
        vec3 side = normalize(cross(vec3(0, 1, 0), direction));
        vec3 up = cross(direction, side);

        vec2 uv = texCoord0 * 2.0 - 1.0;
        vec2 pixel = vec2(dFdx(uv.x), dFdy(uv.y));
        vec3 origin = cameraRot * vec3(1.0, 1.75, 1) * 20.0;

        intersection its[4];
        float hits = 0.0, total = 0.0;

        sample(uv + pixel * vec2(-0.33, -0.33), origin, side, up, direction, its, hits, total);
        sample(uv + pixel * vec2( 0.33, -0.33), origin, side, up, direction, its, hits, total);
        sample(uv + pixel * vec2( 0.33,  0.33), origin, side, up, direction, its, hits, total);
        sample(uv + pixel * vec2(-0.33,  0.33), origin, side, up, direction, its, hits, total);

        if (hits == 0.0) discard;

        vec4 accum = vec4(0.0);
        float wSum = 0.0;

        vec3 lightDir = cameraRot * normalize(vec3(0.0, 1.0, 0.5));

        vec3 refracted = refract(direction, its[0].normal, 1.0 / 1.5);
        float cosT = dot(-direction, its[0].normal);
        float reflectance = its[0].albedo.a < 1.0 ? (0.67 * sqrt(1.0 - cosT * cosT) > 1.0 ? 1.0 : 0.04 + 0.96 * pow(1.0 - cosT, 5.0)) : 0.0;
        vec3 reflected = reflect(direction, its[0].normal);
        intersection reflection = rayTrace(its[0].position + reflected * 0.02, reflected, FAR);
        vec4 reflectionColor = its[0].albedo * reflection.albedo;
        if (reflection.t >= FAR) {
            reflectionColor *= max(0.4, sign(dot(reflected, lightDir))) * 2.0;
        }

        float seed = 0.0;
        for (int i = 0; i < 32; i++) {
            intersection second = its[i % int(hits)];
            vec3 itNormal = second.normal;
            vec3 secondary = direction;
            vec4 sampleColor = second.albedo;
            bool termiated = false;

            vec3 directionalLight = directional(itNormal, lightDir);

            if (sampleColor.a < 1.0) {
                sampleColor = mix(sampleColor, vec4(1.0), sampleColor.a);
                secondary = normalize(refracted + 0.14 * cosineSampleHemisphere(-second.normal, seed));
                second = rayTrace(second.position + secondary * 0.02, secondary, FAR);
                sampleColor *= second.albedo;
                if (second.t >= FAR) {
                    sampleColor *= max(0.1, sign(dot(secondary, lightDir))) * 2.0;
                    termiated = true;
                }
            }
            
            if (!termiated) {
                secondary = cosineSampleHemisphere(abs(second.normal) * sign(itNormal), seed);
                second = rayTrace(second.position + secondary * 0.01, secondary, FAR);
                sampleColor *= second.albedo;
                if (second.t >= FAR) sampleColor.rgb *= directionalLight;
                else {
                    secondary = cosineSampleHemisphere(abs(second.normal) * sign(itNormal), seed);
                    second = rayTrace(second.position + secondary * 0.01, secondary, FAR);
                    if (second.t >= FAR) sampleColor.rgb *= directionalLight;
                    else sampleColor *= 0.0;
                }
            }

            sampleColor.a = 1.0;
            accum += sampleColor;
            wSum += 1.0;
        }

        accum /= wSum;
        accum = mix(accum, reflectionColor, reflectance);

        fragColor = sqrt(accum);
        fragColor.a = hits / total;
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
