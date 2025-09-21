layout(location = 0) in vec2 a_position;

layout(location = 1) in vec2 i_position;
layout(location = 2) in vec2 i_scale;
layout(location = 3) in vec4 i_tex_rect;
layout(location = 4) in vec4 i_color;
layout(location = 5) in vec2 i_position_prev;
layout(location = 6) in vec2 i_scale_prev;

layout(location = 0) out vec2 v_tex_coords;
layout(location = 1) out vec4 v_color;
layout(location = 2) out vec4 v_rect;
layout(location = 3) out vec4 v_rect_prev;
layout(location = 4) out vec2 v_position;

uniform vec2 u_inv_resolution;

void main() {
    v_rect      = vec4(i_position,      i_position      + i_scale);
    v_rect_prev = vec4(i_position_prev, i_position_prev + i_scale_prev);

    vec4 rect_union = vec4(min(v_rect.xy, v_rect_prev.xy), max(v_rect.zw, v_rect_prev.zw));

    v_position   = rect_union.xy * (1 - a_position) + rect_union.zw * a_position;
    v_tex_coords = a_position;
    v_color      = i_color;
    gl_Position  = vec4(vec2(1, -1) * (u_inv_resolution * v_position * 2 - 1), 0, 1);
}
