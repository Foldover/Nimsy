#Setting up Nimsy

import Nimsy
import glut
import opengl
import glu
import PShape
import math

var
  modx = 0.0
  s = newPShape()

proc setup() =
  size(500, 500)

proc draw() {.cdecl.} =
  background(0.0, 0.0, 0.0, 1.0)
  stroke(0.3, 0.7, 0.99, 0.5)
  strokeWeight(4.0)

  s.beginShape()
  s.vertex(100, 100, 0)
  s.vertex(150, 150, 0)
  s.vertex(200, 100, 0)
  s.vertex(200+modx, 200, 0)
  s.vertex(150, 240, 0)
  s.vertex(100, 200, 0)
  s.vertex(100, 100, 0)
  s.endShape()
  s.shape()
  modx += 0.1

proc mouseE(button: int, state: int, x: int, y: int) =
  echo "Mouse!"

proc keyE(key: char, x, y: int) =
  echo "Keyboard!"

setSetup(setup)
setDraw(draw)
setMouseKeyEvent(mouseE)
setKeyboardEvent(keyE)
start()
