# import ../../opengl/src/opengl/glut
# import ../../opengl/src/opengl
# import ../../opengl/src/opengl/glu
import glm
import math
import random
import times, os
import Nimsytypes
import Nimsyglobals
import nimPNG
import system
import sequtils

import glfw
import glfw/wrapper
import ../../nim-glfw/src/glad/gl

#[
  Shader code is temporarily here.
  #TODO: Move shader code to separate module.
]#

var
  mWindows: seq[Win]
  currentWindow = 0

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
  mouseButtonProcedure: proc(win: Win, button: MouseBtn, pressed: bool, modKeys: ModifierKeySet)
  keyboardKeyProcedure: proc(win: Win, key: Key, scanCode: int, action: KeyAction, modKeys: ModifierKeySet)

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
  projection = mat4f(ortho(0.0, float(width), float(height), 0.0, -1.0, 1.0))

proc mousePassiveMotionProc(mx: cint, my: cint) {.cdecl.} =
  mMouseX = mx
  mMouseY = my

proc mouseMotionProc(mx: cint, my: cint) {.cdecl.} =
  mMouseX = mx
  mMouseY = my
  if mouseDragProcedure != nil:
    mouseDragProcedure(float(mx), float(my))

proc mouseButtonProc(win: Win, button: MouseBtn, pressed: bool, modKeys: ModifierKeySet) =
  if mouseButtonProcedure != nil:
    mouseButtonProcedure(win = win, button = button, pressed = pressed, modKeys = modKeys)

proc keyboardKeyProc(win: Win, key: Key, scanCode: int, action: KeyAction, modKeys: ModifierKeySet) =
  if keyboardKeyProcedure != nil:
    keyboardKeyProcedure(win = win, key = key, scanCode = scanCode, action = action, modKeys = modKeys)

#FIXME: Sometimes the program fails to run. See "echo w"
#TODO: initialization REALLY needs to be prettier. How the hell do you resize a gl window?

proc setGLCallbacks(window: Win) =
  window.keyCb = keyboardKeyProc
  window.mouseBtnCb = mouseButtonProc

proc mainLoop() =
  while (not mWindows[0].shouldClose):
    let t1 = epochTime() / 1000.0
    if(isLoop):
      glClear(GL_STENCIL_BUFFER_BIT)
      glfw.swapBufs(mWindows[currentWindow])
      glfw.pollEvents()
      drawProcedure()
    let t2 = epochTime() / 1000.0
    var msDiff = msInFrame - (t2 - t1)
    if msDiff < 0.0:
      msDiff = 0.0
    sleep(int(msDiff))

#[
  Procedures available to Nimsy users
]#

proc start*(w, h: int, name: string = "Nimsy App") =
  mWidth = w
  mHeight = h  

  glfw.init()
  mWindows = newSeq[Win](0)
  mWindows.add(glfw.newGlWin(
    dim = (w: w, h: h), 
    title = name,
    resizable = true,
    version = glv12,
    nMultiSamples = 1,
    forwardCompat = false
    ))
  glfw.makeContextCurrent(mWindows[0])
  mWindows[0].stickyKeys = true

  if not gladLoadGL(getProcAddress):
    quit "Error initialising OpenGL"

  if setupProcedure != nil:
    setupProcedure()

  setGLCallbacks(mWindows[currentWindow])
  glClearColor(0.0, 0.0, 0.0, 1.0)
  glClearDepth(1.0)
  glEnable(GL_DEPTH_TEST)
  glEnable(GL_BLEND)
  glEnable(GL_MULTISAMPLE)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glDepthFunc(GL_LEQUAL)
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

  reshape(GLsizei(mWidth), GLsizei(mHeight))

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
  isLoop = true

proc setMouseButtonEvent*(procedure: proc(win: Win, button: MouseBtn, pressed: bool, modKeys: ModifierKeySet)) =
  mouseButtonProcedure = procedure

proc setKeyboardEvent*(procedure: proc(win: Win, key: Key, scanCode: int, action: KeyAction, modKeys: ModifierKeySet)) =
  keyboardKeyProcedure = procedure

proc setMouseDragged*(procedure: proc(x, y: float)) =
  mouseDragProcedure = procedure

proc loop*() =
  if drawProcedure != nil:
    isLoop = true

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
  projection = translate(projection, vec3f(float(x), float(y), 0.0))

proc rotate*(angle: float) =
  projection = rotate(projection, vec3f(0, 0, 1), angle)

proc scale*(x, y, z: float) =
  projection = scale(projection, vec3f(x, y, z))

#This is horrendously slow. Making data and stringData static doesn't help (that much), so savePNG24() is probably pretty slow
proc saveFrame*(path: string): bool =
  var
    data = newSeq[byte](4 * mWidth * mHeight)
  data.apply(proc(i: var byte) = i = 0x00)
  glReadPixels(GLint(0), GLint(0), GLsizei(mWidth), GLsizei(mHeight), GL_RGBA, GL_UNSIGNED_BYTE, cast[pointer](data))
  var 
    stringData = newStringOfCap(4 * mWidth * mHeight)
  for n in 0..<mWidth*mHeight:
    stringData.add chr(data[n * 4])
    stringData.add chr(data[n * 4 + 1])
    stringData.add chr(data[n * 4 + 2])
  discard savePNG(path, stringData, LCT_RGB, 8, mWidth, mHeight)