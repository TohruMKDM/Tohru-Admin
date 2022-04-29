--[[
    Name: gui/pages/chatLogsPage.lua
    Description: Program the chat logs page
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

local chatLogsPage = gui.MainDragFrame.Main.Pages.ChatLogs
local chatLogsResults = chatLogsPage.Results
local toggleChatLogs = chatLogsPage.ToggleChatLogs
local clearChatLogs = chatLogsPage.ClearChatLogs
local searchBar = chatLogsPage.SearchBar

for _, v in ipairs(players:GetPlayers()) do
    local name = v.Name
    connect(v.Chatted, function(message)
        if settings.chatLogs then
            logMessage(name, message, getTime(), chatLogsResults)
        end
    end)
end

smoothScroll(chatLogsResults, 0.14)
onClick(clearChatLogs, 'BackgroundColor3')

checkmark(toggleChatLogs, function(bool)
    settings.chatLogs = bool
end)

connect(searchBar.NameSearchFrame.Search:GetPropertyChangedSignal('Text'), function()
    local query = searchBar.NameSearchFrame.Search.Text
    for _, v in ipairs(chatLogsResults:GetChildren()) do
        if v.ClassName ~= 'UIListLayout' then
            singleSearch(v, v.Username, query)
        end
    end
    chatLogsResults.CanvasSize = fromOffset(0, chatLogsResults.UIListLayout.AbsoluteContentSize.Y)
end)

connect(searchBar.MessageSearchFrame.Search:GetPropertyChangedSignal('Text'), function()
    local query = searchBar.MessageSearchFrame.Search.Text
    for _, v in ipairs(chatLogsResults:GetChildren()) do
        if v.ClassName ~= 'UIListLayout' then
            singleSearch(v, v.MessageFrame.Message, query)
        end
    end
    chatLogsResults.CanvasSize = fromOffset(0, chatLogsResults.UIListLayout.AbsoluteContentSize.Y)
end)

connect(clearChatLogs.MouseButton1Click, function()
    clearObjects(chatLogsResults)
    chatLogsResults.CanvasSize = fromOffset(0, 0)
end)

connect(players.PlayerAdded, function(player)
    local name = player.Name
    connect(player.Chatted, function(message)
        if settings.chatLogs then
            logMessage(name, message, getTime(), chatLogsResults)
        end
    end)
end)

return chatLogsPage