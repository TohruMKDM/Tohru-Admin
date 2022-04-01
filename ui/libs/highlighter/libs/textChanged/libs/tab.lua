-- Auto tab

local sub = string.sub

return function(obj)
    local text = obj.Text
    local position = obj.CursorPosition
    local previous = sub(text, position - 1, position - 1)
    if previous == '\t' then
        obj.Text = sub(text, 1, position -2)..'    '..sub(text, position, #text)
        obj.CursorPosition = position + 3
    end
end