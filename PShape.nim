#[
  Module defining an object for custom shape drawing
]#

import glut
import opengl
import glu

type
  Vertex = ref object of RootObj
    x: float
    y: float
    z: float

type
  PShape = ref object of RootObj
    vertices: seq[Vertex]
    vlen: int

proc beginShape*(s: PShape) =
  s.vertices = @[]
  s.vlen = 0

proc vertex*(s: PShape, x, y, z: float) =
  s.vertices.insert(Vertex(x: x, y: y, z: z), s.vlen)
  s.vlen += 1
