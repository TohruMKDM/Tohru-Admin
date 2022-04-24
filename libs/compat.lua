-- Standardize function names + load in some other things

local storage = import('storage')

local players = game:GetService('Players')
local httpService = game:GetService('HttpService')

local concat, remove = table.concat, table.remove
local char = string.char
local random = math.random

local compat = {}

compat.request = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or request

compat.protectGui = not is_sirhurt_closure and syn and syn.protect_gui

compat.gethui = get_hidden_gui or gethui

compat.queueTeleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport

compat.setclipboard = setclipboard or toclipboard or set_clipboard

compat.gethidden = gethiddenproperty or get_hidden_property

compat.sethidden = sethiddenproperty or set_hidden_property

compat.localPlayer = players.LocalPlayer

compat.mouse = compat.localPlayer:GetMouse()

local connections = {}
compat.connect = function(signal, fn)
    local connection = signal:Connect(fn)
    connections[#connections + 1] = connection
    return connection
end
storage.connections = connections

compat.removeConnection = function(connection)
    for i, v in ipairs(connections) do
        if v == connection then
            connection:Disconnect()
            remove(connections, i)
            return
        end
    end
end

compat.jsonEncode = function(data)
    return httpService:JSONEncode(data)
end

compat.jsonDecode = function(data)
    return httpService:JSONDecode(data)
end

compat.randomString = function(length)
    local result = {}
    for i = 1, length do
        result[i] = char(random(32, 126))
    end
    return concat(result)
end

return setmetatable(compat, {
    __call = function()
        local global = getgenv()
        for i, v in pairs(compat) do
            global[i] = v
        end
    end
})