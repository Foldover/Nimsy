include NStreamingBuffer
from Nimsytypes import DrawingModes

import Nimsyglobals

type
    CommandQueue = ref object
        commands*: seq[DrawingModes]
        gldrawmode*: seq[GLenum]
        timestamp*: seq[int]
        count*: seq[int]

proc newCommandQueue(): CommandQueue =
    new(result)
    newSeq(result.commands, 0)
    newSeq(result.timestamp, 0)
    newSeq(result.count, 0)
    newSeq(result.gldrawmode, 0)

type
    RenderingObject = ref object
        vertices: array[STREAM_BUFFER_CAPACITY_INT div GLfloat.sizeof, float]
        lastIdx: int
        streamedBuffer: StreamedBuffer
        commands: CommandQueue

proc newRenderingObject(): RenderingObject =
    new(result)
    result.streamedBuffer = newStreamedBuffer()
    result.commands = newCommandQueue()
    result.lastidx = 0

type
    NManager = ref object
        renderObj: RenderingObject

proc newManager*(): NManager =
    new(result)
    result.renderObj = newRenderingObject()

proc queueVertices*(man: NManager, data: seq[float], mode: DrawingModes, glmode: GLenum) =
    man.renderObj.commands.commands.add(mode)
    man.renderObj.commands.timestamp.add(lastIdx)
    man.renderObj.commands.count.add(data.len)
    man.renderObj.commands.gldrawmode.add(glmode)
    for n in lastIdx..lastIdx + data.len:
        man.renderObj.vertices[n] = data[n - man.renderObj.lastIdx]

    man.renderObj.lastIdx += data.len

proc doRender(man: NManager) =
    for n in 0..man.renderObj.commands.commands.high:
        glBindVertexArray(man.renderObj.streamedBuffer.mVao)
        glBindBuffer(GL_ARRAY_BUFFER, man.renderObj.streamedBuffer.mVbo)
        glVertexAttrib1f(GLuint(drawingModeLocation), GLfloat(man.renderObj.commands.commands[n]))
        glDrawArrays(man.renderObj.commands.gldrawmode[n], GLint(man.renderObj.commands.timestamp[n]), GLsizei(man.renderObj.commands.count[n]))