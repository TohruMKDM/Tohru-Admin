--[[
    Name: gui/syntaxHighlighter/textChanged/tabbing.lua
    Description: Handle textbox input when a tab is found
    Author: misrepresenting
]]

local sub = string.sub

return function(object)
    local text = object.Text
    local cursor = object.CursorPosition
    local previous = sub(text, cursor - 1, cursor - 1)
    if previous == '\t' then
        object.Text = sub(text, 1, cursor - 2)..'   '..sub(text, cursor, #text)
        object.CursorPosition = cursor + 3
    end
end