#Setting up Nimsy

import Nimsy
import glut
import opengl
import glu
import PShape

proc setup() =
  size(500, 500)

proc draw() {.cdecl.} =
  background(0.0, 0.0, 0.0, 1.0)
  stroke(1.0, 1.0, 1.0, 0.5)

  arc(250, 250, 50, 0, PI+0.1)
  stroke(0, 1.0, 0.0, 0.5)
  line(250, 250, 250, 255)

  strokeWeight(5.0)
  line(100.0, 200.0, 200.0, 205.0)
  strokeWeight(0.5)
  stroke(1.0, 0.0, 0.2, 0.5)
  line(100.0, 95.0, 100.0, 105.0)
  line(200.0, 95.0, 200.0, 105.0)

proc mouseE(button: int, state: int, x: int, y: int) =
  echo "Mouse!"

proc keyE(key: char, x, y: int) =
  echo "Keyboard!"

setSetup(setup)
setDraw(draw)
setMouseKeyEvent(mouseE)
setKeyboardEvent(keyE)
start()
