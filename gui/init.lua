--[[
    Name: gui/init.lua
    Description: Load and program the GUI
    Author: misrepresenting
]]

local helpers = import('helpers')
local storage = import('storage')
local utils = import('utils')
local gui = helpers.parentGui(game:GetObjects('rbxassetid://6354865289')[1])
storage.gui = gui
local ui = import('ui')

local marketPlace = game:GetService('MarketplaceService')
local runService = game:GetService('RunService')
local players = game:GetService('Players')
local userInputService = game:GetService('UserInputService')
local workSpace = game:GetService('Workspace')

local newUdim2 = UDim2.new
local fromOffset, fromRGB = UDim2.fromOffset, Color3.fromRGB
local thumbnail, headShot = Enum.ThumbnailType.AvatarThumbnail,Enum.ThumbnailType.HeadShot
local size420 = Enum.ThumbnailSize.Size420x420
local commandBar, main = gui.CommandBar, gui.MainDragFrame.Main
local title, menu, pages = main.Title, main.Menu, main.Pages
local settings = storage.settings
local defer = task.defer
local match, format = string.match, string.format
local wrap = coroutine.wrap
local floor = math.floor
local barGoal = {}
local barOpen = false

local commandBarClone = commandBar:Clone()
gui.Notification.Visible = false
commandBar.Visible = false
main.Visible = false
commandBar.Position = newUdim2(0.5, -100, 1, 5)
helpers.setAllTransparent(commandBar)
helpers.dragGui(main)

local colorize = function(message)
    local textColor = settings.textColor
    return format('<font color = "rgb(%s, %s, %s)">%s</font>', textColor[1], textColor[2], textColor[3], message)
end

local barCallback = function(inputBox)
    inputBox:CaptureFocus()
    inputBox.Text = ''
end
connect(userInputService.InputBegan, function(input, gpe)
    if gpe then
        return
    end
    if input.KeyCode == settings.prefix then
        barOpen = not barOpen
        local transparencyTween = barOpen and helpers.tweenAllTransparentToObject or helpers.tweenAllTransparent
        transparencyTween(commandBar, 0.5, commandBarClone)
        if barOpen then
            commandBar.Visible = true
            barGoal.Position = #utils.getTools(localPlayer) == 0 and newUdim2(0.5, -100, 1, -45) or newUdim2(0.5, -100, 1, -110)
            utils.tween(commandBar, 'Quint', 'Out', 0.5, barGoal)
            defer(barCallback, commandBar.Input)
        else
            barGoal.Position = newUdim2(0.5, -100, 1, 5)
            utils.tween(commandBar, 'Quint', 'Out', 0.5, barGoal).Completed:Wait()
            commandBar.Visible = false
        end
    end
end)

connect(commandBar.Input.FocusLost, function()
    barOpen = false
    barGoal.Position = newUdim2(0.5, -100, 1, 5)
    helpers.tweenAllTransparent(commandBar, 0.5)
    utils.tween(commandBar, 'Quint', 'Out', 0.5, barGoal)
end)

local mainDebounce = false
helpers.onClick(title.Close, 'TextColor3')
connect(title.Close.MouseButton1Click, function()
    if not mainDebounce then
        mainDebounce = true
        ui.intro(main)
        mainDebounce = false
    end
end)

do
    local pageLayout = pages.UIPageLayout
    local imageGoal, textGoal = {}, {}
    local tweenPage = function(page, transparency)
        page = menu[page.Name]
        imageGoal.ImageTransparency = transparency
        textGoal.TextTransparency = transparency
        utils.tween(page.Image, 'Sine', 'Out', 0.25, imageGoal)
        utils.tween(page.PageName, 'Sine', 'Out', 0.25, textGoal)
    end
    for _, v in ipairs(menu:GetChildren()) do
        if v.ClassName ~= 'UIListLayout' then
            connect(v.MouseButton1Click, function()
                local page = pages[v.Name]
                local currentPage = pageLayout.CurrentPage
                pageLayout:JumpTo(page)
                if menu:FindFirstChild(currentPage.Name) then
                    tweenPage(currentPage, 0.5)
                end
                tweenPage(page, 0)
            end)
            connect(v.MouseEnter, function()
                local page = pages[v.Name]
                if pageLayout.CurrentPage ~= page then
                    tweenPage(page, 0.3)
                end
            end)
            connect(v.MouseLeave, function()
                local page = pages[v.name]
                if pageLayout.CurrentPage ~= page then
                    tweenPage(page, 0.5)
                end
            end)
        end
    end
    connect(title.TitleButton.MouseButton1Click, function()
        local currentPage = pageLayout.CurrentPage
        if menu:FindFirstChild(currentPage.Name) then
            tweenPage(currentPage, 0.5)
        end
        pageLayout:JumpTo(pages.Menu)
    end)
end

import('pages/players')
import('pages/server')

return gui