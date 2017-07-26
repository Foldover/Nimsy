import ../opengl/src/opengl/glut
import ../opengl/src/opengl
import ../opengl/src/opengl/glu
import glm
import math
import random
import times, os
import Nimsytypes
import Nimsyglobals

#[
  Shader code is temporarily here.
  #TODO: Move shader code to separate module.
]#

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
  These variables are not to be messed with outside this module.
  Horrible things can happen!
]#

var
  #Procedure references. These are used to run the users program.
  setupProcedure: proc()
  drawProcedure: proc() {.cdecl.}
  mouseDragProcedure: proc(x, y: float)
  mouseKeyProcedure: proc(button: int, state: int, x: float, y: float)
  keyboardKeyProcedure: proc(key: char, x, y: int)

#[
  These are getter procedures available to Nimsy users.
]#

proc width*(): float {.inline.} =
  return float(mWidth)

proc height*(): float {.inline.} =
  return float(mHeight)

proc mouseX*(): float {.inline.} =
  return float(mMouseX)

proc mouseY*(): float {.inline.} =
  return float(mMouseY)

#[
  Internal procedures.
]#

proc reshape(width: GLsizei, height: GLsizei) {.cdecl.} =
  if height == 0:
    return
  glViewport(0, 0, GLsizei(width), GLsizei(height))
  #glMatrixMode(GL_PROJECTION)
  #glLoadIdentity()
  #FIXME: Matrix stack is deprecated, investigate this.
  #glOrtho(0, GLdouble(width), GLdouble(height), 0, -1.0, 1.0);
  projection = mat4f(ortho(0.0, float(width), float(height), 0.0, -1.0, 1.0))

proc mainLoop() =
  while (glutGetWindow() != 0):
    let t1 = epochTime() / 1000.0
    glutMainLoopEvent()
    if(isLoop):
      glClear(GL_STENCIL_BUFFER_BIT)
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
  if mouseDragProcedure != nil:
    mouseDragProcedure(float(mx), float(my))

proc mouseKeyProc(button, state, x, y: cint) {.cdecl.} =
  if mouseKeyProcedure != nil:
    mouseKeyProcedure(int(button), int(state), float(x), float(y))

proc keyboardKeyProc(key: int8, x, y: cint) {.cdecl.} =
  if keyboardKeyProcedure != nil:
    keyboardKeyProcedure(char(key), int(x), int(y))
#[
  Procedures available to Nimsy users
]#

#FIXME: Sometimes the program fails to run. See "echo w"
#TODO: initialization REALLY needs to be prettier. How the hell do you resize a gl window?

#For Windows 10. Freeglut complains if a display function callback is not provided.
#On Ubuntu 16.04 this problem doesn't appear. Go figure.
proc dummyDisplayFunc() {.cdecl.} =
  echo "Running dummy display function"

proc start*(w, h: int, name: cstring = "Nimsy App") =
  mWidth = w
  mHeight = h  
  #FIXME: without "echo w" the program can't start. Go figure.
  echo w
  sleep(1000)
  
  glutInit()
  glutInitDisplayMode(GLUT_DOUBLE or GLUT_STENCIL or GLUT_DEPTH or GLUT_MULTISAMPLE)
  glutInitWindowSize(mWidth, mHeight)
  glutInitWindowPosition(50, 50)
  mainWindowID = glutCreateWindow(name)
  loadExtensions()
  glutDisplayFunc(dummyDisplayFunc)

  #Setup opengl callbacks
  if drawProcedure != nil:
    isLoop = true
    glutIdleFunc(TGlutVoidCallback(drawProcedure))
  else:
    isLoop = false

  glutMotionFunc(TGlut2IntCallback(mouseMotionProc))
  glutPassiveMotionFunc(TGlut2IntCallback(mousePassiveMotionProc))
  glutMouseFunc(TGlut4IntCallback(mouseKeyProc))
  glutKeyboardFunc(TGlut1Char2IntCallback(keyboardKeyProc))

  glutReshapeFunc(reshape)

  if setupProcedure != nil:
    setupProcedure()

  glClearColor(0.0, 0.0, 0.0, 1.0)
  glClearDepth(1.0)
  glEnable(GL_DEPTH_TEST)
  glEnable(GL_BLEND)
  glEnable(GL_MULTISAMPLE)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glDepthFunc(GL_LEQUAL)
  #glShadeModel(GL_SMOOTH) #deprecated in opengl 3.3
  #glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)
  glClearStencil( 0 );
  activeShader = Shader(ID: 0)

  #TODO: load default shaders from separate module
  modelView = mat4f(1.0)
  shader(activeShader, "shaders/LINE_VERTEX.glsl", "shaders/LINE_FRAG.glsl")
  modelViewLocation = glGetUniformLocation(activeShader.ID, "u_mv_matrix")
  projectionLocation = glGetUniformLocation(activeShader.ID, "u_p_matrix")
  var
    pointer_modelView: ptr = model_view.caddr
    pointer_projection: ptr = projection.caddr
  glUniformMatrix4fv(modelViewLocation, GLsizei(1), GLboolean(false), pointer_modelView)
  glUniformMatrix4fv(projectionLocation, GLsizei(1), GLboolean(false), pointer_projection)
  vertexNormalLocation = glGetAttribLocation(activeShader.ID, "a_normal")
  vertexMiterLocation = glGetAttribLocation(activeShader.ID, "a_miter")
  vertexPositionLocation = glGetAttribLocation(activeShader.ID, "a_pos")
  drawingModeLocation = glGetAttribLocation(activeShader.ID, "e_i_drawing_mode")
  lineLengthLocation = glGetUniformLocation(activeShader.ID, "u_linelen")
  #TODO: prevent user from calling size() more than once

  mainLoop()

proc setDrawingMode*(dm: DrawingModes) =
  glVertexAttrib1f(GLuint(drawingModeLocation), GLfloat(dm))

#[
  Procedures available to users.
]#
proc size*(width, height: int) =
  mWidth = width
  mHeight = height

proc frameRate*(): float =
  return FPS

proc frameRate*(fps: float) =
  FPS = fps
  msInFrame = 1000.0 / FPS

proc setSetup*(procedure: proc()) =
  setupProcedure = procedure

proc setDraw*(procedure: proc() {.cdecl.}) =
  drawProcedure = procedure

proc setMouseKeyEvent*(procedure: proc(button: int, state: int, x: float, y: float)) =
  mouseKeyProcedure = procedure

proc setKeyboardEvent*(procedure: proc(key: char, x, y: int)) =
  keyboardKeyProcedure = procedure

proc setMouseDragged*(procedure: proc(x, y: float)) =
  mouseDragProcedure = procedure

proc loop*() =
  if drawProcedure != nil:
    isLoop = true
    glutIdleFunc(TGlutVoidCallback(drawProcedure))

proc noLoop*() =
  isLoop = false

proc background*(r, g, b, a: float) =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  glClearColor(r, g, b, a)

proc background*(g: float) =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  glClearColor(g, g, g, 1.0)

proc background*(col: Color) =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  glClearColor(col.r, col.g, col.b, col.a)

proc strokeWeight*(width: float) =
  vertexWidthLocation = glGetUniformLocation(activeShader.ID, "u_linewidth")
  glUniform1f(vertexWidthLocation, width)
  lineWidth = width

proc noStroke*() =
  isStroke = false

proc stroke*(r, g, b, a: float) =
  isStroke = true
  colorStroke[0] = r
  colorStroke[1] = g
  colorStroke[2] = b
  colorStroke[3] = a

proc stroke*(g: float) =
  isStroke = true
  colorStroke[0] = g
  colorStroke[1] = g
  colorStroke[2] = g
  colorStroke[3] = 1.0

proc stroke*(col: Color) =
  isStroke = true
  colorStroke[0] = col.r
  colorStroke[1] = col.g
  colorStroke[2] = col.b
  colorStroke[3] = col.a

proc useStrokeColor*() =
  fragmentStrokeColorLocation = glGetUniformLocation(activeShader.ID, "stroke_color")
  glUniform4f(fragmentStrokeColorLocation, colorStroke[0], colorStroke[1], colorStroke[2], colorStroke[3])

proc useFillColor*() =
  fragmentFillColorLocation = glGetUniformLocation(activeShader.ID, "fill_color")
  glUniform4f(fragmentFillColorLocation, colorFill[0], colorFill[1], colorFill[2], colorFill[3])

proc noFill*() =
  isFill = false

proc fill*(r, g, b, a: float) =
  isFill = true
  colorFill[0] = r
  colorFill[1] = g
  colorFill[2] = b
  colorFill[3] = a

proc fill*(g: float) =
  isFill = true
  colorFill[0] = g
  colorFill[1] = g
  colorFill[2] = g
  colorFill[3] = 1.0

proc fill*(col: Color) =
  isFill = true
  colorFill[0] = col.r
  colorFill[1] = col.g
  colorFill[2] = col.b
  colorFill[3] = col.a

proc pushMatrix*() =
  if not isMatPushed:
    pushedModelView = model_view
    pushedProjection = projection
    isMatPushed = true

proc popMatrix*() =
  if isMatPushed:
    modelView = pushedModelView
    projection = pushedProjection
    isMatPushed = false

proc translate*(x, y: float) =
  #model_view = translate(model_view, vec3f(float(x), float(y), 0.0))
  projection = translate(projection, vec3f(float(x), float(y), 0.0))

proc rotate*(angle: float) =
  #model_view = rotate(model_view, vec3f(0, 0, 1), angle)
  projection = rotate(projection, vec3f(0, 0, 1), angle)
