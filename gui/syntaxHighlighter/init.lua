--[[
    Name: gui/syntaxHighlighter/init.lua
    Description: Import all modules and build a function that'll automatically highlight, indent, and tab
    Author: misrepresenting
]]


local inputBegan = import('inputBegan')
local inputChanged = import('inputChanged')
local textChanged = import('textChanged')

return function(object)
    connect(object.InputBegan, function(input)
        inputBegan(input, object)
    end)
    connect(object.InputChanged, function(input)
        inputChanged(input, object)
    end)
    connect(object:GetPropertyChangedSignal('Text'), function()
        textChanged(object)
    end)
end