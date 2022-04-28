--[[
    Name: gui/pages/adminsPage.lua
    Description: Program the admins page
    Author: misrepresenting
]]

local smoothScroll, singleSearch do
    local helpers = import('../helpers')
    smoothScroll, singleSearch = helpers.smoothScroll, singleSearch
end
local gui = import('storage').gui

local fromOffset = UDim2.fromOffset

local adminsPage = gui.MainDragFrame.Main.Pages.Admins
local adminsResults = adminsPage.Results
local searchBar = adminsPage.SearchBar

smoothScroll(adminsResults, 0.14)
adminsResults.CanvasSize = fromOffset(0, adminsResults.UIListLayout.AbsoluteContentSize.Y)

connect(searchBar.SearchFrame.Search:GetPropertyChangedSignal('Text'), function()
    local query = searchBar.SearchFrame.Search.Text
    for _, v in ipairs(adminsResults:GetChildren()) do
        if v.ClassName ~= 'UIListLayout' then
            singleSearch(v, v.Username, query)
        end
    end
    adminsResults.CanvasSize = fromOffset(0, adminsResults.UIListLayout.AbsoluteContentSize.Y)
end)

return adminsPage