-- Build and launch UI

local ui_utilities = import('ui_utilities')
local highlighter = import('highlighter')
local tween = import('utilities').tween

local newUdim2 = UDim2.new
local mainDebounce = false
local players = services.Players
local wrap = coroutine.wrap

local ui = game:GetObjects('rbxassetid://6354865289')[1]
local commandBar = ui.CommandBar
local main = ui.MainDragFrame.Main
local notification = ui.Notification
local notificationBar = ui.NotificationBar
local toolTip = ui.ToolTip
local title = main.Title
local pages = main.Pages
local menu = main.Menu

pages.Menu.Welcome.Message.Text = '<b>Welcome</b>, '..localPlayer.Name
pages.Menu.Profile.Image = players:GetUserThumbnailAsync(localPlayer.UserId, 0, 2)
local success, daily = pcall(game.HttpGet, game, 'https://ikaros.pw/daily.txt')
pages.Menu.DailyMessage.MessageFrame.Message.Text = success and daily or 'Failed to get the daily message.'
commandBar.Position = newUdim2(.5, -100, 1, 5)
notification.Visible = false
commandBar.Visible = false
main.Visible = false
parentGui(ui)
ui_utilities.makeTransparent(commandBar)
ui_utilities.dragObj(main)
ui_utilities.intro(main)
ui_utilities.onClick(title.Close, 'TextColor3')
do
    local last, _
    local tweenPage = function(page, transparency)
        page = menu[page.Name]
        tween(page.Image, 'Sine', 'Out', .25, {ImageTransparency = transparency})
        tween(page.PageName, 'Sine', 'Out', .25, {TextTransparency = transparency})
    end
    local children = menu:GetChildren()
    for i = 1, #children do
        local child = children[i]
        if child.ClassName ~= 'UIListLayout' then
            connect(child.MouseButton1Click, function()
                local page = pages[child.name]
                last = pages.UIPageLayout.CurrentPage
                _ = last.Name ~= 'Menu' and tweenPage(last, .5)
                tweenPage(page, 0)
                pages.UIPageLayout:JumpTo(page)
            end)
            connect(child.MouseEnter, function()
                local page = pages[child.Name]
                _ = pages.UIPageLayout.CurrentPage ~= page and tweenPage(page, .5)
            end)
            connect(child.MouseLeave, function()
                local page = pages[child.Name]
                _ = pages.UIPageLayout.CurrentPage ~= page and tweenPage(page, .5)
            end)
        end
    end
    connect(title.TitleButton.MouseButton1Click, function()
        last = pages.UIPageLayout.CurrentPage
        _ = last.Name ~= 'Menu' tweenPage(last, .5)
        pages.UIPageLayout:JumpTo(pages.Menu)
    end)
end
connect(title.Close.MouseButton1Click, function()
    if not mainDebounce then
        mainDebounce = true
        ui_utilities.intro(main)
        mainDebounce = false
    end
end)

return