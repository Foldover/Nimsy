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

proc arc*(cx, cy, r, sa, ea: float) =
  let inc: float = abs(ea-sa) / float(tessRes)
  var
    phase: float = sa
    v: array[tessRes+1, tuple[x: float, y: float]]

  var
    pointer_modelView: ptr = model_view.caddr
    pointer_projection: ptr = projection.caddr

  glUniformMatrix4fv(modelViewLocation, GLsizei(1), GLboolean(false), pointer_modelView)
  glUniformMatrix4fv(projectionLocation, GLsizei(1), GLboolean(false), pointer_projection)
  #glVertexAttribI1i(GLuint(drawingModeLocation), GLint(DrawingModes.POLYGON))
  useStrokeColor()
  for n in 0..tessRes:
    let
      x = cx + r*cos(phase)
      y = cy + r*sin(phase)
    phase += inc
    v[n][0] = x
    v[n][1] = y
  glBegin(GL_TRIANGLE_FAN)
  glVertex2f(cx, cy)
  for n in 0..tessRes:
    glVertex2f(v[n][0], v[n][1])
  glEnd()

proc line*(x1, y1, x2, y2: float) =
  #TODO: Should be globally accessible: setup pointers for the transformation matrices.
  var
    pointer_modelView: ptr = model_view.caddr
    pointer_projection: ptr = projection.caddr

  #pass transformation matrices to shader.
  glUniformMatrix4fv(modelViewLocation, GLsizei(1), GLboolean(false), pointer_modelView)
  glUniformMatrix4fv(projectionLocation, GLsizei(1), GLboolean(false), pointer_projection)

  #pass parameters
  glVertexAttribI1i(GLuint(drawingModeLocation), GLint(DrawingModes.LINE))
  let len = sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1))
  glUniform1f(s_lineLenLocation, len)

  useStrokeColor()

  #calculate normals. This is needed to draw variable-width lines.
  var norm1 = vec2(x2 - x1, y2 - y1)
  norm1 = normalize(norm1)
  var norm2 = norm1
  let ntx = norm1.x
  norm1.x = -norm1.y
  norm1.y = ntx
  norm2.x = norm2.y
  norm2.y = -ntx
  glBegin(GL_TRIANGLES)
  glVertexAttrib2f(GLuint(vertexNormalLocation), GLfloat(norm1.x), GLfloat(norm1.y))
  glVertex2f(x1, y1)
  glVertex2f(x2, y2)
  glVertexAttrib2f(GLuint(vertexNormalLocation), GLfloat(norm2.x), GLfloat(norm2.y))
  glVertex2f(x1, y1)
  glVertex2f(x2, y2)
  glVertex2f(x1, y1)
  glVertexAttrib2f(GLuint(vertexNormalLocation), GLfloat(norm1.x), GLfloat(norm1.y))
  glVertex2f(x2, y2)
  glEnd()

  let a = arctan2(norm1.y, norm1.x)
  glVertexAttrib1f(GLuint(drawingModeLocation), GLfloat(DrawingModes.POLYGON))
  arc(x1, y1, lw, a, a+PI)
  arc(x2, y2, lw, a+PI, a)
