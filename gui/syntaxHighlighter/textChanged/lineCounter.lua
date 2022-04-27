--[[
    Name: gui/syntaxHighlighter/textChanged/lineCounter.lua
    Description: Automatically add and remove line numbers based off textbox input.
    Author: misrepresenting
]]

local split = string.split
local clear, concat = table.clear, table.concat
local result = {}

return function(object)
    clear(result)
    for i = 1, #split(object.Text, '\n') do
        result[i] = i
    end
    object.LineCounter.Text = concat(result, '\n')
end