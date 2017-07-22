uniform vec4 stroke_color;
uniform vec4 fill_color;
varying float e_o_drawing_mode;
varying vec2 e_i_normal;

void main()
{
  if(e_o_drawing_mode == 0.0 || e_o_drawing_mode == 1.0)
  {
    gl_FragColor = stroke_color;
  }
  else if(e_o_drawing_mode == 2.0)
  {
    gl_FragColor = vec4(1.0, 1.0, 0.0, 1.0);
  }
  else
  {
    gl_FragColor = stroke_color;
  }
}
