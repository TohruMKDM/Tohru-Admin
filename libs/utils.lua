--[[
    Name: utils.lua
    Description: Methods that'll provide various utilities throughout the entire codebase.
    Author: Tohru
]]

local storage = import('storage')

local tweenService = game:GetService('TweenService')
local players = game:GetService('Players')

local newTweenInfo = TweenInfo.new
local easingStyle, easingDirection = Enum.EasingStyle, Enum.EasingDirection
local headShot, size420 = Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420
local r15 = Enum.HumanoidRigType.R15
local settings = storage.settings
local defer = task.defer
local date = os.date
local format = string.format
local weak = {__mode = 'k'}
local thumbnails, userIds = setmetatable({}, weak), setmetatable({}, weak)

local utils = {}

local tween = function(object, style, direction, time, goal)
    local tweenObj = tweenService:Create(object, newTweenInfo(time, easingStyle[style], easingDirection[direction]), goal)
    tweenObj:Play()
    return tweenObj
end
utils.tween = tween

local killAdmin = function()
    local wayPoints = storage.wayPoints
    local gui = storage.gui
    if wayPoints then
        for _, v in pairs(wayPoints) do
            if v.Parent then
                v:Destroy()
            end
        end
        storage.wayPoints = nil
    end
    if gui and gui.Parent then
        defer(function()
            local intro = import('ui').intro
            local tweenAllTransparent = import('gui/helpers').tweenAllTransparent
            for _, v in ipairs(gui.NotificationBar:GetChildren()) do
                if v.ClassName ~= 'UIListLayout' then
                    tweenAllTransparent(v, 0.5)
                end
            end
            intro(gui.MainDragFrame.Main)
            gui:Destroy()
            storage.gui = nil
        end)
    end
    defer(function()
        local handler = import('')
        if storage.flying then
            handler('unfly')
        end
    end)
end
utils.killAdmin = killAdmin

local getId = function(name)
    local cache = userIds[name]
    if cache then
        return cache
    end
    local player = players:FindFirstChild(name)
    if player then
        userIds[name] = player.UserId
        return userIds[name]
    end
    local success, id = pcall(players.GetUserIdFromNameAsync, players, name)
    id = success and id or nil
    userIds[name] = id
    return id
end
utils.getId = getId

local getRank = function(id)
    if id == localPlayer.UserId then
        return 3
    end
    return storage.staff[id] or 0
end
utils.getRank = getRank

local getThumbnail = function(id)
    local cache = thumbnails[id]
    if cache then
        return cache
    end
    local success, thumbnail = pcall(players.GetUserThumbnailAsync, players, id, headShot, size420)
    thumbnail = success and thumbnail or nil
    thumbnails[id] = thumbnail
    return thumbnail
end
utils.getThumbnail = getThumbnail

local getTime = function(time)
    time = date('*t', time)
    return format("%02d:%02d %s", ((time.hour % 24) - 1) % 12 + 1, time.min, time.hour > 11 and "PM" or "AM")
end
utils.getTime = getTime

local getTools = function(player, collectHoppers)
    local tools = {}
    local character = player.Character
    local backpack = player.Backpack
    if character then
        for _, v in ipairs(character:GetChildren()) do
            local class = v.ClassName
            if class == 'Tool' or (collectHoppers and class == 'HopperBin') then
                tools[#tools + 1] = v
            end
        end
    end
    if backpack then
        for _, v in ipairs(backpack:GetChildren()) do
            local class = v.ClassName
            if class == 'Tool' or (collectHoppers and class == 'HopperBin') then
                tools[#tools + 1] = v
            end
        end
    end
    return tools
end
utils.getTools = getTools

local getTool = function(player)
    local character = player.Character
    local backpack = player.Backpack
    return character and character:FindFirstChildOfClass('Tool') or backpack:FindFirstChildOfClass('Tool')
end
utils.getTool = getTool

local getRoot = function(player)
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass('Humanoid')
        if humanoid then
            local rootPart = humanoid.RootPart
            if rootPart.Name == 'HumanoidRootPart' then
                local torso
            end
        end
    end
end
utils.getRoot = getRoot

local isOwner = function(player)
end
utils.isOwner = isOwner



return utils