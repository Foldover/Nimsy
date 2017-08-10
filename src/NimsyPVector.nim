#[
  This module implements a vector object.
  TODO:Missing procedures:
    #[
      set()
      copy()
      lerp()
      array()
    ]#
  TODO: Math operators should produce new vector, while math procs should operate on the vector they get called upon
]#

import random
import math
from Nimsytypes import NVector

proc newNVector*(x, y, z: float): NVector =
  return NVector(x: x, y: y, z: z)

proc newNVector*(value: float): NVector =
  return NVector(x: value, y: value, z: value)

proc random2D*(): NVector =
  return NVector(x: random(1.0), y: random(1.0), z: 0)

proc random3D*(): NVector =
  return NVector(x: random(1.0), y: random(1.0), z: random(1.0))

proc fromAngle*(angle: float): NVector =
  return NVector(x: cos(angle), y: sin(angle), z: 0)

proc magSq*(v: NVector): float =
  return v.x*v.x + v.y*v.y + v.z*v.z

proc mag*(v: NVector): float =
  return sqrt(v.magSq())

proc `+`(v1, v2: NVector): NVector =
  return NVector(x: v1.x+v2.x,
                  y: v1.y+v2.y,
                  z: v1.z+v2.z)

proc `-`(v1, v2: NVector): NVector =
  return NVector(x: v1.x-v2.x,
                  y: v1.y-v2.y,
                  z: v1.z-v2.z)

proc `*`(v1, v2: NVector): NVector =
  return NVector(x: v1.x*v2.x,
                  y: v1.y*v2.y,
                  z: v1.z*v2.z)

proc `/`(v1, v2: NVector): NVector =
  return NVector(x: v1.x/v2.x,
                  y: v1.y/v2.y,
                  z: v1.z/v2.z)

proc `*`(v1: NVector, s: float): NVector =
  return NVector(x: v1.x*s,
                  y: v1.y*s,
                  z: v1.z*s)

proc `/`(v1: NVector, s: float): NVector =
  return NVector(x: v1.x/s,
                  y: v1.y/s,
                  z: v1.z/s)

proc add*(v1, v2: NVector) =
  v1.x += v2.x
  v1.y += v2.y
  v1.z += v2.z

#TODO: implement more adding, subbing, multiplying and dividing procedures

proc sub*(v1, v2: NVector) =
  v1.x -= v2.x
  v1.y -= v2.y
  v1.z -= v2.z

proc mult*(v1, v2: NVector) =
  v1.x *= v2.x
  v1.y *= v2.y
  v1.z *= v2.z

proc mult*(v1: NVector, s: float) =
  v1.x *= s
  v1.y *= s
  v1.z *= s

#CONSIDERATION: div is a keyword in nim. Maybe have full names for every vector operation? (for consistency)
proc divide*(v1, v2: NVector) =
  v1.x /= v2.x
  v1.y /= v2.y
  v1.z /= v2.z

proc divide*(v1: NVector, s: float) =
  v1.x /= s
  v1.y /= s
  v1.z /= s

proc dist*(v1, v2: NVector): float =
  var
    x = v2.x-v1.x
    y = v2.y-v1.x
    z = v2.z-v1.z
  return sqrt(x*x + y*y + z*z)

proc dot*(v1, v2: NVector): float =
  #TODO: look into Kahan summation
  return v1.x*v2.x + v1.y*v2.y + v1.z*v2.z

proc cross*(v1, v2: NVector): NVector =
  var
    tx = v1.y*v2.z + v1.z*v2.y
    ty = v1.x*v2.z + v1.z*v2.x
    tz = v1.x*v2.y + v1.y*v2.x
  return NVector(x: tx, y: ty, z: tz)

proc normalized*(v: NVector): NVector =
  var m: float = v.mag
  return NVector(x: v.x/m, y: v.y/m, z: v.z/m)

proc normalize*(v: NVector) =
  var m: float = v.mag
  v.x = v.x/m
  v.y = v.y/m
  v.z = v.z/m

proc limited*(v: NVector, max: float): NVector =
  var
    tx: float = v.x
    ty: float = v.y
    tz: float = v.z
  if tx > max:
    tx = max
  if ty > max:
    ty = max
  if tz > max:
    tz = max
  return NVector(x: tx, y: ty, z: tz)

proc setMag*(v: NVector, len: float): NVector =
  return v.normalized() * len

proc heading*(v: NVector): float =
  var
    tv: NVector = v.normalized()
    zv: NVector = newNVector(0.0)
    mapdot: float = (1.0 - (tv.dot(zv) + 1.0) * 0.5)

  return mapdot * 180.0

proc rotated*(v: NVector, angle: float): NVector =
  var
    cs: float = cos(angle)
    sn: float = sin(angle)
  return NVector(x: (v.x*cs - v.y*sn), y: (v.x*sn + v.y*cs), z: v.z)

proc rotate*(v: NVector, angle: float) =
  var
    cs: float = cos(angle)
    sn: float = sin(angle)
  v.x = (v.x*cs - v.y*sn)
  v.y = (v.x*sn + v.y*cs)
  v.z = v.z

proc angleBetween*(v1, v2: NVector): float =
  let
    tv1: NVector = v1.normalized()
    tv2: NVector = v2.normalized()
  var
    mapdot: float = (1.0 - (tv1.dot(tv2) + 1.0) * 0.5)

  return mapdot * 180.0

proc normal*(v1: NVector): NVector =
  var nv = v1
  nv.normalize()
  let tx = nv.x
  nv.x = nv.y
  nv.y = -tx
  return nv

# TODO: Remove this function. It's existance is confusing.
proc normal*(v1, v2: NVector): NVector =
  var nv = v2 - v1
  nv.normalize()
  let tx = nv.x
  nv.x = nv.y
  nv.y = -tx
  return nv

proc tangent3*(v1, v2, v3: NVector): NVector =
  return ((v3-v2).normalized() + (v2-v1).normalized()).normalized()
