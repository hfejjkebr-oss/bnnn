--[[
    HubUI - reusable UI library (extracted from QuickX Hub)

    USAGE:
        local UI = loadstring(game:HttpGet("YOUR_RAW_URL/HubUI.lua"))()

        local Window = UI.CreateWindow({
            Name      = "My Hub",                       -- hub name
            Subtitle  = "Map Name",                     -- map / game name
            Logo      = "rbxassetid://123456789",       -- logo (sidebar + round open button)
            Theme     = "Default",                      -- Default | Crimson | Ocean | Mint | Sunset
            ToggleKey = Enum.KeyCode.RightShift,        -- optional
            ConfigDir = "MyHub",                        -- optional (config folder name)
        })

        -- change later at any time:
        Window:SetTitle("New Name")
        Window:SetSubtitle("New Map")
        Window:SetLogo("rbxassetid://987654321")

        local Tab = Window:Tab({Title = "Main", Icon = "home"})
        Tab:Toggle({Title = "Auto Farm", Value = false, Callback = function(v) end})
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

return (function()
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")

    local Lib = {
        Logo = "rbxassetid://132029940467197", -- fallback logo if none is given
        Name = "Hub",
        Version = "1.0.0",
    }

    local White = Color3.new(1, 1, 1)

    local function MakeTheme(Base, A1, A2)
        return {
            Window = Base,
            Panel = Base:Lerp(White, 0.045),
            Card = Base:Lerp(White, 0.09),
            CardAlt = Base:Lerp(White, 0.15),
            Stroke = Base:Lerp(White, 0.22),
            Track = Base:Lerp(White, 0.2),
            Text = Color3.fromRGB(240, 243, 255),
            Muted = Color3.fromRGB(150, 158, 182),
            Accent = A1,
            Accent2 = A2,
            Knob = White,
        }
    end

    Lib.Themes = {
        Default = MakeTheme(Color3.fromRGB(8, 17, 13), Color3.fromRGB(46, 216, 112), Color3.fromRGB(150, 232, 78)),
        Crimson = MakeTheme(Color3.fromRGB(17, 11, 14), Color3.fromRGB(240, 66, 90), Color3.fromRGB(255, 128, 72)),
        Ocean = MakeTheme(Color3.fromRGB(9, 17, 23), Color3.fromRGB(38, 198, 222), Color3.fromRGB(62, 128, 255)),
        Mint = MakeTheme(Color3.fromRGB(9, 18, 17), Color3.fromRGB(40, 210, 170), Color3.fromRGB(30, 168, 206)),
        Sunset = MakeTheme(Color3.fromRGB(20, 13, 13), Color3.fromRGB(255, 152, 62), Color3.fromRGB(255, 82, 130)),
    }

    local function Safe(Fn, ...)
        if type(Fn) ~= "function" then
            return
        end
        local Ok, Err = pcall(Fn, ...)
        if not Ok then
            warn("[HubUI] " .. tostring(Err))
        end
    end

    local function ResolveParent()
        local Ok, Hui = pcall(function()
            return gethui and gethui()
        end)
        if Ok and Hui then
            return Hui
        end
        local CoreOk = pcall(function()
            local Probe = Instance.new("Folder")
            Probe.Parent = game:GetService("CoreGui")
            Probe:Destroy()
        end)
        if CoreOk then
            return game:GetService("CoreGui")
        end
        return Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    function Lib.CreateWindow(Opts)
        Opts = Opts or {}
        local Window = {
            Tabs = {},
            Visible = true,
            Theme = Lib.Themes[Opts.Theme or "Default"] or Lib.Themes.Default,
            ThemeName = Opts.Theme or "Default",
        }
        local Conns, Binds, DestroyCallbacks = {}, {}, {}
        local Destroyed = false
        local Touch = UserInputService.TouchEnabled
        local Camera = workspace.CurrentCamera
        local ToggleKey = Opts.ToggleKey or Enum.KeyCode.RightShift
        local LogoImage = (Opts.Logo and Opts.Logo ~= "") and Opts.Logo or Lib.Logo
        local Title = Opts.Name or Lib.Name
        local function CleanId(S)
            local Out = tostring(S):gsub("[^%w_%-]", "")
            if Out == "" then
                Out = "Hub"
            end
            return Out
        end
        local GuiName = Opts.GuiName or ("HubUI_" .. CleanId(Title))
        local function FormatSub(S)
            if S == nil or S == "" then
                return ""
            end
            return "[ " .. tostring(S) .. " ]"
        end

        local function Connect(Signal, Fn)
            local C = Signal:Connect(Fn)
            Conns[#Conns + 1] = C
            return C
        end

        local function Tween(Inst, Time, Props)
            local T = TweenService:Create(Inst, TweenInfo.new(Time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), Props)
            T:Play()
            return T
        end

        ----------------------------------------------------------------
        -- Theme binding helpers
        ----------------------------------------------------------------
        local function ApplyBind(B)
            local Value
            if type(B.Get) == "function" then
                Value = B.Get(Window.Theme)
            else
                Value = Window.Theme[B.Get]
            end
            pcall(function()
                B.Inst[B.Prop] = Value
            end)
        end

        local function Bind(Inst, Prop, Get)
            local B = {Inst = Inst, Prop = Prop, Get = Get}
            Binds[#Binds + 1] = B
            ApplyBind(B)
            return B
        end

        local function Make(Class, Props, ThemeProps)
            local Inst = Instance.new(Class)
            local Parent
            for K, V in pairs(Props or {}) do
                if K == "Parent" then
                    Parent = V
                else
                    Inst[K] = V
                end
            end
            if ThemeProps then
                for Prop, Get in pairs(ThemeProps) do
                    Bind(Inst, Prop, Get)
                end
            end
            if Parent then
                Inst.Parent = Parent
            end
            return Inst
        end

        local function Corner(Parent, Radius)
            return Make("UICorner", {CornerRadius = UDim.new(0, Radius), Parent = Parent})
        end

        local function Stroke(Parent, Key, Thickness)
            return Make("UIStroke", {Thickness = Thickness or 1, Parent = Parent}, {Color = Key})
        end

        local function Pad(Parent, Top, Bottom, Left, Right)
            return Make("UIPadding", {
                PaddingTop = UDim.new(0, Top),
                PaddingBottom = UDim.new(0, Bottom),
                PaddingLeft = UDim.new(0, Left),
                PaddingRight = UDim.new(0, Right),
                Parent = Parent,
            })
        end

        local function Label(Props, Key)
            Props.BackgroundTransparency = 1
            Props.BorderSizePixel = 0
            Props.Font = Props.Font or Enum.Font.Gotham
            Props.TextSize = Props.TextSize or 13
            Props.TextXAlignment = Props.TextXAlignment or Enum.TextXAlignment.Left
            return Make("TextLabel", Props, {TextColor3 = Key or "Text"})
        end

        ----------------------------------------------------------------
        -- Screen helpers
        ----------------------------------------------------------------
        local function ClampXY(X, Y, Size)
            local VP = Camera.ViewportSize
            return math.clamp(X, 0, math.max(0, VP.X - Size.X)), math.clamp(Y, 0, math.max(0, VP.Y - Size.Y))
        end

        local function WindowSize()
            local VP = Camera.ViewportSize
            return Vector2.new(math.min(530, VP.X - 12), math.min(390, VP.Y - 12))
        end

        ----------------------------------------------------------------
        -- Shared drag handling (window, button, sliders)
        ----------------------------------------------------------------
        local ActiveDrag = nil

        local function BeginDrag(Input, OnMove, OnEnd)
            ActiveDrag = {Input = Input, Start = Input.Position, OnMove = OnMove, OnEnd = OnEnd}
        end

        Connect(UserInputService.InputChanged, function(Input)
            local D = ActiveDrag
            if not D then
                return
            end
            if Input == D.Input or Input.UserInputType == Enum.UserInputType.MouseMovement then
                D.OnMove(Input.Position, D.Start)
            end
        end)

        Connect(UserInputService.InputEnded, function(Input)
            local D = ActiveDrag
            if not D then
                return
            end
            local SameMouse = D.Input.UserInputType == Enum.UserInputType.MouseButton1
                and Input.UserInputType == Enum.UserInputType.MouseButton1
            if Input == D.Input or SameMouse then
                ActiveDrag = nil
                if D.OnEnd then
                    D.OnEnd()
                end
            end
        end)

        local function IsPress(Input)
            return Input.UserInputType == Enum.UserInputType.MouseButton1
                or Input.UserInputType == Enum.UserInputType.Touch
        end

        local function MakeDraggable(Handle, Target, Click)
            Handle.InputBegan:Connect(function(Input)
                if not IsPress(Input) then
                    return
                end
                local StartX, StartY = Target.Position.X.Offset, Target.Position.Y.Offset
                local Size = Vector2.new(Target.Size.X.Offset, Target.Size.Y.Offset)
                local Moved = false
                BeginDrag(Input, function(Pos, Start)
                    local Delta = Pos - Start
                    if not Moved and Delta.Magnitude < 6 then
                        return
                    end
                    Moved = true
                    local X, Y = ClampXY(StartX + Delta.X, StartY + Delta.Y, Size)
                    Target.Position = UDim2.fromOffset(X, Y)
                end, function()
                    if not Moved and Click then
                        Click()
                    end
                end)
            end)
        end

        ----------------------------------------------------------------
        -- Root GUI
        ----------------------------------------------------------------
        local Parent = ResolveParent()
        pcall(function()
            local Old = Parent:FindFirstChild(GuiName)
            if Old then
                Old:Destroy()
            end
        end)

        local Gui = Make("ScreenGui", {
            Name = GuiName,
            ResetOnSpawn = false,
            IgnoreGuiInset = true,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder = 999,
        })
        pcall(function()
            if syn and syn.protect_gui then
                syn.protect_gui(Gui)
            end
        end)
        Gui.Parent = Parent

        local StartSize = WindowSize()
        local Main = Make("Frame", {
            Name = "Window",
            Size = UDim2.fromOffset(StartSize.X, StartSize.Y),
            Position = UDim2.fromOffset(
                math.floor((Camera.ViewportSize.X - StartSize.X) / 2),
                math.floor((Camera.ViewportSize.Y - StartSize.Y) / 2)
            ),
            BorderSizePixel = 0,
            Active = true,
            Parent = Gui,
        }, {BackgroundColor3 = "Window"})
        local Scale = Make("UIScale", {Parent = Main})
        Corner(Main, 14)
        Stroke(Main, "Stroke", 1.5)

        -- Icons (sprite sheet coordinates)
        local IconSheet = {
            footprints = {16898613353, 918, 710},
            crosshair = {16898613044, 453, 869},
            ["rotate-cw"] = {16898613699, 869, 453},
            gift = {16898613613, 918, 196},
            map = {16898613613, 820, 257},
            wrench = {16898613777, 771, 257},
            settings = {16898613777, 771, 257},
            home = {16898613777, 771, 257},
        }
        local function SetIcon(Image, Name)
            local S = IconSheet[Name]
            if S then
                Image.Image = "rbxassetid://" .. S[1]
                Image.ImageRectSize = Vector2.new(48, 48)
                Image.ImageRectOffset = Vector2.new(S[2], S[3])
                Image.Visible = true
            else
                Image.Visible = false
            end
        end

        -- Sidebar
        local SideW = 168
        local Sidebar = Make("Frame", {
            Name = "Sidebar",
            Size = UDim2.new(0, SideW, 1, 0),
            BackgroundTransparency = 1,
            Parent = Main,
        })
        Make("Frame", {
            Size = UDim2.new(0, 1, 1, 0),
            Position = UDim2.fromOffset(SideW, 0),
            BorderSizePixel = 0,
            Parent = Main,
        }, {BackgroundColor3 = "Stroke"})

        local Brand = Make("Frame", {
            Name = "Brand",
            Size = UDim2.new(1, -16, 0, 54),
            Position = UDim2.fromOffset(8, 8),
            BackgroundColor3 = White,
            BorderSizePixel = 0,
            Active = true,
            Parent = Sidebar,
        })
        Corner(Brand, 12)
        Stroke(Brand, "Stroke", 1)
        local BrandGradient = Make("UIGradient", {Rotation = 90, Parent = Brand})
        Bind(BrandGradient, "Color", function(T)
            return ColorSequence.new(T.CardAlt:Lerp(T.Accent, 0.35), T.Card)
        end)
        local Logo = Make("ImageLabel", {
            Size = UDim2.fromOffset(36, 36),
            Position = UDim2.fromOffset(10, 9),
            BackgroundTransparency = 1,
            Image = LogoImage,
            ScaleType = Enum.ScaleType.Fit,
            Parent = Brand,
        })
        Corner(Logo, 8)
        local TitleLabel = Label({
            Text = Title,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            Size = UDim2.new(1, -56, 0, 18),
            Position = UDim2.fromOffset(54, 10),
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = Brand,
        }, "Text")
        local SubtitleLabel = Label({
            Text = FormatSub(Opts.Subtitle),
            TextSize = 11,
            Size = UDim2.new(1, -56, 0, 14),
            Position = UDim2.fromOffset(54, 29),
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = Brand,
        }, "Muted")
        MakeDraggable(Brand, Main)

        local SearchBox = Make("TextBox", {
            Size = UDim2.new(1, -16, 0, 32),
            Position = UDim2.fromOffset(8, 70),
            Text = "",
            PlaceholderText = "Search...",
            ClearTextOnFocus = false,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderSizePixel = 0,
            Parent = Sidebar,
        }, {BackgroundColor3 = "Card", TextColor3 = "Text", PlaceholderColor3 = "Muted"})
        Corner(SearchBox, 10)
        Stroke(SearchBox, "Stroke", 1)
        Pad(SearchBox, 0, 0, 12, 8)

        local TabScroll = Make("ScrollingFrame", {
            Position = UDim2.fromOffset(0, 110),
            Size = UDim2.new(1, 0, 1, -118),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 0,
            CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            Parent = Sidebar,
        })
        Make("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = TabScroll})
        Pad(TabScroll, 2, 30, 8, 8)

        local Chevron = Make("TextButton", {
            Size = UDim2.fromOffset(54, 24),
            AnchorPoint = Vector2.new(0.5, 1),
            Position = UDim2.new(0.5, 0, 1, -8),
            Text = "v",
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            AutoButtonColor = false,
            BorderSizePixel = 0,
            ZIndex = 4,
            Parent = Sidebar,
        }, {BackgroundColor3 = "Card", TextColor3 = "Accent"})
        Corner(Chevron, 12)
        local function UpdateChevron()
            local Hidden = TabScroll.AbsoluteCanvasSize.Y - TabScroll.AbsoluteSize.Y
            Chevron.Visible = Hidden > 4 and TabScroll.CanvasPosition.Y < Hidden - 4
        end
        Connect(TabScroll:GetPropertyChangedSignal("CanvasPosition"), UpdateChevron)
        Connect(TabScroll:GetPropertyChangedSignal("AbsoluteCanvasSize"), UpdateChevron)
        Connect(TabScroll:GetPropertyChangedSignal("AbsoluteSize"), UpdateChevron)
        Chevron.MouseButton1Click:Connect(function()
            local Hidden = TabScroll.AbsoluteCanvasSize.Y - TabScroll.AbsoluteSize.Y
            Tween(TabScroll, 0.2, {CanvasPosition = Vector2.new(0, math.max(0, Hidden))})
        end)

        -- Right side: header + pages
        local Right = Make("Frame", {
            Name = "Right",
            Position = UDim2.fromOffset(SideW + 1, 0),
            Size = UDim2.new(1, -(SideW + 1), 1, 0),
            BackgroundTransparency = 1,
            Parent = Main,
        })
        local Header = Make("Frame", {
            Name = "Header",
            Size = UDim2.new(1, 0, 0, 58),
            BackgroundTransparency = 1,
            Active = true,
            Parent = Right,
        })
        local HeaderIcon = Make("ImageLabel", {
            Size = UDim2.fromOffset(28, 28),
            Position = UDim2.fromOffset(14, 15),
            BackgroundTransparency = 1,
            Parent = Header,
        }, {ImageColor3 = "Text"})
        local HeaderTitle = Label({
            Text = "",
            Font = Enum.Font.GothamBold,
            TextSize = 15,
            Size = UDim2.new(1, -110, 0, 18),
            Position = UDim2.fromOffset(52, 11),
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = Header,
        }, "Text")
        local HeaderSub = Label({
            Text = "",
            TextSize = 11,
            Size = UDim2.new(1, -110, 0, 14),
            Position = UDim2.fromOffset(52, 31),
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = Header,
        }, "Muted")
        local CloseButton = Make("TextButton", {
            Size = UDim2.fromOffset(26, 26),
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -12, 0.5, 0),
            Text = "X",
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            AutoButtonColor = false,
            BorderSizePixel = 0,
            Parent = Header,
        }, {BackgroundColor3 = "CardAlt", TextColor3 = "Text"})
        Corner(CloseButton, 8)
        MakeDraggable(Header, Main)
        Make("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.fromOffset(0, 58),
            BorderSizePixel = 0,
            Parent = Right,
        }, {BackgroundColor3 = "Stroke"})

        local Content = Make("Frame", {
            Name = "Content",
            Position = UDim2.fromOffset(0, 59),
            Size = UDim2.new(1, 0, 1, -59),
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Parent = Right,
        })

        ----------------------------------------------------------------
        -- Open / close button (square, bordered, draggable, logo)
        ----------------------------------------------------------------
        local ButtonSize = Touch and 50 or 54
        local OpenButton = Make("Frame", {
            Name = "OpenButton",
            Size = UDim2.fromOffset(ButtonSize, ButtonSize),
            Position = UDim2.fromOffset(16, math.floor(Camera.ViewportSize.Y * 0.42)),
            BorderSizePixel = 0,
            Active = true,
            ZIndex = 10,
            Parent = Gui,
        }, {BackgroundColor3 = "Window"})
        Corner(OpenButton, 14)
        local ButtonStroke = Make("UIStroke", {Thickness = 2.5, Color = White, Parent = OpenButton})
        local ButtonGradient = Make("UIGradient", {Parent = ButtonStroke})
        Bind(ButtonGradient, "Color", function(T)
            return ColorSequence.new(T.Accent, T.Accent2)
        end)
        local ButtonScale = Make("UIScale", {Parent = OpenButton})
        local ButtonLogo = Make("ImageLabel", {
            Size = UDim2.new(1, -12, 1, -12),
            Position = UDim2.fromOffset(6, 6),
            BackgroundTransparency = 1,
            Image = LogoImage,
            ScaleType = Enum.ScaleType.Fit,
            ZIndex = 11,
            Parent = OpenButton,
        })
        Corner(ButtonLogo, 10)

        Connect(RunService.Heartbeat, function()
            ButtonGradient.Rotation = (os.clock() * 80) % 360
        end)

        ----------------------------------------------------------------
        -- Show / hide
        ----------------------------------------------------------------
        local VisToken = 0
        function Window:SetVisible(V)
            if Destroyed then
                return
            end
            V = V == true
            VisToken += 1
            local Token = VisToken
            Window.Visible = V
            if V then
                Main.Visible = true
                Scale.Scale = 0.9
                Tween(Scale, 0.18, {Scale = 1})
            else
                Tween(Scale, 0.12, {Scale = 0.9})
                task.delay(0.13, function()
                    if Token == VisToken and not Destroyed then
                        Main.Visible = false
                    end
                end)
            end
        end

        function Window:Toggle()
            Window:SetVisible(not Window.Visible)
        end

        MakeDraggable(OpenButton, OpenButton, function()
            Tween(ButtonScale, 0.08, {Scale = 0.88})
            task.delay(0.09, function()
                if not Destroyed then
                    Tween(ButtonScale, 0.14, {Scale = 1})
                end
            end)
            Window:Toggle()
        end)

        CloseButton.MouseButton1Click:Connect(function()
            Window:SetVisible(false)
        end)

        Connect(UserInputService.InputBegan, function(Input, Processed)
            if Processed or UserInputService:GetFocusedTextBox() then
                return
            end
            if Input.KeyCode == ToggleKey then
                Window:Toggle()
            end
        end)

        function Window:SetToggleKey(Key)
            if typeof(Key) == "EnumItem" then
                ToggleKey = Key
            end
        end

        local function Relayout()
            Camera = workspace.CurrentCamera or Camera
            local S = WindowSize()
            Main.Size = UDim2.fromOffset(S.X, S.Y)
            local X, Y = ClampXY(Main.Position.X.Offset, Main.Position.Y.Offset, S)
            Main.Position = UDim2.fromOffset(X, Y)
            local BS = Vector2.new(ButtonSize, ButtonSize)
            local BX, BY = ClampXY(OpenButton.Position.X.Offset, OpenButton.Position.Y.Offset, BS)
            OpenButton.Position = UDim2.fromOffset(BX, BY)
        end
        if Camera then
            Connect(Camera:GetPropertyChangedSignal("ViewportSize"), Relayout)
        end

        ----------------------------------------------------------------
        -- Transparency
        ----------------------------------------------------------------
        function Window:ToggleTransparency(On)
            Tween(Main, 0.2, {BackgroundTransparency = On and 0.06 or 0})
        end
        Main.BackgroundTransparency = 0.06

        ----------------------------------------------------------------
        -- Notifications
        ----------------------------------------------------------------
        local ToastHolder = Make("Frame", {
            Name = "Toasts",
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.new(0.5, 0, 0, 14),
            Size = UDim2.fromOffset(Touch and 240 or 290, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            ZIndex = 20,
            Parent = Gui,
        })
        Make("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Parent = ToastHolder,
        })

        function Window:Notify(N)
            if Destroyed then
                return
            end
            N = N or {}
            local Toast = Make("CanvasGroup", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BorderSizePixel = 0,
                GroupTransparency = 1,
                Parent = ToastHolder,
            }, {BackgroundColor3 = "Card"})
            Corner(Toast, 10)
            Stroke(Toast, "Accent", 1.2)
            Pad(Toast, 8, 8, 12, 12)
            Make("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Toast})
            Label({
                Text = tostring(N.Title or Title),
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                TextWrapped = true,
                LayoutOrder = 1,
                Parent = Toast,
            }, "Accent")
            if N.Content and tostring(N.Content) ~= "" then
                Label({
                    Text = tostring(N.Content),
                    TextSize = 12,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    TextWrapped = true,
                    LayoutOrder = 2,
                    Parent = Toast,
                }, "Text")
            end
            Tween(Toast, 0.2, {GroupTransparency = 0})
            task.delay(tonumber(N.Duration) or 3, function()
                if Destroyed or not Toast.Parent then
                    return
                end
                local T = Tween(Toast, 0.25, {GroupTransparency = 1})
                T.Completed:Wait()
                Toast:Destroy()
            end)
            return Toast
        end

        ----------------------------------------------------------------
        -- Tabs and elements
        ----------------------------------------------------------------
        local function StyleTabs()
            for _, Tab in ipairs(Window.Tabs) do
                Tab._Style()
            end
        end

        function Window:SelectTab(Which)
            local Target = Which
            if type(Which) == "number" then
                Target = Window.Tabs[Which]
            end
            if not Target then
                return
            end
            Window.Selected = Target
            HeaderTitle.Text = Target.Name
            HeaderSub.Text = Target.Desc or ""
            SetIcon(HeaderIcon, Target.Icon)
            for _, Tab in ipairs(Window.Tabs) do
                Tab._Page.Visible = Tab == Target
            end
            StyleTabs()
        end

        local function NewElement(Card)
            return setmetatable({}, {
                __index = function(_, Key)
                    if Key == "Parent" then
                        return Card.Parent
                    end
                    return nil
                end,
            })
        end

        Connect(SearchBox:GetPropertyChangedSignal("Text"), function()
            local Q = string.lower(SearchBox.Text)
            for _, Tab in ipairs(Window.Tabs) do
                Tab._Button.Visible = Q == "" or string.find(string.lower(Tab.Name), Q, 1, true) ~= nil
            end
        end)

        function Window:Tab(Cfg)
            Cfg = Cfg or {}
            local TabName = Cfg.Title or Cfg.Name or "Tab"
            local Tab = {Name = TabName, Icon = Cfg.Icon, Desc = Cfg.Desc}
            local Index = #Window.Tabs + 1
            local Order = 0
            local function NextOrder()
                Order += 1
                return Order
            end

            local Button = Make("TextButton", {
                Name = TabName,
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundTransparency = 1,
                AutoButtonColor = false,
                Text = "",
                BorderSizePixel = 0,
                LayoutOrder = Index,
                Parent = TabScroll,
            }, {BackgroundColor3 = "Card"})
            Corner(Button, 10)
            local ButtonStroke2 = Stroke(Button, "Stroke", 1)
            ButtonStroke2.Transparency = 1
            local Indicator = Make("Frame", {
                Size = UDim2.fromOffset(3, 18),
                Position = UDim2.new(0, 3, 0.5, -9),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = Button,
            }, {BackgroundColor3 = "Accent"})
            Corner(Indicator, 2)
            local TabIcon = Make("ImageLabel", {
                Size = UDim2.fromOffset(20, 20),
                Position = UDim2.fromOffset(14, 10),
                BackgroundTransparency = 1,
                Parent = Button,
            })
            SetIcon(TabIcon, Cfg.Icon)
            local TabLabel = Label({
                Text = TabName,
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                Size = UDim2.new(1, -48, 1, 0),
                Position = UDim2.fromOffset(Cfg.Icon and IconSheet[Cfg.Icon] and 44 or 16, 0),
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = Button,
            }, "Muted")

            local Page = Make("ScrollingFrame", {
                Name = TabName,
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 3,
                CanvasSize = UDim2.new(),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollingDirection = Enum.ScrollingDirection.Y,
                Visible = false,
                Parent = Content,
            }, {ScrollBarImageColor3 = "Accent"})
            Make("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Page})
            Pad(Page, 8, 8, 8, 10)

            Tab._Page = Page
            Tab._Style = function()
                local Selected = Window.Selected == Tab
                Tween(Button, 0.15, {BackgroundTransparency = Selected and 0 or 1})
                Tween(Indicator, 0.15, {BackgroundTransparency = Selected and 0 or 1})
                Tween(ButtonStroke2, 0.15, {Transparency = Selected and 0 or 1})
                TabLabel.TextColor3 = Selected and Window.Theme.Text or Window.Theme.Muted
                TabIcon.ImageColor3 = Selected and Window.Theme.Accent or Window.Theme.Muted
            end

            Button.MouseButton1Click:Connect(function()
                Window:SelectTab(Tab)
            end)

            Window.Tabs[Index] = Tab
            Tab._Button = Button

            local function Register(C, Obj, Default)
                if C.Title and Opts.OnRegister then
                    Opts.OnRegister(TabName .. "_" .. C.Title, Obj, Default)
                end
            end

            local function MakeCard()
                local Card = Make("Frame", {
                    Size = UDim2.new(1, 0, 0, 46),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BorderSizePixel = 0,
                    LayoutOrder = NextOrder(),
                    Parent = Page,
                }, {BackgroundColor3 = "Card"})
                Corner(Card, 8)
                Stroke(Card, "Stroke", 1)
                Pad(Card, 9, 9, 12, 12)
                return Card
            end

            local function TextBlock(Card, TitleText, DescText, Reserve, Center, TitleKey)
                local Holder = Make("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -(Reserve or 0), 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    LayoutOrder = 1,
                    Parent = Card,
                })
                Make("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Holder})
                local Align = Center and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
                local T = Label({
                    Text = tostring(TitleText or ""),
                    Font = Enum.Font.GothamMedium,
                    TextSize = 14,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    TextWrapped = true,
                    TextXAlignment = Align,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    LayoutOrder = 1,
                    Parent = Holder,
                }, TitleKey or "Text")
                local D = Label({
                    Text = tostring(DescText or ""),
                    TextSize = 12,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    TextWrapped = true,
                    TextXAlignment = Align,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    Visible = DescText ~= nil and tostring(DescText) ~= "",
                    LayoutOrder = 2,
                    Parent = Holder,
                }, "Muted")
                return Holder, T, D
            end

            function Tab:Select()
                Window:SelectTab(Tab)
            end

            function Tab:Section(C)
                local Holder = Make("Frame", {
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    LayoutOrder = NextOrder(),
                    Parent = Page,
                })
                local Bar = Make("Frame", {
                    Size = UDim2.fromOffset(3, 12),
                    Position = UDim2.fromOffset(2, 8),
                    BorderSizePixel = 0,
                    Parent = Holder,
                }, {BackgroundColor3 = "Accent"})
                Corner(Bar, 2)
                Label({
                    Text = tostring(C.Title or ""),
                    Font = Enum.Font.GothamBold,
                    TextSize = 12,
                    Size = UDim2.new(1, -14, 1, 0),
                    Position = UDim2.fromOffset(12, 4),
                    Parent = Holder,
                }, "Accent")
                return Holder
            end

            function Tab:Divider()
                return Make("Frame", {
                    Size = UDim2.new(1, 0, 0, 1),
                    BorderSizePixel = 0,
                    LayoutOrder = NextOrder(),
                    Parent = Page,
                }, {BackgroundColor3 = "Stroke"})
            end

            function Tab:Paragraph(C)
                local Card = MakeCard()
                local _, T, D = TextBlock(Card, C.Title, C.Desc, 0)
                local Obj = NewElement(Card)
                function Obj:SetTitle(Text)
                    T.Text = tostring(Text or "")
                end
                function Obj:SetDesc(Text)
                    Text = tostring(Text or "")
                    D.Text = Text
                    D.Visible = Text ~= ""
                end
                return Obj
            end

            function Tab:Toggle(C)
                local Card = MakeCard()
                TextBlock(Card, C.Title, C.Desc, 56)
                local State = C.Value == true
                local Track = Make("Frame", {
                    Size = UDim2.fromOffset(42, 22),
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    BorderSizePixel = 0,
                    Parent = Card,
                })
                Corner(Track, 11)
                Bind(Track, "BackgroundColor3", function(T)
                    return State and T.Accent or T.Track
                end)
                local Knob = Make("Frame", {
                    Size = UDim2.fromOffset(16, 16),
                    Position = UDim2.fromOffset(State and 23 or 3, 3),
                    BorderSizePixel = 0,
                    Parent = Track,
                }, {BackgroundColor3 = "Knob"})
                Corner(Knob, 8)
                local Click = Make("TextButton", {
                    Size = UDim2.fromScale(1, 1),
                    BackgroundTransparency = 1,
                    Text = "",
                    ZIndex = 5,
                    Parent = Card,
                })

                local Obj = NewElement(Card)
                function Obj:Set(V, Silent)
                    State = V == true
                    Tween(Track, 0.15, {BackgroundColor3 = State and Window.Theme.Accent or Window.Theme.Track})
                    Tween(Knob, 0.15, {Position = UDim2.fromOffset(State and 23 or 3, 3)})
                    if not Silent then
                        Safe(C.Callback, State)
                    end
                end
                function Obj:Get()
                    return State
                end
                Click.MouseButton1Click:Connect(function()
                    Obj:Set(not State)
                end)
                Register(C, Obj, State)
                return Obj
            end

            function Tab:Slider(C)
                local Range = type(C.Value) == "table" and C.Value or {}
                local Min, Max = Range.Min or 0, Range.Max or 100
                local Step = C.Step or 1
                local Value = math.clamp(Range.Default or Min, Min, Max)
                local Default = Value

                local Card = MakeCard()
                Make("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Card})

                local Row = Make("Frame", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    LayoutOrder = 1,
                    Parent = Card,
                })
                Label({
                    Text = tostring(C.Title or ""),
                    Font = Enum.Font.GothamMedium,
                    TextSize = 14,
                    Size = UDim2.new(1, -64, 1, 0),
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = Row,
                }, "Text")
                local ValueLabel = Label({
                    Font = Enum.Font.GothamBold,
                    TextSize = 13,
                    AnchorPoint = Vector2.new(1, 0),
                    Size = UDim2.new(0, 60, 1, 0),
                    Position = UDim2.new(1, 0, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = Row,
                }, "Accent")
                if C.Desc and C.Desc ~= "" then
                    Label({
                        Text = tostring(C.Desc),
                        TextSize = 12,
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        TextWrapped = true,
                        TextYAlignment = Enum.TextYAlignment.Top,
                        LayoutOrder = 2,
                        Parent = Card,
                    }, "Muted")
                end

                local Holder = Make("Frame", {
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    Active = true,
                    LayoutOrder = 3,
                    Parent = Card,
                })
                local TrackArea = Make("Frame", {
                    Size = UDim2.new(1, -16, 1, 0),
                    Position = UDim2.fromOffset(8, 0),
                    BackgroundTransparency = 1,
                    Parent = Holder,
                })
                local Bar = Make("Frame", {
                    Size = UDim2.new(1, 0, 0, 6),
                    Position = UDim2.new(0, 0, 0.5, -3),
                    BorderSizePixel = 0,
                    Parent = TrackArea,
                }, {BackgroundColor3 = "Track"})
                Corner(Bar, 3)
                local Fill = Make("Frame", {
                    Size = UDim2.fromScale(0, 1),
                    BorderSizePixel = 0,
                    Parent = Bar,
                }, {BackgroundColor3 = "Accent"})
                Corner(Fill, 3)
                local Knob = Make("Frame", {
                    Size = UDim2.fromOffset(16, 16),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0, 0.5),
                    BorderSizePixel = 0,
                    Parent = TrackArea,
                }, {BackgroundColor3 = "Knob"})
                Corner(Knob, 8)
                Stroke(Knob, "Accent", 2)

                local function Format(V)
                    if Step >= 1 then
                        return tostring(math.floor(V + 0.5))
                    end
                    local S = string.format("%.2f", V)
                    S = S:gsub("0+$", "")
                    S = S:gsub("%.$", "")
                    return S
                end

                local function Snap(V)
                    V = Min + math.floor((V - Min) / Step + 0.5) * Step
                    V = math.clamp(V, Min, Max)
                    return tonumber(string.format("%.4f", V))
                end

                local function Visual()
                    local Alpha = Max > Min and (Value - Min) / (Max - Min) or 0
                    Fill.Size = UDim2.fromScale(Alpha, 1)
                    Knob.Position = UDim2.fromScale(Alpha, 0.5)
                    ValueLabel.Text = Format(Value)
                end
                Visual()

                local Obj = NewElement(Card)
                function Obj:Set(V, Silent)
                    V = tonumber(V)
                    if not V then
                        return
                    end
                    Value = Snap(V)
                    Visual()
                    if not Silent then
                        Safe(C.Callback, Value)
                    end
                end
                function Obj:Get()
                    return Value
                end

                local function FromX(X)
                    local Width = math.max(TrackArea.AbsoluteSize.X, 1)
                    local Alpha = math.clamp((X - TrackArea.AbsolutePosition.X) / Width, 0, 1)
                    local New = Snap(Min + (Max - Min) * Alpha)
                    if New ~= Value then
                        Value = New
                        Visual()
                        Safe(C.Callback, Value)
                    end
                end

                Holder.InputBegan:Connect(function(Input)
                    if not IsPress(Input) then
                        return
                    end
                    Page.ScrollingEnabled = false
                    FromX(Input.Position.X)
                    BeginDrag(Input, function(Pos)
                        FromX(Pos.X)
                    end, function()
                        Page.ScrollingEnabled = true
                    end)
                end)

                Register(C, Obj, Default)
                return Obj
            end

            function Tab:Dropdown(C)
                local Options = {}
                for _, V in ipairs(C.Values or {}) do
                    Options[#Options + 1] = tostring(V)
                end
                local Value = C.Value
                if type(Value) == "table" then
                    Value = Value[1]
                end
                Value = Value ~= nil and tostring(Value) or Options[1]
                local Default = Value
                local Open = false

                local Card = MakeCard()
                Make("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Card})

                local Row = Make("Frame", {
                    Size = UDim2.new(1, 0, 0, 30),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    LayoutOrder = 1,
                    Parent = Card,
                })
                TextBlock(Row, C.Title, C.Desc, 128)
                local Pill = Make("Frame", {
                    Size = UDim2.fromOffset(116, 28),
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    BorderSizePixel = 0,
                    Parent = Row,
                }, {BackgroundColor3 = "CardAlt"})
                Corner(Pill, 7)
                Stroke(Pill, "Stroke", 1)
                local ValueText = Label({
                    Text = Value or "",
                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,
                    Size = UDim2.new(1, -26, 1, 0),
                    Position = UDim2.fromOffset(9, 0),
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = Pill,
                }, "Text")
                local Arrow = Label({
                    Text = "v",
                    Font = Enum.Font.GothamBold,
                    TextSize = 12,
                    Size = UDim2.fromOffset(16, 28),
                    Position = UDim2.new(1, -20, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Center,
                    Parent = Pill,
                }, "Accent")
                local RowButton = Make("TextButton", {
                    Size = UDim2.fromScale(1, 1),
                    BackgroundTransparency = 1,
                    Text = "",
                    ZIndex = 5,
                    Parent = Row,
                })

                local List = Make("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Visible = false,
                    LayoutOrder = 2,
                    Parent = Card,
                })
                Make("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder, Parent = List})

                local Obj = NewElement(Card)
                local OptionButtons = {}

                local function Highlight()
                    for Name, B in pairs(OptionButtons) do
                        B.TextColor3 = Name == Value and Window.Theme.Accent or Window.Theme.Text
                    end
                end

                local function SetOpen(State)
                    Open = State
                    List.Visible = Open
                    Arrow.Text = Open and "^" or "v"
                end

                local function Build()
                    for _, B in pairs(OptionButtons) do
                        B:Destroy()
                    end
                    table.clear(OptionButtons)
                    for I, Name in ipairs(Options) do
                        local B = Make("TextButton", {
                            Size = UDim2.new(1, 0, 0, 28),
                            Text = Name,
                            Font = Enum.Font.GothamMedium,
                            TextSize = 12,
                            AutoButtonColor = false,
                            BorderSizePixel = 0,
                            LayoutOrder = I,
                            Parent = List,
                        }, {BackgroundColor3 = "CardAlt"})
                        Corner(B, 6)
                        B.MouseButton1Click:Connect(function()
                            Obj:Set(Name)
                            SetOpen(false)
                        end)
                        OptionButtons[Name] = B
                    end
                    Highlight()
                end
                Build()

                function Obj:Set(V, Silent)
                    if type(V) == "table" then
                        V = V[1]
                    end
                    if V == nil then
                        return
                    end
                    Value = tostring(V)
                    ValueText.Text = Value
                    Highlight()
                    if not Silent then
                        Safe(C.Callback, Value)
                    end
                end
                function Obj:Select(V)
                    Obj:Set(V)
                end
                function Obj:Get()
                    return Value
                end
                function Obj:Refresh(NewValues)
                    Options = {}
                    for _, V in ipairs(NewValues or {}) do
                        Options[#Options + 1] = tostring(V)
                    end
                    Build()
                end

                RowButton.MouseButton1Click:Connect(function()
                    SetOpen(not Open)
                end)

                Register(C, Obj, Default)
                return Obj
            end

            function Tab:Button(C)
                local Card = MakeCard()
                Stroke(Card, "Accent", 1)
                TextBlock(Card, C.Title, C.Desc, 0, true, "Accent")
                local Click = Make("TextButton", {
                    Size = UDim2.fromScale(1, 1),
                    BackgroundTransparency = 1,
                    Text = "",
                    ZIndex = 5,
                    Parent = Card,
                })
                Click.MouseButton1Click:Connect(function()
                    Tween(Card, 0.08, {BackgroundColor3 = Window.Theme.CardAlt})
                    task.delay(0.15, function()
                        if Card.Parent then
                            Tween(Card, 0.15, {BackgroundColor3 = Window.Theme.Card})
                        end
                    end)
                    Safe(C.Callback)
                end)
                return NewElement(Card)
            end

            function Tab:Input(C)
                local Card = MakeCard()
                Make("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Card})
                TextBlock(Card, C.Title, C.Desc, 0)
                local Box = Make("TextBox", {
                    Size = UDim2.new(1, 0, 0, 30),
                    Text = tostring(C.Value or ""),
                    PlaceholderText = tostring(C.Placeholder or ""),
                    ClearTextOnFocus = false,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BorderSizePixel = 0,
                    LayoutOrder = 2,
                    Parent = Card,
                }, {BackgroundColor3 = "CardAlt", TextColor3 = "Text", PlaceholderColor3 = "Muted"})
                Corner(Box, 7)
                Pad(Box, 0, 0, 9, 9)
                local Default = Box.Text

                local Obj = NewElement(Card)
                function Obj:Set(V, Silent)
                    Box.Text = tostring(V or "")
                    if not Silent then
                        Safe(C.Callback, Box.Text)
                    end
                end
                function Obj:Get()
                    return Box.Text
                end
                Box.FocusLost:Connect(function()
                    Safe(C.Callback, Box.Text)
                end)
                Register(C, Obj, Default)
                return Obj
            end

            if Index == 1 then
                Window:SelectTab(Tab)
            else
                Tab._Style()
            end
            return Tab
        end

        ----------------------------------------------------------------
        -- Themes
        ----------------------------------------------------------------
        function Window:SetTheme(Name)
            local T = Lib.Themes[Name]
            if not T then
                return
            end
            Window.Theme = T
            Window.ThemeName = Name
            for I = #Binds, 1, -1 do
                local B = Binds[I]
                if not B.Inst.Parent and B.Inst ~= Gui then
                    table.remove(Binds, I)
                else
                    ApplyBind(B)
                end
            end
            StyleTabs()
        end

        ----------------------------------------------------------------
        -- Config saving
        ----------------------------------------------------------------
        local ConfigDir = Opts.ConfigDir or CleanId(Title)

        local function ConfigPath(Name)
            return ConfigDir .. "/" .. Name .. ".json"
        end

        Window.ConfigManager = {
            AllConfigs = function()
                local Out = {}
                pcall(function()
                    if listfiles and isfolder and isfolder(ConfigDir) then
                        for _, Path in ipairs(listfiles(ConfigDir)) do
                            local Name = tostring(Path):match("([^/\\]+)%.json$")
                            if Name then
                                Out[#Out + 1] = Name
                            end
                        end
                    end
                end)
                return Out
            end,
            CreateConfig = function(_, Name)
                local Cfg = {Name = Name, Items = {}}
                function Cfg:Register(Key, Element)
                    self.Items[Key] = Element
                end
                function Cfg:Save()
                    assert(writefile, "no file access")
                    if makefolder and isfolder and not isfolder(ConfigDir) then
                        makefolder(ConfigDir)
                    end
                    local Data = {}
                    for Key, Element in pairs(self.Items) do
                        local Ok, V = pcall(function()
                            return Element:Get()
                        end)
                        if Ok and V ~= nil then
                            Data[Key] = V
                        end
                    end
                    writefile(ConfigPath(Name), HttpService:JSONEncode(Data))
                end
                function Cfg:Load()
                    assert(isfile and readfile and isfile(ConfigPath(Name)), "config not found")
                    local Data = HttpService:JSONDecode(readfile(ConfigPath(Name)))
                    for Key, Element in pairs(self.Items) do
                        if Data[Key] ~= nil then
                            pcall(function()
                                Element:Set(Data[Key])
                            end)
                        end
                    end
                end
                function Cfg:Delete()
                    assert(delfile and isfile and isfile(ConfigPath(Name)), "config not found")
                    delfile(ConfigPath(Name))
                end
                return Cfg
            end,
        }

        ----------------------------------------------------------------
        -- Lifecycle
        ----------------------------------------------------------------
        function Window:SetTitle(Name)
            Title = tostring(Name)
            TitleLabel.Text = Title
        end

        function Window:SetSubtitle(Name)
            SubtitleLabel.Text = FormatSub(Name)
        end

        function Window:SetLogo(Id)
            if Id and Id ~= "" then
                LogoImage = Id
                Logo.Image = Id
                ButtonLogo.Image = Id
            end
        end

        function Window:GetConfigDir()
            return ConfigDir
        end

        function Window:OnDestroy(Fn)
            if type(Fn) == "function" then
                DestroyCallbacks[#DestroyCallbacks + 1] = Fn
            end
        end

        function Window:Destroy()
            if Destroyed then
                return
            end
            Destroyed = true
            ActiveDrag = nil
            for _, C in ipairs(Conns) do
                pcall(function()
                    C:Disconnect()
                end)
            end
            pcall(function()
                Gui:Destroy()
            end)
            for _, Fn in ipairs(DestroyCallbacks) do
                pcall(Fn)
            end
        end
        Window.Unload = Window.Destroy

        return Window
    end

    return Lib
end)()
