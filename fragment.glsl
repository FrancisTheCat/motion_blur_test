layout(location = 0) in vec2 v_tex_coords;
layout(location = 1) in vec4 v_rect;
layout(location = 2) in vec4 v_rect_prev;
layout(location = 3) in vec2 v_position;

layout(location = 0) out vec4 f_color;

uniform sampler2D u_texture;
uniform int       u_samples = 8;

bool point_in_rect(vec4 rect, vec2 point, out vec2 tex_coords) {
    if (point.x < rect.x || point.x > rect.z) {
        return false;
    }
    if (point.y < rect.y || point.y > rect.w) {
        return false;
    }
    tex_coords = (point - rect.xy) / (rect.zw - rect.xy);
    return true;
}

void main() {
    vec4  accumulated = vec4(0);
    float n_hits = 0;
    for (int i = 0; i < u_samples; i += 1) {
        float t = float(i) / float(u_samples);
        vec2  tex_coords;
        if (point_in_rect(mix(v_rect, v_rect_prev, t), v_position, tex_coords)) {
            vec4 v = texture(u_texture, tex_coords);
            // almost correct gamma correction
            accumulated += vec4((v.rgb * v.rgb), v.a);
            n_hits      += 1;
        }
    }

    if (accumulated.a == 0) {
        f_color = vec4(0);
    } else {
        f_color = vec4(sqrt(accumulated.rgb / float(n_hits)), accumulated.a / float(u_samples));
    }
}
