#Setting up Nimsy

import Nimsy
import NimsyPShape
import math

proc setup() =
  size(640, 640)

proc draw() {.cdecl.} =
  discard

setSetup(setup)
setDraw(draw)
start()
