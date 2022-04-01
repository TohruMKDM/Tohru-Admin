-- fix scrolling

return function(input, obj)
    if input.UserInputType == 3 then
        obj:ReleaseFocus()
    end
end