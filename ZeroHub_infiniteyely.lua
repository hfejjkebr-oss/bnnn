--[[
    Zero Hub Launcher
    Type a command in the bar: dex = ZeroDex, rspy = ZeroSpy
]]

local env = (getgenv and getgenv()) or _G
if env.__ZEROHUB_LAUNCHER then pcall(env.__ZEROHUB_LAUNCHER) end

local function svc(name)
    local s = game:GetService(name)
    if cloneref then
        local ok, c = pcall(cloneref, s)
        if ok and c then return c end
    end
    return s
end

local Players = svc("Players")
local UIS = svc("UserInputService")
local TweenService = svc("TweenService")

local LOGO = "rbxassetid://75862850530028"
local VERSION = "v1.0"
local IS_MOBILE = UIS.TouchEnabled and not UIS.KeyboardEnabled
local SOURCES = {}

local connections = {}
local alive = true
local function track(c)
    connections[#connections + 1] = c
    return c
end

local C = {
    bg = Color3.fromRGB(36, 36, 36),
    header = Color3.fromRGB(24, 24, 24),
    bar = Color3.fromRGB(46, 46, 46),
    row = Color3.fromRGB(36, 36, 36),
    rowHover = Color3.fromRGB(58, 58, 58),
    text = Color3.fromRGB(235, 235, 235),
    sub = Color3.fromRGB(160, 160, 160),
    accent = Color3.fromRGB(0, 170, 150),
    ok = Color3.fromRGB(90, 200, 130),
    bad = Color3.fromRGB(230, 90, 90),
}

local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local gui = new("ScreenGui", {
    Name = "ZeroHubLauncher",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

do
    local mounted = false
    if syn and syn.protect_gui then pcall(syn.protect_gui, gui) end
    if gethui then
        mounted = pcall(function() gui.Parent = gethui() end)
    end
    if not mounted or not gui.Parent then
        mounted = pcall(function() gui.Parent = svc("CoreGui") end)
    end
    if not mounted or not gui.Parent then
        local lp = Players.LocalPlayer
        while not lp do task.wait() lp = Players.LocalPlayer end
        gui.Parent = lp:WaitForChild("PlayerGui")
    end
end

local function cleanup()
    alive = false
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    pcall(function() gui:Destroy() end)
    if env.__ZEROHUB_LAUNCHER == cleanup then env.__ZEROHUB_LAUNCHER = nil end
end
env.__ZEROHUB_LAUNCHER = cleanup

local function isPointer(t)
    return t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch
end

local function makeDraggable(handle, target, onTap)
    local start, origin, moved
    track(handle.InputBegan:Connect(function(input)
        if isPointer(input.UserInputType) then
            start = input.Position
            origin = target.Position
            moved = false
            local ch
            ch = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    ch:Disconnect()
                    start = nil
                    if not moved and onTap then onTap() end
                end
            end)
        end
    end))
    track(UIS.InputChanged:Connect(function(input)
        if start and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - start
            if d.Magnitude > 6 then moved = true end
            if moved then
                target.Position = UDim2.new(origin.X.Scale, origin.X.Offset + d.X,
                    origin.Y.Scale, origin.Y.Offset + d.Y)
            end
        end
    end))
end

local PW = IS_MOBILE and 300 or 320
local PH = IS_MOBILE and 250 or 300
local HEAD_H = 28
local BAR_H = 28
local ROW_H = 26
local BTN = 44
local OPEN_POS = UDim2.new(1, -10, 1, -10)
local HIDE_POS = UDim2.new(1, -10, 1, PH + 30)

local function tween(o, t, props, style, dir)
    local tw = TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quad,
        dir or Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

local logoBtn = new("ImageButton", {
    Name = "Logo",
    Image = LOGO,
    BackgroundColor3 = C.header,
    AutoButtonColor = false,
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 70),
    Size = UDim2.fromOffset(BTN, BTN),
    BorderSizePixel = 0,
    ZIndex = 20,
}, gui)
new("UICorner", { CornerRadius = UDim.new(1, 0) }, logoBtn)
new("UIStroke", { Color = C.accent, Thickness = 2 }, logoBtn)

local panel = new("Frame", {
    Name = "Panel",
    AnchorPoint = Vector2.new(1, 1),
    Position = HIDE_POS,
    Size = UDim2.fromOffset(PW, PH),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 10,
    ClipsDescendants = true,
}, gui)
new("UICorner", { CornerRadius = UDim.new(0, 6) }, panel)
new("UIStroke", { Color = Color3.fromRGB(20, 20, 20), Thickness = 1 }, panel)

local header = new("Frame", {
    BackgroundColor3 = C.header,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, HEAD_H),
    Active = true,
    ZIndex = 11,
}, panel)

new("ImageLabel", {
    Image = LOGO,
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(6, 4),
    Size = UDim2.fromOffset(20, 20),
    ZIndex = 12,
}, header)

new("TextLabel", {
    Text = "Zero Hub " .. VERSION,
    Font = Enum.Font.SourceSansSemibold,
    TextSize = 17,
    TextColor3 = C.text,
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(32, 0),
    Size = UDim2.new(1, -96, 1, 0),
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 12,
}, header)

local function headBtn(text, x)
    return new("TextButton", {
        Text = text,
        Font = Enum.Font.SourceSansBold,
        TextSize = 17,
        TextColor3 = C.sub,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, x, 0, 0),
        Size = UDim2.fromOffset(28, HEAD_H),
        ZIndex = 13,
    }, header)
end
local infoBtn = headBtn("i", -34)
local closeBtn = headBtn("X", -4)

local box = new("TextBox", {
    Text = "",
    PlaceholderText = "Command Bar (;)",
    PlaceholderColor3 = C.sub,
    ClearTextOnFocus = false,
    Font = Enum.Font.SourceSans,
    TextSize = 18,
    TextColor3 = C.text,
    BackgroundColor3 = C.bar,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(0, HEAD_H),
    Size = UDim2.new(1, 0, 0, BAR_H),
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 11,
}, panel)
new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, box)

local status = new("TextLabel", {
    Text = "",
    Font = Enum.Font.SourceSans,
    TextSize = 15,
    TextColor3 = C.sub,
    BackgroundColor3 = C.header,
    BorderSizePixel = 0,
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.new(0, 0, 1, 0),
    Size = UDim2.new(1, 0, 0, 22),
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 11,
}, panel)
new("UIPadding", { PaddingLeft = UDim.new(0, 10) }, status)

local list = new("ScrollingFrame", {
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(0, HEAD_H + BAR_H),
    Size = UDim2.new(1, 0, 1, -(HEAD_H + BAR_H + 22)),
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = C.sub,
    ZIndex = 11,
}, panel)
new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, list)

local infoPage = new("TextLabel", {
    Text = "Zero Hub " .. VERSION .. "\n\nType a command and press Enter, or tap a command in the list.\n\ndex - open ZeroDex (explorer)\nrspy - open ZeroSpy (remote spy)\nhide - hide this panel\ndestroy - remove the launcher\n\nPC: press ; to focus the command bar.\nTap the logo to show / hide the panel. Drag the logo or the title bar to move.",
    Font = Enum.Font.SourceSans,
    TextSize = 16,
    TextColor3 = C.text,
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(0, HEAD_H),
    Size = UDim2.new(1, 0, 1, -(HEAD_H + 22)),
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    Visible = false,
    ZIndex = 15,
}, panel)
new("UIPadding", {
    PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 8),
}, infoPage)

local splash = new("ImageLabel", {
    Name = "Splash",
    Image = LOGO,
    BackgroundTransparency = 1,
    ImageTransparency = 1,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(90, 90),
    ZIndex = 20,
}, panel)

local statusToken = 0
local function setStatus(text, color)
    statusToken = statusToken + 1
    local mine = statusToken
    status.Text = text
    status.TextColor3 = color or C.sub
    task.delay(4, function()
        if alive and statusToken == mine then status.Text = "" end
    end)
end

local opened = false
local introActive = false
local lastTouch = os.clock()
local setOpen

local function poke()
    lastTouch = os.clock()
end

local function touch()
    lastTouch = os.clock()
    introActive = false
end

setOpen = function(v)
    if v == opened then
        if v then touch() end
        return
    end
    opened = v
    if v then
        touch()
        panel.Visible = true
        tween(panel, 0.4, { Position = OPEN_POS }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    else
        infoPage.Visible = false
        box:ReleaseFocus()
        local tw = tween(panel, 0.3, { Position = HIDE_POS }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tw.Completed:Connect(function()
            if not opened then panel.Visible = false end
        end)
    end
end

local function intro()
    splash.ImageTransparency = 1
    splash.Size = UDim2.fromOffset(90, 90)
    setOpen(true)
    introActive = true
    task.spawn(function()
        task.wait(0.35)
        if not (alive and introActive) then return end
        tween(splash, 0.7, { ImageTransparency = 0.7, Size = UDim2.fromOffset(150, 150) },
            Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        task.wait(1.1)
        tween(splash, 0.6, { ImageTransparency = 1, Size = UDim2.fromOffset(200, 200) },
            Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.wait(0.6)
        if alive and introActive then
            introActive = false
            setOpen(false)
        end
    end)
end

task.spawn(function()
    while alive do
        task.wait(0.25)
        if opened and not introActive and os.clock() - lastTouch > 5 then
            setOpen(false)
        end
    end
end)

local function runSource(key, label)
    local src = SOURCES[key]
    if not src then
        setStatus(label .. " source missing", C.bad)
        return
    end
    local fn, err = loadstring(src, "=" .. label)
    if not fn then
        setStatus(label .. " failed to load", C.bad)
        warn("[Zero Hub] " .. label .. ": " .. tostring(err))
        return
    end
    setStatus("Opening " .. label .. "...", C.ok)
    task.spawn(function()
        local ok, e = pcall(fn)
        if not ok then
            setStatus(label .. " error", C.bad)
            warn("[Zero Hub] " .. label .. ": " .. tostring(e))
        end
    end)
    setOpen(false)
end

local commands = {
    { names = { "dex", "explorer", "zerodex" }, label = "dex / explorer",
        run = function() runSource("dex", "ZeroDex") end },
    { names = { "rspy", "spy", "zerospy", "remotespy" }, label = "rspy / spy",
        run = function() runSource("spy", "ZeroSpy") end },
    { names = { "hide", "close" }, label = "hide / close", run = function() setOpen(false) end },
    { names = { "destroy", "exit" }, label = "destroy", run = function() cleanup() end },
}

local rows = {}
for i, cmd in ipairs(commands) do
    local b = new("TextButton", {
        Text = cmd.label,
        Font = Enum.Font.SourceSans,
        TextSize = 18,
        TextColor3 = C.text,
        BackgroundColor3 = C.row,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Size = UDim2.new(1, 0, 0, ROW_H),
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = i,
        ZIndex = 12,
    }, list)
    new("UIPadding", { PaddingLeft = UDim.new(0, 10) }, b)
    track(b.MouseEnter:Connect(function() b.BackgroundColor3 = C.rowHover end))
    track(b.MouseLeave:Connect(function() b.BackgroundColor3 = C.row end))
    track(b.Activated:Connect(function()
        box.Text = ""
        cmd.run()
    end))
    rows[i] = { btn = b, cmd = cmd }
end

local function refresh()
    local q = (box.Text:lower():match("^%s*(%S*)")) or ""
    for _, r in ipairs(rows) do
        local show = q == ""
        if not show then
            for _, n in ipairs(r.cmd.names) do
                if n:sub(1, #q) == q then show = true break end
            end
        end
        r.btn.Visible = show
    end
end
track(box:GetPropertyChangedSignal("Text"):Connect(function()
    refresh()
    touch()
end))
track(box.Focused:Connect(touch))

track(box.FocusLost:Connect(function(enter)
    if not enter then return end
    local word = (box.Text:lower():match("^%s*(%S+)")) or ""
    box.Text = ""
    if word == "" then return end
    for _, cmd in ipairs(commands) do
        for _, n in ipairs(cmd.names) do
            if n == word then
                cmd.run()
                return
            end
        end
    end
    setStatus("Unknown command: " .. word, C.bad)
end))

track(infoBtn.Activated:Connect(function()
    touch()
    infoPage.Visible = not infoPage.Visible
end))
track(closeBtn.Activated:Connect(function() setOpen(false) end))

track(panel.InputBegan:Connect(function(input)
    if isPointer(input.UserInputType) then touch() end
end))
track(panel.InputChanged:Connect(function() poke() end))

makeDraggable(logoBtn, logoBtn, function()
    tween(logoBtn, 0.08, { Size = UDim2.fromOffset(BTN - 8, BTN - 8) })
    task.delay(0.08, function()
        if alive then
            tween(logoBtn, 0.2, { Size = UDim2.fromOffset(BTN, BTN) },
                Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
    end)
    setOpen(not opened)
end)

track(UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Semicolon then
        setOpen(true)
        infoPage.Visible = false
        task.wait()
        box.Text = ""
        box:CaptureFocus()
        task.wait()
        box.Text = ""
    end
end))

setStatus("Type dex or rspy", C.sub)
intro()

SOURCES.spy = [=====[
-- zerox
--[[
    ZeroSpy
    Animations tab: logs animations (no duplicates), play again, repeat, speed
    Remotes tab:    logs what the game sends to the server (and what it receives).
                    Tap a remote to slide open its code.
                    Yellow = RemoteEvent, Purple = RemoteFunction.
    Settings tab:   protection (not 100%), deep remote details, sort, compact rows.
    Every remote has a Run button.
    Draggable + resizable window, draggable open button. PC and mobile.
]]

local cloneref = cloneref or function(x)
	return x
end
local function svc(name)
	return cloneref(game:GetService(name))
end
local Players = svc("Players")
local UserInputService = svc("UserInputService")
local TweenService = svc("TweenService")
local RunService = svc("RunService")
local MarketplaceService = svc("MarketplaceService")

local player = Players.LocalPlayer
local env = (getgenv and getgenv()) or _G

-- Remove the old copy if the script is run again
local KEY = "__LH3"
local prevShared = env[KEY]
if prevShared and prevShared.cleanup then
	pcall(prevShared.cleanup)
end
if env.__AnimLoggerCleanup then
	pcall(env.__AnimLoggerCleanup)
end
-- S is shared with the hooks. The hooks are installed once per game session
-- and always call env[KEY].intercept, so a re-run just swaps the logic.
local S = {
	hooked = (prevShared and prevShared.hooked) or false,
	hookInfo = prevShared and prevShared.hookInfo,
	on = true,
	deep = false,
	stealth = false,
}
env[KEY] = S

local connections = {}
local function keep(conn)
	table.insert(connections, conn)
	return conn
end

------------------------------------------------------------------
-- STATE
------------------------------------------------------------------
local running = true
local isOpen = true
local isMaximized = false
local currentTab = "remote"

local loggingOn = true
local loopOn = false
local speed = 1
local currentTrack = nil

local logged = {} -- [animation id] = entry
local order = {} -- oldest -> newest
local counter = 0
local MAX_ENTRIES = 150
local nameCache = {}

local remoteLogging = true
local remoteLogged = { Out = {}, In = {} } -- [direction][remote] = entry
local remoteOrder = {}
local ignoredRemotes = {}
local blockedRemotes = {}
local ignoredNames = {}
local blockedNames = {}
local function isIgnored(remote)
	return ignoredRemotes[remote] == true or ignoredNames[remote.Name] == true
end
local incomingConns = {}
local inQueue = {} -- received remotes waiting to be shown
local remoteSeq = 0
local MAX_REMOTES = 150
local showEvent, showFunction = true, true
local showOut, showIn = true, true
local filterText = ""
local remoteEmptyText = "No remotes yet.\nDo something in the game and what it sends will appear here.\nTap a remote to see its code."

S.blocked = blockedRemotes
S.blockedNames = blockedNames
S.queue = {}
S.on = true

local sortMode = "new" -- new | old | calls | name | type
local compactMode = false
local stealthOn = false
local sortDirty = false
local selfFire = {} -- [remote] = time until which our own Run is ignored when received
local lastRun = 0
local ROW_NORMAL, ROW_COMPACT = 24, 24
local function rowH()
	return compactMode and ROW_COMPACT or ROW_NORMAL
end

local MARGIN = 8
local DRAG_SLOP = 8
local ROW_H = 54

------------------------------------------------------------------
-- GUI ROOT
------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "ZeroSpyGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

do
	local mounted = false
	if syn and syn.protect_gui then
		pcall(syn.protect_gui, gui)
	end
	if gethui then
		mounted = pcall(function()
			gui.Parent = gethui()
		end)
	end
	if not mounted or not gui.Parent then
		mounted = pcall(function()
			gui.Parent = game:GetService("CoreGui")
		end)
	end
	if not mounted or not gui.Parent then
		gui.Parent = player:WaitForChild("PlayerGui")
	end
end

-- Screen size (wait a moment if the engine has not measured it yet)
local function getScreen()
	local s = gui.AbsoluteSize
	if s.X < 10 or s.Y < 10 then
		local cam = workspace.CurrentCamera
		s = (cam and cam.ViewportSize) or Vector2.new(800, 600)
	end
	return s
end
if gui.AbsoluteSize.X < 10 then
	task.wait(0.1)
end

------------------------------------------------------------------
-- THEME
-- Slate base, one steel-blue accent.
-- Yellow = RemoteEvent, Purple = RemoteFunction. Red only for destructive actions.
------------------------------------------------------------------
local C = {
	ink = Color3.fromRGB(35, 33, 35),
	panel = Color3.fromRGB(62, 61, 64),
	panelHover = Color3.fromRGB(78, 77, 81),
	side = Color3.fromRGB(51, 50, 52),
	code = Color3.fromRGB(38, 44, 56),
	btn = Color3.fromRGB(28, 28, 30),
	btnHover = Color3.fromRGB(52, 52, 56),
	title = Color3.fromRGB(226, 100, 112),
	line = Color3.fromRGB(100, 99, 104),
	rowBg = Color3.fromRGB(46, 45, 48),
	rowHover = Color3.fromRGB(60, 59, 63),
	rowSel = Color3.fromRGB(63, 66, 112),
	rowSelLine = Color3.fromRGB(112, 114, 172),
	text = Color3.fromRGB(231, 234, 241),
	dim = Color3.fromRGB(158, 166, 182),
	muted = Color3.fromRGB(104, 112, 129),
	accent = Color3.fromRGB(86, 140, 236),
	accentHover = Color3.fromRGB(110, 158, 244),
	accentSoft = Color3.fromRGB(32, 45, 70),
	red = Color3.fromRGB(238, 106, 106),
	redSoft = Color3.fromRGB(48, 30, 36),
	redLine = Color3.fromRGB(90, 46, 54),
	green = Color3.fromRGB(78, 196, 144),
	amber = Color3.fromRGB(236, 178, 76),
	off = Color3.fromRGB(58, 65, 82),
	event = Color3.fromRGB(242, 192, 68),
	eventSoft = Color3.fromRGB(52, 45, 22),
	func = Color3.fromRGB(178, 134, 244),
	funcSoft = Color3.fromRGB(42, 33, 68),
}

-- Colors used inside the code view (rich text needs hex)
local HL = {
	str = "#98C379",
	num = "#E5A35A",
	kw = "#C678DD",
	fn = "#61AFEF",
	cmt = "#7A8294",
}

local FONT = Enum.Font.Ubuntu
local FONT_MED = Enum.Font.Ubuntu
local FONT_BOLD = Enum.Font.GothamBold
local FONT_MONO = Enum.Font.Ubuntu

------------------------------------------------------------------
-- UI HELPERS
------------------------------------------------------------------
local function tween(obj, t, props, style)
	local tw = TweenService:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
	tw:Play()
	return tw
end

local function new(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do
		o[k] = v
	end
	o.Parent = parent
	return o
end

local function corner(o, r)
	local rr = r or 6
	if rr >= 6 and rr < 20 then
		rr = 0
	end
	new("UICorner", { CornerRadius = UDim.new(0, rr) }, o)
end

local function stroke(o, color, thickness)
	return new("UIStroke", {
		Color = color,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, o)
end

local function makeLabel(parent, props)
	props.BackgroundTransparency = 1
	props.Font = props.Font or FONT
	props.TextSize = props.TextSize or 12
	props.TextColor3 = props.TextColor3 or C.text
	props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
	return new("TextLabel", props, parent)
end

local function divider(parent, pos)
	return new("Frame", {
		BackgroundColor3 = C.line,
		BorderSizePixel = 0,
		Position = pos,
		Size = UDim2.new(1, 0, 0, 1),
	}, parent)
end

-- kind: "primary" (main action), "ghost" (normal), "danger" (destructive)
local function makeButton(parent, text, kind, size, pos)
	local base, hover, textColor, stripeColor = C.btn, C.btnHover, C.text, Color3.new(1, 1, 1)
	if kind == "primary" then
		textColor, stripeColor = Color3.new(1, 1, 1), C.accent
	elseif kind == "danger" then
		textColor, stripeColor = C.red, C.red
	end
	local iconOnly = (text == "")
	if iconOnly then
		base, hover, textColor = C.ink, C.panelHover, C.dim
	end
	local b = new("TextButton", {
		Text = text,
		Font = FONT_MED,
		TextSize = 12,
		TextColor3 = textColor,
		BackgroundColor3 = base,
		AutoButtonColor = false,
		Size = size,
		Position = pos or UDim2.new(),
		BorderSizePixel = 0,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, parent)
	local btnStroke, btnStripe
	if not iconOnly then
		btnStroke = stroke(b, C.line)
		new("UIPadding", { PaddingLeft = UDim.new(0, 16) }, b)
		btnStripe = new("Frame", {
			BackgroundColor3 = stripeColor,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(-16, 0),
			Size = UDim2.new(0, 8, 1, 0),
		}, b)
	end
	b.MouseEnter:Connect(function()
		tween(b, 0.12, { BackgroundColor3 = hover })
		if btnStripe then
			tween(btnStripe, 0.18, { Size = UDim2.new(0, 12, 1, 0) }, Enum.EasingStyle.Back)
			tween(btnStroke, 0.15, { Color = C.rowSelLine })
		end
	end)
	b.MouseLeave:Connect(function()
		tween(b, 0.12, { BackgroundColor3 = base })
		if btnStripe then
			tween(btnStripe, 0.15, { Size = UDim2.new(0, 8, 1, 0) })
			tween(btnStroke, 0.15, { Color = C.line })
		end
	end)
	b.MouseButton1Down:Connect(function()
		tween(b, 0.05, { BackgroundColor3 = hover })
	end)
	b.MouseButton1Up:Connect(function()
		tween(b, 0.12, { BackgroundColor3 = base })
	end)
	return b
end

-- Small on/off switch
local function makeSwitch(parent, pos, initial, onChange)
	local state = initial
	local track = new("TextButton", {
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.fromOffset(34, 18),
		Position = pos,
		BackgroundColor3 = initial and C.accent or C.off,
		BorderSizePixel = 0,
	}, parent)
	new("UICorner", { CornerRadius = UDim.new(0, 9) }, track)
	local knob = new("Frame", {
		Size = UDim2.fromOffset(14, 14),
		Position = initial and UDim2.fromOffset(18, 2) or UDim2.fromOffset(2, 2),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
	}, track)
	new("UICorner", { CornerRadius = UDim.new(0, 7) }, knob)
	track.MouseButton1Click:Connect(function()
		state = not state
		tween(track, 0.15, { BackgroundColor3 = state and C.accent or C.off })
		tween(knob, 0.15, { Position = state and UDim2.fromOffset(18, 2) or UDim2.fromOffset(2, 2) })
		if onChange then
			onChange(state)
		end
	end)
	return track
end

-- Toggle chip (filters). color = text/border color when on, soft = fill when on.
local function makeChip(parent, text, size, initial, onChange, color, soft)
	local state = initial
	color = color or C.accentHover
	soft = soft or C.accentSoft
	local b = new("TextButton", {
		Text = text,
		Font = FONT_MED,
		TextSize = 12,
		AutoButtonColor = false,
		Size = size,
		BorderSizePixel = 0,
		BackgroundColor3 = state and soft or C.panel,
		TextColor3 = state and color or C.muted,
	}, parent)
	corner(b, 6)
	local s = stroke(b, state and color or C.line)
	b.MouseButton1Click:Connect(function()
		state = not state
		tween(b, 0.12, {
			BackgroundColor3 = state and soft or C.panel,
			TextColor3 = state and color or C.muted,
		})
		tween(s, 0.12, { Color = state and color or C.line })
		onChange(state)
	end)
	return b
end

-- Equalizer mark used as the app logo
local function drawBars(parent, color)
	local bars = {}
	local heights = { 8, 14, 10 }
	for i, h in ipairs(heights) do
		local f = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, (i - 2) * 6, 0.5, 0),
			Size = UDim2.fromOffset(3, h),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
		}, parent)
		corner(f, 2)
		bars[i] = f
	end
	return bars
end

-- Drawn "x" icon (no font needed)
local function addCross(parent, color)
	for _, rot in ipairs({ 45, -45 }) do
		local f = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(11, 2),
			Rotation = rot,
			BackgroundColor3 = color,
			BorderSizePixel = 0,
		}, parent)
		corner(f, 1)
	end
end

local function makeList(parent, pos, size)
	local sf = new("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = pos,
		Size = size,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = C.muted,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
	}, parent)
	new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, sf)
	new("UIPadding", { PaddingRight = UDim.new(0, 6) }, sf)
	return sf
end

-- When a new row is added at the top while the person is scrolled down,
-- push the view down by the row height so the list does not jump.
local function keepScroll(sf, rowHeight, pad)
	local y = sf.CanvasPosition.Y
	if y > 4 then
		task.defer(function()
			sf.CanvasPosition = Vector2.new(0, y + rowHeight + (pad or 8))
		end)
	end
end

------------------------------------------------------------------
-- DRAG ENGINE (mouse + touch)
-- Only the finger/mouse button that started the drag can move things,
-- so scrolling a list or touching elsewhere never moves the window.
------------------------------------------------------------------
local function trackDrag(handle, onBegin, onMove, onFinish)
	local dragging, moved = false, false
	local active, moveInput, startPos

	keep(handle.InputBegan:Connect(function(input)
		if dragging then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging, moved = true, false
			active = input
			startPos = input.Position
			onBegin()
		end
	end))

	keep(handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			moveInput = input
		end
	end))

	keep(UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end
		if input ~= active and input ~= moveInput then
			return
		end
		local d = input.Position - startPos
		if not moved and d.Magnitude < DRAG_SLOP then
			return
		end
		moved = true
		onMove(d)
	end))

	local function finish()
		if not dragging then
			return
		end
		dragging = false
		active = nil
		onFinish(moved)
	end

	keep(UserInputService.InputEnded:Connect(function(input)
		if not dragging or not active then
			return
		end
		if input == active
			or (active.UserInputType == Enum.UserInputType.MouseButton1
				and input.UserInputType == Enum.UserInputType.MouseButton1) then
			finish()
		end
	end))
	keep(UserInputService.WindowFocusReleased:Connect(finish))
end

-- Move `target` by dragging `handle`. A short tap calls onTap.
local function makeDraggable(handle, target, onTap)
	local startRel
	trackDrag(handle, function()
		startRel = target.AbsolutePosition - gui.AbsolutePosition
	end, function(d)
		local screen = gui.AbsoluteSize
		local size = target.AbsoluteSize
		local x = math.clamp(startRel.X + d.X, 0, math.max(0, screen.X - size.X))
		local y = math.clamp(startRel.Y + d.Y, 0, math.max(0, screen.Y - size.Y))
		target.Position = UDim2.fromOffset(
			x + size.X * target.AnchorPoint.X,
			y + size.Y * target.AnchorPoint.Y
		)
	end, function(moved)
		if not moved and onTap then
			onTap()
		end
	end)
end

------------------------------------------------------------------
-- WINDOW
------------------------------------------------------------------
local screen0 = getScreen()
local W = math.min(screen0.X - MARGIN * 2, math.clamp(math.floor(screen0.X * 0.6), 420, 600))
local H = math.min(screen0.Y - MARGIN * 2, math.clamp(math.floor(W * 0.64), 300, 420))

local main = new("Frame", {
	Name = "Main",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Size = UDim2.fromOffset(W, H),
	Position = UDim2.fromOffset(math.floor(screen0.X / 2), math.floor(screen0.Y / 2)),
	BackgroundColor3 = C.ink,
	BorderSizePixel = 0,
	Active = true,
}, gui)
local mainScale = new("UIScale", { Scale = 1 }, main)

-- Place the window by its top-left corner and size (inside the screen)
local function applyWindow(x, y, w, h)
	main.Size = UDim2.fromOffset(w, h)
	main.Position = UDim2.fromOffset(x + w * 0.5, y + h * 0.5)
end

local TITLE_H = 26
local BTN_AREA = 130
local LEFT_W = 0.29

-- Old pages and controls are parked here (hidden) so the code behind them keeps working
local legacy = new("Frame", { Name = "Legacy", BackgroundTransparency = 1, Size = UDim2.new(), Visible = false }, main)

-- Title bar (drag here)
local header = new("Frame", {
	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderSizePixel = 0,
	Size = UDim2.new(1, 0, 0, TITLE_H),
	Active = true,
}, main)
do
	local titleLbl = makeLabel(header, {
		Text = "ZeroSpy",
		Font = FONT_BOLD,
		TextSize = 15,
		Position = UDim2.fromOffset(32, 0),
		Size = UDim2.fromOffset(92, TITLE_H),
	})
	pcall(function()
		titleLbl.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Bold)
	end)
end
local countLabel = makeLabel(header, { Text = "", Visible = false })

new("UIGradient", {
	Color = ColorSequence.new(Color3.fromRGB(48, 46, 51), Color3.fromRGB(31, 30, 33)),
	Rotation = 90,
}, header)
do
	local logo = new("Frame", {
		Name = "Logo",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(6, 2),
		Size = UDim2.fromOffset(22, 22),
	}, header)
	new("ImageLabel", {
		Name = "Img",
		Image = "rbxassetid://75862850530028",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, logo)
end

local closeBtn = makeButton(header, "", "ghost", UDim2.fromOffset(28, 22), UDim2.new(1, -32, 0.5, -11))
addCross(closeBtn, C.dim)
local maxBtn = makeButton(header, "", "ghost", UDim2.fromOffset(28, 22), UDim2.new(1, -62, 0.5, -11))
do
	local box = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(11, 11),
		BackgroundTransparency = 1,
	}, maxBtn)
	stroke(box, C.dim, 1.5)
end
local minBtn = makeButton(header, "", "ghost", UDim2.fromOffset(28, 22), UDim2.new(1, -92, 0.5, -11))
new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(11, 2),
	BackgroundColor3 = C.dim,
	BorderSizePixel = 0,
}, minBtn)
makeDraggable(header, main)

-- Status toast: slides in under the title bar, fades out
local statusLabel = new("TextLabel", {
	Text = "",
	Font = FONT_MED,
	TextSize = 12,
	TextColor3 = C.text,
	BackgroundColor3 = C.btn,
	BackgroundTransparency = 1,
	TextTransparency = 1,
	BorderSizePixel = 0,
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, TITLE_H - 4),
	Size = UDim2.fromOffset(0, 24),
	AutomaticSize = Enum.AutomaticSize.X,
	Visible = false,
	ZIndex = 30,
}, main)
new("UIPadding", { PaddingLeft = UDim.new(0, 24), PaddingRight = UDim.new(0, 12) }, statusLabel)
stroke(statusLabel, C.line).Transparency = 1
local statusDot = new("Frame", {
	BackgroundColor3 = C.green,
	BorderSizePixel = 0,
	Position = UDim2.new(0, -16, 0.5, -3),
	Size = UDim2.fromOffset(6, 6),
	ZIndex = 31,
}, statusLabel)
corner(statusDot, 3)

-- Tabs in the title bar: Remotes / Animations / Settings
local tabBtns, tabIndicator = {}, nil
do
	local tabHolder = new("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(126, 0),
		Size = UDim2.new(1, -226, 1, 0),
	}, header)
	tabIndicator = new("Frame", {
		BackgroundColor3 = C.title,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 8, 1, -2),
		Size = UDim2.new(1 / 3, -16, 0, 2),
	}, tabHolder)
	for i, t in ipairs({ { "remote", "Remotes" }, { "anim", "Animations" }, { "settings", "Settings" } }) do
		local b = new("TextButton", {
			Text = t[2],
			Font = FONT_MED,
			TextSize = 12,
			TextColor3 = (i == 1) and C.text or C.muted,
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			Position = UDim2.fromScale((i - 1) / 3, 0),
			Size = UDim2.fromScale(1 / 3, 1),
		}, tabHolder)
		b.MouseEnter:Connect(function()
			if currentTab ~= t[1] then
				tween(b, 0.12, { TextColor3 = C.dim })
			end
		end)
		b.MouseLeave:Connect(function()
			if currentTab ~= t[1] then
				tween(b, 0.12, { TextColor3 = C.muted })
			end
		end)
		tabBtns[t[1]] = b
	end
end

local bodyFrame = new("Frame", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(0, TITLE_H),
	Size = UDim2.new(1, 0, 1, -TITLE_H),
}, main)
local animPage = new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false }, bodyFrame)
local settingsPage = new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false }, bodyFrame)
local remotePage = new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) }, bodyFrame)
-- Cover used for the page-change animation
local veil = new("Frame", {
	BackgroundColor3 = C.ink,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 50,
	Visible = false,
}, bodyFrame)

-- Resize grip (bottom-right corner)
local grip = new("TextButton", {
	Text = "",
	AutoButtonColor = false,
	BackgroundTransparency = 1,
	Position = UDim2.new(1, -18, 1, -18),
	Size = UDim2.fromOffset(18, 18),
	ZIndex = 10,
}, main)
for _, p in ipairs({ { 12, 12 }, { 7, 12 }, { 12, 7 } }) do
	local dot = new("Frame", {
		BackgroundColor3 = C.muted,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(p[1], p[2]),
		Size = UDim2.fromOffset(3, 3),
		ZIndex = 10,
	}, grip)
	corner(dot, 2)
end

-- Minimize: collapse to the title bar
do
	local minimized, savedH = false, nil
	minBtn.MouseButton1Click:Connect(function()
		local tl = main.AbsolutePosition - gui.AbsolutePosition
		local size = main.AbsoluteSize
		if not minimized then
			savedH = size.Y
			minimized = true
			bodyFrame.Visible = false
			grip.Visible = false
			applyWindow(tl.X, tl.Y, size.X, TITLE_H)
		else
			minimized = false
			bodyFrame.Visible = true
			grip.Visible = true
			applyWindow(tl.X, tl.Y, size.X, savedH or H)
		end
	end)
end

local statusToken = 0
local function setStatus(text, color)
	statusToken += 1
	local my = statusToken
	local c = color or C.dim
	statusLabel.Text = text
	statusDot.BackgroundColor3 = c
	local st = statusLabel:FindFirstChildOfClass("UIStroke")
	if st then
		st.Color = c
	end
	if not statusLabel.Visible then
		statusLabel.Position = UDim2.new(0.5, 0, 0, TITLE_H - 4)
	end
	statusLabel.Visible = true
	tween(statusLabel, 0.24, {
		Position = UDim2.new(0.5, 0, 0, TITLE_H + 8),
		BackgroundTransparency = 0.05,
		TextTransparency = 0,
	}, Enum.EasingStyle.Back)
	if st then
		tween(st, 0.2, { Transparency = 0 })
	end
	task.delay(2.6, function()
		if statusToken ~= my or not statusLabel.Parent then
			return
		end
		local tw = tween(statusLabel, 0.2, {
			Position = UDim2.new(0.5, 0, 0, TITLE_H - 4),
			BackgroundTransparency = 1,
			TextTransparency = 1,
		})
		if st then
			tween(st, 0.2, { Transparency = 1 })
		end
		tw.Completed:Once(function()
			if statusToken == my then
				statusLabel.Visible = false
			end
		end)
	end)
end

------------------------------------------------------------------
-- ANIMATIONS PAGE
------------------------------------------------------------------
local stopBtn = makeButton(animPage, "Stop All", "danger", UDim2.fromOffset(76, 28), UDim2.fromOffset(10, 8))
local clearBtn = makeButton(animPage, "Clear", "ghost", UDim2.fromOffset(56, 28), UDim2.fromOffset(92, 8))

makeLabel(animPage, {
	Text = "Logging",
	TextColor3 = C.dim,
	TextXAlignment = Enum.TextXAlignment.Right,
	Position = UDim2.new(1, -102, 0, 8),
	Size = UDim2.fromOffset(52, 28),
})
makeSwitch(animPage, UDim2.new(1, -44, 0, 13), true, function(v)
	loggingOn = v
end)

-- Playback options
local opts = new("Frame", {
	BackgroundColor3 = C.panel,
	BorderSizePixel = 0,
	Position = UDim2.fromOffset(10, 44),
	Size = UDim2.new(1, -20, 0, 34),
}, animPage)
corner(opts, 8)
stroke(opts, C.line)

makeLabel(opts, {
	Text = "Repeat",
	TextColor3 = C.dim,
	Position = UDim2.fromOffset(12, 0),
	Size = UDim2.fromOffset(46, 34),
})
makeSwitch(opts, UDim2.fromOffset(60, 8), false, function(v)
	loopOn = v
	if currentTrack then
		currentTrack.Looped = v
	end
end)

makeLabel(opts, {
	Text = "Speed",
	TextColor3 = C.dim,
	TextXAlignment = Enum.TextXAlignment.Right,
	Position = UDim2.new(1, -152, 0, 0),
	Size = UDim2.fromOffset(42, 34),
})
local slowBtn = makeButton(opts, "-", "ghost", UDim2.fromOffset(24, 24), UDim2.new(1, -106, 0.5, -12))
local speedLabel = makeLabel(opts, {
	Text = "1.0x",
	Font = FONT_MED,
	TextXAlignment = Enum.TextXAlignment.Center,
	Position = UDim2.new(1, -78, 0, 0),
	Size = UDim2.fromOffset(42, 34),
})
local fastBtn = makeButton(opts, "+", "ghost", UDim2.fromOffset(24, 24), UDim2.new(1, -34, 0.5, -12))
slowBtn.TextSize, fastBtn.TextSize = 14, 14

-- Add ID by hand
local inputRow = new("Frame", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(10, 86),
	Size = UDim2.new(1, -20, 0, 30),
}, animPage)
local idBox = new("TextBox", {
	PlaceholderText = "Paste an animation ID",
	PlaceholderColor3 = C.muted,
	Text = "",
	ClearTextOnFocus = false,
	Font = FONT,
	TextSize = 12,
	TextColor3 = C.text,
	BackgroundColor3 = C.panel,
	BorderSizePixel = 0,
	Size = UDim2.new(1, -70, 1, 0),
	TextXAlignment = Enum.TextXAlignment.Left,
}, inputRow)
corner(idBox, 6)
local idBoxStroke = stroke(idBox, C.line)
new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, idBox)
local addBtn = makeButton(inputRow, "Add", "primary", UDim2.fromOffset(62, 30), UDim2.new(1, -62, 0, 0))
idBox.Focused:Connect(function()
	tween(idBoxStroke, 0.12, { Color = C.accent })
end)
idBox.FocusLost:Connect(function()
	tween(idBoxStroke, 0.12, { Color = C.line })
end)

local list = makeList(animPage, UDim2.fromOffset(10, 124), UDim2.new(1, -20, 1, -132))
local emptyLabel = makeLabel(list, {
	Text = "No animations yet.\nPlay one in the game and it will appear here.",
	TextColor3 = C.muted,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextWrapped = true,
	Size = UDim2.new(1, 0, 0, 64),
	LayoutOrder = 999999,
})

------------------------------------------------------------------
-- REMOTES PAGE
-- Row 1: search, pause, clear.  Row 2: four filters.  Then the list.
------------------------------------------------------------------
local searchBox = new("TextBox", {
	PlaceholderText = "Search remotes",
	PlaceholderColor3 = C.muted,
	Text = "",
	ClearTextOnFocus = false,
	Font = FONT,
	TextSize = 12,
	TextColor3 = C.text,
	BackgroundColor3 = C.panel,
	BorderSizePixel = 0,
	Position = UDim2.fromOffset(10, 8),
	Size = UDim2.new(1, -148, 0, 30),
	TextXAlignment = Enum.TextXAlignment.Left,
}, legacy)
corner(searchBox, 6)
local searchStroke = stroke(searchBox, C.line)
new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, searchBox)
searchBox.Focused:Connect(function()
	tween(searchStroke, 0.12, { Color = C.accent })
end)
searchBox.FocusLost:Connect(function()
	tween(searchStroke, 0.12, { Color = C.line })
end)

local pauseBtn = makeButton(legacy, "Pause", "ghost", UDim2.fromOffset(60, 30), UDim2.new(1, -132, 0, 8))
local rClearBtn = makeButton(legacy, "Clear", "ghost", UDim2.fromOffset(56, 30), UDim2.new(1, -66, 0, 8))

local chipRow = new("Frame", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(10, 46),
	Size = UDim2.new(1, -20, 0, 28),
}, legacy)
new("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	Padding = UDim.new(0, 6),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, chipRow)

local remoteList = makeList(new("Frame", {
	BackgroundColor3 = C.side,
	BorderSizePixel = 0,
	Size = UDim2.new(LEFT_W, 0, 1, 0),
}, remotePage), UDim2.fromOffset(8, 8), UDim2.new(1, -16, 1, -16))
remoteList.UIListLayout.Padding = UDim.new(0, 4)
remoteList.Position = UDim2.fromOffset(8, 40)
remoteList.Size = UDim2.new(1, -16, 1, -48)
searchBox.Parent = remoteList.Parent
searchBox.Position = UDim2.fromOffset(8, 8)
searchBox.Size = UDim2.new(1, -16, 0, 24)
searchBox.BackgroundColor3 = C.ink
searchBox.TextSize = 13

-- Right side: code with line numbers (top) + 3 x 4 button grid (bottom)
local selectedEntry = nil
local detail = {}
do
	local right = new("Frame", {
		BackgroundColor3 = C.code,
		BorderSizePixel = 0,
		Position = UDim2.new(LEFT_W, 0, 0, 0),
		Size = UDim2.new(1 - LEFT_W, 0, 1, -BTN_AREA),
		ClipsDescendants = true,
	}, remotePage)
	local scroll = new("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.XY,
		ScrollingDirection = Enum.ScrollingDirection.XY,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = C.muted,
	}, right)
	detail.gutter = makeLabel(scroll, {
		Text = "1\n2",
		TextSize = 14,
		TextColor3 = C.dim,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextYAlignment = Enum.TextYAlignment.Top,
		Position = UDim2.fromOffset(6, 8),
		Size = UDim2.fromOffset(30, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	detail.codeLbl = makeLabel(scroll, {
		Text = "",
		TextSize = 14,
		TextColor3 = C.text,
		RichText = true,
		TextWrapped = false,
		TextYAlignment = Enum.TextYAlignment.Top,
		Position = UDim2.fromOffset(50, 8),
		Size = UDim2.new(),
		AutomaticSize = Enum.AutomaticSize.XY,
	})
	detail.setCode = function(code)
		detail.codeLbl.Text = code
		local _, n = code:gsub("\n", "")
		local nums = table.create(n + 1)
		for i = 1, n + 1 do
			nums[i] = tostring(i)
		end
		detail.gutter.Text = table.concat(nums, "\n")
	end
	detail.setEmpty = function()
		detail.setCode('<font color="#E26470">ZeroSpy</font>\n')
	end
	detail.setFilled = function() end
	detail.pulse = function()
		local logo = header:FindFirstChild("Logo")
		if not logo then
			return
		end
		for _, b in ipairs(logo:GetChildren()) do
			if b:IsA("Frame") then
				b.BackgroundColor3 = Color3.new(1, 1, 1)
				tween(b, 0.4, { BackgroundColor3 = C.title })
			end
		end
	end
	detail.setEmpty()

	local actions = new("Frame", {
		BackgroundColor3 = C.ink,
		BorderSizePixel = 0,
		Position = UDim2.new(LEFT_W, 0, 1, -BTN_AREA),
		Size = UDim2.new(1 - LEFT_W, 0, 0, BTN_AREA),
	}, remotePage)
	new("Frame", {
		BackgroundColor3 = C.line,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 1),
	}, actions)
	local grid = new("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0.06, 0, 0, 8),
		Size = UDim2.new(0.88, 0, 1, -16),
	}, actions)
	new("UIGridLayout", {
		CellSize = UDim2.new(1 / 3, -7, 0, 24),
		CellPadding = UDim2.fromOffset(10, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, grid)
	local function actionBtn(text, order)
		local b = makeButton(grid, text, "ghost", UDim2.new(), UDim2.new())
		b.LayoutOrder = order
		b.TextSize = 13
		b.TextTruncate = Enum.TextTruncate.AtEnd
		return b
	end
	detail.copyB = actionBtn("Copy Code", 1)
	detail.pathB = actionBtn("Copy Remote", 2)
	detail.runB = actionBtn("Run Code", 3)
	detail.scriptB = actionBtn("Get Script", 4)
	detail.infoB = actionBtn("Function Info", 5)
	detail.clrB = actionBtn("Clr Logs", 6)
	detail.hideB = actionBtn("Exclude (i)", 7)
	detail.hideNB = actionBtn("Exclude (n)", 8)
	detail.clrBlackB = actionBtn("Clr Blacklist", 9)
	detail.blockB = actionBtn("Block (i)", 10)
	detail.blockNB = actionBtn("Block (n)", 11)
	detail.clrBlockB = actionBtn("Clr Blocklist", 12)
end

local remoteEmpty = makeLabel(remoteList, {
	Text = remoteEmptyText,
	TextColor3 = C.muted,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextWrapped = true,
	Size = UDim2.new(1, 0, 0, 80),
	LayoutOrder = 999999,
})

-- Slim bar shown only when some remotes are hidden
local hiddenBar = new("Frame", {
	BackgroundColor3 = C.panel,
	BorderSizePixel = 0,
	Size = UDim2.new(1, 0, 0, 32),
	LayoutOrder = -1000000,
	Visible = false,
}, remoteList)
corner(hiddenBar, 8)
stroke(hiddenBar, C.line)
local hiddenLbl = makeLabel(hiddenBar, {
	Text = "",
	TextColor3 = C.dim,
	Position = UDim2.fromOffset(12, 0),
	Size = UDim2.new(1, -90, 1, 0),
})
local hiddenShowBtn = makeButton(hiddenBar, "Show", "ghost", UDim2.fromOffset(56, 24), UDim2.new(1, -64, 0.5, -12))

------------------------------------------------------------------
-- OPEN BUTTON (draggable)
------------------------------------------------------------------
local toggle = new("TextButton", {
	Name = "Toggle",
	Text = "",
	AutoButtonColor = false,
	BackgroundColor3 = C.ink,
	BorderSizePixel = 0,
	Size = UDim2.fromOffset(46, 46),
	Position = UDim2.fromOffset(12, 90),
	Active = true,
}, gui)
corner(toggle, 23)
local toggleStroke = stroke(toggle, C.accent, 1.5)
local toggleBars = drawBars(toggle, C.accent)

local openToken = 0
local function setOpen(open)
	isOpen = open
	openToken += 1
	local my = openToken
	if open then
		main.Visible = true
		mainScale.Scale = 0.88
		tween(mainScale, 0.3, { Scale = 1 }, Enum.EasingStyle.Back)
	else
		tween(mainScale, 0.12, { Scale = 0.95 })
		task.delay(0.12, function()
			if openToken == my then
				main.Visible = false
			end
		end)
	end
	tween(toggleStroke, 0.15, { Color = open and C.accent or C.line })
	for _, bar in ipairs(toggleBars) do
		tween(bar, 0.15, { BackgroundColor3 = open and C.accent or C.dim })
	end
end

makeDraggable(toggle, toggle, function()
	setOpen(not isOpen)
end)
closeBtn.MouseButton1Click:Connect(function()
	setOpen(false)
end)

-- PC shortcut: Right Shift
keep(UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.RightShift then
		setOpen(not isOpen)
	end
end))

------------------------------------------------------------------
-- RESIZE / MAXIMIZE / FIT TO SCREEN
------------------------------------------------------------------
do
	local startSize, startTL
	trackDrag(grip, function()
		startSize = main.AbsoluteSize
		startTL = main.AbsolutePosition - gui.AbsolutePosition
		isMaximized = false
	end, function(d)
		local screen = gui.AbsoluteSize
		local minW = math.min(300, screen.X - MARGIN * 2)
		local minH = math.min(260, screen.Y - MARGIN * 2)
		local w = math.clamp(startSize.X + d.X, minW, math.max(minW, screen.X - startTL.X))
		local h = math.clamp(startSize.Y + d.Y, minH, math.max(minH, screen.Y - startTL.Y))
		applyWindow(startTL.X, startTL.Y, w, h)
	end, function() end)
end

local savedWindow
maxBtn.MouseButton1Click:Connect(function()
	local screen = getScreen()
	if not isMaximized then
		local tl = main.AbsolutePosition - gui.AbsolutePosition
		local size = main.AbsoluteSize
		savedWindow = { x = tl.X, y = tl.Y, w = size.X, h = size.Y }
		applyWindow(MARGIN, MARGIN, screen.X - MARGIN * 2, screen.Y - MARGIN * 2)
		isMaximized = true
	else
		local s = savedWindow
		if s then
			local w = math.min(s.w, screen.X - MARGIN * 2)
			local h = math.min(s.h, screen.Y - MARGIN * 2)
			applyWindow(
				math.clamp(s.x, 0, math.max(0, screen.X - w)),
				math.clamp(s.y, 0, math.max(0, screen.Y - h)),
				w,
				h
			)
		end
		isMaximized = false
	end
end)

-- Keep everything on screen (rotation, window resize)
local function fitToScreen()
	local screen = gui.AbsoluteSize
	if screen.X < 10 or screen.Y < 10 then
		return
	end
	local size = main.AbsoluteSize
	local w = math.min(size.X, screen.X - MARGIN * 2)
	local h = math.min(size.Y, screen.Y - MARGIN * 2)
	local tl = main.AbsolutePosition - gui.AbsolutePosition
	applyWindow(
		math.clamp(tl.X, 0, math.max(0, screen.X - w)),
		math.clamp(tl.Y, 0, math.max(0, screen.Y - h)),
		w,
		h
	)
	local ts = toggle.AbsoluteSize
	local tp = toggle.AbsolutePosition - gui.AbsolutePosition
	toggle.Position = UDim2.fromOffset(
		math.clamp(tp.X, 0, math.max(0, screen.X - ts.X)),
		math.clamp(tp.Y, 0, math.max(0, screen.Y - ts.Y))
	)
end
keep(gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitToScreen))

------------------------------------------------------------------
-- COUNTS + FILTER + TABS
------------------------------------------------------------------
local function entryVisible(e)
	if e.class == "RemoteFunction" then
		if not showFunction then
			return false
		end
	elseif not showEvent then
		return false
	end
	if e.dir == "Out" and not showOut then
		return false
	end
	if e.dir == "In" and not showIn then
		return false
	end
	if filterText ~= "" then
		local hay = (e.remote.Name .. " " .. (e.path or "")):lower()
		if not hay:find(filterText, 1, true) then
			return false
		end
	end
	return true
end

local function updateCount()
	local visible = 0
	for _, e in ipairs(remoteOrder) do
		if entryVisible(e) then
			visible += 1
		end
	end

	if currentTab == "anim" then
		countLabel.Text = #order .. " saved"
	elseif currentTab == "settings" then
		countLabel.Text = "Settings"
	elseif visible == #remoteOrder then
		countLabel.Text = #remoteOrder .. " remotes"
	else
		countLabel.Text = visible .. " of " .. #remoteOrder
	end

	emptyLabel.Visible = (#order == 0)
	if #remoteOrder == 0 then
		remoteEmpty.Text = remoteEmptyText
		remoteEmpty.Visible = true
	elseif visible == 0 then
		remoteEmpty.Text = "No remotes match your filters."
		remoteEmpty.Visible = true
	else
		remoteEmpty.Visible = false
	end
end

local function applyRemoteFilter()
	for _, e in ipairs(remoteOrder) do
		e.row.Visible = entryVisible(e)
	end
	updateCount()
end

local function updateHiddenBar()
	local n = 0
	for _ in pairs(ignoredRemotes) do
		n += 1
	end
	for _ in pairs(ignoredNames) do
		n += 1
	end
	hiddenBar.Visible = n > 0
	hiddenLbl.Text = n .. (n == 1 and " remote is hidden" or " remotes are hidden")
end

do
	local function chip(text, initial, color, soft, onChange)
		return makeChip(chipRow, text, UDim2.new(0.25, -5, 1, 0), initial, onChange, color, soft)
	end
	chip("Event", true, C.event, C.eventSoft, function(v)
		showEvent = v
		applyRemoteFilter()
	end)
	chip("Function", true, C.func, C.funcSoft, function(v)
		showFunction = v
		applyRemoteFilter()
	end)
	chip("Sent", true, C.accentHover, C.accentSoft, function(v)
		showOut = v
		applyRemoteFilter()
	end)
	chip("Received", true, C.accentHover, C.accentSoft, function(v)
		showIn = v
		applyRemoteFilter()
	end)
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	filterText = searchBox.Text:lower()
	applyRemoteFilter()
end)

do
	local TAB_ORDER = { remote = 0, anim = 1, settings = 2 }
	local tabPages = { remote = remotePage, anim = animPage, settings = settingsPage }
	local tabToken = 0
	local function switchTab(name)
		if name == currentTab or not tabPages[name] then
			return
		end
		local dir = (TAB_ORDER[name] > TAB_ORDER[currentTab]) and 1 or -1
		currentTab = name
		tabToken += 1
		local my = tabToken
		for key, b in pairs(tabBtns) do
			tween(b, 0.15, { TextColor3 = (key == name) and C.text or C.muted })
		end
		tween(tabIndicator, 0.3, { Position = UDim2.new(TAB_ORDER[name] / 3, 8, 1, -2) }, Enum.EasingStyle.Back)
		veil.Visible = true
		tween(veil, 0.1, { BackgroundTransparency = 0 }).Completed:Once(function()
			if tabToken ~= my then
				return
			end
			for key, pg in pairs(tabPages) do
				pg.Visible = (key == name)
				pg.Position = UDim2.new()
			end
			local pg = tabPages[name]
			pg.Position = UDim2.fromOffset(dir * 18, 0)
			tween(pg, 0.28, { Position = UDim2.new() }, Enum.EasingStyle.Back)
			tween(veil, 0.22, { BackgroundTransparency = 1 }).Completed:Once(function()
				if tabToken == my then
					veil.Visible = false
				end
			end)
		end)
		updateCount()
	end
	for key, b in pairs(tabBtns) do
		b.MouseButton1Click:Connect(function()
			switchTab(key)
		end)
	end
end

------------------------------------------------------------------
-- ANIMATION LOGIC
------------------------------------------------------------------
local function getAnimator()
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then
		return nil
	end
	local animator = hum:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = hum
	end
	return animator
end

local function stopCurrent()
	if currentTrack then
		pcall(function()
			currentTrack:Stop(0.1)
		end)
		currentTrack = nil
	end
end

local function playEntry(entry)
	local animator = getAnimator()
	if not animator then
		setStatus("Character not found", C.red)
		return
	end
	stopCurrent()

	local anim = Instance.new("Animation")
	anim.AnimationId = "rbxassetid://" .. entry.id

	local ok, trackOrErr = pcall(function()
		return animator:LoadAnimation(anim)
	end)
	if not ok or not trackOrErr then
		setStatus("This animation could not be loaded", C.red)
		return
	end

	local t = trackOrErr
	t.Priority = Enum.AnimationPriority.Action4
	t.Looped = loopOn
	currentTrack = t
	t:Play(0.1)
	t:AdjustSpeed(speed)
	t.Stopped:Once(function()
		if currentTrack == t then
			currentTrack = nil
		end
	end)
	setStatus("Playing: " .. entry.name, C.green)
end

local function removeEntry(entry)
	if not entry.alive then
		return
	end
	entry.alive = false
	logged[entry.id] = nil
	for i, e in ipairs(order) do
		if e == entry then
			table.remove(order, i)
			break
		end
	end
	if entry.row then
		entry.row:Destroy()
	end
	updateCount()
end

local function buildRow(entry)
	local row = new("Frame", {
		BackgroundColor3 = C.panel,
		Size = UDim2.new(1, 0, 0, 56),
		LayoutOrder = -entry.n,
		BorderSizePixel = 0,
	}, list)
	corner(row, 8)
	stroke(row, C.line)

	entry.nameLbl = makeLabel(row, {
		Text = entry.name,
		Font = FONT_MED,
		TextSize = 13,
		Position = UDim2.fromOffset(12, 9),
		Size = UDim2.new(1, -150, 0, 18),
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
	makeLabel(row, {
		Text = entry.id,
		Font = FONT_MONO,
		TextSize = 11,
		TextColor3 = C.muted,
		Position = UDim2.fromOffset(12, 30),
		Size = UDim2.new(1, -150, 0, 16),
		TextTruncate = Enum.TextTruncate.AtEnd,
	})

	local playB = makeButton(row, "Play", "primary", UDim2.fromOffset(44, 26), UDim2.new(1, -136, 0.5, -13))
	local copyB = makeButton(row, "Copy", "ghost", UDim2.fromOffset(44, 26), UDim2.new(1, -86, 0.5, -13))
	local delB = makeButton(row, "", "ghost", UDim2.fromOffset(26, 26), UDim2.new(1, -36, 0.5, -13))
	addCross(delB, C.dim)

	playB.MouseButton1Click:Connect(function()
		playEntry(entry)
	end)
	copyB.MouseButton1Click:Connect(function()
		if setclipboard then
			setclipboard(entry.id)
			setStatus("Copied " .. entry.id, C.green)
		else
			setStatus("Copy is not available here", C.red)
		end
	end)
	delB.MouseButton1Click:Connect(function()
		removeEntry(entry)
	end)

	return row
end

local function addEntry(rawId, fallbackName)
	local id = tostring(rawId or ""):match("%d+")
	if not id or id == "0" then
		return nil, "bad"
	end
	if logged[id] then
		return logged[id], "exists"
	end

	-- keep the list from growing forever
	if #order >= MAX_ENTRIES then
		removeEntry(order[1])
	end

	counter += 1
	local shownName = nameCache[id]
	if not shownName then
		if fallbackName and fallbackName ~= "" and fallbackName ~= "Animation" then
			shownName = fallbackName
		else
			shownName = "Loading name..."
		end
	end

	local entry = { id = id, name = shownName, n = counter, alive = true }
	logged[id] = entry
	table.insert(order, entry)
	keepScroll(list, 56)
	entry.row = buildRow(entry)
	updateCount()

	-- Look up the real animation name (once per ID)
	if not nameCache[id] then
		task.spawn(function()
			local ok, info = pcall(function()
				return MarketplaceService:GetProductInfo(tonumber(id), Enum.InfoType.Asset)
			end)
			if ok and info and info.Name and info.Name ~= "" then
				nameCache[id] = info.Name
				if entry.alive and entry.nameLbl then
					entry.name = info.Name
					entry.nameLbl.Text = info.Name
				end
			elseif entry.alive and entry.name == "Loading name..." then
				entry.name = "Unknown animation"
				entry.nameLbl.Text = entry.name
			end
		end)
	end

	return entry, "new"
end

local function onTrack(t)
	if not loggingOn then
		return
	end
	local anim = t.Animation
	if not anim then
		return
	end
	addEntry(anim.AnimationId, anim.Name)
end

-- Watch the character's animations
local animConn
local function hookCharacter(char)
	if animConn then
		animConn:Disconnect()
		animConn = nil
	end
	currentTrack = nil
	task.spawn(function()
		local hum = char:WaitForChild("Humanoid", 10)
		if not hum then
			return
		end
		local animator = hum:FindFirstChildOfClass("Animator") or hum:WaitForChild("Animator", 5)
		if not animator then
			animator = Instance.new("Animator")
			animator.Parent = hum
		end
		if char ~= player.Character then
			return
		end
		animConn = animator.AnimationPlayed:Connect(onTrack)
		for _, t in ipairs(animator:GetPlayingAnimationTracks()) do
			onTrack(t)
		end
	end)
end

if player.Character then
	hookCharacter(player.Character)
end
keep(player.CharacterAdded:Connect(hookCharacter))

-- Animation page buttons
stopBtn.MouseButton1Click:Connect(function()
	stopCurrent()
	local animator = getAnimator()
	if animator then
		for _, t in ipairs(animator:GetPlayingAnimationTracks()) do
			pcall(function()
				t:Stop(0.1)
			end)
		end
	end
	setStatus("All animations stopped", C.amber)
end)

clearBtn.MouseButton1Click:Connect(function()
	for _, e in ipairs(table.clone(order)) do
		removeEntry(e)
	end
	setStatus("List cleared", C.amber)
end)

local function applySpeed(delta)
	speed = math.clamp(math.floor((speed + delta) * 100 + 0.5) / 100, 0.25, 3)
	local text = string.format("%.2f", speed):gsub("0+$", "")
	if text:sub(-1) == "." then
		text ..= "0"
	end
	speedLabel.Text = text .. "x"
	if currentTrack then
		currentTrack:AdjustSpeed(speed)
	end
end
slowBtn.MouseButton1Click:Connect(function()
	applySpeed(-0.25)
end)
fastBtn.MouseButton1Click:Connect(function()
	applySpeed(0.25)
end)

local function addFromBox()
	local entry, state = addEntry(idBox.Text, nil)
	if state == "bad" then
		setStatus("Enter a valid animation ID", C.red)
	elseif state == "exists" then
		setStatus("That ID is already in the list", C.amber)
	else
		idBox.Text = ""
		setStatus("Added " .. entry.id, C.green)
	end
end
addBtn.MouseButton1Click:Connect(addFromBox)
idBox.FocusLost:Connect(function(enter)
	if enter and idBox.Text ~= "" then
		addFromBox()
	end
end)

------------------------------------------------------------------
-- REMOTE VALUES -> TEXT / CODE
------------------------------------------------------------------
-- Copy of the values at the moment of the call, so the game changing a
-- table later cannot change what we show. Deep tables are kept as they are.
local function snapshot(v, depth, seen)
	if type(v) ~= "table" then
		return v
	end
	if depth > 3 then
		return v
	end
	seen = seen or {}
	if seen[v] then
		return seen[v]
	end
	local copy = {}
	seen[v] = copy
	local n = 0
	for k, val in next, v do
		n += 1
		if n > 60 then
			break
		end
		copy[k] = snapshot(val, depth + 1, seen)
	end
	return copy
end

-- Short text for the collapsed row
local function fmtValue(v, depth)
	local t = typeof(v)
	if t == "string" then
		if #v > 30 then
			v = v:sub(1, 30) .. "..."
		end
		return '"' .. v .. '"'
	elseif t == "Instance" then
		local ok, n = pcall(function()
			return v.Name
		end)
		return ok and n or "Instance"
	elseif t == "table" then
		if depth >= 1 then
			return "{...}"
		end
		local out, c = {}, 0
		for k, val in pairs(v) do
			c += 1
			if c > 3 then
				out[#out + 1] = "..."
				break
			end
			out[#out + 1] = (type(k) == "number" and "" or (tostring(k) .. "=")) .. fmtValue(val, depth + 1)
		end
		return "{" .. table.concat(out, ", ") .. "}"
	end
	return tostring(v)
end

local function preview(args)
	if not args or args.n == 0 then
		return "(no values)"
	end
	local parts = {}
	for i = 1, math.min(args.n, 4) do
		parts[#parts + 1] = fmtValue(args[i], 0)
	end
	local s = table.concat(parts, ", ")
	if args.n > 4 then
		s ..= ", ..."
	end
	return s
end

local function safePreview(args)
	local ok, s = pcall(preview, args)
	return ok and s or "(unreadable)"
end

-- Runnable code
local function isIdentifier(s)
	return s:match("^[%a_][%w_]*$") ~= nil
end

local function instancePath(inst)
	local chain = {}
	local cur = inst
	while cur and cur ~= game do
		table.insert(chain, 1, cur)
		cur = cur.Parent
	end
	if cur ~= game or #chain == 0 then
		return "nil --[[ not in game ]]"
	end
	local code
	if chain[1] == workspace then
		code = "workspace"
	else
		code = 'game:GetService("' .. chain[1].Name .. '")'
	end
	for i = 2, #chain do
		local n = chain[i].Name
		if isIdentifier(n) then
			code ..= "." .. n
		else
			code ..= "[" .. string.format("%q", n) .. "]"
		end
	end
	return code
end

local function toCode(v, depth)
	depth = depth or 0
	local t = typeof(v)
	if t == "string" then
		return string.format("%q", v)
	elseif t == "number" then
		if v ~= v then
			return "0/0"
		elseif v == math.huge then
			return "math.huge"
		elseif v == -math.huge then
			return "-math.huge"
		end
		return tostring(v)
	elseif t == "boolean" or t == "nil" then
		return tostring(v)
	elseif t == "Instance" then
		return instancePath(v)
	elseif t == "Vector3" then
		return string.format("Vector3.new(%s, %s, %s)", v.X, v.Y, v.Z)
	elseif t == "Vector2" then
		return string.format("Vector2.new(%s, %s)", v.X, v.Y)
	elseif t == "CFrame" then
		return "CFrame.new(" .. table.concat({ v:GetComponents() }, ", ") .. ")"
	elseif t == "Color3" then
		return string.format("Color3.new(%s, %s, %s)", v.R, v.G, v.B)
	elseif t == "EnumItem" then
		return tostring(v)
	elseif t == "table" then
		if depth > 4 then
			return "{}"
		end
		local out, c = {}, 0
		for k, val in pairs(v) do
			c += 1
			if c > 40 then
				out[#out + 1] = "--[[ more ]]"
				break
			end
			out[#out + 1] = "[" .. toCode(k, depth + 1) .. "] = " .. toCode(val, depth + 1)
		end
		return "{" .. table.concat(out, ", ") .. "}"
	end
	return "nil --[[ " .. t .. " ]]"
end

local function argsCode(args)
	local parts = {}
	if args then
		for i = 1, args.n do
			parts[i] = toCode(args[i])
		end
	end
	return table.concat(parts, ", ")
end

local function buildCode(entry)
	if entry.dir == "In" then
		return "-- Received from the server\nlocal args = { " .. argsCode(entry.args) .. " }"
	end
	local path = instancePath(entry.remote)
	if entry.class == "RemoteFunction" then
		return "local result = " .. path .. ":InvokeServer(" .. argsCode(entry.args) .. ")"
	end
	return path .. ":FireServer(" .. argsCode(entry.args) .. ")"
end

------------------------------------------------------------------
-- CODE VIEW (colored text)
------------------------------------------------------------------
local function esc(s)
	s = s:gsub("&", "&amp;")
	s = s:gsub("<", "&lt;")
	s = s:gsub(">", "&gt;")
	return s
end

local KEYWORDS = { ["local"] = true, ["true"] = true, ["false"] = true, ["nil"] = true }

local function highlight(code)
	local out, i, len = {}, 1, #code
	local function add(text, color)
		if color then
			out[#out + 1] = '<font color="' .. color .. '">' .. esc(text) .. "</font>"
		else
			out[#out + 1] = esc(text)
		end
	end
	while i <= len do
		local c = code:sub(i, i)
		if code:sub(i, i + 1) == "--" then
			local j
			if code:sub(i, i + 3) == "--[[" then
				local close = code:find("]]", i + 4, true)
				j = close and (close + 1) or len
			else
				local nl = code:find("\n", i, true)
				j = nl and (nl - 1) or len
			end
			add(code:sub(i, j), HL.cmt)
			i = j + 1
		elseif c == '"' then
			local j = i + 1
			while j <= len do
				local d = code:sub(j, j)
				if d == "\\" then
					j += 2
				elseif d == '"' then
					break
				else
					j += 1
				end
			end
			add(code:sub(i, math.min(j, len)), HL.str)
			i = j + 1
		elseif c:match("%d") or (c == "-" and code:sub(i + 1, i + 1):match("%d")) then
			local num = code:match("^-?%d+%.?%d*[eE]?[%+%-]?%d*", i) or c
			add(num, HL.num)
			i += #num
		elseif c:match("[%a_]") then
			local word = code:match("^[%a_][%w_]*", i)
			local nextChar = code:sub(i + #word, i + #word)
			if KEYWORDS[word] then
				add(word, HL.kw)
			elseif nextChar == "(" then
				add(word, HL.fn)
			else
				add(word)
			end
			i += #word
		else
			add(c)
			i += 1
		end
	end
	return table.concat(out)
end

local function codeForView(entry)
	local ok, code = pcall(buildCode, entry)
	if not ok then
		code = "-- Could not build the code for this remote"
	end
	if #code > 3000 then
		code = code:sub(1, 3000) .. "\n-- The code is longer. Press Copy code to get all of it."
	end
	return highlight(code)
end

local function metaText(entry)
	local function label(t)
		return '<font color="' .. HL.cmt .. '">' .. t .. "</font>"
	end
	local function line(k, v)
		return label(k) .. "   " .. esc(tostring(v))
	end
	local lines = { line("Path", entry.path or "?") }
	if entry.caller then
		local ok, name = pcall(function()
			return entry.caller:GetFullName()
		end)
		if ok then
			lines[#lines + 1] = line("From", name)
		end
	end
	if entry.lastResult then
		lines[#lines + 1] = line("Result", entry.lastResult)
	end
	if not S.deep then
		return table.concat(lines, "\n")
	end

	-- Deep details
	local isOut = entry.dir == "Out"
	lines[#lines + 1] = line("Class", entry.class .. (isOut and "  (sent to server)" or "  (received from server)"))
	if entry.caller then
		local ok, cls = pcall(function()
			return entry.caller.ClassName
		end)
		if ok then
			lines[#lines + 1] = line("Caller", cls)
		end
	end
	local span = math.max(1, (entry.lastClock or entry.firstClock) - entry.firstClock)
	lines[#lines + 1] = line("Calls", entry.count .. "  (about " .. string.format("%.1f", entry.count / span) .. "/s)")
	lines[#lines + 1] = line("Seen", "first " .. entry.firstStr .. "   last " .. (entry.lastStr or entry.firstStr))
	local okP, parentClass = pcall(function()
		return entry.remote.Parent and entry.remote.Parent.ClassName or "nil"
	end)
	lines[#lines + 1] = line("Parent", okP and parentClass or "?")
	lines[#lines + 1] = line("State", (blockedRemotes[entry.remote] or blockedNames[entry.remote.Name]) and "blocked" or "normal")

	local args = entry.args
	local n = args and args.n or 0
	lines[#lines + 1] = line("Args", n .. (n == 1 and " value" or " values"))
	for i = 1, math.min(n, 12) do
		lines[#lines + 1] = "   " .. label("[" .. i .. "]") .. " " .. esc(typeof(args[i])) .. "  " .. esc(fmtValue(args[i], 0))
	end
	if n > 12 then
		lines[#lines + 1] = "   ..."
	end

	local h = entry.history
	if h and #h > 0 then
		lines[#lines + 1] = label("Recent calls")
		for i = #h, math.max(1, #h - 5), -1 do
			lines[#lines + 1] = "   " .. esc(h[i].t .. "  " .. safePreview(h[i].args))
		end
	end

	if entry.stack and entry.stack ~= "" then
		lines[#lines + 1] = label("Stack")
		local c = 0
		for ln in entry.stack:gmatch("[^\n]+") do
			c += 1
			if c > 5 then
				break
			end
			lines[#lines + 1] = "   " .. esc(ln)
		end
	end
	return table.concat(lines, "\n")
end

local function refreshDetail(entry)
	if selectedEntry ~= entry then
		return
	end
	if detail.info then
		local ok, meta = pcall(metaText, entry)
		if ok then
			detail.setCode(meta)
		end
		return
	end
	local ok, code = pcall(codeForView, entry)
	if ok then
		detail.setCode(code)
	end
end

------------------------------------------------------------------
-- REMOTE ROWS
------------------------------------------------------------------
-- Run: sent remotes are fired again, received remotes are replayed on the client
local function runEntry(entry)
	local remote = entry.remote
	if not remote or not remote.Parent then
		setStatus("This remote no longer exists", C.red)
		return
	end
	local now = os.clock()
	if stealthOn then
		if entry.lastRunAt and now - entry.lastRunAt < 0.6 then
			setStatus("Slow down (protection is on)", C.amber)
			return
		end
		entry.lastRunAt = now
		task.wait(0.05 + math.random() * 0.2)
		now = os.clock()
	end
	lastRun = now
	local args = entry.args or table.pack()
	local name = remote.Name

	if entry.dir == "In" then
		selfFire[remote] = now + 0.6
		local fired = false
		if firesignal then
			fired = pcall(function()
				firesignal(remote.OnClientEvent, table.unpack(args, 1, args.n))
			end)
		end
		if not fired and getconnections then
			fired = pcall(function()
				for _, c in ipairs(getconnections(remote.OnClientEvent)) do
					if c.Fire then
						c:Fire(table.unpack(args, 1, args.n))
					end
				end
			end)
		end
		if fired then
			setStatus("Ran (received): " .. name, C.green)
		else
			setStatus("Your executor cannot run received remotes", C.red)
		end
		return
	end

	if entry.class == "RemoteFunction" then
		setStatus("Running: " .. name, C.accent)
		task.spawn(function()
			local res = table.pack(pcall(function()
				return remote:InvokeServer(table.unpack(args, 1, args.n))
			end))
			if res[1] then
				local vals = table.pack(table.unpack(res, 2, res.n))
				entry.lastResult = safePreview(vals)
				setStatus("Returned: " .. entry.lastResult, C.green)
			else
				entry.lastResult = "error: " .. tostring(res[2])
				setStatus("Run failed: " .. tostring(res[2]), C.red)
			end
			entry.detailStale = true
		end)
	else
		local ok, err = pcall(function()
			remote:FireServer(table.unpack(args, 1, args.n))
		end)
		if ok then
			setStatus("Ran: " .. name, C.green)
		else
			setStatus("Could not run: " .. tostring(err), C.red)
		end
	end
end

local function removeRemoteEntry(entry)
	if not entry.alive then
		return
	end
	entry.alive = false
	entry.animToken = (entry.animToken or 0) + 1
	if selectedEntry == entry then
		selectedEntry = nil
		detail.setEmpty()
	end
	remoteLogged[entry.dir][entry.remote] = nil
	for i, e in ipairs(remoteOrder) do
		if e == entry then
			table.remove(remoteOrder, i)
			break
		end
	end
	if entry.row then
		entry.row:Destroy()
	end
	updateCount()
end

local function hideRemote(remote)
	ignoredRemotes[remote] = true
	for _, dir in ipairs({ "Out", "In" }) do
		local e = remoteLogged[dir][remote]
		if e then
			removeRemoteEntry(e)
		end
	end
	updateHiddenBar()
end

local function refreshBlockColors()
	for _, e in ipairs(remoteOrder) do
		if e.alive and e.nameLbl then
			local blocked = blockedRemotes[e.remote] or blockedNames[e.remote.Name]
			e.nameLbl.TextColor3 = blocked and C.red or C.text
		end
	end
end

local function selectEntry(entry)
	local prev = selectedEntry
	if prev then
		prev.expanded = false
		if prev.alive and prev.row then
			tween(prev.row, 0.15, { BackgroundColor3 = C.rowBg })
			tween(prev.rowStroke, 0.15, { Color = C.line })
			tween(prev.stripe, 0.15, { Size = UDim2.new(0, 8, 1, 0) })
		end
	end
	if entry == nil or entry == prev then
		selectedEntry = nil
		detail.setEmpty()
		return
	end
	selectedEntry = entry
	entry.expanded = true
	tween(entry.row, 0.18, { BackgroundColor3 = C.rowSel })
	tween(entry.rowStroke, 0.18, { Color = C.rowSelLine })
	tween(entry.stripe, 0.22, { Size = UDim2.new(0, 12, 1, 0) }, Enum.EasingStyle.Back)
	detail.setFilled()
	refreshDetail(entry)
	detail.codeLbl.TextTransparency = 1
	detail.gutter.TextTransparency = 1
	tween(detail.codeLbl, 0.22, { TextTransparency = 0 })
	tween(detail.gutter, 0.22, { TextTransparency = 0 })
	entry.nextDetail = os.clock() + 0.4
end

local function copyText(text, okMsg)
	if setclipboard then
		setclipboard(text)
		setStatus(okMsg, C.green)
	else
		setStatus("Copy is not available here", C.red)
	end
end

detail.copyB.MouseButton1Click:Connect(function()
	local e = selectedEntry
	if e then
		local ok, code = pcall(buildCode, e)
		copyText(ok and code or "", "Code copied")
	end
end)
detail.pathB.MouseButton1Click:Connect(function()
	local e = selectedEntry
	if e then
		copyText(tostring(e.path), "Remote path copied")
	end
end)
detail.runB.MouseButton1Click:Connect(function()
	if selectedEntry then
		runEntry(selectedEntry)
	end
end)
detail.scriptB.MouseButton1Click:Connect(function()
	local e = selectedEntry
	if not e then
		return
	end
	local ok, path = pcall(function()
		return e.caller:GetFullName()
	end)
	if ok and path then
		copyText(path, "Script path copied")
	else
		setStatus("No calling script recorded", C.amber)
	end
end)
detail.infoB.MouseButton1Click:Connect(function()
	detail.info = not detail.info
	if selectedEntry then
		refreshDetail(selectedEntry)
	end
	setStatus(detail.info and "Showing function info" or "Showing code", C.dim)
end)
detail.clrB.MouseButton1Click:Connect(function()
	for _, e in ipairs(table.clone(remoteOrder)) do
		removeRemoteEntry(e)
	end
	setStatus("Remote list cleared", C.amber)
end)
detail.hideB.MouseButton1Click:Connect(function()
	local e = selectedEntry
	if e then
		local name = e.remote.Name
		hideRemote(e.remote)
		setStatus("Excluded: " .. name, C.amber)
	end
end)
detail.hideNB.MouseButton1Click:Connect(function()
	local e = selectedEntry
	if not e then
		return
	end
	local name = e.remote.Name
	ignoredNames[name] = true
	for _, x in ipairs(table.clone(remoteOrder)) do
		if x.remote.Name == name then
			removeRemoteEntry(x)
		end
	end
	updateHiddenBar()
	setStatus("Excluded name: " .. name, C.amber)
end)
detail.clrBlackB.MouseButton1Click:Connect(function()
	ignoredRemotes = {}
	ignoredNames = {}
	updateHiddenBar()
	setStatus("Blacklist cleared", C.green)
end)
detail.blockB.MouseButton1Click:Connect(function()
	local e = selectedEntry
	if not e then
		return
	end
	if e.dir ~= "Out" then
		setStatus("Only sent remotes can be blocked", C.amber)
		return
	end
	if blockedRemotes[e.remote] then
		blockedRemotes[e.remote] = nil
		setStatus("Unblocked: " .. e.remote.Name, C.green)
	else
		blockedRemotes[e.remote] = true
		setStatus("Blocked: " .. e.remote.Name, C.amber)
	end
	refreshBlockColors()
end)
detail.blockNB.MouseButton1Click:Connect(function()
	local e = selectedEntry
	if not e then
		return
	end
	if e.dir ~= "Out" then
		setStatus("Only sent remotes can be blocked", C.amber)
		return
	end
	local name = e.remote.Name
	if blockedNames[name] then
		blockedNames[name] = nil
		setStatus("Unblocked name: " .. name, C.green)
	else
		blockedNames[name] = true
		setStatus("Blocked name: " .. name, C.amber)
	end
	refreshBlockColors()
end)
detail.clrBlockB.MouseButton1Click:Connect(function()
	for k in pairs(blockedRemotes) do
		blockedRemotes[k] = nil
	end
	for k in pairs(blockedNames) do
		blockedNames[k] = nil
	end
	refreshBlockColors()
	setStatus("Blocklist cleared", C.green)
end)

local function buildRemoteRow(entry)
	local isFunction = (entry.class == "RemoteFunction")
	local isOut = (entry.dir == "Out")
	local stripeColor = Color3.fromRGB(100, 84, 236)
	if not isOut then
		stripeColor = C.green
	elseif isFunction then
		stripeColor = C.amber
	end

	local row = new("TextButton", {
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = C.rowBg,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, rowH()),
		LayoutOrder = -entry.n,
		Visible = entryVisible(entry),
	}, remoteList)
	entry.rowStroke = stroke(row, C.line)
	entry.rowStroke.Transparency = 1
	entry.stripe = new("Frame", {
		BackgroundColor3 = stripeColor,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, 0),
	}, row)
	entry.nameLbl = makeLabel(row, {
		Text = entry.remote.Name,
		TextSize = 14,
		TextTransparency = 1,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.fromOffset(18, 0),
		Size = UDim2.new(1, -64, 1, 0),
	})
	entry.countLbl = makeLabel(row, {
		Text = "x1",
		TextSize = 11,
		TextColor3 = C.muted,
		TextTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Right,
		Position = UDim2.new(1, -46, 0, 0),
		Size = UDim2.new(0, 40, 1, 0),
	})
	-- appear animation
	tween(row, 0.25, { BackgroundTransparency = 0 })
	tween(entry.rowStroke, 0.25, { Transparency = 0 })
	tween(entry.stripe, 0.32, { Size = UDim2.new(0, 8, 1, 0) }, Enum.EasingStyle.Back)
	tween(entry.nameLbl, 0.25, { TextTransparency = 0 })
	tween(entry.countLbl, 0.25, { TextTransparency = 0 })
	if detail.pulse then
		detail.pulse()
	end

	row.MouseEnter:Connect(function()
		if not entry.expanded then
			tween(row, 0.1, { BackgroundColor3 = C.rowHover })
			tween(entry.stripe, 0.15, { Size = UDim2.new(0, 10, 1, 0) })
		end
	end)
	row.MouseLeave:Connect(function()
		if not entry.expanded then
			tween(row, 0.1, { BackgroundColor3 = C.rowBg })
			tween(entry.stripe, 0.15, { Size = UDim2.new(0, 8, 1, 0) })
		end
	end)
	row.MouseButton1Click:Connect(function()
		selectEntry(entry)
	end)
	return row
end

-- Shows one remote call (or a batch of calls to the same remote)
local function onRemoteCall(remote, method, args, dir, caller, count, extra)
	if not running or not remoteLogging then
		return
	end
	if typeof(remote) ~= "Instance" or isIgnored(remote) then
		return
	end
	local ok, class = pcall(function()
		return remote.ClassName
	end)
	if not ok or not (class == "RemoteEvent" or class == "RemoteFunction" or class == "UnreliableRemoteEvent") then
		return
	end

	dir = dir or "Out"
	local entry = remoteLogged[dir][remote]
	if not entry then
		if #remoteOrder >= MAX_REMOTES then
			removeRemoteEntry(remoteOrder[1])
		end
		remoteSeq += 1
		local okPath, fullName = pcall(function()
			return remote:GetFullName()
		end)
		entry = {
			remote = remote,
			class = class,
			dir = dir,
			n = remoteSeq,
			count = 0,
			args = args,
			path = okPath and fullName or "?",
			alive = true,
			dirty = false,
			expanded = false,
			history = {},
			firstStr = os.date("%H:%M:%S"),
			firstClock = os.clock(),
		}
		remoteLogged[dir][remote] = entry
		table.insert(remoteOrder, entry)
		if sortMode == "new" then
			keepScroll(remoteList, rowH(), 4)
		end
		entry.row = buildRemoteRow(entry)
		sortDirty = true
		updateCount()
	end
	entry.count += (count or 1)
	entry.args = args
	entry.caller = caller or entry.caller
	entry.lastClock = os.clock()
	entry.lastStr = os.date("%H:%M:%S")
	if extra then
		entry.stack = extra.stack or entry.stack
		if extra.calls then
			local h = entry.history
			for _, c in ipairs(extra.calls) do
				if #h >= 8 then
					table.remove(h, 1)
				end
				h[#h + 1] = { t = os.date("%H:%M:%S", c.t), args = c.args }
			end
		end
	end
	entry.dirty = true
end

-- Sorting: rows get LayoutOrder = their place in the chosen order
local function sortRank(e)
	return (e.class == "RemoteFunction" and 2 or 1) * 10 + (e.dir == "Out" and 0 or 1)
end

local function applySort()
	sortDirty = false
	local arr = table.clone(remoteOrder)
	local mode = sortMode
	pcall(table.sort, arr, function(a, b)
		if mode == "old" then
			return a.n < b.n
		elseif mode == "calls" then
			if a.count ~= b.count then
				return a.count > b.count
			end
			return a.n > b.n
		elseif mode == "name" then
			local an, bn = a.remote.Name:lower(), b.remote.Name:lower()
			if an ~= bn then
				return an < bn
			end
			return a.n < b.n
		elseif mode == "type" then
			local ra, rb = sortRank(a), sortRank(b)
			if ra ~= rb then
				return ra < rb
			end
			return a.n > b.n
		end
		return a.n > b.n
	end)
	for i, e in ipairs(arr) do
		if e.row then
			e.row.LayoutOrder = i
		end
	end
end

-- Compact mode: one-line rows
local function applyCompactAll()
	local layout = remoteList:FindFirstChildOfClass("UIListLayout")
	if layout then
		layout.Padding = UDim.new(0, 4)
	end
	for _, e in ipairs(remoteOrder) do
		if e.alive and e.applyLayout then
			e.applyLayout()
		end
	end
end

------------------------------------------------------------------
-- REMOTE HOOKS
-- Sent: method calls (remote:FireServer) and direct calls
--       (remote.FireServer(remote)) are both caught.
-- The hook only drops a note in a queue (fast, cannot break the game);
-- the queue is turned into rows a few times per second.
-- Received: every RemoteEvent's OnClientEvent.
------------------------------------------------------------------
local passSelf, passClock = nil, 0 -- set by the namecall hook so the direct hook does not log the same call twice
local busy = false

-- Takes a note of one call (runs inside the game's thread, so it stays small)
local function record(self, method, ...)
	local q = S.queue
	if not q then
		return
	end
	local args = table.pack(...)
	-- protection mode: do less work inside the game's thread (shallow copy, no caller lookup)
	local d0 = S.stealth and 3 or 1
	for i = 1, args.n do
		args[i] = snapshot(args[i], d0, nil)
	end
	local caller
	if getcallingscript and not S.stealth then
		local okc, cs = pcall(getcallingscript)
		if okc then
			caller = cs
		end
	end
	local stack
	if S.deep and not S.stealth and debug and debug.traceback then
		stack = debug.traceback("", 2)
	end
	local item = q[self]
	if not item then
		item = { count = 0, method = method }
		q[self] = item
	end
	item.count += 1
	item.args = args
	item.caller = caller or item.caller
	item.stack = stack or item.stack
	if S.deep then
		local calls = item.calls
		if not calls then
			calls = {}
			item.calls = calls
		end
		if #calls >= 8 then
			table.remove(calls, 1)
		end
		calls[#calls + 1] = { args = args, t = os.time() }
	end
end

-- Runs inside the hook. Returns true when the call must be blocked.
-- Hooks always call env[KEY].intercept, so a newer copy of the script
-- takes over without installing the hooks again.
S.intercept = function(self, method, ...)
	if busy then
		return false
	end
	if checkcaller and checkcaller() then
		return false
	end
	if typeof(self) ~= "Instance" then
		return false
	end
	local blockedTbl = S.blocked
	local isBlocked = (blockedTbl ~= nil) and (blockedTbl[self] == true)
	if not isBlocked and S.blockedNames then
		isBlocked = S.blockedNames[self.Name] == true
	end
	if S.on and S.queue and not isIgnored(self) then
		busy = true
		pcall(record, self, method, ...)
		busy = false
	end
	return isBlocked
end

local function installRemoteHooks()
	if S.hooked then
		return true
	end

	local wrap = newcclosure or function(f)
		return f
	end
	local namecallOk, directOk = false, false

	-- Method calls: remote:FireServer(...)
	if hookmetamethod and getnamecallmethod then
		namecallOk = pcall(function()
			local old
			old = hookmetamethod(game, "__namecall", wrap(function(self, ...)
				local method = getnamecallmethod()
				if method == "FireServer" or method == "InvokeServer" or method == "fireServer" or method == "invokeServer" then
					local st = env[KEY]
					if st and st.intercept then
						local ok, blocked = pcall(st.intercept, self, method, ...)
						if ok and blocked == true then
							return
						end
					end
					-- the namecall name can be overwritten by the code above: put it back
					if setnamecallmethod then
						setnamecallmethod(method)
					end
					passSelf, passClock = self, os.clock()
					if method == "FireServer" or method == "fireServer" then
						old(self, ...)
						passSelf = nil
						return
					end
					return old(self, ...)
				end
				return old(self, ...)
			end))
		end)
	end

	-- Direct calls: remote.FireServer(remote, ...)
	if hookfunction then
		local seenFn = {}
		local function hookDirect(className, methodName)
			return pcall(function()
				local inst = Instance.new(className)
				local fn = inst[methodName]
				inst:Destroy()
				if seenFn[fn] then
					return
				end
				seenFn[fn] = true
				local oldFn
				oldFn = hookfunction(fn, wrap(function(self, ...)
					if passSelf ~= nil and passSelf == self and os.clock() - passClock < 0.05 then
						-- already handled by the namecall hook
						passSelf = nil
						return oldFn(self, ...)
					end
					local st = env[KEY]
					if st and st.intercept then
						local ok, blocked = pcall(st.intercept, self, methodName, ...)
						if ok and blocked == true then
							return
						end
					end
					return oldFn(self, ...)
				end))
			end)
		end
		local a = hookDirect("RemoteEvent", "FireServer")
		local b = hookDirect("RemoteFunction", "InvokeServer")
		local c = hookDirect("UnreliableRemoteEvent", "FireServer")
		directOk = a or b or c
	end

	S.hooked = namecallOk or directOk
	S.hookInfo = "Sent: namecall hook " .. (namecallOk and "on" or "off") .. ", direct hook " .. (directOk and "on" or "off")
	return S.hooked
end

-- Received remotes
local function hookIncoming(remote)
	if incomingConns[remote] then
		return
	end
	local okClass, class = pcall(function()
		return remote.ClassName
	end)
	if not okClass or not (class == "RemoteEvent" or class == "UnreliableRemoteEvent") then
		return
	end
	local ok, conn = pcall(function()
		return remote.OnClientEvent:Connect(function(...)
			if not running or not remoteLogging or isIgnored(remote) then
				return
			end
			local fireUntil = selfFire[remote]
			if fireUntil and os.clock() < fireUntil then
				return -- this is our own Run
			end
			local args = table.pack(...)
			for i = 1, args.n do
				args[i] = snapshot(args[i], 1, nil)
			end
			local item = inQueue[remote]
			if not item then
				item = { count = 0, method = "OnClientEvent" }
				inQueue[remote] = item
			end
			item.count += 1
			item.args = args
			if S.deep then
				local calls = item.calls
				if not calls then
					calls = {}
					item.calls = calls
				end
				if #calls >= 8 then
					table.remove(calls, 1)
				end
				calls[#calls + 1] = { args = args, t = os.time() }
			end
		end)
	end)
	if ok then
		incomingConns[remote] = conn
	end
end

task.spawn(function()
	local count = 0
	for _, d in ipairs(game:GetDescendants()) do
		if not running then
			return
		end
		local class = d.ClassName
		if class == "RemoteEvent" or class == "UnreliableRemoteEvent" then
			hookIncoming(d)
		end
		count += 1
		if count % 400 == 0 then
			task.wait()
		end
	end
end)
keep(game.DescendantAdded:Connect(function(d)
	local class = d.ClassName
	if class == "RemoteEvent" or class == "UnreliableRemoteEvent" then
		hookIncoming(d)
	end
end))

keep(game.DescendantRemoving:Connect(function(d)
	local c = incomingConns[d]
	if c then
		pcall(function()
			c:Disconnect()
		end)
		incomingConns[d] = nil
	end
end))

-- Turns the queues into rows and refreshes changed rows (a few times a second)
local function refreshRow(e, now)
	if e.dirty then
		e.dirty = false
		e.detailStale = true
		e.countLbl.Text = "x" .. e.count
		if e.argLbl then
			e.argLbl.Text = safePreview(e.args)
		end
		if sortMode == "calls" then
			sortDirty = true
		end
	end
	if e.expanded and e.detailStale and now >= (e.nextDetail or 0) then
		e.detailStale = false
		e.nextDetail = now + 0.4
		refreshDetail(e)
	end
end

task.spawn(function()
	local nextSort = 0
	while running do
		task.wait(0.15)
		pcall(function()
			local q = S.queue
			if q then
				for remote, item in pairs(q) do
					q[remote] = nil
					pcall(onRemoteCall, remote, item.method, item.args, "Out", item.caller, item.count, item)
				end
			end
			for remote, item in pairs(inQueue) do
				inQueue[remote] = nil
				pcall(onRemoteCall, remote, item.method, item.args, "In", nil, item.count, item)
			end

			local now = os.clock()
			for _, e in ipairs(remoteOrder) do
				if e.alive then
					pcall(refreshRow, e, now)
				end
			end
			if sortDirty and now >= nextSort then
				nextSort = now + 0.4
				applySort()
			end
		end)
	end
end)

------------------------------------------------------------------
-- SETTINGS PAGE
------------------------------------------------------------------
local function randName(len)
	local t = {}
	for i = 1, len do
		t[i] = string.char(math.random(97, 122))
	end
	return table.concat(t)
end

local function applyStealth(on)
	stealthOn = on
	S.stealth = on
	gui.Name = on and randName(math.random(8, 14)) or "ZeroSpyGui"
	main.Name = on and randName(math.random(6, 12)) or "Main"
	toggle.Name = on and randName(math.random(6, 12)) or "Toggle"
	pcall(function()
		gui.Archivable = not on
		for _, d in ipairs(gui:GetDescendants()) do
			d.Archivable = not on
		end
	end)
	pcall(function()
		gui.ResetOnSpawn = false
		gui.DisplayOrder = on and math.random(900, 2000) or 999
	end)
	setStatus(on and "Protection on (not 100%)" or "Protection off", on and C.amber or C.dim)
end

local settingsList = makeList(settingsPage, UDim2.fromOffset(10, 8), UDim2.new(1, -20, 1, -16))

-- A card with a title and a description. Returns card, body, description label.
local function settingCard(title, desc, order)
	local card = new("Frame", {
		BackgroundColor3 = C.panel,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = order,
	}, settingsList)
	corner(card, 8)
	stroke(card, C.line)
	local body = new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	}, card)
	new("UIPadding", {
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 12),
	}, body)
	new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, body)
	makeLabel(body, {
		Text = title,
		Font = FONT_MED,
		TextSize = 13,
		Size = UDim2.new(1, -48, 0, 18),
		LayoutOrder = 1,
	})
	local d = makeLabel(body, {
		Text = desc,
		TextSize = 11,
		TextColor3 = C.dim,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		Size = UDim2.new(1, -48, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
	})
	return card, body, d
end

-- 1. Protection
do
	local card, body = settingCard(
		"Protection",
		"Lowers the hub's footprint: random UI names, UI that cannot be cloned, lighter work inside the game's calls (shallow copy, no caller script, no call stack), and Run waits a random short time with a cooldown per remote. Deep details are limited while this is on.",
		1
	)
	makeLabel(body, {
		Text = "Not 100%. The game can still detect you, so use at your own risk.",
		TextSize = 11,
		TextColor3 = C.amber,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 3,
	})
	makeSwitch(card, UDim2.new(1, -46, 0, 12), false, applyStealth)
end

-- 2. Deep details
do
	local card = settingCard(
		"Deep details",
		"Open a remote to see much more: class, direction, calls per second, first and last call, parent, every argument with its type, recent calls, the caller script and the call stack. Only calls made after you turn this on are recorded in full.",
		2
	)
	makeSwitch(card, UDim2.new(1, -46, 0, 12), false, function(v)
		S.deep = v
		for _, e in ipairs(remoteOrder) do
			if e.alive and e.expanded then
				pcall(refreshDetail, e)
			end
		end
		setStatus(v and "Deep details on" or "Deep details off", v and C.green or C.dim)
	end)
end

-- 3. Sort
do
	local _, body = settingCard("Sort remotes", "Choose the order of the remote list.", 3)
	local grid = new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 3,
	}, body)
	new("UIGridLayout", {
		CellSize = UDim2.new(1 / 3, -4, 0, 28),
		CellPadding = UDim2.fromOffset(6, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, grid)

	local modes = {
		{ "new", "Newest" },
		{ "old", "Oldest" },
		{ "calls", "Most calls" },
		{ "name", "A - Z" },
		{ "type", "By type" },
	}
	local btns = {}
	local function paint()
		for mode, b in pairs(btns) do
			local on = (mode == sortMode)
			b.btn.BackgroundColor3 = on and C.accentSoft or C.panel
			b.btn.TextColor3 = on and C.accentHover or C.muted
			b.stroke.Color = on and C.accentHover or C.line
		end
	end
	for i, m in ipairs(modes) do
		local b = new("TextButton", {
			Text = m[2],
			Font = FONT_MED,
			TextSize = 12,
			AutoButtonColor = false,
			BorderSizePixel = 0,
			LayoutOrder = i,
		}, grid)
		corner(b, 6)
		btns[m[1]] = { btn = b, stroke = stroke(b, C.line) }
		b.MouseButton1Click:Connect(function()
			sortMode = m[1]
			paint()
			applySort()
			setStatus("Sorted: " .. m[2], C.green)
		end)
	end
	paint()
end

-- 4. Compact
do
	local card = settingCard(
		"Compact rows",
		"Shrinks every remote to one short line (name, type, count and the Run button).",
		4
	)
	makeSwitch(card, UDim2.new(1, -46, 0, 12), false, function(v)
		compactMode = v
		applyCompactAll()
		setStatus(v and "Compact rows on" or "Compact rows off", v and C.green or C.dim)
	end)
end

-- 5. Hook status
local hookStatusLbl
do
	local _, _, d = settingCard("Hook status", "Checking...", 5)
	hookStatusLbl = d
end

-- Remote page buttons
rClearBtn.MouseButton1Click:Connect(function()
	for _, e in ipairs(table.clone(remoteOrder)) do
		removeRemoteEntry(e)
	end
	setStatus("Remote list cleared", C.amber)
end)

pauseBtn.MouseButton1Click:Connect(function()
	remoteLogging = not remoteLogging
	S.on = remoteLogging
	pauseBtn.Text = remoteLogging and "Pause" or "Resume"
	pauseBtn.TextColor3 = remoteLogging and C.dim or C.amber
	setStatus(remoteLogging and "Remote logging resumed" or "Remote logging paused", remoteLogging and C.green or C.amber)
end)

hiddenShowBtn.MouseButton1Click:Connect(function()
	ignoredRemotes = {}
	ignoredNames = {}
	updateHiddenBar()
	setStatus("Hidden remotes will show again", C.green)
end)

if installRemoteHooks() then
	hookStatusLbl.Text = (S.hookInfo or "Sent: hooks active") .. "\nReceived: listening on every RemoteEvent."
	hookStatusLbl.TextColor3 = C.green
else
	remoteEmptyText = "Sent remotes cannot be logged on your executor.\nReceived remotes still work."
	remoteEmpty.TextColor3 = C.red
	hookStatusLbl.Text = "Sent hooks failed: your executor has no hookmetamethod / hookfunction.\nReceived remotes still work."
	hookStatusLbl.TextColor3 = C.red
end

------------------------------------------------------------------
-- CLEANUP (runs if you execute the script again)
------------------------------------------------------------------
S.cleanup = function()
	running = false
	S.queue = nil
	S.on = false
	S.intercept = nil
	S.blocked = nil
	for _, c in ipairs(connections) do
		pcall(function()
			c:Disconnect()
		end)
	end
	for _, c in pairs(incomingConns) do
		pcall(function()
			c:Disconnect()
		end)
	end
	if animConn then
		pcall(function()
			animConn:Disconnect()
		end)
	end
	stopCurrent()
	if gui then
		gui:Destroy()
	end
	S.cleanup = nil
end

updateCount()
updateHiddenBar()
setOpen(true)

]=====]

SOURCES.dex = [=====[
--[[
    ZeroDex  V1.5.0
    Roblox Studio style  |  Mobile + PC supported
]]

local env = (getgenv and getgenv()) or _G
if env.__DexV1 then pcall(env.__DexV1) end
if env.__ZeroDex then pcall(env.__ZeroDex) end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait()
    LocalPlayer = Players.LocalPlayer
end
local Mouse = LocalPlayer:GetMouse()

local IS_MOBILE = UIS.TouchEnabled and not UIS.KeyboardEnabled
local VERSION = "V1.5.0"
local SHEET = "rbxasset://textures/ClassImages.png"

local setclip = env.setclipboard or env.toclipboard or env.set_clipboard
    or (env.Clipboard and env.Clipboard.set)
local decompileFn = env.decompile

local connections = {}
local alive = true
local gui, propsConn

local function track(c)
    connections[#connections + 1] = c
    return c
end

local function cleanup()
    alive = false
    for _, c in ipairs(connections) do
        pcall(function() c:Disconnect() end)
    end
    if propsConn then pcall(function() propsConn:Disconnect() end) end
    if gui then pcall(function() gui:Destroy() end) end
    if env.__ZeroDex == cleanup then env.__ZeroDex = nil end
end
env.__ZeroDex = cleanup

local C = {
    bg = Color3.fromRGB(46, 46, 46),
    header = Color3.fromRGB(53, 53, 53),
    line = Color3.fromRGB(34, 34, 34),
    input = Color3.fromRGB(37, 37, 37),
    btn = Color3.fromRGB(64, 64, 64),
    text = Color3.fromRGB(215, 215, 215),
    sub = Color3.fromRGB(150, 150, 150),
    sel = Color3.fromRGB(11, 90, 175),
    accent = Color3.fromRGB(0, 162, 255),
    on = Color3.fromRGB(46, 160, 90),
    off = Color3.fromRGB(150, 60, 60),
}

local function kids(inst)
    local ok, list = pcall(inst.GetChildren, inst)
    return ok and list or {}
end

local FONT = Enum.Font.SourceSans
local FONTB = Enum.Font.SourceSansBold
local TS = IS_MOBILE and 15 or 14
local ROW_H = IS_MOBILE and 21 or 20
local HEAD_H = IS_MOBILE and 24 or 22
local SEARCH_H = IS_MOBILE and 24 or 22
local ACT_H = IS_MOBILE and 28 or 24
local ICON = IS_MOBILE and 19 or 17
local AW = IS_MOBILE and 16 or 15

local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function corner(o, r)
    return new("UICorner", { CornerRadius = UDim.new(0, r or 4) }, o)
end

local function stroke(o, color, thick)
    return new("UIStroke", {
        Color = color or C.line,
        Thickness = thick or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, o)
end

local function esc(s)
    return (tostring(s):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function isPointer(t)
    return t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch
end

local vp = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize) or Vector2.new(1280, 720)

gui = new("ScreenGui", {
    Name = "DexV1_" .. tostring(math.random(100000, 999999)),
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999999,
    IgnoreGuiInset = true,
})
pcall(function()
    if env.syn and env.syn.protect_gui then env.syn.protect_gui(gui) end
end)
do
    local parent
    pcall(function() parent = env.gethui and env.gethui() end)
    if not parent then pcall(function() parent = game:GetService("CoreGui") end) end
    local ok = parent and pcall(function() gui.Parent = parent end)
    if not ok or not gui.Parent then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end

local toastLabel = new("TextLabel", {
    AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.new(0.5, 0, 1, -40),
    AutomaticSize = Enum.AutomaticSize.XY,
    Size = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = C.header,
    TextColor3 = C.text,
    Font = FONT,
    TextSize = TS,
    Visible = false,
    ZIndex = 100,
}, gui)
corner(toastLabel, 6)
stroke(toastLabel, C.accent)
new("UIPadding", {
    PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14),
    PaddingTop = UDim.new(0, 7), PaddingBottom = UDim.new(0, 7),
}, toastLabel)

local toastId = 0
local function toast(msg)
    toastId = toastId + 1
    local id = toastId
    toastLabel.Text = tostring(msg)
    toastLabel.Visible = true
    task.delay(2.2, function()
        if toastId == id and alive then toastLabel.Visible = false end
    end)
end

local function dragDelta(handle, onStart, onMove)
    local dragging, startPos, inputObj = false, nil, nil
    track(handle.InputBegan:Connect(function(i)
        if isPointer(i.UserInputType) then
            dragging, startPos, inputObj = true, i.Position, i
            onStart()
            local c
            c = i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    c:Disconnect()
                end
            end)
        end
    end))
    track(UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i == inputObj) then
            onMove(i.Position - startPos)
        end
    end))
end

local PW = math.clamp(vp.X * 0.8, 300, 700)
local PH = math.clamp(vp.Y * 0.75, 220, 520)
local popup = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, PW, 0, PH),
    BackgroundColor3 = C.bg,
    Visible = false,
    ZIndex = 60,
    Active = true,
}, gui)
corner(popup, 6)
stroke(popup, C.accent)
local popupTitle = new("TextLabel", {
    Size = UDim2.new(1, -150, 0, 34),
    Position = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1,
    TextXAlignment = Enum.TextXAlignment.Left,
    Font = FONTB,
    TextSize = TS + 1,
    TextColor3 = C.text,
    TextTruncate = Enum.TextTruncate.AtEnd,
}, popup)
local popupScroll = new("ScrollingFrame", {
    Position = UDim2.new(0, 6, 0, 38),
    Size = UDim2.new(1, -12, 1, -44),
    BackgroundColor3 = C.input,
    BorderSizePixel = 0,
    ScrollBarThickness = 6,
    AutomaticCanvasSize = Enum.AutomaticSize.XY,
    CanvasSize = UDim2.new(),
}, popup)
corner(popupScroll, 4)
local popupBox = new("TextBox", {
    Size = UDim2.new(1, 0, 0, 0),
    AutomaticSize = Enum.AutomaticSize.XY,
    BackgroundTransparency = 1,
    TextColor3 = C.text,
    Font = Enum.Font.Code,
    TextSize = TS - 2,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    MultiLine = true,
    ClearTextOnFocus = false,
    TextWrapped = false,
}, popupScroll)
new("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingTop = UDim.new(0, 4) }, popupScroll)
local popupFull = ""

local function showText(title, text)
    popupFull = text
    popupTitle.Text = title
    popupBox.Text = (#text > 60000) and (text:sub(1, 60000) .. "\n-- [truncated: Copy gets everything]") or text
    popup.Visible = true
end

local function copy(text, label)
    if setclip then
        local ok = pcall(setclip, text)
        if ok then toast("Copied: " .. label) return end
    end
    showText(label, text)
    toast("No clipboard API - copy from this window")
end

do
    local function pbtn(text, xOff, fn)
        local b = new("TextButton", {
            Text = text,
            Size = UDim2.new(0, 64, 0, 28),
            Position = UDim2.new(1, xOff, 0, 4),
            BackgroundColor3 = C.btn,
            TextColor3 = C.text,
            Font = FONTB,
            TextSize = TS,
            BorderSizePixel = 0,
            ZIndex = 61,
        }, popup)
        corner(b, 4)
        track(b.Activated:Connect(fn))
    end
    pbtn("Close", -70, function() popup.Visible = false end)
    pbtn("Copy", -138, function() copy(popupFull, popupTitle.Text) end)
end

local WHITE, BLACK = Color3.new(1, 1, 1), Color3.new(0, 0, 0)
local function tone(c, a)
    if a >= 0 then return c:Lerp(WHITE, a) end
    return c:Lerp(BLACK, -a)
end

local function fr(parent, x, y, w, h, color, round)
    local f = new("Frame", {
        Position = UDim2.fromScale(x / 16, y / 16),
        Size = UDim2.fromScale(w / 16, h / 16),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
    }, parent)
    if round then new("UICorner", { CornerRadius = UDim.new(round, 0) }, f) end
    return f
end

local function ringShape(parent, x, y, w, h, color, thick)
    local f = fr(parent, x, y, w, h, BLACK, 0.5)
    f.BackgroundTransparency = 1
    new("UIStroke", { Color = color, Thickness = thick or 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, f)
    return f
end

local function subArea(parent, x, y, w, h)
    local f = fr(parent, x, y, w, h, BLACK)
    f.BackgroundTransparency = 1
    return f
end

local DRAW = {}
do

local function cubeDraw(c)
    return function(p)
        fr(p, 3, 1, 11, 5, tone(c, 0.4), 0.15)
        fr(p, 1, 5, 9, 10, c, 0.15)
        fr(p, 10, 6, 5, 8, tone(c, -0.35), 0.15)
    end
end
local function boxModel(c)
    return function(p)
        ringShape(p, 2, 2, 12, 12, c, 2).UICorner.CornerRadius = UDim.new(0.2, 0)
        fr(p, 5, 5, 6, 6, tone(c, -0.2), 0.2)
    end
end
local function folderDraw(c)
    return function(p)
        fr(p, 1, 2, 7, 4, tone(c, -0.25), 0.25)
        fr(p, 1, 4, 14, 10, c, 0.15)
        fr(p, 1, 4, 14, 2, tone(c, 0.35), 0.15)
    end
end
local function pageDraw(c)
    return function(p)
        fr(p, 2, 0, 12, 16, Color3.fromRGB(236, 239, 246), 0.14)
        fr(p, 2, 0, 12, 5, c, 0.2)
        fr(p, 4, 7, 8, 1.6, Color3.fromRGB(150, 156, 170), 0.5)
        fr(p, 4, 10, 8, 1.6, Color3.fromRGB(150, 156, 170), 0.5)
        fr(p, 4, 13, 5, 1.6, Color3.fromRGB(150, 156, 170), 0.5)
    end
end
local function windowDraw(c)
    return function(p)
        fr(p, 0, 2, 16, 12, Color3.fromRGB(232, 236, 244), 0.14)
        fr(p, 0, 2, 16, 4, c, 0.25)
        fr(p, 2, 8, 5, 4, tone(c, 0.35), 0.2)
        fr(p, 8, 8, 6, 1.6, Color3.fromRGB(150, 156, 170), 0.5)
        fr(p, 8, 11, 4, 1.6, Color3.fromRGB(150, 156, 170), 0.5)
    end
end
local function personDraw(c)
    return function(p)
        fr(p, 4.5, 0.5, 7, 7, c, 0.5)
        fr(p, 2, 8, 12, 7.5, tone(c, -0.15), 0.4)
    end
end
local function arrowsDraw(c)
    return function(p)
        fr(p, 1, 2, 11, 3.5, c, 0.5)
        fr(p, 10, 0, 5, 7.5, c, 0.2).Rotation = 0
        fr(p, 4, 10.5, 11, 3.5, tone(c, -0.2), 0.5)
        fr(p, 1, 8.5, 5, 7.5, tone(c, -0.2), 0.2)
    end
end
local function bulbDraw(c)
    return function(p)
        fr(p, 2.5, 0.5, 11, 11, c, 0.5)
        fr(p, 5, 3, 3, 3, tone(c, 0.6), 0.5)
        fr(p, 5.5, 11, 5, 2, Color3.fromRGB(150, 156, 170), 0.4)
        fr(p, 6, 13.5, 4, 2, Color3.fromRGB(110, 114, 126), 0.4)
    end
end
local function speakerDraw(c)
    return function(p)
        fr(p, 1, 5, 4, 6, c, 0.2)
        fr(p, 4, 2.5, 4, 11, c, 0.25)
        ringShape(p, 8, 4.5, 6, 7, tone(c, 0.3), 1.5)
    end
end
local function ringDraw(c)
    return function(p)
        ringShape(p, 1.5, 1.5, 13, 13, c, 2)
        fr(p, 5.5, 5.5, 5, 5, tone(c, 0.3), 0.5)
    end
end
local function blockDraw(c)
    return function(p)
        fr(p, 1.5, 1.5, 13, 13, c, 0.28)
        fr(p, 5.5, 5.5, 5, 5, WHITE, 0.5)
    end
end
local function valueDraw(c)
    return function(p)
        fr(p, 0.5, 2.5, 15, 11, c, 0.25)
        fr(p, 3, 5, 5, 1.8, WHITE, 0.5)
        fr(p, 3, 8.5, 9, 1.8, WHITE, 0.5)
    end
end
local function cameraDraw(c)
    return function(p)
        fr(p, 3, 1.5, 6, 3, c, 0.3)
        fr(p, 0.5, 3.5, 15, 10.5, c, 0.22)
        fr(p, 4.5, 5, 7, 7, WHITE, 0.5)
        fr(p, 6.2, 6.7, 3.6, 3.6, tone(c, -0.45), 0.5)
    end
end
local function diamondDraw(c)
    return function(p)
        local d = fr(p, 3, 3, 10, 10, BLACK, 0.12)
        d.BackgroundTransparency = 1
        d.Rotation = 45
        new("UIStroke", { Color = c, Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, d)
    end
end
local function globeDraw(blue, green)
    return function(p)
        fr(p, 0.5, 0.5, 15, 15, blue, 0.5)
        fr(p, 2.5, 3, 6, 5, green, 0.45)
        fr(p, 8, 8.5, 5.5, 5, green, 0.45)
        fr(p, 3.5, 9, 3, 3, tone(blue, 0.3), 0.5)
    end
end

DRAW.globe = globeDraw(Color3.fromRGB(52, 140, 235), Color3.fromRGB(90, 205, 110))
DRAW.root = globeDraw(Color3.fromRGB(220, 224, 232), Color3.fromRGB(150, 160, 175))
DRAW.players = function(p)
    local g, o = Color3.fromRGB(90, 205, 110), Color3.fromRGB(250, 170, 60)
    fr(p, 1.5, 1.5, 5, 5, g, 0.5); fr(p, 0.5, 7.5, 7, 6, g, 0.35)
    fr(p, 9.5, 1.5, 5, 5, o, 0.5); fr(p, 8.5, 7.5, 7, 6, o, 0.35)
    fr(p, 5.5, 8.5, 5, 6.5, Color3.fromRGB(80, 150, 240), 0.35)
    fr(p, 6, 4, 4, 4, Color3.fromRGB(80, 150, 240), 0.5)
end
DRAW.bulb = bulbDraw(Color3.fromRGB(255, 214, 70))
DRAW.cube_b = cubeDraw(Color3.fromRGB(120, 168, 235))
DRAW.cube_m = cubeDraw(Color3.fromRGB(165, 130, 235))
DRAW.cube_o = cubeDraw(Color3.fromRGB(245, 160, 75))
DRAW.cube_p = cubeDraw(Color3.fromRGB(190, 120, 240))
DRAW.cube_y = cubeDraw(Color3.fromRGB(245, 205, 90))
DRAW.cube_g = cubeDraw(Color3.fromRGB(120, 205, 140))
DRAW.model = function(p)
    fr(p, 4.5, 0.5, 6, 6, Color3.fromRGB(255, 196, 40), 0.12)
    fr(p, 0.5, 8.5, 6.5, 6.5, Color3.fromRGB(40, 160, 255), 0.12)
    fr(p, 9, 8.5, 6.5, 6.5, Color3.fromRGB(255, 70, 160), 0.12)
end
DRAW.player = function(p)
    local c = Color3.fromRGB(225, 225, 225)
    ringShape(p, 4.5, 0.8, 7, 7, c, 1.5)
    local b = fr(p, 2, 9.5, 12, 6, BLACK, 0.5)
    b.BackgroundTransparency = 1
    new("UIStroke", { Color = c, Thickness = 1.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, b)
end
DRAW.folder = folderDraw(Color3.fromRGB(250, 200, 80))
DRAW.page_b = pageDraw(Color3.fromRGB(70, 140, 235))
DRAW.page_g = pageDraw(Color3.fromRGB(70, 195, 120))
DRAW.page_p = pageDraw(Color3.fromRGB(170, 105, 235))
DRAW.page_t = pageDraw(Color3.fromRGB(60, 195, 185))
DRAW.window_b = windowDraw(Color3.fromRGB(235, 100, 120))
DRAW.window_p = windowDraw(Color3.fromRGB(160, 105, 235))
DRAW.window_c = windowDraw(Color3.fromRGB(70, 170, 235))
DRAW.person_g = personDraw(Color3.fromRGB(95, 205, 120))
DRAW.person_r = personDraw(Color3.fromRGB(240, 110, 110))
DRAW.person_k = personDraw(Color3.fromRGB(245, 125, 160))
DRAW.remote = arrowsDraw(Color3.fromRGB(250, 150, 70))
DRAW.bindable = arrowsDraw(Color3.fromRGB(80, 190, 235))
DRAW.speaker = speakerDraw(Color3.fromRGB(250, 175, 90))
DRAW.ring = ringDraw(Color3.fromRGB(90, 200, 235))
DRAW.diamond = diamondDraw(Color3.fromRGB(205, 210, 220))
DRAW.camera = cameraDraw(Color3.fromRGB(150, 160, 180))
DRAW.value = valueDraw(Color3.fromRGB(110, 200, 110))
DRAW.block = blockDraw(Color3.fromRGB(135, 150, 185))
DRAW.block_o = blockDraw(Color3.fromRGB(245, 150, 80))
DRAW.block_p = blockDraw(Color3.fromRGB(175, 120, 235))

DRAW.__cube = cubeDraw
DRAW.__block = blockDraw
end

local SERVICE_KIND = {
    Workspace = "globe", Players = "players", Lighting = "bulb", CoreGui = "window_b",
    CorePackages = "diamond", ReplicatedStorage = "cube_o", ReplicatedFirst = "cube_o",
    ServerStorage = "cube_p", ServerScriptService = "page_t", StarterGui = "window_p",
    StarterPack = "cube_y", StarterPlayer = "person_g", SoundService = "speaker",
    Chat = "window_c", Teams = "person_r", MaterialService = "cube_o",
    TextChatService = "window_c", Camera = "camera",
}

local kindCache = {}
local function kindFor(inst)
    if inst == game then return "root" end
    if inst.Parent == game then
        return SERVICE_KIND[inst.Name] or SERVICE_KIND[inst.ClassName] or "diamond"
    end
    local cn = inst.ClassName
    local k = kindCache[cn]
    if k then return k end
    if inst:IsA("LocalScript") then k = "page_g"
    elseif inst:IsA("ModuleScript") then k = "page_p"
    elseif inst:IsA("LuaSourceContainer") then k = "page_b"
    elseif inst:IsA("Folder") or inst:IsA("Configuration") then k = "folder"
    elseif inst:IsA("Model") then k = "model"
    elseif inst:IsA("MeshPart") or inst:IsA("UnionOperation") or inst:IsA("NegateOperation") then k = "cube_m"
    elseif inst:IsA("BasePart") then k = "cube_b"
    elseif inst:IsA("Humanoid") or inst:IsA("HumanoidDescription") then k = "person_k"
    elseif inst:IsA("Player") then k = "player"
    elseif inst:IsA("Team") then k = "person_r"
    elseif inst:IsA("RemoteEvent") or inst:IsA("RemoteFunction") then k = "remote"
    elseif inst:IsA("BindableEvent") or inst:IsA("BindableFunction") then k = "bindable"
    elseif inst:IsA("LayerCollector") then k = "window_p"
    elseif inst:IsA("GuiObject") then k = "block_p"
    elseif inst:IsA("ValueBase") then k = "value"
    elseif inst:IsA("Sound") or inst:IsA("SoundGroup") or inst:IsA("SoundEffect") then k = "speaker"
    elseif inst:IsA("Light") then k = "bulb"
    elseif inst:IsA("Camera") then k = "camera"
    elseif inst:IsA("Attachment") or inst:IsA("Constraint") or inst:IsA("JointInstance") then k = "ring"
    elseif inst:IsA("Tool") or inst:IsA("HopperBin") then k = "cube_y"
    elseif inst:IsA("Accoutrement") then k = "cube_o"
    elseif inst:IsA("ParticleEmitter") or inst:IsA("Fire") or inst:IsA("Smoke") or inst:IsA("Sparkles")
        or inst:IsA("Trail") or inst:IsA("Beam") then k = "block_o"
    else k = "block" end
    kindCache[cn] = k
    return k
end

local function applyIcon(rec, inst)
    local k = kindFor(inst)
    if rec.kind == k then return end
    rec.kind = k
    rec.plate:ClearAllChildren()
    ;(DRAW[k] or DRAW.block)(rec.plate)
end

local function getPath(inst)
    if inst == game then return "game" end
    local parts, cur = {}, inst
    while cur and cur ~= game do
        table.insert(parts, 1, cur)
        cur = cur.Parent
    end
    if cur ~= game then return "nil --[[ " .. inst.Name .. " (parent = nil) ]]" end
    local s = "game"
    for idx, p in ipairs(parts) do
        local done = false
        if idx == 1 then
            local ok, svc = pcall(game.GetService, game, p.ClassName)
            if ok and svc == p then
                s = (p.ClassName == "Workspace") and "workspace" or ('game:GetService("' .. p.ClassName .. '")')
                done = true
            end
        end
        if not done then
            if p == LocalPlayer then
                s = 'game:GetService("Players").LocalPlayer'
            elseif (function()
                local par = p.Parent
                local okF, fc = pcall(par.FindFirstChild, par, p.Name)
                return okF and fc ~= nil and fc ~= p
            end)() then
                local pos = table.find(p.Parent:GetChildren(), p) or 1
                s = s .. ":GetChildren()[" .. pos .. "]"
            elseif p.Name:match("^[%a_][%w_]*$") then
                s = s .. "." .. p.Name
            else
                s = s .. '["' .. (p.Name:gsub("\\", "\\\\"):gsub('"', '\\"')) .. '"]'
            end
        end
    end
    return s
end

local function fmtNum(n) return tostring(math.round(n * 1000) / 1000) end

local function fmt(v)
    local t = typeof(v)
    if v == nil then return "nil" end
    if t == "number" then return fmtNum(v) end
    if t == "string" then return v end
    if t == "Color3" then
        return string.format("[%d, %d, %d]", math.round(v.R * 255), math.round(v.G * 255), math.round(v.B * 255))
    end
    if t == "Vector3" then return fmtNum(v.X) .. ", " .. fmtNum(v.Y) .. ", " .. fmtNum(v.Z) end
    if t == "Vector2" then return fmtNum(v.X) .. ", " .. fmtNum(v.Y) end
    if t == "UDim" then return fmtNum(v.Scale) .. ", " .. fmtNum(v.Offset) end
    if t == "UDim2" then
        return string.format("{%s, %s}, {%s, %s}", fmtNum(v.X.Scale), fmtNum(v.X.Offset), fmtNum(v.Y.Scale), fmtNum(v.Y.Offset))
    end
    if t == "CFrame" then
        local parts = {}
        for i, n in ipairs({ v:GetComponents() }) do parts[i] = fmtNum(n) end
        return table.concat(parts, ", ")
    end
    if t == "EnumItem" or t == "BrickColor" then return v.Name end
    return tostring(v)
end

local EDITABLE = {
    string = true, number = true, Color3 = true, Vector3 = true, Vector2 = true,
    UDim = true, UDim2 = true, CFrame = true, EnumItem = true, BrickColor = true,
}

local function nums(s)
    local t = {}
    for n in s:gmatch("-?%d*%.?%d+") do t[#t + 1] = tonumber(n) end
    return t
end

local function parseValue(cur, text)
    local t = typeof(cur)
    if t == "string" then return text end
    if t == "number" then return assert(tonumber(text), "Must be a number") end
    if t == "boolean" then
        local l = text:lower()
        return l == "true" or l == "1"
    end
    local n = nums(text)
    if t == "Color3" then
        assert(#n >= 3, "Needs 3 values (R, G, B)")
        if text:find("%.") and n[1] <= 1 and n[2] <= 1 and n[3] <= 1 then
            return Color3.new(n[1], n[2], n[3])
        end
        return Color3.fromRGB(n[1], n[2], n[3])
    elseif t == "Vector3" then
        assert(#n >= 3, "Needs 3 values")
        return Vector3.new(n[1], n[2], n[3])
    elseif t == "Vector2" then
        assert(#n >= 2, "Needs 2 values")
        return Vector2.new(n[1], n[2])
    elseif t == "UDim" then
        assert(#n >= 2, "Needs 2 values")
        return UDim.new(n[1], n[2])
    elseif t == "UDim2" then
        assert(#n >= 4, "Needs 4 values (xScale, xOffset, yScale, yOffset)")
        return UDim2.new(n[1], n[2], n[3], n[4])
    elseif t == "CFrame" then
        if #n == 3 then return CFrame.new(n[1], n[2], n[3]) end
        assert(#n >= 12, "Needs 3 values (position) or 12 values")
        return CFrame.new(table.unpack(n, 1, 12))
    elseif t == "EnumItem" then
        for _, item in ipairs(cur.EnumType:GetEnumItems()) do
            if item.Name:lower() == text:lower() or tostring(item.Value) == text then
                return item
            end
        end
        error("Enum not found")
    elseif t == "BrickColor" then
        return BrickColor.new(text)
    end
    error("This type cannot be edited")
end

local dockW = IS_MOBILE and math.clamp(vp.X * 0.33, 240, 400) or 320
local dockTop = IS_MOBILE and 58 or 44
local dockH = math.clamp(vp.Y - dockTop, 200, 900)
local dockSide = "Right"
local explorerOn, propsOn, dockOpen = true, true, true
local ratio = 0.5
local opacity = 0.45
local showClass = false
local autoRefresh = true
local clickSelect = false

local expanded = setmetatable({}, { __mode = "k" })
expanded[game] = true
local flat = {}
local rows = {}
local selected = nil
local multi = {}
local sortAZ = true
local bookmarks = {}
local buildToken = 0
local undoStack = {}
local selHistory = {}
local navigating = false

local function pushUndo(label, fn)
    undoStack[#undoStack + 1] = { label = label, fn = fn }
    if #undoStack > 40 then table.remove(undoStack, 1) end
end
local searchQuery = ""
local dirty, propsDirty = false, false
local lastBuild = 0
local lastClick = { inst = nil, t = 0 }

local setSelected, reveal, rebuild, renderExplorer, buildProps, updateTiles, openContext

local hl
pcall(function()
    hl = Instance.new("Highlight")
    hl.FillColor = C.accent
    hl.OutlineColor = Color3.new(1, 1, 1)
    hl.FillTransparency = 0.6
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = gui
end)

local dock = new("Frame", {
    Name = "Dock",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Active = true,
}, gui)

local panelFrames = {}
local headFrames = {}

local function makePanel(title, bottomReserve, placeholder)
    local p = new("Frame", { BackgroundColor3 = C.bg, BorderSizePixel = 0, ClipsDescendants = true }, dock)
    stroke(p, C.line)
    panelFrames[#panelFrames + 1] = p
    local head = new("Frame", {
        Size = UDim2.new(1, 0, 0, HEAD_H), BackgroundColor3 = C.header, BorderSizePixel = 0,
    }, p)
    headFrames[#headFrames + 1] = head
    local titleLbl = new("TextLabel", {
        Text = title,
        Size = UDim2.new(1, -HEAD_H * 2 - 12, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = FONT,
        TextSize = TS + 1,
        TextColor3 = C.text,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, head)
    local function headBtn(xOff)
        local b = new("TextButton", {
            Text = "", Size = UDim2.new(0, HEAD_H, 1, 0), Position = UDim2.new(1, xOff, 0, 0),
            BackgroundTransparency = 1,
        }, head)
        local h = new("Frame", {
            Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0.5, -6, 0.5, -6), BackgroundTransparency = 1,
        }, b)
        return b, h
    end
    local closeB, ch = headBtn(-HEAD_H - 2)
    fr(ch, 7, -2, 1.8, 20, C.text).Rotation = 45
    fr(ch, 7, -2, 1.8, 20, C.text).Rotation = -45
    local restoreB, rh = headBtn(-HEAD_H * 2 - 2)
    local sq1 = fr(rh, 4, 0, 11, 11, BLACK); sq1.BackgroundTransparency = 1
    new("UIStroke", { Color = C.text, Thickness = 1.2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, sq1)
    local sq2 = fr(rh, 0, 4, 11, 11, C.header)
    new("UIStroke", { Color = C.text, Thickness = 1.2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, sq2)
    local search = new("TextBox", {
        PlaceholderText = placeholder,
        Text = "",
        Size = UDim2.new(1, -8, 0, SEARCH_H),
        Position = UDim2.new(0, 4, 0, HEAD_H + 4),
        BackgroundColor3 = C.input,
        TextColor3 = C.text,
        PlaceholderColor3 = C.sub,
        Font = FONT,
        TextSize = TS,
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0,
    }, p)
    headFrames[#headFrames + 1] = search
    stroke(search, Color3.fromRGB(62, 62, 62))
    new("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 26) }, search)
    local mag = new("Frame", {
        Size = UDim2.new(0, 14, 0, 14), AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -9, 0, HEAD_H + 4 + SEARCH_H / 2), BackgroundTransparency = 1,
    }, p)
    ringShape(mag, 1, 1, 10, 10, C.sub, 1.5)
    fr(mag, 9.5, 9, 2, 6, C.sub, 0.4).Rotation = -45
    local top = HEAD_H + SEARCH_H + 8
    local list = new("ScrollingFrame", {
        Position = UDim2.new(0, 0, 0, top),
        Size = UDim2.new(1, 0, 1, -(top + bottomReserve)),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = IS_MOBILE and 14 or 12,
        ScrollBarImageColor3 = Color3.fromRGB(85, 85, 85),
        CanvasSize = UDim2.new(),
        ClipsDescendants = true,
        ScrollingDirection = Enum.ScrollingDirection.Y,
    }, p)
    return p, search, list, titleLbl, closeB, restoreB
end

local explorerPanel, exSearch, exList, _, exClose, exRestore = makePanel("Explorer", ACT_H, "Search workspace")
local propsPanel, prSearch, prList, prTitle, prClose, prRestore = makePanel("Properties", 0, "Search properties")

local splitter = new("Frame", {
    Size = UDim2.new(1, 0, 0, 10),
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundTransparency = 1,
    Active = true,
    ZIndex = 5,
}, dock)
new("Frame", {
    Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 0.5, -1),
    BackgroundColor3 = C.line, BorderSizePixel = 0, ZIndex = 5,
}, splitter)

local widthHandle = new("Frame", {
    Size = UDim2.new(0, 8, 1, 0),
    BackgroundColor3 = C.accent,
    BackgroundTransparency = 1,
    Active = true,
    ZIndex = 6,
}, dock)

local hideBtn = new("TextButton", {
    Name = "HideDock",
    Text = ">",
    Size = UDim2.new(0, IS_MOBILE and 18 or 16, 0, IS_MOBILE and 34 or 26),
    BackgroundColor3 = Color3.fromRGB(34, 34, 34),
    TextColor3 = C.text,
    Font = FONTB,
    TextSize = TS + 3,
    BorderSizePixel = 0,
    ZIndex = 28,
}, gui)
stroke(hideBtn, C.line)

local dockTween
local layoutDock

layoutDock = function(animate)
    if not alive then return end
    local anyPanel = explorerOn or propsOn
    dock.Size = UDim2.new(0, dockW, 0, dockH)
    local tabY = dockTop - hideBtn.Size.Y.Offset
    local shown, hidden
    if dockSide == "Right" then
        dock.AnchorPoint = Vector2.new(1, 0)
        shown = UDim2.new(1, 0, 0, dockTop)
        hidden = UDim2.new(1, dockW + 4, 0, dockTop)
        hideBtn.AnchorPoint = Vector2.new(1, 0)
        hideBtn.Position = UDim2.new(1, 0, 0, tabY)
        widthHandle.Position = UDim2.new(0, 0, 0, 0)
        hideBtn.Text = dockOpen and ">" or "<"
    else
        dock.AnchorPoint = Vector2.new(0, 0)
        shown = UDim2.new(0, 0, 0, dockTop)
        hidden = UDim2.new(0, -dockW - 4, 0, dockTop)
        hideBtn.AnchorPoint = Vector2.new(0, 0)
        hideBtn.Position = UDim2.new(0, 0, 0, tabY)
        widthHandle.Position = UDim2.new(1, -8, 0, 0)
        hideBtn.Text = dockOpen and "<" or ">"
    end
    hideBtn.Visible = anyPanel
    local target = dockOpen and shown or hidden
    if dockTween then pcall(function() dockTween:Cancel() end) end

    if animate then
        if dockOpen then dock.Visible = anyPanel end
        local info = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        dockTween = TweenService:Create(dock, info, { Position = target })
        local thisTween = dockTween
        dockTween.Completed:Connect(function()
            if alive and dockTween == thisTween and not dockOpen then dock.Visible = false end
        end)
        dockTween:Play()
    else
        dock.Position = target
        dock.Visible = anyPanel and dockOpen
    end

    explorerPanel.Visible = explorerOn
    propsPanel.Visible = propsOn
    splitter.Visible = explorerOn and propsOn
    if explorerOn and propsOn then
        explorerPanel.Position = UDim2.new(0, 0, 0, 0)
        explorerPanel.Size = UDim2.new(1, 0, ratio, -3)
        propsPanel.Position = UDim2.new(0, 0, ratio, 3)
        propsPanel.Size = UDim2.new(1, 0, 1 - ratio, -3)
        splitter.Position = UDim2.new(0, 0, ratio, 0)
    elseif explorerOn then
        explorerPanel.Position = UDim2.new(0, 0, 0, 0)
        explorerPanel.Size = UDim2.new(1, 0, 1, 0)
    else
        propsPanel.Position = UDim2.new(0, 0, 0, 0)
        propsPanel.Size = UDim2.new(1, 0, 1, 0)
    end
    for _, f in ipairs(panelFrames) do f.BackgroundTransparency = opacity end
    for _, f in ipairs(headFrames) do f.BackgroundTransparency = opacity * 0.6 end
    if renderExplorer then renderExplorer() end
    if updateTiles then updateTiles() end
end

local function setDockOpen(v)
    dockOpen = v
    layoutDock(true)
end
track(hideBtn.Activated:Connect(function() setDockOpen(not dockOpen) end))

do
    local startRatio, startW
    dragDelta(splitter, function() startRatio = ratio end, function(d)
        local h = math.max(1, dock.AbsoluteSize.Y)
        ratio = math.clamp(startRatio + d.Y / h, 0.15, 0.85)
        layoutDock()
    end)
    dragDelta(widthHandle, function() startW = dockW end, function(d)
        local dx = (dockSide == "Right") and -d.X or d.X
        dockW = math.clamp(startW + dx, 200, math.max(260, vp.X * 0.6))
        layoutDock()
    end)
end

track(exClose.Activated:Connect(function() explorerOn = false layoutDock() end))
track(exRestore.Activated:Connect(function() ratio = (ratio > 0.6) and 0.5 or 0.85 layoutDock() end))
track(prRestore.Activated:Connect(function() ratio = (ratio < 0.4) and 0.5 or 0.15 layoutDock() end))
track(prClose.Activated:Connect(function() propsOn = false layoutDock() end))

local function makeRow()
    local frame = new("TextButton", {
        Text = "",
        AutoButtonColor = false,
        Size = UDim2.new(1, 0, 0, ROW_H),
        BackgroundColor3 = C.sel,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, exList)
    local rec = { frame = frame }
    rec.arrow = new("TextButton", {
        Text = ">",
        Size = UDim2.new(0, AW, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = C.sub,
        Font = FONT,
        TextSize = TS,
    }, frame)
    rec.plate = new("Frame", {
        Size = UDim2.new(0, ICON, 0, ICON),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, frame)
    rec.label = new("TextLabel", {
        BackgroundTransparency = 1,
        RichText = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Font = FONT,
        TextSize = TS,
        TextColor3 = C.text,
    }, frame)

    track(rec.arrow.Activated:Connect(function()
        local e = rec.entry
        if e then
            expanded[e.inst] = (not expanded[e.inst]) or nil
            rebuild()
        end
    end))
    track(frame.InputBegan:Connect(function(i)
        local t = i.UserInputType
        if t == Enum.UserInputType.MouseButton2 then
            local e = rec.entry
            if e and openContext then openContext(e.inst) end
        elseif t == Enum.UserInputType.Touch then
            local start = i.Position
            local token = {}
            rec.press = token
            task.delay(0.45, function()
                if not alive or rec.press ~= token then return end
                if i.UserInputState == Enum.UserInputState.End then return end
                if (i.Position - start).Magnitude > 14 then return end
                local e = rec.entry
                if e and openContext then
                    rec.longFired = true
                    openContext(e.inst)
                end
            end)
        end
    end))
    track(frame.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then
            rec.press = nil
            if rec.longFired then
                rec.longFired = false
                rec.suppressUntil = os.clock() + 0.4
            end
        end
    end))
    track(frame.Activated:Connect(function()
        local e = rec.entry
        if not e then return end
        local now = os.clock()
        if rec.suppressUntil and now < rec.suppressUntil then return end
        if lastClick.inst == e.inst and now - lastClick.t < 0.35 and searchQuery == "" then
            expanded[e.inst] = (not expanded[e.inst]) or nil
            rebuild()
        end
        lastClick.inst, lastClick.t = e.inst, now
        setSelected(e.inst)
    end))
    rows[#rows + 1] = rec
    return rec
end

renderExplorer = function()
    if not alive then return end
    local total = #flat
    exList.CanvasSize = UDim2.new(0, 0, 0, total * ROW_H)
    local h = exList.AbsoluteSize.Y
    local first = math.max(1, math.floor(exList.CanvasPosition.Y / ROW_H) + 1)
    local count = math.ceil(h / ROW_H) + 1
    for i = 1, count do
        local rec = rows[i] or makeRow()
        local idx = first + i - 1
        local e = flat[idx]
        if e then
            local inst = e.inst
            local indent = e.depth * 12
            local has = (searchQuery == "") and (#kids(inst) > 0)
            rec.entry = e
            rec.frame.Visible = true
            rec.frame.Position = UDim2.new(0, 0, 0, (idx - 1) * ROW_H)
            rec.arrow.Position = UDim2.new(0, indent, 0, 0)
            rec.arrow.Visible = has
            rec.arrow.Rotation = expanded[inst] and 90 or 0
            rec.plate.Position = UDim2.new(0, indent + AW + 1, 0.5, 0)

            applyIcon(rec, inst)

            local lx = indent + AW + ICON + 6
            rec.label.Position = UDim2.new(0, lx, 0, 0)
            rec.label.Size = UDim2.new(1, -lx - 4, 1, 0)
            local okN, name = pcall(function() return inst.Name end)
            local txt = esc(okN and name or "?")
            if showClass then
                local okC, cn = pcall(function() return inst.ClassName end)
                txt = txt .. '  <font color="#8b8b8b">' .. esc(okC and cn or "") .. "</font>"
            end
            rec.label.Text = txt
            rec.frame.BackgroundTransparency = (inst == selected or multi[inst]) and 0.4 or 1
        else
            rec.frame.Visible = false
            rec.entry = nil
        end
    end
    for i = count + 1, #rows do
        rows[i].frame.Visible = false
        rows[i].entry = nil
    end
end

local CollectionService = game:GetService("CollectionService")

local function buildMatcher(q)
    local tests = {}
    for term in q:gmatch("%S+") do
        local key, val = term:match("^(%a+):(.*)$")
        key = key and key:lower()
        if key and (key == "class" or key == "c" or key == "name" or key == "n" or key == "prop"
            or key == "p" or key == "attr" or key == "a" or key == "tag" or key == "t") then
            local lv = val:lower()
            if key == "class" or key == "c" then
                tests[#tests + 1] = function(d)
                    if d.ClassName:lower():find(lv, 1, true) then return true end
                    local ok, r = pcall(d.IsA, d, val)
                    return ok and r
                end
            elseif key == "name" or key == "n" then
                tests[#tests + 1] = function(d) return d.Name:lower():find(lv, 1, true) ~= nil end
            elseif key == "prop" or key == "p" then
                local pname, pval = val:match("^([^=]+)=(.*)$")
                pname = pname or val
                tests[#tests + 1] = function(d)
                    local ok, v = pcall(function() return d[pname] end)
                    if not ok or v == nil then return false end
                    if not pval then return true end
                    return tostring(v):lower():find(pval:lower(), 1, true) ~= nil
                end
            elseif key == "attr" or key == "a" then
                local aname, aval = val:match("^([^=]+)=(.*)$")
                aname = aname or val
                tests[#tests + 1] = function(d)
                    local ok, v = pcall(d.GetAttribute, d, aname)
                    if not ok or v == nil then return false end
                    if not aval then return true end
                    return tostring(v):lower():find(aval:lower(), 1, true) ~= nil
                end
            else
                tests[#tests + 1] = function(d)
                    local ok, r = pcall(CollectionService.HasTag, CollectionService, d, val)
                    return ok and r
                end
            end
        else
            local lt = term:lower()
            tests[#tests + 1] = function(d)
                return d.Name:lower():find(lt, 1, true) ~= nil or d.ClassName:lower():find(lt, 1, true) ~= nil
            end
        end
    end
    return function(d)
        for _, t in ipairs(tests) do
            local ok, r = pcall(t, d)
            if not (ok and r) then return false end
        end
        return #tests > 0
    end
end

local function byName(a, b)
    local an, bn = a.Name:lower(), b.Name:lower()
    if an ~= bn then return an < bn end
    return a.ClassName < b.ClassName
end

rebuild = function()
    lastBuild = os.clock()
    dirty = false
    buildToken = buildToken + 1
    local token = buildToken
    if searchQuery ~= "" then
        local match = buildMatcher(searchQuery)
        local res, n, seen = {}, 0, 0
        local okD, descs = pcall(game.GetDescendants, game)
        for _, d in ipairs(okD and descs or {}) do
            seen = seen + 1
            if seen % 4000 == 0 then
                task.wait()
                if token ~= buildToken or not alive then return end
            end
            if match(d) then
                n = n + 1
                res[n] = { inst = d, depth = 0 }
                if n >= 500 then break end
            end
        end
        if token ~= buildToken then return end
        table.clear(flat)
        for i2, e in ipairs(res) do flat[i2] = e end
    else
        table.clear(flat)
        local TOP_FIRST = { Workspace = 1, Players = 2 }
        local function sortTop(list)
            pcall(table.sort, list, function(a, b)
                local pa, pb = TOP_FIRST[a.Name] or 100, TOP_FIRST[b.Name] or 100
                if pa ~= pb then return pa < pb end
                return byName(a, b)
            end)
            return list
        end
        local function walk(inst, depth)
            flat[#flat + 1] = { inst = inst, depth = depth }
            if expanded[inst] then
                local list = kids(inst)
                if sortAZ then pcall(table.sort, list, byName) end
                for _, k in ipairs(list) do walk(k, depth + 1) end
            end
        end
        for _, svc in ipairs(sortTop(kids(game))) do walk(svc, 0) end
    end
    renderExplorer()
end

reveal = function(inst)
    if searchQuery ~= "" then
        searchQuery = ""
        exSearch.Text = ""
    end
    local p = inst.Parent
    while p do
        expanded[p] = true
        p = p.Parent
    end
    rebuild()
    for i, e in ipairs(flat) do
        if e.inst == inst then
            exList.CanvasPosition = Vector2.new(0, math.max(0, (i - 1) * ROW_H - exList.AbsoluteSize.Y / 2))
            break
        end
    end
    renderExplorer()
end

track(exList:GetPropertyChangedSignal("CanvasPosition"):Connect(renderExplorer))
track(exList:GetPropertyChangedSignal("AbsoluteSize"):Connect(renderExplorer))

local searchToken = 0
track(exSearch:GetPropertyChangedSignal("Text"):Connect(function()
    searchToken = searchToken + 1
    local t = searchToken
    task.delay(0.35, function()
        if t == searchToken and alive and exSearch.Text ~= searchQuery then
            searchQuery = exSearch.Text
            exList.CanvasPosition = Vector2.zero
            rebuild()
        end
    end)
end))

track(game.DescendantAdded:Connect(function(inst)
    if expanded[inst.Parent] then dirty = true end
end))
track(game.DescendantRemoving:Connect(function(inst)
    multi[inst] = nil
    if expanded[inst.Parent] then dirty = true end
    if inst == selected then
        task.defer(function() if alive then setSelected(nil) end end)
    end
end))

local GROUPS = {
    { "Data", {
        "Name", "ClassName", "Parent", "Archivable", "DisplayName", "UserId", "Team", "TeamColor", "Neutral",
        "AccountAge", "MembershipType", "Character", "Value", "Disabled", "RunContext", "Enabled", "Visible",
        "Text", "PlaceholderText", "Image", "SoundId", "MeshId", "TextureID", "ActionText", "ObjectText",
    } },
    { "Appearance", {
        "Color", "BrickColor", "Material", "Transparency", "Reflectance", "CastShadow", "TextColor3", "TextSize",
        "Font", "TextTransparency", "TextScaled", "TextWrapped", "RichText", "TextXAlignment", "TextYAlignment",
        "BackgroundColor3", "BackgroundTransparency", "BorderSizePixel", "BorderColor3", "ImageColor3",
        "ImageTransparency", "ScaleType", "ZIndex", "Brightness", "Shadows", "FogColor", "Ambient",
        "OutdoorAmbient", "Thickness", "CornerRadius", "FieldOfView", "TopSurface", "BottomSurface",
    } },
    { "Transform", {
        "Position", "Size", "CFrame", "Orientation", "Rotation", "AnchorPoint", "AutomaticSize", "SizeConstraint",
        "WorldPivot", "WorldPosition", "WorldCFrame", "StudsOffset", "Offset", "Scale", "CanvasSize", "HipHeight",
    } },
    { "Behavior", {
        "Anchored", "CanCollide", "CanTouch", "CanQuery", "Massless", "Locked", "Shape", "CollisionGroup",
        "AssemblyLinearVelocity", "AssemblyAngularVelocity", "PrimaryPart", "Active", "Selectable",
        "AutoButtonColor", "ClipsDescendants", "LayoutOrder", "ResetOnSpawn", "DisplayOrder", "IgnoreGuiInset",
        "ZIndexBehavior", "Adornee", "AlwaysOnTop", "MaxDistance", "Range", "Angle", "Volume", "Playing", "Looped",
        "PlaybackSpeed", "TimePosition", "TimeLength", "Rate", "Lifetime", "Speed", "MaxActivationDistance",
        "HoldDuration", "RequiresLineOfSight", "Attachment0", "Attachment1", "Part0", "Part1", "C0", "C1", "Axis",
        "ScrollBarThickness", "Padding", "SortOrder", "FillDirection", "HorizontalAlignment", "VerticalAlignment",
        "ClearTextOnFocus", "Health", "MaxHealth", "WalkSpeed", "JumpPower", "JumpHeight", "UseJumpPower",
        "AutoRotate", "PlatformStand", "Sit", "DisplayDistanceType", "HealthDisplayType", "CameraType",
        "CameraSubject", "CameraMode", "ClockTime", "TimeOfDay", "FogEnd", "FogStart", "GlobalShadows",
        "Technology", "Gravity", "FallenPartsDestroyHeight", "StreamingEnabled",
    } },
}

local PH = ROW_H + 2
local propRows, propHeaders = {}, {}
local groupOpen = {}

new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, prList)
prList.AutomaticCanvasSize = Enum.AutomaticSize.Y

local function clearProps()
    for _, c in ipairs(prList:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end
    table.clear(propRows)
    table.clear(propHeaders)
end

local function applyPropVisibility()
    local q = prSearch.Text:lower()
    local hasMatch = {}
    for _, r in ipairs(propRows) do
        local match = (q == "") or (r.name:lower():find(q, 1, true) ~= nil)
        if match then hasMatch[r.group] = true end
        r.frame.Visible = match and (q ~= "" or groupOpen[r.group] ~= false)
    end
    for _, h in ipairs(propHeaders) do
        h.frame.Visible = hasMatch[h.group] == true
        h.arrow.Rotation = (groupOpen[h.group] ~= false) and 90 or 0
    end
end
track(prSearch:GetPropertyChangedSignal("Text"):Connect(applyPropVisibility))

local function addHeader(group, order)
    local f = new("TextButton", {
        Text = "",
        Size = UDim2.new(1, 0, 0, ROW_H),
        BackgroundColor3 = C.header,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        LayoutOrder = order,
    }, prList)
    local arrow = new("TextLabel", {
        Text = ">",
        Size = UDim2.new(0, AW + 4, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = C.sub,
        Font = FONTB,
        TextSize = TS - 2,
    }, f)
    new("TextLabel", {
        Text = group,
        Size = UDim2.new(1, -AW - 8, 1, 0),
        Position = UDim2.new(0, AW + 4, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = C.text,
        Font = FONTB,
        TextSize = TS,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, f)
    local rec = { frame = f, arrow = arrow, group = group }
    propHeaders[#propHeaders + 1] = rec
    track(f.Activated:Connect(function()
        groupOpen[group] = not (groupOpen[group] ~= false)
        applyPropVisibility()
    end))
    return rec
end

local colorBox, colorPreview, colorHex, colorApply

local function colorToHex(c)
    return string.format("#%02X%02X%02X", math.round(c.R * 255), math.round(c.G * 255), math.round(c.B * 255))
end

local function parseColorText(txt)
    txt = txt:gsub("%s", "")
    local hex = txt:match("^#?(%x%x%x%x%x%x)$")
    if hex then
        return Color3.fromRGB(tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16))
    end
    local r, g, b = txt:match("^(%d+),(%d+),(%d+)$")
    if r then
        return Color3.fromRGB(math.clamp(tonumber(r), 0, 255), math.clamp(tonumber(g), 0, 255), math.clamp(tonumber(b), 0, 255))
    end
    return nil
end

local function openColorPicker(start, apply)
    colorApply = apply
    if not colorBox then
        local COLS = 10
        local CELL = IS_MOBILE and 26 or 24
        local GAP = 3
        local palette = {}
        for i = 0, COLS - 1 do
            local v = 1 - i / (COLS - 1)
            palette[#palette + 1] = Color3.new(v, v, v)
        end
        local hues = { 0, 0.07, 0.13, 0.17, 0.3, 0.45, 0.52, 0.6, 0.72, 0.85 }
        local sv = { { 0.35, 1 }, { 0.65, 1 }, { 1, 1 }, { 1, 0.78 }, { 1, 0.55 }, { 1, 0.35 } }
        for _, q in ipairs(sv) do
            for _, h in ipairs(hues) do palette[#palette + 1] = Color3.fromHSV(h, q[1], q[2]) end
        end
        local rowsN = math.ceil(#palette / COLS)
        local gridW = COLS * (CELL + GAP) - GAP
        local gridH = rowsN * (CELL + GAP) - GAP
        local TOPH, BOT = 28, 28
        local W, H = gridW + 16, TOPH + gridH + 8 + BOT + 8

        colorBox = new("Frame", {
            Name = "ColorPicker",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.new(0, W, 0, H),
            BackgroundColor3 = C.bg,
            BorderSizePixel = 0,
            Active = true,
            Visible = false,
            ZIndex = 90,
        }, gui)
        corner(colorBox, 6)
        stroke(colorBox, C.accent)
        new("TextLabel", {
            Text = "Pick a color",
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -50, 0, TOPH),
            BackgroundTransparency = 1,
            TextColor3 = C.text,
            Font = FONTB,
            TextSize = TS + 1,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, colorBox)
        local closeBtn = new("TextButton", {
            Text = "X",
            Position = UDim2.new(1, -34, 0, 3),
            Size = UDim2.new(0, 28, 0, TOPH - 6),
            BackgroundColor3 = C.btn,
            TextColor3 = C.text,
            Font = FONTB,
            TextSize = TS,
            BorderSizePixel = 0,
        }, colorBox)
        corner(closeBtn, 3)
        track(closeBtn.Activated:Connect(function() colorBox.Visible = false end))

        for i, col in ipairs(palette) do
            local cx = (i - 1) % COLS
            local cy = math.floor((i - 1) / COLS)
            local cell = new("TextButton", {
                Text = "",
                AutoButtonColor = false,
                Position = UDim2.new(0, 8 + cx * (CELL + GAP), 0, TOPH + cy * (CELL + GAP)),
                Size = UDim2.new(0, CELL, 0, CELL),
                BackgroundColor3 = col,
                BorderSizePixel = 0,
            }, colorBox)
            corner(cell, 4)
            stroke(cell, Color3.fromRGB(20, 20, 20))
            track(cell.Activated:Connect(function()
                colorBox.Visible = false
                if colorApply then colorApply(col) end
            end))
        end

        local by = TOPH + gridH + 8
        colorPreview = new("Frame", {
            Position = UDim2.new(0, 8, 0, by),
            Size = UDim2.new(0, BOT, 0, BOT),
            BackgroundColor3 = Color3.new(),
            BorderSizePixel = 0,
        }, colorBox)
        corner(colorPreview, 4)
        stroke(colorPreview, Color3.fromRGB(90, 90, 90))
        colorHex = new("TextBox", {
            Text = "",
            PlaceholderText = "#RRGGBB or R,G,B",
            ClearTextOnFocus = false,
            Position = UDim2.new(0, 16 + BOT, 0, by),
            Size = UDim2.new(1, -(24 + BOT), 0, BOT),
            BackgroundColor3 = C.input,
            TextColor3 = C.text,
            PlaceholderColor3 = C.sub,
            Font = FONT,
            TextSize = TS,
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderSizePixel = 0,
        }, colorBox)
        corner(colorHex, 4)
        new("UIPadding", { PaddingLeft = UDim.new(0, 8) }, colorHex)
        track(colorHex.FocusLost:Connect(function(enter)
            if not enter then return end
            local c = parseColorText(colorHex.Text)
            if c then
                colorBox.Visible = false
                if colorApply then colorApply(c) end
            else
                toast("Invalid color")
            end
        end))
    end
    colorPreview.BackgroundColor3 = start
    colorHex.Text = colorToHex(start)
    colorBox.Visible = true
end

local function addRow(order, group, name, get, set)
    local ok, v = pcall(get)
    if not ok then return false end
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, PH),
        BackgroundTransparency = 1,
        LayoutOrder = order,
    }, prList)
    new("Frame", {
        Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = C.line, BorderSizePixel = 0,
    }, row)
    new("Frame", {
        Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(0.42, 0, 0, 0),
        BackgroundColor3 = C.line, BorderSizePixel = 0,
    }, row)
    new("TextLabel", {
        Text = name,
        Size = UDim2.new(0.42, -8, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = C.text,
        Font = FONT,
        TextSize = TS,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, row)

    local t = typeof(v)
    local ctrl, update, swatch
    local common = {
        Position = UDim2.new(0.42, 1, 0, 0),
        Size = UDim2.new(0.58, -1, 1, -1),
        BackgroundTransparency = 1,
        BackgroundColor3 = C.input,
        BorderSizePixel = 0,
        TextColor3 = C.text,
        TextSize = TS,
        Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left,
    }

    if t == "boolean" then
        common.Text = ""
        ctrl = new("TextButton", common, row)
        new("UIPadding", { PaddingLeft = UDim.new(0, 8) }, ctrl)
        update = function()
            local ok2, val = pcall(get)
            if ok2 then
                ctrl.Text = (val and "[x]  true" or "[  ]  false")
                ctrl.TextColor3 = val and Color3.fromRGB(120, 220, 140) or C.sub
            end
        end
        track(ctrl.Activated:Connect(function()
            local ok2, val = pcall(get)
            if ok2 then set(not val) end
            update()
        end))
    elseif t == "Instance" or v == nil then
        common.Text = ""
        ctrl = new("TextButton", common, row)
        new("UIPadding", { PaddingLeft = UDim.new(0, 8) }, ctrl)
        ctrl.TextTruncate = Enum.TextTruncate.AtEnd
        update = function()
            local ok2, val = pcall(get)
            if ok2 and typeof(val) == "Instance" then
                ctrl.Text = val.Name .. " (" .. val.ClassName .. ")"
                ctrl.TextColor3 = Color3.fromRGB(110, 180, 255)
            else
                ctrl.Text = "nil"
                ctrl.TextColor3 = C.sub
            end
        end
        track(ctrl.Activated:Connect(function()
            local ok2, val = pcall(get)
            if ok2 and typeof(val) == "Instance" then
                setSelected(val)
                reveal(val)
            end
        end))
    elseif t == "Color3" or t == "BrickColor" then
        common.Text = ""
        ctrl = new("TextButton", common, row)
        swatch = new("Frame", {
            Size = UDim2.new(0, ICON - 4, 0, ICON - 4),
            Position = UDim2.new(0, 8, 0.5, -(ICON - 4) / 2),
            BorderSizePixel = 0,
        }, ctrl)
        stroke(swatch, Color3.fromRGB(90, 90, 90))
        new("UIPadding", { PaddingLeft = UDim.new(0, ICON + 14) }, ctrl)
        update = function()
            local ok2, val = pcall(get)
            if ok2 then
                ctrl.Text = fmt(val)
                swatch.BackgroundColor3 = (typeof(val) == "Color3") and val or (val.Color or Color3.new())
            end
        end
        track(ctrl.Activated:Connect(function()
            local ok2, val = pcall(get)
            if not ok2 then return end
            local cur = (typeof(val) == "Color3") and val or (val.Color or Color3.new())
            openColorPicker(cur, function(c)
                set(t == "BrickColor" and BrickColor.new(c) or c)
                update()
            end)
        end))
    elseif EDITABLE[t] then
        common.Text = ""
        common.ClearTextOnFocus = false
        ctrl = new("TextBox", common, row)
        new("UIPadding", { PaddingLeft = UDim.new(0, 8) }, ctrl)
        update = function()
            if ctrl:IsFocused() then return end
            local ok2, val = pcall(get)
            if ok2 then
                ctrl.Text = fmt(val)
            end
        end
        track(ctrl.Focused:Connect(function()
            ctrl.BackgroundTransparency = 0
        end))
        track(ctrl.FocusLost:Connect(function(enter)
            ctrl.BackgroundTransparency = 1
            if enter then set(ctrl.Text) end
            update()
        end))
    else
        common.Text = ""
        ctrl = new("TextLabel", common, row)
        new("UIPadding", { PaddingLeft = UDim.new(0, 8) }, ctrl)
        ctrl.TextColor3 = C.sub
        update = function()
            local ok2, val = pcall(get)
            if ok2 then ctrl.Text = fmt(val) end
        end
    end
    update()
    propRows[#propRows + 1] = { frame = row, name = name, group = group, update = update }
    return true
end

local function makeSetter(read, write)
    return function(v)
        local ok, err = pcall(function()
            local cur = read()
            if type(v) == "string" and typeof(cur) ~= "string" then
                v = parseValue(cur, v)
            end
            write(v)
            pushUndo("Property", function() write(cur) end)
        end)
        if not ok then
            local msg = tostring(err):gsub("^.-:%d+: ", "")
            toast("Edit failed: " .. msg:sub(1, 70))
        end
    end
end

buildProps = function()
    clearProps()
    local inst = selected
    prTitle.Text = "Properties" .. (inst and ("  -  " .. inst.Name) or "")
    if not inst then
        new("TextLabel", {
            Text = "Select an object in Explorer\nto view Properties",
            Size = UDim2.new(1, 0, 0, 70),
            BackgroundTransparency = 1,
            TextColor3 = C.sub,
            Font = FONT,
            TextSize = TS,
        }, prList)
        return
    end

    for gi, g in ipairs(GROUPS) do
        local header = addHeader(g[1], gi * 1000)
        local count = 0
        for pi, name in ipairs(g[2]) do
            if pcall(inst.GetPropertyChangedSignal, inst, name) then
                local okRow = addRow(gi * 1000 + pi, g[1], name,
                    function() return inst[name] end,
                    makeSetter(function() return inst[name] end, function(v) inst[name] = v end))
                if okRow then count = count + 1 end
            end
        end
        if count == 0 then
            header.frame:Destroy()
            table.remove(propHeaders)
        end
    end

    local okA, attrs = pcall(inst.GetAttributes, inst)
    if not okA then attrs = {} end
    local keys = {}
    for k in pairs(attrs) do keys[#keys + 1] = k end
    table.sort(keys)
    if #keys > 0 then
        addHeader("Attributes", 9000)
        for i, k in ipairs(keys) do
            addRow(9000 + i, "Attributes", k,
                function() return inst:GetAttribute(k) end,
                makeSetter(function() return inst:GetAttribute(k) end, function(v) inst:SetAttribute(k, v) end))
        end
    end
    applyPropVisibility()
end

setSelected = function(inst)
    if inst and selected and inst ~= selected and not navigating then
        selHistory[#selHistory + 1] = selected
        if #selHistory > 40 then table.remove(selHistory, 1) end
    end
    selected = inst
    if propsConn then propsConn:Disconnect() propsConn = nil end
    if inst then
        local okC, conn = pcall(function()
            return inst.Changed:Connect(function() propsDirty = true end)
        end)
        propsConn = okC and conn or nil
    end
    if hl then
        local ok = inst and inst ~= game and inst.Parent ~= game
            and not inst:IsA("Terrain") and not inst:IsA("WorldRoot")
            and (inst:IsA("BasePart") or inst:IsA("Model"))
        pcall(function() hl.Adornee = ok and inst or nil end)
    end
    pcall(buildProps)
    renderExplorer()
end

local actBar = new("ScrollingFrame", {
    Position = UDim2.new(0, 4, 1, -ACT_H),
    Size = UDim2.new(1, -8, 0, ACT_H),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 0,
    AutomaticCanvasSize = Enum.AutomaticSize.X,
    CanvasSize = UDim2.new(),
    ScrollingDirection = Enum.ScrollingDirection.X,
}, explorerPanel)
new("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0, 4),
    VerticalAlignment = Enum.VerticalAlignment.Center,
}, actBar)

local function actButton(text, fn)
    local b = new("TextButton", {
        Text = text,
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 1, -6),
        BackgroundColor3 = C.btn,
        TextColor3 = C.text,
        Font = FONT,
        TextSize = TS,
        BorderSizePixel = 0,
    }, actBar)
    corner(b, 3)
    new("UIPadding", { PaddingLeft = UDim.new(0, 11), PaddingRight = UDim.new(0, 11) }, b)
    track(b.Activated:Connect(fn))
    return b
end

local function need()
    if not selected then toast("Select an object first") return false end
    return true
end

local clipboard = {}

local function safeClone(inst)
    local flipped = {}
    pcall(function()
        if inst.Archivable == false then
            inst.Archivable = true
            flipped[#flipped + 1] = inst
        end
        for _, d in ipairs(inst:GetDescendants()) do
            if d.Archivable == false then
                d.Archivable = true
                flipped[#flipped + 1] = d
            end
        end
    end)
    local ok, cl = pcall(inst.Clone, inst)
    for _, f in ipairs(flipped) do
        pcall(function() f.Archivable = false end)
    end
    if ok and cl then return cl end
    return nil
end

local function actionTargets(inst, noServices)
    local list = {}
    if multi[inst] then
        for i in pairs(multi) do
            if typeof(i) == "Instance" and i.Parent ~= nil and i ~= game and not (noServices and i.Parent == game) then
                list[#list + 1] = i
            end
        end
    elseif inst ~= game and not (noServices and inst.Parent == game) then
        list[1] = inst
    end
    return list
end

local function copyToClipboard(list, cut)
    local snap = {}
    for _, i in ipairs(list) do
        local cl = safeClone(i)
        if cl then
            snap[#snap + 1] = cl
            if cut then pcall(function() i:Destroy() end) end
        end
    end
    if #snap == 0 then
        toast(cut and "Cut failed" or "Copy failed")
        return
    end
    for _, old in ipairs(clipboard) do pcall(function() old:Destroy() end) end
    clipboard = snap
    toast((cut and "Cut: " or "Copied: ") .. #snap)
    if cut then
        table.clear(multi)
        setSelected(nil)
        rebuild()
    end
end

local function pasteClipboard(inst)
    if #clipboard == 0 then toast("Clipboard is empty") return end
    local targets = multi[inst] and actionTargets(inst, false) or { inst }
    local pasted = {}
    for _, t in ipairs(targets) do
        for _, item in ipairs(clipboard) do
            local cl = safeClone(item)
            if cl then
                local ok = pcall(function() cl.Parent = t end)
                if ok and cl.Parent == t then
                    pasted[#pasted + 1] = cl
                else
                    pcall(function() cl:Destroy() end)
                end
            end
        end
    end
    if #pasted == 0 then toast("Paste failed") return end
    toast("Pasted: " .. #pasted)
    table.clear(multi)
    if #pasted > 1 then
        for _, c in ipairs(pasted) do multi[c] = true end
    end
    setSelected(pasted[1])
    reveal(pasted[1])
end

actButton("Copy Path", function()
    if need() then copy(getPath(selected), "Path") end
end)

actButton("Clone", function()
    if not need() then return end
    local ok, c = pcall(function()
        local clone = safeClone(selected)
        clone.Parent = selected.Parent
        return clone
    end)
    if ok and c then
        toast("Cloned")
        setSelected(c)
        reveal(c)
    else
        toast("Clone failed")
    end
end)

local function deleteWithUndo(inst)
    local par = inst.Parent
    local snap = safeClone(inst)
    local ok = pcall(function() inst:Destroy() end)
    if ok and snap and par then
        pushUndo("Delete " .. inst.Name, function()
            local c = safeClone(snap)
            c.Parent = par
        end)
    end
    return ok
end

local function doUndo()
    local item = table.remove(undoStack)
    if not item then toast("Nothing to undo") return end
    local ok = pcall(item.fn)
    toast(ok and ("Undone: " .. item.label) or "Undo failed")
    propsDirty = true
    rebuild()
end

local function goBack()
    while #selHistory > 0 do
        local target = table.remove(selHistory)
        if typeof(target) == "Instance" and target.Parent ~= nil then
            navigating = true
            setSelected(target)
            reveal(target)
            navigating = false
            return
        end
    end
    toast("No previous selection")
end

actButton("Back", goBack)
actButton("Undo", doUndo)

actButton("Copy", function()
    if not need() then return end
    copyToClipboard(actionTargets(selected, false), false)
end)

actButton("Paste", function()
    if not need() then return end
    pasteClipboard(selected)
end)

actButton("Delete", function()
    if not need() then return end
    local inst = selected
    local ok = deleteWithUndo(inst)
    if ok then toast("Deleted " .. inst.Name) setSelected(nil) rebuild() else toast("Delete failed") end
end)

actButton("Teleport", function()
    if not need() then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then toast("Character not found") return end
    local cf
    if selected:IsA("BasePart") then
        cf = selected.CFrame
    elseif selected:IsA("Model") then
        cf = selected:GetPivot()
    elseif selected:IsA("Attachment") then
        cf = selected.WorldCFrame
    end
    if not cf then toast("This object has no position") return end
    hrp.CFrame = cf + Vector3.new(0, 5, 0)
    toast("Teleported")
end)

local viewing = false
local viewBtn
viewBtn = actButton("View", function()
    local cam = workspace.CurrentCamera
    if viewing then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then cam.CameraSubject = hum end
        viewing = false
        viewBtn.Text = "View"
        return
    end
    if not need() then return end
    local inst, subject = selected, nil
    if inst:IsA("Humanoid") or inst:IsA("BasePart") then
        subject = inst
    elseif inst:IsA("Player") and inst.Character then
        subject = inst.Character:FindFirstChildOfClass("Humanoid")
    elseif inst:IsA("Model") then
        subject = inst:FindFirstChildOfClass("Humanoid") or inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart", true)
    end
    if not subject then toast("View failed") return end
    cam.CameraSubject = subject
    viewing = true
    viewBtn.Text = "Unview"
end)

actButton("Decompile", function()
    if not need() then return end
    if not selected:IsA("LuaSourceContainer") then toast("Select a Script / ModuleScript") return end
    if not decompileFn then toast("Executor does not support decompile") return end
    local inst = selected
    toast("Decompiling...")
    task.spawn(function()
        local ok, src = pcall(decompileFn, inst)
        if ok and type(src) == "string" then
            showText(inst.Name .. ".lua", src)
        else
            toast("Decompile failed")
        end
    end)
end)

track(UIS.InputBegan:Connect(function(input, gp)
    if gp or not clickSelect then return end
    if isPointer(input.UserInputType) then
        task.defer(function()
            local t = Mouse.Target
            if t and alive then
                setSelected(t)
                reveal(t)
            end
        end)
    end
end))

local function saveInstanceOf(inst)
    local wf = env.writefile
    local sv = env.saveinstance or env.save_instance
    if inst and inst:IsA("LuaSourceContainer") and wf and decompileFn then
        task.spawn(function()
            local ok, src = pcall(decompileFn, inst)
            if ok and type(src) == "string" then
                local fname = (inst.Name:gsub("[^%w_%-]", "_")) .. ".lua"
                local ok2 = pcall(wf, fname, src)
                toast(ok2 and ("Saved: " .. fname) or "Save failed")
            else
                toast("Decompile failed")
            end
        end)
    elseif sv then
        task.spawn(function()
            local ok
            if inst then
                local fname = (inst.Name:gsub("[^%w_%-]", "_"))
                ok = pcall(sv, { Object = inst, FileName = fname })
                toast(ok and ("saveinstance: " .. fname) or "saveinstance failed")
            else
                toast("Saving the whole game...")
                ok = pcall(sv)
                toast(ok and "saveinstance done" or "saveinstance failed")
            end
        end)
    else
        toast("Executor does not support Save")
    end
end

do
local MENU_ICONS = {}
do
    local GREEN = Color3.fromRGB(80, 200, 110)
    local RED = Color3.fromRGB(235, 70, 70)
    local LB = Color3.fromRGB(150, 185, 245)
    local SB = Color3.fromRGB(80, 140, 235)
    local LG = Color3.fromRGB(215, 220, 230)
    MENU_ICONS.cut = function(p)
        fr(p, 5, 0, 2, 10, LG, 0.4).Rotation = 22
        fr(p, 8.5, 0, 2, 10, LG, 0.4).Rotation = -22
        ringShape(p, 0.5, 9.5, 5.5, 5.5, RED, 1.5)
        ringShape(p, 9.5, 9.5, 5.5, 5.5, RED, 1.5)
    end
    MENU_ICONS.copy = function(p)
        fr(p, 0.5, 0, 9, 12, LB, 0.12)
        fr(p, 6, 4, 9.5, 12, SB, 0.12)
        fr(p, 8, 7, 5.5, 1.5, WHITE, 0.5)
        fr(p, 8, 10, 5.5, 1.5, WHITE, 0.5)
    end
    MENU_ICONS.paste = function(p)
        fr(p, 1.5, 1.5, 13, 14, Color3.fromRGB(150, 150, 150), 0.15)
        fr(p, 4.5, 0, 7, 3.5, Color3.fromRGB(95, 95, 95), 0.3)
        fr(p, 3.5, 4.5, 9, 10, Color3.fromRGB(236, 239, 246), 0.1)
        fr(p, 5, 7, 6, 1.4, Color3.fromRGB(150, 156, 170), 0.5)
        fr(p, 5, 10, 6, 1.4, Color3.fromRGB(150, 156, 170), 0.5)
    end
    MENU_ICONS.del = function(p)
        fr(p, 6.8, -1, 2.4, 18, RED, 0.3).Rotation = 45
        fr(p, 6.8, -1, 2.4, 18, RED, 0.3).Rotation = -45
    end
    MENU_ICONS.rename = function(p)
        fr(p, 6.5, 0, 3.5, 13, Color3.fromRGB(245, 200, 70), 0.2).Rotation = 45
        fr(p, 0.5, 11.5, 4, 4, Color3.fromRGB(240, 215, 175), 0.3)
        fr(p, 11.5, 0.5, 3.5, 3.5, Color3.fromRGB(235, 130, 130), 0.3)
    end
    MENU_ICONS.group = function(p)
        ringShape(p, 0.5, 0.5, 10, 10, SB, 1.5)
        fr(p, 5.5, 5.5, 10, 10, SB, 0.12)
        fr(p, 8, 8, 5, 5, LB, 0.1)
    end
    MENU_ICONS.ungroup = function(p)
        ringShape(p, 0.5, 0.5, 7, 7, SB, 1.5)
        ringShape(p, 8.5, 8.5, 7, 7, LB, 1.5)
        fr(p, 6, 6, 4, 4, SB, 0.2)
    end
    MENU_ICONS.jump = function(p)
        fr(p, 0.5, 2, 15, 1.6, LG, 0.5)
        fr(p, 4, 7, 11.5, 1.6, LG, 0.5)
        fr(p, 4, 12, 11.5, 1.6, LG, 0.5)
        fr(p, 0.5, 5.5, 3, 3, SB, 0.5)
    end
    MENU_ICONS.path = function(p)
        fr(p, 3, 3, 10, 10, SB, 0.15).Rotation = 45
        fr(p, 6, 6, 4, 4, WHITE, 0.5)
    end
    MENU_ICONS.plus = function(p)
        fr(p, 6.3, 0.5, 3.4, 15, GREEN, 0.25)
        fr(p, 0.5, 6.3, 15, 3.4, GREEN, 0.25)
    end
    MENU_ICONS.save = function(p)
        fr(p, 0.5, 10.5, 15, 5, LG, 0.2)
        fr(p, 6.3, 0, 3.4, 8, GREEN, 0.2)
        fr(p, 4.5, 5, 7, 7, GREEN, 0.12).Rotation = 45
        fr(p, 2.5, 12.4, 2, 1.4, Color3.fromRGB(110, 114, 126), 0.5)
    end
    MENU_ICONS.api = function(p)
        fr(p, 0.5, 0.5, 15, 15, WHITE, 0.5)
        new("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "?",
            Font = FONTB, TextScaled = true, TextColor3 = Color3.fromRGB(40, 40, 46),
        }, p)
    end
    MENU_ICONS.tele = function(p)
        fr(p, 0, 6, 10, 4, GREEN, 0.3)
        fr(p, 7, 3, 8, 8, GREEN, 0.12).Rotation = 45
        fr(p, 4.5, 5.2, 4, 5.6, Color3.fromRGB(32, 32, 32)).BackgroundTransparency = 1
    end
    MENU_ICONS.view = function(p)
        fr(p, 0.5, 3, 15, 10, SB, 0.4)
        fr(p, 5, 5, 6, 6, WHITE, 0.5)
        fr(p, 6.8, 6.8, 2.6, 2.6, Color3.fromRGB(40, 40, 46), 0.5)
    end
    MENU_ICONS.char = function(p)
        ringShape(p, 1, 1, 14, 14, Color3.fromRGB(170, 175, 185), 1.5)
        fr(p, 5.5, 3.5, 5, 5, Color3.fromRGB(170, 175, 185), 0.5)
        fr(p, 4, 9, 8, 4, Color3.fromRGB(170, 175, 185), 0.4)
    end
end

local function menuIcon(parent, kind)
    local d = MENU_ICONS[kind] or DRAW[kind]
    if d then d(parent) end
end

local ctxOpenT = 0
local ctxH = 0
local MROW = IS_MOBILE and 32 or 24
local MWID = IS_MOBILE and math.clamp(vp.X * 0.30, 220, 300) or 250

local ctxOverlay = new("TextButton", {
    Text = "", AutoButtonColor = false, Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1, Visible = false, ZIndex = 48,
}, gui)
local ctxFrame = new("Frame", {
    Size = UDim2.new(0, MWID, 0, 100), BackgroundColor3 = Color3.fromRGB(32, 32, 32),
    BorderSizePixel = 0, Visible = false, ZIndex = 49, Active = true, ClipsDescendants = true,
}, gui)
corner(ctxFrame, 3)
stroke(ctxFrame, Color3.fromRGB(70, 70, 70))
local ctxList = new("ScrollingFrame", {
    Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
    ScrollBarThickness = IS_MOBILE and 5 or 4, CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 49,
    ScrollingDirection = Enum.ScrollingDirection.Y,
}, ctxFrame)
new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, ctxList)
new("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2) }, ctxList)

local function closeCtx()
    ctxFrame.Visible = false
    ctxOverlay.Visible = false
end
track(ctxOverlay.Activated:Connect(function()
    if os.clock() - ctxOpenT > 0.35 then closeCtx() end
end))

local ctxOrder = 0
local function ctxClear()
    for _, c in ipairs(ctxList:GetChildren()) do
        if c:IsA("GuiObject") then c:Destroy() end
    end
    ctxOrder, ctxH = 0, 4
end
local function ctxSep()
    ctxOrder = ctxOrder + 1
    ctxH = ctxH + 7
    local f = new("Frame", {
        Size = UDim2.new(1, 0, 0, 7), BackgroundTransparency = 1, LayoutOrder = ctxOrder, ZIndex = 49,
    }, ctxList)
    new("Frame", {
        Size = UDim2.new(1, -16, 0, 1), Position = UDim2.new(0, 8, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(70, 70, 70), BorderSizePixel = 0, ZIndex = 49,
    }, f)
end
local function ctxItem(label, icon, enabled, fn, keepOpen)
    ctxOrder = ctxOrder + 1
    ctxH = ctxH + MROW
    local b = new("TextButton", {
        Text = "", AutoButtonColor = false, Size = UDim2.new(1, 0, 0, MROW),
        BackgroundColor3 = Color3.fromRGB(62, 62, 62), BackgroundTransparency = 1,
        BorderSizePixel = 0, LayoutOrder = ctxOrder, ZIndex = 49,
    }, ctxList)
    local isz = MROW - 12
    local ih = new("Frame", {
        Size = UDim2.new(0, isz, 0, isz), Position = UDim2.new(0, 8, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, ZIndex = 49,
    }, b)
    if icon then menuIcon(ih, icon) end
    new("TextLabel", {
        Text = label, Position = UDim2.new(0, isz + 16, 0, 0), Size = UDim2.new(1, -isz - 22, 1, 0),
        BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Font = FONT,
        TextSize = TS, TextColor3 = enabled and C.text or Color3.fromRGB(110, 110, 110),
        TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 49,
    }, b)
    if enabled then
        track(b.MouseEnter:Connect(function() b.BackgroundTransparency = 0 end))
        track(b.MouseLeave:Connect(function() b.BackgroundTransparency = 1 end))
        track(b.Activated:Connect(function()
            if not keepOpen then closeCtx() end
            fn()
        end))
    end
end

local renameTarget
local renameFrame = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 60),
    Size = UDim2.new(0, math.clamp(vp.X * 0.5, 260, 360), 0, 88),
    BackgroundColor3 = C.bg, Visible = false, ZIndex = 70, Active = true,
}, gui)
corner(renameFrame, 6)
stroke(renameFrame, C.accent)
local renameBox = new("TextBox", {
    Text = "", Size = UDim2.new(1, -16, 0, 32), Position = UDim2.new(0, 8, 0, 8),
    BackgroundColor3 = C.input, TextColor3 = C.text, Font = FONT, TextSize = TS + 1,
    ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0, ZIndex = 71,
}, renameFrame)
corner(renameBox, 4)
new("UIPadding", { PaddingLeft = UDim.new(0, 8) }, renameBox)
local function renameBtn(text, xOff, fn)
    local b = new("TextButton", {
        Text = text, Size = UDim2.new(0.5, -12, 0, 32), Position = UDim2.new(xOff, xOff == 0 and 8 or 4, 0, 48),
        BackgroundColor3 = C.btn, TextColor3 = C.text, Font = FONTB, TextSize = TS, BorderSizePixel = 0, ZIndex = 71,
    }, renameFrame)
    corner(b, 4)
    track(b.Activated:Connect(fn))
    return b
end
local function applyRename()
    local t = renameTarget
    renameFrame.Visible = false
    renameTarget = nil
    if t and renameBox.Text ~= "" then
        local ok = pcall(function() t.Name = renameBox.Text end)
        if ok then toast("Renamed") else toast("Rename failed") end
        renderExplorer()
        if selected == t then propsDirty = true end
    end
end
renameBtn("OK", 0, applyRename)
renameBtn("Cancel", 0.5, function() renameFrame.Visible = false renameTarget = nil end)
track(renameBox.FocusLost:Connect(function(enter) if enter then applyRename() end end))

local INSERT_LIST = {
    { "Part", "cube_b" }, { "Model", "model" }, { "Folder", "folder" },
    { "Script", "page_b" }, { "LocalScript", "page_g" }, { "ModuleScript", "page_p" },
    { "RemoteEvent", "remote" }, { "RemoteFunction", "remote" },
    { "BindableEvent", "bindable" }, { "StringValue", "value" }, { "NumberValue", "value" },
    { "BoolValue", "value" }, { "ObjectValue", "value" }, { "Frame", "block_p" },
    { "TextLabel", "block_p" }, { "ScreenGui", "window_p" }, { "PointLight", "bulb" },
    { "Sound", "speaker" }, { "Attachment", "ring" },
}

local function viewObj(inst)
    local cam = workspace.CurrentCamera
    if viewing then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then cam.CameraSubject = hum end
        viewing = false
        viewBtn.Text = "View"
        toast("View: OFF")
        return
    end
    local subject
    if inst:IsA("Humanoid") or inst:IsA("BasePart") then
        subject = inst
    elseif inst:IsA("Player") and inst.Character then
        subject = inst.Character:FindFirstChildOfClass("Humanoid")
    elseif inst:IsA("Model") then
        subject = inst:FindFirstChildOfClass("Humanoid") or inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart", true)
    end
    if not subject then toast("View failed") return end
    cam.CameraSubject = subject
    viewing = true
    viewBtn.Text = "Unview"
    toast("Viewing " .. inst.Name)
end

local function teleportTo(inst)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then toast("Character not found") return end
    local cf
    if inst:IsA("BasePart") then cf = inst.CFrame
    elseif inst:IsA("Model") then cf = inst:GetPivot()
    elseif inst:IsA("Attachment") then cf = inst.WorldCFrame end
    if not cf then toast("This object has no position") return end
    hrp.CFrame = cf + Vector3.new(0, 5, 0)
    toast("Teleported")
end

local buildCtxMain

local function buildCtxInsert(inst)
    ctxClear()
    ctxItem("< Back", nil, true, function() buildCtxMain(inst) end, true)
    ctxSep()
    for _, e in ipairs(INSERT_LIST) do
        ctxItem(e[1], e[2], true, function()
            local ok, o = pcall(function()
                local obj = Instance.new(e[1])
                obj.Parent = inst
                return obj
            end)
            if ok and o then
                setSelected(o)
                reveal(o)
                toast("Inserted " .. e[1])
            else
                toast("Insert failed")
            end
        end)
    end
    ctxFrame.Size = UDim2.new(0, MWID, 0, math.min(ctxH + 4, math.max(160, dockH)))
    ctxList.CanvasPosition = Vector2.zero
end

local function buildCtxBookmarks(inst)
    ctxClear()
    ctxItem("< Back", nil, true, function() buildCtxMain(inst) end, true)
    ctxSep()
    local already = false
    for _, b in ipairs(bookmarks) do if b == inst then already = true end end
    ctxItem(already and "Remove This Bookmark" or "Bookmark This", "plus", inst ~= game, function()
        if already then
            for i2 = #bookmarks, 1, -1 do
                if bookmarks[i2] == inst then table.remove(bookmarks, i2) end
            end
            toast("Bookmark removed")
        elseif #bookmarks >= 30 then
            toast("Bookmark limit reached")
        else
            bookmarks[#bookmarks + 1] = inst
            toast("Bookmarked: " .. inst.Name)
        end
    end)
    for i2 = #bookmarks, 1, -1 do
        if bookmarks[i2].Parent == nil then table.remove(bookmarks, i2) end
    end
    for _, b in ipairs(bookmarks) do
        ctxItem(b.Name .. "  (" .. b.ClassName .. ")", "jump", true, function()
            setSelected(b)
            reveal(b)
        end)
    end
    ctxItem("Clear All Bookmarks", "del", #bookmarks > 0, function()
        table.clear(bookmarks)
        toast("Bookmarks cleared")
    end)
    ctxFrame.Size = UDim2.new(0, MWID, 0, math.min(ctxH + 4, math.max(160, dockH)))
    ctxList.CanvasPosition = Vector2.zero
end

local function multiList()
    local list = {}
    for i in pairs(multi) do
        if typeof(i) == "Instance" and i.Parent ~= nil then
            list[#list + 1] = i
        else
            multi[i] = nil
        end
    end
    return list
end

local function multiCount()
    return #multiList()
end

local function runOnMulti(label, fn)
    local done, failed = 0, 0
    for _, i in ipairs(multiList()) do
        if i.Parent ~= game and pcall(fn, i) then
            done = done + 1
        else
            failed = failed + 1
        end
    end
    toast(label .. ": " .. done .. (failed > 0 and (" (" .. failed .. " failed)") or ""))
    rebuild()
end

local playingAnims = {}

local function myRoot()
    local ch = LocalPlayer.Character
    return ch and (ch:FindFirstChild("HumanoidRootPart") or ch.PrimaryPart)
end

local function playAnimation(anim)
    local ch = LocalPlayer.Character
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    if not hum then toast("Character not found") return end
    local old = playingAnims[anim]
    if old then pcall(function() old:Stop() end) end
    local ok, track_ = pcall(function()
        local loader = hum:FindFirstChildOfClass("Animator") or hum
        local t = loader:LoadAnimation(anim)
        t:Play()
        return t
    end)
    if ok and track_ then
        playingAnims[anim] = track_
        toast("Playing: " .. anim.Name)
    else
        toast("Play failed")
    end
end

local function stopAnimation(anim)
    local t = playingAnims[anim]
    playingAnims[anim] = nil
    if t then pcall(function() t:Stop() end) toast("Stopped") else toast("Not playing") end
end

local function fireTarget(inst)
    local ok = false
    if inst:IsA("ClickDetector") then
        ok = env.fireclickdetector ~= nil and pcall(env.fireclickdetector, inst)
    elseif inst:IsA("ProximityPrompt") then
        ok = env.fireproximityprompt ~= nil and pcall(env.fireproximityprompt, inst)
    elseif inst:IsA("TouchTransmitter") then
        local root, part = myRoot(), inst.Parent
        if env.firetouchinterest and root and part and part:IsA("BasePart") then
            ok = pcall(function()
                env.firetouchinterest(root, part, 0)
                task.wait()
                env.firetouchinterest(root, part, 1)
            end)
        end
    end
    toast(ok and ("Fired " .. inst.ClassName) or ("Fire failed: " .. inst.ClassName))
end

buildCtxMain = function(inst)
    ctxClear()
    local isGame = (inst == game)
    local isSvc = (inst.Parent == game)
    local canMod = (not isGame) and (not isSvc)
    local hasKids = #kids(inst) > 0

    local mc = multiCount()
    ctxItem(multi[inst] and "Remove from Selection" or "Add to Selection", "plus", not isGame, function()
        multi[inst] = (not multi[inst]) or nil
        renderExplorer()
        toast("Selected: " .. multiCount())
    end)
    ctxItem("Select Children", nil, hasKids, function()
        local n = 0
        for _, k in ipairs(kids(inst)) do
            multi[k] = true
            n = n + 1
        end
        renderExplorer()
        toast("Selected: " .. multiCount())
    end)
    if mc > 0 then
        ctxItem("Delete Selected (" .. mc .. ")", "del", true, function()
            runOnMulti("Deleted", function(i) assert(deleteWithUndo(i)) end)
            for k in pairs(multi) do multi[k] = nil end
            setSelected(nil)
        end)
        ctxItem("Duplicate Selected (" .. mc .. ")", "copy", true, function()
            runOnMulti("Duplicated", function(i)
                local cl = safeClone(i)
                cl.Parent = i.Parent
            end)
        end)
        ctxItem("Group Selected (" .. mc .. ")", "group", true, function()
            local list = multiList()
            local ok = pcall(function()
                local model = Instance.new("Model")
                model.Name = "Model"
                model.Parent = list[1].Parent
                for _, i in ipairs(list) do
                    if i.Parent ~= game then i.Parent = model end
                end
            end)
            for k in pairs(multi) do multi[k] = nil end
            toast(ok and "Grouped" or "Group failed")
            rebuild()
        end)
        ctxItem("Copy Paths (" .. mc .. ")", "path", true, function()
            local lines = {}
            for _, i in ipairs(multiList()) do lines[#lines + 1] = getPath(i) end
            copy(table.concat(lines, "\n"), "Paths")
        end)
        ctxItem("Clear Selection", nil, true, function()
            for k in pairs(multi) do multi[k] = nil end
            renderExplorer()
        end)
    end
    ctxSep()
    ctxItem("Cut", "cut", canMod, function()
        copyToClipboard(actionTargets(inst, true), true)
    end)
    ctxItem("Copy", "copy", not isGame, function()
        copyToClipboard(actionTargets(inst, false), false)
    end)
    ctxItem("Paste Into", "paste", #clipboard > 0, function()
        pasteClipboard(inst)
    end)
    ctxItem("Duplicate", "copy", canMod, function()
        local ok, c = pcall(function()
            local cl = safeClone(inst)
            cl.Parent = inst.Parent
            return cl
        end)
        if ok and c then toast("Duplicated") setSelected(c) reveal(c) else toast("Duplicate failed") end
    end)
    ctxItem("Delete", "del", canMod, function()
        local ok = deleteWithUndo(inst)
        if ok then toast("Deleted " .. inst.Name) setSelected(nil) rebuild() else toast("Delete failed") end
    end)
    ctxItem("Delete Children", "del", hasKids and not isGame, function()
        local ok = pcall(function() inst:ClearAllChildren() end)
        if ok then toast("Deleted children") rebuild() else toast("Delete failed") end
    end)
    ctxItem("Rename", "rename", not isGame, function()
        renameTarget = inst
        renameBox.Text = inst.Name
        renameFrame.Visible = true
    end)
    ctxSep()
    ctxItem("Group", "group", canMod, function()
        local ok, m = pcall(function()
            local model = Instance.new("Model")
            model.Name = "Model"
            model.Parent = inst.Parent
            inst.Parent = model
            return model
        end)
        if ok and m then setSelected(m) reveal(m) toast("Grouped") else toast("Group failed") end
    end)
    ctxItem("Ungroup", "ungroup", canMod and (inst:IsA("Model") or inst:IsA("Folder")) and hasKids, function()
        local p = inst.Parent
        local ok = pcall(function()
            for _, k in ipairs(inst:GetChildren()) do k.Parent = p end
            inst:Destroy()
        end)
        if ok then toast("Ungrouped") setSelected(nil) rebuild() else toast("Ungroup failed") end
    end)
    ctxItem("Jump to Parent", "jump", inst.Parent ~= nil, function()
        setSelected(inst.Parent)
        reveal(inst.Parent)
    end)
    ctxItem("Expand All", nil, hasKids, function()
        local n = 0
        local function walk(i)
            for _, k in ipairs(i:GetChildren()) do
                n = n + 1
                if n > 4000 then return end
                if #k:GetChildren() > 0 then
                    expanded[k] = true
                    walk(k)
                end
            end
        end
        expanded[inst] = true
        walk(inst)
        rebuild()
    end)
    ctxItem("Collapse All", nil, hasKids, function()
        local n = 0
        for _, d in ipairs(inst:GetDescendants()) do
            n = n + 1
            if n > 8000 then break end
            expanded[d] = nil
        end
        if inst ~= game then expanded[inst] = nil end
        rebuild()
    end)
    ctxSep()
    ctxItem("Copy Path", "path", true, function() copy(getPath(inst), "Path") end)
    ctxItem("Insert Object", "plus", true, function() buildCtxInsert(inst) end, true)
    ctxItem("Bookmarks", "jump", true, function() buildCtxBookmarks(inst) end, true)
    ctxItem("Save to File", "save", not isGame, function() saveInstanceOf(inst) end)
    ctxItem("Copy Roblox API Page URL", "api", true, function()
        copy("https://create.roblox.com/docs/reference/engine/classes/" .. inst.ClassName, "API URL")
    end)
    ctxSep()
    local hasPos = inst:IsA("BasePart") or inst:IsA("Model") or inst:IsA("Attachment")
    ctxItem("Teleport To", "tele", hasPos, function() teleportTo(inst) end)
    ctxItem(viewing and "Unview Object" or "View Object", "view",
        viewing or inst:IsA("BasePart") or inst:IsA("Model") or inst:IsA("Humanoid") or inst:IsA("Player"),
        function() viewObj(inst) end)
    if inst:IsA("Player") then
        ctxItem("Select Character", "char", inst.Character ~= nil, function()
            if inst.Character then setSelected(inst.Character) reveal(inst.Character) end
        end)
    end
    ctxItem("Refresh", nil, true, function() rebuild() end)
    ctxItem("Find Same Class", nil, not isGame, function()
        exSearch.Text = "class:" .. inst.ClassName
    end)
    ctxItem("Dump Properties", nil, not isGame, function()
        local lines = { inst.Name .. "  (" .. inst.ClassName .. ")", getPath(inst), "" }
        for _, g in ipairs(GROUPS) do
            for _, name in ipairs(g[2]) do
                local ok, v = pcall(function() return inst[name] end)
                if ok and v ~= nil and name ~= "Parent" then
                    lines[#lines + 1] = name .. " = " .. fmt(v)
                end
            end
        end
        local okA, attrs = pcall(inst.GetAttributes, inst)
        if okA then
            for k, v in pairs(attrs) do lines[#lines + 1] = "[Attr] " .. k .. " = " .. fmt(v) end
        end
        showText(inst.Name .. " properties", table.concat(lines, "\n"))
    end)
    if inst:IsA("BasePart") then
        ctxItem("Toggle Anchored", nil, true, function()
            local old = inst.Anchored
            inst.Anchored = not old
            pushUndo("Anchored", function() inst.Anchored = old end)
            toast("Anchored: " .. tostring(inst.Anchored))
            propsDirty = true
        end)
        ctxItem("Toggle CanCollide", nil, true, function()
            local old = inst.CanCollide
            inst.CanCollide = not old
            pushUndo("CanCollide", function() inst.CanCollide = old end)
            toast("CanCollide: " .. tostring(inst.CanCollide))
            propsDirty = true
        end)
    end
    if inst:IsA("PVInstance") and not inst:IsA("Workspace") then
        ctxItem("Bring To Me", nil, myRoot() ~= nil, function()
            local root = myRoot()
            if not root then toast("Character not found") return end
            local oldPivot = inst:GetPivot()
            inst:PivotTo(root.CFrame * CFrame.new(0, 0, -6))
            pushUndo("Bring To Me", function() inst:PivotTo(oldPivot) end)
            toast("Brought: " .. inst.Name)
        end)
    end
    if inst.Parent == game and inst.Name == "Players" then
        ctxItem("Select Local Player", "char", LocalPlayer.Parent ~= nil, function()
            setSelected(LocalPlayer)
            reveal(LocalPlayer)
        end)
    end
    if inst:IsA("ClickDetector") then
        ctxItem("Fire ClickDetector", nil, env.fireclickdetector ~= nil, function() fireTarget(inst) end)
    elseif inst:IsA("ProximityPrompt") then
        ctxItem("Fire ProximityPrompt", nil, env.fireproximityprompt ~= nil, function() fireTarget(inst) end)
    elseif inst:IsA("TouchTransmitter") then
        ctxItem("Fire TouchTransmitter", nil, env.firetouchinterest ~= nil, function() fireTarget(inst) end)
    elseif inst:IsA("Animation") then
        ctxItem("Play Animation", nil, true, function() playAnimation(inst) end)
        ctxItem("Stop Animation", nil, playingAnims[inst] ~= nil, function() stopAnimation(inst) end)
    end
    if inst:IsA("LuaSourceContainer") then
        ctxItem("View Script", "page_b", decompileFn ~= nil, function()
            task.spawn(function()
                local ok, src = pcall(decompileFn, inst)
                if ok and type(src) == "string" then showText(inst.Name .. ".lua", src) else toast("Decompile failed") end
            end)
        end)
    end

    ctxFrame.Size = UDim2.new(0, MWID, 0, math.min(ctxH + 4, math.max(160, dockH)))
    ctxList.CanvasPosition = Vector2.zero
end

openContext = function(inst)
    if not alive or not inst then return end
    setSelected(inst)
    buildCtxMain(inst)
    local ap = dock.AbsolutePosition
    local x
    if dockSide == "Right" then
        x = ap.X + dockW - MWID - 4
    else
        x = ap.X + 4
    end
    x = math.clamp(x, 0, math.max(0, vp.X - MWID))
    local y = math.clamp(ap.Y, 0, math.max(0, vp.Y - ctxFrame.Size.Y.Offset))
    ctxFrame.Position = UDim2.fromOffset(x, y)
    ctxOverlay.Visible = true
    ctxFrame.Visible = true
    ctxOpenT = os.clock()
end
end

local tabH = IS_MOBILE and 30 or 26
local MW = IS_MOBILE and math.clamp(vp.X * 0.25, 210, 260) or 260
local MWS = IS_MOBILE and math.clamp(vp.X * 0.34, 290, 340) or 330
local TILE_H = IS_MOBILE and 64 or 66
local BAR_H = IS_MOBILE and 26 or 28
local GAP = 8
local TW = math.floor((MW - 16 - GAP * 2) / 3)
local H_MAIN = 8 + TILE_H * 2 + GAP * 2 + 30 + BAR_H
local H_SET = 8 + 7 * 36 + 8 + BAR_H
local H_INFO = 8 + 214 + 8 + BAR_H

local tab = new("TextButton", {
    Text = "ZeroDex",
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 2),
    Size = UDim2.new(0, IS_MOBILE and 78 or 96, 0, tabH),
    BackgroundColor3 = Color3.fromRGB(40, 40, 40),
    TextColor3 = C.text,
    Font = FONTB,
    TextSize = TS,
    BorderSizePixel = 0,
    ZIndex = 30,
}, gui)
corner(tab, 5)

local menu = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, tabH + 2),
    Size = UDim2.new(0, MW, 0, H_MAIN),
    BackgroundColor3 = Color3.fromRGB(38, 38, 38),
    Visible = false,
    ZIndex = 29,
    Active = true,
}, gui)
stroke(menu, C.line)

local pageMain = new("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, -BAR_H), BackgroundTransparency = 1, BorderSizePixel = 0,
    CanvasSize = UDim2.new(0, 0, 0, 8 + 4 * TILE_H + 3 * GAP + 10),
    ScrollBarThickness = 3, ScrollBarImageColor3 = Color3.fromRGB(90, 90, 90),
    ScrollingDirection = Enum.ScrollingDirection.Y, ClipsDescendants = true,
}, menu)
local pageSet = new("Frame", { Size = UDim2.new(1, 0, 1, -BAR_H), BackgroundTransparency = 1, Visible = false }, menu)
local pageInfo = new("Frame", { Size = UDim2.new(1, 0, 1, -BAR_H), BackgroundTransparency = 1, Visible = false }, menu)

local bar = new("Frame", {
    Size = UDim2.new(1, 0, 0, BAR_H),
    Position = UDim2.new(0, 0, 1, -BAR_H),
    BackgroundColor3 = C.header,
    BorderSizePixel = 0,
}, menu)

local function barButton(text, xOff, fn)
    local b = new("TextButton", {
        Text = text,
        Size = UDim2.new(0, 76, 1, -8),
        Position = UDim2.new(xOff >= 0 and 0 or 1, xOff, 0, 4),
        BackgroundColor3 = C.btn,
        TextColor3 = C.text,
        Font = FONT,
        TextSize = TS,
        BorderSizePixel = 0,
    }, bar)
    corner(b, 4)
    track(b.Activated:Connect(fn))
    return b
end

local currentPage = "main"
local backBtn, setBtn, infoBtn
local function setPage(p)
    currentPage = p
    pageMain.Visible = (p == "main")
    pageSet.Visible = (p == "settings")
    pageInfo.Visible = (p == "info")
    menu.Size = UDim2.new(0, (p == "main") and MW or MWS, 0, (p == "main" and H_MAIN) or (p == "settings" and H_SET) or H_INFO)
    backBtn.Visible = (p ~= "main")
    setBtn.Visible = (p == "main")
    infoBtn.Visible = (p == "main")
end
backBtn = barButton("< Back", 8, function() setPage("main") end)
local function barIcon(xOff, kind, fn)
    local b = new("TextButton", {
        Text = "", Size = UDim2.new(0, BAR_H + 4, 1, 0), Position = UDim2.new(1, xOff, 0, 0),
        BackgroundTransparency = 1,
    }, bar)
    local ih = new("Frame", {
        Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0.5, -8, 0.5, -8), BackgroundTransparency = 1,
    }, b)
    local dark = Color3.fromRGB(45, 45, 45)
    if kind == "gear" then
        for _, r in ipairs({ 0, 45, 90, 135 }) do fr(ih, 6, -0.5, 4, 17, WHITE, 0.15).Rotation = r end
        fr(ih, 2.5, 2.5, 11, 11, WHITE, 0.5)
        fr(ih, 6, 6, 4, 4, dark, 0.5)
    else
        fr(ih, 0.5, 0.5, 15, 15, WHITE, 0.5)
        fr(ih, 7, 3, 2, 2, dark, 0.5)
        fr(ih, 7, 6.5, 2, 6.5, dark, 0.2)
    end
    track(b.Activated:Connect(fn))
    return b
end
setBtn = barIcon(-(BAR_H + 4) * 2 - 6, "gear", function() setPage("settings") end)
infoBtn = barIcon(-(BAR_H + 4) - 6, "info", function() setPage("info") end)

local function setMenuOpen(v)
    menu.Visible = v
    tab.Text = v and "Close" or "ZeroDex"
    if v then setPage("main") end
end
track(tab.Activated:Connect(function() setMenuOpen(not menu.Visible) end))

local GRAY = Color3.fromRGB(205, 210, 220)
local BLUE = Color3.fromRGB(80, 150, 240)
local function drawIcon(parent, kind)
    local holder = new("Frame", {
        Size = UDim2.new(0, 27, 0, 27), Position = UDim2.new(0.5, -13, 0, 4),
        BackgroundTransparency = 1,
    }, parent)
    if kind == "tree" then
        fr(holder, 1, 1, 4, 4, Color3.fromRGB(110, 215, 130), 0.2); fr(holder, 7, 2, 8, 2, GRAY, 0.5)
        fr(holder, 4, 6, 4, 4, BLUE, 0.2); fr(holder, 10, 7, 5, 2, GRAY, 0.5)
        fr(holder, 4, 11, 4, 4, BLUE, 0.2); fr(holder, 10, 12, 5, 2, GRAY, 0.5)
        fr(holder, 2.5, 5, 1, 9, GRAY)
        fr(holder, 2.5, 8, 1.5, 1, GRAY); fr(holder, 2.5, 13, 1.5, 1, GRAY)
    elseif kind == "props" then
        for i = 0, 2 do
            fr(holder, 1, 4 + i * 4.5, 2.5, 2.5, BLUE, 0.5)
            fr(holder, 5, 4.4 + i * 4.5, 9, 1.8, GRAY, 0.5)
        end
        fr(holder, 9, 0, 7, 7, BLUE, 0.5)
        fr(holder, 12, 1.6, 1, 1, WHITE, 0.5)
        fr(holder, 12, 3, 1, 2.6, WHITE, 0.2)
    elseif kind == "select" then
        DRAW.__cube(Color3.fromRGB(175, 182, 195))(subArea(holder, 0, 1, 12, 12))
        local cur = fr(holder, 9.5, 8, 5, 5, WHITE, 0.15)
        cur.Rotation = 20
        fr(holder, 11.5, 11.5, 1.8, 4.5, WHITE, 0.4).Rotation = -25
    elseif kind == "refresh" then
        ringShape(holder, 2, 3, 12, 12, BLUE, 2)
        local notch = fr(holder, 9, 1.5, 6, 5, Color3.fromRGB(50, 50, 50))
        local head = fr(holder, 9.2, 1, 5, 5, BLUE, 0.12)
        head.Rotation = 45
    elseif kind == "collapse" then
        local cy = Color3.fromRGB(100, 215, 235)
        fr(holder, 1, 3, 14, 2.4, cy, 0.5)
        fr(holder, 4, 7, 11, 2.4, tone(cy, -0.1), 0.5)
        fr(holder, 7, 11, 8, 2.4, tone(cy, -0.2), 0.5)
    elseif kind == "unload" then
        fr(holder, 1, 1, 14, 14, Color3.fromRGB(225, 85, 85), 0.5)
        fr(holder, 7, 3.5, 2, 9, WHITE, 0.3).Rotation = 45
        fr(holder, 7, 3.5, 2, 9, WHITE, 0.3).Rotation = -45
    elseif kind == "notepad" then
        fr(holder, 3.5, 1, 9.5, 14, Color3.fromRGB(80, 140, 235), 0.15).Rotation = 12
        fr(holder, 1.5, 0, 11, 3.5, Color3.fromRGB(150, 190, 250), 0.5).Rotation = 12
        fr(holder, 4, 12.5, 11, 3.5, Color3.fromRGB(60, 110, 205), 0.5).Rotation = 12
    elseif kind == "console" then
        fr(holder, 0.5, 1, 15, 14, Color3.fromRGB(236, 239, 246), 0.08)
        fr(holder, 0.5, 1, 15, 3, Color3.fromRGB(80, 140, 235), 0.2)
        fr(holder, 3, 6, 1.6, 4, Color3.fromRGB(40, 44, 54), 0.3).Rotation = -45
        fr(holder, 3, 8.5, 1.6, 4, Color3.fromRGB(40, 44, 54), 0.3).Rotation = 45
        fr(holder, 8, 11.5, 5, 1.6, Color3.fromRGB(40, 44, 54), 0.3)
    elseif kind == "savebook" then
        fr(holder, 1, 2, 14, 12, Color3.fromRGB(205, 70, 80), 0.12)
        fr(holder, 1, 2, 14, 3.5, Color3.fromRGB(238, 125, 135), 0.12)
        fr(holder, 3, 13, 11, 2.5, Color3.fromRGB(236, 230, 230), 0.3)
        fr(holder, 5, 7, 6, 3, Color3.fromRGB(240, 235, 235), 0.2)
    elseif kind == "scan" then
        local cy = Color3.fromRGB(0, 224, 255)
        fr(holder, 1, 4, 14, 10, Color3.fromRGB(225, 232, 245), 0.15)
        fr(holder, 4.5, 2, 7, 3, Color3.fromRGB(190, 200, 220), 0.3)
        fr(holder, 4.5, 6, 7, 7, Color3.fromRGB(40, 44, 54), 0.5)
        fr(holder, 6, 7.5, 4, 4, cy, 0.5)
        fr(holder, 11.5, 5.2, 2, 1.4, cy, 0.4)
    elseif kind == "gscan" then
        local cy = Color3.fromRGB(0, 224, 255)
        fr(holder, 1, 2, 14, 12, Color3.fromRGB(225, 232, 245), 0.12)
        fr(holder, 1, 2, 14, 3, Color3.fromRGB(170, 120, 255), 0.12)
        fr(holder, 2.5, 6.5, 4.5, 3, Color3.fromRGB(40, 44, 54), 0.25)
        fr(holder, 2.5, 10.5, 10, 2, Color3.fromRGB(40, 44, 54), 0.3)
        local rg = fr(holder, 8, 5.8, 6, 4.2, BLACK)
        rg.BackgroundTransparency = 1
        new("UIStroke", { Color = cy, Thickness = 1.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, rg)
    else
        DRAW.__block(GRAY)(holder)
    end
end

local notepadText = ""
local consoleBuf = {}
pcall(function()
    local LogService = game:GetService("LogService")
    local hist = LogService:GetLogHistory()
    for i = math.max(1, #hist - 120), #hist do consoleBuf[#consoleBuf + 1] = tostring(hist[i].message) end
    track(LogService.MessageOut:Connect(function(msg, mtype)
        local tag = ""
        if mtype == Enum.MessageType.MessageError then tag = "[ERR] "
        elseif mtype == Enum.MessageType.MessageWarning then tag = "[WARN] " end
        consoleBuf[#consoleBuf + 1] = tag .. tostring(msg)
        if #consoleBuf > 300 then table.remove(consoleBuf, 1) end
        if popup.Visible and popupTitle.Text == "Console" then
            popupBox.Text = table.concat(consoleBuf, "\n")
            popupFull = popupBox.Text
        end
    end))
end)
track(popupBox:GetPropertyChangedSignal("Text"):Connect(function()
    if popup.Visible and popupTitle.Text == "Notepad" then
        notepadText = popupBox.Text
        popupFull = notepadText
    end
end))

local tiles = {}
local function tile(col, row, label, icon, fn)
    local b = new("TextButton", {
        Text = "",
        Position = UDim2.new(0, 8 + col * (TW + GAP), 0, 8 + row * (TILE_H + GAP)),
        Size = UDim2.new(0, TW, 0, TILE_H),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        BorderSizePixel = 0,
    }, pageMain)
    drawIcon(b, icon)
    new("TextLabel", {
        Text = label,
        Position = UDim2.new(0, 2, 0, 33),
        Size = UDim2.new(1, -4, 1, -34),
        BackgroundTransparency = 1,
        TextColor3 = C.text,
        Font = FONT,
        TextSize = TS - 2,
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
    }, b)
    local ul = new("Frame", {
        Size = UDim2.new(1, 0, 0, 3), Position = UDim2.new(0, 0, 1, -3),
        BackgroundColor3 = C.accent, BorderSizePixel = 0, Visible = false,
    }, b)
    track(b.Activated:Connect(function() fn() updateTiles() end))
    tiles[#tiles + 1] = { ul = ul }
    return ul
end

local ulExplorer, ulProps, ulClick

ulExplorer = tile(0, 0, "Explorer", "tree", function() explorerOn = not explorerOn layoutDock() end)
ulProps = tile(1, 0, "Properties", "props", function() propsOn = not propsOn layoutDock() end)
ulClick = tile(2, 0, "Click part to select", "select", function()
    clickSelect = not clickSelect
    toast("Click Select: " .. (clickSelect and "ON" or "OFF"))
end)
tile(0, 1, "Notepad", "notepad", function() showText("Notepad", notepadText) end)
tile(1, 1, "Console", "console", function() showText("Console", table.concat(consoleBuf, "\n")) end)
tile(2, 1, "Save Instance", "savebook", function() saveInstanceOf(selected) end)
tile(0, 2, "Refresh", "refresh", function() rebuild() buildProps() toast("Refreshed") end)
tile(1, 2, "Collapse All", "collapse", function()
    table.clear(expanded)
    expanded[game] = true
    exList.CanvasPosition = Vector2.zero
    rebuild()
end)
tile(2, 2, "Unload", "unload", function()
    if viewing then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then workspace.CurrentCamera.CameraSubject = hum end
    end
    cleanup()
end)

updateTiles = function()
    ulExplorer.Visible = explorerOn
    ulProps.Visible = propsOn
    ulClick.Visible = clickSelect
end

-- ====================================================================
--  SCAN CAMERA  (top button "Scan" + tile)
--  first-person viewfinder -> aim -> shutter -> jump to it in Explorer
--  (wrapped in xpcall: adds no top-level locals, can never break Dex)
-- ====================================================================
xpcall(function()
    local RunService = game:GetService("RunService")

    local CY = Color3.fromRGB(0, 224, 255)
    local GR = Color3.fromRGB(70, 255, 150)
    local AM = Color3.fromRGB(255, 196, 70)
    local INK = Color3.fromRGB(6, 12, 18)
    local HUDF = Enum.Font.Code
    local BOLDF = Enum.Font.GothamBold

    local S = {
        active = false,   -- viewfinder is live
        mode = "live",    -- "live" (aim + pick) or "snap" (photo, then detailed scan)
        frozen = nil,     -- camera freeze (photo) info
        lock = false,     -- start / stop transition running
        busy = false,     -- capture animation running
        skipClear = false,
        conns = {},
        tweens = {},
        saved = nil,
        prev = nil,
        target = nil,
        chain = {},
        idx = 1,
        sticky = nil,
        dist = 0,
        boxInit = false,
        cardInit = false,
        bp = Vector2.new(0, 0),
        bs = Vector2.new(0, 0),
        cardP = Vector2.new(0, 0),
        typeT0 = 0,
        typing = false,
        locked = false,
        acc = 0,
        warned = false,
        cache = { inst = nil, t = 0, cf = nil, size = nil },
    }
    local U = {}
    local N = {            -- SNAP mode state
        phase = "idle",    -- idle | scanning | results
        token = 0,
        all = {}, parts = {}, models = {}, modelOf = {}, view = {},
        counts = {},
        sel = nil,
        filter = "ALL",
        fillTok = 0,
        nBoxes = 0, nMBoxes = 0,
    }
    local startScan, stopScan, capture, setMode, snapCapture, snapReset

    ----------------------------------------------------------------
    -- small helpers
    ----------------------------------------------------------------
    local function circle(o)
        return new("UICorner", { CornerRadius = UDim.new(0.5, 0) }, o)
    end

    local function loopTween(inst, secs, props)
        local tw = TweenService:Create(inst,
            TweenInfo.new(secs, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), props)
        S.tweens[#S.tweens + 1] = tw
        tw:Play()
        return tw
    end

    local function brackets(parent, len, thick, color)
        local list = {}
        local corners = { { 0, 0 }, { 1, 0 }, { 0, 1 }, { 1, 1 } }
        for _, a in ipairs(corners) do
            for k = 1, 2 do
                list[#list + 1] = new("Frame", {
                    AnchorPoint = Vector2.new(a[1], a[2]),
                    Position = UDim2.new(a[1], 0, a[2], 0),
                    Size = (k == 1) and UDim2.new(0, len, 0, thick) or UDim2.new(0, thick, 0, len),
                    BackgroundColor3 = color,
                    BorderSizePixel = 0,
                }, parent)
            end
        end
        return list
    end

    local function tint(list, color)
        for _, f in ipairs(list) do f.BackgroundColor3 = color end
    end

    local function label(parent, text, size, font, color, extra)
        local l = new("TextLabel", {
            Text = text,
            TextSize = size,
            Font = font,
            TextColor3 = color,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, parent)
        if extra then
            for k, v in pairs(extra) do l[k] = v end
        end
        return l
    end

    local function placeLine(line, a, b)
        local d = b - a
        local mid = (a + b) / 2
        line.Position = UDim2.fromOffset(mid.X, mid.Y)
        line.Size = UDim2.fromOffset(math.max(d.Magnitude, 1), 2)
        line.Rotation = math.deg(math.atan2(d.Y, d.X))
        line.Visible = true
    end

    ----------------------------------------------------------------
    -- aiming: ray from the centre of the screen
    ----------------------------------------------------------------
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude

    local function castAim(cam)
        local vs = cam.ViewportSize
        local ray = cam:ViewportPointToRay(vs.X / 2, vs.Y / 2)
        local ignore = {}
        if LocalPlayer.Character then ignore[1] = LocalPlayer.Character end
        local tries = S.skipClear and 12 or 1
        for _ = 1, tries do
            rayParams.FilterDescendantsInstances = ignore
            local res = workspace:Raycast(ray.Origin, ray.Direction * 3000, rayParams)
            if not res then return nil end
            local p = res.Instance
            if S.skipClear and p ~= workspace.Terrain and p.Transparency >= 0.9 then
                ignore[#ignore + 1] = p
            else
                return res
            end
        end
        return nil
    end

    -- world-space bounds of the thing we are looking at
    local function boundsOf(inst, hitPos)
        if inst:IsA("Terrain") then
            return CFrame.new(hitPos), Vector3.new(8, 8, 8)
        elseif inst:IsA("BasePart") then
            return inst.CFrame, inst.Size
        end
        local c = S.cache
        local now = os.clock()
        if c.inst == inst and now - c.t < (inst:IsA("Model") and 0.1 or 0.5) then
            return c.cf, c.size
        end
        local cf, size
        if inst:IsA("Model") then
            local ok, a, b = pcall(inst.GetBoundingBox, inst)
            if ok then cf, size = a, b end
        end
        if not cf then
            local mn, mx, n = nil, nil, 0
            for _, d in ipairs(inst:GetDescendants()) do
                if d:IsA("BasePart") then
                    local p, h = d.Position, d.Size.Magnitude / 2
                    local lo, hi = p - Vector3.new(h, h, h), p + Vector3.new(h, h, h)
                    if mn then
                        mn = Vector3.new(math.min(mn.X, lo.X), math.min(mn.Y, lo.Y), math.min(mn.Z, lo.Z))
                        mx = Vector3.new(math.max(mx.X, hi.X), math.max(mx.Y, hi.Y), math.max(mx.Z, hi.Z))
                    else
                        mn, mx = lo, hi
                    end
                    n = n + 1
                    if n >= 300 then break end
                end
            end
            if mn then
                cf, size = CFrame.new((mn + mx) / 2), mx - mn
            else
                cf, size = CFrame.new(hitPos), Vector3.new(6, 6, 6)
            end
        end
        c.inst, c.t, c.cf, c.size = inst, now, cf, size
        return cf, size
    end

    -- project the 3D bounds to a 2D box on screen
    local function screenBox(cam, cf, size, vs)
        local hx, hy, hz = size.X / 2, size.Y / 2, size.Z / 2
        local x0, y0, x1, y1 = math.huge, math.huge, -math.huge, -math.huge
        local behind = false
        for sx = -1, 1, 2 do
            for sy = -1, 1, 2 do
                for sz = -1, 1, 2 do
                    local v = cam:WorldToViewportPoint(cf:PointToWorldSpace(Vector3.new(sx * hx, sy * hy, sz * hz)))
                    if v.Z <= 0 then
                        behind = true
                    else
                        if v.X < x0 then x0 = v.X end
                        if v.Y < y0 then y0 = v.Y end
                        if v.X > x1 then x1 = v.X end
                        if v.Y > y1 then y1 = v.Y end
                    end
                end
            end
        end
        if behind or x1 < x0 then
            -- huge object (floor / big map): small box around the reticle
            return Vector2.new(vs.X / 2, vs.Y / 2), Vector2.new(150, 150), true
        end
        local m = 18
        x0 = math.clamp(x0, m, vs.X - m)
        x1 = math.clamp(x1, m, vs.X - m)
        y0 = math.clamp(y0, m, vs.Y - m)
        y1 = math.clamp(y1, m, vs.Y - m)
        local w, h = math.max(x1 - x0, 56), math.max(y1 - y0, 56)
        return Vector2.new((x0 + x1) / 2, (y0 + y1) / 2), Vector2.new(w, h), false
    end

    local function flagsText(inst)
        if inst:IsA("BasePart") then
            local s = inst.Size
            return string.format("%s  %s  T:%.1f  %.1fx%.1fx%.1f",
                inst.Anchored and "ANCH" or "FREE",
                inst.CanCollide and "SOLID" or "GHOST",
                inst.Transparency, s.X, s.Y, s.Z)
        end
        return string.format("%d children", #inst:GetChildren())
    end

    ----------------------------------------------------------------
    -- camera in / out
    ----------------------------------------------------------------
    -- photo freeze: keep the camera exactly where the picture was taken
    local function freezeCam()
        local cam = workspace.CurrentCamera
        if not cam or S.frozen then return end
        S.frozen = { ctype = cam.CameraType }
        local cf = cam.CFrame
        cam.CameraType = Enum.CameraType.Scriptable
        cam.CFrame = cf
    end

    local function unfreezeCam()
        local fz = S.frozen
        if not fz then return end
        S.frozen = nil
        local cam = workspace.CurrentCamera
        if cam then pcall(function() cam.CameraType = fz.ctype end) end
    end

    local function enterFirstPerson()
        local cam = workspace.CurrentCamera
        S.saved = {
            mode = LocalPlayer.CameraMode,
            minZ = LocalPlayer.CameraMinZoomDistance,
            maxZ = LocalPlayer.CameraMaxZoomDistance,
            fov = cam and cam.FieldOfView or 70,
        }
        pcall(function() LocalPlayer.CameraMinZoomDistance = 0.5 end)
        pcall(function() LocalPlayer.CameraMaxZoomDistance = 0.5 end)
        pcall(function() LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson end)
        if cam then
            S.fovTween = TweenService:Create(cam,
                TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                { FieldOfView = math.max(40, S.saved.fov - 12) })
            S.fovTween:Play()
        end
    end

    local function leaveFirstPerson()
        unfreezeCam()
        local sv = S.saved
        if not sv then return end
        S.saved = nil
        if S.fovTween then
            pcall(function() S.fovTween:Cancel() end)
            S.fovTween = nil
        end
        pcall(function() LocalPlayer.CameraMaxZoomDistance = sv.maxZ end)
        pcall(function() LocalPlayer.CameraMinZoomDistance = sv.minZ end)
        pcall(function() LocalPlayer.CameraMode = sv.mode end)
        local cam = workspace.CurrentCamera
        if cam then
            pcall(function()
                TweenService:Create(cam,
                    TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                    { FieldOfView = sv.fov }):Play()
            end)
        end
    end

    ----------------------------------------------------------------
    -- top button (next to the "Dex" tab)
    ----------------------------------------------------------------
    local tabW = IS_MOBILE and 78 or 96
    local topBtn = new("TextButton", {
        Name = "ScanBtn",
        Text = "",
        Position = UDim2.new(0.5, tabW / 2 + 4, 0, 2),
        Size = UDim2.new(0, IS_MOBILE and 78 or 92, 0, tabH),
        BackgroundColor3 = WHITE,
        BorderSizePixel = 0,
        AutoButtonColor = true,
        ZIndex = 30,
    }, gui)
    corner(topBtn, 5)
    new("UIGradient", {
        Color = ColorSequence.new(Color3.fromRGB(0, 175, 215), Color3.fromRGB(25, 95, 195)),
        Rotation = 0,
    }, topBtn)
    do
        local ic = new("Frame", {
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(0, 8, 0.5, -9),
            BackgroundTransparency = 1,
        }, topBtn)
        fr(ic, 0.5, 3.5, 15, 11, WHITE, 0.15)
        fr(ic, 5, 1.5, 6, 3, Color3.fromRGB(215, 230, 245), 0.3)
        fr(ic, 4.5, 5.5, 7, 7, Color3.fromRGB(20, 40, 60), 0.5)
        fr(ic, 6, 7, 4, 4, CY, 0.5)
        new("TextLabel", {
            Text = "Scan",
            Position = UDim2.new(0, 30, 0, 0),
            Size = UDim2.new(1, -34, 1, 0),
            BackgroundTransparency = 1,
            TextColor3 = WHITE,
            Font = FONTB,
            TextSize = TS,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, topBtn)
    end

    ----------------------------------------------------------------
    -- hide / show the normal Dex UI
    ----------------------------------------------------------------
    local function hideDexGui()
        S.prev = { dockOpen = dockOpen, explorerOn = explorerOn, click = clickSelect }
        clickSelect = false
        pcall(closeCtx)
        popup.Visible = false
        setMenuOpen(false)
        dock.Visible = false
        hideBtn.Visible = false
        tab.Visible = false
        topBtn.Visible = false
    end

    local function showDexGui(pick)
        local pv = S.prev
        S.prev = nil
        tab.Visible = true
        topBtn.Visible = true
        if pv then clickSelect = pv.click end
        if pick then
            explorerOn = true
            dockOpen = false
            layoutDock(false)
        else
            if pv then
                dockOpen = pv.dockOpen
                explorerOn = pv.explorerOn
            end
            layoutDock(false)
        end
        updateTiles()
    end

    ----------------------------------------------------------------
    -- viewfinder UI
    ----------------------------------------------------------------
    local function toggleSkip()
        S.skipClear = not S.skipClear
        if U.skipBtn then
            U.skipBtn.Text = S.skipClear and "SKIP CLEAR: ON" or "SKIP CLEAR: OFF"
            U.skipBtn.TextColor3 = S.skipClear and GR or WHITE
        end
    end

    local function ping(color)
        if not U.root then return end
        local p = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 40, 0, 40),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 9,
        }, U.root)
        circle(p)
        local st = new("UIStroke", {
            Color = color or CY,
            Thickness = 2.5,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        }, p)
        local info = TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(p, info, { Size = UDim2.new(0, 180, 0, 180) }):Play()
        TweenService:Create(st, info, { Transparency = 1 }):Play()
        task.delay(0.6, function() pcall(function() p:Destroy() end) end)
    end

    local function stepLevel(dir)
        if not S.active or S.busy then return end
        local chain, cur = S.chain, S.target
        if not cur or #chain == 0 then return end
        local idx = 1
        for i, v in ipairs(chain) do
            if v == cur then idx = i break end
        end
        local ni = math.clamp(idx + dir, 1, #chain)
        if ni ~= idx then
            S.sticky = chain[ni]
            ping(AM)
        end
    end

    local function hudButton(text, w, h, pos, anchor, fn)
        local b = new("TextButton", {
            Text = text,
            Size = UDim2.new(0, w, 0, h),
            Position = pos,
            AnchorPoint = anchor,
            BackgroundColor3 = INK,
            BackgroundTransparency = 0.25,
            BorderSizePixel = 0,
            TextColor3 = WHITE,
            Font = HUDF,
            TextSize = 12,
            AutoButtonColor = true,
            ZIndex = 12,
        }, U.root)
        corner(b, 5)
        stroke(b, CY, 1)
        b.Activated:Connect(fn)
        return b
    end

    local function paintMode()
        if not U.modeBtns then return end
        for key, b in pairs(U.modeBtns) do
            local on = (key == S.mode)
            b.BackgroundTransparency = on and 0 or 1
            b.TextColor3 = on and INK or WHITE
        end
    end

    local function buildUi()
        for k in pairs(U) do U[k] = nil end
        local M = 22

        local root = new("Frame", {
            Name = "ScanCam",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 40,
        }, gui)
        U.root = root

        -- soft shading at the top / bottom edge
        for _, top in ipairs({ true, false }) do
            local f = new("Frame", {
                AnchorPoint = Vector2.new(0, top and 0 or 1),
                Position = UDim2.new(0, 0, top and 0 or 1, 0),
                Size = UDim2.new(1, 0, 0, top and 70 or 120),
                BackgroundColor3 = INK,
                BorderSizePixel = 0,
                ZIndex = 1,
            }, root)
            local seq
            if top then
                seq = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.25), NumberSequenceKeypoint.new(1, 1) })
            else
                seq = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.25) })
            end
            new("UIGradient", { Rotation = 90, Transparency = seq }, f)
        end

        -- scanning sweep (glow + bright line)
        local sweep = new("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 0, 0.08, 0),
            Size = UDim2.new(1, 0, 0, 120),
            BackgroundColor3 = CY,
            BorderSizePixel = 0,
            ZIndex = 2,
        }, root)
        new("UIGradient", {
            Rotation = 90,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.5, 0.8),
                NumberSequenceKeypoint.new(1, 1),
            }),
        }, sweep)
        local sweepLine = new("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.new(1, 0, 0, 2),
            BackgroundColor3 = CY,
            BorderSizePixel = 0,
        }, sweep)
        new("UIGradient", {
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.15, 0.15),
                NumberSequenceKeypoint.new(0.85, 0.15),
                NumberSequenceKeypoint.new(1, 1),
            }),
        }, sweepLine)
        U.sweep = sweep
        loopTween(sweep, 2.4, { Position = UDim2.new(0, 0, 0.92, 0) })

        -- viewfinder corner brackets
        local vf = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, 240, 1, 240),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 4,
        }, root)
        U.vf = vf
        U.vfSize = UDim2.new(1, -M * 2, 1, -M * 2)
        brackets(vf, IS_MOBILE and 26 or 34, 3, CY)

        -- reticle (rotating ticks + ring)
        local ret = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 180, 0, 180),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 8,
        }, root)
        U.ret = ret
        U.retTicks = {}
        local tickDefs = {
            { 0.5, 0, 2, 12 }, { 0.5, 1, 2, 12 }, { 0, 0.5, 12, 2 }, { 1, 0.5, 12, 2 },
        }
        for _, d in ipairs(tickDefs) do
            U.retTicks[#U.retTicks + 1] = new("Frame", {
                AnchorPoint = Vector2.new(d[1], d[2]),
                Position = UDim2.new(d[1], 0, d[2], 0),
                Size = UDim2.new(0, d[3], 0, d[4]),
                BackgroundColor3 = CY,
                BorderSizePixel = 0,
            }, ret)
        end
        local ring = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, -16, 1, -16),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
        }, ret)
        circle(ring)
        U.retStroke = new("UIStroke", {
            Color = CY, Thickness = 1.5, Transparency = 0.45,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        }, ring)
        local inner = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 22, 0, 22),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 9,
        }, root)
        circle(inner)
        new("UIStroke", {
            Color = WHITE, Thickness = 1, Transparency = 0.45,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        }, inner)
        local dot = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 4, 0, 4),
            BackgroundColor3 = WHITE,
            BorderSizePixel = 0,
            ZIndex = 9,
        }, root)
        circle(dot)

        -- target box (follows the object on screen)
        local box = new("Frame", {
            Size = UDim2.new(0, 100, 0, 100),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = 6,
        }, root)
        U.box = box
        U.boxFill = new("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = CY,
            BackgroundTransparency = 0.9,
            BorderSizePixel = 0,
        }, box)
        local clip = new("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ClipsDescendants = true,
        }, box)
        U.scanBar = new("Frame", {
            Size = UDim2.new(1, 0, 0, 2),
            BackgroundColor3 = CY,
            BackgroundTransparency = 0.25,
            BorderSizePixel = 0,
        }, clip)
        loopTween(U.scanBar, 0.9, { Position = UDim2.new(0, 0, 1, -2) })
        U.boxBr = brackets(box, 16, 3, CY)

        -- info card + leader line
        local CW = IS_MOBILE and 208 or 232
        local CH = 88
        U.CW, U.CH = CW, CH
        local card = new("Frame", {
            Size = UDim2.new(0, CW, 0, CH),
            BackgroundColor3 = INK,
            BackgroundTransparency = 0.15,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = 7,
        }, root)
        U.card = card
        corner(card, 5)
        U.cardStroke = stroke(card, CY, 1.2)
        U.cardBar = new("Frame", {
            Size = UDim2.new(0, 3, 1, -12),
            Position = UDim2.new(0, 0, 0, 6),
            BackgroundColor3 = CY,
            BorderSizePixel = 0,
        }, card)
        U.plate = new("Frame", {
            Size = UDim2.new(0, 28, 0, 28),
            Position = UDim2.new(0, 12, 0, 8),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
        }, card)
        U.cName = label(card, "", 15, BOLDF, WHITE, {
            Position = UDim2.new(0, 48, 0, 6),
            Size = UDim2.new(1, -56, 0, 20),
            TextTruncate = Enum.TextTruncate.AtEnd,
        })
        U.cClass = label(card, "", 12, HUDF, CY, {
            Position = UDim2.new(0, 48, 0, 26),
            Size = UDim2.new(1, -56, 0, 14),
            TextTruncate = Enum.TextTruncate.AtEnd,
        })
        U.cInfo = label(card, "", 11, HUDF, Color3.fromRGB(170, 182, 198), {
            Position = UDim2.new(0, 12, 0, 46),
            Size = UDim2.new(1, -20, 0, 14),
            TextTruncate = Enum.TextTruncate.AtEnd,
        })
        U.cLvl = label(card, "", 11, HUDF, AM, {
            Position = UDim2.new(0, 12, 0, 64),
            Size = UDim2.new(1, -20, 0, 14),
            TextTruncate = Enum.TextTruncate.AtEnd,
        })
        U.line = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.new(0, 10, 0, 2),
            BackgroundColor3 = CY,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = 6,
        }, root)
        U.dotA = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.new(0, 8, 0, 8),
            BackgroundColor3 = CY,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = 7,
        }, root)
        circle(U.dotA)
        U.dotE = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.new(0, 8, 0, 8),
            BackgroundColor3 = CY,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = 7,
        }, root)
        circle(U.dotE)

        -- HUD text
        local rec = new("Frame", {
            Position = UDim2.new(0, M + 14, 0, M + 12),
            Size = UDim2.new(0, 10, 0, 10),
            BackgroundColor3 = Color3.fromRGB(255, 70, 70),
            BorderSizePixel = 0,
            ZIndex = 10,
        }, root)
        circle(rec)
        loopTween(rec, 0.55, { BackgroundTransparency = 1 })
        label(root, "SCAN CAM", 14, HUDF, WHITE, {
            Position = UDim2.new(0, M + 32, 0, M + 6),
            Size = UDim2.new(0, 120, 0, 20),
            ZIndex = 10,
        })
        U.coords = label(root, "", 12, HUDF, CY, {
            Position = UDim2.new(0, M + 14, 0, M + 28),
            Size = UDim2.new(0, 280, 0, 14),
            ZIndex = 10,
        })
        U.status = label(root, "SCANNING", 13, HUDF, CY, {
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.new(0.5, 0, 0, M + 8),
            Size = UDim2.new(0, 260, 0, 18),
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 10,
        })
        U.hint = label(root, "AIM AT AN OBJECT", 12, HUDF, WHITE, {
            AnchorPoint = Vector2.new(0.5, 1),
            Position = UDim2.new(0.5, 0, 1, -(M + 82)),
            Size = UDim2.new(0, 420, 0, 16),
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 10,
        })

        -- buttons
        U.exitBtn = hudButton("EXIT", 62, 28, UDim2.new(1, -(M + 14), 0, M + 6), Vector2.new(1, 0), function()
            stopScan(nil)
        end)
        U.skipBtn = hudButton("SKIP CLEAR: OFF", 124, 28,
            UDim2.new(1, -(M + 14 + 62 + 8), 0, M + 6), Vector2.new(1, 0), toggleSkip)
        hudButton("PARENT", 76, 32, UDim2.new(1, -(M + 14), 0.5, -4), Vector2.new(1, 1), function()
            stepLevel(1)
        end)
        hudButton("CHILD", 76, 32, UDim2.new(1, -(M + 14), 0.5, 4), Vector2.new(1, 0), function()
            stepLevel(-1)
        end)
        toggleSkip() toggleSkip() -- refresh label to the current state

        -- shutter
        local sh = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 1),
            Position = UDim2.new(0.5, 0, 1, -(M + 6)),
            Size = UDim2.new(0, 70, 0, 70),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 12,
        }, root)
        local shRing = new("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 12,
        }, sh)
        circle(shRing)
        U.shStroke = new("UIStroke", {
            Color = WHITE, Thickness = 3, ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        }, shRing)
        local core = new("TextButton", {
            Text = "",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 54, 0, 54),
            BackgroundColor3 = WHITE,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            ZIndex = 13,
        }, sh)
        circle(core)
        U.shCore = core
        core.Activated:Connect(function() capture() end)
        U.shutter = sh
        local sc = new("UIScale", {}, sh)
        loopTween(sc, 0.8, { Scale = 1.07 })

        -- white flash (used on capture)
        U.flash = new("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = WHITE,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 30,
        }, root)

        -- glow on the real object in the world
        local okH, h = pcall(function()
            local x = Instance.new("Highlight")
            x.FillColor = CY
            x.OutlineColor = CY
            x.FillTransparency = 0.8
            x.OutlineTransparency = 0.05
            x.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            x.Parent = gui
            return x
        end)
        if okH then
            U.hl = h
            loopTween(h, 0.7, { FillTransparency = 0.55 })
        end

        -- mode switch: LIVE (aim + pick)  /  SNAP (photo, then detailed scan)
        local pill = new("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, M + 14, 1, -(M + 18)),
            Size = UDim2.new(0, 150, 0, 32),
            BackgroundColor3 = INK,
            BackgroundTransparency = 0.2,
            BorderSizePixel = 0,
            ZIndex = 12,
        }, root)
        circle(pill)
        stroke(pill, CY, 1)
        U.pill = pill
        U.modeBtns = {}
        local modeDefs = { { "live", "LIVE" }, { "snap", "SNAP" } }
        for i, def in ipairs(modeDefs) do
            local b = new("TextButton", {
                Text = def[2],
                Position = UDim2.new((i - 1) * 0.5, (i == 1) and 3 or 1, 0, 3),
                Size = UDim2.new(0.5, -4, 1, -6),
                BackgroundColor3 = CY,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                TextColor3 = WHITE,
                Font = BOLDF,
                TextSize = 13,
                AutoButtonColor = false,
                ZIndex = 13,
            }, pill)
            circle(b)
            b.Activated:Connect(function() setMode(def[1]) end)
            U.modeBtns[def[1]] = b
        end

        -- everything that is only for LIVE mode (hidden in SNAP mode)
        local keep = { [sh] = true, [U.exitBtn] = true, [pill] = true, [U.flash] = true }
        U.live = {}
        for _, ch in ipairs(root:GetChildren()) do
            if not keep[ch] then U.live[#U.live + 1] = ch end
        end
        paintMode()
    end

    ----------------------------------------------------------------
    -- lock-on / lost
    ----------------------------------------------------------------
    local function onAcquire(inst)
        S.locked = true
        U.status.Text = "TARGET LOCKED"
        U.status.TextColor3 = GR
        for _, tk in ipairs(U.retTicks) do tk.BackgroundColor3 = GR end
        U.retStroke.Color = GR
        TweenService:Create(U.ret,
            TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { Size = UDim2.new(0, 64, 0, 64) }):Play()
        U.hint.Text = IS_MOBILE and "PRESS THE SHUTTER TO PICK"
            or "CLICK = PICK    SCROLL = PARENT/CHILD    Q = EXIT"
        U.cName.Text = inst.Name
        pcall(function() U.cName.MaxVisibleGraphemes = 0 end)
        S.typeT0 = os.clock()
        S.typing = true
        U.plate:ClearAllChildren()
        local draw = DRAW[kindFor(inst)] or DRAW.block
        draw(U.plate)
        ping(GR)
        if U.hl then pcall(function() U.hl.Adornee = inst end) end
    end

    local function onLost()
        S.target = nil
        S.boxInit = false
        S.cardInit = false
        S.locked = false
        S.typing = false
        U.box.Visible = false
        U.card.Visible = false
        U.line.Visible = false
        U.dotA.Visible = false
        U.dotE.Visible = false
        if U.hl then pcall(function() U.hl.Adornee = nil end) end
        for _, tk in ipairs(U.retTicks) do tk.BackgroundColor3 = CY end
        U.retStroke.Color = CY
        TweenService:Create(U.ret,
            TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { Size = UDim2.new(0, 96, 0, 96) }):Play()
        U.hint.Text = "AIM AT AN OBJECT"
    end

    ----------------------------------------------------------------
    -- SNAP mode: take a photo, then scan the whole frame in detail
    -- (every part that is really visible, even tiny ones) and tap to pick
    ----------------------------------------------------------------
    local PINK = Color3.fromRGB(255, 110, 140)
    local PURP = Color3.fromRGB(176, 128, 255)
    local SNAP_DUR = 2.4        -- seconds the sweep takes
    local SNAP_MAXD = 3000      -- parts further than this are ignored
    local SNAP_MAXC = 8000      -- max number of parts that get a visibility test
    local MAX_BOXES = 400       -- max boxes drawn on the photo
    local MAX_ROWS = 120        -- max rows built in the list

    local function setControls(v)
        if U.shutter then U.shutter.Visible = v end
        if U.exitBtn then U.exitBtn.Visible = v end
        if U.pill then U.pill.Visible = v end
    end

    local function colorOf(it)
        for _, t in ipairs(it.tags) do
            if t == "NPC" or t == "PLAYER" then return PINK end
        end
        if it.special then return AM end
        if it.clear then return PURP end
        if it.kind == "model" then return GR end
        return CY
    end

    local function passes(it, f)
        if f == "ALL" then return it.kind == "part" end
        if f == "MODEL" then return it.kind == "model" end
        if f == "SPECIAL" then return it.special end
        if f == "SMALL" then return it.kind == "part" and it.small end
        if f == "CLEAR" then return it.kind == "part" and it.clear end
        return false
    end

    local function snapCleanup()
        N.fillTok = N.fillTok + 1
        if U.snapRoot then pcall(function() U.snapRoot:Destroy() end) end
        U.snapRoot, U.boxLayer, U.selBox, U.panel, U.list = nil, nil, nil, nil, nil
        U.sBand, U.sGrid, U.sStatus, U.sBar, U.sBarBg, U.sFrame = nil, nil, nil, nil, nil, nil
        U.chips, U.barName, U.barInfo, U.barFlags, U.pickBtn, U.parentBtn, U.hdrCount =
            nil, nil, nil, nil, nil, nil, nil
        N.all, N.parts, N.models, N.view, N.sel, N.modelOf = {}, {}, {}, {}, nil, {}
        if U.hl then pcall(function() U.hl.Adornee = nil end) end
    end

    local function styleRow(it, on)
        local row = it.row
        if not row or not row.Parent then return end
        row.BackgroundColor3 = on and Color3.fromRGB(0, 78, 104) or Color3.fromRGB(16, 26, 36)
        local st = row:FindFirstChildOfClass("UIStroke")
        if st then st.Transparency = on and 0 or 1 end
    end

    local function updateBar()
        if not U.barName then return end
        local it = N.sel
        if not it then
            U.barName.Text = "NOTHING SELECTED"
            U.barInfo.Text = IS_MOBILE and "TAP AN OBJECT IN THE PHOTO OR THE LIST"
                or "CLICK AN OBJECT OR PICK FROM THE LIST"
            U.barFlags.Text = ""
            U.pickBtn.BackgroundTransparency = 0.75
            U.parentBtn.BackgroundTransparency = 0.75
            return
        end
        U.barName.Text = it.name
        U.barInfo.Text = string.format("%s  |  %.1f studs", it.class, it.dist)
        local ok, ft = pcall(flagsText, it.inst)
        local tg = table.concat(it.tags, " ")
        U.barFlags.Text = (ok and ft or "") .. (tg ~= "" and ("  " .. tg) or "")
        U.pickBtn.BackgroundTransparency = 0.05
        U.parentBtn.BackgroundTransparency = 0.15
    end

    local function snapSelect(it)
        if N.phase ~= "results" or not it then return end
        if N.sel then styleRow(N.sel, false) end
        N.sel = it
        styleRow(it, true)
        if U.hl then
            pcall(function()
                U.hl.FillColor = AM
                U.hl.OutlineColor = AM
                U.hl.Adornee = it.inst
            end)
        end
        local sb = U.selBox
        if sb then
            local w = math.max(it.x1 - it.x0, 20)
            local h = math.max(it.y1 - it.y0, 20)
            local cx, cy = (it.x0 + it.x1) / 2, (it.y0 + it.y1) / 2
            local pos = UDim2.fromOffset(cx - w / 2, cy - h / 2)
            local siz = UDim2.fromOffset(w, h)
            if sb.Visible then
                TweenService:Create(sb,
                    TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    { Position = pos, Size = siz }):Play()
            else
                sb.Position = pos
                sb.Size = siz
                sb.Visible = true
            end
        end
        if it.row and it.row.Parent and U.list then
            pcall(function()
                local l = U.list
                local y = it.row.AbsolutePosition.Y - l.AbsolutePosition.Y + l.CanvasPosition.Y
                l.CanvasPosition = Vector2.new(0, math.max(0, y - 6))
            end)
        end
        updateBar()
    end

    local function snapDeselect()
        if N.sel then styleRow(N.sel, false) end
        N.sel = nil
        if U.selBox then U.selBox.Visible = false end
        if U.hl then pcall(function() U.hl.Adornee = nil end) end
        updateBar()
    end

    local function snapParent()
        local cur = N.sel
        if not cur or not cur.inst then return end
        local p = cur.inst.Parent
        if not p or p == workspace or p == game then
            toast("Already at the top")
            return
        end
        local it = N.modelOf[p]
        if not it then
            local x0, y0, x1, y1 = math.huge, math.huge, -math.huge, -math.huge
            local dist, cnt = math.huge, 0
            for _, q in ipairs(N.parts) do
                if q.inst:IsDescendantOf(p) then
                    cnt = cnt + 1
                    if q.x0 < x0 then x0 = q.x0 end
                    if q.y0 < y0 then y0 = q.y0 end
                    if q.x1 > x1 then x1 = q.x1 end
                    if q.y1 > y1 then y1 = q.y1 end
                    if q.dist < dist then dist = q.dist end
                end
            end
            if cnt == 0 then
                x0, y0, x1, y1, dist, cnt = cur.x0, cur.y0, cur.x1, cur.y1, cur.dist, 1
            end
            it = {
                kind = "model", inst = p, name = p.Name, class = p.ClassName, count = cnt,
                dist = dist, x0 = x0, y0 = y0, x1 = x1, y1 = y1,
                tags = {}, special = false, small = false, clear = false,
            }
        end
        snapSelect(it)
    end

    local function addRow(it, order)
        local row = new("TextButton", {
            Text = "",
            AutoButtonColor = false,
            Size = UDim2.new(1, -6, 0, 38),
            BackgroundColor3 = Color3.fromRGB(16, 26, 36),
            BackgroundTransparency = 0.1,
            BorderSizePixel = 0,
            LayoutOrder = order,
            ZIndex = 15,
        }, U.list)
        corner(row, 5)
        new("UIStroke", {
            Color = CY, Thickness = 1.5, Transparency = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        }, row)
        it.row = row
        local plate = new("Frame", {
            Size = UDim2.new(0, 24, 0, 24),
            Position = UDim2.new(0, 6, 0.5, -12),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 16,
        }, row)
        pcall(function()
            local draw = DRAW[kindFor(it.inst)] or DRAW.block
            draw(plate)
        end)
        local nm = it.name
        if it.kind == "model" then nm = nm .. "  x" .. tostring(it.count) end
        label(row, nm, 13, BOLDF, WHITE, {
            Position = UDim2.new(0, 38, 0, 3),
            Size = UDim2.new(1, -44, 0, 17),
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 16,
        })
        local tg = table.concat(it.tags, " ")
        local info = string.format("%s | %.0f studs", it.class, it.dist)
        if tg ~= "" then info = info .. " | " .. tg end
        label(row, info, 10, HUDF, it.special and AM or Color3.fromRGB(150, 165, 182), {
            Position = UDim2.new(0, 38, 0, 21),
            Size = UDim2.new(1, -44, 0, 13),
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 16,
        })
        row.Activated:Connect(function() snapSelect(it) end)
        if N.sel == it then styleRow(it, true) end
    end

    local function fillList()
        local list = U.list
        if not list then return end
        N.fillTok = N.fillTok + 1
        local tk = N.fillTok
        for _, ch in ipairs(list:GetChildren()) do
            if ch:IsA("GuiObject") then ch:Destroy() end
        end
        for _, it in ipairs(N.all) do it.row = nil end
        local view = N.view
        task.spawn(function()
            local n = math.min(#view, MAX_ROWS)
            for i = 1, n do
                if N.fillTok ~= tk or not U.list then return end
                addRow(view[i], i)
                if i % 14 == 0 then RunService.Heartbeat:Wait() end
            end
            if N.fillTok ~= tk or not U.list then return end
            local msg
            if #view == 0 then
                msg = "NOTHING IN THIS FILTER"
            elseif #view > n then
                msg = string.format("+%d MORE - TAP THE PHOTO OR USE A FILTER", #view - n)
            end
            if msg then
                label(U.list, msg, 11, HUDF, Color3.fromRGB(150, 165, 182), {
                    Size = UDim2.new(1, -6, 0, 26),
                    LayoutOrder = n + 1,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    ZIndex = 15,
                })
            end
        end)
    end

    local function paintChips()
        if not U.chips then return end
        for key, c in pairs(U.chips) do
            local on = (key == N.filter)
            c.BackgroundColor3 = on and CY or Color3.fromRGB(20, 36, 50)
            c.TextColor3 = on and INK or WHITE
        end
    end

    local function applyFilter(f)
        N.filter = f
        local view = {}
        for _, it in ipairs(N.all) do
            local ok = passes(it, f)
            if ok then view[#view + 1] = it end
            if it.box then it.box.Visible = ok end
        end
        N.view = view
        paintChips()
        snapDeselect()
        fillList()
    end

    local function buildPanel(vs)
        local land = vs.X >= vs.Y * 1.1
        local pw = land and math.clamp(math.floor(vs.X * 0.36), 220, 300) or vs.X
        local ph = land and vs.Y or math.floor(vs.Y * 0.5)
        local pad = 8
        local panel = new("Frame", {
            Name = "SnapPanel",
            AnchorPoint = land and Vector2.new(1, 0) or Vector2.new(0, 1),
            Position = land and UDim2.new(1, pw, 0, 0) or UDim2.new(0, 0, 1, ph),
            Size = UDim2.fromOffset(pw, ph),
            BackgroundColor3 = INK,
            BackgroundTransparency = 0.06,
            BorderSizePixel = 0,
            Active = true,
            ZIndex = 14,
        }, U.snapRoot)
        stroke(panel, CY, 1)
        U.panel = panel
        TweenService:Create(panel,
            TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            { Position = land and UDim2.new(1, 0, 0, 0) or UDim2.new(0, 0, 1, 0) }):Play()

        -- header
        label(panel, "SNAP SCAN", 13, HUDF, WHITE, {
            Position = UDim2.new(0, pad, 0, 6), Size = UDim2.new(0, 80, 0, 18), ZIndex = 15,
        })
        U.hdrCount = label(panel, "", 11, HUDF, CY, {
            Position = UDim2.new(0, pad, 0, 25), Size = UDim2.new(1, -pad * 2, 0, 14), ZIndex = 15,
        })
        local function pbtn(text, w, x, color, fn)
            local b = new("TextButton", {
                Text = text,
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, x, 0, 4),
                Size = UDim2.new(0, w, 0, 24),
                BackgroundColor3 = color,
                BackgroundTransparency = 0.1,
                BorderSizePixel = 0,
                TextColor3 = WHITE,
                Font = HUDF,
                TextSize = 12,
                AutoButtonColor = true,
                ZIndex = 15,
            }, panel)
            corner(b, 5)
            b.Activated:Connect(fn)
            return b
        end
        pbtn("EXIT", 48, -pad, Color3.fromRGB(150, 50, 60), function() stopScan(nil) end)
        pbtn("RETAKE", 70, -(pad + 54), Color3.fromRGB(30, 90, 130), function() snapReset() end)

        -- filter chips (with counts)
        local defs = {
            { "ALL", "ALL" }, { "MODEL", "MODEL" }, { "SPECIAL", "SPEC" },
            { "SMALL", "SMALL" }, { "CLEAR", "CLEAR" },
        }
        local cw = math.floor((pw - pad * 2 - 4 * 3) / 5)
        U.chips = {}
        for i, d in ipairs(defs) do
            local c = new("TextButton", {
                Text = d[2] .. "\n" .. tostring(N.counts[d[1]] or 0),
                Position = UDim2.new(0, pad + (i - 1) * (cw + 3), 0, 44),
                Size = UDim2.new(0, cw, 0, 36),
                BackgroundColor3 = Color3.fromRGB(20, 36, 50),
                BorderSizePixel = 0,
                TextColor3 = WHITE,
                Font = HUDF,
                TextSize = 11,
                AutoButtonColor = false,
                ZIndex = 15,
            }, panel)
            corner(c, 5)
            c.Activated:Connect(function() applyFilter(d[1]) end)
            U.chips[d[1]] = c
        end

        -- list
        local actH = 98
        local top = 86
        local list = new("ScrollingFrame", {
            Position = UDim2.new(0, pad, 0, top),
            Size = UDim2.new(1, -pad * 2, 0, math.max(60, ph - top - actH - pad * 2)),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = CY,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            ZIndex = 15,
        }, panel)
        new("UIListLayout", {
            Padding = UDim.new(0, 3),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, list)
        U.list = list

        -- selected-object bar
        local bar = new("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, pad, 1, -pad),
            Size = UDim2.new(1, -pad * 2, 0, actH),
            BackgroundColor3 = Color3.fromRGB(12, 22, 32),
            BackgroundTransparency = 0.1,
            BorderSizePixel = 0,
            ZIndex = 15,
        }, panel)
        corner(bar, 6)
        U.barName = label(bar, "", 14, BOLDF, WHITE, {
            Position = UDim2.new(0, 8, 0, 4), Size = UDim2.new(1, -16, 0, 18),
            TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 16,
        })
        U.barInfo = label(bar, "", 11, HUDF, CY, {
            Position = UDim2.new(0, 8, 0, 23), Size = UDim2.new(1, -16, 0, 14),
            TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 16,
        })
        U.barFlags = label(bar, "", 10, HUDF, Color3.fromRGB(150, 165, 182), {
            Position = UDim2.new(0, 8, 0, 38), Size = UDim2.new(1, -16, 0, 13),
            TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 16,
        })
        U.pickBtn = new("TextButton", {
            Text = "PICK > EXPLORER",
            Position = UDim2.new(0, 8, 1, -36),
            Size = UDim2.new(0.62, -10, 0, 28),
            BackgroundColor3 = Color3.fromRGB(30, 140, 85),
            BackgroundTransparency = 0.75,
            BorderSizePixel = 0,
            TextColor3 = WHITE,
            Font = BOLDF,
            TextSize = 12,
            AutoButtonColor = true,
            ZIndex = 16,
        }, bar)
        corner(U.pickBtn, 5)
        U.parentBtn = new("TextButton", {
            Text = "PARENT ^",
            Position = UDim2.new(0.62, 0, 1, -36),
            Size = UDim2.new(0.38, -8, 0, 28),
            BackgroundColor3 = Color3.fromRGB(190, 135, 30),
            BackgroundTransparency = 0.75,
            BorderSizePixel = 0,
            TextColor3 = WHITE,
            Font = BOLDF,
            TextSize = 12,
            AutoButtonColor = true,
            ZIndex = 16,
        }, bar)
        corner(U.parentBtn, 5)
        U.pickBtn.Activated:Connect(function()
            local it = N.sel
            if not it then return end
            if not it.inst or not it.inst.Parent then
                toast("Object is gone")
                return
            end
            stopScan(it.inst)
        end)
        U.parentBtn.Activated:Connect(function() snapParent() end)
        updateBar()
    end

    local function makeBox(it, vs, animate)
        local isModel = (it.kind == "model")
        local key = isModel and "nMBoxes" or "nBoxes"
        if N[key] >= (isModel and 150 or MAX_BOXES) then return end
        N[key] = N[key] + 1
        local w = math.max(it.x1 - it.x0, 14)
        local h = math.max(it.y1 - it.y0, 14)
        local cx, cy = (it.x0 + it.x1) / 2, (it.y0 + it.y1) / 2
        local col = colorOf(it)
        local area = math.min((it.x1 - it.x0) * (it.y1 - it.y0) / (vs.X * vs.Y), 1)
        local fillT = (area > 0.4) and 0.96 or 0.9     -- huge parts (floor...) stay faint
        local strokeT = (area > 0.4) and 0.75 or 0.35
        local b = new("TextButton", {
            Text = "",
            AutoButtonColor = false,
            BackgroundColor3 = col,
            BackgroundTransparency = fillT,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(cx - w / 2, cy - h / 2),
            Size = UDim2.fromOffset(w, h),
            ZIndex = math.floor((1 - area) * 1000) + 1,   -- small boxes sit on top = easy to tap
        }, U.boxLayer)
        local st = new("UIStroke", {
            Color = col,
            Thickness = isModel and 2 or 1,
            Transparency = strokeT,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        }, b)
        b.Activated:Connect(function() snapSelect(it) end)
        it.box = b
        if animate then
            b.Position = UDim2.fromOffset(cx - w / 2 - 14, cy - h / 2 - 14)
            b.Size = UDim2.fromOffset(w + 28, h + 28)
            b.BackgroundTransparency = 1
            st.Transparency = 1
            local info = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            TweenService:Create(b, info, {
                Position = UDim2.fromOffset(cx - w / 2, cy - h / 2),
                Size = UDim2.fromOffset(w, h),
                BackgroundTransparency = fillT,
            }):Play()
            TweenService:Create(st, info, { Transparency = strokeT }):Play()
        end
    end

    local function buildSnapFx()
        local sr = new("Frame", {
            Name = "SnapFx",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 20,
        }, U.root)
        U.snapRoot = sr

        -- catches taps on empty space (deselect)
        local catcher = new("TextButton", {
            Text = "",
            AutoButtonColor = false,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 1,
        }, sr)
        catcher.Activated:Connect(function()
            if N.phase == "results" then snapDeselect() end
        end)

        U.boxLayer = new("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 3,
        }, sr)

        -- box that marks the selected object
        local sb = new("Frame", {
            BackgroundColor3 = AM,
            BackgroundTransparency = 0.85,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = 6,
        }, sr)
        new("UIStroke", {
            Color = AM, Thickness = 2.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        }, sb)
        brackets(sb, 12, 3, AM)
        U.selBox = sb

        -- scan grid
        local grid = new("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 2,
        }, sr)
        U.sGrid = {}
        for k = 1, 11 do
            U.sGrid[#U.sGrid + 1] = new("Frame", {
                Position = UDim2.new(k / 12, 0, 0, 0),
                Size = UDim2.new(0, 1, 1, 0),
                BackgroundColor3 = CY,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
            }, grid)
        end
        for k = 1, 6 do
            U.sGrid[#U.sGrid + 1] = new("Frame", {
                Position = UDim2.new(0, 0, k / 7, 0),
                Size = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = CY,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
            }, grid)
        end
        for _, g in ipairs(U.sGrid) do
            TweenService:Create(g,
                TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { BackgroundTransparency = 0.88 }):Play()
        end

        -- sweep band
        local band = new("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.new(1, 0, 0, 150),
            BackgroundColor3 = CY,
            BorderSizePixel = 0,
            ZIndex = 8,
        }, sr)
        new("UIGradient", {
            Rotation = 90,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.5, 0.7),
                NumberSequenceKeypoint.new(1, 1),
            }),
        }, band)
        local bl = new("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.new(1, 0, 0, 3),
            BackgroundColor3 = WHITE,
            BorderSizePixel = 0,
        }, band)
        new("UIGradient", {
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.12, 0.1),
                NumberSequenceKeypoint.new(0.88, 0.1),
                NumberSequenceKeypoint.new(1, 1),
            }),
        }, bl)
        U.sBand = band

        -- big viewfinder corners
        local vf = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, -44, 1, -44),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 4,
        }, sr)
        brackets(vf, IS_MOBILE and 26 or 34, 3, CY)
        U.sFrame = vf

        -- status + progress
        U.sStatus = label(sr, "INDEXING  0%", 14, HUDF, CY, {
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.new(0.5, 0, 0, 20),
            Size = UDim2.new(0, 230, 0, 44),
            BackgroundColor3 = INK,
            BackgroundTransparency = 0.3,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 10,
        })
        corner(U.sStatus, 6)
        stroke(U.sStatus, CY, 1)
        local barBg = new("Frame", {
            Size = UDim2.new(1, 0, 0, 4),
            BackgroundColor3 = INK,
            BackgroundTransparency = 0.3,
            BorderSizePixel = 0,
            ZIndex = 10,
        }, sr)
        U.sBarBg = barBg
        U.sBar = new("Frame", {
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = CY,
            BorderSizePixel = 0,
            ZIndex = 11,
        }, barBg)
    end

    local function snapRun(token)
        local cam = workspace.CurrentCamera
        if not cam then return end
        local vs = cam.ViewportSize
        local cf = cam.CFrame
        local camPos, look = cf.Position, cf.LookVector
        local focal = (vs.Y / 2) / math.tan(math.rad(cam.FieldOfView) / 2)
        local char = LocalPlayer.Character

        local function isLive()
            return N.token == token and S.active and U.snapRoot ~= nil
        end

        -- screen rectangle + distance of one part (nil = not in the frame)
        local function project(d)
            local pcf, size = d.CFrame, d.Size
            local pos = pcf.Position
            local rel = pos - camPos
            local rad = size.Magnitude * 0.5
            local depth = look:Dot(rel)
            if depth + rad <= 0.1 then return nil end
            local dist = rel.Magnitude
            if dist - rad > SNAP_MAXD then return nil end
            if depth > 0 then
                local margin = rad / depth * focal + 2
                local v = cam:WorldToViewportPoint(pos)
                if v.X < -margin or v.X > vs.X + margin or v.Y < -margin or v.Y > vs.Y + margin then
                    return nil
                end
            end
            local hx, hy, hz = size.X / 2, size.Y / 2, size.Z / 2
            local x0, y0, x1, y1 = math.huge, math.huge, -math.huge, -math.huge
            local behind = false
            for sx = -1, 1, 2 do
                for sy = -1, 1, 2 do
                    for sz = -1, 1, 2 do
                        local v = cam:WorldToViewportPoint(
                            pcf:PointToWorldSpace(Vector3.new(sx * hx, sy * hy, sz * hz)))
                        if v.Z <= 0 then
                            behind = true
                        else
                            if v.X < x0 then x0 = v.X end
                            if v.Y < y0 then y0 = v.Y end
                            if v.X > x1 then x1 = v.X end
                            if v.Y > y1 then y1 = v.Y end
                        end
                    end
                end
            end
            local huge = false
            if behind or x1 < x0 then
                x0, y0, x1, y1 = 0, 0, vs.X, vs.Y
                huge = true
            end
            x0 = math.max(x0, 0)
            y0 = math.max(y0, 0)
            x1 = math.min(x1, vs.X)
            y1 = math.min(y1, vs.Y)
            if x1 <= x0 or y1 <= y0 then return nil end
            if x1 - x0 < 1.5 and y1 - y0 < 1.5 then return nil end   -- sub-pixel: cannot be seen
            return {
                part = d, cf = pcf, size = size, dist = dist,
                x0 = x0, y0 = y0, x1 = x1, y1 = y1, cy = (y0 + y1) / 2, huge = huge,
            }
        end

        ------------------------------------------------------------
        -- step 1: index every part that touches the frame
        ------------------------------------------------------------
        local cands, nC = {}, 0
        local all = workspace:GetDescendants()
        local total = #all
        local i = 1
        local ySm, dt = 0, 1 / 60
        while i <= total do
            if not isLive() then return end
            local last = math.min(total, i + 1499)
            for k = i, last do
                local d = all[k]
                if nC < SNAP_MAXC and d:IsA("BasePart") and d.ClassName ~= "Terrain" then
                    if not (char and d:IsDescendantOf(char)) then
                        local ok, c = pcall(project, d)
                        if ok and c then
                            nC = nC + 1
                            cands[nC] = c
                        end
                    end
                end
            end
            i = last + 1
            local pct = math.floor(100 * (i - 1) / total)
            U.sStatus.Text = string.format("INDEXING  %d%%\nPARTS IN VIEW %d", pct, nC)
            U.sBar.Size = UDim2.new(0.5 * (i - 1) / total, 0, 1, 0)
            local target = vs.Y * (0.5 + 0.42 * math.sin(os.clock() * 4))
            ySm = ySm + (target - ySm) * (1 - math.exp(-dt * 8))
            U.sBand.Position = UDim2.fromOffset(0, ySm)
            dt = RunService.Heartbeat:Wait()
        end
        if not isLive() then return end

        ------------------------------------------------------------
        -- step 2: sweep top -> bottom, test what is really visible
        ------------------------------------------------------------
        table.sort(cands, function(a, b) return a.cy < b.cy end)

        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Exclude
        local baseIgnore = {}
        if char then baseIgnore[1] = char end
        rp.FilterDescendantsInstances = baseIgnore

        -- true when `part` is the first solid thing along the ray (clear parts are looked through)
        local function firstHit(origin, dir, part)
            local ign = nil
            local result = false
            for _ = 1, 4 do
                local res = workspace:Raycast(origin, dir, rp)
                if not res then
                    result = not part.CanQuery
                    break
                end
                local hit = res.Instance
                if hit == part then
                    result = true
                    break
                end
                if hit.ClassName ~= "Terrain" and hit.Transparency >= 0.9 then
                    if not ign then
                        ign = {}
                        for n2, v in ipairs(baseIgnore) do ign[n2] = v end
                    end
                    ign[#ign + 1] = hit
                    rp.FilterDescendantsInstances = ign
                else
                    break
                end
            end
            if ign then rp.FilterDescendantsInstances = baseIgnore end
            return result
        end

        local function tryPoint(p, part)
            local v = p - camPos
            local len = v.Magnitude
            if len < 0.05 then return true end
            return firstHit(camPos, v.Unit * (len + 0.25), part)
        end

        local function isVisible(c)
            local part, pcf, size = c.part, c.cf, c.size
            if tryPoint(pcf.Position, part) then return true end
            local hx, hy, hz = size.X * 0.4, size.Y * 0.4, size.Z * 0.4
            for sx = -1, 1, 2 do
                for sy = -1, 1, 2 do
                    for sz = -1, 1, 2 do
                        if tryPoint(pcf:PointToWorldSpace(Vector3.new(sx * hx, sy * hy, sz * hz)), part) then
                            return true
                        end
                    end
                end
            end
            local w, h = c.x1 - c.x0, c.y1 - c.y0
            if part.CanQuery and (c.huge or w * h > vs.X * vs.Y * 0.01) then
                for gx = 1, 3 do
                    for gy = 1, 3 do
                        local ray = cam:ViewportPointToRay(c.x0 + w * gx / 4, c.y0 + h * gy / 4)
                        if firstHit(ray.Origin, ray.Direction * 3200, part) then return true end
                    end
                end
            end
            return false
        end

        local function specialsOf(d)
            local tags = {}
            if d:FindFirstChildWhichIsA("ClickDetector") then tags[#tags + 1] = "CLICK" end
            if d:FindFirstChildWhichIsA("ProximityPrompt", true) then tags[#tags + 1] = "PROMPT" end
            if d:FindFirstChild("TouchInterest") then tags[#tags + 1] = "TOUCH" end
            return tags
        end

        local function makeItem(c)
            local d = c.part
            local tags = specialsOf(d)
            local item = {
                kind = "part", inst = d, name = d.Name, class = d.ClassName,
                dist = c.dist, x0 = c.x0, y0 = c.y0, x1 = c.x1, y1 = c.y1,
                tags = tags, special = #tags > 0,
                small = c.size.Magnitude < 3,
                clear = d.Transparency >= 0.95,
            }
            if item.clear then tags[#tags + 1] = "CLEAR" end
            return item
        end

        local found = {}
        local idx = 1
        local t0 = os.clock()
        while idx <= nC do
            if not isLive() then return end
            local frac = (os.clock() - t0) / SNAP_DUR
            local want = math.min(nC, math.max(idx, math.floor(frac * nC) + 1))
            local tb = os.clock()
            while idx <= want and os.clock() - tb < 0.006 do
                local c = cands[idx]
                idx = idx + 1
                local ok, vis = pcall(isVisible, c)
                if ok and vis then
                    local ok2, item = pcall(makeItem, c)
                    if ok2 and item then
                        found[#found + 1] = item
                        pcall(makeBox, item, vs, #found <= 90)
                    end
                end
            end
            local target = cands[math.max(1, idx - 1)].cy
            ySm = ySm + (target - ySm) * (1 - math.exp(-dt * 10))
            U.sBand.Position = UDim2.fromOffset(0, ySm)
            U.sStatus.Text = string.format("SCANNING  %d%%\nFOUND %d",
                math.floor(100 * (idx - 1) / nC), #found)
            U.sBar.Size = UDim2.new(0.5 + 0.5 * (idx - 1) / nC, 0, 1, 0)
            dt = RunService.Heartbeat:Wait()
        end
        if not isLive() then return end
        U.sBar.Size = UDim2.new(1, 0, 1, 0)

        ------------------------------------------------------------
        -- step 3: group into models, count, show the results
        ------------------------------------------------------------
        local models, order = {}, {}
        for _, it in ipairs(found) do
            local m = it.inst:FindFirstAncestorOfClass("Model")
            if m then
                local mi = models[m]
                if not mi then
                    mi = {
                        kind = "model", inst = m, name = m.Name, class = m.ClassName, count = 0,
                        dist = it.dist, x0 = it.x0, y0 = it.y0, x1 = it.x1, y1 = it.y1,
                        tags = {}, special = false, small = false, clear = false,
                    }
                    models[m] = mi
                    order[#order + 1] = mi
                    if m:FindFirstChildOfClass("Humanoid") then
                        mi.tags[#mi.tags + 1] = Players:GetPlayerFromCharacter(m) and "PLAYER" or "NPC"
                    end
                    if m:FindFirstChildWhichIsA("ClickDetector") then
                        mi.tags[#mi.tags + 1] = "CLICK"
                    end
                end
                mi.count = mi.count + 1
                if it.dist < mi.dist then mi.dist = it.dist end
                if it.x0 < mi.x0 then mi.x0 = it.x0 end
                if it.y0 < mi.y0 then mi.y0 = it.y0 end
                if it.x1 > mi.x1 then mi.x1 = it.x1 end
                if it.y1 > mi.y1 then mi.y1 = it.y1 end
                for _, t in ipairs(it.tags) do
                    if t ~= "CLEAR" then
                        local has = false
                        for _, e in ipairs(mi.tags) do
                            if e == t then has = true break end
                        end
                        if not has then mi.tags[#mi.tags + 1] = t end
                    end
                end
            end
        end
        for _, mi in ipairs(order) do mi.special = #mi.tags > 0 end

        table.sort(found, function(a, b) return a.dist < b.dist end)
        table.sort(order, function(a, b) return a.dist < b.dist end)
        local allItems = {}
        for _, it in ipairs(found) do allItems[#allItems + 1] = it end
        for _, it in ipairs(order) do allItems[#allItems + 1] = it end
        table.sort(allItems, function(a, b) return a.dist < b.dist end)

        local counts = {}
        for _, key in ipairs({ "ALL", "MODEL", "SPECIAL", "SMALL", "CLEAR" }) do
            local n = 0
            for _, it in ipairs(allItems) do
                if passes(it, key) then n = n + 1 end
            end
            counts[key] = n
        end
        N.parts, N.models, N.all, N.modelOf, N.counts = found, order, allItems, models, counts

        local nPart, nModel = #found, #order
        if nPart == 0 then
            U.sStatus.Text = "NOTHING FOUND"
            U.sStatus.TextColor3 = AM
            task.wait(1.4)
            if isLive() then snapReset() end
            return
        end

        for _, mi in ipairs(order) do
            pcall(makeBox, mi, vs, false)
            if mi.box then mi.box.Visible = false end
        end

        U.sStatus.Text = string.format("SCAN COMPLETE\n%d PARTS | %d MODELS", nPart, nModel)
        U.sStatus.TextColor3 = GR
        TweenService:Create(U.sBand,
            TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            { Position = UDim2.fromOffset(0, vs.Y + 120) }):Play()
        for _, g in ipairs(U.sGrid) do
            TweenService:Create(g,
                TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { BackgroundTransparency = 1 }):Play()
        end
        task.wait(0.8)
        if not isLive() then return end
        pcall(function() U.sStatus:Destroy() end)
        pcall(function() U.sBarBg:Destroy() end)
        pcall(function() U.sBand:Destroy() end)
        U.sStatus, U.sBarBg, U.sBar, U.sBand = nil, nil, nil, nil

        N.phase = "results"
        N.filter = "ALL"
        buildPanel(vs)
        U.hdrCount.Text = string.format("%d PARTS | %d MODELS", nPart, nModel)
        applyFilter("ALL")
    end

    snapReset = function()
        N.token = N.token + 1
        N.phase = "idle"
        snapCleanup()
        unfreezeCam()
        if U.root then setControls(true) end
    end

    snapCapture = function()
        if not S.active or S.lock or S.mode ~= "snap" or N.phase ~= "idle" then return end
        if not workspace.CurrentCamera or not U.root then return end
        N.phase = "scanning"
        N.token = N.token + 1
        local token = N.token
        N.nBoxes, N.nMBoxes = 0, 0
        snapCleanup()
        freezeCam()
        setControls(false)
        U.flash.BackgroundTransparency = 0.05
        TweenService:Create(U.flash,
            TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { BackgroundTransparency = 1 }):Play()
        buildSnapFx()
        task.spawn(function()
            local ok, err = pcall(snapRun, token)
            if not ok then
                warn("[ZeroDex] Snap scan: " .. tostring(err))
                if N.token == token and S.active then
                    toast("Scan failed")
                    snapReset()
                end
            end
        end)
    end

    setMode = function(m, silent)
        if not U.root or N.phase ~= "idle" then return end
        if m ~= "live" and m ~= "snap" then return end
        S.mode = m
        paintMode()
        onLost()
        if m == "snap" then
            for _, o in ipairs(U.live or {}) do o.Visible = false end
            if U.hl then pcall(function() U.hl.Adornee = nil end) end
            if not silent then toast("SNAP mode: press the shutter to photo + scan") end
        else
            for _, o in ipairs(U.live or {}) do o.Visible = true end
            onLost()
        end
    end

    ----------------------------------------------------------------
    -- per-frame update
    ----------------------------------------------------------------
    local function onFrame(dt)
        if not S.active or not U.root then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        local vs = cam.ViewportSize
        local now = os.clock()

        if S.mode == "snap" then return end
        U.ret.Rotation = (U.ret.Rotation + dt * (S.locked and 150 or 45)) % 360

        S.acc = S.acc + dt
        local slow = S.acc >= 0.1
        if slow then
            S.acc = 0
            local cf = cam.CFrame
            local p, lk = cf.Position, cf.LookVector
            U.coords.Text = string.format("X %d  Y %d  Z %d   HDG %03d",
                math.floor(p.X), math.floor(p.Y), math.floor(p.Z),
                math.floor(math.deg(math.atan2(lk.X, -lk.Z)) % 360))
            if not S.locked and not S.busy then
                U.status.Text = "SCANNING" .. string.rep(".", 1 + math.floor(now * 3) % 3)
                U.status.TextColor3 = CY
            end
        end
        if S.busy then return end

        local res = castAim(cam)
        local target, hitPos
        if res then
            hitPos = res.Position
            S.dist = res.Distance
            local chain = {}
            local c = res.Instance
            while c and c ~= workspace and c ~= game do
                chain[#chain + 1] = c
                c = c.Parent
            end
            if #chain > 0 then
                local idx = 1
                if S.sticky then
                    idx = 0
                    for i, v in ipairs(chain) do
                        if v == S.sticky then idx = i break end
                    end
                    if idx == 0 then
                        idx = 1
                        S.sticky = nil
                    end
                end
                target = chain[idx]
                S.chain = chain
                S.idx = idx
            end
        end

        if not target then
            if S.target then onLost() end
            return
        end

        if target ~= S.target then
            S.target = target
            onAcquire(target)
        end

        -- box on screen
        local cf, size = boundsOf(target, hitPos)
        local c2, s2 = screenBox(cam, cf, size, vs)
        if not S.boxInit then
            S.boxInit = true
            S.bp = c2
            S.bs = s2 + Vector2.new(120, 120) -- starts big, then snaps onto the object
        end
        local a = 1 - math.exp(-dt * 14)
        S.bp = S.bp:Lerp(c2, a)
        S.bs = S.bs:Lerp(s2, a)
        U.box.Visible = true
        U.box.Position = UDim2.fromOffset(S.bp.X - S.bs.X / 2, S.bp.Y - S.bs.Y / 2)
        U.box.Size = UDim2.fromOffset(S.bs.X, S.bs.Y)

        -- card + leader line
        local CW, CH = U.CW, U.CH
        local A = Vector2.new(S.bp.X + S.bs.X / 2, S.bp.Y - S.bs.Y / 2)
        local right = (A.X + 52 + CW + 12) <= vs.X
        if not right then
            A = Vector2.new(S.bp.X - S.bs.X / 2, S.bp.Y - S.bs.Y / 2)
        end
        local cx = right and (A.X + 52) or (A.X - 52 - CW)
        local cy = A.Y - 44
        cx = math.clamp(cx, 10, math.max(10, vs.X - CW - 10))
        cy = math.clamp(cy, 56, math.max(56, vs.Y - CH - 112))
        local want = Vector2.new(cx, cy)
        if not S.cardInit then
            S.cardInit = true
            S.cardP = want
        end
        S.cardP = S.cardP:Lerp(want, a)
        U.card.Position = UDim2.fromOffset(S.cardP.X, S.cardP.Y)
        U.card.Visible = true
        local E = Vector2.new(right and S.cardP.X or (S.cardP.X + CW), S.cardP.Y + CH / 2)
        placeLine(U.line, A, E)
        U.dotA.Position = UDim2.fromOffset(A.X, A.Y)
        U.dotE.Position = UDim2.fromOffset(E.X, E.Y)
        U.dotA.Visible = true
        U.dotE.Visible = true

        -- text
        if S.typing then
            local n = math.floor((now - S.typeT0) * 40)
            if n >= #U.cName.Text then
                S.typing = false
                pcall(function() U.cName.MaxVisibleGraphemes = -1 end)
            else
                pcall(function() U.cName.MaxVisibleGraphemes = n end)
            end
        end
        if slow then
            U.cClass.Text = string.format("%s  |  %.1f studs", target.ClassName, S.dist)
            U.cInfo.Text = flagsText(target)
            U.cLvl.Text = string.format("LEVEL %d/%d    PARENT / CHILD", S.idx, #S.chain)
        end
    end

    ----------------------------------------------------------------
    -- transitions (camera shutter blades)
    ----------------------------------------------------------------
    local function blinds(mid, after, done)
        task.spawn(function()
            local top = new("Frame", {
                Size = UDim2.new(1, 0, 0.5, 1),
                Position = UDim2.new(0, 0, -0.5, -1),
                BackgroundColor3 = BLACK,
                BorderSizePixel = 0,
                ZIndex = 90,
            }, gui)
            local bot = new("Frame", {
                Size = UDim2.new(1, 0, 0.5, 1),
                Position = UDim2.new(0, 0, 1, 0),
                BackgroundColor3 = BLACK,
                BorderSizePixel = 0,
                ZIndex = 90,
            }, gui)
            new("Frame", {
                AnchorPoint = Vector2.new(0, 1),
                Position = UDim2.new(0, 0, 1, 0),
                Size = UDim2.new(1, 0, 0, 2),
                BackgroundColor3 = CY,
                BorderSizePixel = 0,
            }, top)
            new("Frame", {
                Size = UDim2.new(1, 0, 0, 2),
                BackgroundColor3 = CY,
                BorderSizePixel = 0,
            }, bot)
            local cinfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            TweenService:Create(top, cinfo, { Position = UDim2.new(0, 0, 0, 0) }):Play()
            TweenService:Create(bot, cinfo, { Position = UDim2.new(0, 0, 0.5, 0) }):Play()
            task.wait(0.26)
            if mid then pcall(mid) end
            task.wait(0.08)
            local oinfo = TweenInfo.new(0.42, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            TweenService:Create(top, oinfo, { Position = UDim2.new(0, 0, -0.5, -1) }):Play()
            TweenService:Create(bot, oinfo, { Position = UDim2.new(0, 0, 1, 0) }):Play()
            if after then pcall(after) end
            task.wait(0.46)
            pcall(function() top:Destroy() end)
            pcall(function() bot:Destroy() end)
            if done then pcall(done) end
        end)
    end

    local function teardown(pick)
        for _, tw in ipairs(S.tweens) do pcall(function() tw:Cancel() end) end
        S.tweens = {}
        if U.hl then pcall(function() U.hl:Destroy() end) end
        if U.root then pcall(function() U.root:Destroy() end) end
        for k in pairs(U) do U[k] = nil end
        leaveFirstPerson()
        showDexGui(pick ~= nil and pick.Parent ~= nil)
    end

    startScan = function()
        if S.active or S.lock or not alive then return end
        if not workspace.CurrentCamera then
            toast("Camera not found")
            return
        end
        S.lock = true
        blinds(function()
            if not alive then return end
            local ok, err = pcall(function()
                hideDexGui()
                enterFirstPerson()
                buildUi()
                N.phase, N.token = "idle", N.token + 1
                N.all, N.parts, N.models, N.modelOf, N.view, N.sel = {}, {}, {}, {}, {}, nil
                S.frozen = nil
                S.target, S.sticky, S.chain, S.idx = nil, nil, {}, 1
                S.boxInit, S.cardInit, S.locked, S.busy, S.typing = false, false, false, false, false
                S.acc, S.warned = 0, false
                S.active = true
                env.__ZeroDex_SCANNING = true
                paintMode()
                if S.mode == "snap" then setMode("snap", true) end
                S.conns[#S.conns + 1] = UIS.InputBegan:Connect(function(input, gp)
                    if not S.active or gp or S.lock then return end
                    local kc = input.KeyCode
                    if kc == Enum.KeyCode.Q or kc == Enum.KeyCode.X then
                        stopScan(nil)
                    elseif kc == Enum.KeyCode.G then
                        toggleSkip()
                    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                        capture()
                    end
                end)
                S.conns[#S.conns + 1] = UIS.InputChanged:Connect(function(input)
                    if S.active and not S.lock and input.UserInputType == Enum.UserInputType.MouseWheel then
                        stepLevel(input.Position.Z > 0 and 1 or -1)
                    end
                end)
                S.conns[#S.conns + 1] = RunService.RenderStepped:Connect(function(dt)
                    local ok2, err2 = pcall(onFrame, dt)
                    if not ok2 and not S.warned then
                        S.warned = true
                        warn("[ZeroDex] Scan: " .. tostring(err2))
                    end
                end)
            end)
            if not ok then
                warn("[ZeroDex] Scan failed to start: " .. tostring(err))
                S.active = false
                env.__ZeroDex_SCANNING = nil
                for _, c in ipairs(S.conns) do pcall(function() c:Disconnect() end) end
                S.conns = {}
                pcall(teardown, nil)
            end
        end, function()
            -- blades are opening: play the intro
            if S.active and U.vf then
                TweenService:Create(U.vf,
                    TweenInfo.new(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                    { Size = U.vfSize }):Play()
                TweenService:Create(U.ret,
                    TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                    { Size = UDim2.new(0, 96, 0, 96) }):Play()
            end
        end, function()
            S.lock = false
        end)
    end

    stopScan = function(pick, instant)
        if not S.active then return end
        if S.lock and not instant then return end
        S.active = false
        S.busy = false
        N.token = N.token + 1
        N.phase = "idle"
        env.__ZeroDex_SCANNING = nil
        for _, c in ipairs(S.conns) do pcall(function() c:Disconnect() end) end
        S.conns = {}
        if instant then
            teardown(pick)
            return
        end
        S.lock = true
        blinds(function()
            teardown(pick)
        end, function()
            -- blades are opening: slide Dex in and navigate to the picked object
            if pick and pick.Parent then
                dockOpen = true
                layoutDock(true)
                setSelected(pick)
                reveal(pick)
                toast("Picked: " .. pick.Name)
            end
        end, function()
            S.lock = false
        end)
    end

    capture = function()
        if not S.active or S.busy or S.lock then return end
        if S.mode == "snap" then return snapCapture() end
        local inst = S.target
        if not inst or not inst.Parent then
            U.status.Text = "NO TARGET - AIM AT AN OBJECT"
            U.status.TextColor3 = AM
            return
        end
        S.busy = true
        S.typing = false
        pcall(function() U.cName.MaxVisibleGraphemes = -1 end)
        tint(U.boxBr, GR)
        U.boxFill.BackgroundColor3 = GR
        U.scanBar.BackgroundColor3 = GR
        U.cardStroke.Color = GR
        U.cardBar.BackgroundColor3 = GR
        U.line.BackgroundColor3 = GR
        U.dotA.BackgroundColor3 = GR
        U.dotE.BackgroundColor3 = GR
        U.shStroke.Color = GR
        U.status.Text = "CAPTURED"
        U.status.TextColor3 = GR
        U.hint.Text = ""
        U.cLvl.Text = "SENDING TO EXPLORER..."
        if U.hl then
            pcall(function()
                U.hl.FillColor = GR
                U.hl.OutlineColor = GR
            end)
        end
        U.flash.BackgroundTransparency = 0.05
        TweenService:Create(U.flash,
            TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { BackgroundTransparency = 1 }):Play()
        local core = U.shCore
        core.Size = UDim2.new(0, 42, 0, 42)
        TweenService:Create(core,
            TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { Size = UDim2.new(0, 54, 0, 54) }):Play()
        ping(GR)
        task.delay(0.6, function()
            if S.active and S.busy then stopScan(inst) end
        end)
    end

    ----------------------------------------------------------------
    -- entry points
    ----------------------------------------------------------------
    local function toggle()
        if S.lock then return end
        if S.active then stopScan(nil) else startScan() end
    end

    track(topBtn.Activated:Connect(toggle))
    tile(0, 3, "Scan Camera", "scan", toggle)

    -- Unload Dex while scanning: put the camera back immediately
    track({ Disconnect = function()
        if S.active then stopScan(nil, true) end
        env.__ZeroDex_SCANNING = nil
    end })
end, function(e)
    warn("[ZeroDex] Scan Camera failed to load: " .. tostring(e))
end)

xpcall(function()
    local RunService = game:GetService("RunService")

    local CY = Color3.fromRGB(0, 224, 255)
    local GR = Color3.fromRGB(70, 255, 150)
    local AM = Color3.fromRGB(255, 196, 70)
    local VI = Color3.fromRGB(170, 120, 255)
    local INK = Color3.fromRGB(6, 12, 18)
    local BTN = Color3.fromRGB(16, 34, 48)
    local GRY = Color3.fromRGB(150, 165, 175)
    local HUDF = Enum.Font.Code
    local BOLDF = Enum.Font.GothamBold
    local ROWS_MAX = 40
    local OUTLINES_MAX = 300
    local HEAD_PX = 26
    local BTN_H = 26
    local LIST_TOP = 78
    local LIST_BOTTOM = 96

    local okCore, CoreGuiSvc = pcall(function() return game:GetService("CoreGui") end)
    if not okCore then CoreGuiSvc = nil end

    local G = {
        active = false,
        locked = false,
        pressed = false,
        hover = false,
        dirty = false,
        hoverOn = not IS_MOBILE,
        skipClear = true,
        showAll = false,
        useCore = false,
        minimized = false,
        warned = false,
        target = nil,
        chain = {},
        idx = 1,
        layers = {},
        lastX = -1,
        lastY = -1,
        acc = 0,
        allAcc = 0,
        count = 0,
        conns = {},
        mirrors = {},
        ours = {},
        pool = {},
        prev = nil,
    }
    G.ours[gui] = true
    local U = {}
    local stop, start, setTarget

    local function vps()
        local cam = workspace.CurrentCamera
        return (cam and cam.ViewportSize) or Vector2.new(1280, 720)
    end

    local function isOurs(o)
        local sg = o:FindFirstAncestorWhichIsA("ScreenGui")
        return sg ~= nil and G.ours[sg] == true
    end

    local function mirrorFor(sg)
        local ignore, ins = false, nil
        pcall(function() ignore = sg.IgnoreGuiInset end)
        pcall(function() ins = sg.ScreenInsets end)
        local key = tostring(ignore) .. "|" .. tostring(ins)
        local m = G.mirrors[key]
        if m and m.gui.Parent and m.root.Parent then return m.root end
        local g = Instance.new("ScreenGui")
        g.Name = "ZeroDex_gs" .. tostring(math.random(1000, 9999))
        g.ResetOnSpawn = false
        g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        g.DisplayOrder = 999998
        g.IgnoreGuiInset = ignore
        if ins ~= nil then pcall(function() g.ScreenInsets = ins end) end
        pcall(function()
            if env.syn and env.syn.protect_gui then env.syn.protect_gui(g) end
        end)
        local okP = pcall(function() g.Parent = gui.Parent end)
        if not okP or not g.Parent then
            g.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
        G.ours[g] = true
        local root = new("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Active = false,
        }, g)
        G.mirrors[key] = { gui = g, root = root }
        G.allAcc = 0.45
        return root
    end

    local function clearMirrors()
        for k, m in pairs(G.mirrors) do
            pcall(function() m.gui:Destroy() end)
            G.ours[m.gui] = nil
            G.mirrors[k] = nil
        end
        G.pool = {}
        U.box, U.tag = nil, nil
    end

    local function painted(o)
        if o.BackgroundTransparency < 1 then return true end
        if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then
            if o.Text ~= "" and o.TextTransparency < 1 then return true end
        end
        if o:IsA("ImageLabel") or o:IsA("ImageButton") then
            if o.Image ~= "" and o.ImageTransparency < 1 then return true end
        end
        if o:IsA("ViewportFrame") or o:IsA("VideoFrame") then return true end
        if o:FindFirstChildWhichIsA("UIStroke") then return true end
        return false
    end

    local function shown(o)
        local sz = o.AbsoluteSize
        if sz.X < 1 or sz.Y < 1 then return false end
        local cur = o
        while cur do
            if cur:IsA("GuiObject") then
                if not cur.Visible then return false end
            elseif cur:IsA("LayerCollector") then
                if cur:IsA("ScreenGui") then return cur.Enabled end
                return false
            end
            cur = cur.Parent
        end
        return false
    end

    local function colorFor(o)
        if o:IsA("GuiButton") then return GR end
        if o:IsA("TextLabel") or o:IsA("TextBox") then return AM end
        if o:IsA("ImageLabel") then return CY end
        return GRY
    end

    local function collect(x, y)
        local out, seen = {}, {}
        local function add(src)
            local ok, res = pcall(function() return src:GetGuiObjectsAtPosition(x, y) end)
            if not ok or type(res) ~= "table" then return end
            for _, o in ipairs(res) do
                if not seen[o] and not isOurs(o) then
                    seen[o] = true
                    out[#out + 1] = o
                end
            end
        end
        if G.useCore and CoreGuiSvc then add(CoreGuiSvc) end
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if pg then add(pg) end
        return out
    end

    local function sameList(a, b)
        if #a ~= #b then return false end
        for i = 1, #a do
            if a[i] ~= b[i] then return false end
        end
        return true
    end

    local function paintHeader()
        if not U.title then return end
        local s = "GUI SCAN"
        if not IS_MOBILE then s = s .. (G.locked and "  LOCKED" or "  LIVE") end
        if G.showAll then s = s .. "  " .. G.count end
        U.title.Text = s
    end

    local function paintToggles()
        local function paint(b, label, on)
            if not b then return end
            b.Text = label .. (on and ": ON" or ": OFF")
            b.TextColor3 = on and GR or GRY
        end
        paint(U.skipBtn, "SKIP", G.skipClear)
        paint(U.allBtn, "ALL", G.showAll)
        if U.coreBtn then
            if CoreGuiSvc then
                paint(U.coreBtn, "CORE", G.useCore)
            else
                U.coreBtn.Text = "CORE: N/A"
                U.coreBtn.TextColor3 = GRY
            end
        end
    end

    local function paintRows()
        for _, r in ipairs(U.rows or {}) do
            local sel = (r.obj == G.target)
            r.btn.BackgroundColor3 = sel and VI or BTN
            r.btn.BackgroundTransparency = sel and 0.3 or 0.2
            r.btn.TextColor3 = sel and WHITE or colorFor(r.obj)
        end
    end

    local function pathShort(o)
        local ok, s = pcall(function() return o:GetFullName() end)
        s = ok and s or o.Name
        if #s > 44 then s = "..." .. s:sub(-41) end
        return s
    end

    local function infoText()
        local o = G.target
        if not o or not o.Parent then
            if IS_MOBILE then
                return "Tap any GUI element on the screen.\nDrag to fine-tune the point."
            end
            return "Hover a GUI element, click to lock.\nRight-click / R = live hover again.\nScroll = parent / child."
        end
        local ap, sz = o.AbsolutePosition, o.AbsoluteSize
        local lines = {}
        lines[1] = o.Name .. "  [" .. o.ClassName .. "]"
        lines[2] = "Pos " .. math.floor(ap.X + 0.5) .. ", " .. math.floor(ap.Y + 0.5)
            .. "   Size " .. math.floor(sz.X + 0.5) .. " x " .. math.floor(sz.Y + 0.5)
        local l3 = "Level " .. G.idx .. "/" .. #G.chain
        pcall(function()
            l3 = l3 .. "   Z " .. o.ZIndex .. "   Alpha " .. fmtNum(o.BackgroundTransparency)
        end)
        lines[3] = l3
        local l4 = ""
        pcall(function()
            if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then
                l4 = 'Text "' .. (o.Text:gsub("%s+", " ")):sub(1, 36) .. '"'
            elseif o:IsA("ImageLabel") or o:IsA("ImageButton") then
                l4 = "Image " .. tostring(o.Image):sub(1, 36)
            end
        end)
        lines[4] = l4
        lines[5] = pathShort(o)
        return table.concat(lines, "\n")
    end

    local function updateInfo()
        if U.info then U.info.Text = infoText() end
    end

    local function rebuildRows()
        for _, r in ipairs(U.rows or {}) do
            pcall(function() r.btn:Destroy() end)
        end
        U.rows = {}
        if not U.list then return end
        for i, o in ipairs(G.layers) do
            if i > ROWS_MAX then break end
            local b = new("TextButton", {
                Text = i .. "  " .. o.ClassName .. "  " .. o.Name,
                Size = UDim2.new(1, -6, 0, 18),
                BackgroundColor3 = BTN,
                BackgroundTransparency = 0.2,
                TextColor3 = colorFor(o),
                Font = HUDF,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                BorderSizePixel = 0,
                LayoutOrder = i,
            }, U.list)
            new("UIPadding", { PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 4) }, b)
            b.Activated:Connect(function()
                if not G.active then return end
                G.locked = true
                setTarget(o)
                paintHeader()
            end)
            U.rows[#U.rows + 1] = { btn = b, obj = o }
        end
        paintRows()
    end

    setTarget = function(o, keepChain)
        G.target = o
        if not keepChain then
            local chain = {}
            local cur = o
            while cur and cur:IsA("GuiObject") do
                chain[#chain + 1] = cur
                cur = cur.Parent
            end
            G.chain = chain
            G.idx = 1
        end
        paintRows()
        updateInfo()
    end

    local function step(dir)
        if not G.target then return end
        local ni = G.idx + dir
        if ni < 1 or ni > #G.chain then
            toast(dir > 0 and "Already the top GUI object" or "Already the deepest GUI object")
            return
        end
        G.idx = ni
        G.locked = true
        setTarget(G.chain[ni], true)
        paintHeader()
    end

    local function sample()
        local x, y = Mouse.X, Mouse.Y
        if not G.dirty and x == G.lastX and y == G.lastY then return end
        G.lastX, G.lastY, G.dirty = x, y, false
        local all = collect(x, y)
        local list = all
        if G.skipClear then
            local f = {}
            for _, o in ipairs(all) do
                if painted(o) then f[#f + 1] = o end
            end
            if #f > 0 then list = f end
        end
        if not sameList(list, G.layers) then
            G.layers = list
            rebuildRows()
        end
        local top = list[1]
        if top ~= G.target then setTarget(top) end
    end

    local function updateBox()
        local o = G.target
        if o and not o.Parent then
            setTarget(nil)
            o = nil
        end
        local sg = o and o:FindFirstAncestorWhichIsA("ScreenGui")
        if not (o and sg) then
            if U.box then U.box.Visible = false end
            if U.tag then U.tag.Visible = false end
            return
        end
        local root = mirrorFor(sg)
        if not U.box then
            U.box = new("Frame", {
                BackgroundColor3 = CY,
                BackgroundTransparency = 0.85,
                BorderSizePixel = 0,
                Active = false,
                ZIndex = 5,
            })
            new("UIStroke", { Color = CY, Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, U.box)
            U.tag = new("TextLabel", {
                BackgroundColor3 = CY,
                BackgroundTransparency = 0.1,
                TextColor3 = INK,
                Font = HUDF,
                TextSize = 12,
                BorderSizePixel = 0,
                ZIndex = 6,
                Size = UDim2.fromOffset(0, 16),
                AutomaticSize = Enum.AutomaticSize.X,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            new("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) }, U.tag)
        end
        if U.box.Parent ~= root then
            U.box.Parent = root
            U.tag.Parent = root
        end
        local ap, sz, rp = o.AbsolutePosition, o.AbsoluteSize, root.AbsolutePosition
        local x, y = ap.X - rp.X, ap.Y - rp.Y
        U.box.Position = UDim2.fromOffset(x, y)
        U.box.Size = UDim2.fromOffset(sz.X, sz.Y)
        pcall(function() U.box.Rotation = o.AbsoluteRotation end)
        U.box.Visible = true
        U.tag.Text = o.Name .. "  [" .. o.ClassName .. "]"
        local ty = y - 17
        if ty < 0 then ty = y + 2 end
        U.tag.Position = UDim2.fromOffset(math.max(0, x), ty)
        U.tag.Visible = true
    end

    local function hideOutlines()
        for _, p in ipairs(G.pool) do p.f.Visible = false end
        G.count = 0
        paintHeader()
    end

    local function drawAll()
        local sources = {}
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if pg then sources[#sources + 1] = pg end
        if G.useCore and CoreGuiSvc then sources[#sources + 1] = CoreGuiSvc end
        local v = vps()
        local n = 0
        local full = false
        for _, src in ipairs(sources) do
            local okK, top = pcall(function() return src:GetChildren() end)
            if okK then
                for _, sg in ipairs(top) do
                    if full then break end
                    if sg:IsA("ScreenGui") and sg.Enabled and not G.ours[sg] then
                        local root = mirrorFor(sg)
                        local rp = root.AbsolutePosition
                        local okD, desc = pcall(function() return sg:GetDescendants() end)
                        if okD then
                            for _, o in ipairs(desc) do
                                if o:IsA("GuiObject") and shown(o) and (not G.skipClear or painted(o)) then
                                    local ap, sz = o.AbsolutePosition, o.AbsoluteSize
                                    if ap.X < v.X + 80 and ap.Y < v.Y + 80 and ap.X + sz.X > -80 and ap.Y + sz.Y > -80 then
                                        n = n + 1
                                        local p = G.pool[n]
                                        if not p then
                                            local f = new("Frame", {
                                                BackgroundTransparency = 1,
                                                BorderSizePixel = 0,
                                                Active = false,
                                                ZIndex = 1,
                                                Visible = false,
                                            })
                                            local s = new("UIStroke", {
                                                Thickness = 1,
                                                Transparency = 0.4,
                                                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                                            }, f)
                                            p = { f = f, s = s }
                                            G.pool[n] = p
                                        end
                                        if p.f.Parent ~= root then p.f.Parent = root end
                                        p.f.Position = UDim2.fromOffset(ap.X - rp.X, ap.Y - rp.Y)
                                        p.f.Size = UDim2.fromOffset(sz.X, sz.Y)
                                        pcall(function() p.f.Rotation = o.AbsoluteRotation end)
                                        p.s.Color = colorFor(o)
                                        p.f.Visible = true
                                        if n >= OUTLINES_MAX then
                                            full = true
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        for i = n + 1, #G.pool do G.pool[i].f.Visible = false end
        G.count = n
        paintHeader()
    end

    local function onFrame(dt)
        if not G.active then return end
        if G.pressed or G.dirty or (G.hoverOn and G.hover and not G.locked) then sample() end
        updateBox()
        G.acc = G.acc + dt
        if G.acc >= 0.3 then
            G.acc = 0
            updateInfo()
        end
        if G.showAll then
            G.allAcc = G.allAcc + dt
            if G.allAcc >= 0.5 then
                G.allAcc = 0
                drawAll()
            end
        end
    end

    local function toggleSkip()
        G.skipClear = not G.skipClear
        G.dirty = true
        G.allAcc = 1
        paintToggles()
    end

    local function toggleAll()
        G.showAll = not G.showAll
        G.allAcc = 1
        if not G.showAll then hideOutlines() end
        paintToggles()
        paintHeader()
    end

    local function toggleCore()
        if not CoreGuiSvc then
            toast("CoreGui is not accessible")
            return
        end
        G.useCore = not G.useCore
        G.dirty = true
        G.allAcc = 1
        paintToggles()
    end

    local function doSelect()
        local o = G.target
        if not o or not o.Parent then
            toast("Nothing selected - tap a GUI element first")
            return
        end
        stop(o)
    end

    local function doCopy()
        local o = G.target
        if not o or not o.Parent then
            toast("Nothing selected - tap a GUI element first")
            return
        end
        copy(getPath(o), "GUI path")
    end

    local function build()
        if U.root then return end
        local v = vps()
        local pw = math.floor(math.clamp(v.X * 0.36, 230, 310))
        local ph = math.floor(math.min(math.clamp(v.Y - 24, 250, 340), v.Y - 8))

        U.root = new("Frame", {
            Name = "GuiScan",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = 40,
        }, gui)
        U.overlay = new("TextButton", {
            Text = "",
            AutoButtonColor = false,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = INK,
            BackgroundTransparency = 0.93,
            BorderSizePixel = 0,
            Active = true,
            ZIndex = 1,
        }, U.root)
        U.panel = new("Frame", {
            Position = UDim2.fromOffset(math.max(0, v.X - pw - 8), 8),
            Size = UDim2.fromOffset(pw, ph),
            BackgroundColor3 = INK,
            BackgroundTransparency = 0.08,
            BorderSizePixel = 0,
            Active = true,
            ZIndex = 2,
        }, U.root)
        corner(U.panel, 6)
        stroke(U.panel, CY, 1)

        U.header = new("Frame", {
            Size = UDim2.new(1, 0, 0, HEAD_PX),
            BackgroundColor3 = Color3.fromRGB(12, 26, 38),
            BorderSizePixel = 0,
        }, U.panel)
        corner(U.header, 6)
        U.drag = new("TextButton", {
            Text = "",
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -56, 1, 0),
        }, U.header)
        U.title = new("TextLabel", {
            Text = "GUI SCAN",
            Position = UDim2.new(0, 8, 0, 0),
            Size = UDim2.new(1, -8, 1, 0),
            BackgroundTransparency = 1,
            TextColor3 = CY,
            Font = HUDF,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, U.drag)

        local startPos
        dragDelta(U.drag, function() startPos = U.panel.Position end, function(d)
            local vv = vps()
            local w, h = U.panel.AbsoluteSize.X, U.panel.AbsoluteSize.Y
            local x = math.clamp(startPos.X.Offset + d.X, 0, math.max(0, vv.X - w))
            local y = math.clamp(startPos.Y.Offset + d.Y, 0, math.max(0, vv.Y - h))
            U.panel.Position = UDim2.fromOffset(x, y)
        end)

        local function hbtn(text, xOff, fn)
            local b = new("TextButton", {
                Text = text,
                Position = UDim2.new(1, xOff, 0, 3),
                Size = UDim2.fromOffset(22, 20),
                BackgroundColor3 = BTN,
                TextColor3 = CY,
                Font = BOLDF,
                TextSize = 12,
                BorderSizePixel = 0,
            }, U.header)
            corner(b, 4)
            b.Activated:Connect(fn)
            return b
        end
        U.minBtn = hbtn("-", -52, function()
            G.minimized = not G.minimized
            U.body.Visible = not G.minimized
            U.minBtn.Text = G.minimized and "+" or "-"
            U.panel.Size = UDim2.fromOffset(pw, G.minimized and HEAD_PX or ph)
        end)
        hbtn("X", -26, function() stop(nil) end)

        U.body = new("Frame", {
            Position = UDim2.new(0, 0, 0, HEAD_PX),
            Size = UDim2.new(1, 0, 1, -HEAD_PX),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
        }, U.panel)

        U.info = new("TextLabel", {
            Text = "",
            Position = UDim2.fromOffset(6, 4),
            Size = UDim2.new(1, -12, 0, 70),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(200, 225, 235),
            Font = HUDF,
            TextSize = 11,
            TextWrapped = false,
            ClipsDescendants = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
        }, U.body)

        U.list = new("ScrollingFrame", {
            Position = UDim2.fromOffset(6, LIST_TOP),
            Size = UDim2.new(1, -12, 1, -(LIST_TOP + LIST_BOTTOM)),
            BackgroundColor3 = Color3.fromRGB(4, 10, 15),
            BackgroundTransparency = 0.3,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(),
            ScrollingDirection = Enum.ScrollingDirection.Y,
        }, U.body)
        corner(U.list, 4)
        new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) }, U.list)

        local function mkBtn(text, x, y, w, color, fn)
            local b = new("TextButton", {
                Text = text,
                Position = UDim2.new(0, x, 1, y),
                Size = UDim2.fromOffset(w, BTN_H),
                BackgroundColor3 = BTN,
                TextColor3 = color,
                Font = HUDF,
                TextSize = 12,
                BorderSizePixel = 0,
            }, U.body)
            corner(b, 4)
            stroke(b, color, 1).Transparency = 0.5
            b.Activated:Connect(fn)
            return b
        end

        local inner = pw - 12
        local w2 = math.floor((inner - 4) / 2)
        local w3 = math.floor((inner - 8) / 3)
        local x2 = 6 + w2 + 4
        local r1, r2, r3 = -(BTN_H * 3 + 18), -(BTN_H * 2 + 12), -(BTN_H + 6)

        mkBtn("PARENT", 6, r1, w2, VI, function() step(1) end)
        mkBtn("CHILD", x2, r1, w2, VI, function() step(-1) end)
        mkBtn("SELECT", 6, r2, w2, GR, doSelect)
        mkBtn("COPY PATH", x2, r2, w2, CY, doCopy)
        U.skipBtn = mkBtn("SKIP", 6, r3, w3, GRY, toggleSkip)
        U.allBtn = mkBtn("ALL", 6 + w3 + 4, r3, w3, GRY, toggleAll)
        U.coreBtn = mkBtn("CORE", 6 + (w3 + 4) * 2, r3, w3, GRY, toggleCore)
        paintToggles()
    end

    local function hideDex()
        G.prev = { dockOpen = dockOpen, explorerOn = explorerOn, click = clickSelect }
        clickSelect = false
        pcall(closeCtx)
        popup.Visible = false
        setMenuOpen(false)
        dock.Visible = false
        hideBtn.Visible = false
        tab.Visible = false
        local sb = gui:FindFirstChild("ScanBtn")
        if sb then sb.Visible = false end
    end

    stop = function(pick)
        if not G.active then return end
        G.active = false
        G.pressed = false
        env.__ZeroDex_SCANNING = nil
        for _, c in ipairs(G.conns) do pcall(function() c:Disconnect() end) end
        G.conns = {}
        if U.root then U.root.Visible = false end
        clearMirrors()
        G.target, G.chain, G.idx, G.layers = nil, {}, 1, {}
        rebuildRows()
        if not alive then return end
        local pv = G.prev
        G.prev = nil
        tab.Visible = true
        local sb = gui:FindFirstChild("ScanBtn")
        if sb then sb.Visible = true end
        if pv then clickSelect = pv.click end
        if pick and pick.Parent then
            explorerOn = true
            dockOpen = false
            layoutDock(false)
            dockOpen = true
            layoutDock(true)
            setSelected(pick)
            reveal(pick)
            toast("Picked: " .. pick.Name)
        else
            if pv then
                dockOpen = pv.dockOpen
                explorerOn = pv.explorerOn
            end
            layoutDock(false)
        end
        updateTiles()
    end

    start = function()
        if G.active or not alive then return end
        if env.__ZeroDex_SCANNING then
            toast("Close the other scan first")
            return
        end
        local ok, err = pcall(function()
            build()
            hideDex()
            G.active = true
            env.__ZeroDex_SCANNING = true
            G.target, G.chain, G.idx, G.layers = nil, {}, 1, {}
            G.locked, G.pressed, G.hover, G.dirty = false, false, false, false
            G.lastX, G.lastY, G.acc, G.allAcc, G.count = -1, -1, 0, 1, 0
            G.warned = false
            U.root.Visible = true
            rebuildRows()
            paintToggles()
            paintHeader()
            updateInfo()

            G.conns[#G.conns + 1] = U.overlay.InputBegan:Connect(function(input)
                if not G.active then return end
                local t = input.UserInputType
                if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
                    G.pressed, G.locked, G.dirty = true, true, true
                elseif t == Enum.UserInputType.MouseButton2 then
                    G.locked, G.dirty = false, true
                end
                paintHeader()
            end)
            G.conns[#G.conns + 1] = UIS.InputEnded:Connect(function(input)
                if not G.active then return end
                if isPointer(input.UserInputType) and G.pressed then
                    G.pressed = false
                    G.dirty = true
                end
            end)
            G.conns[#G.conns + 1] = U.overlay.MouseEnter:Connect(function() G.hover = true end)
            G.conns[#G.conns + 1] = U.overlay.MouseLeave:Connect(function() G.hover = false end)
            G.conns[#G.conns + 1] = UIS.InputBegan:Connect(function(input, gp)
                if not G.active or gp then return end
                local kc = input.KeyCode
                if kc == Enum.KeyCode.Q or kc == Enum.KeyCode.X then
                    stop(nil)
                elseif kc == Enum.KeyCode.G then
                    toggleSkip()
                elseif kc == Enum.KeyCode.R then
                    G.locked, G.dirty = false, true
                    paintHeader()
                end
            end)
            G.conns[#G.conns + 1] = UIS.InputChanged:Connect(function(input)
                if G.active and G.hover and input.UserInputType == Enum.UserInputType.MouseWheel then
                    step(input.Position.Z > 0 and 1 or -1)
                end
            end)
            G.conns[#G.conns + 1] = RunService.RenderStepped:Connect(function(dt)
                local ok2, err2 = pcall(onFrame, dt)
                if not ok2 and not G.warned then
                    G.warned = true
                    warn("[ZeroDex] GUI Scan: " .. tostring(err2))
                end
            end)
        end)
        if not ok then
            warn("[ZeroDex] GUI Scan failed to start: " .. tostring(err))
            G.active = true
            stop(nil)
        end
    end

    local function toggle()
        if G.active then stop(nil) else start() end
    end

    local gbtn = new("TextButton", {
        Name = "GuiScanBtn",
        Text = "",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(0, -4, 0, 0),
        Size = UDim2.new(0, IS_MOBILE and 78 or 92, 1, 0),
        BackgroundColor3 = WHITE,
        BorderSizePixel = 0,
        AutoButtonColor = true,
        ZIndex = 31,
    }, tab)
    corner(gbtn, 5)
    new("UIGradient", {
        Color = ColorSequence.new(Color3.fromRGB(150, 95, 240), Color3.fromRGB(80, 60, 190)),
        Rotation = 0,
    }, gbtn)
    do
        local ic = new("Frame", {
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(0, 8, 0.5, -9),
            BackgroundTransparency = 1,
        }, gbtn)
        fr(ic, 0.5, 2, 15, 12.5, WHITE, 0.12)
        fr(ic, 0.5, 2, 15, 3.2, Color3.fromRGB(215, 205, 250), 0.12)
        fr(ic, 2.5, 6.5, 5, 3, Color3.fromRGB(60, 50, 110), 0.25)
        fr(ic, 2.5, 10.5, 11, 2, Color3.fromRGB(60, 50, 110), 0.3)
        local rg = fr(ic, 8, 5.8, 6.5, 4.6, BLACK)
        rg.BackgroundTransparency = 1
        new("UIStroke", { Color = CY, Thickness = 1.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, rg)
        new("TextLabel", {
            Text = "GUI",
            Position = UDim2.new(0, 30, 0, 0),
            Size = UDim2.new(1, -34, 1, 0),
            BackgroundTransparency = 1,
            TextColor3 = WHITE,
            Font = FONTB,
            TextSize = TS,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, gbtn)
    end
    track(gbtn.Activated:Connect(toggle))
    tile(1, 3, "GUI Scan", "gscan", toggle)

    track({ Disconnect = function()
        if G.active then stop(nil) end
        env.__ZeroDex_SCANNING = nil
    end })
end, function(e)
    warn("[ZeroDex] GUI Scan failed to load: " .. tostring(e))
end)


local settingUpdaters = {}
local function sLabel(y, text)
    new("TextLabel", {
        Text = text, Position = UDim2.new(0, 12, 0, y), Size = UDim2.new(0.5, -12, 0, 32),
        BackgroundTransparency = 1, TextColor3 = C.text, Font = FONT, TextSize = TS,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, pageSet)
end
local function sButton(text, pos, size, fn)
    local b = new("TextButton", {
        Text = text, Position = pos, Size = size, BackgroundColor3 = C.btn,
        TextColor3 = C.text, Font = FONTB, TextSize = TS, BorderSizePixel = 0,
    }, pageSet)
    corner(b, 4)
    track(b.Activated:Connect(fn))
    return b
end
local function sToggle(y, label, get, set)
    sLabel(y, label)
    local b
    b = sButton("", UDim2.new(1, -92, 0, y + 2), UDim2.new(0, 80, 0, 28), function()
        set(not get())
        for _, u in ipairs(settingUpdaters) do u() end
    end)
    settingUpdaters[#settingUpdaters + 1] = function()
        local v = get()
        b.Text = v and "On" or "Off"
        b.BackgroundColor3 = v and C.on or C.off
    end
end
local function sStepper(y, label, getText, minus, plus)
    sLabel(y, label)
    local val = new("TextLabel", {
        Position = UDim2.new(1, -136, 0, y + 2), Size = UDim2.new(0, 64, 0, 28),
        BackgroundTransparency = 1, TextColor3 = C.text, Font = FONT, TextSize = TS,
    }, pageSet)
    local function refresh()
        val.Text = getText()
    end
    sButton("-", UDim2.new(1, -172, 0, y + 2), UDim2.new(0, 32, 0, 28), function() minus() refresh() end)
    sButton("+", UDim2.new(1, -44, 0, y + 2), UDim2.new(0, 32, 0, 28), function() plus() refresh() end)
    settingUpdaters[#settingUpdaters + 1] = refresh
end

do
    local sideBtn
    sLabel(8, "Dock side")
    sideBtn = sButton("", UDim2.new(1, -92, 0, 10), UDim2.new(0, 80, 0, 28), function()
        dockSide = (dockSide == "Right") and "Left" or "Right"
        layoutDock()
        for _, u in ipairs(settingUpdaters) do u() end
    end)
    settingUpdaters[#settingUpdaters + 1] = function() sideBtn.Text = dockSide end

    sStepper(44, "Panel width",
        function() return tostring(math.floor(dockW)) end,
        function() dockW = math.max(200, dockW - 20) layoutDock() end,
        function() dockW = math.min(math.max(260, vp.X * 0.6), dockW + 20) layoutDock() end)
    sStepper(80, "Panel height",
        function() return tostring(math.floor(dockH)) end,
        function() dockH = math.max(160, dockH - 30) layoutDock() end,
        function() dockH = math.min(math.max(200, vp.Y - dockTop - 10), dockH + 30) layoutDock() end)
    sStepper(116, "Transparency",
        function() return tostring(math.floor(opacity * 100 + 0.5)) .. "%" end,
        function() opacity = math.max(0, opacity - 0.1) layoutDock() end,
        function() opacity = math.min(0.9, opacity + 0.1) layoutDock() end)
    sToggle(152, "Show class names", function() return showClass end, function(v) showClass = v renderExplorer() end)
    sToggle(188, "Auto refresh", function() return autoRefresh end, function(v) autoRefresh = v end)
    sToggle(224, "Sort A-Z", function() return sortAZ end, function(v) sortAZ = v rebuild() end)
    for _, u in ipairs(settingUpdaters) do u() end
end

new("TextLabel", {
    Text = "ZeroDex " .. VERSION .. "\n\n"
        .. "- Tap a row to select / double-tap or tap > to expand\n"
        .. "- Drag the bar between Explorer and Properties to resize\n"
        .. "- Drag the panel edge to change its width\n"
        .. "- Press the > button beside the panel to hide / < to show again\n"
        .. "- Long-press a row (mobile) / right-click (PC) to open the menu\n"
        .. "- Save Instance: nothing selected = saves the whole game\n"
        .. "- Scan (top button): first-person camera. Aim the reticle at an object, press the shutter (PC: click) to pick it - Dex jumps to it in Explorer\n"
        .. "- Scan keys (PC): click = pick, scroll = parent/child, G = skip clear parts, Q = exit\n"
        .. "- Scan SNAP mode (switch at the bottom-left of the camera): the screen clears, press the shutter = photo + detailed scan of every visible part (even tiny ones). Tap an object in the photo or in the list, then PICK to jump to it in Explorer\n"
        .. "- GUI Scan (top button, left of Dex): tap any on-screen GUI to inspect it. Pick another layer from the list, PARENT / CHILD climbs the hierarchy, SELECT jumps to it in Explorer, COPY PATH copies its path, ALL outlines every visible GUI\n"
        .. "- GUI Scan keys (PC): hover = live, click = lock, right-click / R = live again, scroll = parent / child, G = skip clear, Q = exit\n"
        .. "- Search filters: class:Part name:x prop:Anchored=true attr:x tag:x\n"
        .. (IS_MOBILE and "" or "- RightControl = hide/show panels\n"),
    Position = UDim2.new(0, 12, 0, 8), Size = UDim2.new(1, -24, 1, -16),
    BackgroundTransparency = 1, TextColor3 = C.text, Font = FONT, TextSize = TS,
    TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
}, pageInfo)

track(UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightControl and not env.__ZeroDex_SCANNING then
        setDockOpen(not dockOpen)
    end
end))

task.spawn(function()
    while alive do
        task.wait(0.3)
        pcall(function()
            if dock.Visible then
                if propsDirty then
                    propsDirty = false
                    for _, r in ipairs(propRows) do pcall(r.update) end
                end
                if autoRefresh and dirty and searchQuery == "" and explorerOn
                    and os.clock() - lastBuild >= math.max(0.5, #flat / 8000) then
                    rebuild()
                end
            end
        end)
    end
end)

setPage("main")
layoutDock(false)
rebuild()
setSelected(nil)
task.delay(1.5, function() if alive then renderExplorer() end end)
toast("ZeroDex " .. VERSION .. " loaded")

]=====]
