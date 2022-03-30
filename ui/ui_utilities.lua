-- Utilities to aid in the UI building process.

local tween = import('utilities').tween
local connections = import('storage').connections

local uis = services.UserInputService
local coreGui = services.CoreGui
local mouse = services.Players.LocalPlayer:GetMouse()
local inputType, inputState = Enum.UserInputType, Enum.UserInputState
local newColor3, newUdim2 = Color3.new, UDim2.new
local clamp = math.clamp
local remove = table.remove
local wrap = coroutine.wrap

local blinkFn = function(obj, goal, color)
    local original = {[goal] = obj[goal]}
    local tweenObj = tween(obj, 'Sine', 'Out', .5, {[goal] = color})
    tweenObj.Completed:Wait()
    tween(obj, 'Sine', 'Out', .5, original)
end

local relativePosition = function(obj, x, y)
    local pos = obj.AbsolutePosition
    return newUdim2(0, x - pos.X, 0, y - pos.Y)
end

local multColor3 = function(color, delta)
    return newColor3(clamp(color.R * delta, 0, 1), clamp(color.G * delta, 0, 1), clamp(color.B * delta, 0, 1))
end

local onClick = function(obj, goal)
    local hover = {[goal] = multColor3(obj[goal], .9)}
    local press = {[goal] = multColor3(obj[goal], 1.2)}
    local original = {[goal] = obj[goal]}
    connect(obj.MouseEnter, function()
        tween(obj, 'Sine', 'Out', .5, hover)
    end)
    connect(obj.MouseLeave, function()
        tween(obj, 'Sine', 'Out', .5, original)
    end)
    connect(obj.MouseButton1Down, function()
        tween(obj, 'Sine', 'Out', .3, press)
    end)
    connect(obj.MouseButton1Up, function()
        tween(obj, 'Sine', 'Out', .4, hover)
    end)
end

local blink = function(obj, goal, color)
    wrap(blinkFn)(obj, goal, color)
end

local onHover = function(obj, goal)
    local hover = {[goal] = multColor3(obj[goal], .9)}
    local original = {[goal] = obj[goal]}
    connect(obj.MouseEnter, function()
        tween(obj, 'Sine', 'Out', .5, hover)
    end)
    connect(obj.MouseLeave, function()
        tween(obj, 'Sine', 'Out', .5, original)
    end)
end

local dragObj = function(obj)
    local toggle, dragInput, start, position
    connect(obj.InputBegan, function(input)
        local t = input.UserInputType
        if (t == inputType.MouseButton1 or t == inputType.Touch) and not uis:GetFocusedTextBox() then
            toggle = true
            start = input.Position
            position = obj.Position
        end
        local connection, pos
        connection, pos = connect(input.Changed, function()
            if input.UserInputState == inputState.End then
                toggle = false
                connection:Disconnect()
                remove(connections, pos)
            end
        end)
    end)
    connect(obj.InputChanged, function(input)
        local t = input.UserInputType
        if t == inputType.MouseMovement or t == inputType.Touch then
            dragInput = input
        end
    end)
    connect(uis.InputChanged, function(input)
        if toggle and input == dragInput then
            local delta = input.Position - start
            local x, y = position.X, position.Y
            tween(obj, 'Quad', 'Out', .25, {Position = newUdim2(x.Scale, x.Offset + delta.X, y.Scale, y.Offset + delta.Y)}) 
        end
    end)
end

local slider = function(obj, min, max, fn)
    local sliderObj = obj.Slider
    local bar = sliderObj.Bar
    local bound = sliderObj.AbsolutePosition.X
    local toggle = false
    connect(uis.InputBegan, function()
        local objects = uis:GetGuiObjectsAtPosition(mouse.X, mouse.Y)
        for i = 1, #objects do
            if objects[i] == Bar then
                toggle = true
                return
            end
        end
    end)
    connect(uis.InputEnded, function()
        toggle = false
    end)
    connect(mouse.Move, function()
        if not toggle then
            return
        end
        local position = clamp(mouse.X - Slider.AbsolutePosition.X, 0, bound)
        local x, y = bar.Position.X, bar.Position.Y
        local tweenObj = tween(bar, 'Linear', 'Out', .15, {Position = newUdim2(x.Scale, position, y.Scale, y.Offset)})
        tweenObj.Completed:Wait()
        fn(min + (max - min) * position / bound)
    end)
    onClick(bar, 'BackgroundColor3')
end

local colorPicker = function(obj, fn)
    local hue, saturation, brightness = obj.Hue, obj.Saturation, obj.Value
    local hueValue, saturationValue, brightnessValue = 0, 0, 0
end

return {
    tween = tween,
    multColor3 = multColor3,
    onClick = onClick,
    blink = blink,
    onHover = onHover,
    dragObj = dragObj,
    slider = slider
}