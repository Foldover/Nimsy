import Nimsygl
import math
import glm
import glut
import opengl
import glu

proc circle*(cx, cy, r: float) =
  let inc: float = TWO_PI / float(tessRes)
  var
    phase: float = TWO_PI
    v: array[tessRes, tuple[x: float, y: float]]

  var
    pointer_modelView: ptr = model_view.caddr
    pointer_projection: ptr = projection.caddr

  glUniformMatrix4fv(modelViewLocation, GLsizei(1), GLboolean(false), pointer_modelView)
  glUniformMatrix4fv(projectionLocation, GLsizei(1), GLboolean(false), pointer_projection)
  #glVertexAttribI1i(GLuint(drawingModeLocation), GLint(DrawingModes.POLYGON))
  useStrokeColor()
  for n in 0..tessRes-1:
    let
      x = cx + r*cos(phase)
      y = cy + r*sin(phase)
    phase -= inc
    v[n][0] = x
    v[n][1] = y
  glBegin(GL_POLYGON)
  for n in 0..tessRes-1:
    glVertex2f(v[n][0], v[n][1])
  glEnd()
