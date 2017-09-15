import glfw
import glfw/wrapper
import ../../nim-glfw/src/glad/gl

const 
    STREAM_BUFFER_CAPACITY*: GLSizeiptr = 8192 * 1024 #8 megabytes
    STREAM_BUFFER_CAPACITY_INT*: int = int(STREAM_BUFFER_CAPACITY)
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
    #bind the streambuffer's vbo
    glBindBuffer(GL_ARRAY_BUFFER, sb.mVbo)

    #get the size of the data to upload, as well as the size of streamed buffer to use
    var 
        dataSize = GLuint(data.sizeof)
        streamDataSize: GLuint = nextPowerOfTwo(dataSize)
    
    #check if the incumbent data upload will overshoot the capacity of the streamed buffer
    if sb.mStreamOffset + streamDataSize > GLuint(STREAM_BUFFER_CAPACITY):
        #orfan the buffer
        glBufferData(GL_ARRAY_BUFFER,
            STREAM_BUFFER_CAPACITY,
            nil,
            GL_STREAM_DRAW)
        #bind the vao
        glBindVertexArray(sb.mVao)
        #bind the vbo
        glBindBuffer(GL_ARRAY_BUFFER, sb.mVbo)
        #tell opengl how to interpret the data in the vbo
        glVertexAttribPointer(GLuint(0), GLint(3), cGL_FLOAT, GLboolean(0), GLsizei(0), cast[pointer](0))
        #unbind vao
        glBindVertexArray(0)
        #reset the stream offset counter
        sb.mStreamOffset = 0

    #get a range "streamoff<=range<=datasize" for writing. Tell opengl that no synchronization is needed, because we
    #can promise to not write to unfinished queued ranges of buffer commands, as well as promise to not read memory.
    var vertices = glMapBufferRange(GL_ARRAY_BUFFER,
                        GLintptr(sb.mStreamOffset),
                        GLsizeiptr(dataSize),
                        GL_MAP_WRITE_BIT or GL_MAP_UNSYNCHRONIZED_BIT)

    #if we didn't get any memory range, just fail silently
    if vertices == nil:
        return

    #cast the void* pointer to a float* pointer (needs testing)
    var verticesFloat = cast[ptr array[0 .. 0, float]](vertices)

    #write to the mapped memory
    for n in 0..lastIdx:
        verticesFloat[n] = data[n]

    #unmap tells opengl we're done
    discard glUnmapBuffer(GL_ARRAY_BUFFER)
    #unbind vbo
    glBindBuffer(GL_ARRAY_BUFFER, 0)
    #update draw and stream offset
    sb.mDrawOffset = sb.mStreamOffset div (GLfloat.sizeof * 3)
    sb.mStreamOffset += dataSize