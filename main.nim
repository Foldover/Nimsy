#Setting up Nimsy

import Nimsy
import glut
import opengl
import glu

proc setup() =
  size(1000, 1000)

proc draw() {.cdecl.} =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  glMatrixMode(GL_MODELVIEW)                          # To operate on model-view matrix
  glLoadIdentity()                 # Reset the model-view matrix

  glutSwapBuffers() # Swap the front and back frame buffers (double buffering)

setSetup(setup)
setDraw(draw)
start()
