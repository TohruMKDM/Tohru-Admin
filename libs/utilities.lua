-- Utilities to aid with various different things

local tweenService = services.TweenService
local tweenInfo = TweenInfo.new
local easingStyle, easingDirection = Enum.EasingStyle, Enum.EasingDirection

local tween = function(obj, style, direction, time, goal)
    local tweenObj = tweenService:create(obj, tweenInfo(Time, easingStyle[style], easingDirection[direction]), goal)
    tweenObj:Play()
    return tweenObj
end


return {
    tween = tween
}