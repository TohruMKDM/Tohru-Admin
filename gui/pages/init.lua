--[[
    Name: gui/pagesinit.lua
    Description: Import the code for each page in the gui
    Author: misrepresenting
]]

local names = {
    'adminsPage',
    'chatLogsPage',
    'commandLogsPage',
    'executorPage',
    'joinLogsPage',
    'playersPage',
    'serverPage',
    'settingsPage'
}

local pages = {}

for _, v in ipairs(names) do
    pages[v] = import(v)
end

return pages