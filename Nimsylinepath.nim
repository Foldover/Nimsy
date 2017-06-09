import Nimsytypes
import NimsyPVector
import Nimsygl
import Nimsyglobals
import opengl
import glut
import glu
import glm

proc linePathDraw*(vertices: seq[PVector]) =
  var miters = newSeq[PVector]()
  var normals = newSeq[PVector]()
  for n in 0..vertices.high-1:
    if n == 0:
      let tan = tangent3(vertices[vertices.high-1], vertices[n], vertices[n+1])
      miters.add(normal(tan))
      normals.add(normal(vertices[n], vertices[n+1]))
    elif n == vertices.high-1:
      let tan = tangent3(vertices[n-1], vertices[n], vertices[0])
      miters.add(normal(tan))
      normals.add(normal(vertices[n], vertices[n+1]))
    else:
      let tan = tangent3(vertices[n-1], vertices[n], vertices[n+1])
      miters.add(normal(tan))
      normals.add(normal(vertices[n], vertices[n+1]))

  useStrokeColor()
  glVertexAttrib1f(GLuint(drawingModeLocation), GLfloat(DrawingModes.PATH))
  glBegin(GL_TRIANGLE_STRIP)
  for n in 0..vertices.high-1:
    glVertexAttrib2f(GLuint(vertexMiterLocation), GLfloat(-miters[n].x), GLfloat(-miters[n].y))
    glVertexAttrib2f(GLuint(vertexNormalLocation), GLfloat(-normals[n].x), GLfloat(-normals[n].y))
    glVertex2f(vertices[n].x, vertices[n].y)
    glVertexAttrib2f(GLuint(vertexMiterLocation), GLfloat(miters[n].x), GLfloat(miters[n].y))
    glVertexAttrib2f(GLuint(vertexNormalLocation), GLfloat(normals[n].x), GLfloat(normals[n].y))
    glVertex2f(vertices[n].x, vertices[n].y)
  glVertexAttrib2f(GLuint(vertexMiterLocation), GLfloat(-miters[0].x), GLfloat(-miters[0].y))
  glVertexAttrib2f(GLuint(vertexNormalLocation), GLfloat(-normals[0].x), GLfloat(-normals[0].y))
  glVertex2f(vertices[0].x, vertices[0].y)
  glVertexAttrib2f(GLuint(vertexMiterLocation), GLfloat(miters[0].x), GLfloat(miters[0].y))
  glVertexAttrib2f(GLuint(vertexNormalLocation), GLfloat(normals[0].x), GLfloat(normals[0].y))
  glVertex2f(vertices[0].x, vertices[0].y)
  glEnd()
