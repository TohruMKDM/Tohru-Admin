-- init

local highlight = import('syntaxHighlighter')
local tab = import('tab')
local counter = import('lineCounter')

return function(obj)
    highlight(obj)
    tab(obj)
    counter(obj)
end