import glfw
import glfw/wrapper
import ../../nim-glfw/src/glad/gl

type
    StreamedBuffer* = ref object
        mVao: GLuint
        mVbo: GLuint
        mVertices: seq[float]