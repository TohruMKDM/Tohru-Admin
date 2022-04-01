-- Utilities to aid in the UI building process.

local tween = import('utilities').tween
local connections = import('storage').connections

local uis = services.UserInputService
local mouse = services.Players.LocalPlayer:GetMouse()
local stepped = services.RunService.Stepped
local newColor3, newUdim2, newUdim, newInstance, newVector2 = Color3.new, UDim2.new, UDim.new, Instance.new, Vector2.new
local fromHSV, toHSV, fromOffset = Color3.fromHSv, Color3.toHSV, UDim2.fromOffset
local newSequence = ColorSequence.new
local find = string.find
local clamp = math.clamp
local remove = table.remove
local wrap = coroutine.wrap

local props = {'CanvasSize', 'Position', 'Rotation', 'ScrollingDirection', 'ScrollBarThickness', 'BorderSizePixel', 'ElasticBehavior', 'SizeConstraint', 'ZIndex', 'BorderColor3', 'Size', 'AnchorPoint', 'Visible'}

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
        if (t == 0 or t == 7) and not uis:GetFocusedTextBox() then
            toggle = true
            start = input.Position
            position = obj.Position
        end
        local connection, pos
        connection, pos = connect(input.Changed, function()
            if input.UserInputState == 2 then
                toggle = false
                connection:Disconnect()
                remove(connections, pos)
            end
        end)
    end)
    connect(obj.InputChanged, function(input)
        local t = input.UserInputType
        if t == 4 or t == 7 then
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
    local update = function(percentage)
        if percentage then
            local points = hue.Slider.UIGradient.Color.Keypoints
            for i = 1, #points - 1 do
                local point1, point2 = points[i], points[i + 1]
                if point1.Time <= percentage and point2.Time >= percentage then
                    hueValue = toHSV(point1.Value:Lerp(point2.Value, percentage - point1.Time / point2.Time - point1.Time))
                end
            end
        end
        fn(fromHSV(hueValue, saturationValue, 1 - brightnessValue))
    end
    slider(hue, 0, 1, function(value)
        update(value)
        saturation.Slider.UIGradient.Color = newSequence(fromHSV(hueValue, 0, 1 - brightnessValue), fromHSV(hueValue, 1, 1))
        brightness.Slider.UIGradient.Color = newSequence(fromHSV(hueValue, saturationValue, 1), newColor3(0, 0, 0))
    end)
    slider(saturation, 0, 1, function(value)
        saturationValue = value
        update()
        brightness.Slider.UIGradient.Color = newSequence(fromHSV(hueValue, saturationValue, 1), newColor3(0, 0, 0))
    end)
    slider(brightness, 0, 1, function(value)
        brightnessValue = value
        update()
        saturation.Slider.UIGradient.Color = newSequence(fromHSV(hueValue, 0, 1 - brightnessValue), fromHSV(hueValue, 1, 1))
    end)
end

local smoothScroll = function(obj, factor)
    local inputFrame = obj:Clone()
    inputFrame.Name = obj.Name..'_smoothInputFrame'
    inputFrame:ClearAllChildren()
    inputFrame.BackgroundTransparency = 1
    inputFrame.ScrollBarImageTransparency = 1
    inputFrame.ZIndex = obj.ZIndex + 1
    inputFrame.ScrollingENabled = true
    inputFrame.Parent = obj.Parent
    obj.ScrollingEnabled = false
    for i = 1, #props do
        local prop = props[i]
        connect(obj:GetPropertyChangedSignal(prop), function()
            inputFrame[prop] = prop == 'ZIndex' and obj[prop] + 1 or obj[prop]
        end)
    end
    connect(stepped, function()
        obj.CanvasPosition = (inputFrame.CanvasPosition - obj.CanvasPosition) * factor + obj.CanvasPosition
    end)
end

local tweenToObject = function(obj, time, beforeObj)
    local descendants, oldDescendants
    local tweenObj = tween(obj, 'Sine', 'Out', time, {BackgroundTransparency = beforeObj.BackgroundTransparency})
    for i = 1, descendants do
        local descendant, oldDescendant = descendants[i], oldDescendants[i]
        if descendant.ClassName ~= 'UIListLayout' then
            local goal = {BackgroundTransparency = oldDescendant.BackgroundTransparency}
            if find(descendant.ClassName, 'Text') then
                goal.TextTransparency = oldDescendant.TextTransparency
                goal.TextStrokeTransparency = oldDescendant.TextStrokeTransparency
            elseif find(descendant.ClassName, 'Image') then
                goal.ImageTransparency = oldDescendant.ImageTransparency
            elseif descendant.ClassName == 'ClassName' then
                goal.ScrollBarImageTransparency = oldDescendant.ScrollBarImageTransparency
            end
            tween(descendant, 'Sine', 'Out', time, goal)
        end
    end
    return tweenObj
end

local makeTransparent = function(obj)
    local descendants = obj:GetDescendants()
    obj.BackgroundTransparency = 1
    for i = 1, #descendants do
        local descendant = descendants[i]
        if descendant.ClassName ~= 'UIListLayout' and descendant.ClassName ~= 'UICorner' then
            if find(descendant.ClassName, 'Text') then
                descendant.TextTransparency = 1
            elseif find(descendant.ClassName, 'Image') then
                descendant.ImageTransparency = 1
            elseif descendant.ClassName == 'ScrollingFrame' then
                descendant.ScrollBarImageTransparency = 1
            end
            descendant.BackgroundTransparency = 1
        end
    end
end

local clear = function(obj)
    local children = obj:getChildren()
    for i = 1, #children do
        local child = children[i]
        if child.ClassName ~= 'UIListLayout' and child.ClassName ~= 'UIGridLyout' then
            child:Destroy()
        end
    end
end

local intro = function(obj)
    local frame, corner = newInstance('Frame'), newInstance('UICorner')
    frame.ZIndex = 1000
    frame.Size = fromOffset(obj.AbsoluteSize.X, obj.AbsoluteSize.Y)
    frame.AnchorPoint = newVector2(.5, .5)
    frame.Position = newUdim2(obj.Position.X.Scale, obj.Position.X.Offset + (obj.AbsoluteSize.X / 2), obj.Position.Y.Scale, obj.Position.Y.Offset + (obj.AbsoluteSize.Y / 2))
    frame.BackgroundColor3 = obj.BackgroundColor3
    frame.BorderSizePixel = 0
    corner.CornerRadius = newUdim(0, 0)
    corner.Parent = frame
    frame.Parent = obj.Parent
    if obj.Visible then
        frame.BackgroundTransparency = 1
        local tweenObj = tween(frame, 'Sine', 'Out', .25, {BackgroundTransparency = 0})
        tweenObj.Completed:Wait()
        obj.Visible = false
        tweenObj = tween(frame, 'Sine', 'Out', .25, {Size = fromOffset(0, 0)})
        tween(corner, 'Sine', 'Out', .25, {CornerRadius = newUdim(1, 0)})
        tweenObj.Completed:Wait()
    else
        frame.Visible = true
        frame.Size = fromOffset(0, 0)
        corner.CornerRadius = newUdim(1, 0)
        local tweenObj = tween(frame, 'Sine', 'Out', .25, {Size = fromOffset(obj.AbsoluteSize.X, obj.AbsoluteSize.Y)})
        tween(corner, 'Sine', 'Out', .25, {CornerRadius = newUdim(0, 0)})
        tweenObj.Completed:Wait()
        obj.Visible = true
        tweenObj = tween(frame, 'Sine', 'Out', .25, {BackgroundTransparency = 1})
        tweenObj.Completed:Wait()
    end
    frame:Destroy()
end

local checkmark = function(obj, fn)
    local button = obj.checkmark
    local toggle
    onClick(button, 'BackgroundColor3')
    connect(button.MouseButton1Click, function()
        toggle = not toggle
        button.Text = toggle and '✓' or ''
        fn(toggle)
    end)
end

return {
    relativePosition = relativePosition,
    multColor3 = multColor3,
    onClick = onClick,
    blink = blink,
    onHover = onHover,
    dragObj = dragObj,
    slider = slider,
    colorPicker =colorPicker,
    smoothScroll = smoothScroll,
    tweenToObject = tweenToObject,
    makeTransparent = makeTransparent,
    clear = clear,
    intro = intro,
    checkmark = checkmark
}