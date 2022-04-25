--[[
    Name: ./init.lua
    Description: Load commands and setup events for the admin scripts.
    Author: Tohru
]]

local compat = import('compat')
local storage = import('storage')
local defaultSettings = import('settings')
local loadFailed = false

compat()

if isfile(import.root..'/settings.json') then
    local success, save = pcall(jsonDecode, readfile(import.root..'/settings.json'))
    local settings = {}
    if not success then
        for i, v in pairs(defaultSettings) do
            settings[i] = v
        end
        loadFailed = true
    else
        for i, v in pairs(defaultSettings) do
            local saved = save[i]
            if save ~= nil then
                settings[i] = saved
            else
                settings[i] = v
            end
        end
    end
    storage.settings = settings
else
    writefile(import.root..'/settings.json', jsonEncode(defaultSettings))
    local settings = {}
    for i, v in pairs(defaultSettings) do
        settings[i] = v
    end
    storage.settings = settings
end

local gui = import('gui')
local ui = import('ui')

if loadFailed then
    ui.notify('Savefile Error', 'Your save file was corrupted. It has been overwritten')
end