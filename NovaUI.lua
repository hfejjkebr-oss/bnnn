--[[
    NovaUI Library v1.0.0
    A clean, themeable Roblox UI library. Works on PC and mobile.

    Usage:
        local Library = loadstring(game:HttpGet("RAW_URL_OF_THIS_FILE"))()
        local Window = Library:CreateWindow({
            Title = "My Hub", SubTitle = "v1.0 | User : Guest",
            Logo = "rbxassetid://0", Theme = "Emerald",
        })
        local Tab = Window:AddTab({ Name = "Main" })
        Tab:AddToggle({ Name = "Example", Flag = "Example", Callback = function(v) end })

    Elements : AddSection, AddToggle, AddButton, AddSlider, AddDropdown (Multi),
               AddInput, AddKeybind, AddLabel, AddParagraph, AddDivider
    Extras   : Library:Notify, Library:SetTheme, Window:AddSettingsTab,
               Save/Load config (Flags), floating toggle button, UI scale
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Remove a previous copy if the script is executed twice
local env = (getgenv and getgenv()) or _G
if env.__NovaUI and env.__NovaUI.Destroy then
	pcall(function()
		env.__NovaUI:Destroy()
	end)
end

local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local ROW = IsMobile and 40 or 36

local Library = {
	Version = "1.0.0",
	IsMobile = IsMobile,
	GuiName = "NovaUI",
	Folder = "NovaUI",
	AutoSave = false,
	Flags = {},
	Options = {},
	Windows = {},
	_themed = {},
	_themeFns = {},
	_connections = {},
}
Library.__index = Library
env.__NovaUI = Library

------------------------------------------------------------------------
-- Themes
------------------------------------------------------------------------
Library.Themes = {
	Emerald = {
		Accent = Color3.fromRGB(46, 229, 157),
		Background = Color3.fromRGB(22, 24, 26),
		Secondary = Color3.fromRGB(30, 33, 36),
		Tertiary = Color3.fromRGB(42, 46, 50),
		Stroke = Color3.fromRGB(58, 64, 70),
		Text = Color3.fromRGB(236, 239, 241),
		SubText = Color3.fromRGB(150, 158, 165),
	},
	Ocean = { Accent = Color3.fromRGB(56, 152, 255) },
	Violet = { Accent = Color3.fromRGB(168, 85, 247) },
	Rose = { Accent = Color3.fromRGB(244, 63, 94) },
	Amber = { Accent = Color3.fromRGB(251, 191, 36) },
}
-- Themes that only define Accent inherit the rest from Emerald
for name, t in pairs(Library.Themes) do
	if name ~= "Emerald" then
		for k, v in pairs(Library.Themes.Emerald) do
			if t[k] == nil then
				t[k] = v
			end
		end
	end
end

Library.Theme = {}
for k, v in pairs(Library.Themes.Emerald) do
	Library.Theme[k] = v
end

------------------------------------------------------------------------
-- Helpers
------------------------------------------------------------------------
local function Create(class, props, children)
	local inst = Instance.new(class)
	local parent
	for k, v in pairs(props or {}) do
		if k == "Parent" then
			parent = v
		else
			inst[k] = v
		end
	end
	for _, c in ipairs(children or {}) do
		c.Parent = inst
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

local function Label(props)
	props.BackgroundTransparency = 1
	props.BorderSizePixel = 0
	props.Font = props.Font or Enum.Font.Gotham
	props.TextSize = props.TextSize or 13
	props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
	return Create("TextLabel", props)
end

local function Corner(parent, radius)
	return Create("UICorner", { CornerRadius = UDim.new(0, radius or 6), Parent = parent })
end

local function Stroke(parent, thickness)
	return Create("UIStroke", {
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent,
	})
end

local function Padding(parent, l, t, r, b)
	return Create("UIPadding", {
		PaddingLeft = UDim.new(0, l or 0),
		PaddingTop = UDim.new(0, t or 0),
		PaddingRight = UDim.new(0, r or 0),
		PaddingBottom = UDim.new(0, b or 0),
		Parent = parent,
	})
end

local function Tween(inst, props, time, style, dir)
	local tw = TweenService:Create(
		inst,
		TweenInfo.new(time or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
		props
	)
	tw:Play()
	return tw
end

local function Fire(cb, ...)
	if type(cb) ~= "function" then
		return
	end
	task.spawn(function(...)
		local ok, err = pcall(cb, ...)
		if not ok then
			warn("[NovaUI] callback error: " .. tostring(err))
		end
	end, ...)
end

local function GetGuiParent()
	if gethui then
		local ok, ui = pcall(gethui)
		if ok and ui then
			return ui
		end
	end
	local ok = pcall(function()
		local f = Instance.new("Folder")
		f.Parent = CoreGui
		f:Destroy()
	end)
	if ok then
		return CoreGui
	end
	return LocalPlayer:WaitForChild("PlayerGui")
end

local function ToKeyCode(v)
	if typeof(v) == "EnumItem" then
		return v
	end
	if type(v) == "string" and v ~= "" then
		local ok, k = pcall(function()
			return Enum.KeyCode[v]
		end)
		if ok then
			return k
		end
	end
	return nil
end

local function CanFS()
	return type(writefile) == "function"
		and type(readfile) == "function"
		and type(isfile) == "function"
		and type(makefolder) == "function"
		and type(isfolder) == "function"
end

------------------------------------------------------------------------
-- Library core
------------------------------------------------------------------------
function Library:Connect(signal, fn)
	local c = signal:Connect(fn)
	table.insert(self._connections, c)
	return c
end

function Library:Bind(inst, prop, key)
	inst[prop] = self.Theme[key]
	table.insert(self._themed, { inst, prop, key })
end

function Library:OnTheme(fn)
	table.insert(self._themeFns, fn)
	fn()
end

function Library:_ApplyTheme()
	local alive = {}
	for _, b in ipairs(self._themed) do
		if b[1] and b[1].Parent then
			b[1][b[2]] = self.Theme[b[3]]
			table.insert(alive, b)
		end
	end
	self._themed = alive
	for _, fn in ipairs(self._themeFns) do
		pcall(fn)
	end
end

function Library:SetTheme(t)
	if type(t) == "string" then
		t = self.Themes[t]
	end
	if type(t) ~= "table" then
		return
	end
	for k, v in pairs(t) do
		self.Theme[k] = v
	end
	self:_ApplyTheme()
end

function Library:_Gui()
	if self._gui and self._gui.Parent then
		return self._gui
	end
	local gui = Create("ScreenGui", {
		Name = self.GuiName,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
		DisplayOrder = 999,
	})
	gui.Parent = GetGuiParent()
	self._gui = gui

	self._notifyHolder = Create("Frame", {
		Name = "Notifications",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -12, 1, -12),
		Size = UDim2.new(0, 260, 1, -24),
		ZIndex = 100,
		Parent = gui,
	}, {
		Create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			Padding = UDim.new(0, 8),
		}),
	})
	return gui
end

function Library:Destroy()
	for _, c in ipairs(self._connections) do
		pcall(function()
			c:Disconnect()
		end)
	end
	self._connections = {}
	if self._gui then
		self._gui:Destroy()
		self._gui = nil
	end
	self.Windows, self.Flags, self.Options = {}, {}, {}
	self._themed, self._themeFns = {}, {}
end

------------------------------------------------------------------------
-- Notifications
------------------------------------------------------------------------
function Library:Notify(opts)
	if type(opts) == "string" then
		opts = { Content = opts }
	end
	opts = opts or {}
	self:_Gui()
	local duration = opts.Duration or 4

	local wrap = Create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ClipsDescendants = true,
		Parent = self._notifyHolder,
	})
	local card = Create("Frame", {
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.new(1, 30, 0, 0),
		Parent = wrap,
	})
	self:Bind(card, "BackgroundColor3", "Background")
	Corner(card, 8)
	self:Bind(Stroke(card), "Color", "Stroke")
	Padding(card, 12, 10, 12, 10)
	Create("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = card,
	})

	local title = Label({
		Text = opts.Title or "Notification",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		Size = UDim2.new(1, 0, 0, 16),
		LayoutOrder = 1,
		Parent = card,
	})
	self:Bind(title, "TextColor3", "Accent")

	local content = Label({
		Text = opts.Content or "",
		TextWrapped = true,
		TextSize = 12,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
		Parent = card,
	})
	self:Bind(content, "TextColor3", "Text")

	local bar = Create("Frame", {
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 2),
		LayoutOrder = 3,
		Parent = card,
	})
	self:Bind(bar, "BackgroundColor3", "Accent")

	Tween(card, { Position = UDim2.new(0, 0, 0, 0) }, 0.25, Enum.EasingStyle.Quint)
	Tween(bar, { Size = UDim2.new(0, 0, 0, 2) }, duration, Enum.EasingStyle.Linear)

	task.delay(duration, function()
		if not card.Parent then
			return
		end
		Tween(card, { Position = UDim2.new(1, 30, 0, 0) }, 0.25)
		task.wait(0.3)
		wrap:Destroy()
	end)
end

------------------------------------------------------------------------
-- Config (save / load flags)
------------------------------------------------------------------------
function Library:_Changed()
	if not self.AutoSave or self._loading then
		return
	end
	self._saveToken = (self._saveToken or 0) + 1
	local token = self._saveToken
	task.delay(1.5, function()
		if token == self._saveToken then
			pcall(function()
				self:SaveConfig("Default")
			end)
		end
	end)
end

function Library:SaveConfig(name)
	if not CanFS() then
		return false, "Executor does not support file functions"
	end
	name = name or "Default"
	if not isfolder(self.Folder) then
		makefolder(self.Folder)
	end
	local data = {}
	for flag, opt in pairs(self.Options) do
		if opt.Serialize then
			data[flag] = opt:Serialize()
		end
	end
	local ok, err = pcall(function()
		writefile(self.Folder .. "/" .. name .. ".json", HttpService:JSONEncode(data))
	end)
	return ok, err
end

function Library:LoadConfig(name)
	if not CanFS() then
		return false, "Executor does not support file functions"
	end
	name = name or "Default"
	local path = self.Folder .. "/" .. name .. ".json"
	if not isfile(path) then
		return false, "Config not found"
	end
	local ok, data = pcall(function()
		return HttpService:JSONDecode(readfile(path))
	end)
	if not ok or type(data) ~= "table" then
		return false, "Invalid config file"
	end
	self._loading = true
	for flag, value in pairs(data) do
		local opt = self.Options[flag]
		if opt and opt.Deserialize then
			pcall(function()
				opt:Deserialize(value)
			end)
		end
	end
	self._loading = false
	return true
end

------------------------------------------------------------------------
-- Draggable helper
------------------------------------------------------------------------
local function MakeDraggable(lib, handle, target, getScale)
	local state = { Dragging = false, Moved = 0 }
	local dragStart, startPos, dragInput

	handle.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			state.Dragging = true
			state.Moved = 0
			dragStart = input.Position
			startPos = target.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					state.Dragging = false
				end
			end)
		end
	end)

	handle.InputChanged:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragInput = input
		end
	end)

	lib:Connect(UserInputService.InputChanged, function(input)
		if state.Dragging and input == dragInput then
			local d = input.Position - dragStart
			state.Moved = math.max(state.Moved, d.Magnitude)
			local s = getScale and getScale() or 1
			target.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + d.X / s,
				startPos.Y.Scale,
				startPos.Y.Offset + d.Y / s
			)
		end
	end)

	return state
end

------------------------------------------------------------------------
-- Tab elements
------------------------------------------------------------------------
local TabMethods = {}
TabMethods.__index = TabMethods

local function NextOrder(tab)
	tab._order = tab._order + 1
	return tab._order
end

local function NewCard(tab, height)
	local lib = tab.Library
	local card = Create("Frame", {
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, height or ROW),
		LayoutOrder = NextOrder(tab),
		Parent = tab.Page,
	})
	lib:Bind(card, "BackgroundColor3", "Secondary")
	Corner(card, 6)
	lib:Bind(Stroke(card), "Color", "Stroke")
	return card
end

local function NewName(tab, card, text, widthOffset)
	local lbl = Label({
		Text = text or "",
		Size = UDim2.new(1, -(widthOffset or 24), 0, ROW),
		Position = UDim2.fromOffset(12, 0),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = card,
	})
	tab.Library:Bind(lbl, "TextColor3", "Text")
	return lbl
end

local function Commit(lib, cfg, value, silent)
	if cfg.Flag then
		lib.Flags[cfg.Flag] = value
	end
	if not silent then
		Fire(cfg.Callback, value)
		lib:_Changed()
	end
end

local function Register(lib, cfg, obj)
	if cfg.Flag then
		lib.Options[cfg.Flag] = obj
	end
end

-- Section header:  - Title -
function TabMethods:AddSection(name)
	local s = Label({
		Text = "- " .. tostring(name) .. " -",
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, 0, 0, 26),
		LayoutOrder = NextOrder(self),
		Parent = self.Page,
	})
	self.Library:Bind(s, "TextColor3", "Text")
	return {
		Type = "Section",
		Set = function(_, t)
			s.Text = "- " .. tostring(t) .. " -"
		end,
	}
end

function TabMethods:AddDivider()
	local d = Create("Frame", {
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 1),
		LayoutOrder = NextOrder(self),
		Parent = self.Page,
	})
	self.Library:Bind(d, "BackgroundColor3", "Stroke")
	return d
end

function TabMethods:AddLabel(cfg)
	if type(cfg) == "string" then
		cfg = { Text = cfg }
	end
	cfg = cfg or {}
	local lbl = Label({
		Text = cfg.Text or "",
		RichText = true,
		TextWrapped = true,
		TextSize = 12,
		TextXAlignment = cfg.Center and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 18),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = NextOrder(self),
		Parent = self.Page,
	})
	self.Library:Bind(lbl, "TextColor3", cfg.Accent and "Accent" or "SubText")
	return {
		Type = "Label",
		Instance = lbl,
		Set = function(_, t)
			lbl.Text = tostring(t)
		end,
	}
end

function TabMethods:AddParagraph(cfg)
	cfg = cfg or {}
	local lib = self.Library
	local card = NewCard(self)
	card.Size = UDim2.new(1, 0, 0, 0)
	card.AutomaticSize = Enum.AutomaticSize.Y
	Padding(card, 12, 10, 12, 10)
	Create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = card })

	local title = Label({
		Text = cfg.Title or "",
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		Size = UDim2.new(1, 0, 0, 16),
		LayoutOrder = 1,
		Parent = card,
	})
	lib:Bind(title, "TextColor3", "Text")
	local content = Label({
		Text = cfg.Content or "",
		RichText = true,
		TextWrapped = true,
		TextSize = 12,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
		Parent = card,
	})
	lib:Bind(content, "TextColor3", "SubText")

	return {
		Type = "Paragraph",
		SetTitle = function(_, t)
			title.Text = tostring(t)
		end,
		SetContent = function(_, t)
			content.Text = tostring(t)
		end,
	}
end

function TabMethods:AddButton(cfg)
	if type(cfg) == "string" then
		cfg = { Name = cfg }
	end
	cfg = cfg or {}
	local lib = self.Library
	local card = NewCard(self)
	local btn = Create("TextButton", {
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Text = cfg.Name or "Button",
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		Parent = card,
	})
	lib:Bind(btn, "TextColor3", "Text")

	local Button = { Type = "Button" }
	function Button:SetText(t)
		btn.Text = tostring(t)
	end
	function Button:Click()
		card.BackgroundColor3 = lib.Theme.Tertiary
		Tween(card, { BackgroundColor3 = lib.Theme.Secondary }, 0.3)
		Fire(cfg.Callback)
	end
	btn.Activated:Connect(function()
		Button:Click()
	end)
	return Button
end

function TabMethods:AddToggle(cfg)
	cfg = cfg or {}
	local lib = self.Library
	local card = NewCard(self)
	local label = NewName(self, card, cfg.Name or "Toggle", 70)

	local track = Create("Frame", {
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(40, 22),
		Parent = card,
	})
	Corner(track, 11)
	local knob = Create("Frame", {
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 3, 0.5, 0),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = track,
	})
	Corner(knob, 8)
	local hit = Create("TextButton", {
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 2,
		Parent = card,
	})

	local Toggle = { Type = "Toggle", Value = cfg.Default == true }

	local function render(animate)
		local on = Toggle.Value
		local color = on and lib.Theme.Accent or lib.Theme.Tertiary
		local pos = on and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
		if animate then
			Tween(track, { BackgroundColor3 = color }, 0.15)
			Tween(knob, { Position = pos }, 0.15)
		else
			track.BackgroundColor3 = color
			knob.Position = pos
		end
	end
	lib:OnTheme(function()
		render(false)
	end)

	function Toggle:Set(v, silent)
		self.Value = v and true or false
		render(true)
		Commit(lib, cfg, self.Value, silent)
	end
	function Toggle:Get()
		return self.Value
	end
	function Toggle:SetName(t)
		label.Text = tostring(t)
	end
	function Toggle:Serialize()
		return self.Value
	end
	function Toggle:Deserialize(v)
		self:Set(v)
	end

	hit.Activated:Connect(function()
		Toggle:Set(not Toggle.Value)
	end)

	Register(lib, cfg, Toggle)
	Commit(lib, cfg, Toggle.Value, true)
	if Toggle.Value then
		task.defer(Fire, cfg.Callback, true)
	end
	return Toggle
end

function TabMethods:AddSlider(cfg)
	cfg = cfg or {}
	local lib = self.Library
	local min, max = cfg.Min or 0, cfg.Max or 100
	local inc = cfg.Increment or 1
	local decimals = #(tostring(inc):match("%.(%d+)") or "")
	local suffix = cfg.Suffix or ""

	local card = NewCard(self, 52)
	local label = NewName(self, card, cfg.Name or "Slider", 90)
	label.Size = UDim2.new(1, -90, 0, 28)
	label.Position = UDim2.fromOffset(12, 4)

	local valueLabel = Label({
		Size = UDim2.new(0, 70, 0, 28),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 4),
		TextXAlignment = Enum.TextXAlignment.Right,
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		Parent = card,
	})
	lib:Bind(valueLabel, "TextColor3", "Accent")

	local track = Create("Frame", {
		BorderSizePixel = 0,
		Position = UDim2.new(0, 12, 0, 36),
		Size = UDim2.new(1, -24, 0, 6),
		Parent = card,
	})
	Corner(track, 3)
	lib:Bind(track, "BackgroundColor3", "Tertiary")
	local fill = Create("Frame", { BorderSizePixel = 0, Size = UDim2.fromScale(0, 1), Parent = track })
	Corner(fill, 3)
	lib:Bind(fill, "BackgroundColor3", "Accent")
	local knob = Create("Frame", {
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = fill,
	})
	Corner(knob, 7)
	local hit = Create("TextButton", {
		Text = "",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 24),
		Size = UDim2.new(1, 0, 1, -24),
		Parent = card,
	})

	local function snap(v)
		v = math.clamp(v, min, max)
		v = math.floor((v - min) / inc + 0.5) * inc + min
		v = math.clamp(v, min, max)
		return tonumber(string.format("%." .. decimals .. "f", v))
	end

	local Slider = { Type = "Slider", Value = snap(cfg.Default or min) }

	local function render(animate)
		local alpha = (max == min) and 0 or (Slider.Value - min) / (max - min)
		valueLabel.Text = tostring(Slider.Value) .. suffix
		local goal = UDim2.fromScale(alpha, 1)
		if animate then
			Tween(fill, { Size = goal }, 0.08)
		else
			fill.Size = goal
		end
	end
	render(false)

	function Slider:Set(v, silent)
		self.Value = snap(tonumber(v) or self.Value)
		render(true)
		Commit(lib, cfg, self.Value, silent)
	end
	function Slider:Get()
		return self.Value
	end
	function Slider:Serialize()
		return self.Value
	end
	function Slider:Deserialize(v)
		self:Set(v)
	end

	local dragging = false
	local function fromX(x)
		local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		local v = snap(min + (max - min) * rel)
		if v ~= Slider.Value then
			Slider:Set(v)
		end
	end

	hit.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragging = true
			self.Page.ScrollingEnabled = false
			fromX(input.Position.X)
		end
	end)
	lib:Connect(UserInputService.InputChanged, function(input)
		if
			dragging
			and (
				input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch
			)
		then
			fromX(input.Position.X)
		end
	end)
	lib:Connect(UserInputService.InputEnded, function(input)
		if
			dragging
			and (
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			)
		then
			dragging = false
			self.Page.ScrollingEnabled = true
		end
	end)

	Register(lib, cfg, Slider)
	Commit(lib, cfg, Slider.Value, true)
	if cfg.Default ~= nil then
		task.defer(Fire, cfg.Callback, Slider.Value)
	end
	return Slider
end

function TabMethods:AddDropdown(cfg)
	cfg = cfg or {}
	local lib = self.Library
	local multi = cfg.Multi == true

	local card = NewCard(self)
	card.ClipsDescendants = true
	local header = Create("TextButton", {
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, ROW),
		Parent = card,
	})
	local name = Label({
		Text = cfg.Name or "Dropdown",
		Size = UDim2.new(0.5, -12, 1, 0),
		Position = UDim2.fromOffset(12, 0),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = header,
	})
	lib:Bind(name, "TextColor3", "Text")
	local valueLabel = Label({
		Size = UDim2.new(0.5, -36, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		TextXAlignment = Enum.TextXAlignment.Right,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		Parent = header,
	})
	lib:Bind(valueLabel, "TextColor3", "Accent")
	local arrow = Label({
		Text = "\u{25BC}",
		TextSize = 9,
		Size = UDim2.fromOffset(20, ROW),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -8, 0, 0),
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = header,
	})
	lib:Bind(arrow, "TextColor3", "SubText")

	local list = Create("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(8, ROW + 2),
		Size = UDim2.new(1, -16, 0, 0),
		ScrollBarThickness = 2,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = card,
	})
	lib:Bind(list, "ScrollBarImageColor3", "Accent")
	Create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = list })

	local Dropdown = { Type = "Dropdown", Open = false, Options = {} }
	local selected = {}
	local buttons = {}

	local function copyOptions(src)
		local out = {}
		for _, o in ipairs(src or {}) do
			table.insert(out, tostring(o))
		end
		return out
	end

	local function current()
		if multi then
			local out = {}
			for _, o in ipairs(Dropdown.Options) do
				if selected[o] then
					table.insert(out, o)
				end
			end
			return out
		end
		for o in pairs(selected) do
			return o
		end
		return nil
	end

	local function renderSelection()
		for opt, b in pairs(buttons) do
			local on = selected[opt] == true
			b.BackgroundColor3 = lib.Theme.Tertiary
			b.BackgroundTransparency = on and 0 or 1
			b.TextColor3 = on and lib.Theme.Accent or lib.Theme.SubText
		end
		local v = current()
		if multi then
			valueLabel.Text = (#v > 0) and table.concat(v, ", ") or "None"
		else
			valueLabel.Text = (v ~= nil) and tostring(v) or "None"
		end
	end
	lib:OnTheme(renderSelection)

	local function visibleHeight()
		return math.min(#Dropdown.Options, 5) * 30
	end

	local function setOpen(state)
		Dropdown.Open = state
		local h = state and (ROW + 6 + visibleHeight() + 4) or ROW
		list.Size = UDim2.new(1, -16, 0, visibleHeight())
		Tween(card, { Size = UDim2.new(1, 0, 0, h) }, 0.18)
		Tween(arrow, { Rotation = state and 180 or 0 }, 0.18)
	end

	local function build()
		for _, b in pairs(buttons) do
			b:Destroy()
		end
		buttons = {}
		for i, opt in ipairs(Dropdown.Options) do
			local b = Create("TextButton", {
				AutoButtonColor = false,
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -4, 0, 28),
				LayoutOrder = i,
				Text = opt,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = list,
			})
			Corner(b, 4)
			Padding(b, 10, 0, 6, 0)
			b.Activated:Connect(function()
				if multi then
					selected[opt] = (not selected[opt]) or nil
				else
					selected = { [opt] = true }
					if cfg.CloseOnSelect ~= false then
						setOpen(false)
					end
				end
				renderSelection()
				Commit(lib, cfg, current())
			end)
			buttons[opt] = b
		end
		renderSelection()
	end

	function Dropdown:Set(value, silent)
		selected = {}
		if multi then
			if type(value) == "table" then
				for k, v in pairs(value) do
					if type(k) == "number" then
						selected[tostring(v)] = true
					elseif v then
						selected[tostring(k)] = true
					end
				end
			end
		elseif value ~= nil then
			selected[tostring(value)] = true
		end
		renderSelection()
		Commit(lib, cfg, current(), silent)
	end
	function Dropdown:Get()
		return current()
	end
	function Dropdown:Refresh(newOptions, keepSelection)
		self.Options = copyOptions(newOptions)
		if keepSelection then
			local valid = {}
			for _, o in ipairs(self.Options) do
				if selected[o] then
					valid[o] = true
				end
			end
			selected = valid
		else
			selected = {}
		end
		build()
		if self.Open then
			setOpen(true)
		end
	end
	function Dropdown:Serialize()
		return current()
	end
	function Dropdown:Deserialize(v)
		self:Set(v)
	end

	header.Activated:Connect(function()
		setOpen(not Dropdown.Open)
	end)

	Dropdown.Options = copyOptions(cfg.Options or cfg.Values)
	build()
	Register(lib, cfg, Dropdown)
	if cfg.Default ~= nil then
		Dropdown:Set(cfg.Default, true)
		task.defer(Fire, cfg.Callback, current())
	end
	return Dropdown
end

function TabMethods:AddInput(cfg)
	cfg = cfg or {}
	local lib = self.Library
	local card = NewCard(self)
	NewName(self, card, cfg.Name or "Input", 0).Size = UDim2.new(0.5, -12, 0, ROW)

	local box = Create("TextBox", {
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.new(0.5, -14, 0, 24),
		Font = Enum.Font.Gotham,
		TextSize = 12,
		ClearTextOnFocus = false,
		PlaceholderText = cfg.Placeholder or "...",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Text = "",
		Parent = card,
	})
	Corner(box, 4)
	Padding(box, 8, 0, 8, 0)
	lib:Bind(box, "BackgroundColor3", "Tertiary")
	lib:Bind(box, "TextColor3", "Text")
	lib:Bind(box, "PlaceholderColor3", "SubText")

	local Input = { Type = "Input" }
	Input.Value = cfg.Default
	if Input.Value == nil then
		Input.Value = cfg.Numeric and 0 or ""
	end
	box.Text = tostring(Input.Value)

	function Input:Set(v, silent)
		if cfg.Numeric then
			self.Value = tonumber(v) or self.Value
		else
			self.Value = tostring(v)
		end
		box.Text = tostring(self.Value)
		Commit(lib, cfg, self.Value, silent)
	end
	function Input:Get()
		return self.Value
	end
	function Input:Serialize()
		return self.Value
	end
	function Input:Deserialize(v)
		self:Set(v)
	end

	box.FocusLost:Connect(function()
		if cfg.Numeric and not tonumber(box.Text) then
			box.Text = tostring(Input.Value)
			return
		end
		Input:Set(box.Text)
	end)

	Register(lib, cfg, Input)
	Commit(lib, cfg, Input.Value, true)
	return Input
end

function TabMethods:AddKeybind(cfg)
	cfg = cfg or {}
	local lib = self.Library
	local card = NewCard(self)
	NewName(self, card, cfg.Name or "Keybind", 110)

	local btn = Create("TextButton", {
		AutoButtonColor = false,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(84, 24),
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		Parent = card,
	})
	Corner(btn, 4)
	lib:Bind(btn, "BackgroundColor3", "Tertiary")
	lib:Bind(btn, "TextColor3", "Accent")

	local Keybind = { Type = "Keybind", Value = ToKeyCode(cfg.Default) }
	local binding = false

	local function render()
		btn.Text = binding and "..." or (Keybind.Value and Keybind.Value.Name or "None")
	end

	function Keybind:Set(v, silent)
		self.Value = ToKeyCode(v)
		binding = false
		render()
		if cfg.Flag then
			lib.Flags[cfg.Flag] = self.Value and self.Value.Name or ""
		end
		if not silent then
			Fire(cfg.OnChanged, self.Value)
			lib:_Changed()
		end
	end
	function Keybind:Get()
		return self.Value
	end
	function Keybind:Serialize()
		return self.Value and self.Value.Name or ""
	end
	function Keybind:Deserialize(v)
		self:Set(v)
	end

	btn.Activated:Connect(function()
		binding = true
		render()
	end)

	lib:Connect(UserInputService.InputBegan, function(input, gpe)
		if binding then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode == Enum.KeyCode.Escape then
					Keybind:Set(nil)
				else
					Keybind:Set(input.KeyCode)
				end
			end
			return
		end
		if gpe or not Keybind.Value then
			return
		end
		if input.KeyCode == Keybind.Value then
			Fire(cfg.Callback, Keybind.Value)
		end
	end)

	render()
	Register(lib, cfg, Keybind)
	if cfg.Flag then
		lib.Flags[cfg.Flag] = Keybind.Value and Keybind.Value.Name or ""
	end
	return Keybind
end

------------------------------------------------------------------------
-- Logo helper (image, or first letter of the title if no image)
------------------------------------------------------------------------
local function MakeLogo(lib, parent, size)
	local holder = Create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(size, size),
		Parent = parent,
	})
	local img = Create("ImageLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ScaleType = Enum.ScaleType.Fit,
		Visible = false,
		Parent = holder,
	})
	local txt = Label({
		Size = UDim2.fromScale(1, 1),
		TextXAlignment = Enum.TextXAlignment.Center,
		Font = Enum.Font.GothamBold,
		TextSize = math.floor(size * 0.6),
		Text = "N",
		Parent = holder,
	})
	lib:Bind(txt, "TextColor3", "Accent")

	local api = { Holder = holder }
	function api.Set(image, letter)
		if type(image) == "number" then
			image = "rbxassetid://" .. image
		end
		if type(image) == "string" and image ~= "" then
			img.Image = image
			img.Visible = true
			txt.Visible = false
		else
			img.Visible = false
			txt.Visible = true
			txt.Text = string.upper(string.sub(letter or "N", 1, 1))
		end
	end
	return api
end

------------------------------------------------------------------------
-- Window
------------------------------------------------------------------------
function Library:CreateWindow(cfg)
	cfg = cfg or {}
	local lib = self
	if cfg.Theme then
		lib:SetTheme(cfg.Theme)
	end
	if cfg.Accent then
		lib:SetTheme({ Accent = cfg.Accent })
	end
	lib.Folder = tostring(cfg.Folder or cfg.Title or "NovaUI"):gsub("[^%w_%- ]", "")
	lib.AutoSave = cfg.AutoSave == true
	local gui = lib:_Gui()

	local Window = {
		Library = lib,
		Tabs = {},
		Visible = true,
		Scale = cfg.Scale or 1,
		ToggleKey = ToKeyCode(cfg.ToggleKey) or Enum.KeyCode.RightShift,
	}

	-- Size (clamped to the screen so it fits on phones)
	local cam = workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
	local want = cfg.Size or Vector2.new(560, 340)
	if typeof(want) == "UDim2" then
		want = Vector2.new(want.X.Offset, want.Y.Offset)
	end
	local W = math.clamp(want.X, 320, math.max(320, vp.X - 40))
	local H = math.clamp(want.Y, 220, math.max(220, vp.Y - 40))

	local Main = Create("Frame", {
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.fromOffset(W, H),
		BorderSizePixel = 0,
		BackgroundTransparency = 0.04,
		ClipsDescendants = true,
		Parent = gui,
	})
	lib:Bind(Main, "BackgroundColor3", "Background")
	Corner(Main, 10)
	local mainStroke = Stroke(Main, 1.5)
	lib:Bind(mainStroke, "Color", "Accent")
	local UIScale = Create("UIScale", { Scale = Window.Scale, Parent = Main })
	Window.Instance = Main

	-- Header
	local Header = Create("Frame", {
		Name = "Header",
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 48),
		Parent = Main,
	})
	lib:Bind(Header, "BackgroundColor3", "Secondary")
	local headerLine = Create("Frame", {
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 1),
		Parent = Header,
	})
	lib:Bind(headerLine, "BackgroundColor3", "Stroke")

	local headerLogo = MakeLogo(lib, Header, 32)
	headerLogo.Holder.Position = UDim2.fromOffset(10, 8)

	local titleLabel = Label({
		Text = cfg.Title or "Nova Hub",
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		Position = UDim2.fromOffset(52, 6),
		Size = UDim2.new(1, -140, 0, 20),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = Header,
	})
	lib:Bind(titleLabel, "TextColor3", "Text")
	local subLabel = Label({
		Text = cfg.SubTitle or "",
		TextSize = 11,
		Position = UDim2.fromOffset(52, 26),
		Size = UDim2.new(1, -140, 0, 14),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = Header,
	})
	lib:Bind(subLabel, "TextColor3", "SubText")

	local function HeaderButton(text, offset)
		local b = Create("TextButton", {
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, offset, 0.5, 0),
			Size = UDim2.fromOffset(30, 30),
			Text = text,
			Font = Enum.Font.GothamBold,
			TextSize = 20,
			Parent = Header,
		})
		lib:Bind(b, "TextColor3", "SubText")
		b.MouseEnter:Connect(function()
			b.TextColor3 = lib.Theme.Accent
		end)
		b.MouseLeave:Connect(function()
			b.TextColor3 = lib.Theme.SubText
		end)
		return b
	end
	local minBtn = HeaderButton("\u{2013}", -42)
	local closeBtn = HeaderButton("\u{00D7}", -8)

	-- Body
	local Body = Create("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 48),
		Size = UDim2.new(1, 0, 1, -48),
		Parent = Main,
	})
	local SidebarW = IsMobile and 104 or 126
	local Sidebar = Create("Frame", {
		BorderSizePixel = 0,
		Size = UDim2.new(0, SidebarW, 1, 0),
		Parent = Body,
	})
	lib:Bind(Sidebar, "BackgroundColor3", "Secondary")
	local sideLine = Create("Frame", {
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0, 1, 1, 0),
		Parent = Sidebar,
	})
	lib:Bind(sideLine, "BackgroundColor3", "Stroke")

	local TabList = Create("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -1, 1, 0),
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = Sidebar,
	})
	Padding(TabList, 6, 8, 6, 8)
	Create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = TabList })

	local Content = Create("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, SidebarW, 0, 0),
		Size = UDim2.new(1, -SidebarW, 1, 0),
		ClipsDescendants = true,
		Parent = Body,
	})

	-- Floating toggle button (tap to open / close, drag to move)
	local Float
	if cfg.FloatingButton ~= false then
		Float = Create("TextButton", {
			Name = "FloatingButton",
			Text = "",
			AutoButtonColor = false,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0),
			Position = cfg.FloatPosition or UDim2.new(0.5, 0, 0, 12),
			Size = UDim2.fromOffset(46, 46),
			ZIndex = 10,
			Parent = gui,
		})
		lib:Bind(Float, "BackgroundColor3", "Background")
		Corner(Float, 23)
		lib:Bind(Stroke(Float, 2), "Color", "Accent")
	end
	local floatLogo
	if Float then
		floatLogo = MakeLogo(lib, Float, 30)
		floatLogo.Holder.AnchorPoint = Vector2.new(0.5, 0.5)
		floatLogo.Holder.Position = UDim2.new(0.5, 0, 0.5, 0)
		floatLogo.Holder.Active = false
	end

	-- Window API
	function Window:SetLogo(image)
		headerLogo.Set(image, titleLabel.Text)
		if floatLogo then
			floatLogo.Set(image, titleLabel.Text)
		end
		self.LogoImage = image
	end
	function Window:SetTitle(t)
		titleLabel.Text = tostring(t)
		self:SetLogo(self.LogoImage)
	end
	function Window:SetSubTitle(t)
		subLabel.Text = tostring(t)
	end
	function Window:SetScale(s)
		self.Scale = math.clamp(tonumber(s) or 1, 0.5, 1.6)
		UIScale.Scale = self.Scale
	end
	function Window:SetToggleKey(k)
		self.ToggleKey = ToKeyCode(k) or self.ToggleKey
	end
	function Window:Show()
		self.Visible = true
		Main.Visible = true
		UIScale.Scale = self.Scale * 0.92
		Tween(UIScale, { Scale = self.Scale }, 0.18)
	end
	function Window:Hide()
		self.Visible = false
		local tw = Tween(UIScale, { Scale = self.Scale * 0.92 }, 0.15)
		tw.Completed:Connect(function()
			if not self.Visible then
				Main.Visible = false
			end
		end)
	end
	function Window:Toggle()
		if self.Visible then
			self:Hide()
		else
			self:Show()
		end
	end
	function Window:Notify(o)
		lib:Notify(o)
	end
	function Window:SaveConfig(name)
		return lib:SaveConfig(name)
	end
	function Window:LoadConfig(name)
		return lib:LoadConfig(name)
	end
	function Window:Destroy()
		Main:Destroy()
		if Float then
			Float:Destroy()
		end
		for i, w in ipairs(lib.Windows) do
			if w == Window then
				table.remove(lib.Windows, i)
				break
			end
		end
	end

	function Window:SelectTab(tab)
		if type(tab) == "number" then
			tab = self.Tabs[tab]
		elseif type(tab) == "string" then
			for _, t in ipairs(self.Tabs) do
				if t.Name == tab then
					tab = t
					break
				end
			end
		end
		if type(tab) ~= "table" then
			return
		end
		for _, t in ipairs(self.Tabs) do
			t.Active = (t == tab)
			t.Render()
		end
		self.ActiveTab = tab
	end

	function Window:AddTab(opts)
		if type(opts) == "string" then
			opts = { Name = opts }
		end
		opts = opts or {}
		local Tab = setmetatable({
			Library = lib,
			Window = Window,
			Name = opts.Name or "Tab",
			Active = false,
			_order = 0,
		}, TabMethods)

		local icon = opts.Icon
		if type(icon) == "number" then
			icon = "rbxassetid://" .. icon
		end
		local hasIcon = type(icon) == "string" and icon ~= ""

		local btn = Create("TextButton", {
			Text = "",
			AutoButtonColor = false,
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 34),
			LayoutOrder = #Window.Tabs + 1,
			Parent = TabList,
		})
		Corner(btn, 6)
		local bar = Create("Frame", {
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.fromOffset(3, 16),
			Visible = false,
			Parent = btn,
		})
		Corner(bar, 2)
		lib:Bind(bar, "BackgroundColor3", "Accent")

		local ico
		if hasIcon then
			ico = Create("ImageLabel", {
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 10, 0.5, 0),
				Size = UDim2.fromOffset(16, 16),
				Image = icon,
				Parent = btn,
			})
		end
		local textX = hasIcon and 34 or 12
		local txt = Label({
			Text = Tab.Name,
			Font = Enum.Font.GothamMedium,
			TextSize = 13,
			Position = UDim2.fromOffset(textX, 0),
			Size = UDim2.new(1, -(textX + 6), 1, 0),
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = btn,
		})

		local Page = Create("ScrollingFrame", {
			Name = Tab.Name,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			ScrollBarThickness = 3,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			Visible = false,
			Parent = Content,
		})
		lib:Bind(Page, "ScrollBarImageColor3", "Accent")
		Padding(Page, 10, 10, 12, 10)
		Create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Page })
		Tab.Page = Page
		Tab.Button = btn

		Tab.Render = function()
			local on = Tab.Active
			btn.BackgroundColor3 = lib.Theme.Tertiary
			btn.BackgroundTransparency = on and 0 or 1
			bar.Visible = on
			txt.TextColor3 = on and lib.Theme.Accent or lib.Theme.SubText
			if ico then
				ico.ImageColor3 = on and lib.Theme.Accent or lib.Theme.SubText
			end
			Page.Visible = on
		end
		lib:OnTheme(Tab.Render)

		btn.Activated:Connect(function()
			Window:SelectTab(Tab)
		end)

		table.insert(Window.Tabs, Tab)
		if #Window.Tabs == 1 then
			Window:SelectTab(Tab)
		end
		return Tab
	end

	-- Built-in settings tab: theme, scale, toggle key, config, unload
	function Window:AddSettingsTab()
		local tab = self:AddTab({ Name = "Settings", Icon = (cfg.SettingsIcon) })
		local names = {}
		for n in pairs(lib.Themes) do
			table.insert(names, n)
		end
		table.sort(names)

		tab:AddSection("Interface")
		tab:AddDropdown({
			Name = "Theme",
			Options = names,
			Callback = function(v)
				lib:SetTheme(v)
			end,
		})
		tab:AddSlider({
			Name = "UI Scale",
			Min = 0.6,
			Max = 1.4,
			Increment = 0.05,
			Default = self.Scale,
			Callback = function(v)
				self:SetScale(v)
			end,
		})
		if not IsMobile then
			tab:AddKeybind({
				Name = "Toggle UI Key",
				Default = self.ToggleKey,
				OnChanged = function(k)
					if k then
						self.ToggleKey = k
					end
				end,
			})
		end

		tab:AddSection("Configuration")
		local cfgName = "Default"
		tab:AddInput({
			Name = "Config name",
			Default = cfgName,
			Callback = function(v)
				cfgName = (v ~= "" and v) or "Default"
			end,
		})
		tab:AddButton({
			Name = "Save config",
			Callback = function()
				local ok, err = lib:SaveConfig(cfgName)
				lib:Notify({
					Title = ok and "Saved" or "Error",
					Content = ok and ("Config '" .. cfgName .. "' saved") or tostring(err),
				})
			end,
		})
		tab:AddButton({
			Name = "Load config",
			Callback = function()
				local ok, err = lib:LoadConfig(cfgName)
				lib:Notify({
					Title = ok and "Loaded" or "Error",
					Content = ok and ("Config '" .. cfgName .. "' loaded") or tostring(err),
				})
			end,
		})

		tab:AddSection("Other")
		tab:AddButton({
			Name = "Unload UI",
			Callback = function()
				lib:Destroy()
			end,
		})
		return tab
	end

	-- Interactions
	MakeDraggable(lib, Header, Main, function()
		return UIScale.Scale
	end)

	minBtn.Activated:Connect(function()
		Window:Hide()
	end)
	closeBtn.Activated:Connect(function()
		Window:Destroy()
	end)

	if Float then
		local state = MakeDraggable(lib, Float, Float, function()
			return 1
		end)
		Float.Activated:Connect(function()
			if state.Moved < 8 then
				Window:Toggle()
			end
		end)
	end

	lib:Connect(UserInputService.InputBegan, function(input, gpe)
		if gpe or IsMobile then
			return
		end
		if input.KeyCode == Window.ToggleKey then
			Window:Toggle()
		end
	end)

	Window:SetLogo(cfg.Logo)
	table.insert(lib.Windows, Window)
	Window:Show()
	return Window
end

return Library
