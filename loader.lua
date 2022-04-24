--[[
    Name: loader.lua
    Description: Downloads the script if it hasn't been downloaded already and launches it

    Author: Tohru
]]

local starterGui = game:GetService('StarterGui')
local sub, find, format, upper = string.sub, string.find, string.format, string.upper
local date = os.date

local notify = function(title, message, button, callback)
    local config = {
        Title = title,
        Text = message
    }
    if button then
        local bindable = Instance.new('BindableFunction')
        bindable.OnInvoke = callback
        config.Callback = bindable
        config.Button1 = button
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

local downloadScript = function()
    local unzipData = game:HttpGet('https://raw.githubusercontent.com/TohruMKDM/Tohru-Admin/master/libs/unzip.lua')
    local scriptData = game:HttpGet('https://github.com/TohruMKDM/Tohru-Admin/archive/refs/heads/master.zip')
    local unzip = loadstring(unzipData, '@unzip.lua')()
    local stream = unzip.newStream(scriptData)
    local inflate = unzip.inflate
    for name, offset in unzip.getFiles(stream) do
        name = 'TohruAdmin'..sub(name, select(2, find(name, '%a/')))
        if sub(name, -1) == '/' then
            makefolder(name)
        elseif sub(name, -4) == '.lua' then
            writefile(name, inflate(stream, offset))
        end
    end
end

local launchScript
launchScript = function()
    if import then
        notify('Tohru Admin', 'Tohru admin is already running', 'Restart?', function()
            getgenv().import = nil
            launchScript()
        end)
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
            getgenv().import = nil
            log('error', 'Error initializing tohru admin; %s', fail)
            notify('Tohru Admin', 'Unable to initialize tohru admin\nError logged at "TohruAdmin/debug.log"', 'Retry?', function()
                launchScript()
            end)
        end
    else
        downloadScript()
    end
end

return launchScript()