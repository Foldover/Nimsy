import glut
import opengl
import glu
import glm
import math
import random

include PVector

#[
  Shader code is temporarily here.
  #TODO: Move shader code to separate module.
]#

type
  Shader = ref object of RootObj
    ID* : GLuint
var activeShader: Shader

proc logShader(shader: GLuint) =
   var length: GLint = 0
   glGetShaderiv(shader, GL_INFO_LOG_LENGTH, length.addr)
   var log: string = newString(length.int)
   glGetShaderInfoLog(shader, length, nil, log)
   echo "Log: ", log

proc shader(s: Shader, pathToVerShader: string, pathToFragShader: string) =
  var
    verFromFile: array[1, string] = [readFile(pathToVerShader).string]
    fragFromFile: array[1, string] = [readFile(pathToFragShader).string]
    verSource = allocCStringArray(verFromFile)
    fragSource = allocCStringArray(fragFromFile)
    resultVer: GLuint = 0
    resultFrag: GLuint = 0
    compiled: GLint = 0

  resultVer = glCreateShader(GL_VERTEX_SHADER)
  glShaderSource(resultVer, 1, verSource, nil)
  glCompileShader(resultVer)
  glGetShaderiv(resultVer, GL_COMPILE_STATUS, compiled.addr)
  if compiled == 0:
    logShader(resultVer)

  resultFrag = glCreateShader(GL_FRAGMENT_SHADER)
  glShaderSource(resultFrag, 1, fragSource, nil)
  glCompileShader(resultFrag)
  glGetShaderiv(resultFrag, GL_COMPILE_STATUS, compiled.addr)
  if compiled == 0:
    logShader(resultFrag)

  s.ID = glCreateProgram();
  glAttachShader(s.ID, resultVer)
  glAttachShader(s.ID, resultFrag)
  glLinkProgram(s.ID)

  deallocCStringArray(verSource)
  deallocCStringArray(fragSource)
  glDeleteShader(resultVer)
  glDeleteShader(resultFrag)

  glUseProgram(s.ID)

#[
  Variables that aren't directly available outside of the module,
  but have getter procedures.
]#
var
  mWidth: float
  mHeight: float
  mMouseX: float
  mMouseY: float
  windowID: int

#[
  These variables are not to be messed with outside this module.
  Horrible things can happen!
]#

var
  #Rendering variables.
  FILL: bool = true
  STROKE: bool = true

  #Shader matrices.
  model_view = mat4f(1.0)
  projection: Mat4x4[float32]

  #Shader locations.
  modelViewLocation: GLint
  projectionLocation: GLint
  fragmentStrokeColorLocation: GLint
  fragmentFillColorLocation: GLint
  vertexWidthLocation: GLint
  vertexNormalLocation: GLint
  vertexPositionLocation: GLint

  #Procedure references. These are used to run the users program.
  setupProcedure: proc()
  drawProcedure: proc() {.cdecl.}

#[
  These are getter procedures available to Nimsy users.
]#

proc width*(): float {.inline.} =
  return mWidth

proc height*(): float {.inline.} =
  return mHeight

proc mouseX*(): float {.inline.} =
  return mMouseX

proc mouseY*(): float {.inline.} =
  return mMouseY

#[
  Internal procedures.
]#

proc reshape(width: GLsizei, height: GLsizei) {.cdecl.} =
  if height == 0:
    return
  glViewport(0, 0, GLsizei(width), GLsizei(height))
  glMatrixMode(GL_PROJECTION)
  glLoadIdentity()
  #FIXME: Matrix stack is deprecated, investigate this.
  glOrtho(0, GLdouble(width), GLdouble(height), 0, -1.0, 1.0);
  projection = mat4f(ortho(0.0, float(width), float(height), 0.0, -1.0, 1.0))

#[
  Procedures available to Nimsy users
]#

#FIXME: Sometimes the program fails to compile. Investigate this
proc start*(name: cstring = "Nimsy App") =
  #Nimsy aims to recreate Processing in the nim language. The setup() Processing
  #function is integral to the language's workings, and, as such, it's high
  #status is mirrored in Nimsy. A setup procedure MUST thus be provided.

  if setupProcedure == nil:
    echo "You must define and supply a setup procedure"

  glutInit()
  glutInitDisplayMode(GLUT_DOUBLE)
  glutInitWindowSize(int(mWidth), int(mHeight))
  glutInitWindowPosition(50, 50)
  windowID = glutCreateWindow(name)
  echo windowID

  glutReshapeFunc(reshape)
  loadExtensions()

  glClearColor(0.0, 0.0, 0.0, 1.0)
  glClearDepth(1.0)
  glEnable(GL_DEPTH_TEST)
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glDepthFunc(GL_LEQUAL)
  glShadeModel(GL_SMOOTH)
  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)
  activeShader = Shader(ID: 0)

  #TODO: load default shaders from separate module
  shader(activeShader, "shaders/LINE_VERTEX.glsl", "shaders/LINE_FRAG.glsl")
  modelViewLocation = glGetUniformLocation(activeShader.ID, "u_mv_matrix")
  projectionLocation = glGetUniformLocation(activeShader.ID, "u_p_matrix")
  var
    pointer_modelView: ptr = model_view.caddr
    pointer_projection: ptr = projection.caddr
  glUniformMatrix4fv(modelViewLocation, GLsizei(1), GLboolean(false), pointer_modelView)
  glUniformMatrix4fv(projectionLocation, GLsizei(1), GLboolean(false), pointer_projection)
  vertexNormalLocation = glGetAttribLocation(activeShader.ID, "a_normal")
  vertexPositionLocation = glGetAttribLocation(activeShader.ID, "a_pos")

  #ideally start() should be called by the user. Here setupProcedure would be
  #called, and an already initialized window would be resized through size()
  #(if it is called by the user in setupProcedure). This doesn't appear to work
  #now and might be a bug in freeglut
  #TODO: prevent user from calling size() more than once

  if drawProcedure != nil:
    glutIdleFunc(TGlutVoidCallback(drawProcedure))
  glutMainLoop()

#[
  Procedures available to users.
]#
proc size*(width, height: float) =
  mWidth = width
  mHeight = height
  start()

proc setSetup*(procedure: proc()) =
  setupProcedure = procedure

proc setDraw*(procedure: proc() {.cdecl.}) =
  drawProcedure = procedure

proc loop*(procedure: TGlutVoidCallback) =
  glutIdleFunc(procedure)

#TODO: add a noLoop*() procedure

proc background*(r, g, b, a: float) =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  glClearColor(r, g, b, a)


proc strokeWeight*(width: float) =
  vertexWidthLocation = glGetUniformLocation(activeShader.ID, "u_linewidth")
  glUniform1f(vertexWidthLocation, width)

proc noStroke*() =
  STROKE = false

proc stroke*(r, g, b, a: float) =
  STROKE = true
  fragmentStrokeColorLocation = glGetUniformLocation(activeShader.ID, "stroke_color")
  glUniform4f(fragmentStrokeColorLocation, r, g, b, a)

proc noFill*() =
  FILL = false

proc fill*(r, g, b, a: float) =
  FILL = true
  fragmentFillColorLocation = glGetUniformLocation(activeShader.ID, "fill_color")
  glUniform4f(fragmentFillColorLocation, r, g, b, a)

#[
  Primitive drawing.
  #TODO: Move Primitive drawing to separate module.
]#

proc line*(x1, y1, x2, y2: float) =
  #setup pointers for the transformation matrices.
  var
    pointer_modelView: ptr = model_view.caddr
    pointer_projection: ptr = projection.caddr

  #pass transformation matrices to shader.
  glUniformMatrix4fv(modelViewLocation, GLsizei(1), GLboolean(false), pointer_modelView)
  glUniformMatrix4fv(projectionLocation, GLsizei(1), GLboolean(false), pointer_projection)

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
