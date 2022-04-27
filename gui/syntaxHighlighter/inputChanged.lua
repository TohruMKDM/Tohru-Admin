--[[
    Name: gui/syntaxHighlighter/inputChanged.lua
    Description: Fix a scrolling bug when the textbox is focused
    Author: misrepresenting
]]

local mouseWheel = Enum.UserInputType.MouseWheel

return function(input, object)
    if input.UserInputType == mouseWheel then
        object:ReleaseFocus()
    end
end