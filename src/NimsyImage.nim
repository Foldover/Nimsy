from Nimsytypes import Image, Color
import nimPNG

proc loadImage*(img: Image, path: string) =
    var png = loadPNG24(path)
    img.pixels = newSeq[Color](png.width * png.height)
    for n in 0..<png.width*png.height:
        img.pixels[0] = new(Color)
        img.pixels[0].r =