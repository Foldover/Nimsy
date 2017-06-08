import glut
import opengl
import glu
import glm

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
  PVector* = ref object of RootObj
    x*: float
    y*: float
    z*: float

type
  PShape* = ref object of RootObj
    vertices*: seq[PVector]
    vlen*: int

type
  Shader* = ref object of RootObj
    ID* : GLuint

type
  DrawingModes* {.pure.} = enum
    LINE, PATH, POLYGON
