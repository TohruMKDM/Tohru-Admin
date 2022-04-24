--[[
    Name: utils.lua
    Description: Methods that'll provide various utilities throughout the entire codebase.
    Author: Tohru
]]

local tweenService = game:GetService('TweenService')

local newTweenInfo = TweenInfo.new
local easingStyle, easingDirection = Enum.EasingStyle, Enum.EasingDirection

local utils = {}

utils.tween = function(object, style, direction, time, goal)
    local tweenObj = tweenService:Create(object, newTweenInfo(time, easingStyle[style], easingDirection[direction]), goal)
    tweenObj:Play()
    return tweenObj
end

utils.getTools = function(player, collectHoppers)
    local tools = {}
    if player.Character then
        for _, v in ipairs(player.Character:GetChildren()) do
            local class = v.ClassName
            if class == 'Tool' or (collectHoppers and class == 'HopperBin') then
                tools[#tools + 1] = v
            end
        end
    end
    if player.Backpack then
        for _, v in ipairs(player.Backpack:GetChildren()) do
            local class = v.ClassName
            if class == 'Tool' or (collectHoppers and class == 'HopperBin') then
                tools[#tools + 1] = v
            end
        end
    end
    return tools
end


return utils