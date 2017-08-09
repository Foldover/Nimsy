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
  PVector* = ref object of RootObj
    x*: float
    y*: float
    z*: float

type
  PShape* = ref object of RootObj
    vertices*: seq[PVector]
    miters*: seq[PVector]
    normals*: seq[PVector]
    vlen*: int
    children*: seq[PShape]

type
  Shader* = ref object of RootObj
    ID* : GLuint

type
  DrawingModes* {.pure.} = enum
    LINE, PATH, POLYGON, CAP

type
  Image* = ref object of RootObj
    pixels*: seq[Color]