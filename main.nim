#Setting up Nimsy

import Nimsy
import math
import Nimsytypes

var
  x, y = 10

proc setup() =
  size(640, 640)
  frameRate(60)

proc draw() {.cdecl.} =
  #background(0.0, 0.0, 0.0, 1.0)
  strokeWeight(2.0)
  stroke(1.0, 0.0, 0.2, 1.0)
  fill(1.0, 1.0, 1.0, 0.05)
  rect(0, 0, width(), height())
  pushMatrix()
  translate(mouseX(), mouseY())
  point(0, 0, 0)
  popMatrix()

setSetup(setup)
setDraw(draw)
start()
