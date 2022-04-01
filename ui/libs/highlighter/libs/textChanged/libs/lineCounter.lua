-- Line Counting

local split = string.split

return function(obj)
    local text = obj.Text
    local count = ''
    for i = 1, #split(text, '\n') do
        count = count..i..'\n'
    end
    obj.LineCounter.Text = count
end