-- Utilities to aid with various different things

local tweenService = services.TweenService
local tweenInfo = TweenInfo.new
local easingStyle, easingDirection = Enum.EasingStyle, Enum.EasingDirection

local tween = function(obj, style, direction, time, goal)
    local tweenObj = tweenService:create(obj, tweenInfo(time, easingStyle[style], easingDirection[direction]), goal)
    tweenObj:Play()
    return tweenObj
end

local getRoot = function(player)
    local character = player.Character
    if not character then return end
    local root = character:FindFirstChild('HumanoidRootPart') or character:FindFirstChild('Torso') or character:FindFirstChild('UpperTorso') or character:FindFirstChild('Head')
    if not root then return end
    if root.Name == 'HumanoidRootPart' then
        local torso = character:FindFirstChild('Torso') or character:FindFirstChild('UpperTorso')
        if torso and (torso.Position - root.Position).Magnitude >= 1 then
            return Torso
        end
    end
    return root
end

local getHumanoid = function(player)
    local character = player.Character
    if not character then return end
    return character:FindFirstChildOfClass('Humanoid')
end

local isR15 = function(player)
    local humanoid = getHumanoid(player)
    return humanoid and humanoid.RigType == 0
end

local isReanimated = function(player)
    local character = player.Character
    if not character then return end
    local r15 = isR15(player)
    return not character:FindFirstChild(r15 and 'Root' or 'RootJoint', true)
end

local getTool = function(player)
    local character, backpack = player.Character, player.Backpack
    return character and character:FindFirstChildOfClass('Tool') or backpack and backpack:FindFirstChildOfClass('Tool')
end

local getTools = function(player)
    local character, backpack = player.Character, player.Backpack
    local tools = {}
    local children
    if character then
        children = character:GetChildren()
        for i = 1, #children do
            local child = children[i]
            if child.ClassName == 'Tool' then
                tools[#tools + 1] = child
            end
        end
    end
    if backpack then
        children = backpack:GetChildren()
        for i = 1, #children do
            local child = children[i]
            if child.ClassName == 'Tool' then
                tools[#tools + 1] = child
            end
        end
    end
    return tools
end

return {
    tween = tween,
    getRoot = getRoot,
    getHumanoid = getHumanoid,
    isR15 = isR15,
    isReanimated = isReanimated,
    getTool = getTool,
    getTools = getTools
}