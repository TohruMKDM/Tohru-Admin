--[[
    Name: helpers.lua
    Description: Some functions that'll help during the GUI building process.
    Author: misrepresenting
]]

local tween = import('utils').tween
local settings = import('storage').settings

local coreGui = game:GetService('CoreGui')
local userInputService = game:GetService('UserInputService')
local runService = game:GetService('RunService')

local newUDim2 = UDim2.new
local newColor3, newColorSequence = Color3.new, ColorSequence.new
local fromHSV = Color3.fromHSV
local toHSV = Color3.toHSV
local userInputState, userInputType = Enum.UserInputState, Enum.UserInputType
local lower, find, format = string.lower, string.find,string.format
local search = table.find
local clamp = math.clamp
local wrap = coroutine.wrap
local smoothProperties = {'CanvasSize', 'Position', 'Rotation', 'ScrollingDirection', 'ScrollBarThickness', 'BorderSizePixel', 'ElasticBehavior', 'SizeConstraint', 'ZIndex', 'BorderColor3', 'Size', 'AnchorPoint', 'Visible'}


local helpers = {}

local colorize = function(message)
    return format('<font color = "rgb(%s,%s,%s)">%s</font>', unpack(settings.textColor), message)
end
helpers.colorize = colorize

local relativePosition = function(object, x, y)
    local absolutePosition = object.AbsolutePosition
    return newUDim2(0, x - absolutePosition.X, 0, y - absolutePosition.Y)
end
helpers.relativePosition = relativePosition

local multColor3 = function(color, delta)
    return newColor3(clamp(color.R * delta, 0, 1), clamp(color.G * delta, 0, 1), clamp(color.B * delta, 0, 1))
end
helpers.multColor3 = multColor3

local onClick = function(object, property)
    local value = object[property]
    local hover = {[property] = multColor3(value, 0.9)}
    local press = {[property] = multColor3(value, 1.2)}
    local original = {[property] = value}
    connect(object.MouseEnter, function()
        tween(object, 'Sine', 'Out', 0.5, hover)
    end)
    connect(object.MouseLeave, function()
        tween(object, 'Sine', 'Out', 0.5, original)
    end)
    connect(object.MouseButton1Down, function()
        tween(object, 'Sine', 'Out', 0.3, press)
    end)
    connect(object.MouseButton1Up, function()
        tween(object, 'Sine', 'Out', 0.4, hover)
    end)
end
helpers.onClick = onClick

local blinkCallback = function(object, property, color)
    local original = object[property]
    tween(object, 'Sine', 'Out', 0.5, {[property] = color}).Completed:Wait()
    tween(object, 'Sine', 'Out', 0.5, {[property] = original}).Completed:Wait()
end

local blink = function(object, property, color, async)
    if async then
        wrap(blinkCallback)(object, property, color)
        return
    end
    blinkCallback(object, property, color)
end
helpers.blink = blink

local onHover = function(object, property)
    local value = object[property]
    local hover = {[property] = multColor3(value, 0.9)}
    local original = {[property] = value}
    connect(object.MouseEnter, function()
        tween(object, 'Sine', 'Out', 0.5, hover)
    end)
    connect(object.MouseLeave, function()
        tween(object, 'Sine', 'Out', 0.5, original)
    end)
end
helpers.onHover = onHover

local dragGui = function(object)
    local toggle = false
    local inputPosition, objPosition, inputObj
    local goal = {}
    connect(object.InputBegan, function(input)
        local inputType = input.UserInputType
        if (inputType == userInputType.MouseButton1 or inputType == userInputType.Touch) and not userInputService:GetFocusedTextBox() then
            toggle = true
            inputPosition = input.Position
            objPosition = object.Position
        end
        local connection
        connection  = connect(input.Changed, function()
            if input.UserInputState == userInputState.End then
                toggle = false
                inputPosition, objPosition = nil, nil
                removeConnection(connection)
            end
        end)
    end)
    connect(object.InputChanged, function(input)
        if not toggle then
            return
        end
        local inputType = input.UserInputType
        if inputType == userInputType.MouseMovement or inputType == userInputType.Touch then
            inputObj = input
        end
    end)
    connect(userInputService.InputChanged, function(input)
        if not toggle then
            return
        end
        if input == inputObj then
            local delta = input.Position - inputPosition
            goal.Position = newUDim2(objPosition.X.Scale, objPosition.X.Offset + delta.X, objPosition.Y.Scale, objPosition.Y.Offset + delta.Y)
            tween(object, 'Linear', 'Out', 0.25, goal)
        end
    end)
end
helpers.dragGui = dragGui

local slider = function(object, min, max, callback)
    local sliderObj = object.Slider
    local bar = sliderObj.Bar
    local rightBound = sliderObj.AbsoluteSize.X
    local toggle = false
    local goal = {}
    connect(userInputService.InputBegan, function()
        for _, v in ipairs(coreGui:GetGuiObjectsAtPosition(mouse.X, mouse.Y)) do
            if bar == v then
                toggle = true
                return
            end
        end
    end)
    connect(userInputService.InputEnded, function()
        toggle = false
    end)
    connect(mouse.Move, function()
        if toggle then
            local position = clamp(mouse.X - sliderObj.AbsolutePosition.X, 0, rightBound)
            local value = min + (max -min) * (position / rightBound)
            goal.Position = newUDim2(bar.Position.X.Scale, position, bar.Position.Y.Scale, bar.Position.Y.Offset)
            tween(bar, 'Linear', 'Out', 0.15, goal).Completed:Wait()
            callback(value)
        end
    end)
    onClick(bar, 'BackgroundColor3')
end
helpers.slider = slider

local colorPicker = function(object, callback)
    local hue, saturation, brightness = object.Hue, object.Saturation, object.Value
    local hueValue, saturationValue, brightnessValue = 0, 0, 0
    local keyPoints = hue.Slider.UIGradient.Color.Keypoints
    local update = function(percentage)
        if percentage then
            for i = 1, #keyPoints - 1 do
                local keyPoint, nextPoint = KeyPoints[i], keyPoints[i + 1]
                if keyPoint.Time <= percentage and nextPoint.Time >= percentage then
                    hueValue = toHSV(keyPoint.Value:Lerp(nextPoint.Value, percentage - keyPoint.Time / nextPoint.Time - keyPoint.Time))
                end
            end
        end
        callback(fromHSV(hueValue, saturationValue, 1 - brightnessValue))
    end
    slider(hue, 0, 1, function(value)
        update(value)
        saturation.Slider.UIGradient.Color = newColorSequence(fromhSV(hueValue, 0, 1 - brightnessValue), fromHSV(hueValue, 1, 1))
        brightness.Slider.UIGradient.Color = newColorSequence(fromHSV(hueValue, saturationValue, 1), newColor3(0, 0, 0))
    end)
    slider(saturation, 0, 1, function(value)
        saturationValue = value
        update()
        brightness.Slider.UIGradient.Color = newColorSequence(fromHSV(hueValue, saturationValue, 1), newColor3(0, 0, 0))
    end)
    slider(brightness, 0, 1, function(value)
        brightnessValue = value
        update()
        saturation.Slider.UIGradient.Color = newColorSequence(fromHSV(hueValue, 0, 1 - brightnessValue), fromHSV(hueValue, 1, 1))
    end)
end
helpers.colorPicker = colorPicker

local smoothScroll = function(object, factor)
    local scroll = object:Clone()
    scroll:ClearAllChildren()
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarImageTransparency = 1
    scroll.ZIndex = object.ZIndex + 1
    scroll.Name = '_smoothInputFrame'
    scroll.ScrollingEnabled = true
    object.ScrollingEnabled = false
    scroll.Parent = object.Parent
    for _, v in ipairs(smoothProperties) do
        if v == 'ZIndex' then
            connect(object:GetPropertyChangedSignal(v), function()
                scroll[v] = object[v] + 1
            end)
        else
            connect(object:GetPropertyChangedSignal(v), function()
                scroll[v] = object[v]
            end)
        end
    end
   local connection = connect(runService.Stepped, function()
        object.CanvasPosition = (scroll.CanvasPosition - object.CanvasPosition) * factor + object.CanvasPosition
    end)
    connect(object.AncestryChanged, function()
        if not object.Parent then
            scroll:Destroy()
            removeConnection(connection)
        end
    end)
end
helpers.smoothScroll = smoothScroll

local tweenAllTransparentToObject = function(object, time, previousObject)
    local previousDescendants = previousObject:GetDescendants()
    local textGoal, imageGoal, scrollGoal, goal = {}, {}, {}, {}
    goal.BackgroundTransparency = previousObject.BackgroundTransparency
    local tweenObj = tween(object, 'Sine', 'Out', time, goal)
    for i, v in ipairs(object:GetDescendants()) do
        local previousDescendant = previousDescendants[i]
        local class = v.ClassName
        if class ~= 'UIListLayout' then
            if find(class, 'Text', 1, true) then
                textGoal.TextTransparency = previousDescendant.TextTransparency
                textGoal.TextStrokeTransparency = previousDescendant.TextStrokeTransparency
                textGoal.BackgroundTransparency = previousDescendant.BackgroundTransparency
                tween(v, 'Sine', 'Out', time, textGoal)
            elseif find(class, 'Image', 1, true) then
                imageGoal.ImageTransparency = previousDescendant.ImageTransparency
                imageGoal.BackgroundTransparency = previousDescendant.BackgroundTransparency
                tween(v, 'Sine', 'Out', time, imageGoal)
            elseif class == 'ScrollingFrame' then
                scrollGoal.ScrollBarImageTransparency = previousDescendant.ScrollBarImageTransparency
                scrollGoal.BackgroundTransparency = previousDescendant.BackgroundTransparency
                tween(v, 'Sine', 'Out', time, scrollGoal)
            else
                goal.BackgroundTransparency = previousDescendant.BackgroundTransparency
                tween(v, 'Sine', 'Out', time, goal)
            end
        end
    end
    return tweenObj
end
helpers.tweenAllTransparentToObject = tweenAllTransparentToObject

local setAllTransparent = function(object)
    object.BackgroundTransparency = 1
    for _, v in ipairs(object:GetDescendants()) do
        local class = v.ClassName
        if class ~= 'UIListLayout' and class ~= 'UICorner' then
            if find(class, 'Text', 1, true) then
                v.TextTransparency = 1
            elseif find(class, 'Image', 1, true) then
                v.ImageTransparency = 1
            elseif class == 'ScrollingFrame' then
                v.ScrollBarImageTransparency = 1
            end
            v.BackgroundTransparency = 1
        end
    end
end
helpers.setAllTransparent = setAllTransparent

local tweenAllTransparent = function(object, time, value, exclude)
    value = tonumber(value) or 1
    local textGoal, imageGoal, scrollGoal, goal = {}, {}, {}, {}
    imageGoal.BackgroundTransparency = value
    scrollGoal.BackgroundTransparency = value
    goal.BackgroundTransparency = value
    local tweenObj = tween(object, 'Sine', 'Out', time, goal)
    for _, v in ipairs(object:GetDescendants()) do
        local class = v.ClassName
        local name = v.Name
        if class ~= 'UIListLayout' and class ~= 'UICorner' then
            if exclude and search(exclude, name) then
                continue
            end
            if find(class, 'Text', 1, true) then
                textGoal.TextTransparency = value
                if exclude then
                    local skip
                    for j, k in pairs(exclude) do
                        if name == j and k == 'BackgroundTransparency' then
                            textGoal.BackgroundTransparency = nil
                            tween(v, 'Sine', 'Out', time, textGoal)
                            skip = true
                        end
                    end
                    if skip then
                        continue
                    end
                end
                textGoal.BackgroundTransparency = value
                tween(v, 'Sine', 'Out', time, textGoal)
            elseif find(class, 'Image', 1, true) then
                imageGoal.ImageTransparency = value
                tween(v, 'Sine', 'Out', time, imageGoal)
            elseif class == 'ScrollingFrame' then
                scrollGoal.ScrollBarImageTransparency = value
                tween(v, 'Sine', 'Out', time, scrollGoal)
            else
                tween(v, 'Sine', 'Out', time, goal)
            end
        end
    end
    return tweenObj
end
helpers.tweenAllTransparent = tweenAllTransparent

local checkmark = function(object, callback)
    local button = object.checkmark
    local checked = button.Text == '✓'
    onClick(button, 'BackgroundColor3')
    connect(Button.MouseButton1Click, function()
        checked = not checked
        button.Text = checked and '✓' or ''
        callback(checked)
    end)
end
helpers.checkmark = checkmark

local singleSearch = function(object, matchObject, text)
    object.Visible = find(lower(matchObject.Text), text, 1, true)
end
helpers.singleSearch = singleSearch

local clearObjects = function(object)
    for _, v in ipairs(object:GetChildren()) do
        local class = v.ClassName
        if class ~= 'UIListLayout' and class ~= 'UIGridLayout' then
            v:Destroy()
        end
    end
end
helpers.clearObjects = clearObjects

local parentGui = function(object)
    object.Name = randomString(20)
    if protectGui then
        protectGui(object)
        object.Parent = coreGui
    elseif getHui then
        gui.Parent = getHui()
    else
        gui.Parent = coreGui
    end
    return object
end
helpers.parentGui = parentGui

return helpers