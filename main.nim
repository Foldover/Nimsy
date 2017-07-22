#Setting up Nimsy

import Nimsy
import math
import Nimsytypes

var
  shp: PShape
  m: float = 0

proc setup() =
  frameRate(60)
  shp = newPShape()
  shp.beginShape()
  shp.vertex(10, 10, 0)
  shp.vertex(110, 10, 0)
  shp.vertex(110, 50, 0)
  shp.vertex(10, 150, 0)
  shp.vertex(10, 10, 0)
  shp.endShape()

proc draw() {.cdecl.} =
  background(0.0, 0.0, 0.0, 1.0)
  strokeWeight(1.12)
  stroke(1.0, 0.0, 0.2, 1.0)
  fill(1.0, 1.0, 1.0, 0.05)
  shp.shape()

setSetup(setup)
setDraw(draw)
start(640, 640)
