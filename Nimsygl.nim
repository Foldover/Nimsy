import glut
import opengl
import glu
import glm
import math
import random
import times, os
import NimsyglCallbacks

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
  Enums needed to let the shaders now how they should operate on our vertices.
]#
type
  DrawingModes* {.pure.} = enum
    LINE, POLYGON

#[
  Variables directly available outside of the module
]#
const
  tessRes*: int = 32
  PI*: float = 3.14159265359
  TWO_PI*: float = 6.28318530718
  HALF_PI*: float = 1.57079632679
  QUARTER_PI*: float = 0.78539816339

var
  lw*: float

#[
  Variables that aren't directly available outside of the module,
  but have getter procedures.
]#
var
  #General opengl vars
  mWidth: float
  mHeight: float

  #Inputs
  mMouseX: int
  mMouseY: int

#[
  These variables are not to be messed with outside this module.
  Horrible things can happen!
]#

var
  #General opengl vars
  mainWindowID: int

  #Main loop related
  msInFrame: float = 1000.0 / 60.0
  bLOOP: bool

  #Rendering variables.
  FILL: bool = true
  STROKE: bool = true
  color_stroke: array[4, float] = [0.0, 0.0, 0.0, 1.0]
  color_fill: array[4, float] = [1.0, 1.0, 1.0, 1.0]

  #Shader matrices.
  model_view* = mat4f(1.0)
  projection*: Mat4x4[float32]

  #Shader locations.
  modelViewLocation*: GLint
  projectionLocation*: GLint
  fragmentStrokeColorLocation: GLint
  fragmentFillColorLocation: GLint
  vertexWidthLocation*: GLint
  vertexNormalLocation*: GLint
  vertexPositionLocation*: GLint
  drawingModeLocation*: GLint
  s_lineLenLocation*: GLint

  #Procedure references. These are used to run the users program.
  setupProcedure: proc()
  drawProcedure: proc() {.cdecl.}
  mouseKeyProcedure: proc(button: int, state: int, x: int, y: int)
  keyboardKeyProcedure: proc(key: char, x, y: int)

#[
  These are getter procedures available to Nimsy users.
]#

proc width*(): float {.inline.} =
  return mWidth

proc height*(): float {.inline.} =
  return mHeight

proc mouseX*(): int {.inline.} =
  return mMouseX

proc mouseY*(): int {.inline.} =
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

proc mainLoop() =
  while (glutGetWindow() != 0):
    let t1 = epochTime() / 1000.0
    glutMainLoopEvent()
    if(bLOOP):
      drawProcedure()
      glutSwapBuffers()
    let t2 = epochTime() / 1000.0
    var msDiff = msInFrame - (t2 - t1)
    if msDiff < 0.0:
      msDiff = 0.0
    sleep(int(msDiff))

proc mousePassiveMotionProc(mx: cint, my: cint) {.cdecl.} =
  mMouseX = mx
  mMouseY = my

proc mouseMotionProc(mx: cint, my: cint) {.cdecl.} =
  mMouseX = mx
  mMouseY = my

proc mouseKeyProc(button, state, x, y: cint) {.cdecl.} =
  if mouseKeyProcedure != nil:
    mouseKeyProcedure(int(button), int(state), int(x), int(y))

proc keyboardKeyProc(key: int8, x, y: cint) {.cdecl.} =
  if keyboardKeyProcedure != nil:
    keyboardKeyProcedure(char(key), int(x), int(y))
#[
  Procedures available to Nimsy users
]#

#FIXME: Sometimes the program fails to compile. Investigate this
proc start*(name: cstring = "Nimsy App") =
  glutInit()
  glutInitDisplayMode(GLUT_DOUBLE or GLUT_STENCIL or GLUT_DEPTH)
  glutInitWindowSize(int(300), int(300))
  glutInitWindowPosition(50, 50)
  mainWindowID = glutCreateWindow(name)

  #Setup opengl callbacks
  if drawProcedure != nil:
    bLOOP = true
    glutIdleFunc(TGlutVoidCallback(drawProcedure))
  else:
    bLOOP = false

  glutMotionFunc(TGlut2IntCallback(mouseMotionProc))
  glutPassiveMotionFunc(TGlut2IntCallback(mousePassiveMotionProc))
  glutMouseFunc(TGlut4IntCallback(mouseKeyProc))
  glutKeyboardFunc(TGlut1Char2IntCallback(keyboardKeyProc))

  #Nimsy aims to recreate Processing in the nim language. The setup() Processing
  #function is integral to the language's workings, and, as such, it's high
  #status is mirrored in Nimsy. A setup procedure MUST thus be provided.
  if setupProcedure != nil:
    setupProcedure()
  else:
    echo "You must define and supply a setup procedure"

  glutReshapeFunc(reshape)
  loadExtensions()

  glClearColor(0.0, 0.0, 0.0, 1.0)
  glClearDepth(1.0)
  glEnable(GL_DEPTH_TEST)
  #glEnable(GL_STENCIL_TEST)
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glDepthFunc(GL_LEQUAL)
  glShadeModel(GL_SMOOTH)
  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)
  glClearStencil( 0 );
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
  drawingModeLocation = glGetAttribLocation(activeShader.ID, "e_i_drawing_mode")
  s_lineLenLocation = glGetUniformLocation(activeShader.ID, "u_linelen")
  #TODO: prevent user from calling size() more than once

  mainLoop()

proc setDrawingMode*(dm: DrawingModes) =
  glVertexAttrib1f(GLuint(drawingModeLocation), GLfloat(dm))

#[
  Procedures available to users.
]#
proc size*(width, height: float) =
  mWidth = width
  mHeight = height

proc setSetup*(procedure: proc()) =
  setupProcedure = procedure

proc setDraw*(procedure: proc() {.cdecl.}) =
  drawProcedure = procedure

proc setMouseKeyEvent*(procedure: proc(button: int, state: int, x: int, y: int)) =
  mouseKeyProcedure = procedure

proc setKeyboardEvent*(procedure: proc(key: char, x, y: int)) =
  keyboardKeyProcedure = procedure

proc loop*() =
  if drawProcedure != nil:
    bLOOP = true
    glutIdleFunc(TGlutVoidCallback(drawProcedure))

proc noLoop*() =
  bLOOP = false

proc background*(r, g, b, a: float) =
  glClear(GL_COLOR_BUFFER_BIT or GL_STENCIL_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  glClearColor(r, g, b, a)

proc strokeWeight*(width: float) =
  vertexWidthLocation = glGetUniformLocation(activeShader.ID, "u_linewidth")
  glUniform1f(vertexWidthLocation, width)
  lw = width

proc noStroke*() =
  STROKE = false

proc stroke*(r, g, b, a: float) =
  STROKE = true
  color_stroke[0] = r
  color_stroke[1] = g
  color_stroke[2] = b
  color_stroke[3] = a

proc useStrokeColor*() =
  fragmentStrokeColorLocation = glGetUniformLocation(activeShader.ID, "stroke_color")
  glUniform4f(fragmentStrokeColorLocation, color_stroke[0], color_stroke[1], color_stroke[2], color_stroke[3])

proc noFill*() =
  FILL = false

proc fill*(r, g, b, a: float) =
  FILL = true
  color_fill[0] = r
  color_fill[1] = g
  color_fill[2] = b
  color_fill[3] = a

proc useFillColor*() =
  fragmentFillColorLocation = glGetUniformLocation(activeShader.ID, "fill_color")
  glUniform4f(fragmentFillColorLocation, color_fill[0], color_fill[1], color_fill[2], color_fill[3])
