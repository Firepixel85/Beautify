shader_type canvas_item;

uniform float blur_radius : hint_range(0.0, 10.0); // Control the blur radius

void fragment() {
    vec2 tex_size = vec2(textureSize(TEXTURE, 0));
    vec2 texel = vec2(0.0, 1.0 / tex_size.y);

    vec4 color = texture(TEXTURE, UV) * 0.4; // Center weight
    color += texture(TEXTURE, UV + texel * blur_radius) * 0.3;
    color += texture(TEXTURE, UV - texel * blur_radius) * 0.3;

    COLOR = color;
}
