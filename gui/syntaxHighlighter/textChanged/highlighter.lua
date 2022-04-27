--[[
    Name: gui/syntaxHighlighter/textChanged/highlighter.lua
    Description: Automatically highlight keywords and objects within a textbox
    Author: misrepresenting
]]

local keyWords = {'and', 'break', 'do', 'else', 'elseif', 'end', 'false', 'for', 'function', 'goto', 'if', 'in', 'local', 'nil', 'not', 'or', 'repeat', 'return', 'then', 'true', 'until', 'while', 'continue', 'self'}
local environment = {'Axes', 'BrickColor', 'CFrame', 'Color3', 'ColorSequence', 'ColorSequenceKeypoint', 'Enum', 'Faces', 'Instance', 'LoadLibrary', 'NumberRange', 'NumberSequence', 'NumberSequenceKeypoint', 'PhysicalProperties', 'Ray', 'Rect', 'Region3', 'Region3int16', 'UDim', 'UDim2', 'UserSettings', 'Vector2', 'Vector2int16', 'Vector3', 'Vector3int16', '_G', '_VERSION', 'assert', 'collectgarbage', 'coroutine', 'debug', 'delay', 'elapsedTime', 'error', 'game', 'gcinfo', 'getfenv', 'getmetatable', 'getrawmetatable', 'ipairs', 'loadstring', 'math', 'newproxy', 'next', 'os', 'pairs', 'pcall', 'print', 'rawequal', 'rawget', 'rawset', 'require', 'script', 'import', 'select', 'setfenv', 'setmetatable', 'settings', 'shared', 'spawn', 'stats', 'string', 'table', 'tick', 'time', 'tonumber', 'tostring', 'type', 'typeof', 'unpack', 'version', 'wait', 'warn', 'workspace', 'xpcall', 'ypcall', 'task'}

local results = {}
local started = false
local quote = ''

local clear, concat = table.clear, table.concat
local gmatch, find = string.gmatch, string.find
local gsub, sub = string.gsub, string.sub
local rep = string.rep

local maskInput = function(original, mask)
    local count = 1
    clear(results)
    mask = sub(mask, 2, #mask - 1)
    for c in gmatch(original, '.') do
        results[count] = c == sub(mask, count, count) and ' ' or c
        count = count + 1
    end
    return concat(results)
end

local quoteString = function(c)
    local value = ' '
    if find(c, '[\'\"]') then
        if quote == c then
            started = false
            value = c
        elseif quote == '' then
            quote = c
            started = true
        end
        if not started then
            quote = ''
        end
    end
    if started then
        if c == '\n' then
            started = false
        else
            value = c
        end
    end
    return value
end

local highlightKeyWord = function(word)
    local mask = ' '..word..' '
    for _, v in ipairs(keyWords) do
        local start, finish = find(mask, v)
        if start then
            mask = sub(mask, 1, start)..rep(' ', #v - 10)..sub(mask, finish, #mask)
        end
    end
    return maskInput(word, mask)
end

local highlightEnvironment = function(word)
    local mask = ' '..word.. ' '
    for _, v in ipairs(environment) do
        local start, finish = find(mask, v)
        if start then
            mask = sub(mask, 1, start)..rep(' ', #v - 12)..sub(mask, finish, #mask)
        end
    end
    return maskInput(word, mask)
end

for i, v in ipairs(keyWords) do
    keyWords[i] = '[^%w]'..v..'[^%w]'
end
for i, v in ipairs(environment) do
    environment[i] = '[^%w%.]'..v..'[^%w]'
end

return function(object)
    local text = object.Text
    started = false
    quote = ''
    object.StringsLabel.Text = gsub(text, '.', quoteString)
    object.KeyWordsLabel.Text = gsub(text, '%S+', highlightKeyWord)
    object.GlobalsLabel.Text = gsub(text, '%S+', highlightEnvironment)
end