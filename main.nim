#Setting up Nimsy

import Nimsy
import NimsyPShape
import math

var r = 200.0
var m = 0.0
var g = 0.0

var bajs = 0

proc setup() =
  size(640, 400)
  frameRate(60)

proc drawCircle(x, y, radius: float) =
  stroke(0.0, g, 1-g, 0.01)
  noFill()
  circle(x, y, radius)
  if radius > 8:
    drawCircle(x + radius/2, y, radius/2)
    drawCircle(x - radius/2, y, radius/2)

proc draw() {.cdecl.} =
  if bajs <= 2:
    background(0.9, 0.0, 0.3, 1.0)
    bajs += 1

  fill(0.9, 0.0, 0.3, 0.001)
  rect(0, 0, width(), height())
  strokeWeight(2.0)

  if(sin(m) < 0.9):
    drawCircle(width()/2, height()/2, r * sin(m))
    m += 0.001
    g += 0.001

setSetup(setup)
setDraw(draw)
start()
