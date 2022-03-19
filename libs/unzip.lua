-- "Rewrite" + patch of https://github.com/zerkman/zzlib

local lshift, rshift, band do
    local bit = bit32 or bit
    lshift, rshift, band = bit.lshift, bit.rshift, bit.band
end

local sub, find, char, byte = string.sub, string.find, string.char, string.byte
local insert, unpack = table.insert, unpack or table.unpack
local setmetatable = setmetatable
local order = {17, 18, 19, 1, 9, 8, 10, 7, 11, 6, 12, 5, 13, 4, 14, 3, 15, 2, 16}
local nbt = {2, 3, 7}

local stream = {}
stream.__index = stream

function stream:init(buffer)
    return setmetatable({
        buffer = buffer,
        position = 1,
        bits = 0,
        count = 0
    }, self)
end

function stream:peekBits(number)
    while self.count < number do
        self.bits = self.bits + lshift(byte(self.buffer, self.position), self.count)
        self.position = self.position + 1
        self.count = self.count + 8
    end
    return band(self.bits, lshift(1, number) - 1)
end

function stream:getBits(number)
    local result = self:peekBits(number)
    self.count = self.count - number
    self.bits = rshift(self.bits, number)
    return result
end

function stream:getNext(huff, number)
    local entry = huff[self:peekBits(number)]
    local length = band(entry, 15)
    local result = rshift(entry, 4)
    self.count = self.count - length
    self.bits = rshift(self.bits, length)
    return result
end

local hufftable = function(depths)
    local count = #depths
    local bits = 1
    local blocks = {}
    local nextCodes = {}
    for i = 1, count do
        local depth = depths[i]
        if depth > bits then
            bits = depth
        end
        blocks[depth] = (blocks[depth] or 0) + 1
    end
    local huff = {}
    local code = 0
    blocks[0] = 0
    for i = 1, bits do
        code = (code + (blocks[i - 1] or 0))  * 2
        nextCodes[i] = code
    end
    for i = 1, count do
        local depth = depths[i]
        if depth > 0 then
            local x = (i - 1) * 16 + depth
            code = nextCodes[depth]
            local rightCode = 0
            for v = 1, depth do
                rightCode = rightCode + lshift(band(1, rshift(code, v - 1)), depth - v)
            end
            for v = 0, 2 ^ bits - 1, 2 ^ depth do
                huff[v + rightCode] = x
            end
            nextCodes[depth] = nextCodes[depth] + 1
        end
    end
    return huff, bits
end

local function blockLoop(output, streamObject, litCount, distCount, litTable, distTable)
    local lit
    repeat
        lit = streamObject:getNext(litTable, litCount)
        if lit < 256 then
            insert(output, lit)
        elseif lit > 256 then
            local bits = 0
            local size = 3
            local dist = 1
            if lit < 265 then
                size = size + lit - 257
            elseif lit < 285 then
                bits = rshift(lit - 261, 2)
                size = size + lshift(band(lit - 261, 3) + 4, bits)
            else
                size = 258
            end
            if bits > 0 then
                size = size + streamObject:getBits(bits)
            end
            local v = streamObject:getNext(distTable, distCount)
            if v < 4 then
                dist = dist + v
            else
                bits = rshift(v - 2, 1)
                dist = dist + lshift(band(v, 1) + 2, bits)
                dist = dist + streamObject:getBits(bits)
            end
            local p = #output - dist + 1
            while size > 0 do
                insert(output, output[p])
                p = p + 1
                size = size - 1
            end
        end
    until lit == 256
end

local function blockDynamic(output, streamObject)
    local lit = 257 + streamObject:getBits(5)
    local dist = 1 + streamObject:getBits(5)
    local length = 4 + streamObject:getBits(4)
    local depths = {}
    for i = 1, length do
        depths[order[i]] = streamObject:getBits(3)
    end
    for i = length + 1, 19 do
        depths[order[i]] = 0
    end
    local huff, bits = hufftable(depths)
    local i = 1
    while i <= lit + dist do
        local v = streamObject:getNext(huff, bits)
        if v < 16 then
            depths[i] = v
            i = i + 1
        elseif v < 19 then
            local nb = nbt[v - 15]
            local c = 0
            local number = 3 + streamObject:getBits(nb)
            if v == 16 then
                c = depths[i - 1]
            elseif v == 18 then
                number = number + 8
            end
            for _ = 1, number do
                depths[i] = c
                i = i + 1
            end
        end
    end
    local litDepths = {}
    local distDepths = {}

    for a = 1, lit do
        insert(litDepths, depths[a])
    end

    for a = lit + 1, #depths do
        insert(distDepths, depths[a])
    end
    local litTable, litCount = hufftable(litDepths)
    local distTable, distCount = hufftable(distDepths)
    blockLoop(output, streamObject, litCount, distCount, litTable, distTable)
end

local function inflate(streamObject)
    local output = {}
    local last, typ
    repeat
        last = streamObject:getBits(1)
        typ = streamObject:getBits(2)
        if typ == 2 then
            blockDynamic(output, streamObject)
        end
    until last == 1
    return char(unpack(output))
end

local function int2le(input, position)
    local a, b = byte(input, position, position + 1)
    return b * 256 + a
end

local function int4le(input, position)
    local a, b, c, d = byte(input, position, position + 3)
    return ((d * 256 + c) * 256 + b) * 256 + a
end

local function strip(data)
    local start = find(data, '\x50\x4b\x05\x06')
    if start then
        return sub(data, 1, start + 19)..'\x00\x00'
    end
    return data
end

local streamObject = stream:init()
local function unzip(data, offset)
    streamObject.buffer = strip(data)
    streamObject.position = offset
    streamObject.bits = 0
    streamObject.count = 0
    local result = inflate(streamObject)
    return result
end

local function getFiles(data)
    data = strip(data)
    local i = #data - 21
    i = int4le(data, i + 16) + 1
    return function()
        if int4le(data, i) ~= 33639248 then return end
        local packed = int2le(data, i + 10) ~= 0
        local length = int2le(data, i + 28)
        local file = sub(data, i + 46, i + 45 + length)
        local offset = int4le(data, i + 42) + 1
        local extLength = int2le(data, offset + 28)
        local size = int4le(data, offset + 18)
        i = i + 46 + length + int2le(data, i + 30) + int2le(data, i + 32)
        return file, offset + 30 + length + extLength, packed, size
    end
end

return {
    getFiles = getFiles,
    unzip = unzip
}