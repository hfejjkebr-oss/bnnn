--[[
    QuickUI v1.0  |  UI Library แนว macOS (Sidebar + Cards)  |  รองรับ PC / มือถือ

    วิธีใช้ (อัปโหลดไฟล์นี้ขึ้น GitHub raw / pastebin raw แล้ว):
        local UI = loadstring(game:HttpGet("https://.../QuickUI.lua"))()

        local Win = UI:CreateWindow({
            Name       = "ชื่อ Hub ของคุณ v1.0",   -- ชื่อบนหัวหน้าต่าง (เปลี่ยนได้ทุก Hub)
            Subtitle   = nil,                       -- nil = แสดงชื่อแท็บปัจจุบัน
            Icon       = nil,                       -- ข้อความ/emoji บนปุ่มลอย (ค่าเริ่มต้น = ตัวแรกของชื่อ)
            Accent     = Color3.fromRGB(59,130,246),
            ToggleKey  = Enum.KeyCode.RightShift,   -- ปุ่มเปิด/ปิดบน PC
            ToggleButton = nil,                     -- true/false บังคับปุ่มลอย (มือถือแสดงให้อัตโนมัติ)
            Size       = Vector2.new(780,500),
            ConfigName = nil,                       -- ใส่ชื่อ = เปิดระบบเซฟ config
            AutoSave   = true,
            OnClose    = function() end,
        })

        local Tab = Win:AddTab({ Name="Farming", Icon="rbxassetid://123", Category="Auto Farm" })
        local Sec = Tab:AddSection({ Name="Clan", Description="...", Icon="🎖" })  -- ไม่ใส่ Name = การ์ดเปล่า

        Sec:AddToggle  { Name, Description, Default, Flag, Callback(v) }
        Sec:AddNumber  { Name, Description, Default, Min, Max, Step, Flag, Callback(v) }
        Sec:AddSlider  { Name, Description, Default, Min, Max, Step, Flag, Callback(v) }
        Sec:AddDropdown{ Name, Description, Options, Default, Multi, Flag, Callback(v) }
        Sec:AddButton  { Name, Description, ButtonText, Callback }
        Sec:AddInput   { Name, Description, Default, Placeholder, Flag, Callback(text) }
        Sec:AddKeybind { Name, Description, Default(Enum.KeyCode), Flag, Callback(), OnChange(key) }
        Sec:AddLabel   (text)
        Sec:AddCombo   { Name, Description, Default(bool), Modes={"Instant","Hold"}, Mode, Delay, Min, Max, Step, Flag, Callback(enabled, mode, delay) }
                       -- แถวรวม: สวิตช์ + ตัวเลือกโหมด + ตัวเลข (เหมือนแถว Skill Z / Skill X ในรูป)

        ทุก element คืน object: .Value / :Set(v) / .Item   ,  ค่าทั้งหมดอยู่ที่ Win.Flags[Flag].Value
        Win:Notify{Title,Content,Duration}  Win:Show() Win:Hide() Win:Toggle() Win:Destroy()
        Win:SetTitle(t) Win:SetSubtitle(t) Win:SaveConfig() Win:LoadConfig()
]]

local Players          = game:GetService("Players")
local UIS              = game:GetService("UserInputService")
local TS               = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local CoreGui          = game:GetService("CoreGui")
local LP               = Players.LocalPlayer

local Lib = { Version = "1.2.0", Flags = {} }
Lib.Options = Lib.Flags
local Window, Tab, Section = {}, {}, {}
Window.__index, Tab.__index, Section.__index = Window, Tab, Section

local Theme = {
	Window  = Color3.fromRGB(17, 22, 41),
	Sidebar = Color3.fromRGB(22, 28, 50),
	Card    = Color3.fromRGB(27, 34, 61),
	Input   = Color3.fromRGB(16, 21, 39),
	Divider = Color3.fromRGB(38, 46, 79),
	Stroke  = Color3.fromRGB(50, 60, 100),
	Text    = Color3.fromRGB(238, 241, 250),
	Sub     = Color3.fromRGB(190, 197, 218),
	Muted   = Color3.fromRGB(128, 138, 168),
	Off     = Color3.fromRGB(58, 66, 98),
	Hover   = Color3.fromRGB(37, 46, 80),
	Accent  = Color3.fromRGB(59, 130, 246),
}

local FONT, FONT_M, FONT_B = Enum.Font.Gotham, Enum.Font.GothamMedium, Enum.Font.GothamBold
local WHITE = Color3.new(1, 1, 1)

----------------------------------------------------------------- helpers
local function create(class, props, children)
	local o = Instance.new(class)
	local parent
	for k, v in pairs(props or {}) do
		if k == "Parent" then parent = v else o[k] = v end
	end
	for _, c in ipairs(children or {}) do c.Parent = o end
	if parent then o.Parent = parent end
	return o
end

local function corner(o, r) return create("UICorner", { CornerRadius = UDim.new(0, r), Parent = o }) end
local function stroke(o, c, t)
	return create("UIStroke", { Color = c, Thickness = t or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = o })
end
local function tw(o, t, props)
	TS:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function safe(cb, ...)
	if type(cb) ~= "function" then return end
	local args = table.pack(...)
	task.spawn(function()
		local ok, err = pcall(cb, table.unpack(args, 1, args.n))
		if not ok then warn("[QuickUI] callback error: " .. tostring(err)) end
	end)
end

local function snap(v, step, min, max)
	if step and step > 0 then
		local base = min or 0
		v = math.floor((v - base) / step + 0.5) * step + base
	end
	v = tonumber(string.format("%.6f", v))
	if min then v = math.max(min, v) end
	if max then v = math.min(max, v) end
	return v
end

local function isPress(i)
	return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end
local function isMove(i)
	return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch
end

local function makeIcon(parent, icon, size, color)
	if icon == nil or icon == "" then return nil end
	if type(icon) == "number" or tostring(icon):find("rbxasset", 1, true) then
		return create("ImageLabel", {
			BackgroundTransparency = 1, Size = UDim2.fromOffset(size, size), ImageColor3 = color,
			Image = type(icon) == "number" and ("rbxassetid://" .. icon) or icon, Parent = parent,
		})
	end
	if (utf8.len(tostring(icon)) or 99) > 2 then return nil end
	return create("TextLabel", {
		BackgroundTransparency = 1, Size = UDim2.fromOffset(size, size), Text = tostring(icon),
		Font = FONT_B, TextSize = size - 2, TextColor3 = color, Parent = parent,
	})
end

local function clearOld(name)
	local list = {}
	pcall(function() if gethui then table.insert(list, gethui()) end end)
	pcall(function() table.insert(list, CoreGui) end)
	pcall(function() table.insert(list, LP.PlayerGui) end)
	for _, p in ipairs(list) do
		pcall(function()
			local o = p:FindFirstChild(name)
			if o then o:Destroy() end
		end)
	end
end

local function mount(gui)
	pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
	local ok = pcall(function()
		if gethui then gui.Parent = gethui() else error("no gethui") end
	end)
	if ok and gui.Parent then return end
	ok = pcall(function() gui.Parent = CoreGui end)
	if ok and gui.Parent then return end
	gui.Parent = LP:WaitForChild("PlayerGui")
end

----------------------------------------------------------------- window
function Lib:CreateWindow(cfg)
	cfg = cfg or {}
	-- รองรับ config แบบ Rayfield / Orion / Fluent
	cfg.Name = cfg.Name or cfg.Title
	cfg.Subtitle = cfg.Subtitle or cfg.SubTitle
	cfg.ToggleKey = cfg.ToggleKey or cfg.MinimizeKey
	local cs = cfg.ConfigurationSaving
	if type(cs) == "table" and cs.Enabled then
		cfg.ConfigName = cfg.ConfigName or cs.FileName or "config"
		cfg.ConfigFolder = cfg.ConfigFolder or cs.FolderName
	end
	if cfg.SaveConfig and not cfg.ConfigName then cfg.ConfigName = (tostring(cfg.Name or "config"):gsub("[^%w_%-]", "")) end
	local T = {}
	for k, v in pairs(Theme) do T[k] = v end
	if cfg.Accent then T.Accent = cfg.Accent end

	local self = setmetatable({
		T = T, Flags = {}, Name = cfg.Name or "Hub", _conns = {}, _cats = {}, _catN = 0,
		_hist = {}, _hi = 0, _tabs = {}, _sbOpen = true, _big = false, _acc = {},
		ConfigName = cfg.ConfigName, AutoSave = cfg.AutoSave ~= false, _fixedSub = cfg.Subtitle,
	}, Window)
	self.Folder = cfg.ConfigFolder or ("QuickUI/" .. (self.Name:gsub("[^%w_%-]", "")))

	local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
	local size = cfg.Size or (isMobile and Vector2.new(640, 380) or Vector2.new(780, 500))
	if typeof(size) == "UDim2" then size = Vector2.new(size.X.Offset, size.Y.Offset) end
	local baseSize = size
	local SB_W = cfg.TabWidth or 200

	local guiName = "QuickUI_" .. (self.Name:gsub("[^%w_]", ""))
	clearOld(guiName)
	local gui = create("ScreenGui", {
		Name = guiName, ResetOnSpawn = false, IgnoreGuiInset = false, DisplayOrder = 999,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	mount(gui)
	self._gui = gui

	local function track(c) table.insert(self._conns, c) return c end

	-- root
	local root = create("Frame", {
		Name = "Root", AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
		Size = UDim2.fromOffset(size.X, size.Y), BackgroundColor3 = T.Window, BorderSizePixel = 0,
		ClipsDescendants = true, Parent = gui,
	})
	corner(root, 14)
	local rootStroke = stroke(root, WHITE, 1.4)
	local rootGrad = create("UIGradient", { Rotation = 135, Parent = rootStroke })
	local function paintRootStroke()
		rootGrad.Color = ColorSequence.new(T.Accent:Lerp(WHITE, .1), T.Stroke:Lerp(T.Accent, .15), T.Stroke)
	end
	paintRootStroke()
	table.insert(self._acc, paintRootStroke)
	create("UIGradient", { Rotation = 125, Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(196, 205, 232)), Parent = root })
	local scaleObj = create("UIScale", { Parent = root })
	self._root, self._scaleObj = root, scaleObj

	local function updateScale()
		local cam = workspace.CurrentCamera
		local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
		scaleObj.Scale = math.max(0.3, math.min(vp.X * 0.94 / size.X, vp.Y * 0.88 / size.Y, self._uiScale or 1))
	end
	updateScale()
	self._updateScale = updateScale
	if workspace.CurrentCamera then
		track(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale))
	end

	-- drag
	local function drag(handle, target)
		local dragging, startI, startP = false, nil, nil
		track(handle.InputBegan:Connect(function(i)
			if isPress(i) then
				dragging, startI, startP = true, i.Position, target.Position
				local c; c = i.Changed:Connect(function()
					if i.UserInputState == Enum.UserInputState.End then dragging = false; c:Disconnect() end
				end)
			end
		end))
		track(UIS.InputChanged:Connect(function(i)
			if dragging and isMove(i) then
				local d = i.Position - startI
				target.Position = UDim2.new(startP.X.Scale, startP.X.Offset + d.X, startP.Y.Scale, startP.Y.Offset + d.Y)
			end
		end))
	end

	-- sidebar
	local sidebar = create("Frame", {
		Name = "Sidebar", Size = UDim2.new(0, SB_W, 1, 0), BackgroundColor3 = T.Sidebar,
		BorderSizePixel = 0, ClipsDescendants = true, Parent = root,
	})
	create("Frame", {
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.new(0, 1, 1, 0),
		BackgroundColor3 = T.Divider, BorderSizePixel = 0, Parent = sidebar,
	})
	local sbTop = create("Frame", { Size = UDim2.new(1, 0, 0, 52), BackgroundTransparency = 1, Parent = sidebar })
	drag(sbTop, root)

	local tabList = create("ScrollingFrame", {
		Position = UDim2.fromOffset(0, 52), Size = UDim2.new(1, -1, 1, -52), BackgroundTransparency = 1,
		BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = T.Off, CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = sidebar,
	})
	create("UIPadding", {
		PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), Parent = tabList,
	})
	create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = tabList })
	self._tabList = tabList

	-- content + top bar
	local content = create("Frame", {
		Name = "Content", Position = UDim2.new(0, SB_W, 0, 0), Size = UDim2.new(1, -SB_W, 1, 0),
		BackgroundTransparency = 1, ClipsDescendants = true, Parent = root,
	})
	local top = create("Frame", { Size = UDim2.new(1, 0, 0, 52), BackgroundTransparency = 1, Parent = content })
	create("Frame", {
		AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = T.Divider, BorderSizePixel = 0, Parent = top,
	})
	drag(top, root)
	local pages = create("Frame", {
		Position = UDim2.fromOffset(0, 52), Size = UDim2.new(1, 0, 1, -52), BackgroundTransparency = 1,
		ClipsDescendants = true, Parent = content,
	})

	local leftGrp = create("Frame", {
		Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -196, 1, 0), BackgroundTransparency = 1,
		ClipsDescendants = true, Parent = top,
	})
	local function navBtn(x, txt)
		return create("TextButton", {
			Position = UDim2.new(0, x, .5, -14), Size = UDim2.fromOffset(26, 28), BackgroundTransparency = 1,
			Text = txt, Font = FONT_B, TextSize = 22, TextColor3 = T.Sub, AutoButtonColor = false, Parent = leftGrp,
		})
	end
	local sbBtn = create("TextButton", {
		Position = UDim2.new(0, 0, .5, -14), Size = UDim2.fromOffset(28, 28), BackgroundTransparency = 1,
		Text = "", AutoButtonColor = false, Parent = leftGrp,
	})
	local ico = create("Frame", {
		AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(16, 12),
		BackgroundTransparency = 1, Parent = sbBtn,
	})
	corner(ico, 3); stroke(ico, T.Sub, 1.5)
	create("Frame", { Position = UDim2.fromOffset(5, 0), Size = UDim2.new(0, 1, 1, 0), BackgroundColor3 = T.Sub, BorderSizePixel = 0, Parent = ico })
	local backBtn, fwdBtn = navBtn(32, "‹"), navBtn(58, "›")

	local titleLbl = create("TextLabel", {
		Position = UDim2.fromOffset(96, 9), Size = UDim2.new(1, -96, 0, 18), BackgroundTransparency = 1,
		Text = self.Name, Font = FONT_B, TextSize = 14, TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = leftGrp,
	})
	local subLbl = create("TextLabel", {
		Position = UDim2.fromOffset(96, 27), Size = UDim2.new(1, -96, 0, 12), BackgroundTransparency = 1,
		Text = self._fixedSub or "", Font = FONT, TextSize = 10, TextColor3 = T.Muted,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = leftGrp,
	})
	self._titleLbl, self._subLbl = titleLbl, subLbl

	-- search
	local sBox = create("Frame", {
		AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -14, .5, 0), Size = UDim2.fromOffset(164, 30),
		BackgroundColor3 = T.Input, BorderSizePixel = 0, Parent = top,
	})
	corner(sBox, 8)
	local sStroke = stroke(sBox, T.Stroke, 1)
	do -- ไอคอนแว่นขยาย (วาดด้วย Frame ไม่พึ่งฟอนต์)
		local mg = create("Frame", { Position = UDim2.fromOffset(11, 9), Size = UDim2.fromOffset(10, 10), BackgroundTransparency = 1, Parent = sBox })
		corner(mg, 5); stroke(mg, T.Muted, 1.4)
		create("Frame", {
			AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromOffset(22, 21), Size = UDim2.fromOffset(6, 2), Rotation = 45,
			BackgroundColor3 = T.Muted, BorderSizePixel = 0, Parent = sBox,
		})
	end
	local search = create("TextBox", {
		Position = UDim2.fromOffset(30, 0), Size = UDim2.new(1, -36, 1, 0), BackgroundTransparency = 1, Text = "",
		PlaceholderText = "Search", PlaceholderColor3 = T.Muted, ClearTextOnFocus = false, Font = FONT, TextSize = 12,
		TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = sBox,
	})
	self._search = search
	search.Focused:Connect(function() tw(sStroke, .15, { Color = T.Accent }) end)
	search.FocusLost:Connect(function() tw(sStroke, .15, { Color = T.Stroke }) end)

	-- traffic lights
	local lights = create("Frame", {
		Position = UDim2.fromOffset(16, 20), Size = UDim2.fromOffset(60, 12), BackgroundTransparency = 1, ZIndex = 10, Parent = root,
	})
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = lights,
	})
	local function dot(color, order)
		local b = create("TextButton", {
			Size = UDim2.fromOffset(12, 12), BackgroundColor3 = color, Text = "", AutoButtonColor = false,
			LayoutOrder = order, ZIndex = 11, Parent = lights,
		})
		corner(b, 6)
		return b
	end
	local red, yellow, green = dot(Color3.fromRGB(255, 95, 87), 1), dot(Color3.fromRGB(254, 188, 46), 2), dot(Color3.fromRGB(40, 200, 64), 3)

	-- floating toggle button (มือถือ / minimize)
	local alwaysFB = cfg.ToggleButton
	if alwaysFB == nil then alwaysFB = isMobile end
	local fb = create("TextButton", {
		Name = "FloatButton", Position = UDim2.new(0, 18, .35, 0), Size = UDim2.fromOffset(46, 46), BackgroundColor3 = T.Accent,
		Text = tostring(cfg.Icon or self.Name:sub(1, 1)), Font = FONT_B, TextSize = 20, TextColor3 = WHITE,
		AutoButtonColor = false, Visible = alwaysFB, ZIndex = 50, Parent = gui,
	})
	corner(fb, 23); stroke(fb, T.Stroke, 1)
	table.insert(self._acc, function() fb.BackgroundColor3 = T.Accent end)
	local function refreshFB() fb.Visible = alwaysFB or not root.Visible end
	do
		local dragging, moved, start, startPos = false, false, nil, nil
		track(fb.InputBegan:Connect(function(i)
			if isPress(i) then dragging, moved, start, startPos = true, false, i.Position, fb.Position end
		end))
		track(UIS.InputChanged:Connect(function(i)
			if dragging and isMove(i) then
				local d = i.Position - start
				if d.Magnitude > 6 then moved = true end
				if moved then fb.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end
			end
		end))
		track(UIS.InputEnded:Connect(function(i)
			if dragging and isPress(i) then
				dragging = false
				if not moved then self:Toggle() end
			end
		end))
	end

	-- toasts
	self._toasts = create("Frame", {
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 16), Size = UDim2.new(0, 280, 1, -32),
		BackgroundTransparency = 1, ZIndex = 100, Parent = gui,
	})
	create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = self._toasts })

	self._pages = pages

	-- layout / nav
	local function layout()
		local w = self._sbOpen and SB_W or 0
		tw(sidebar, .2, { Size = UDim2.new(0, w, 1, 0) })
		tw(content, .2, { Position = UDim2.new(0, w, 0, 0), Size = UDim2.new(1, -w, 1, 0) })
		tw(leftGrp, .2, { Position = UDim2.fromOffset(self._sbOpen and 12 or 84, 0) })
	end
	sbBtn.MouseButton1Click:Connect(function() self._sbOpen = not self._sbOpen; layout() end)

	function self:_nav()
		backBtn.TextColor3 = self._hi > 1 and T.Sub or T.Off
		fwdBtn.TextColor3 = self._hi < #self._hist and T.Sub or T.Off
	end
	backBtn.MouseButton1Click:Connect(function()
		if self._hi > 1 then self._hi = self._hi - 1; self:_select(self._hist[self._hi], true) end
	end)
	fwdBtn.MouseButton1Click:Connect(function()
		if self._hi < #self._hist then self._hi = self._hi + 1; self:_select(self._hist[self._hi], true) end
	end)

	-- search filter
	local function applyFilter(tab, q)
		if not tab then return end
		q = (q or ""):lower()
		for _, e in ipairs(tab._elems) do
			e.item.Visible = (q == "") or (e.key:find(q, 1, true) ~= nil)
		end
		for _, s in ipairs(tab._sections) do
			local any = false
			for _, e in ipairs(s._elems) do if e.item.Visible then any = true break end end
			s.root.Visible = (q == "") or any
		end
	end
	self._applyFilter = applyFilter
	search:GetPropertyChangedSignal("Text"):Connect(function() applyFilter(self._active, search.Text) end)

	-- window buttons
	red.MouseButton1Click:Connect(function() self:Destroy() end)
	yellow.MouseButton1Click:Connect(function() self:Hide() end)
	green.MouseButton1Click:Connect(function()
		self._big = not self._big
		size = self._big and baseSize * 1.3 or baseSize
		tw(root, .2, { Size = UDim2.fromOffset(size.X, size.Y) })
		updateScale()
	end)

	-- toggle key
	self._key = cfg.ToggleKey or Enum.KeyCode.RightShift
	track(UIS.InputBegan:Connect(function(i, gp)
		if not gp and i.KeyCode == self._key then self:Toggle() end
	end))

	self._refreshFB = refreshFB
	self._onClose = cfg.OnClose
	self:_nav()
	Lib._last = self
	Lib.Unloaded = false
	return self
end

function Window:SetTitle(t) self.Name = t; self._titleLbl.Text = t end
function Window:SetSubtitle(t) self._fixedSub = t; self._subLbl.Text = t or (self._active and self._active.Name or "") end
function Window:Show()
	local sc = self._scaleObj
	self._updateScale()
	local target = sc.Scale
	self._root.Visible = true; self.Minimized = false; self._refreshFB()
	sc.Scale = target * .93
	TS:Create(sc, TweenInfo.new(.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = target }):Play()
end
function Window:Hide() self._root.Visible = false; self.Minimized = true; self._refreshFB() end
function Window:Minimize() self:Toggle() end

function Window:SetAccent(c)
	self.T.Accent = c
	for _, f in ipairs(self._acc) do pcall(f) end
end
function Window:SetUIScale(v) self._uiScale = v; self._updateScale() end

function Window:Dialog(o)
	o = o or {}
	local T = self.T
	local overlay = create("TextButton", {
		Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = .45, Text = "",
		AutoButtonColor = false, ZIndex = 60, Parent = self._root,
	})
	local card = create("Frame", {
		AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.new(0, 300, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = T.Card, BorderSizePixel = 0, ZIndex = 61, Parent = overlay,
	})
	corner(card, 10); stroke(card, T.Stroke, 1)
	create("UIPadding", { PaddingTop = UDim.new(0, 16), PaddingBottom = UDim.new(0, 16), PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16), Parent = card })
	create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = card })
	create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 18), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = o.Title or "",
		Font = FONT_B, TextSize = 15, TextColor3 = T.Text, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1, Parent = card,
	})
	create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 14), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = o.Content or "",
		Font = FONT, TextSize = 12, TextColor3 = T.Sub, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 2, Parent = card,
	})
	local rowF = create("Frame", { Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, LayoutOrder = 3, Parent = card })
	create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = rowF })
	local btns = o.Buttons or { { Title = "OK" } }
	local n = #btns
	for i, bd in ipairs(btns) do
		local b = create("TextButton", {
			Size = UDim2.new(1 / n, -8 * (n - 1) / n, 1, 0), BackgroundColor3 = i == 1 and T.Accent or T.Hover, Text = bd.Title or "OK",
			Font = FONT_M, TextSize = 12, TextColor3 = WHITE, AutoButtonColor = false, LayoutOrder = i, ZIndex = 62, Parent = rowF,
		})
		corner(b, 6)
		b.MouseButton1Click:Connect(function() overlay:Destroy(); safe(bd.Callback) end)
	end
	return overlay
end
function Window:Toggle() if self._root.Visible then self:Hide() else self:Show() end end

function Window:Destroy()
	for _, c in ipairs(self._conns) do pcall(function() c:Disconnect() end) end
	self._conns = {}
	Lib.Unloaded = true
	if self._gui then self._gui:Destroy() end
	safe(self._onClose)
end

function Window:Notify(o)
	o = o or {}
	local T = self.T
	local t = create("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = T.Card,
		BorderSizePixel = 0, Parent = self._toasts,
	})
	corner(t, 10); stroke(t, T.Accent:Lerp(T.Stroke, .45), 1.2)
	create("UIPadding", {
		PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = t,
	})
	create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = t })
	create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 16), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = o.Title or self.Name,
		Font = FONT_B, TextSize = 13, TextColor3 = T.Text, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1, Parent = t,
	})
	if o.Content then
		create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 14), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = o.Content,
			Font = FONT, TextSize = 12, TextColor3 = T.Sub, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 2, Parent = t,
		})
	end
	if o.SubContent then
		create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 12), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = o.SubContent,
			Font = FONT, TextSize = 11, TextColor3 = T.Muted, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 3, Parent = t,
		})
	end
	task.delay(o.Duration or 4, function() if t.Parent then t:Destroy() end end)
end

----------------------------------------------------------------- config
function Window:_register(flag, obj, o)
	if o then
		obj.SetValue = obj.SetValue or function(s, v) s:Set(v) end
		obj.OnChanged = function(_, f) if o._ls then table.insert(o._ls, f) end end
		setmetatable(obj, { __index = function(t, k)
			if k == "CurrentValue" then return rawget(t, "Value") end
			if k == "CurrentOption" then
				local v = rawget(t, "Value")
				if type(v) == "table" then return v end
				return { v }
			end
		end })
	end
	if flag then self.Flags[flag] = obj; Lib.Flags[flag] = obj end
end

function Window:_changed()
	if not (self.AutoSave and self.ConfigName) or self._loading then return end
	self._saveTok = (self._saveTok or 0) + 1
	local tok = self._saveTok
	task.delay(1, function() if tok == self._saveTok then self:SaveConfig() end end)
end

function Window:SaveConfig(name)
	name = name or self.ConfigName
	if not (name and writefile) then return false end
	local data = {}
	for f, o in pairs(self.Flags) do
		local ok, v = pcall(function() if o.Export then return o:Export() end return o.Value end)
		if ok then data[f] = v end
	end
	return (pcall(function()
		if makefolder and not (isfolder and isfolder(self.Folder)) then
			local parts, path = self.Folder:split("/"), ""
			for _, p in ipairs(parts) do
				path = (path == "" and p) or (path .. "/" .. p)
				if not (isfolder and isfolder(path)) then makefolder(path) end
			end
		end
		writefile(self.Folder .. "/" .. name .. ".json", HttpService:JSONEncode(data))
	end))
end

function Window:LoadConfig(name)
	name = name or self.ConfigName
	if not (name and readfile and isfile) then return false end
	local path = self.Folder .. "/" .. name .. ".json"
	local ok, data = pcall(function()
		if not isfile(path) then return nil end
		return HttpService:JSONDecode(readfile(path))
	end)
	if not ok or type(data) ~= "table" then return false end
	self._loading = true
	for f, v in pairs(data) do
		local o = self.Flags[f]
		if o then pcall(function() if o.Import then o:Import(v) else o:Set(v) end end) end
	end
	self._loading = false
	return true
end

----------------------------------------------------------------- tabs
function Window:_select(tab, fromNav)
	if self._active == tab then return end
	local old = self._active
	if old then
		if self._search.Text ~= "" then self._applyFilter(old, ""); self._search.Text = "" end
		old.Page.Visible = false
		old:_style(false)
	end
	self._active = tab
	tab.Page.Visible = true
	tab:_style(true)
	self._subLbl.Text = self._fixedSub or tab.Name
	if not fromNav then
		for i = #self._hist, self._hi + 1, -1 do self._hist[i] = nil end
		table.insert(self._hist, tab)
		self._hi = #self._hist
	end
	self:_nav()
end

function Window:SelectTab(t)
	if type(t) == "number" then t = self._tabs[t] end
	if type(t) == "string" then
		for _, x in ipairs(self._tabs) do if x.Name == t then t = x break end end
	end
	if type(t) == "table" then self:_select(t) end
end

function Window:AddTab(o)
	if type(o) == "string" then o = { Name = o } end
	o = o or {}
	o.Name = o.Name or o.Title
	local T = self.T
	local catName = o.Category or ""
	local cat = self._cats[catName]
	if not cat then
		if catName ~= "" then self._catN = self._catN + 1 end
		cat = { idx = (catName == "") and 0 or self._catN, n = 0 }
		self._cats[catName] = cat
		if catName ~= "" then
			local lbl = create("TextLabel", {
				BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28), Text = catName, Font = FONT_M, TextSize = 10,
				TextColor3 = T.Muted, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = cat.idx * 1000, Parent = self._tabList,
			})
			create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingTop = UDim.new(0, 10), Parent = lbl })
		end
	end
	cat.n = cat.n + 1

	local tab = setmetatable({ _win = self, Name = o.Name or "Tab", _sections = {}, _elems = {} }, Tab)
	local btn = create("TextButton", {
		Name = tab.Name, Size = UDim2.new(1, 0, 0, 33), BackgroundColor3 = T.Hover, BackgroundTransparency = 1,
		Text = "", AutoButtonColor = false, LayoutOrder = cat.idx * 1000 + cat.n, Parent = self._tabList,
	})
	corner(btn, 8)
	local selGrad = create("UIGradient", {
		Rotation = 0, Enabled = false, Color = ColorSequence.new(WHITE, Color3.fromRGB(190, 208, 255)), Parent = btn,
	})
	local x = 12
	local ic = makeIcon(btn, o.Icon, 16, T.Sub)
	if ic then ic.Position = UDim2.new(0, 10, .5, -8); x = 34 end
	local lbl = create("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.new(0, x, 0, 0), Size = UDim2.new(1, -x - 6, 1, 0), Text = tab.Name,
		Font = FONT_M, TextSize = 13, TextColor3 = T.Sub, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = btn,
	})
	tab.Button = btn
	table.insert(self._acc, function() tab:_style(self._active == tab) end)

	function tab:_style(on)
		selGrad.Enabled = on
		btn.BackgroundColor3 = on and T.Accent or T.Hover
		btn.BackgroundTransparency = on and 0 or 1
		lbl.Font = on and FONT_B or FONT_M
		lbl.TextColor3 = on and WHITE or T.Sub
		if ic then
			if ic:IsA("ImageLabel") then ic.ImageColor3 = on and WHITE or T.Sub else ic.TextColor3 = on and WHITE or T.Sub end
		end
	end
	btn.MouseEnter:Connect(function() if self._active ~= tab then btn.BackgroundTransparency = 0 end end)
	btn.MouseLeave:Connect(function() if self._active ~= tab then btn.BackgroundTransparency = 1 end end)
	btn.MouseButton1Click:Connect(function() self:_select(tab) end)

	local page = create("ScrollingFrame", {
		Name = tab.Name, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
		ScrollBarImageColor3 = T.Off, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y, Visible = false, Parent = self._pages,
	})
	create("UIPadding", {
		PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 16), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), Parent = page,
	})
	create("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder, Parent = page })
	tab.Page = page

	table.insert(self._tabs, tab)
	if not self._active then self:_select(tab) end
	return tab
end

----------------------------------------------------------------- sections
function Tab:AddSection(o)
	if type(o) == "string" then o = { Name = o } end
	o = o or {}
	local T = self._win.T
	local sec = setmetatable({ _win = self._win, _tab = self, _count = 0, _elems = {} }, Section)
	local root = create("Frame", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = #self._sections + 1, Parent = self.Page,
	})
	create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = root })
	if o.Name then
		local h = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 1, Parent = root })
		create("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingTop = UDim.new(0, 4), Parent = h })
		create("UIListLayout", { Padding = UDim.new(0, 1), SortOrder = Enum.SortOrder.LayoutOrder, Parent = h })
		create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 16), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
			Text = (o.Icon and (tostring(o.Icon) .. "  ") or "") .. o.Name, Font = FONT_B, TextSize = 13, TextColor3 = T.Text,
			TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1, Parent = h,
		})
		if o.Description and o.Description ~= "" then
			create("TextLabel", {
				Size = UDim2.new(1, 0, 0, 12), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = o.Description,
				Font = FONT, TextSize = 11, TextColor3 = T.Muted, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 2, Parent = h,
			})
		end
	end
	local card = create("Frame", {
		BackgroundColor3 = T.Card, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		ClipsDescendants = true, LayoutOrder = 2, Parent = root,
	})
	corner(card, 10); stroke(card, T.Divider, 1)
	create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = card })
	sec.root, sec._card = root, card
	table.insert(self._sections, sec)
	return sec
end

function Tab:_default()
	if not self._def then self._def = self:AddSection({}) end
	return self._def
end
for _, m in ipairs({ "AddToggle", "AddNumber", "AddSlider", "AddDropdown", "AddButton", "AddInput", "AddKeybind", "AddLabel", "AddParagraph", "AddTextbox", "AddBind", "AddColorpicker", "AddCombo" }) do
	Tab[m] = function(self, ...)
		local s = self:_default()
		return s[m](s, ...)
	end
end

function Section:_reg(item, name, desc)
	local e = { item = item, key = ((name or "") .. " " .. (desc or "")):lower() }
	table.insert(self._elems, e)
	table.insert(self._tab._elems, e)
end

function Section:_item(name, desc, ctrlW)
	local T = self._win.T
	self._count = self._count + 1
	local item = create("Frame", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = self._count, Parent = self._card,
	})
	create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = item })
	create("Frame", {
		Name = "Div", BackgroundColor3 = T.Divider, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 1),
		LayoutOrder = 0, Visible = self._count > 1, Parent = item,
	})
	local row = create("Frame", {
		Name = "Row", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 1, Parent = item,
	})
	create("UISizeConstraint", { MinSize = Vector2.new(0, 50), Parent = row })
	local left = create("Frame", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -(ctrlW + 40), 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, Parent = row,
	})
	create("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), Parent = left })
	create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = left })
	create("TextLabel", {
		Name = "Title", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), AutomaticSize = Enum.AutomaticSize.Y,
		Text = name or "", Font = FONT_M, TextSize = 13, TextColor3 = T.Text, TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1, Parent = left,
	})
	if desc and desc ~= "" then
		create("TextLabel", {
			Name = "Desc", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 12), AutomaticSize = Enum.AutomaticSize.Y,
			Text = desc, Font = FONT, TextSize = 11, TextColor3 = T.Muted, TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 2, Parent = left,
		})
	end
	local holder = create("Frame", {
		AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -14, .5, 0), Size = UDim2.fromOffset(ctrlW, 28),
		BackgroundTransparency = 1, Parent = row,
	})
	return item, row, holder
end

----------------------------------------------------------------- elements
local function pick(...)
	for i = 1, select("#", ...) do
		local v = select(i, ...)
		if v ~= nil then return v end
	end
end

-- แปลงรูปแบบ argument ของ Rayfield / Orion / Fluent ให้เป็นรูปแบบเดียว
local function norm(a, b)
	local o
	if type(a) == "string" and type(b) == "table" then
		o = b; o.Flag = o.Flag or a; o._style = o._style or "fluent"
	elseif type(a) == "table" then o = a
	else o = {} end
	o._style = o._style or "orion"
	o.Name = pick(o.Name, o.Title)
	o.Description = pick(o.Description, o.Content)
	o.Default = pick(o.Default, o.CurrentValue, o.CurrentOption, o.CurrentKeybind)
	o.Options = pick(o.Options, o.Values)
	o.Placeholder = pick(o.Placeholder, o.PlaceholderText)
	if type(o.Range) == "table" then o.Min, o.Max = o.Range[1], o.Range[2] end
	o.Step = pick(o.Step, o.Increment, o.Rounding and 10 ^ (-o.Rounding))
	if not o._ls then
		o._ls = {}
		local cb = o.Callback
		o._cb = cb
		o.Callback = function(...)
			if type(cb) == "function" then cb(...) end
			for _, f in ipairs(o._ls) do f(...) end
		end
	end
	return o
end

function Section:AddParagraph(a, b)
	local title, content
	if type(a) == "table" then title, content = pick(a.Title, a.Name), pick(a.Content, a.Description) else title, content = a, b end
	local item = self:_item(title, content, 0)
	self:_reg(item, title, content)
	local obj = { Item = item }
	function obj:Set(t, c)
		local tl, dl = item:FindFirstChild("Title", true), item:FindFirstChild("Desc", true)
		if tl and t then tl.Text = t end
		if dl and c then dl.Text = c end
	end
	return obj
end

function Section:AddLabel(text)
	local item = self:_item(text, nil, 0)
	self:_reg(item, text, "")
	local obj = { Item = item }
	obj.Set = function(_, t)
		local lbl = item:FindFirstChild("Title", true)
		if lbl then lbl.Text = t end
	end
	return obj
end

function Section:AddToggle(a, b)
	local o = norm(a, b)
	local win = self._win; local T = win.T
	local item, row, holder = self:_item(o.Name or "Toggle", o.Description, 44)
	local track = create("Frame", {
		AnchorPoint = Vector2.new(1, .5), Position = UDim2.fromScale(1, .5), Size = UDim2.fromOffset(38, 20),
		BackgroundColor3 = T.Off, BorderSizePixel = 0, Parent = holder,
	})
	corner(track, 10)
	local tStroke = stroke(track, T.Stroke, 1)
	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0, .5), Position = UDim2.new(0, 3, .5, 0), Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = WHITE, BorderSizePixel = 0, Parent = track,
	})
	corner(knob, 7)
	local obj = { Value = false, Item = item }
	local function render()
		tw(track, .18, { BackgroundColor3 = obj.Value and T.Accent or T.Off })
		tw(tStroke, .18, { Color = obj.Value and T.Accent:Lerp(WHITE, .3) or T.Stroke })
		tw(knob, .18, { Position = obj.Value and UDim2.new(1, -17, .5, 0) or UDim2.new(0, 3, .5, 0) })
	end
	function obj:Set(v, silent)
		self.Value = v and true or false
		render()
		if not silent then safe(o.Callback, self.Value); win:_changed() end
	end
	local btn = create("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", Parent = row })
	btn.MouseButton1Click:Connect(function() obj:Set(not obj.Value) end)
	table.insert(win._acc, render)
	win:_register(o.Flag, obj, o); self:_reg(item, o.Name, o.Description)
	if o.Default then obj:Set(true, true) end
	return obj
end

function Section:AddButton(a, b)
	local o = norm(a, b)
	local win = self._win; local T = win.T
	local item, row, holder = self:_item(o.Name or "Button", o.Description, 84)
	local b = create("TextButton", {
		AnchorPoint = Vector2.new(1, .5), Position = UDim2.fromScale(1, .5), Size = UDim2.fromOffset(84, 28),
		BackgroundColor3 = T.Accent, Text = o.ButtonText or "Run", Font = FONT_M, TextSize = 12, TextColor3 = WHITE,
		AutoButtonColor = false, Parent = holder,
	})
	corner(b, 6)
	b.MouseEnter:Connect(function() tw(b, .1, { BackgroundColor3 = T.Accent:Lerp(WHITE, .15) }) end)
	b.MouseLeave:Connect(function() tw(b, .1, { BackgroundColor3 = T.Accent }) end)
	b.MouseButton1Click:Connect(function() safe(o.Callback) end)
	table.insert(win._acc, function() b.BackgroundColor3 = T.Accent end)
	self:_reg(item, o.Name, o.Description)
	return { Item = item, Button = b }
end

function Section:AddNumber(a, b)
	local o = norm(a, b)
	local win = self._win; local T = win.T
	local min, max, step = o.Min, o.Max, o.Step or 1
	local item, row, holder = self:_item(o.Name or "Number", o.Description, 78)
	local box = create("Frame", {
		AnchorPoint = Vector2.new(1, .5), Position = UDim2.fromScale(1, .5), Size = UDim2.fromOffset(78, 28),
		BackgroundColor3 = T.Input, BorderSizePixel = 0, Parent = holder,
	})
	corner(box, 6); stroke(box, T.Stroke, 1)
	local tb = create("TextBox", {
		BackgroundTransparency = 1, Size = UDim2.new(1, -20, 1, 0), Text = "", ClearTextOnFocus = false, Font = FONT,
		TextSize = 12, TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Right, Parent = box,
	})
	create("UIPadding", { PaddingRight = UDim.new(0, 4), Parent = tb })
	local function spin(y, txt, delta)
		local b = create("TextButton", {
			Position = UDim2.new(1, -18, y, 0), Size = UDim2.new(0, 18, .5, 0), BackgroundTransparency = 1, Text = txt,
			Font = FONT_B, TextSize = 8, TextColor3 = T.Muted, AutoButtonColor = false, Parent = box,
		})
		b.MouseEnter:Connect(function() b.TextColor3 = T.Text end)
		b.MouseLeave:Connect(function() b.TextColor3 = T.Muted end)
		return b
	end
	local up, down = spin(0, "▲"), spin(.5, "▼")
	local obj = { Value = o.Default or min or 0, Item = item }
	function obj:Set(v, silent)
		v = tonumber(v)
		if not v then tb.Text = tostring(self.Value); return end
		self.Value = snap(v, step, min, max)
		tb.Text = tostring(self.Value)
		if not silent then safe(o.Callback, self.Value); win:_changed() end
	end
	tb.FocusLost:Connect(function() obj:Set(tb.Text) end)
	up.MouseButton1Click:Connect(function() obj:Set(obj.Value + step) end)
	down.MouseButton1Click:Connect(function() obj:Set(obj.Value - step) end)
	obj:Set(obj.Value, true)
	win:_register(o.Flag, obj, o); self:_reg(item, o.Name, o.Description)
	return obj
end

function Section:AddSlider(a, b)
	local o = norm(a, b)
	local win = self._win; local T = win.T
	local min, max, step = o.Min or 0, o.Max or 100, o.Step or 1
	local item, row, holder = self:_item(o.Name or "Slider", o.Description, 190)
	holder.Size = UDim2.fromOffset(190, 28)
	local valLbl = create("TextLabel", {
		AnchorPoint = Vector2.new(1, .5), Position = UDim2.fromScale(1, .5), Size = UDim2.fromOffset(60, 20),
		BackgroundTransparency = 1, Text = "", Font = FONT_M, TextSize = 12, TextColor3 = T.Sub,
		TextXAlignment = Enum.TextXAlignment.Right, Parent = holder,
	})
	local trackF = create("Frame", {
		AnchorPoint = Vector2.new(0, .5), Position = UDim2.fromScale(0, .5), Size = UDim2.new(1, -70, 0, 4),
		BackgroundColor3 = T.Off, BorderSizePixel = 0, Parent = holder,
	})
	corner(trackF, 2)
	local fill = create("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = T.Accent, BorderSizePixel = 0, Parent = trackF })
	corner(fill, 2)
	local knob = create("Frame", {
		AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(1, .5), Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = WHITE, BorderSizePixel = 0, Parent = fill,
	})
	corner(knob, 7)
	local hit = create("TextButton", {
		AnchorPoint = Vector2.new(0, .5), Position = UDim2.fromScale(0, .5), Size = UDim2.new(1, -70, 0, 28),
		BackgroundTransparency = 1, Text = "", Parent = holder,
	})
	local obj = { Value = o.Default or min, Item = item }
	function obj:Set(v, silent)
		v = tonumber(v) or self.Value
		self.Value = snap(v, step, min, max)
		local p = (max > min) and (self.Value - min) / (max - min) or 0
		fill.Size = UDim2.fromScale(math.clamp(p, 0, 1), 1)
		valLbl.Text = tostring(self.Value) .. (o.Suffix or (o.ValueName and (" " .. o.ValueName)) or "")
		if not silent then safe(o.Callback, self.Value); win:_changed() end
	end
	table.insert(win._acc, function() fill.BackgroundColor3 = T.Accent end)
	local dragging = false
	local page = self._tab.Page
	local function fromX(x)
		local w = trackF.AbsoluteSize.X
		if w <= 0 then return end
		obj:Set(min + math.clamp((x - trackF.AbsolutePosition.X) / w, 0, 1) * (max - min))
	end
	hit.InputBegan:Connect(function(i)
		if isPress(i) then dragging = true; page.ScrollingEnabled = false; fromX(i.Position.X) end
	end)
	table.insert(win._conns, UIS.InputChanged:Connect(function(i)
		if dragging and isMove(i) then fromX(i.Position.X) end
	end))
	table.insert(win._conns, UIS.InputEnded:Connect(function(i)
		if dragging and isPress(i) then dragging = false; page.ScrollingEnabled = true end
	end))
	obj:Set(obj.Value, true)
	win:_register(o.Flag, obj, o); self:_reg(item, o.Name, o.Description)
	return obj
end

function Section:AddCombo(a, b)
	local o = norm(a, b)
	local win = self._win; local T = win.T
	local modes = o.Modes or { "Instant" }
	local min, max, step = o.Min or 0, o.Max or 60, o.Step or .1
	local item, row, holder = self:_item(o.Name or "Combo", o.Description, 200)

	-- toggle (ขวาสุด)
	local track = create("Frame", {
		AnchorPoint = Vector2.new(1, .5), Position = UDim2.fromScale(1, .5), Size = UDim2.fromOffset(38, 20),
		BackgroundColor3 = T.Off, BorderSizePixel = 0, Parent = holder,
	})
	corner(track, 10)
	local tStroke = stroke(track, T.Stroke, 1)
	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0, .5), Position = UDim2.new(0, 3, .5, 0), Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = WHITE, BorderSizePixel = 0, Parent = track,
	})
	corner(knob, 7)
	local tbtn = create("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", Parent = track })

	-- กล่องตัวเลข (delay)
	local nBox = create("Frame", {
		AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -48, .5, 0), Size = UDim2.fromOffset(58, 26),
		BackgroundColor3 = T.Input, BorderSizePixel = 0, Parent = holder,
	})
	corner(nBox, 6); stroke(nBox, T.Stroke, 1)
	local nTb = create("TextBox", {
		BackgroundTransparency = 1, Size = UDim2.new(1, -18, 1, 0), Text = "", ClearTextOnFocus = false, Font = FONT,
		TextSize = 12, TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Right, Parent = nBox,
	})
	create("UIPadding", { PaddingRight = UDim.new(0, 3), Parent = nTb })

	-- กล่องโหมด
	local mBox = create("TextButton", {
		AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -112, .5, 0), Size = UDim2.fromOffset(80, 26),
		BackgroundColor3 = T.Input, Text = "", AutoButtonColor = false, Parent = holder,
	})
	corner(mBox, 6); stroke(mBox, T.Stroke, 1)
	local mLbl = create("TextLabel", {
		Position = UDim2.fromOffset(8, 0), Size = UDim2.new(1, -24, 1, 0), BackgroundTransparency = 1, Text = "", Font = FONT,
		TextSize = 12, TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = mBox,
	})

	local function spin(parent, y, txt)
		return create("TextButton", {
			Position = UDim2.new(1, -18, y, 0), Size = UDim2.new(0, 18, .5, 0), BackgroundTransparency = 1, Text = txt,
			Font = FONT_B, TextSize = 8, TextColor3 = T.Muted, AutoButtonColor = false, ZIndex = 3, Parent = parent,
		})
	end
	local nUp, nDn = spin(nBox, 0, "▲"), spin(nBox, .5, "▼")
	local mUp, mDn = spin(mBox, 0, "▲"), spin(mBox, .5, "▼")

	local mi = 1
	if o.Mode then mi = table.find(modes, o.Mode) or 1 end
	local obj = { Item = item, Enabled = false, Mode = modes[mi], Delay = snap(o.Delay or min, step, min, max) }
	obj.Value = { Enabled = obj.Enabled, Mode = obj.Mode, Delay = obj.Delay }

	local function render()
		obj.Value = { Enabled = obj.Enabled, Mode = obj.Mode, Delay = obj.Delay }
		tw(track, .18, { BackgroundColor3 = obj.Enabled and T.Accent or T.Off })
		tw(tStroke, .18, { Color = obj.Enabled and T.Accent:Lerp(WHITE, .3) or T.Stroke })
		tw(knob, .18, { Position = obj.Enabled and UDim2.new(1, -17, .5, 0) or UDim2.new(0, 3, .5, 0) })
		mLbl.Text = tostring(obj.Mode)
		nTb.Text = (step < 1) and string.format("%.1f", obj.Delay) or tostring(obj.Delay)
	end
	local function fire(silent)
		render()
		if not silent then safe(o.Callback, obj.Enabled, obj.Mode, obj.Delay); win:_changed() end
	end
	function obj:Set(v, silent)
		if type(v) == "table" then
			if v.Enabled ~= nil then self.Enabled = v.Enabled and true or false end
			if v.Mode ~= nil and table.find(modes, v.Mode) then self.Mode = v.Mode; mi = table.find(modes, v.Mode) end
			if v.Delay ~= nil then self.Delay = snap(tonumber(v.Delay) or self.Delay, step, min, max) end
		else
			self.Enabled = v and true or false
		end
		fire(silent)
	end
	function obj:Export() return { Enabled = self.Enabled, Mode = self.Mode, Delay = self.Delay } end
	function obj:Import(d) self:Set(d) end

	local function cycle(d)
		mi = ((mi - 1 + d) % #modes) + 1
		obj.Mode = modes[mi]; fire()
	end
	local function setDelay(v) obj.Delay = snap(tonumber(v) or obj.Delay, step, min, max); fire() end
	tbtn.MouseButton1Click:Connect(function() obj.Enabled = not obj.Enabled; fire() end)
	mBox.MouseButton1Click:Connect(function() cycle(1) end)
	mUp.MouseButton1Click:Connect(function() cycle(-1) end)
	mDn.MouseButton1Click:Connect(function() cycle(1) end)
	nUp.MouseButton1Click:Connect(function() setDelay(obj.Delay + step) end)
	nDn.MouseButton1Click:Connect(function() setDelay(obj.Delay - step) end)
	nTb.FocusLost:Connect(function() setDelay(nTb.Text) end)

	table.insert(win._acc, render)
	render()
	win:_register(o.Flag, obj, o); self:_reg(item, o.Name, o.Description)
	if o.Default then obj:Set(true, true) end
	return obj
end

local MOUSEKEYS = { MB1 = Enum.UserInputType.MouseButton1, MB2 = Enum.UserInputType.MouseButton2, MB3 = Enum.UserInputType.MouseButton3 }
local function parseKey(k)
	if k == nil or k == "" then return nil end
	if typeof(k) == "EnumItem" then return k end
	if type(k) == "string" then
		if MOUSEKEYS[k] then return MOUSEKEYS[k] end
		local ok, v = pcall(function() return Enum.KeyCode[k] end)
		if ok then return v end
	end
end
local function keyName(k)
	if not k then return "None" end
	for n, v in pairs(MOUSEKEYS) do if v == k then return n end end
	return k.Name
end
local function bindDrag(win, hit, page, fn)
	local dragging = false
	hit.InputBegan:Connect(function(i)
		if isPress(i) then dragging = true; page.ScrollingEnabled = false; fn(i.Position) end
	end)
	table.insert(win._conns, UIS.InputChanged:Connect(function(i)
		if dragging and isMove(i) then fn(i.Position) end
	end))
	table.insert(win._conns, UIS.InputEnded:Connect(function(i)
		if dragging and isPress(i) then dragging = false; page.ScrollingEnabled = true end
	end))
end

function Section:AddInput(a, b)
	local o = norm(a, b)
	local win = self._win; local T = win.T
	local fluent = (o._style == "fluent")
	local item, row, holder = self:_item(o.Name or "Input", o.Description, 150)
	local box = create("Frame", {
		AnchorPoint = Vector2.new(1, .5), Position = UDim2.fromScale(1, .5), Size = UDim2.fromOffset(150, 28),
		BackgroundColor3 = T.Input, BorderSizePixel = 0, Parent = holder,
	})
	corner(box, 6); stroke(box, T.Stroke, 1)
	local tb = create("TextBox", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = tostring(o.Default or ""), PlaceholderText = o.Placeholder or "",
		PlaceholderColor3 = T.Muted, ClearTextOnFocus = false, Font = FONT, TextSize = 12, TextColor3 = T.Text,
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = box,
	})
	create("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = tb })
	local function clean(v)
		v = tostring(v or "")
		if o.Numeric then v = v:gsub("[^%d%.%-]", "") end
		return v
	end
	local obj = { Value = clean(tb.Text), Item = item }
	function obj:Set(v, silent)
		self.Value = clean(v); tb.Text = self.Value
		if not silent then safe(o.Callback, self.Value); win:_changed() end
	end
	if fluent and not o.Finished then
		tb:GetPropertyChangedSignal("Text"):Connect(function()
			if tb.Text ~= obj.Value then obj:Set(tb.Text) end
		end)
	else
		tb.FocusLost:Connect(function()
			obj:Set(tb.Text)
			if o.RemoveTextAfterFocusLost or o.TextDisappear then tb.Text = "" end
		end)
	end
	win:_register(o.Flag, obj, o); self:_reg(item, o.Name, o.Description)
	return obj
end

function Section:AddKeybind(a, b)
	local o = norm(a, b)
	local win = self._win; local T = win.T
	local fluent = (o._style == "fluent")
	local item, row, holder = self:_item(o.Name or "Keybind", o.Description, 90)
	local btn = create("TextButton", {
		AnchorPoint = Vector2.new(1, .5), Position = UDim2.fromScale(1, .5), Size = UDim2.fromOffset(90, 28),
		BackgroundColor3 = T.Input, Text = "", Font = FONT_M, TextSize = 12, TextColor3 = T.Text, AutoButtonColor = false, Parent = holder,
	})
	corner(btn, 6); stroke(btn, T.Stroke, 1)
	local key = parseKey(o.Default)
	local obj = { Item = item, Mode = o.Mode or "Toggle", State = false }
	local listening, clicks = false, {}
	local function val() if fluent then return keyName(key) end return key end
	local function render() btn.Text = listening and "..." or keyName(key) end
	obj.Value = val()
	function obj:GetState() if self.Mode == "Always" then return true end return self.State end
	function obj:OnClick(f) table.insert(clicks, f) end
	function obj:Set(k, mode, silent)
		if type(mode) == "boolean" then silent = mode; mode = nil end
		key = parseKey(k)
		if type(mode) == "string" then self.Mode = mode end
		listening = false; self.State = false; self.Value = val(); render()
		if not silent then
			safe(o.OnChange or o.ChangedCallback, key)
			for _, f in ipairs(o._ls) do safe(f, self.Value) end
			win:_changed()
		end
	end
	function obj:Export() return { Key = keyName(key), Mode = self.Mode } end
	function obj:Import(d)
		if type(d) == "table" then self:Set(d.Key, d.Mode) else self:Set(d) end
	end
	obj.SetValue = function(s, k, m) s:Set(k, m) end
	btn.MouseButton1Click:Connect(function() listening = true; render() end)
	local function matches(i) return key ~= nil and (i.KeyCode == key or i.UserInputType == key) end
	table.insert(win._conns, UIS.InputBegan:Connect(function(i, gp)
		if listening then
			if i.UserInputType == Enum.UserInputType.Keyboard then
				obj:Set(i.KeyCode ~= Enum.KeyCode.Escape and i.KeyCode or nil)
			elseif i.UserInputType == Enum.UserInputType.MouseButton2 or i.UserInputType == Enum.UserInputType.MouseButton3 then
				obj:Set(i.UserInputType)
			end
			return
		end
		if gp or not matches(i) then return end
		if not fluent then safe(o._cb); return end
		if obj.Mode == "Toggle" then
			obj.State = not obj.State
			safe(o._cb, obj.State)
			for _, f in ipairs(clicks) do safe(f) end
		elseif obj.Mode == "Hold" then
			obj.State = true; safe(o._cb, true)
		end
	end))
	table.insert(win._conns, UIS.InputEnded:Connect(function(i)
		if fluent and obj.Mode == "Hold" and obj.State and matches(i) then obj.State = false; safe(o._cb, false) end
	end))
	render()
	win:_register(o.Flag, obj, o); self:_reg(item, o.Name, o.Description)
	return obj
end

function Section:AddColorpicker(a, b)
	local o = norm(a, b)
	local win = self._win; local T = win.T
	local item, row, holder = self:_item(o.Name or "Colorpicker", o.Description, 44)
	local hasT = o.Transparency ~= nil
	local sw = create("TextButton", {
		AnchorPoint = Vector2.new(1, .5), Position = UDim2.fromScale(1, .5), Size = UDim2.fromOffset(44, 24),
		BackgroundColor3 = WHITE, Text = "", AutoButtonColor = false, Parent = holder,
	})
	corner(sw, 6); stroke(sw, T.Stroke, 1)
	local panel = create("Frame", {
		BackgroundColor3 = T.Input, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, hasT and 172 or 146),
		Visible = false, LayoutOrder = 2, Parent = item,
	})
	local sv = create("Frame", { Position = UDim2.fromOffset(14, 10), Size = UDim2.fromOffset(150, 120), BackgroundColor3 = Color3.new(1, 0, 0), BorderSizePixel = 0, Parent = panel })
	corner(sv, 4)
	local wh = create("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, BorderSizePixel = 0, Parent = sv })
	corner(wh, 4)
	create("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }), Parent = wh })
	local bl = create("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, Parent = sv })
	corner(bl, 4)
	create("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }), Parent = bl })
	local svKnob = create("Frame", { AnchorPoint = Vector2.new(.5, .5), Size = UDim2.fromOffset(10, 10), BackgroundTransparency = 1, Parent = sv })
	corner(svKnob, 5); stroke(svKnob, WHITE, 2)
	local svHit = create("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", Parent = sv })

	local hue = create("Frame", { Position = UDim2.fromOffset(172, 10), Size = UDim2.fromOffset(16, 120), BackgroundColor3 = WHITE, BorderSizePixel = 0, Parent = panel })
	corner(hue, 4)
	local kps = {}
	for k = 0, 6 do kps[#kps + 1] = ColorSequenceKeypoint.new(k / 6, Color3.fromHSV(k / 6, 1, 1)) end
	create("UIGradient", { Rotation = 90, Color = ColorSequence.new(kps), Parent = hue })
	local hueKnob = create("Frame", { AnchorPoint = Vector2.new(.5, .5), Size = UDim2.fromOffset(20, 4), BackgroundTransparency = 1, Parent = hue })
	corner(hueKnob, 2); stroke(hueKnob, WHITE, 2)
	local hueHit = create("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", Parent = hue })

	local trBar, trKnob, trHit
	if hasT then
		trBar = create("Frame", { Position = UDim2.fromOffset(14, 140), Size = UDim2.fromOffset(174, 14), BackgroundColor3 = WHITE, BorderSizePixel = 0, Parent = panel })
		corner(trBar, 4)
		create("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, .95) }), Parent = trBar })
		trKnob = create("Frame", { AnchorPoint = Vector2.new(.5, .5), Size = UDim2.fromOffset(4, 20), BackgroundTransparency = 1, Parent = trBar })
		corner(trKnob, 2); stroke(trKnob, WHITE, 2)
		trHit = create("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", Parent = trBar })
	end

	local h, s, v = 0, 1, 1
	local obj = { Item = item, Transparency = o.Transparency or 0 }
	local function apply(silent)
		obj.Value = Color3.fromHSV(h, s, v)
		sw.BackgroundColor3 = obj.Value
		sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		svKnob.Position = UDim2.fromScale(s, 1 - v)
		hueKnob.Position = UDim2.fromScale(.5, h)
		if hasT then trBar.BackgroundColor3 = obj.Value; trKnob.Position = UDim2.fromScale(obj.Transparency, .5) end
		if not silent then safe(o.Callback, obj.Value, obj.Transparency); win:_changed() end
	end
	function obj:Set(c, silent, t)
		if type(silent) == "number" then t = silent; silent = nil end
		if typeof(c) == "Color3" then
			h, s, v = c:ToHSV()
		elseif type(c) == "table" then
			if c.R then h, s, v = Color3.new(c.R, c.G, c.B):ToHSV() else h, s, v = c[1] or 0, c[2] or 0, c[3] or 0 end
		end
		if t then self.Transparency = t end
		apply(silent)
	end
	function obj:SetValueRGB(c, t) self:Set(c, nil, t) end
	obj.SetValue = function(s2, hsv, t) s2:Set(hsv, nil, t) end
	function obj:Export() return { R = self.Value.R, G = self.Value.G, B = self.Value.B, T = self.Transparency } end
	function obj:Import(d)
		if type(d) == "table" then self:Set(Color3.new(d.R or 0, d.G or 0, d.B or 0), nil, d.T) end
	end

	local page = self._tab.Page
	bindDrag(win, svHit, page, function(p)
		s = math.clamp((p.X - sv.AbsolutePosition.X) / math.max(sv.AbsoluteSize.X, 1), 0, 1)
		v = 1 - math.clamp((p.Y - sv.AbsolutePosition.Y) / math.max(sv.AbsoluteSize.Y, 1), 0, 1)
		apply()
	end)
	bindDrag(win, hueHit, page, function(p)
		h = math.clamp((p.Y - hue.AbsolutePosition.Y) / math.max(hue.AbsoluteSize.Y, 1), 0, .999)
		apply()
	end)
	if hasT then
		bindDrag(win, trHit, page, function(p)
			obj.Transparency = math.clamp((p.X - trBar.AbsolutePosition.X) / math.max(trBar.AbsoluteSize.X, 1), 0, 1)
			apply()
		end)
	end
	sw.MouseButton1Click:Connect(function() panel.Visible = not panel.Visible end)
	if typeof(o.Default) == "Color3" then h, s, v = o.Default:ToHSV() end
	apply(true)
	win:_register(o.Flag, obj, o); self:_reg(item, o.Name, o.Description)
	return obj
end

function Section:AddDropdown(a, b)
	local o = norm(a, b)
	local win = self._win; local T = win.T
	local multi = o.Multi or o.MultipleOptions
	local item, row, holder = self:_item(o.Name or "Dropdown", o.Description, 130)
	local btn = create("TextButton", {
		AnchorPoint = Vector2.new(1, .5), Position = UDim2.fromScale(1, .5), Size = UDim2.fromOffset(130, 28),
		BackgroundColor3 = T.Input, Text = "", AutoButtonColor = false, Parent = holder,
	})
	corner(btn, 6); stroke(btn, T.Stroke, 1)
	local lbl = create("TextLabel", {
		Position = UDim2.fromOffset(8, 0), Size = UDim2.new(1, -26, 1, 0), BackgroundTransparency = 1, Text = "", Font = FONT,
		TextSize = 12, TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = btn,
	})
	local arrow = create("TextLabel", {
		AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -7, .5, 0), Size = UDim2.fromOffset(12, 12),
		BackgroundTransparency = 1, Text = "▼", Font = FONT_B, TextSize = 8, TextColor3 = T.Sub, Parent = btn,
	})
	local list = create("ScrollingFrame", {
		BackgroundColor3 = T.Input, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0), Visible = false, LayoutOrder = 2,
		ScrollBarThickness = 3, ScrollBarImageColor3 = T.Off, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = item,
	})
	create("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = list })
	create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = list })

	local opts, sel, btns = {}, {}, {}
	local obj = { Value = multi and {} or nil, Item = item }
	local open = false

	local function text()
		if multi then
			local t = {}
			for _, v in ipairs(opts) do if sel[v] then t[#t + 1] = v end end
			return #t > 0 and table.concat(t, ", ") or (o.Placeholder or "None")
		end
		return obj.Value ~= nil and tostring(obj.Value) or (o.Placeholder or "Select")
	end
	local function paint()
		lbl.Text = text()
		for v, b in pairs(btns) do
			local on = multi and sel[v] or (not multi and obj.Value == v)
			b.TextColor3 = on and T.Accent or T.Text
			b.Check.Visible = on and true or false
			b.Check.TextColor3 = T.Accent
		end
	end
	local function setOpen(v)
		open = v
		list.Visible = v
		arrow.Text = v and "▲" or "▼"
		list.Size = UDim2.new(1, 0, 0, math.min(#opts * 28 + 8, 172))
	end
	local function fire(silent)
		local cbVal
		if multi then
			local arr = {}
			for _, v in ipairs(opts) do if sel[v] then arr[#arr + 1] = v end end
			if o._style == "fluent" then
				local d = {}
				for _, v in ipairs(arr) do d[v] = true end
				obj.Value = d
			else obj.Value = arr end
			cbVal = (o._style == "fluent") and obj.Value or arr
		else
			cbVal = (o._style == "rayfield") and { obj.Value } or obj.Value
		end
		paint()
		if not silent then safe(o.Callback, cbVal); win:_changed() end
	end
	local function rebuild()
		for _, c in ipairs(list:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
		btns = {}
		for i, v in ipairs(opts) do
			local b = create("TextButton", {
				Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = T.Hover, BackgroundTransparency = 1, Text = v, Font = FONT,
				TextSize = 12, TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false,
				LayoutOrder = i, Parent = list,
			})
			corner(b, 5)
			create("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = b })
			create("TextLabel", {
				Name = "Check", AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -6, .5, 0), Size = UDim2.fromOffset(14, 14),
				BackgroundTransparency = 1, Text = "✓", Font = FONT_B, TextSize = 12, TextColor3 = T.Accent, Visible = false, Parent = b,
			})
			b.MouseEnter:Connect(function() b.BackgroundTransparency = 0 end)
			b.MouseLeave:Connect(function() b.BackgroundTransparency = 1 end)
			b.MouseButton1Click:Connect(function()
				if multi then sel[v] = not sel[v] or nil; fire()
				else obj.Value = v; fire(); setOpen(false) end
			end)
			btns[v] = b
		end
		if open then setOpen(true) end
		paint()
	end

	function obj:Refresh(newOpts, keep)
		opts = {}
		for _, v in ipairs(newOpts or {}) do opts[#opts + 1] = tostring(v) end
		if not keep then sel = {}; obj.Value = multi and {} or nil end
		rebuild()
	end
	function obj:Set(v, silent)
		if multi then
			sel = {}
			for k, x in pairs(type(v) == "table" and v or {}) do
				if type(k) == "number" then sel[tostring(x)] = true elseif x then sel[tostring(k)] = true end
			end
		else
			v = v ~= nil and tostring(v) or nil
			self.Value = (v == nil or table.find(opts, v)) and v or self.Value
		end
		fire(silent)
	end

	table.insert(win._acc, paint)
	btn.MouseButton1Click:Connect(function() setOpen(not open) end)
	obj:Refresh(o.Options, false)
	local d = o.Default
	if not multi then
		if type(d) == "number" then d = opts[d] end
		if type(d) == "table" then d = d[1] end
	end
	if d ~= nil then obj:Set(d, true) end
	win:_register(o.Flag, obj, o); self:_reg(item, o.Name, o.Description)
	return obj
end

----------------------------------------------------------------- compat (Rayfield / Orion / Fluent)
Section.AddTextbox, Section.AddBind = Section.AddInput, Section.AddKeybind
for new, old in pairs({
	CreateToggle = "AddToggle", CreateSlider = "AddSlider", CreateDropdown = "AddDropdown", CreateButton = "AddButton",
	CreateInput = "AddInput", CreateKeybind = "AddKeybind", CreateLabel = "AddLabel", CreateParagraph = "AddParagraph",
}) do
	Section[new] = function(self, a, b)
		if type(a) == "table" then a._style = "rayfield" end
		return self[old](self, a, b)
	end
	Tab[new] = function(self, a, b)
		local s = self:_default()
		return Section[new](s, a, b)
	end
end
function Tab:CreateSection(name)   -- Rayfield: element ถัดไปจะอยู่ใต้หัวข้อนี้
	local s = self:AddSection({ Name = name })
	self._def = s
	return s
end

function Lib:MakeWindow(cfg) return self:CreateWindow(cfg) end                 -- Orion
function Window:MakeTab(o) return self:AddTab(o) end                           -- Orion
function Window:CreateTab(name, icon)                                           -- Rayfield
	if type(name) == "table" then return self:AddTab(name) end
	return self:AddTab({ Name = name, Icon = icon })
end
function Window:Init() self:LoadConfig() end
function Lib:Init() if Lib._last then Lib._last:LoadConfig() end end          -- Orion
function Lib:LoadConfiguration() if Lib._last then Lib._last:LoadConfig() end end -- Rayfield
function Lib:Notify(o) if Lib._last then Lib._last:Notify(o) end end           -- Rayfield / Fluent
function Lib:Destroy() if Lib._last then Lib._last:Destroy() end end

----------------------------------------------------------------- SaveManager / InterfaceManager (เข้ากันกับ Fluent)
local function mkdirs(path)
	if not makefolder then return end
	local p = ""
	for part in path:gmatch("[^/]+") do
		p = (p == "" and part) or (p .. "/" .. part)
		pcall(function() if not (isfolder and isfolder(p)) then makefolder(p) end end)
	end
end

local SaveManager = { Folder = "FluentSettings", Ignore = {} }
function SaveManager:SetLibrary(l) self.Library = l end
function SaveManager:SetFolder(f) self.Folder = f end
function SaveManager:IgnoreThemeSettings()
	for _, k in ipairs({ "InterfaceTheme", "AcrylicToggle", "TransparentToggle", "MenuKeybind" }) do self.Ignore[k] = true end
end
function SaveManager:SetIgnoreIndexes(list)
	for _, k in ipairs(list or {}) do self.Ignore[k] = true end
end
function SaveManager:_dir()
	local d = self.Folder .. "/settings"
	mkdirs(d)
	return d
end
function SaveManager:Save(name)
	if not writefile then return false, "executor ไม่รองรับ writefile" end
	if not name or name:match("^%s*$") then return false, "ชื่อ config ว่างอยู่" end
	local data = {}
	for f, obj in pairs(Lib.Flags) do
		if not self.Ignore[f] then
			local ok, v = pcall(function() if obj.Export then return obj:Export() end return obj.Value end)
			if ok and v ~= nil then data[f] = v end
		end
	end
	local ok, err = pcall(function() writefile(self:_dir() .. "/" .. name .. ".json", HttpService:JSONEncode(data)) end)
	return ok, err
end
function SaveManager:Load(name)
	if not (readfile and isfile) then return false, "executor ไม่รองรับ readfile" end
	if not name or name:match("^%s*$") then return false, "ยังไม่ได้เลือก config" end
	local path = self:_dir() .. "/" .. name .. ".json"
	if not isfile(path) then return false, "ไม่พบไฟล์ config" end
	local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
	if not ok or type(data) ~= "table" then return false, "อ่านไฟล์ config ไม่ได้" end
	for f, v in pairs(data) do
		local obj = Lib.Flags[f]
		if obj and not self.Ignore[f] then
			pcall(function() if obj.Import then obj:Import(v) else obj:Set(v) end end)
		end
	end
	return true
end
function SaveManager:RefreshConfigList()
	local out = {}
	if listfiles then
		local ok, files = pcall(listfiles, self:_dir())
		if ok then
			for _, f in ipairs(files) do
				local n = f:match("([^/\\]+)%.json$")
				if n then out[#out + 1] = n end
			end
		end
	end
	table.sort(out)
	return out
end
function SaveManager:GetAutoload()
	if not (isfile and readfile) then return nil end
	local p = self:_dir() .. "/autoload.txt"
	local ok, r = pcall(function() if isfile(p) then return readfile(p) end end)
	if ok and r and r ~= "" then return r end
end
function SaveManager:SetAutoload(name)
	if not writefile then return false end
	return (pcall(function() writefile(self:_dir() .. "/autoload.txt", name) end))
end
function SaveManager:LoadAutoloadConfig()
	local n = self:GetAutoload()
	if not n then return end
	local ok, err = self:Load(n)
	Lib:Notify({
		Title = "Configuration manager", Duration = 7,
		Content = ok and ("โหลด config อัตโนมัติ: " .. n) or ("โหลด config อัตโนมัติไม่สำเร็จ: " .. tostring(err)),
	})
end
function SaveManager:BuildConfigSection(tab)
	local sec = tab:AddSection({ Name = "Configuration" })
	local nameIn = sec:AddInput({ Name = "Config name", Placeholder = "ชื่อ config" })
	local list = sec:AddDropdown({ Name = "Config list", Options = self:RefreshConfigList(), Placeholder = "เลือก config" })
	local status = sec:AddLabel("Current autoload config: " .. (self:GetAutoload() or "none"))
	local function note(ok, okMsg, err)
		Lib:Notify({ Title = "Configuration manager", Content = ok and okMsg or tostring(err), Duration = 5 })
	end
	local function refresh() list:Refresh(self:RefreshConfigList(), false) end
	sec:AddButton({ Name = "Create config", ButtonText = "Create", Callback = function()
		local n = nameIn.Value
		local ok, err = self:Save(n)
		note(ok, "สร้าง config " .. tostring(n) .. " แล้ว", err)
		if ok then refresh() end
	end })
	sec:AddButton({ Name = "Load config", ButtonText = "Load", Callback = function()
		local ok, err = self:Load(list.Value)
		note(ok, "โหลด config " .. tostring(list.Value) .. " แล้ว", err)
	end })
	sec:AddButton({ Name = "Overwrite config", ButtonText = "Overwrite", Callback = function()
		local ok, err = self:Save(list.Value)
		note(ok, "เขียนทับ config " .. tostring(list.Value) .. " แล้ว", err)
	end })
	sec:AddButton({ Name = "Refresh list", ButtonText = "Refresh", Callback = refresh })
	sec:AddButton({ Name = "Set as autoload", ButtonText = "Set", Callback = function()
		if list.Value and self:SetAutoload(list.Value) then
			status:Set("Current autoload config: " .. list.Value)
			note(true, "ตั้ง " .. list.Value .. " เป็น autoload แล้ว")
		else
			note(false, nil, "ยังไม่ได้เลือก config")
		end
	end })
end

local InterfaceManager = { Folder = "FluentSettings" }
local ACCENTS = {
	Dark = Color3.fromRGB(59, 130, 246), Aqua = Color3.fromRGB(34, 197, 194), Amethyst = Color3.fromRGB(139, 92, 246),
	Rose = Color3.fromRGB(244, 63, 94), Emerald = Color3.fromRGB(16, 185, 129), Orange = Color3.fromRGB(249, 115, 22),
}
function InterfaceManager:SetLibrary(l) self.Library = l end
function InterfaceManager:SetFolder(f) self.Folder = f end
function InterfaceManager:BuildInterfaceSection(tab)
	local win = Lib._last
	if not win then return end
	local path = self.Folder .. "/interface.json"
	local saved = {}
	pcall(function()
		if isfile and isfile(path) then saved = HttpService:JSONDecode(readfile(path)) end
	end)
	local function persist()
		pcall(function() mkdirs(self.Folder); writefile(path, HttpService:JSONEncode(saved)) end)
	end
	local sec = tab:AddSection({ Name = "Interface" })
	sec:AddDropdown({
		Name = "Theme", Description = "Changes the interface accent color.",
		Options = { "Dark", "Aqua", "Amethyst", "Rose", "Emerald", "Orange" }, Default = saved.Theme or "Dark",
		Callback = function(v) if ACCENTS[v] then win:SetAccent(ACCENTS[v]); saved.Theme = v; persist() end end,
	})
	sec:AddSlider({
		Name = "UI Scale", Description = "ปรับขนาดหน้าต่าง (มือถือ: ลดถ้าเล็ก/ใหญ่เกินไป)",
		Min = .5, Max = 1.3, Step = .05, Default = saved.Scale or 1,
		Callback = function(v) win:SetUIScale(v); saved.Scale = v; persist() end,
	})
	sec:AddKeybind({
		Name = "Minimize Bind", Default = win._key,
		OnChange = function(k)
			if typeof(k) == "EnumItem" and k.EnumType == Enum.KeyCode then win._key = k end
		end,
	})
	if ACCENTS[saved.Theme] then win:SetAccent(ACCENTS[saved.Theme]) end
	if saved.Scale then win:SetUIScale(saved.Scale) end
end

return Lib, SaveManager, InterfaceManager
