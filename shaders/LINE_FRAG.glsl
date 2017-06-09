uniform vec4 stroke_color;
uniform vec4 fill_color;
varying float e_o_drawing_mode;

void main()
{
  if(e_o_drawing_mode == 0.0 || e_o_drawing_mode == 1.0)
  {
    gl_FragColor = stroke_color;
  }
  else
  {
    gl_FragColor = fill_color; //jag runkar pjuk
  }
}
