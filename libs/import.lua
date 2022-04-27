--[[
    Name: import.lua
    Description: A custom require system with support for relative paths, inspired from luvit.
    Author: Tohru
]]

local gmatch, gsub = string.gmatch, string.gsub
local format, find = string.format, string.find
local concat, remove = table.concat, table.remove

local environment = {
    __index = getfenv(1)
}
local cache = {}

local splitPath = function(path)
    local result = {}
    for split in gmatch(path, '[^/\\]+') do
        result[#result + 1] = split
    end
    return result
end

local getLast = function(path)
    local last
    for split in gmatch(path, '[^/\\]+') do
        last = split
    end
    return last
end

local parse = function(folder, name)
    if not isfolder(folder) then
        return
    end
    for _, v in ipairs(listfiles(folder)) do
        local file = getLast(v)
        if file == name..'.lua' then
            return v
        end
        local path = v..'/init.lua'
        if file == name and isfile(path) then
            return path
        end
    end
end

local import = {cache = cache}
setmetatable(import, import)
import.__index = import

import.__call = function(self, name, force)
    local path = self:resolve(name)
    if path then
        if find(path, '\\', 1, true) then
            path = gsub(path, '\\', '/')
        end
    end
    if not force and cache[path] then
        return cache[path]
    end
    if not path then
        error(format('No such module "%s" in "%s"', name, self.dir), 2)
    end
    local module = assert(loadstring(readfile(path), '@'..path))
    setfenv(module, setmetatable({
        import = import:init(path)
    }, environment))
    local result = module()
    cache[path] = result or {}
    return result
end

import.resolve = function(self, name)
    local path = parse(self.dir..'/libs', name)
    if path then
        return path
    end
    local split = splitPath(name)
    local searchName = remove(split)
    path = parse(self.dir..'/'..concat(split, '/'), searchName)
    if path then
        return path
    end
    path = parse(self.dir, name)
    if path then
        return path
    end
    if self.dir == self.root then
        return
    end
    path = parse(self.root..'/libs', name)
    if path then
        return path
    end
    split = splitPath(name)
    searchName = remove(split)
    path = parse(self.root..'/'..concat(split, '/'), searchName)
    if path then
        return path
    end
    path = parse(self.root, name)
    if path then
        return path
    end
end

import.init = function(self, path)
    local split = splitPath(path)
    local instance = {
        root = split[1],
        dir = concat(split, '/', 1, #split - 1),
        path = path
    }
    return setmetatable(instance, self)
end

return import