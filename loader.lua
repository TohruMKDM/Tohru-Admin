-- Tohru~ (トール) 💖#0001

if isfile('TohruAdmin/libs/import.lua') then
    local generator = loadstring(readfile('TohruAdmin/libs/import.lua'), '@import.lua')
    local import = generator('TohruAdmin', 'libs/import.lua')
    return import('init')
end

local url = 'https://github.com/TohruMKDM/Tohru-Admin/archive/refs/heads/master.zip'
local sub = string.sub
local unzip = loadstring(game:HttpGet('https://raw.githubusercontent.com/TohruMKDM/Tohru-Admin/master/libs/unzip.lua'), '@unzip.lua')()
local stream = unzip.newStream(game:HttpGet(url))

for name, content in unzip.getFiles(stream, true) do
    if sub(name, -1) == '/' then
        makefolder(name)
    else
        writefile(name, content)
    end
end