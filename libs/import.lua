-- Basically just require but for support for the local file system
-- + Support for relative files

local gmatch, gsub, match = string.gmatch, string.gsub, string.match
local concat = table.concat
local importCache = {}

local mt = {}
mt.__index = mt

local makePath = function(...)
    return concat({...}, '/')
end

local splitPath = function(path)
    local result = {}
    for split in gmatch(path, '[^/\\]+') do
        result[#result + 1] = split
    end
    return result
end

local parseFolder = function(folder, path)
    if isfolder(folder) then
        for _, file in pairs(listfiles(folder)) do
            local split = splitPath(file)
            local name = split[#split]
            split[#split] = nil
            if path == gsub(name, '%.[^/\\%.]+$', '') then
                if match(name, '%.[^/\\%.]+$') == '.lua' then
                    return name, concat(split, '/'), file
                elseif isfolder(file) and isfile(makePath(file, 'init.lua')) then
                    return 'init.lua', file, makePath(file, 'init.lua')
                end
            end
        end
    end
end

mt.init = function(self, directory, name)
    return setmetatable({
        path = makePath(directory, name or 'import.lua'),
        dir = directory
    }, self)
end

mt.resolve = function(self, path)
    local module = module or self
    local current = module.dir
    local file, directory, absolutePath = parseFolder(makePath(current, 'libs'), path)
    if file then
        return file, directory, absolutePath
    end
    file, directory, absolutePath = parseFolder(current, path)
    if file then
        return file, directory, absolutePath
    end
    path = makePath(current, path)
    local split = splitPath(path)
    local name = split[#split]
    split[#split] = nil
    if isfolder(path) and isfile(makePath(path, 'init.lua')) then
        return 'init.lua', concat(split, '/'), makePath(path, 'init.lua')
    end
    if isfile(path..'.lua') then
        return name, concat(split, '/'), path..'.lua'
    end
end

mt.import = function(self, path, force)
    local module = module or self
    assert(path ~= nil, 'Missing name to require')
    local name, directory, absolutePath = self:resolve(path)
    if not force and importCache[absolutePath] then
        return importCache[absolutePath]
    end
    assert(name, 'No such module "'..path..'" in "'..module.path..'"')
    local fn = assert(loadstring(readfile(absolutePath), '@'..name))
    local mod = mt:init(directory, name)
    local environment = {
        module = mod,
        import = function(...)
            return mod:import(...)
        end
    }
    setfenv(fn, setmetatable(environment, {__index = getgenv()}))
    mod.export = fn()
    importCache[absolutePath] = mod.export
    return mod.export
end

return function(directory, name)
    local mod = mt:init(directory, name)
    return function(...)
        return mod:import(...)
    end, mod
end