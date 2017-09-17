# import ../../opengl/src/opengl/glut
# import ../../opengl/src/opengl
# import ../../opengl/src/opengl/glu
import glm

import glfw
import glfw/wrapper
import ../../nim-glfw/src/glad/gl

type
  EJoint* {.pure.} = enum
    MITER, BEVEL, ROUND

type
  ECap* {.pure.} = enum
    BUTT, ROUND, SQUARE

type
  Color* = ref object of RootObj
    r*, g*, b*, a*: float

type
  NVector* = ref object
    x*: float
    y*: float
    z*: float

type
  NakedVertex* = ref object
    x*: float
    y*: float 
    z*: float

type
  VertexWithNormal* = ref object
    x*: float
    y*: float
    z*: float
    n*: NVector

type
  PShape* = ref object of RootObj
    vertices*: seq[NVector]
    miters*: seq[NVector]
    normals*: seq[NVector]
    vlen*: int
    children*: seq[PShape]

type
  DrawingModes* {.pure.} = enum
    LINE, PATH, POLYGON, CAP

type
  Image* = ref object of RootObj
    pixels*: seq[Color]