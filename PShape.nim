#[
  Module defining an object for custom shape drawing
]#

import Nimsygl
import Nimsyprimitives
import glut
import opengl
import glu
import glm

type
  Vertex = ref object of RootObj
    x*: float
    y*: float
    z*: float

type
  PShape = ref object of RootObj
    vertices: seq[Vertex]
    vlen: int

proc newPShape*(): PShape =
  return PShape(vertices: newSeq[Vertex](), vlen: 0)

proc beginShape*(s: PShape) =
  s.vertices = @[]
  s.vlen = 0

proc vertex*(s: PShape, x, y, z: float) =
  s.vertices.insert(Vertex(x: x, y: y, z: z), s.vlen)
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

  for n in 1..s.getVertexCount()-1:
    line(s.vertices[n-1].x, s.vertices[n-1].y, s.vertices[n].x, s.vertices[n].y)
