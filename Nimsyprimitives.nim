import Nimsytypes
import Nimsyglobals
import Nimsygl
import Nimsylinepath
import NimsyPVector
import math
import glm
import glut
import opengl
import glu

proc circle*(cx, cy, r: float) =
  let inc: float = TWO_PI / float(TESS_RES)
  var
    phase: float = TWO_PI
    v: array[TESS_RES, tuple[x: float, y: float]]

  var
    pointer_modelView: ptr = modelView.caddr
    pointer_projection: ptr = projection.caddr

  glUniformMatrix4fv(modelViewLocation, GLsizei(1), GLboolean(false), pointer_modelView)
  glUniformMatrix4fv(projectionLocation, GLsizei(1), GLboolean(false), pointer_projection)
  glVertexAttrib1f(GLuint(drawingModeLocation), GLfloat(DrawingModes.POLYGON))
  useStrokeColor()
  for n in 0..TESS_RES-1:
    let
      x = cx + r*cos(phase)
      y = cy + r*sin(phase)
    phase -= inc
    v[n][0] = x
    v[n][1] = y
  glBegin(GL_POLYGON)
  for n in 0..TESS_RES-1:
    glVertex2f(v[n][0], v[n][1])
  glEnd()

proc arc*(cx, cy, r, sa, ea: float) =
  let inc: float = abs(ea-sa) / float(TESS_RES)
  var
    phase: float = sa
    v: array[TESS_RES+1, PVector]

  var
    pointer_modelView: ptr = modelView.caddr
    pointer_projection: ptr = projection.caddr

  glUniformMatrix4fv(modelViewLocation, GLsizei(1), GLboolean(false), pointer_modelView)
  glUniformMatrix4fv(projectionLocation, GLsizei(1), GLboolean(false), pointer_projection)
  glVertexAttrib1f(GLuint(drawingModeLocation), GLfloat(DrawingModes.POLYGON))
  useFillColor()
  for n in 0..TESS_RES:
    let
      x = cx + r*cos(phase)
      y = cy + r*sin(phase)
    phase += inc
    v[n] = newPVector(x, y, 0)
  glBegin(GL_TRIANGLE_FAN)
  glVertex2f(cx, cy)
  for n in 0..TESS_RES:
    glVertex2f(v[n].x, v[n].y)
  glEnd()

proc roundButtArc*(cx, cy, r, sa, ea: float) =
  let inc: float = abs(ea-sa) / float(TESS_RES)
  var
    phase: float = sa
    v: array[TESS_RES+1, PVector]

  var
    pointer_modelView: ptr = modelView.caddr
    pointer_projection: ptr = projection.caddr

  glUniformMatrix4fv(modelViewLocation, GLsizei(1), GLboolean(false), pointer_modelView)
  glUniformMatrix4fv(projectionLocation, GLsizei(1), GLboolean(false), pointer_projection)
  glVertexAttrib1f(GLuint(drawingModeLocation), GLfloat(DrawingModes.CAP))
  useStrokeColor()
  for n in 0..TESS_RES:
    let
      x = cx + r*cos(phase)
      y = cy + r*sin(phase)
    phase += inc
    v[n] = newPVector(x, y, 0)
  glBegin(GL_TRIANGLE_FAN)
  glVertex2f(cx, cy)
  for n in 0..TESS_RES:
    glVertex2f(v[n].x, v[n].y)
  glEnd()

proc rect*(x, y, w, h: float) =
  var
    pointer_modelView: ptr = modelView.caddr
    pointer_projection: ptr = projection.caddr

  #pass transformation matrices to shader.
  glUniformMatrix4fv(modelViewLocation, GLsizei(1), GLboolean(false), pointer_modelView)
  glUniformMatrix4fv(projectionLocation, GLsizei(1), GLboolean(false), pointer_projection)

  if isFill:
    glVertexAttrib1f(GLuint(drawingModeLocation), GLfloat(DrawingModes.POLYGON))
    useFillColor()
    glBegin(GL_TRIANGLE_STRIP)
    glVertex2f(x + w, y)
    glVertex2f(x, y)
    glVertex2f(x + w, y + h)
    glVertex2f(x, y + h)
    # glVertex2f(x + w, y + h)
    # glVertex2f(x + w, y)
    # glVertex2f(x, y)
    glEnd()

  if isStroke:
    linePathDraw(@[newPVector(x, y, 0), newPVector(x + w, y, 0), newPVector(x + w, y + h, 0), newPVector(x, y + h, 0), newPVector(x, y, 0)])


proc line*(x1, y1, x2, y2: float) =
  #TODO: Should be globally accessible: setup pointers for the transformation matrices.
  var
    pointer_modelView: ptr = modelView.caddr
    pointer_projection: ptr = projection.caddr

  #pass transformation matrices to shader.
  glUniformMatrix4fv(modelViewLocation, GLsizei(1), GLboolean(false), pointer_modelView)
  glUniformMatrix4fv(projectionLocation, GLsizei(1), GLboolean(false), pointer_projection)

  #pass parameters
  glVertexAttrib1f(GLuint(drawingModeLocation), GLfloat(DrawingModes.LINE))
  let len = sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1))
  glUniform1f(lineLengthLocation, len)

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
  roundButtArc(x1, y1, lineWidth, a, a+PI)
  roundButtArc(x2, y2, lineWidth, a+PI, a)
