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
local players = game:GetService('players')
local userInputService = game:GetService('UserInputService')

local newUdim2 = UDim2.new
local commandBar, main = gui.CommandBar, gui.MainDragFrame.Main
local title, uiPages = main.Title, main.Pages
local config = storage.config
local defer = task.defer
local barGoal = {}
local barOpen = false

local commandBarClone = commandBar:Clone()
gui.Notification.Visible = false
commandBar.Visible = false
commandBar.Position = newUdim2(0.5, -100, 1, 5)
helpers.setAllTransparent(commandBar)
helpers.dragGui(main)
main.Visible = false

local barCallback = function(inputBox)
    inputBox:CaptureFocus()
    inputBox.Text = ''
end
connect(userInputService.InputBegan, function(input, gpe)
    if gpe then
        return
    end
    if input.KeyCode == config.Prefix then
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