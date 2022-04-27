--[[
    Name: gui/syntaxHighlighter/textChanged/init.lua
    Description: Register functions that'll be called when the user inputs text
    Author: misrepresenting
]]

local counter = import('lineCounter')
local tabbing = import('tabbing')
local highlighter = import('highlighter')

return function(object)
    counter(object)
    tabbing(object)
    highlighter(object)
end