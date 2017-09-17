import glfw
import glfw/wrapper
import ../../nim-glfw/src/glad/gl

type
  Shader* = ref object of RootObj
    ID* : GLuint
    vertexPositionAttribute: GLint
    vertexNormalAttribute: GLint

proc use*(shader: Shader) =
  glUseProgram(shader.ID)

proc logShader(shader: GLuint) =
   var length: GLint = 0
   glGetShaderiv(shader, GL_INFO_LOG_LENGTH, length.addr)
   var log: string = newString(length.int)
   glGetShaderInfoLog(shader, length, nil, log)
   echo "Log: ", log

proc shader*(pathToVerShader: string, pathToFragShader: string): GLuint =
  var
    verFromFile: array[1, string] = [readFile(pathToVerShader).string]
    fragFromFile: array[1, string] = [readFile(pathToFragShader).string]
    verSource = allocCStringArray(verFromFile)
    fragSource = allocCStringArray(fragFromFile)
    resultVer: GLuint = 0
    resultFrag: GLuint = 0
    compiled: GLint = 0

  resultVer = glCreateShader(GL_VERTEX_SHADER)
  glShaderSource(resultVer, 1, verSource, nil)
  glCompileShader(resultVer)
  glGetShaderiv(resultVer, GL_COMPILE_STATUS, compiled.addr)
  if compiled == 0:
    logShader(resultVer)

  resultFrag = glCreateShader(GL_FRAGMENT_SHADER)
  glShaderSource(resultFrag, 1, fragSource, nil)
  glCompileShader(resultFrag)
  glGetShaderiv(resultFrag, GL_COMPILE_STATUS, compiled.addr)
  if compiled == 0:
    logShader(resultFrag)

  var shaderProgram = glCreateProgram();
  glAttachShader(shaderProgram, resultVer)
  glAttachShader(shaderProgram, resultFrag)
  glLinkProgram(shaderProgram)

  deallocCStringArray(verSource)
  deallocCStringArray(fragSource)
  glDeleteShader(resultVer)
  glDeleteShader(resultFrag)

  return shaderProgram

proc newShader*(): Shader =
  new(result)