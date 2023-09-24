// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define round(a) floor(a + 0.5)
#define texture flixel_texture2D
#define iResolution openfl_TextureSize
uniform float iTime;
#define iChannel0 bitmap
uniform sampler2D iChannel1;
uniform sampler2D iChannel2;
uniform sampler2D iChannel3;

vec3 getImage (vec2 uv) {
    return texture(iChannel0, uv).rgb;
}

vec2 minLen (vec2 a, vec2 b) {
    //if (length(a) > length(b)) return a; // maximum (weird effect)
    if (length(a) < length(b)) return a;
    return b;
}

mat2 rotation (float a) {
    return mat2(cos(a),-sin(a),sin(a),cos(a));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float a = iResolution.x / iResolution.y;
    vec2 uv = (fragCoord/iResolution.xy)*2. - 1.;
    uv.x *= a;
    vec3 col = vec3(0.);
    // view direction
    vec3 d = normalize(vec3(uv,1.2));
    // rotation
    vec2 m;
        m = (iResolution.xy)*3. - 1.5;
        m = vec2(6.2832 * sin(0.05 * iTime));
    d.zy *= rotation(-m.y);
    d.xz *= rotation(m.x);
    // texture
    vec2 v1 = sign(d.z)*d.xy / d.z,
         v2 = sign(d.y)*d.xz / d.y,
         v3 = sign(d.x)*d.zy / d.x;
    m = minLen(minLen(v1,v2),v3)*0.5 + 0.5;
    col = getImage(m);
    // shading
    col*=0.7-length(m-0.5);

    fragColor = vec4(col,texture(iChannel0, uv).a);
}

void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}