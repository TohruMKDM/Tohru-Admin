-- Build and launch UI

local ui_utilities = import('ui_utilities')
local highlighter = import('highlighter')

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
connect(title.Close.MouseButton1Click, function()
    if not mainDebounce then
        mainDebounce = true
        ui_utilities.intro(main)
        mainDebounce = false
    end
end)

return