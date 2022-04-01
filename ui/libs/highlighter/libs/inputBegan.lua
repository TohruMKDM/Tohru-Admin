-- Handle auto indenting

local keywords = {
    {'else', 'end'},
    {'do', 'end'},
    {'then', 'end'},
    {'{', '}'},
    {'%([ ]*function', 'end'},
    {'function', 'end'},
    {'repeat', 'until'}
}
local patterns = {
    '"(.-)"',
    "'(.-)'",
    '%-%-.+',
    '{(.-)}'
}
local sub, gsub = string.sub, string.gsub
local find, match = string.find, string.match
local rep, split = string.rep, string.split

return function(input, obj)
    if input.KeyCode ~= 13 or not obj:IsFocused() then return end
    local text = obj.Text
    local lines = split(sub(text, 1, obj.CursorPosition - 1), '\n')
    local previous = lines[#lines - 1] or ''
    local start, finish = find(previous, '[ ]+')
    local layer = start == 1 and finish or 0
    for i = 1, 4 do
        previous = gsub(previous, patterns[i], '')
    end
    for i = 1, 7 do
        local keyword = keywords[i]
        if match(previous, keyword[1]) then
            local tab = rep(' ', layer)
            obj.Text = sub(text, 1, obj.CursorPosition -1)..'    '..tab..'\n'..tab..keyword[2]..sub(text, obj.CursorPosition, #text)
            obj.CursorPosition = obj.CursorPosition + 4 + layer
            return
        end
    end
end