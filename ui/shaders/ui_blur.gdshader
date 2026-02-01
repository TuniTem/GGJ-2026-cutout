shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture;

uniform float radius : hint_range(0.0, 12.0) = 6.0;
uniform float strength : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec2 uv = SCREEN_UV;

    vec2 tex_size = vec2(textureSize(screen_tex, 0));
    vec2 px = radius / tex_size;

    vec4 sum = vec4(0.0);
    float w = 0.0;

    float weights[5] = float[](0.227027, 0.1945946, 0.1216216, 0.054054, 0.016216);

    sum += texture(screen_tex, uv) * weights[0];
    w += weights[0];

    for (int i = 1; i < 5; i++) {
        vec2 offx = vec2(px.x * float(i), 0.0);
        vec2 offy = vec2(0.0, px.y * float(i));

        sum += texture(screen_tex, uv + offx) * weights[i];
        sum += texture(screen_tex, uv - offx) * weights[i];
        sum += texture(screen_tex, uv + offy) * weights[i];
        sum += texture(screen_tex, uv - offy) * weights[i];

        w += 4.0 * weights[i];
    }

    vec4 blurred = sum / w;
    vec4 original = texture(screen_tex, uv);

    COLOR = mix(original, blurred, strength);
}
