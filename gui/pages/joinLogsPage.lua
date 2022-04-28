--[[
    Name: gui/pages/joinLogsPage.lua
    Description: Program the join logs page
    Author: misrepresenting
]]

local onClick, smoothScroll, singleSearch, checkmark, clearObjects do
    local helpers = import('../helpers')
    onClick, smoothScroll, singleSearch, checkmark, clearObjects = helpers.onClick, helpers.smoothScroll, helpers.singleSearch, helpers.checkmark, helpers.clearObjects
end
local gui, settings do
    local storage = import('storage')
    gui, settings = storage.gui, storage.settings
end
local logJoin = import('ui').logJoin
local getTime = import('utils').getTime

local players = game:GetService('Players')

local fromOffset = UDim2.fromOffset

local joinLogsPage = gui.MainDragFrame.Main.Pages.JoinLogs
local joinLogsResults = joinLogsPage.Results
local toggleJoinLogs = joinLogsPage.ToggleJoinLogs
local clearJoinLogs = joinLogsPage.ClearJoinLogs
local searchBar = joinLogsPage.SearchBar

smoothScroll(joinLogsResults, 0.14)
onClick(clearJoinLogs, 'BackgroundColor3')

checkmark(toggleJoinLogs, function(bool)
    settings.joinLogs = bool
end)

connect(searchBar.SearchFrame.Search:GetPropertyChangedSignal('Text'), function()
    local query = searchBar.SearchFrame.Search.Text
    for _, v in ipairs(joinLogsResults:GetChildren()) do
        if v.ClassName ~= 'UILIstLayout' then
            singleSearch(v, v.Username, query)
        end
    end
    joinLogsResults.CanvasSize = fromOffset(0, joinLogsResults.UIListLayout.AbsoluteContentSize.Y)
end)

connect(clearJoinLogs.MouseButton1Click, function()
    clearJoinLogs(joinLogsResults)
    joinLogsResults.CanvasSize = fromOffset(0, 0)
end)

connect(players.PlayerAdded, function(player)
    if settings.joinLogs then
        logJoin(player.Name, getTime(), true)
    end
end)

connect(players.PlayerRemoving, function(player)
    if settings.joinLogs then
        logJoin(player.Name, getTime(), false)
    end
end)

return joinLogsPage

