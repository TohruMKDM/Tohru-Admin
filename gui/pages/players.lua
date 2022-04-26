--[[
    Name: gui/pages/players.lua
    Description: Program the players page
    Author: misrepresenting
]]

local smoothScroll, onClick, clearObjects, colorize, blink do
    local helpers = import('helpers')
    smoothScroll, onClick, clearObjects, colorize, blink = helpers.smoothScroll, helpers.onClick, helpers.clearObjects, helpers.colorize, helpers.blink
end
local notify, intro do
    local ui = import('ui')
    notify, intro = ui.notify, ui.intro
end
local endpoints = import('endpoints')
local tween = import('utils').tween
local gui = import('storage').gui

local players = game:GetService('Players')
local marketPlace = game:GetService('MarketplaceService')

local fromOffset, fromRGB = UDim2.fromOffset, Color3.fromRGB
local avatarThumbnail, headShot = Enum.ThumbnailType.AvatarThumbnail, Enum.ThumbnailType.HeadShot
local size420 = Enum.ThumbnailSize.Size420x420
local placeholderColor, textColor = fromRGB(89, 41, 41), fromRGB(211, 53, 56)
local goal = {BackgroundTransparency = 1}
local infoDebounce, searchDebounce = false, false
local match, format = string.match, string.format
local wrap = coroutine.wrap

local playersPage = gui.MainDragFrame.Main.Pages.Players
local playersInfo = playersPage.Info
local playersUser = playersInfo.User
local playersGame = playersPage.Game
local playersResults = playersPage.Results
local searchBox = playersPage.SearchBar.SearchFrame.Search
local infoFrame = playersInfo.Frame.Mask.ScrollingFrame
local gamesFrame = infoFrame.Games.GamesFrame.ScrollingFrame
local gridLayout = playersResults.UIGridLayout

local searchPlayers = function(endpoint)
    return jsonDecode(game:HttpGet(endpoint))
end

local setInfo = function(player)
    local endpoint = format(endpoints.USER, player.id)
    local json = jsonDecode(game:HttpGet(endpoint))
    local thumbnail = players:GetUserThumbnailAsync(player.id, avatarThumbnail, size420)
    local year, month, day = match(json.created, '(%d+)-(%d+)-(%d+)')
    infoFrame.UsernameFrame.Username.Text = player.name
    infoFrame.Avatar.Image = thumbnail
    infoFrame.Description.DescriptionFrame.Description.Text = json.description
    infoFrame.JoinDate.JoinDateLabel.Text = format('%s/%s/%s', colorize(month), colorize(day), colorize(year))
end

local setFollowing = function(player)
    local endpoint = format(endpoints.FOLLOWING, player.id)
    local json = jsonDecode(game:HttpGet(endpoint))
    infoFrame.Following.FollowingLabel.Text = json.count
end

local setFollowers = function(player)
    local endpoint = format(endpoints.FOLLOWERS, player.id)
    local json = jsonDecode(game:HttpGet(endpoint))
    infoFrame.Followers.FollowersLabel.Text = json.count
end

local setFriends = function(player)
    local endpoint = format(endpoint.FRIENDS, player.id)
    local json = jsonDecode(game:HttpGet(endpoint))
    infoFrame.Friends.FriendsLabel.Text = json.count
end

local setGames = function(player)
    clearObjects(gamesFrame)
    gamesFrame.CanvasSize = fromOffset(0, 0)
    local endpoint = format(endpoints.GAMES, player.id)
    local json = jsonDecode(game:HttpGet(endpoint))
    if json.data then
        for _, v in ipairs(json.data) do
            local clone = playersGame:Clone()
            local gameId = v.rootPlace.gameId
            local assetId = marketPlace:GetProductInfo(gameId).IconImageAssetId
            onClick(clone.Icon, 'ImageColor3')
            connect(clone.Icon.MouseButton1Click, function()
                if setClipBoard then
                    setClipBoard(gameId)
                    notify(format('Copied the id of "%s" to your clipboard', gameId))
                else
                    notify('Incompatible exploit', 'Your exploit does not support copying content to your clipboard')
                end
            end)
            clone.Visible = true
            clone.Title.Text = v.name
            clone.Icon.Image = format(endpoints.ASSET, assetId)
            clone.Parent = gamesFrame
        end
    end
end

local setStatus = function(object, player)
    local endpoint = format(endpoints.ONLINE, player.id)
    local json = jsonDecode(game:HttpGet(endpoint))
    local thumbnail = players:GetUserThumbnailAsync(player.id, headShot, size420)
    object.Profile.Image = thumbnail
    object.Profile.Text = json.IsOnline and 'Online' or 'Offline'
end

smoothScroll(playersResults, 0.14)
smoothScroll(infoFrame, 0.14)
smoothScroll(gamesFrame, 0.14)
onClick(playersInfo.Frame.Close, 'TextColor3')
onClick(infoFrame.UsernameFrame.Username, 'TextColor3')

connect(infoFrame.UsernameFrame.Username.MouseButton1Click, function()
    if setClipBoard then
        local name = infoFrame.UsernameFrame.Username.Text
        setClipBoard(players:GetUserIdFromNameAsync(name))
        notify(format('Copied the id of "%s" to your clipboard', name))
    else
        notify('Incompatible exploit', 'Your exploit does not support copying content to your clipboard')
    end
end)

connect(playersInfo.Frame.Close.MouseButton1Click, function()
    if not infoDebounce then
        infoDebounce = true
        tween(playersInfo.Frame, 'Sine', 'Out', 0.25, goal)
        intro(playersInfo.Frame)
        playersInfo.Visible = false
        infoDebounce = false
    end
end)

connect(searchBox.FocusLost, function()
    if not searchDebounce then
        searchDebounce = true
        local endpoint = format(endpoints.USER_SEARCH, searchBox.Text)
        local success, json = pcall(searchPlayers, endpoint)
        if success and json.data and #json.data ~= 0 then
            for _, v in ipairs(json.data) do
                local clone = playersUser:Clone()
                onClick(clone.GetInfo, 'BackgroundColor3')
                connect(clone.GetInfo.MouseButton1Click, function()
                    wrap(setInfo)(v)
                    wrap(setFollowers)(v)
                    wrap(setFollowing)(v)
                    wrap(setFriends)(v)
                    wrap(setGames)(v)
                    playersInfo.Frame.BackgroundTransparency = 1
                    playersInfo.Visible = false
                    playersInfo.Frame.Visible = false
                    tween(playersInfo.Frame, 'Sine', 'Out', 0.25, goal)
                    intro(playersInfo.Frame)
                end)
                wrap(setStatus)(clone, v)
                clone.Visible = true
                clone.Parent = playersResults
                playersResults.CanvasSize = fromOffset(gridLayout.AbsoluteContentSize.X, gridLayout.AbsoluteContentSize.Y)
            end
        else
            blink(searchBox, 'Placeholder3', placeholderColor, true)
            blink(searchBox, 'TextColor3', textColor, true)
        end
        searchDebounce = false
    else
        notify('Player Search', 'The current player search is still loading')
    end
end)

return playersPage