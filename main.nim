# OpenGL example using glut

import glut
import opengl
import glu

var FILL: bool = true
var STROKE: bool = true
var color_stroke: array = [0.0, 0.0, 0.0, 0.0]
var color_fill: array = [0.0, 0.0, 0.0, 0.0]
var half_sw: float = 0.5

proc useFillColor() =
  glColor4f(color_fill[0], color_fill[1], color_fill[2], color_fill[3])

proc useStrokeColor() =
  glColor4f(color_stroke[0], color_stroke[1], color_stroke[2], color_stroke[3])

proc strokeWeight(sw: float) =
  glLineWidth(sw)
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

proc line(x1: float, y1: float, x2: float, y2: float) =
  if STROKE:
    glBegin(GL_TRIANGLE_STRIP);
    glColor3f(1,1,1);
    glVertex3f(50,270,0);
    glVertex3f( 100,30,0);
    useStrokeColor()
    glVertex3f( 54,270,0);
    glVertex3f( 104,30,0);
    glColor3f( 1,1,1);
    glVertex3f( 58,270,0);
    glVertex3f( 108,30,0);
    glEnd();


    #useStrokeColor()
    #glBegin(GL_LINES)
    #glVertex2f(x1, y1)
    #glVertex2f(x2, y2)
    #glEnd()

proc point(x, y: float) =
  useStrokeColor()
  glBegin(GL_POINTS)
  glVertex2f(x, y)

proc draw() {.cdecl.} =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT) # Clear color and depth buffers
  glMatrixMode(GL_MODELVIEW)                          # To operate on model-view matrix
  glLoadIdentity()                 # Reset the model-view matrix
  glTranslatef(0.0, 0.0, 0.0)     # Move right and into the screen

  # Render a cube consisting of 6 quads
  # Each quad consists of 2 triangles
  # Each triangle consists of 3 vertices

  stroke(0.0, 1.0, 1.0, 0.5)
  line(0, 0, 40.0, 40.0)
  stroke(0.8, 0.2, 0.0, 0.5)
  line(0.0, 40.0, 40.0, 0.0)
  stroke(0.7, 0.7, 0.1, 0.5)
  strokeWeight(5.0)
  fill(0.3, 0.3, 0.3, 0.1)
  rect(100, 100, 20, 30)

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

glutMainLoop()
