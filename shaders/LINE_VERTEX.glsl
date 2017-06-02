attribute vec2 a_pos;
attribute vec2 a_normal;

uniform float u_linewidth;
uniform mat4 u_mv_matrix;
uniform mat4 u_p_matrix;

void main() {
    vec4 delta = vec4(a_normal * u_linewidth, 0, 0);
    vec4 pos = u_mv_matrix * vec4(a_pos, 0, 1);
    gl_Position = u_p_matrix * (pos + delta);
}
