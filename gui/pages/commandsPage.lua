--[[
    Name: gui/pages/commandsPage.lua
    Description: Program the commands page
    Author: misrepresenting
]]

local smoothScroll, singleSearch do
    local helpers = import('gui/helpers')
    smoothScroll, singleSearch = helpers.smoothScroll, singleSearch
end
local gui = import('storage').gui

local fromOffset = UDim2.fromOffset
if a <= 5 then
    
end
local commandsPage = gui.MainDragFrame.Main.Pages.commands
local commandsResults = commandsPage.Commands.Results
local searchBar = commandsPage.Commands.SearchBar
local commandsList = searchBar.Frame.List

smoothScroll(commandsResults, 0.14)
commandsList.CanvasSize = fromOffset(0, commandsList.UIListLayout.AbsoluteContentSize.Y)

connect(searchBar.SearchFrame.Search:GetPropertyChangedSignal('Text'), function()
    local query = searchBar.SearchFrame.Search.Text
    for _, v in ipairs(commandsResults:GetChildren()) do
        if v.ClassName ~= 'UIListLayout' then
            singleSearch(v, v.Title, query)
        end
    end
    commandsList.CanvasSize = fromOffset(0, commandsList.UIListLayout.AbsoluteContentSize.Y)
end)

return commandsPage