--[[
    Name: gui/init.lua
    Description: Load and program the GUI
    Author: misrepresenting
]]

local helpers = import('helpers')
local storage = import('storage')
local utils = import('utils')
local gui = helpers.parentGui(game:GetObjects('rbxassetid://6354865289')[1])
storage.gui = gui
local ui = import('ui')

local marketPlace = game:GetService('MarketplaceService')
local players = game:GetService('Players')
local userInputService = game:GetService('UserInputService')
local workSpace = game:GetService('Workspace')

local newUdim2 = UDim2.new
local fromOffset, fromRGB = UDim2.fromOffset, Color3.fromRGB
local thumbnail, headShot = Enum.ThumbnailType.AvatarThumbnail,Enum.ThumbnailType.HeadShot
local size420 = Enum.ThumbnailSize.Size420x420
local keyCode = Enum.KeyCode
local commandBar, main = gui.CommandBar, gui.MainDragFrame.Main
local title, menu, pages = main.Title, main.Menu, main.Pages
local settings = storage.settings
local defer, tWait = task.defer, task.wait
local match, format = string.match, string.format
local wrap = coroutine.wrap
local barGoal = {}
local barOpen = false

local commandBarClone = commandBar:Clone()
gui.Notification.Visible = false
commandBar.Visible = false
main.Visible = false
commandBar.Position = newUdim2(0.5, -100, 1, 5)
helpers.setAllTransparent(commandBar)
helpers.dragGui(main)

local colorize = function(message)
    local textColor = settings.textColor
    return format('<font color = "rgb(%s, %s, %s)">%s</font>', textColor[1], textColor[2], textColor[3], message)
end

local barCallback = function(inputBox)
    inputBox:CaptureFocus()
    inputBox.Text = ''
end
connect(userInputService.InputBegan, function(input, gpe)
    if gpe then
        return
    end
    if input.KeyCode == keyCode[settings.prefix] then
        barOpen = not barOpen
        local transparencyTween = barOpen and helpers.tweenAllTransparentToObject or helpers.tweenAllTransparent
        transparencyTween(commandBar, 0.5, commandBarClone)
        if barOpen then
            commandBar.Visible = true
            barGoal.Position = #utils.getTools(localPlayer) == 0 and newUdim2(0.5, -100, 1, -45) or newUdim2(0.5, -100, 1, -110)
            utils.tween(commandBar, 'Quint', 'Out', 0.5, barGoal)
            defer(barCallback, commandBar.Input)
        else
            barGoal.Position = newUdim2(0.5, -100, 1, 5)
            utils.tween(commandBar, 'Quint', 'Out', 0.5, barGoal).Completed:Wait()
            commandBar.Visible = false
        end
    end
end)

connect(commandBar.Input.FocusLost, function()
    barOpen = false
    barGoal.Position = newUdim2(0.5, -100, 1, 5)
    helpers.tweenAllTransparent(commandBar, 0.5)
    utils.tween(commandBar, 'Quint', 'Out', 0.5, barGoal)
end)

local mainDebounce = false
helpers.onClick(title.Close, 'TextColor3')
connect(title.Close.MouseButton1Click, function()
    if not mainDebounce then
        mainDebounce = true
        ui.intro(main)
        mainDebounce = false
    end
end)

do
    local pageLayout = pages.UIPageLayout
    local imageGoal, textGoal = {}, {}
    local lastPage
    local tweenPage = function(page, transparency)
        page = menu[Page.Name]
        imageGoal.ImageTransparency = transparency
        textGoal.TextTransparency = transparency
        utils.tween(page.Image, 'Sine', 'Out', 0.25, imageGoal)
        utils.tween(page.PageName, 'Sine', 'Out', 0.25, textGoal)
    end
    for _, v in ipairs(menu:GetChildren()) do
        if v.ClassName ~= 'UIListLayout' then
            connect(v.MouseButton1Click, function()
                local page = pages[v.Name]
                lastPage = pageLayout.CurrentPage
                pageLayout:JumpTo(page)
                if menu:FindFirstChild(lastPage.Name) then
                    tweenPage(lastPage, 0.5)
                end
                tweenPage(page, 0)
            end)
            connect(v.MouseEnter, function()
                local page = pages[v.Name]
                if lastPage ~= page then
                    tweenPage(page, 0.4)
                end
            end)
            connect(v.MouseLeave, function()
                local page = pages[v.name]
                if lastPage ~= page then
                    tweenPage(page, 0.4)
                end
            end)
        end
    end
    connect(title.TitleButton.MouseButton1Click, function()
        lastPage = pageLayout.CurrentPage
        if menu:FindFirstChild(lastPage.Name) then
            tweenPage(lastPage, 0.5)
        end
        pageLayout:JumpTo(pages.Menu)
    end)
end

do
    local playersPage = pages.Players
    local searchBox = playersPage.SearchBar.SearchFrame.Search
    local playersInfo = playersPage.Info
    local playersResults = playersPage.Results
    local playersGame = playersPage.Game
    local playersUser = playersPage.User
    local infoFrame = playersInfo.Frame.Mask.ScrollingFrame
    local gamesFrame = infoFrame.Games.GamesFrame.ScrollingFrame
    local gridLayout = playersResults.UIGridLayout
    local infoGoal = {BackgroundTransparency = 1}

    local playersDebounce = false
    helpers.smoothScroll(playersResults, 0.14)
    helpers.smoothScroll(infoFrame, 0.14)
    helpers.smoothScroll(gamesFrame, 0.14)
    helpers.onClick(playersInfo.Frame.Close, 'TextColor3')
    helpers.onClick(infoFrame.UsernameFrame.Username, 'TextColor3')
    local setInfo = function(result)
        local data = game:HttpGet('https://users.roblox.com/v1/'..result.id)
        local json = jsonDecode(data)
        local year, month, day = match(result.created, '(%d+)-(%d+)-(%d+)')
        infoFrame.UsernameFrame.Username.Text = result.name
        infoFrame.Avatar.Image = players:GetUserThumbnailAsync(result.id, thumbnail, size420)
        infoFrame.JoinDate.JoinDateLabel.Text = format('%s/%s/%s', colorize(month), colorize(day), colorize(year))
        infoFrame.Description.DescriptionFrame.Description.Text = json.description
    end
    local setFollowers = function(result)
        local data = game:HttpGet('https://friends.roblox.com/v1/users/'..result.id..'/followers/count')
        local json = jsonDecode(data)
        infoFrame.Followers.FollowersLabel.Text = json.count
    end
    local setFollowing = function(result)
        local data = game:HttpGet('https://friends.roblox.com/v1/users/'..result.id..'/followings/count')
        local json = jsonDecode(data)
        infoFrame.Folllowing.FollowingLabel.Text = json.count
    end
    local setGames = function(results)
        helpers.ClearAllObjects(gamesFrame)
        gamesFrame.CanvasSize = fromOffset(0, 0)
        local data = game:HttpGet('https://games.roblox.com/v2/users/'..result.id..'/games?accessFilter=Public&sortOrder=Asc&limit=25')
        local json = jsonDecode(data)
        for _, v in ipairs(json.data) do
            local id = v.rootPlace.id
            local clone = playersGame:Clone()
            clone.Icon.Image = 'rbxassetid://'..marketPlace:GetProductInfo(id).IconImageAssetId
            clone.Title.Text = v.name
            clone.Visible = true
            clone.Parent = gamesFrame
            helpers.onClick(clone.Icon, 'ImageColor3')
            connect(clone.Icon.MouseButton1Click, function()
                if setClipboard then
                    setClipboard(id)
                    ui.notify('Copied the GameID of "'..v.Name..'" to your clipboard.')
                else
                    ui.notify('Incompatible exploit', 'Your exploit does not support copying content to your clipboard')
                end
            end)
        end
    end
    local setStatus = function(clone, player)
        local data = game:GetService('https://api.roblox.com/users/'..player.id..'/onlinestatus/')
        local json = jsonDecode(data)
        clone.Profile.Image = players:GetUserThumbnailAsync(player.id, headShot, size420)
        clone.Status.Text = json.IsOnline and 'Online' or 'Offline'
    end
    connect(playersInfo.Frame.Close.MouseButton1Click, function()
        if not playersDebounce then
            playersDebounce = true
            utils.tween(playersInfo.Frame, 'Sine', 'Out', 0.25, infoGoal)
            ui.intro(playersInfo.Frame)
            playersDebounce = false
        end
    end)
    connect(searchBox.FocusLost, function()
        if not playersDebounce then
            playersDebounce = true
            local data = game:HttpGet('https://users.roblox.com/v1/users/search?keyword='..searchBox.Text..'&limit=25')
            local json = jsonDecode(data)
            helpers.ClearAllObjects(playersResults)
            playersResults.CanvasSize = fromOffset(gridLayout.AbsoluteContentSize.X, gridLayout.AbsoluteContentSize.Y)
            if json.data then
                for _, player in ipairs(json.data) do
                    local clone = playersUser:Clone()
                    clone.UsernameFrame.Username.Text = player.name
                    clone.Visible = true
                    clone.Parent = playersResults
                    helpers.onClick(clone.GetInfo, 'BackgroundColor3')
                    connect(clone.GetInfo.MouseButton1Click, function()
                        wrap(setInfo)(player)
                        wrap(setFollowing)(player)
                        wrap(setFollowers)(player)
                        wrap(setGames)(player)
                        ui.intro(playersInfo.Frame)
                    end)
                    wrap(setStatus)(clone, player)
                end
            else
                helpers.blink(searchBox, 'PlaceholderColor3', fromRGB(89, 41, 41), true)
                helpers.blink(searchBox, 'TextColor3', fromRGB(211, 53, 56), true)
            end
            playersDebounce = false
        else
            ui.notify('Player Search', 'Please wait until the current search is finished')
        end
    end)
end

do
    local server = pages.Server
    local serverGame = server.Game
    local serverPlayers = server.Players
    local serverAge = server.ClientAge
    local count = #players:GetPlayers()
    serverPlayers.PlayersFrame.Players.Text = format('%s/%s', colorize(count), colorize(players.MaxPlayers))
    serverGame.Thumbnail.Image = 'https://www.roblox.com/asset-thumbnail/image?assetId='..game.PlaceId..'&width=768&height=432&format=png'
    serverGame.Id.Text = game.PlaceId
    connect(serverGame.Id.MouseButton1Click, function()
        if setClipboard then
            setClipboard(id)
            ui.notify('Copied the current GameID to your clipboard')
        else
            ui.notify('Incompatible exploit', 'Your exploit does not support copying content to your clipboard')
        end
    end)
    connect(players.PlayerAdded, function()
        count = count + 1
        serverPlayers.PlayersFrame.Players.Text = format('%s/%s', colorize(count), colorize(players.MaxPlayers))
    end)
    connect(players.PlayerRemoving, function()
        count = count - 1
        serverPlayers.PlayersFrame.Players.Text = format('%s/%s', colorize(count), colorize(players.MaxPlayers))
    end)
    wrap(function()
        local product = marketPlace:GetProductInfo(game.PlaceId)
        serverGame.Title.Text = product.Name
        serverGame.By.Text = 'By '..colorize(product.Creator.Name)
        serverGame.Description.DescriptionFrame.Description.Text = product.Description
        while tWait(1) do
            local mins = workSpace.DistributedGameTime / 60
            local hrs = mins / 60
            serverAge.ClientAge.ClientAge.Text = format('%s hrs, %s mins', colorize(hrs), colorize(mins))
        end
    end)()
end