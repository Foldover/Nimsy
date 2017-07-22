import ../opengl/src/opengl/glut
import ../opengl/src/opengl
import ../opengl/src/opengl/glu
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
<<<<<<< HEAD
=======
    vbo*: GLuint
    vao*: GLuint
>>>>>>> 7d58e26ee87ea8e1a9e6c09995eee227d0242702
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
