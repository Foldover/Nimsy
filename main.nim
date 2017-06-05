#Setting up Nimsy

import Nimsy
import glut
import opengl
import glu
import PShape
import math

var
  s = newPShape()
  modx = 0.0

proc setup() =
  size(500, 500)

proc draw() {.cdecl.} =
  background(0.0, 0.0, 0.0, 1.0)
  stroke(1.0, 1.0, 1.0, 0.4)

  circle(150 + cos(modx) * 100, 150 + sin(modx) * 100, 30)

  # s.beginShape()
  # s.vertex(100 + modx, 100, 0)
  # s.vertex(150, 150, 0)
  # s.vertex(200, 100, 0)
  # s.vertex(200, 200, 0)
  # s.vertex(100, 200, 0)
  # s.vertex(110, 150, 0)
  # s.endShape()
  # s.shape()

  strokeWeight(5.0)
  line(0.0, 0.0, 100.0, 200.0)

  modx += 0.05

proc mouseE(button: int, state: int, x: int, y: int) =
  echo "Mouse!"

proc keyE(key: char, x, y: int) =
  echo "Keyboard!"

setSetup(setup)
setDraw(draw)
setMouseKeyEvent(mouseE)
setKeyboardEvent(keyE)
start()
