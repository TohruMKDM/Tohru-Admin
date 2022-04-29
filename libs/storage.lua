--[[
    Name: storage.lua
    Description: Basic storage module to allow sharing data throughout different files.
    Author: Tohru
]]

local storage = {
    commands = {},
    gui = game:GetObjects("rbxassetid://6354865289")[1]
}

return storage