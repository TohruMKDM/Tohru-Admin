-- Syntax highlighting

local inputBegan = import('inputBegan')
local inputChanged = import('inputChanged')
local textChanged = import('textChanged')

local uis = services.UserInputService

return function(obj)
    connect(obj.InputBegan, function(input)
        inputBegan(input, obj)
    end)
    connect(obj:GetPropertyChangedSignal('Text'), function()
        textChanged(obj)
    end)
    connect(uis.InputBegan, function(input)
        inputBegan(input, obj)
    end)
end