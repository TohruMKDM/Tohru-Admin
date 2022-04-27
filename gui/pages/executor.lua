--[[
    Name: gui/pages/executor.lua
    Description: Program the executor page
    Author: misrepresenting
]]

local notify, newTab do
    local ui = import('ui')
    notify, newTab = ui.notify, ui.newTab
end
local onClick = import('../helpers').onClick
local syntaxHighlighter = import('../syntaxHighlighter')
local gui = import('storage').gui

local traceback = debug.traceback

local executorPage = gui.MainDragFrame.Main.Pages.Executor
local executorClear = executorPage.Clear
local executorRun = executorPage.Execute
local executorFrame = executorPage.ExecutorFrame
local executorTabFrame = executorFrame.TabFrame
local executorTabs = executorFrame.Tabs
local executorAddTab = executorFrame.AddTab
local pageLayout = executorTabs.UIPageLayout

onClick(executorClear, 'BackgroundColor3')
onClick(executorRun, 'BackgroundColor3')
onClick(executorAddTab, 'BackgroundColor3')
onClick(executorTabFrame.Tab1, 'BackgroundColor3')
syntaxHighlighter(executorTabs.Tab1.CodeInput)

connect(executorTabFrame.Tab1.MouseButton1Click, function()
    pageLayout:JumpTo(executorTabs.Tab1)
end)

connect(executorAddTab.MouseButton1Click, function()
    local count = #executorTabFrame:GetChildren()
    if count <= 4 then
        newTab('Tab '..count)
    else
        notify('Executor', 'You have the maximum allowed tabs open')
    end
end)

connect(executorRun.MouseButton1Click, function()
    local current = pageLayout.CurrentPage
    local fn, err = loadstring(current.CodeInput.Text, '@'..current.Name)
    if not fn then
        warn(current.Name..': '..err)
        return
    end
    local success, fail = pcall(fn)
    if not success then
        warn(traceback(fail, 2))
    end
end)

connect(executorClear.MouseButton1Click, function()
    pageLayout.CurrentPage.CodeInput.Text = ''
end)

return executorPage