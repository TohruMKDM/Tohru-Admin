--[[
    Name: loader.lua
    Description: Downloads the script if it hasn't been downloaded already and launches it
    Author: Tohru
]]

local starterGui = game:GetService('StarterGui')

local newInstance = Instance.new
local sub, upper = string.sub, string.upper
local find, format = string.find, string.format
local date = os.date
local traceback = debug.traceback

local blacklist = {
    ['TohruAdmin/misc/'] = true,
    ['TohruAdmin/misc/loader.lua'] = true,
    ['TohruAdmin/misc/script.lua'] = true,
    ['TohruAdmin/libs/unzip.lua'] = true
}

local notify = function(title, message, button1, button2, callback)
    local config = {Title = title, Text = message, Button1 = button1, Button2 = button2}
    if callback then
        local bindable = newInstance('BindableFunction')
        bindable.OnInvoke = callback
        config.Callback = bindable
    end
    starterGui:SetCore('SendNotification', config)
end

if not writefile then
    notify('Tohru Admin', 'Your exploit is not compatible with Tohru Admin\nMissing file system functions')
    return
end

local log = function(tag, message, ...)
    tag, message = upper(tag), format(message, ...)
    if isfolder('TohruAdmin') then
        local write = isfile('TohruAdmin/debug.log') and appendfile or writefile
        write('TohruAdmin/debug.log', format('\n%s | %s | %s', date('%x - %X'), tag, message))
    else
        makefolder('TohruAdmin')
        writefile('TohruAdmin/debug.log', format('\n%s | [%s] | %s', date('%x - %X'), tag, message))
    end
end

local downloadScript = function()
    local unzipData = game:HttpGet('https://github.com/TohruMKDM/Tohru-Admin/raw/master/libs/unzip.lua')
    local scriptData = game:HttpGet('https://github.com/TohruMKDM/Tohru-Admin/archive/refs/heads/master.zip')
    local unzip = loadstring(unzipData, '@unzip.lua')()
    local stream = unzip.newStream(scriptData)
    for name, content in unzip.getFiles(stream, true) do
        name = 'TohruAdmin'..sub(name, select(2, find(name, '%a/')))
        if not blacklist[name] then
            if sub(name, -1) == '/' then
                makefolder(name)
            elseif sub(name, -4) == '.lua' then
                writefile(name, content)
            end
        end
    end
end

local launchScript
launchScript = function()
    if import then
        notify('Tohru Admin', 'Tohru admin is already running', 'Restart?', 'Reload?', function(response)
            pcall(cleanUp)
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
            log('error', 'Error initializing tohru admin;\n %s', traceback(fail, 4))
            notify('Tohru Admin', 'Unable to initialize tohru admin\nError logged at "TohruAdmin/debug.log"', 'Retry?', nil, function()
                launchScript()
            end)
        end
    else
        downloadScript()
        launchScript()
    end
end

return launchScript()