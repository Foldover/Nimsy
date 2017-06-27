#version 330 core

layout (location = 0) in vec2 a_pos;
layout (location = 1) in vec2 a_normal;
layout (location = 2) in vec2 a_miter;

// attribute vec2 a_pos;
// attribute vec2 a_normal;
// attribute vec2 a_miter;


uniform float u_linewidth;
uniform float u_linelen;
uniform mat4 u_mv_matrix;
uniform mat4 u_p_matrix;

attribute float e_i_drawing_mode;
varying float e_o_drawing_mode;
varying vec2 e_o_normal;

void main() {

  if(e_i_drawing_mode == 0.0)
  {
    vec4 delta = vec4(a_normal * u_linewidth, 0, 0);
    vec4 pos = u_mv_matrix * vec4(a_pos, 0, 1);
    gl_Position = u_p_matrix * (pos + delta);
    e_o_drawing_mode = e_i_drawing_mode;
    e_o_normal = abs(a_normal);
  }
  else if(e_i_drawing_mode == 1.0)
  {
    vec4 delta = vec4(a_miter * abs(u_linewidth / dot(a_miter, a_normal)), 0, 0);
    vec4 pos = u_mv_matrix * vec4(a_pos, 0, 1);
    gl_Position = u_p_matrix * (pos + delta);
    e_o_drawing_mode = e_i_drawing_mode;
  }
  else
  {
    vec4 pos = u_mv_matrix * vec4(a_pos, 0, 1);
    gl_Position = u_p_matrix * pos;
    e_o_drawing_mode = e_i_drawing_mode;
  }
}
