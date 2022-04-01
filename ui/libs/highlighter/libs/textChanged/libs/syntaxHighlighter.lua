-- Syntax highlighting

local keyWords = {'and', 'break', 'do', 'else', 'elseif', 'end', 'false', 'for', 'function', 'goto', 'if', 'in', 'local', 'nil', 'not', 'or', 'repeat', 'return', 'then', 'true', 'until', 'while', 'continue'}
local globals = {'Axes', 'BrickColor', 'CFrame', 'Color3', 'ColorSequence', 'ColorSequenceKeypoint', 'Enum', 'Faces', 'Instance', 'LoadLibrary', 'NumberRange', 'NumberSequence', 'NumberSequenceKeypoint', 'PhysicalProperties', 'Ray', 'Rect', 'Region3', 'Region3int16', 'UDim', 'UDim2', 'UserSettings', 'Vector2', 'Vector2int16', 'Vector3', 'Vector3int16', '_G', '_VERSION', 'assert', 'collectgarbage', 'coroutine', 'debug', 'delay', 'elapsedTime', 'error', 'game', 'gcinfo', 'getfenv', 'getmetatable', 'getrawmetatable', 'ipairs', 'loadstring', 'math', 'newproxy', 'next', 'os', 'pairs', 'pcall', 'print', 'rawequal', 'rawget', 'rawset', 'require', 'script', 'select', 'setfenv', 'setmetatable', 'settings', 'shared', 'spawn', 'stats', 'string', 'table', 'tick', 'time', 'tonumber', 'tostring', 'type', 'typeof', 'unpack', 'version', 'wait', 'warn', 'workspace', 'xpcall', 'ypcall'};
local sub, gsub, rep = string.sub, string.gsub, string.rep
local find, gmatch = string.find, string.gmatch

local maskInput = function(original, mask)
    local result = ''
    local i = 1
    mask = sub(mask, 2, #mask - 1)
    for str in gmatch(original, '.') do
        result = result..(sub(mask, i, i) == str and ' ' or str)
        i = i + #str
    end
    return result
end

return function(obj)
    local text = obj.Text
    local toggle = false
    local previous, previousPrevious = '', ''
    local quote = ''
    obj.StringsLabel.Text = gsub(text, '.', function(char)
        local value = ' '
        if find(char '[\'\"]') and (previous ~= '\\' or (previous == '\\' and previousPrevious == '\\')) then
            if quote == '' then
                quote = char
                toggle = true
            elseif quote == char then
                value = char
                toggle = false
            end
            if not toggle then
                quote = ''
            end
        end
        if toggle then
            if char == '\n' then
                toggle = false
            else
                value = char
            end
        end
        previousPrevious = previous
        previous = char
        return value
    end)
    obj.KeyWordsLabel.Text = gsub(text, '%S+', function(word)
        local mask = ' '..word..' '
        for i = 1, #keyWords do
            local keyWord = keyWords[i]
            local start, finish = find(mask, '[^%w]'..keyWord..'[^%w]')
            if start then
                mask = sub(mask, 1, start)..rep(' ', #keyWord)..sub(mask, finish, #mask)
            end
        end
        return maskInput(word, mask)
    end)
    obj.GlobalsLabel.Text = gsub(text, '%S+', function(word)
        local mask = ' '..word..' '
        for i = 1, #globals do
            local global = globals[i]
            local start, finish = find(mask, '[^%w%.]'..global..'[^%w]')
            if start then
                mask = sub(mask, 1, start)..rep(' ', #global)..sub(mask, finish, #mask)
            end
        end
        return maskInput(word, mask)
    end)
    obj.NumbersLabel.Text = gsub(text, '%S+', function(word)
        local mask = ' '..word..' '
        local start, finish = find(mask, '[^%w]%d+[.]')
        if start then
            mask = sub(mask, 1, start)..rep(' ', start - finish)..sub(mask, finish, #mask)
        end
        return maskInput(word, mask)
    end)
end
