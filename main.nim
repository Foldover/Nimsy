#Setting up Nimsy

import Nimsy
import math
import Nimsytypes

var
  x, y = 10

proc setup() =
  size(640, 640)
  frameRate(480)

proc draw() {.cdecl.} =
  background(0.0, 0.0, 0.0, 1.0)
  strokeWeight(2.0)
  stroke(1.0, 0.0, 0.2, 1.0)
  fill(1.0, 1.0, 1.0, 1.0)
  pushMatrix()
  translate(width() * 0.5, height() * 0.5)
  rotate(mouseX() / width() * TWO_PI)
  rect(0, 0, 50, 50)
  popMatrix()

setSetup(setup)
setDraw(draw)
start()
