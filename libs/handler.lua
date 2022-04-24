--local commands = import('storage').commands

--local players = services.Players
local gsub, sub, find = string.gsub, string.sub, string.find

local parse = function(query)
    local arguments = {}
    local i = 1
    local count = #query + 1
    while i < count do
        local beginning = sub(query, i, i)
        if beginning == '"' and sub(query, i - 1, i - 1) ~= '\\' then
            local finish = find(query, '"', i + 1, true)
            if not finish then
                return nil, 'Expected closing "'
            end
            if sub(query, finish - 1 , finish - 1) == '\\' then
                local x = 2
                repeat
                    finish = find(query, '"', i + x, true)
                    if not finish then
                        return nil, 'Expected closing "'
                    end
                    x = x + 1
                until sub(query, finish - 1, finish - 1) ~= '\\'
            end
            local after = sub(query, finish + 1, finish + 1)
            if after ~= '' and after ~= ' ' then
                return nil, "Expected a space after closing quote, received '"..after.."'"
            end
            local str = sub(query, i + 1, finish - 1)
            if find(str, '\\"', 1, true) then
                str = gsub(str, '\\"', '"')
            end
            arguments[#arguments + 1] = str
            i = finish + 1
        elseif beginning == ' ' then
            local _, spaces = find(query, ' +', i)
            i = spaces + 1
        else
            local space = find(query, ' ', i, true)
            local word = sub(query, i, space and space - 1)
            local quote = find(word, '"', 1, true)
            if quote and sub(word, quote - 1, quote - 1) ~= '\\' then
                return nil, 'Unexpected quote mark in non-quoted string'
            end
            if find(word, '\\"', 1, true) then
                word = gsub(word, '\\"', '"')
            end
            if not space then
                arguments[#arguments + 1] = word
                break
            end
            arguments[#arguments + 1] = word
            i = space + 1
        end
    end
    return arguments
end

return function(query, speaker)
    local arguments = parse(query)
    local flags = {}
end