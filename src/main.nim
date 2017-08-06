#Setting up Nimsy

import Nimsy
import math
import Nimsytypes
import strutils

type
  Star = ref object
    s: PShape
    rot: float
    posx: float
    posy: float

proc newStar(x, y: float): Star =
  var ss = newPShape()
  ss.beginShape()
  ss.vertex(0, -50, 0);
  ss.vertex(14, -20, 0);
  ss.vertex(47, -15, 0);
  ss.vertex(23, 7, 0);
  ss.vertex(29, 40, 0);
  ss.vertex(0, 25, 0);
  ss.vertex(-29, 40, 0);
  ss.vertex(-23, 7, 0);
  ss.vertex(-47, -15, 0);
  ss.vertex(-14, -20, 0);
  ss.vertex(0, -50, 0);
  ss.endShape()
  return Star(s: ss, rot: 0, posx: x, posy: y)

proc show(star: Star) =
  pushMatrix()
  translate(star.posx, star.posy)
  rotate(star.rot)
  star.s.shape()
  popMatrix()

const
  nstars = 10

var
  stars = newSeq[Star](nstars)

proc setup() =
  frameRate(60)
  background(0.0, 0.0, 0.0, 1.0)

  for n in 0..<nstars:
    stars[n] = newStar(40.0, float(n) * 100.0)

proc draw() {.cdecl.} =
  background(0.0, 0.0, 0.0, 1.0)

  strokeWeight(2.0)
  stroke(0.78, 0.3, 0.3, 0.8)
  fill(0.2, 0.7, 0.6, 0.7)
  for n in 0..<nstars:
    stars[n].show()
    stars[n].rot += 0.01

setSetup(setup)
setDraw(draw)
start(640, 640)
