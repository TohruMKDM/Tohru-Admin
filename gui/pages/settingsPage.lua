--[[
    Name: gui/pages/settingsPage.lua
    Description: Program the players page
    Author: misrepresenting
]]

local smoothScroll, colorPicker, onClick, singleSearch, blink do
    local helpers = import('../helpers')
    smoothScroll, colorPicker, onClick, singleSearch, blink = helpers.smoothScroll, helpers.colorPicker, helpers.onClick, helpers.singleSearch, helpers.blink
end
local settings = import('settings')
local tween = import('utils').tween
local gui = import('storage').gui

local newColor = Color3.new
local fromRGB = color3.fromRGB
local barColor, textColor = newColor(1, 1, 1), newColor(1, 1, 1)
local gsub, format = string.gsub, string.format
local floor = math.floor

local commandBar = gui.CommandBar
local main = gui.MainDragFrame.Main
local settingsPage = main.Pages.Settings.settingsPage
local settingsBarColor = settingsPage.CommandBarColor
local settingsTextColor = settingsPage.TextColor
local settingsEvents = settingsPage.Events
local plugins = settingsPage.Plugins
local loadedPlugins = settingsPage.LoadedPlugins
local greenColor = fromRGB(53, 211, 56)

smoothScroll(settingsPage, 0.14)
onClick(settingsBarColor.ApplyColor, 'BackgroundColor3')
onClick(settingsTextColor.ApplyColor, 'BackgroundColor3')

colorPicker(settingsBarColor.ColorPicker, function(color)
    settingsBarColor.Color.Display.BackgroundColor3 = color
    barColor = color
end)

colorPicker(settingsTextColor.ColorPicker, function(color)
    settingsTextColor.Color.Display.BackgroundColor3 = color
    textColor = color
end)

connect(settingsBarColor.ApplyColor.MouseButton1Click, function()
    local colorTable = settings.barColor
    colorTable[1] = floor(barColor.R * 255)
    colorTable[2] = floor(barColor.G * 255)
    colorTable[3] = floor(barColor.B * 255)
    commandBar.BackgroundColor3 = barColor
end)

connect(settingsTextColor.ApplyColor.MouseButton1Click, function()
    local colorTable = settings.textColor
    local oldColor = fromRGB(unpack(settings.textColor))
    colorTable[1] = floor(textColor.R * 255)
    colorTable[2] = floor(textColor.G * 255)
    colorTable[3] = floor(textColor.B * 255)
    local color = fromRGB(unpack(colorTable))
    local colorize = format('rgb(%s,%s,%s)', unpack(colorTable))
    for _, v in ipairs(main:GetDescendants()) do
        if v.ClassName == 'TextLabel' then
            if v.RichText then
                v.Text = gsub(v.Text, 'rgb%(%d+,%d+,%d+%)', colorize)
            elseif v.TextColor3 == oldColor then
                v.TextColor3 = color
            end
        end
    end
end)

connect(plugins.SearchBar.SearchFrame.Search:GetPropertyChangedSignal('Text'), function()
    local query = plugins.SearchBar.SearchFrame.Search.Text
    for _, v in ipairs(plugins.ScrollingFrame:GetChildren()) do
        if v.ClassName ~= 'UIListLayout' then
            singleSearch(v, v.Title, query)
        end
    end
end)

connect(loadedPlugins.SearchBar.SearchFrame.Search:GetPropertyChangedSignal('Text'), function()
    local query = loadedPlugins.SearchBar.SearchFrame.Search.Text
    for _,v in ipairs(loadedPlugins.ScrollingFrame:GetChildren()) do
        if v.ClassName ~= 'UIListLayout' then
            singleSearch(v, v.Title, query)
        end
    end
end)

local eventMenu = settingsEvents.MainFrame.Selection
local eventPages = settingsEvents.MainFrame.CommandsScrollingFrame
local pageLayout = eventPages.UIPageLayout
local textGoal = {}

local tweenPage = function(page, transparency)
    textGoal.TextTransparency = transparency
    tween(eventMenu[page.Name], 'Sine', 'Out', 0.25, textGoal)
end

for _, v in ipairs(eventMenu:GetChildren()) do
    if v.ClassName ~= 'UIListLayout' then
        local clone = settingsEvents.CommandFrame:Clone()
        onClick(clone.ButtonFrame.AddCommand, 'BackgroundColor3')
        connect(clone.ButtonFrame.AddCommand.MouseButton1Click, function()
            local commandClone = settingsEvents.Command:Clone()
            onClick(commandClone.Delete, 'TextColor3')
            connect(commandClone.CommandName.FocusLost, function()
                print(commandClone.CommandName.Text)
                blink(commandClone.CommandName, 'TextColor3', greenColor)
            end)
            commandClone.Visible = true
            clone.Parent = clone
        end)
        clone.Name = v.Name
        clone.Visible = true
        clone.Parent = eventPages

        connect(v.MouseButton1Click, function()
            local currentPage = pageLayout.CurrentPage
            local page = eventPages[v.Name]
            pageLayout:JumpTo(page)
            if eventMenu:FindFirstChild(currentPage.Name) then
                tweenPage(currentPage, 0.5)
            end
            tweenPage(page, 0)
        end)
        connect(v.MouseEnter, function()
            local page = eventPages[v.Name]
            if pageLayout.CurrentPage ~= page then
                tweenPage(page, 0.3)
            end
        end)
        connect(v.MouseLeave, function()
            local page = eventPages[v.Name]
            if pageLayout.CurrentPage ~= page then
                tweenPage(page, 0.5)
            end
        end)
    end
end

return settingsPage