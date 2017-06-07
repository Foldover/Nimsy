#[
  Module defining an object for custom shape drawing
]#

import Nimsygl
import glut
import opengl
import glu
import glm
import Nimsyprimitives
from Nimsytypes import PShape, PVector, DrawingModes
from NimsyPVector import normal, tangent3
import Nimsyglobals

proc newPShape*(): PShape =
  return PShape(vertices: newSeq[PVector](), vlen: 0)

proc beginShape*(s: PShape) =
  s.vertices = @[]
  s.vlen = 0

proc vertex*(s: PShape, x, y, z: float) =
  s.vertices.insert(PVector(x: x, y: y, z: z), s.vlen)
  s.vlen += 1

proc endShape*(s: PShape) =
  if(true):
    discard

proc getVertexCount*(s: PShape) : int =
  return s.vlen


proc shape*(s: PShape) =
  #FIXME: When drawing other stuff on the shape, the stencil test appears to be influenced.
  var
    pointer_modelView: ptr = model_view.caddr
    pointer_projection: ptr = projection.caddr

  useStrokeColor()
  #glVertexAttrib1f(GLuint(drawingModeLocation), GLfloat(DrawingModes.POLYGON))
  glUniformMatrix4fv(modelViewLocation, GLsizei(1), GLboolean(false), pointer_modelView)
  glUniformMatrix4fv(projectionLocation, GLsizei(1), GLboolean(false), pointer_projection)
  glColorMask(GL_FALSE,GL_FALSE,GL_FALSE,GL_FALSE);
  glDepthMask(GL_FALSE);
  glEnable(GL_STENCIL_TEST);
  glStencilFunc(GL_ALWAYS,0x1,0x1);
  glStencilOp(GL_KEEP,GL_INVERT,GL_INVERT);
  glBegin(GL_TRIANGLE_FAN)
  for v in s.vertices:
    glVertex2f(v.x, v.y)
  glEnd()

  glDepthMask(GL_TRUE);
  glColorMask(GL_TRUE,GL_TRUE,GL_TRUE,GL_TRUE);
  glStencilFunc(GL_EQUAL,0x1,0x1);
  glStencilOp(GL_KEEP,GL_KEEP,GL_INVERT);
  glBegin(GL_TRIANGLE_FAN)
  for v in s.vertices:
    glVertex2f(v.x, v.y)
  glEnd()
  glDisable(GL_STENCIL_TEST);

  var normals = newSeq[PVector]()
  for n in 0..s.getVertexCount() - 1:
    if n == 0:
      let tan = tangent3(s.vertices[s.getVertexCount() - 1], s.vertices[n], s.vertices[n+1])
      normals.insert(normal(tan), 0)
    elif n == s.getVertexCount() - 1:
      let tan = tangent3(s.vertices[n-1], s.vertices[n], s.vertices[0])
      normals.insert(normal(tan), n-1)
    else:
      let tan = tangent3(s.vertices[n-1], s.vertices[n], s.vertices[n+1])
      normals.insert(normal(tan), n-1)

  glVertexAttribI1i(GLuint(drawingModeLocation), GLint(DrawingModes.LINE))
  for n in 0..s.getVertexCount() - 1:
    glBegin(GL_TRIANGLES)

    if n == s.getVertexCount() - 1:
      glVertexAttrib2f(GLuint(vertexNormalLocation), GLfloat(-normals[n].x), GLfloat(-normals[n].y))
      glVertex2f(s.vertices[n].x, s.vertices[n].y)
      glVertexAttrib2f(GLuint(vertexNormalLocation), GLfloat(normals[n].x), GLfloat(normals[n].y))
      glVertex2f(s.vertices[n].x, s.vertices[n].y)
      glVertex2f(s.vertices[0].x, s.vertices[0].y)
      glVertex2f(s.vertices[0].x, s.vertices[0].y)
      glVertexAttrib2f(GLuint(vertexNormalLocation), GLfloat(-normals[n].x), GLfloat(-normals[n].y))
      glVertex2f(s.vertices[0].x, s.vertices[0].y)
      glVertex2f(s.vertices[n].x, s.vertices[n].y)
    else:
      glVertexAttrib2f(GLuint(vertexNormalLocation), GLfloat(-normals[n].x), GLfloat(-normals[n].y))
      glVertex2f(s.vertices[n].x, s.vertices[n].y)
      glVertexAttrib2f(GLuint(vertexNormalLocation), GLfloat(normals[n].x), GLfloat(normals[n].y))
      glVertex2f(s.vertices[n].x, s.vertices[n].y)
      glVertex2f(s.vertices[n+1].x, s.vertices[n+1].y)
      glVertex2f(s.vertices[n+1].x, s.vertices[n+1].y)
      glVertexAttrib2f(GLuint(vertexNormalLocation), GLfloat(-normals[n].x), GLfloat(-normals[n].y))
      glVertex2f(s.vertices[n+1].x, s.vertices[n+1].y)
      glVertex2f(s.vertices[n].x, s.vertices[n].y)
    glEnd()
