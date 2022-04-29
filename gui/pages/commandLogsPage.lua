--[[
    Name: gui/pages/commandLogsPage.lua
    Description: Program the command logs page
    Author: misrepresenting
]]

local onClick, smoothScroll, singleSearch, checkmark, clearObjects do
    local helpers = import('gui/helpers')
    onClick, smoothScroll, singleSearch, checkmark, clearObjects = helpers.onClick, helpers.smoothScroll, helpers.singleSearch, helpers.checkmark, helpers.clearObjects
end
local gui, settings do
    local storage = import('storage')
    gui, settings = storage.gui, storage.settings
end
local logMessage = import('ui').logMessage
local getTime = import('utils').getTime

local players = game:GetService('Players')

local fromOffset = UDim2.fromOffset
local find, char = string.find, string.char

local commandLogsPage = gui.MainDragFrame.Main.Pages.CommandLogs
local commandLogsResults = commandLogsPage.Results
local toggleCommandLogs = commandLogsPage.ToggleCommandLogs
local clearCommandLogs = commandLogsPage.ClearCommandLogs
local searchBar = commandLogsPage.SearchBar

for _, v in ipairs(players:GetPlayers()) do
    local name = v.Name
    connect(v.Chatted, function(message)
        if settings.commandLogs and find(message, char(settings.prefix.Value), 1, true) == 1 then
            logMessage(name, message, getTime(), commandLogsResults)
        end
    end)
end

smoothScroll(commandLogsResults, 0.14)
onClick(clearCommandLogs, 'BackgroundColor3')

checkmark(toggleCommandLogs, function(bool)
    settings.commandLogs = bool
end)

connect(searchBar.NameSearchFrame.Search:GetPropertyChangedSignal('Text'), function()
    local query = searchBar.NameSearchFrame.Search.Text
    for _, v in ipairs(commandLogsResults:GetChildren()) do
        if v.ClassName ~= 'UIListLayout' then
            singleSearch(v, v.Username, query)
        end
    end
    commandLogsResults.CanvasSize = fromOffset(0, commandLogsResults.UIListLayout.AbsoluteContentSize.Y)
end)

connect(searchBar.CommandSearchFrame.Search:GetPropertyChangedSignal('Text'), function()
    local query = searchBar.CommandSearchFrame.Search.Text
    for _, v in ipairs(commandLogsResults:GetChildren()) do
        if v.ClassName ~= 'UIListLayout' then
            singleSearch(v, v.MessageFrame.Message, query)
        end
    end
    commandLogsResults.CanvasSize = fromOffset(0, commandLogsResults.UIListLayout.AbsoluteContentSize.Y)
end)

connect(clearCommandLogs.MouseButton1Click, function()
    clearObjects(commandLogsResults)
    commandLogsResults.CanvasSize = fromOffset(0, 0)
end)

connect(players.PlayerAdded, function(player)
    local name = player.Name
    connect(player.Chatted, function(message)
        if settings.commandLogs and find(message, char(settings.prefix.Value), 1, true) == 1 then
            logMessage(name, message, getTime(), commandLogsResults)
        end
    end)
end)

return commandLogsPage