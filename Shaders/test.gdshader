// ditherShader.gdshader

shader_type canvas_item;
#include "res://dither.gdshaderinc"
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

void vertex() {
    world_to_clip = SCREEN_MATRIX * CANVAS_MATRIX;
    world_vertex = (MODEL_MATRIX * vec4(VERTEX, 0., 1.)).xy;
}

void fragment() {
    vec2 s_vertex = SCREEN_UV / SCREEN_PIXEL_SIZE;
    vec2 s_uv = SCREEN_UV;

    if (quantize_enabled) {
        quantize(s_vertex, s_uv);
    }

    // Get pixelated Texture
    vec4 c = texture(SCREEN_TEXTURE, s_uv);
    COLOR.rgb = dither(c, s_vertex);
}
