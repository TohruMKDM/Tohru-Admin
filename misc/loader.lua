--[[
    Name: loader.lua
    Description: Downloads the script if it hasn't been downloaded already and launches it

    Author: Tohru
]]

local starterGui = game:GetService('StarterGui')
local sub, find, format, upper = string.sub, string.find, string.format, string.upper
local date = os.date
local traceback = debug.traceback

local blacklist = {
    ['TohruAdmin/misc/'] = true,
    ['TohruAdmin/misc/loader.lua'] = true,
    ['TohruAdmin/misc/script.lua'] = true,
    ['TohruAdmin/libs/unzip.lua'] = true
}

local notify = function(title, message, button, button2, callback)
    local config = {
        Title = title,
        Text = message
    }
    if button then
        local bindable = Instance.new('BindableFunction')
        bindable.OnInvoke = callback
        config.Callback = bindable
        config.Button1 = button
        config.Button2 = button2
    end
    starterGui:SetCore('SendNotification', config)
end

local log = function(tag, message, ...)
    message = format(message, ...)
    tag = upper(tag)
    if isfolder('TohruAdmin') then
        local write = isfile('TohruAdmin/debug.log') and appendfile or writefile
        write('TohruAdmin/debug.log', format('\n%s | %s | %s', date('%x - %X'), tag, message))
    else
        makefolder('TohruAdmin')
        writefile('TohruAdmin/debug.log', format('\n%s | [%s] | %s', date('%x - %X'), tag, message))
    end
end

if not writefile then
    notify('Tohru Admin', 'Your exploit is not compatible with Tohru Admin\nMissing file system functions')
    return
end

local cleanUp = function()
    local storage = import('storage')
    if storage.gui then
        storage.gui:Destroy()
        storage.gui = nil
    end
    if storage.connections then
        for _, v in ipairs(storage.connections) do
            v:Disconnect()
        end
        storage.connections = nil
    end
    local compat = import('compat')
    local global = getgenv()
    for i in pairs(compat) do
        global[i] = nil
    end
end

local downloadScript = function()
    local unzipData = game:HttpGet('https://github.com/TohruMKDM/Tohru-Admin/raw/master/libs/unzip.lua')
    local scriptData = game:HttpGet('https://github.com/TohruMKDM/Tohru-Admin/archive/refs/heads/master.zip')
    local unzip = loadstring(unzipData, '@unzip.lua')()
    local stream = unzip.newStream(scriptData)
    local inflate = unzip.inflate
    for name, offset in unzip.getFiles(stream) do
        name = 'TohruAdmin'..sub(name, select(2, find(name, '%a/')))
        if not blacklist[name] then
            if sub(name, -1) == '/' then
                makefolder(name)
            elseif sub(name, -4) == '.lua' then
                writefile(name, inflate(stream, offset))
            end
        end
    end
end

local launchScript
launchScript = function()
    if import then
        notify('Tohru Admin', 'Tohru admin is already running', 'Restart?', 'Reload?', function(response)
            getgenv().import = nil
            if response == 'Restart?' then
                launchScript()
            else
                downloadScript()
                launchScript()
            end
        end)
        return
    end
    if isfile('TohruAdmin/libs/import.lua') then
        local data = readfile('TohruAdmin/libs/import.lua')
        local getter, err = loadstring(data, '@import.lua')
        if not getter then
            log('error', 'Error loading import.lua; %s', err)
            notify('Tohru Admin', 'Unable to load import.lua\nError logged at "TohruAdmin/debug.log"', 'Reload?', function()
                downloadScript()
                launchScript()
            end)
            return
        end
        local import = getter():init('TohruAdmin/startup.lua')
        getgenv().import = import
        local success, fail = pcall(import, 'init')
        if not success then
            pcall(cleanUp)
            getgenv().import = nil
            log('error', 'Error initializing tohru admin; %s', traceback(fail, 4))
            notify('Tohru Admin', 'Unable to initialize tohru admin\nError logged at "TohruAdmin/debug.log"', 'Retry?', nil, function()
                launchScript()
            end)
        else
            local package = import('package')
            notify('Tohru Admin', 'Tohru Admin v'..package.version..' initialized successfully')
        end
    else
        downloadScript()
        launchScript()
    end
end

return launchScript()