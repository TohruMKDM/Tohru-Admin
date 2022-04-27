--[[
    Name: gui/syntaxHighlighter/inputBegan.lua
    Description: Automatically indent and tab certain prerequisites are met
    Author: misrepresenting
]]

local keyWords = {{'else', 'end'}, {'do', 'end'}, {'then', 'end'}, {'{', '}'}, {'(function', 'end)'}, {'function', 'end'}, {'repeat', 'until'}}
local patterns = {'\"(.-)\"', '\'(.-)\'', '%-%-.+', '{(.-)}'}

local enter = Enum.KeyCode.Return

local gsub, sub = string.gsub, string.sub
local split, find = string.split, string.find
local rep, format = string.rep, string.format

return function(input, object)
    if object:IsFocused() and input.KeyCode == enter then
        local text = object.Text
        local cursor = object.CursorPosition
        local lines = split(sub(text, 1, cursor - 1), '\n')
        local previous = lines[#lines - 1]
        if not previous then
            return
        end
        local start, finish = find(previous, ' +')
        finish = start == 1 and finish or 0
        for _, v in ipairs(patterns) do
            previous = gsub(previous, v, '')
        end
        for _, v in ipairs(keyWords) do
            if find(previous, v[1], 1, true) then
                finish = rep(' ', finish)
                object.Text = format('%s    %s\n%s%s%s', sub(text, 1, cursor - 1), finish, finish, v[2], sub(text, cursor, #text))
                return
            end
        end
        object.Text = sub(text, 1, cursor - 1)..rep(' ', finish)..sub(text, cursor, #text)
        object.CursorPosition = cursor + finish
    end
end