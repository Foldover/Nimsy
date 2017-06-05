#Setting up Nimsy

import Nimsy
import glut
import opengl
import glu
import PShape

var
  s = newPShape()
  modx = 0.0
proc setup() =
  size(500, 500)

  s.beginShape()
  s.vertex(100, 100, 0)
  s.vertex(200, 100, 0)
  s.vertex(150, 200, 0)
  s.endShape()

proc draw() {.cdecl.} =
  #glClear(GL_COLOR_BUFFER_BIT or GL_STENCIL_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  #FIXME remove this = glMatrixMode(GL_MODELVIEW)                          # To operate on model-view matrix
  #FIXME remove this = glLoadIdentity()                 # Reset the model-view matrix
  background(0.0, 0.0, 0.0, 1.0)

  s.beginShape()
  s.vertex(100, 100, 0)
  s.vertex(150, 150, 0)
  s.vertex(200, 100, 0)
  s.vertex(200, 200, 0)
  s.vertex(100, 200, 0)
  s.vertex(140, 150, 0)
  s.vertex(100, 100, 0)
  s.endShape()
  s.shape()

  stroke(1.0, 1.0, 1.0, 0.1)
  fill(1.0, 1.0, 1.0, 1.0)
  strokeWeight(5.0)
  line(modx, 0.0, modx + 100.0, 200.0)
  modx += 1

  glutSwapBuffers() # Swap the front and back frame buffers (double buffering)

setSetup(setup)
setDraw(draw)
start()
