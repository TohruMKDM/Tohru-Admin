--[[
    Name: gui/init.lua
    Description: Load and program the GUI
    Author: misrepresenting
]]

local onClick, parentGui, dragGui, setAllTransparent, tweenAllTransparentToObject, tweenAllTransparent do
    local helpers = import('helpers')
    onClick, parentGui, dragGui, setAllTransparent, tweenAllTransparentToObject, tweenAllTransparent = helpers.onClick, helpers.parentGui, helpers.dragGui, helpers.setAllTransparent, helpers.tweenAllTransparentToObject, helpers.tweenAllTransparent
end
local settings, gui do
    local storage = import('storage')
    settings, gui = storage.settings, storage.gui
end
local intro = import('ui').intro
local tween, getTools do
    local utils = import('utils')
    tween, getTools = utils.tween, utils.getTools
end

local userInputService = game:GetService('UserInputService')

local newUDim2 = UDim2.new
local defer = task.defer
local barGoals = {
    close = {Position = newUDim2(0.5, -100, 1, 5)},
    openTools = {Position = newUDim2(0.5, -100, 1, -110)},
    open = {Position = newUDim2(0.5,-100, 1, -45)}
}
local textGoal, imageGoal = {}, {}
local barOpen = false
local debounce = false

local commandBar, main = gui.CommandBar, gui.MainDragFrame.Main
local title, menu, pages = main.Title,main.Menu, main.Pages
local pageLayout = pages.UIPageLayout
local barClone = commandBar:Clone()

commandBar.Position = barGoals.close.Position
gui.Notification.Visible = false
commandBar.Visible = false
main.Visible = false

local barCallback = function(object)
    object:CaptureFocus()
    object.Text = ''
end

local tweenPage = function(page, transparency)
    page = menu[page.Name]
    imageGoal.ImageTransparency = transparency
    textGoal.TextTransparency = transparency
    tween(page.Image, 'Sine', 'Out', 0.25, imageGoal)
    tween(page.PageName, 'Sine', 'Out', 0.25, textGoal)
end

setAllTransparent(commandBar)
dragGui(main)
parentGui(gui)
onClick(title.Close, 'TextColor3')
if settings.uiOpen then
    intro(main, true)
end

connect(userInputService.InputBegan, function(input, gpe)
    if gpe then
        return
    end
    if input.KeyCode == settings.prefix then
        barOpen = not barOpen
        local transparencyTween = barOpen and tweenAllTransparentToObject or tweenAllTransparent
        transparencyTween(commandBar, 0.5, barClone)
        if barOpen then
            commandBar.Visible = true
            local goal = getTools(localPlayer) == 0 and barGoals.open or barGoals.openTools
            tween(commandBar, 'Quint', 'Out', 0.5, goal)
            defer(barCallback, commandBar.ScrollingFrame.Input)
        else
            tween(commandBar, 'Quint', 'Out', 0.5, barGoals.close).Completed:Wait()
            commandBar.Visible = false
        end
    end
end)

connect(commandBar.ScrollingFrame.Input.FocusLost, function()
    barOpen = false
    tweenAllTransparent(commandBar, 0.5)
    tween(commandBar, 'Quint', 'Out', 0.5, barGoals.close)
end)

connect(title.Close.MouseButton1Click, function()
    if not debounce then
        debounce = true
        intro(main)
        debounce = false
    end
end)

connect(title.TitleButton.MouseButton1Click, function()
    local currentPage = pageLayout.CurrentPage
    if menu:FindFirstChild(currentPage.Name) then
        tweenPage(currentPage, 0.5)
    end
    pageLayout:JumpTo(pages.Menu)
end)

for _, v in ipairs(menu:GetChildren()) do
    if v.ClassName ~= 'UIListLayout' then
        connect(v.MouseButton1Click, function()
            local page = pages[v.Name]
            local currentPage = pageLayout.CurrentPage
            if menu:FindFirstChild(currentPage) then
                tweenPage(currentPage, 0.5)
            end
            pageLayout:JumpTo(page)
            tweenPage(page, 0)
        end)
        connect(v.MouseEnter, function()
            local page = pages[v.Name]
            if pageLayout.CurrentPage ~= page then
                tweenPage(page, 0.3)
            end
        end)
        connect(v.MouseLeave, function()
            local page = pages[v.Name]
            if pageLayout.CurrentPage ~= page then
                tweenPage(page, 0.5)
            end
        end)
    end
end

return import('pages')