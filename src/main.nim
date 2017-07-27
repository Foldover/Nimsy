#Setting up Nimsy

import Nimsy
import math
import Nimsytypes
import strutils

var
  shp: PShape
  m: float = 0

proc setup() =
  frameRate(60)
  shp = newPShape()
  shp.beginShape()
  shp.vertex(0, -50, 0);
  shp.vertex(14, -20, 0);
  shp.vertex(47, -15, 0);
  shp.vertex(23, 7, 0);
  shp.vertex(29, 40, 0);
  shp.vertex(0, 25, 0);
  shp.vertex(-29, 40, 0);
  shp.vertex(-23, 7, 0);
  shp.vertex(-47, -15, 0);
  shp.vertex(-14, -20, 0);
  shp.vertex(0, -50, 0);
  shp.endShape()
  background(0.0, 0.0, 0.0, 1.0)

proc draw() {.cdecl.} =
  #background(0.0, 0.0, 0.0, 1.0)
  noStroke()
  fill(0.24, 0.12, 0.87, 0.001)
  rect(0, 0, width(), height())
  strokeWeight(5)
  stroke(1.0, 0.0, 0.2, 0.01)
  fill(0.12, 0.89, 0.18, 0.01)
  pushMatrix()
  
  translate(width()/2, height()/2)
  scale(1+sin(m)*4, 1+sin(m)*4, 0)
  rotate(m)
  shp.shape()
  popMatrix()
  m += 0.01

setSetup(setup)
setDraw(draw)
start(640, 640)
