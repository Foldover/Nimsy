import glfw
import glfw/wrapper
import ../../nim-glfw/src/glad/gl

const 
    STREAM_BUFFER_CAPACITY*: GLSizeiptr = 8192 * 1024 #8 megabytes
    CHAR_BIT*: int = 8 

proc nextPowerOfTwo(number: var GLuint): GLuint =
    if number == 0:
        return 1
    number -= 1
    var i: GLuint = 1 
    while (i < GLuint.sizeof*CHAR_BIT):
        number = number or number shr i
        i = i shl 1
    return number+1


type
    StreamedBuffer* = ref object
        mVao: GLuint
        mVbo: GLuint
        mVertices: seq[float]
        mStreamOffset: GLuint
        mDrawOffset: GLuint

var
    lastIdx: int = 0

proc newStreamedBuffer*() : StreamedBuffer =
    new(result)
    #generate buffers
    glGenVertexArrays(1, addr result.mVao)
    glGenBuffers(1, addr result.mVao)
    glBindBuffer(GL_ARRAY_BUFFER, result.mVbo)
    glBufferData(GL_ARRAY_BUFFER,
        STREAM_BUFFER_CAPACITY,
        nil,
        GL_STREAM_DRAW)
    glBindBuffer(GL_ARRAY_BUFFER, 0)

proc uploadData*(sb: StreamedBuffer, data: seq[float]) =
    glBindBuffer(GL_ARRAY_BUFFER, sb.mVbo)
    var 
        dataSize = GLuint(data.sizeof)
        streamDataSize: GLuint = nextPowerOfTwo(dataSize)
    
    if sb.mStreamOffset + streamDataSize > GLuint(STREAM_BUFFER_CAPACITY):
        glBufferData(GL_ARRAY_BUFFER,
            STREAM_BUFFER_CAPACITY,
            nil,
            GL_STREAM_DRAW)
        glBindVertexArray(sb.mVao)
        glBindBuffer(GL_ARRAY_BUFFER, sb.mVbo)
        glVertexAttribPointer(GLuint(0), GLint(3), cGL_FLOAT, GLboolean(0), GLsizei(0), cast[pointer](0))
        glBindVertexArray(0)
        sb.mStreamOffset = 0

    var vertices = glMapBufferRange(GL_ARRAY_BUFFER,
                        GLintptr(sb.mStreamOffset),
                        GLsizeiptr(dataSize),
                        GL_MAP_WRITE_BIT or GL_MAP_UNSYNCHRONIZED_BIT)

    if vertices == nil:
        return

    var verticesFloat = cast[ptr array[0 .. 0, float]](vertices)

    for n in 0..lastIdx:
        verticesFloat[n] = sb.mVertices[n]

    discard glUnmapBuffer(GL_ARRAY_BUFFER)
    glBindBuffer(GL_ARRAY_BUFFER, 0)
    sb.mDrawOffset = sb.mStreamOffset div (GLfloat.sizeof * 3)
    sb.mStreamOffset += dataSize