#Setting up Nimsy

import glut
import opengl
import glu
import glm
import math
import streams

type
  Shader = ref object of RootObj
    ID* : GLuint
var shader: Shader

proc logShader(shader: GLuint) =
   var length: GLint = 0
   glGetShaderiv(shader, GL_INFO_LOG_LENGTH, length.addr)
   var log: string = newString(length.int)
   glGetShaderInfoLog(shader, length, nil, log)
   echo "Log: ", log

proc loadShader(s: Shader, pathToVerShader: string, pathToFragShader: string) =
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

var FILL: bool = true
var STROKE: bool = true
var color_stroke: array = [0.0, 0.0, 0.0, 0.0]
var color_fill: array = [0.0, 0.0, 0.0, 0.0]
var half_sw: float = 0.5

var vertexNormalLoc: GLint
var vertexPosLoc: GLint

var model_view = mat4f(1.0)
var projection: Mat4x4[float32]
echo model_view

proc useFillColor() =
  glColor4f(color_fill[0], color_fill[1], color_fill[2], color_fill[3])

proc useStrokeColor() =
  let fragmentColorLocation: GLint = glGetUniformLocation(shader.ID, "color")
  glUniform4f(fragmentColorLocation, color_stroke[0], color_stroke[1], color_stroke[2], color_stroke[3])

proc strokeWeight(sw: float) =
  let vertexWidthLocation: GLint = glGetUniformLocation(shader.ID, "u_linewidth")
  glUniform1f(vertexWidthLocation, sw)
  half_sw = sw * 0.5

proc noStroke() =
  STROKE = false

proc stroke(r, g, b, a: float) =
  STROKE = true
  color_stroke[0] = r
  color_stroke[1] = g
  color_stroke[2] = b
  color_stroke[3] = a

proc noFill() =
  FILL = false

proc fill(r, g, b, a: float) =
  FILL = true
  color_fill[0] = r
  color_fill[1] = g
  color_fill[2] = b
  color_fill[3] = a

proc rect(t, l, w, h: float) =
  if FILL:
    useFillColor()
    glBegin(GL_QUADS)
    glVertex2f(t, l)
    glVertex2f(t+h, l)
    glVertex2f(t+h, l+w)
    glVertex2f(t, l+w)
    glEnd()
  if STROKE:
    useStrokeColor()
    glBegin(GL_LINES)
    glVertex2f(t - half_sw, l)
    glVertex2f(t+h + half_sw, l)
    glVertex2f(t+h, l + half_sw)
    glVertex2f(t+h, l+w + half_sw)
    glVertex2f(t+h - half_sw, l+w)
    glVertex2f(t - half_sw, l+w)
    glVertex2f(t, l+w - half_sw)
    glVertex2f(t, l + half_sw)
    glEnd()

proc line(x1, y1, x2, y2: float) =
  let modelViewLocation: GLint = glGetUniformLocation(shader.ID, "u_mv_matrix")
  let projectionLocation: GLint = glGetUniformLocation(shader.ID, "u_p_matrix")
  var
    pointer_modelView: ptr = model_view.caddr
    pointer_projection: ptr = projection.caddr
  glUniformMatrix4fv(modelViewLocation, GLsizei(1), GLboolean(false), pointer_modelView)
  glUniformMatrix4fv(projectionLocation, GLsizei(1), GLboolean(false), pointer_projection)
  var norm1 = vec2(x2 - x1, y2 - y1)
  norm1 = normalize(norm1)
  var norm2 = norm1
  let ntx = norm1.x
  norm1.x = -norm1.y
  norm1.y = ntx
  norm2.x = norm2.y
  norm2.y = -ntx
  useStrokeColor()
  glBegin(GL_TRIANGLES)
  glVertexAttrib2f(GLuint(vertexNormalLoc), GLfloat(norm1.x), GLfloat(norm1.y))
  glVertex2f(x1, y1)
  glVertex2f(x2, y2)
  glVertexAttrib2f(GLuint(vertexNormalLoc), GLfloat(norm2.x), GLfloat(norm2.y))
  glVertex2f(x1, y1)
  glVertex2f(x2, y2)
  glVertex2f(x1, y1)
  glVertexAttrib2f(GLuint(vertexNormalLoc), GLfloat(norm1.x), GLfloat(norm1.y))
  glVertex2f(x2, y2)
  glEnd()

proc point(x, y: float) =
  useStrokeColor()
  glBegin(GL_POINTS)
  glVertex2f(x, y)

proc draw() {.cdecl.} =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT) # Clear color and depth buffers

  glMatrixMode(GL_MODELVIEW)                          # To operate on model-view matrix
  glLoadIdentity()                 # Reset the model-view matrix
  glTranslatef(0.0, 0.0, 0.0)     # Move right and into the screen

  strokeWeight(4.0)
  stroke(0.0, 1.0, 1.0, 0.5)
  line(0, 0, 100.0, 100.0)
  stroke(0.8, 0.2, 0.0, 0.5)
  line(100.0, 100.0, 300.0, 100.0)

  glutSwapBuffers() # Swap the front and back frame buffers (double buffering)

proc reshape(width: GLsizei, height: GLsizei) {.cdecl.} =
  # Compute aspect ratio of the new window
  if height == 0:
    return                # To prevent divide by 0

  # Set the viewport to cover the new window
  glViewport(0, 0, width, height)

  # Set the aspect ratio of the clipping volume to match the viewport
  glMatrixMode(GL_PROJECTION)  # To operate on the Projection matrix
  glLoadIdentity()             # Reset
  # Enable perspective projection with fovy, aspect, zNear and zFar
  #gluPerspective(45.0, width / height, 0.1, 100.0)
  glOrtho(0, GLdouble(width), GLdouble(height), 0, -1.0, 1.0);

  projection = mat4f(ortho(0.0, float(width), float(height), 0.0, -1.0, 1.0))
  echo projection

glutInit()
glutInitDisplayMode(GLUT_DOUBLE)
glutInitWindowSize(640, 480)
glutInitWindowPosition(50, 50)
discard glutCreateWindow("Nimsy")

glutDisplayFunc(draw)
glutReshapeFunc(reshape)

loadExtensions()

glClearColor(0.0, 0.0, 0.0, 1.0)                   # Set background color to black and opaque
glClearDepth(1.0)                                 # Set background depth to farthest
glEnable(GL_DEPTH_TEST)                           # Enable depth testing for z-culling
glDepthFunc(GL_LEQUAL)                            # Set the type of depth-test
glShadeModel(GL_SMOOTH)                           # Enable smooth shading
glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST) # Nice perspective corrections
shader = Shader(ID: 0)
loadShader(shader, "shaders/LINE_VERTEX.glsl", "shaders/LINE_FRAG.glsl")
let modelViewLocation: GLint = glGetUniformLocation(shader.ID, "u_mv_matrix")
let projectionLocation: GLint = glGetUniformLocation(shader.ID, "u_p_matrix")
var
  pointer_modelView: ptr = model_view.caddr
  pointer_projection: ptr = projection.caddr
glUniformMatrix4fv(modelViewLocation, GLsizei(1), GLboolean(false), pointer_modelView)
glUniformMatrix4fv(projectionLocation, GLsizei(1), GLboolean(false), pointer_projection)
vertexNormalLoc = glGetAttribLocation(shader.ID, "a_normal")
vertexPosLoc = glGetAttribLocation(shader.ID, "a_pos")
glutMainLoop()
