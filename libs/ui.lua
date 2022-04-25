--[[
    Name: ui.lua
    Description: Some functions that will allow interaction with the GUI such as notifications
    Author: misrepresenting
]]

local helpers = import('gui/helpers')
local utils = import('utils')
local storage = import('storage')
import('gui')


local textService = game:GetService('TextService')
local players = game:GetService('Players')

local gui = storage.gui
local newUDim2, newVector2 = UDim2.new, Vector2.new
local newUDim, newInstance = UDim.new, Instance.new
local fromOffset = UDim2.fromOffset
local headShot, size420 = Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420
local notification, notificationBar = gui.Notification, gui.NotificationBar
local uiPages, toolTip = gui.MainDragFrame.Main.Pages, gui.ToolTip
local executor, joinLogs, settings = uiPages.Executor, uiPages.JoinLogs, uiPages.Settings.ScrollingFrame
local wrap = coroutine.wrap
local tWait = task.wait
local introGoals = {
    opened = {
        frameTransparency = {BackgroundTransparency = 0},
        frameSize = {Size = fromOffset(0, 0)}
    },
    closed = {
        frameTransparency = {BackgroundTransparency = 1},
        frameSize = {}
    },
    cornerRadius = {CornerRadius = newUDim(0, 0)}
}
local canvasGoal = {}
local rankMap = {
    [0] = 'Member',
    [1] = 'Moderator',
    [2] = 'Adminstrator',
    [3] = 'Owner'
}

local ui = {}

local getSize = function(object)
    return textService:GetTextSize(object.Text, object.TextSize, object.Font, newVector2(object.AbsoluteSize.X, 1000)).Y
end

local tweenDestroy = function(object)
    if object.Parent then
        helpers.tweenAllTransparent(object, 0.25).Completed:Wait()
        object:Destroy()
    end
end

local notifyCallback = function(object, time)
    helpers.tweenAllTransparentToObject(object, notification, 0.5).Completed:Wait()
    tWait(time or 5)
    tweenDestroy(object)
end

local notify = function(title, message, time)
    local clone = notification:Clone()
    if not message then
        title, message = 'Notification', title
    end
    clone.Title.Text = title
    clone.Message.Text = message
    clone.Size = fromOffset(clone.Size.X.Offset, getSize(clone.Message) + clone.Size.Y.Offset - clone.Message.TextSize)
    helpers.setAllTransparent(clone)
    helpers.onClick(clone.Close, 'TextColor3')
    clone.Visible = true
    clone.Parent = notificationBar
    wrap(notifyCallback)(clone, time)
    connect(clone.Close.MouseButton1Click, function()
        tweenDestroy(clone)
    end)
end
ui.notify = notify

local introCallback = function(object, frame, corner)
    if object.Visible then
        local goals = introGoals.opened
        frame.BackgroundTransparency = 1
        utils.tween(frame, 'Sine', 'Out', 0.25, goals.frameTransparency).Completed:Wait()
        object.Visible = false
        utils.tween(corner, 'Sine', 'Out', 0.25, introGoals.cornerRadius)
        utils.tween(frame, 'Sine', 'Out', 0.25, goals.frameSize).Completed:Wait()
        frame:Destroy()
    else
        local goals = introGoals.closed
        goals.frameSize.Size = fromOffset(object.AbsoluteSize.X, object.AbsoluteSize.Y)
        frame.Visible = true
        frame.Size = fromOffset(0, 0)
        corner.CornerRadius = newUDim(1, 0)
        utils.tween(corner, 'Sine', 'Out', 0.25, introGoals.cornerRadius)
        utils.tween(frame, 'Sine', 'Out', 0.25, goals.frameSize).Completed:Wait()
        object.Visible = true
        utils.tween(frame, 'Sine', 'Out', 0.25, goals.frameTransparency).Completed:Wait()
        frame:Destroy()
    end
end

local intro = function(object, async)
    local frame, corner = newInstance('Frame'), newInstance('UICorner')
    frame.Position = newUDim2(object.Position.X.Scale, object.Position.X.Offset + (object.AbsoluteSize.X / 2), object.Position.Y.Scale, object.Position.Y.Offset + (object.AbsoluteSize.Y /2))
    frame.Size = fromOffset(object.AbsoluteSize.X, object.AbsoluteSize.Y)
    frame.AnchorPoint = newVector2(0.5, 0.5)
    corner.CornerRadius = newUDim(0, 0)
    frame.BackgroundColor3 = object.BackgroundColor3
    frame.BorderSizePixel = 0
    frame.ZIndex = 1000
    frame.Parent = object.Parent
    if async then
        wrap(introCallback)(object, frame, corner)
        return
    end
    introCallback(object, frame, corner)
end
ui.intro = intro

local logMessage = function(username, message, time, target)
    local userId = players:GetUserIdFromNameAsync(username)
    local thumbnail = players:GetUserThumbnailAsync(userId, headShot, size420)
    local rank = utils.getRank(userId)
    local clone = target.Log:Clone()
    local autoScroll = false
    clone.Username.Text = username
    clone.MessageFrame.Message.text = message
    clone.Rank.Text = rankMap[rank]
    clone.Time.Text = time
    clone.Profile.Image = thumbnail
    clone.Visible = true
    clone.Size = newUDim2(1, clone.Size.X.Offset, 0, getSize(clone.MessageFrame.Message) + clone.Size.Y.Offset - clone.MessageFrame.Message.TextSize)
    autoScroll = (target.Results.UIListLayout.AbsoluteContentSize.Y - target._smoothInputFrame.CanvasPosition.Y) < 1
    clone.Parent = target.Results
    target.Results.CanvasSize = fromOffset(0, target.Results.UIListLayout.AbsoluteContentSize.Y)
    if autoScroll then
        canvasGoal.CanvasPosition = newVector2(0, target.Results.UIListLayout.AbsoluteContentSize.Y)
        utils.tween(target._smoothInputFrame, 'Quad', 'Out', 0.25, canvasGoal)
    end
end
ui.logMessage = logMessage

local logJoin = function(username, time, joined)
    local userId = players:GetUserIdFromNameAsync(username)
    local thumbnail = players:GetUserThumbnailAsync(id, headShot, size420)
    local rank = utils.getRank(userId)
    local clone = joinLogs.JoinLog:Clone()
    local autoScroll = false
    clone.Status.Text = joined and 'Has joined the server' or 'Has left the server'
    clone.Rank.Text = rankMap[rank]
    clone.Time.Text = time
    clone.Profile.Image = thumbnail
    clone.Visible = true
    autoScroll = (joinLogs.Results.UIListLayout.AbsoluteContentSize.Y - joinLogs._smoothInputFrame.CanvasPosition.Y) < 1
    clone.Parent = joinLogs.Results
    joinLogs.Results.CanvasSize = fromOffset(0, joinLogs.Results.UIListLayout.AbsoluteContentSize.Y)
    if autoScroll then
        canvasGoal.CanvasPosition = newVector2(0, joinLogs.Results.UIListLayout.AbsoluteContentSize.Y)
        utils.tween(target._smoothInputFrame, 'Quad', 'Out', 0.25, canvasGoal)
    end
end
ui.logJoin = logJoin

local unloadPlugin, loadPlugin
unloadPlugin = function(name)
    local clone = settings.Plugins.Plugin:Clone()
    clone.Title.Text = name
    helpers.onClick(clone.LoadPlugin, 'TextColor3')
    helpers.onClick(clone.ViewCode, 'ImageColor3')
    connect(clone.LoadPlugin.MouseButton1Click, function()
        clone:Destroy()
        loadPlugin(name)
    end)
    connect(clone.ViewCode.MouseButton1Click, function()

    end)
    clone.Visible = true
    clone.Parent = settings.Plugins.ScrollingFrame
end
ui.unloadPlugin = unloadPlugin

loadPlugin = function(name)
    local clone = settings.LoadedPlugins.Plugin:Clone()
    clone.Title.Text = name
    helpers.onClick(clone.UnloadPlugin, 'TextColor3')
    helpers.onClick(clone.ViewCode, 'ImageColor3')
end
ui.loadPlugin = loadPlugin


local newTab = function(name, text)
    local frame = executor.ExecutorFrame
    local codeClone = frame.CodeTab:Clone()
    local tabClone = frame.Tab:Clone()
    local delete
    tabClone.Text = name
    tabClone.Visible = true
    tabClone.Parent = frame.TabFrame
    codeClone.CodeInput.Text = text or ''
    codeClone.Visible = true
    codeClone.Parent = frame.Tabs
    helpers.onClick(tabClone, 'BackgroundColor3')
    connect(tabClone.MouseButton1Click, function()
        frame.Tabs.UIPageLayout:JumpTo(codeClone)
    end)
    connect(tabClone.MouseButton2Click, function()
        if tabClone.BackgroundTransparency < 1 and not delete then
            delete = toolTip:Clone()
            delete.Position = helpers.relativePosition(tabClone, mouse.X + 10, mouse.Y + 10)
            delete.Visible = true
            delete.Parent = tabClone
            helpers.onClick(delete, 'BackgroundColor3')
            connect(delete.MouseButton1Click, function()
                codeClone:Destroy()
                tabClone:Destroy()
                delete:Destroy()
            end)
        elseif delete then
            delete:Destroy()
            delete = nil
        end
    end)
end
ui.newTab = newTab

return ui