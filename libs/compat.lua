-- Standardize function names + load in some other things

local storage = import('storage')

local globals = getgenv()
local connections = {}

local compat = {}

compat.request = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or request

compat.queueTeleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport

compat.setclipboard = setclipboard or toclipboard or set_clipboard

compat.gethidden = gethiddenproperty or get_get_hidden_property

compat.sethidden = sethiddenproperty or set_hidden_property

compat.services = setmetatable({}, {
    __index = function(_, k)
        return game:GetService(k)
    end
})

compat.localPlayer = compat.services.Players.localPlayer

compat.parentGui = function(gui)
    local protect_gui = not is_sirhurt_closure and syn and syn.protect_gui
    local hiddenUI = get_hidden_gui or gethui
    if protect_gui then
        protect_gui(gui)
    elseif hiddenUI then
        gui.Parent = hiddenUI()
        return
    end
    gui.Parent = game:GetService('CoreGui')
    return gui
end

compat.connect = function(signal, fn)
    local connection = signal:Connect(fn)
    local position = #connections + 1
    connections[position] = connection
    return connection, position
end

storage.connections = connections

return function()
    for i, v in pairs(compat) do
        globals[i] = v
    end
end