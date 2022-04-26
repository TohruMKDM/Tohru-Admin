--[[
    Name: gui/pages/server.lua
    Description: Program the server page
    Author: misrepresenting
]]

local onClick, colorize do
    local helpers = import('../helpers')
    onClick, colorize = helpers.onClick, helpers.colorize
end
local notify= import('ui').notify
local gui = import('storage').gui

local players = game:GetService('Players')
local runService = game:GetService('RunService')
local workSpace = game:GetService('Workspace')
local marketPlace = game:GetService('MarketplaceService')

local playerCount = #players:GetPlayers()
local maxPlayers = players.MaxPlayers
local format = string.format
local floor = math.floor
local wrap = coroutine.wrap

local serverPage = gui.MainDragFrame.Main.Pages.server
local serverGame = serverPage.serverGame
local serverPlayers = serverPage.Players
local serverAge = serverPage.ClientAge

onClick(serverGame.Id, 'TextColor3')

local connection = connect(runService.RenderStepped, function()
    local secs = workSpace.DistributedGameTime
    local mins = secs / 60
    local hrs = mins / 60
    serverAge.ClientAgeFrame.ClientAge.Text = format('%s hrs, %s mins, %s secs', colorize(floor(hrs)), colorize(floor(mins)), colorize(floor(secs % 60)))
end)

connect(serverAge.AncestryChanged, function()
    if not serverAge.Parent then
        removeConnection(connection)
    end
end)

connect(serverGame.Id.MouseButton1Click, function()
    if setClipBoard then
        setClipBoard(game.PlaceId)
        notify('Copied the current GameID to your clipboard')
    else
        notify('Incompatible exploit', 'Your exploit does not support copying content to your clipboard')
    end
end)

connect(players.PlayerAdded, function()
    playerCount = playerCount + 1
    serverPlayers.PlayersFrame.Players.Text = format('%s/%s', colorize(playerCount), colorize(maxPlayers))
end)

connect(players.PlayerRemoving, function() 
    playerCount = playerCount - 1
    serverPlayers.PlayersFrame.Players.Text = format('%s/%s', colorize(playerCount), colorize(maxPlayers))
end)

wrap(function()
    local product = marketPlace:GetProductInfo(game.PlaceId)
    serverGame.Title.Text = product.Name
    serverGame.By.Text = 'By '..colorize(product.Creator.Name)
    serverGame.Description.DescriptionFrame.Description.Text = product.Description
end)()

return serverPage