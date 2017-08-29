include NStreamingBuffer

type
    NManager = ref object
        vertices: seq[seq[float]]
        lastIdx: array[8, int]
        streamedBuffers: seq[StreamedBuffer]

proc newManager*(): NManager =
    new(result)
    newSeq(result.streamedBuffers, 1)
    result.streamedBuffers[0] = newStreamedBuffer()

proc queueVertices*(man: NManager, data: seq[float]) =
    for n in lastIdx..lastIdx + data.len:
        man.vertices[0][n] = data[n - man.lastIdx[0]]

    man.lastIdx[0] += data.len