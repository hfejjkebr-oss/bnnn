-- QuickLibrary v1.0.0
-- GUI Library สำหรับ Roblox โหลดผ่าน loadstring ได้เลย รองรับทั้ง PC และมือถือ
-- ตัวอย่างการใช้งานอยู่ในไฟล์ Example.lua

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Env = (typeof(getgenv) == "function" and getgenv()) or _G

-- ถ้ามีตัวเก่าค้างอยู่ให้ปิดก่อน กัน UI ซ้อนกัน
if type(Env.QuickLibrary) == "table" and type(Env.QuickLibrary.Unload) == "function" then
	pcall(function()
		Env.QuickLibrary:Unload()
	end)
end

local Library = {
	Name = "QuickLibrary",
	Version = "1.0.0",
	Flags = {},
	Options = {},
	Windows = {},
	Themes = {},
	ThemeName = "Emerald",
	NotifyPosition = "BottomRight",
	ConfigFolder = "QuickLibrary",
	Unloaded = false,
	IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled,
	_connections = {},
	_themed = {},
	_themeCallbacks = {},
	_unloadCallbacks = {},
	_listening = false,
}

Library.Status = {
	Success = Color3.fromRGB(80, 220, 130),
	Warning = Color3.fromRGB(255, 190, 70),
	Error = Color3.fromRGB(245, 85, 85),
}

-- สร้างธีมจากสีหลักกับสีพื้นหลัง ที่เหลือคำนวณให้อัตโนมัติ
local function makeTheme(accent, bg)
	local function lift(n)
		return Color3.fromRGB(
			math.clamp(math.floor(bg.R * 255 + n), 0, 255),
			math.clamp(math.floor(bg.G * 255 + n), 0, 255),
			math.clamp(math.floor(bg.B * 255 + n), 0, 255)
		)
	end
	return {
		Background = bg,
		Topbar = lift(4),
		Section = lift(9),
		Element = lift(17),
		ElementHover = lift(26),
		Stroke = lift(40),
		Accent = accent,
		Text = Color3.fromRGB(240, 244, 244),
		SubText = Color3.fromRGB(150, 162, 162),
	}
end

Library.Themes = {
	Emerald = makeTheme(Color3.fromRGB(46, 230, 166), Color3.fromRGB(15, 19, 19)),
	Ocean = makeTheme(Color3.fromRGB(60, 160, 255), Color3.fromRGB(14, 18, 26)),
	Violet = makeTheme(Color3.fromRGB(155, 115, 255), Color3.fromRGB(18, 16, 28)),
	Rose = makeTheme(Color3.fromRGB(255, 95, 135), Color3.fromRGB(25, 16, 20)),
	Amber = makeTheme(Color3.fromRGB(255, 175, 55), Color3.fromRGB(23, 20, 14)),
	Mono = makeTheme(Color3.fromRGB(225, 225, 225), Color3.fromRGB(18, 18, 18)),
}
Library.Theme = Library.Themes.Emerald

local WindowClass = {}
WindowClass.__index = WindowClass
local TabClass = {}
TabClass.__index = TabClass
local SectionClass = {}
SectionClass.__index = SectionClass

-- ฟังก์ชันช่วยทั่วไป

local function viewport()
	local cam = Workspace.CurrentCamera
	return cam and cam.ViewportSize or Vector2.new(1280, 720)
end

local function safeSpawn(fn, ...)
	if type(fn) ~= "function" then
		return
	end
	task.spawn(function(...)
		local ok, err = pcall(fn, ...)
		if not ok then
			warn("[QuickLibrary] " .. tostring(err))
		end
	end, ...)
end

local function tween(obj, time, props, style, dir)
	local info = TweenInfo.new(time or 0.15, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
	local t = TweenService:Create(obj, info, props)
	t:Play()
	return t
end

local function normalizeIcon(icon)
	if type(icon) == "number" then
		return "rbxassetid://" .. icon
	end
	if type(icon) == "string" and string.match(icon, "^%d+$") then
		return "rbxassetid://" .. icon
	end
	return icon
end

local function countDecimals(n)
	local frac = string.match(tostring(n), "%.(%d+)")
	return frac and #frac or 0
end

local function toStrings(t)
	local out = {}
	if type(t) == "table" then
		for _, v in ipairs(t) do
			table.insert(out, tostring(v))
		end
	end
	return out
end

local function toKeyCode(v)
	if typeof(v) == "EnumItem" then
		return v
	end
	if type(v) == "string" and v ~= "" then
		local ok, kc = pcall(function()
			return Enum.KeyCode[v]
		end)
		if ok then
			return kc
		end
	end
	return nil
end

local function toHex(c)
	return string.format(
		"%02x%02x%02x",
		math.floor(c.R * 255 + 0.5),
		math.floor(c.G * 255 + 0.5),
		math.floor(c.B * 255 + 0.5)
	)
end

local function fromHex(s)
	s = string.gsub(tostring(s), "#", "")
	local r, g, b = tonumber(string.sub(s, 1, 2), 16), tonumber(string.sub(s, 3, 4), 16), tonumber(string.sub(s, 5, 6), 16)
	if r and g and b then
		return Color3.fromRGB(r, g, b)
	end
	return nil
end

-- ค่าเริ่มต้นของแต่ละ class จะได้ไม่ต้องเขียนซ้ำ
local Defaults = {
	Frame = { BorderSizePixel = 0 },
	ScrollingFrame = {
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		ScrollBarThickness = 3,
		ScrollBarImageTransparency = 0.2,
		CanvasSize = UDim2.new(),
		ElasticBehavior = Enum.ElasticBehavior.Never,
	},
	TextLabel = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = Color3.new(1, 1, 1),
		Text = "",
	},
	TextButton = {
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = Color3.new(1, 1, 1),
		Text = "",
	},
	TextBox = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = Color3.new(1, 1, 1),
		Text = "",
	},
	ImageLabel = { BackgroundTransparency = 1, BorderSizePixel = 0 },
	ImageButton = { AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0 },
}

local function new(class, props, children)
	local inst = Instance.new(class)
	local defaults = Defaults[class]
	if defaults then
		for k, v in pairs(defaults) do
			inst[k] = v
		end
	end
	local parent
	if props then
		for k, v in pairs(props) do
			if k == "Parent" then
				parent = v
			else
				inst[k] = v
			end
		end
	end
	if children then
		for _, child in ipairs(children) do
			child.Parent = inst
		end
	end
	inst.Parent = parent
	return inst
end

local function corner(parent, radius)
	return new("UICorner", { CornerRadius = UDim.new(0, radius or 6), Parent = parent })
end

local function stroke(parent, color, thickness, transparency)
	return new("UIStroke", {
		Color = color,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent,
	})
end

local function padding(parent, l, t, r, b)
	l = l or 0
	t = t or l
	r = r or l
	b = b or t
	return new("UIPadding", {
		PaddingLeft = UDim.new(0, l),
		PaddingTop = UDim.new(0, t),
		PaddingRight = UDim.new(0, r),
		PaddingBottom = UDim.new(0, b),
		Parent = parent,
	})
end

local function list(parent, gap, direction)
	return new("UIListLayout", {
		Padding = UDim.new(0, gap or 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = direction or Enum.FillDirection.Vertical,
		Parent = parent,
	})
end

-- ระบบธีม: ผูก property ของ Instance กับ key ในธีม เปลี่ยนธีมแล้วอัปเดตให้ทั้งหมด

local function resolve(theme, key)
	if type(key) == "function" then
		return key(theme)
	end
	return theme[key]
end

local function themed(inst, map)
	table.insert(Library._themed, { Instance = inst, Map = map })
	for prop, key in pairs(map) do
		inst[prop] = resolve(Library.Theme, key)
	end
	return inst
end

local function themedStroke(parent, key, thickness, transparency)
	local s = stroke(parent, Library.Theme[key], thickness, transparency)
	themed(s, { Color = key })
	return s
end

function Library:SetTheme(theme)
	local chosen = theme
	if type(theme) == "string" then
		chosen = self.Themes[theme]
		if chosen then
			self.ThemeName = theme
		end
	elseif type(theme) == "table" then
		self.ThemeName = "Custom"
	end
	if type(chosen) ~= "table" then
		return
	end
	local merged = {}
	for k, v in pairs(self.Themes.Emerald) do
		merged[k] = v
	end
	for k, v in pairs(chosen) do
		merged[k] = v
	end
	self.Theme = merged

	local alive = {}
	for _, entry in ipairs(self._themed) do
		if entry.Instance.Parent ~= nil then
			for prop, key in pairs(entry.Map) do
				pcall(function()
					tween(entry.Instance, 0.2, { [prop] = resolve(merged, key) })
				end)
			end
			table.insert(alive, entry)
		end
	end
	self._themed = alive

	for _, fn in ipairs(self._themeCallbacks) do
		safeSpawn(fn, merged)
	end
end

function Library:SetAccent(color)
	local copy = {}
	for k, v in pairs(self.Theme) do
		copy[k] = v
	end
	copy.Accent = color
	self:SetTheme(copy)
end

function Library:OnThemeChanged(fn)
	table.insert(self._themeCallbacks, fn)
end

function Library:OnUnload(fn)
	table.insert(self._unloadCallbacks, fn)
end

function Library:Connect(signal, fn)
	local c = signal:Connect(fn)
	table.insert(self._connections, c)
	return c
end

function Library:Copy(text)
	if typeof(setclipboard) == "function" then
		setclipboard(tostring(text))
		return true
	end
	return false
end

-- ลากหน้าต่าง รองรับทั้งเมาส์และนิ้ว ถ้าขยับน้อยกว่า 6px ถือว่าเป็นการแตะ
local function makeDraggable(handle, target, options)
	options = options or {}
	local dragging = false
	local dragInput, startMouse, startPos, travel = nil, nil, nil, 0

	handle.InputBegan:Connect(function(input)
		local t = input.UserInputType
		if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
			dragging = true
			dragInput = input
			startMouse = input.Position
			startPos = target.Position
			travel = 0
			local conn
			conn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					conn:Disconnect()
					if travel < 6 and options.OnClick then
						options.OnClick()
					end
				end
			end)
		end
	end)

	return UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input == dragInput then
			local scale = options.Scale and options.Scale() or 1
			local delta = input.Position - startMouse
			travel = math.max(travel, delta.Magnitude)
			if travel < 6 and options.OnClick then
				return
			end
			local x = startPos.X.Offset + delta.X / scale
			local y = startPos.Y.Offset + delta.Y / scale
			if options.Clamp then
				x, y = options.Clamp(x, y)
			end
			target.Position = UDim2.new(startPos.X.Scale, x, startPos.Y.Scale, y)
		end
	end)
end

-- ลากค่า (slider, color picker) ล็อกการเลื่อนหน้าไว้ระหว่างลาก ไม่งั้นบนมือถือหน้าจะเลื่อนแทน
local function bindDrag(hit, onMove, lock)
	hit.InputBegan:Connect(function(input)
		local t = input.UserInputType
		if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
			lock(true)
			onMove(input.Position)
			local moveConn, endConn
			moveConn = UserInputService.InputChanged:Connect(function(i)
				if i == input or (t == Enum.UserInputType.MouseButton1 and i.UserInputType == Enum.UserInputType.MouseMovement) then
					onMove(i.Position)
				end
			end)
			endConn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					moveConn:Disconnect()
					endConn:Disconnect()
					lock(false)
				end
			end)
		end
	end)
end

-- เลือกที่วาง ScreenGui: gethui > CoreGui > PlayerGui
local function mountGui(gui)
	if typeof(syn) == "table" and typeof(syn.protect_gui) == "function" then
		pcall(syn.protect_gui, gui)
	end
	local candidates = {}
	if typeof(gethui) == "function" then
		table.insert(candidates, function()
			return gethui()
		end)
	end
	table.insert(candidates, function()
		return CoreGui
	end)
	table.insert(candidates, function()
		return LocalPlayer:WaitForChild("PlayerGui")
	end)
	for _, getParent in ipairs(candidates) do
		local ok = pcall(function()
			gui.Parent = getParent()
		end)
		if ok and gui.Parent then
			return
		end
	end
end

function Library:_ensureGui()
	if self._gui and self._gui.Parent then
		return self._gui
	end
	local gui = new("ScreenGui", {
		Name = "QuickLibrary",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
		DisplayOrder = 999,
	})
	mountGui(gui)
	self._gui = gui

	local holder = new("Frame", {
		Name = "Notifications",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, self.IsMobile and 230 or 270, 1, -24),
		ZIndex = 50,
		Parent = gui,
	})
	self._notifyHolder = holder
	self._notifyLayout = list(holder, 6)
	self:SetNotifyPosition(self.NotifyPosition)
	return gui
end

function Library:SetNotifyPosition(position)
	self.NotifyPosition = position or "BottomRight"
	if not self._notifyHolder then
		return
	end
	local right = string.find(self.NotifyPosition, "Right") ~= nil
	local bottom = string.find(self.NotifyPosition, "Bottom") ~= nil
	self._notifyHolder.AnchorPoint = Vector2.new(right and 1 or 0, bottom and 1 or 0)
	self._notifyHolder.Position = UDim2.new(right and 1 or 0, right and -12 or 12, bottom and 1 or 0, bottom and -12 or 12)
	self._notifyLayout.HorizontalAlignment = right and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Left
	self._notifyLayout.VerticalAlignment = bottom and Enum.VerticalAlignment.Bottom or Enum.VerticalAlignment.Top
end

-- แจ้งเตือน: Library:Notify({Title, Content, Duration, Type = "Success" | "Warning" | "Error"})
function Library:Notify(o)
	if self.Unloaded then
		return
	end
	if type(o) == "string" then
		o = { Content = o }
	end
	o = o or {}
	self:_ensureGui()

	local T = self.Theme
	local color = self.Status[o.Type or ""] or T.Accent
	local duration = o.Duration or 4
	local right = string.find(self.NotifyPosition, "Right") ~= nil
	local offset = right and 300 or -300

	local wrapper = new("Frame", {
		Name = "Notification",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = self._notifyHolder,
	})
	local card = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.new(0, offset, 0, 0),
		BackgroundColor3 = T.Topbar,
		Parent = wrapper,
	})
	corner(card, 8)
	stroke(card, color, 1.2, 0.15)
	padding(card, 10, 8, 10, 8)
	list(card, 3)

	new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 16),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = o.Title or self.Name,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = color,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 1,
		Parent = card,
	})
	new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 14),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = o.Content or "",
		TextSize = 13,
		TextColor3 = T.Text,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 2,
		Parent = card,
	})
	local bar = new("Frame", {
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = color,
		LayoutOrder = 3,
		Parent = card,
	})
	corner(bar, 1)

	tween(card, 0.3, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Quint)
	tween(bar, duration, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)

	task.delay(duration, function()
		if wrapper.Parent == nil then
			return
		end
		local t = tween(card, 0.25, { Position = UDim2.new(0, offset, 0, 0) })
		t.Completed:Connect(function()
			wrapper:Destroy()
		end)
	end)
end

-- คอนฟิก: บันทึก/โหลดค่าของทุก element ที่ตั้ง Flag ไว้

local function hasFileApi()
	return typeof(writefile) == "function"
		and typeof(readfile) == "function"
		and typeof(isfolder) == "function"
		and typeof(makefolder) == "function"
end

function Library:_configPath(name)
	local clean = string.gsub(tostring(name or "default"), "[^%w_%-%s]", "_")
	return self.ConfigFolder .. "/" .. clean .. ".json"
end

local function serializeOption(obj)
	local t = obj.Type
	if t == "Keybind" then
		local k = obj:Get()
		return k and k.Name or ""
	elseif t == "ColorPicker" then
		return toHex(obj:Get())
	end
	return obj:Get()
end

local function deserializeOption(obj, value)
	local t = obj.Type
	if t == "Keybind" then
		obj:Set(toKeyCode(value))
	elseif t == "ColorPicker" then
		local c = fromHex(value)
		if c then
			obj:Set(c)
		end
	elseif t == "Slider" then
		obj:Set(tonumber(value))
	else
		obj:Set(value)
	end
end

function Library:SaveConfig(name)
	if not hasFileApi() then
		return false, "Executor does not support file functions"
	end
	local data = {}
	for flag, obj in pairs(self.Options) do
		local ok, value = pcall(serializeOption, obj)
		if ok and value ~= nil then
			data[flag] = value
		end
	end
	local ok, err = pcall(function()
		if not isfolder(self.ConfigFolder) then
			makefolder(self.ConfigFolder)
		end
		writefile(self:_configPath(name), HttpService:JSONEncode(data))
	end)
	if not ok then
		return false, tostring(err)
	end
	return true
end

function Library:LoadConfig(name)
	if not hasFileApi() then
		return false, "Executor does not support file functions"
	end
	local path = self:_configPath(name)
	local okRead, raw = pcall(readfile, path)
	if not okRead then
		return false, "Config not found"
	end
	local okJson, data = pcall(function()
		return HttpService:JSONDecode(raw)
	end)
	if not okJson or type(data) ~= "table" then
		return false, "Config is corrupted"
	end
	for flag, value in pairs(data) do
		local obj = self.Options[flag]
		if obj then
			pcall(deserializeOption, obj, value)
		end
	end
	return true
end

function Library:GetConfigs()
	local out = {}
	if typeof(listfiles) == "function" and typeof(isfolder) == "function" and isfolder(self.ConfigFolder) then
		local ok, files = pcall(listfiles, self.ConfigFolder)
		if ok and type(files) == "table" then
			for _, path in ipairs(files) do
				local name = string.match(path, "([^/\\]+)%.json$")
				if name then
					table.insert(out, name)
				end
			end
		end
	end
	return out
end

function Library:Unload()
	if self.Unloaded then
		return
	end
	self.Unloaded = true
	for _, fn in ipairs(self._unloadCallbacks) do
		pcall(fn)
	end
	local windows = {}
	for i, w in ipairs(self.Windows) do
		windows[i] = w
	end
	for _, w in ipairs(windows) do
		pcall(function()
			w:Destroy()
		end)
	end
	for _, c in ipairs(self._connections) do
		pcall(function()
			c:Disconnect()
		end)
	end
	if self._gui then
		pcall(function()
			self._gui:Destroy()
		end)
	end
	if Env.QuickLibrary == self then
		Env.QuickLibrary = nil
	end
end

-- ตัวช่วยสำหรับ element

local function emit(obj, value)
	local o = obj._opts
	if o.Callback then
		safeSpawn(o.Callback, value)
	end
	for _, fn in ipairs(obj._listeners) do
		safeSpawn(fn, value)
	end
end

local function baseElement(typeName, opts)
	local obj = { Type = typeName, _opts = opts, _listeners = {}, Flag = opts.Flag }
	function obj:OnChanged(fn)
		table.insert(self._listeners, fn)
	end
	return obj
end

local function setFlag(obj, value)
	if obj.Flag then
		Library.Flags[obj.Flag] = value
	end
end

local function registerOption(obj, value)
	if obj.Flag then
		Library.Flags[obj.Flag] = value
		Library.Options[obj.Flag] = obj
	end
end

-- ถ้าตั้ง Default ไว้ จะเรียก Callback หนึ่งครั้งตอนสร้าง (ปิดได้ด้วย NoInitCallback = true)
local function initCallback(obj, hasDefault, value)
	if hasDefault and not obj._opts.NoInitCallback then
		task.defer(function()
			emit(obj, value)
		end)
	end
end

local function finish(obj, frame)
	obj.Frame = frame
	function obj:SetVisible(v)
		frame.Visible = v
	end
	function obj:Destroy()
		if self.Flag and Library.Options[self.Flag] == self then
			Library.Options[self.Flag] = nil
			Library.Flags[self.Flag] = nil
		end
		frame:Destroy()
	end
	return obj
end

local function elementFrame(section, height, name)
	section._order = section._order + 1
	local frame = new("Frame", {
		Name = name,
		Size = UDim2.new(1, 0, 0, height),
		LayoutOrder = section._order,
		Parent = section.Content,
	})
	themed(frame, { BackgroundColor3 = "Element" })
	corner(frame, 6)
	return frame
end

local function hover(frame, hit)
	hit.MouseEnter:Connect(function()
		tween(frame, 0.12, { BackgroundColor3 = Library.Theme.ElementHover })
	end)
	hit.MouseLeave:Connect(function()
		tween(frame, 0.12, { BackgroundColor3 = Library.Theme.Element })
	end)
end

local function nameLabel(parent, text, widthScale, widthOffset)
	local label = new("TextLabel", {
		Size = UDim2.new(widthScale, widthOffset, 1, 0),
		Position = UDim2.fromOffset(10, 0),
		Text = text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = parent,
	})
	themed(label, { TextColor3 = "Text" })
	return label
end

-- Section: ปุ่ม, สวิตช์, ฯลฯ

function SectionClass:AddLabel(text)
	local o = type(text) == "table" and text or { Text = text }
	self._order = self._order + 1
	local align = Enum.TextXAlignment.Left
	if o.Align == "Center" then
		align = Enum.TextXAlignment.Center
	elseif o.Align == "Right" then
		align = Enum.TextXAlignment.Right
	end
	local lbl = new("TextLabel", {
		Name = "Label",
		Size = UDim2.new(1, 0, 0, 18),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = self._order,
		Text = tostring(o.Text or ""),
		TextWrapped = true,
		TextXAlignment = align,
		Parent = self.Content,
	})
	themed(lbl, { TextColor3 = "Text" })
	local obj = { Type = "Label" }
	function obj:Set(t)
		lbl.Text = tostring(t)
	end
	function obj:Get()
		return lbl.Text
	end
	return finish(obj, lbl)
end

function SectionClass:AddParagraph(o)
	if type(o) == "string" then
		o = { Content = o }
	end
	o = o or {}
	local frame = elementFrame(self, 0, "Paragraph")
	frame.AutomaticSize = Enum.AutomaticSize.Y
	padding(frame, 10, 8, 10, 8)
	list(frame, 3)
	local title
	if o.Title then
		title = new("TextLabel", {
			Size = UDim2.new(1, 0, 0, 16),
			AutomaticSize = Enum.AutomaticSize.Y,
			Text = o.Title,
			Font = Enum.Font.GothamBold,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = 1,
			Parent = frame,
		})
		themed(title, { TextColor3 = "Text" })
	end
	local body = new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 14),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = o.Content or "",
		TextSize = 12,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 2,
		Parent = frame,
	})
	themed(body, { TextColor3 = "SubText" })
	local obj = { Type = "Paragraph" }
	function obj:Set(t, c)
		if title and t then
			title.Text = t
		end
		if c then
			body.Text = c
		end
	end
	return finish(obj, frame)
end

function SectionClass:AddDivider()
	self._order = self._order + 1
	local line = new("Frame", {
		Name = "Divider",
		Size = UDim2.new(1, 0, 0, 1),
		LayoutOrder = self._order,
		BackgroundTransparency = 0.4,
		Parent = self.Content,
	})
	themed(line, { BackgroundColor3 = "Stroke" })
	return finish({ Type = "Divider" }, line)
end

function SectionClass:AddButton(o)
	if type(o) == "string" then
		o = { Name = o }
	end
	o = o or {}
	local obj = { Type = "Button" }
	local frame = elementFrame(self, 34, "Button")
	local btn = new("TextButton", {
		Size = UDim2.new(1, 0, 1, 0),
		Text = o.Name or "Button",
		ZIndex = 2,
		Parent = frame,
	})
	themed(btn, { TextColor3 = "Text" })
	hover(frame, btn)
	btn.Activated:Connect(function()
		tween(frame, 0.08, { BackgroundColor3 = Library.Theme.Accent })
		task.delay(0.14, function()
			if frame.Parent then
				tween(frame, 0.2, { BackgroundColor3 = Library.Theme.Element })
			end
		end)
		safeSpawn(o.Callback)
	end)
	function obj:SetText(t)
		btn.Text = t
	end
	return finish(obj, frame)
end

function SectionClass:AddToggle(o)
	if type(o) == "string" then
		o = { Name = o }
	end
	o = o or {}
	local obj = baseElement("Toggle", o)
	local state = o.Default == true
	local frame = elementFrame(self, 34, "Toggle")
	nameLabel(frame, o.Name or "Toggle", 1, -64)

	local track = new("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(38, 20),
		Parent = frame,
	})
	themed(track, {
		BackgroundColor3 = function(t)
			return state and t.Accent or t.Stroke
		end,
	})
	corner(track, 10)
	local knob = new("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = state and UDim2.new(0, 21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Parent = track,
	})
	corner(knob, 7)

	local hit = new("TextButton", { Size = UDim2.new(1, 0, 1, 0), ZIndex = 5, Parent = frame })
	hover(frame, hit)

	function obj:Set(value, silent)
		value = value and true or false
		if state == value then
			return
		end
		state = value
		tween(track, 0.15, { BackgroundColor3 = state and Library.Theme.Accent or Library.Theme.Stroke })
		tween(knob, 0.15, { Position = state and UDim2.new(0, 21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) })
		setFlag(obj, state)
		if not silent then
			emit(obj, state)
		end
	end
	function obj:Get()
		return state
	end

	hit.Activated:Connect(function()
		obj:Set(not state)
	end)
	registerOption(obj, state)
	initCallback(obj, o.Default ~= nil, state)
	return finish(obj, frame)
end

function SectionClass:AddSlider(o)
	o = o or {}
	local obj = baseElement("Slider", o)
	local min, max = o.Min or 0, o.Max or 100
	if max <= min then
		max = min + 1
	end
	local inc = o.Increment or 1
	local suffix = o.Suffix or ""
	local decimals = countDecimals(inc)

	local function snap(v)
		v = math.clamp(v, min, max)
		local r = min + math.floor((v - min) / inc + 0.5) * inc
		r = math.clamp(r, min, max)
		return tonumber(string.format("%." .. decimals .. "f", r))
	end

	local value = snap(o.Default or min)
	local frame = elementFrame(self, 48, "Slider")

	local label = new("TextLabel", {
		Position = UDim2.fromOffset(10, 6),
		Size = UDim2.new(1, -90, 0, 16),
		Text = o.Name or "Slider",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = frame,
	})
	themed(label, { TextColor3 = "Text" })
	local valueLabel = new("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 6),
		Size = UDim2.new(0, 76, 0, 16),
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = frame,
	})
	themed(valueLabel, { TextColor3 = "Accent" })

	local bar = new("Frame", {
		Position = UDim2.fromOffset(10, 32),
		Size = UDim2.new(1, -20, 0, 6),
		Parent = frame,
	})
	themed(bar, { BackgroundColor3 = "Stroke" })
	corner(bar, 3)
	local fill = new("Frame", { Size = UDim2.new(0, 0, 1, 0), Parent = bar })
	themed(fill, { BackgroundColor3 = "Accent" })
	corner(fill, 3)
	local knob = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(12, 12),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Parent = fill,
	})
	corner(knob, 6)

	local hit = new("TextButton", {
		Position = UDim2.fromOffset(0, 20),
		Size = UDim2.new(1, 0, 1, -20),
		ZIndex = 5,
		Parent = frame,
	})

	local function render()
		fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
		valueLabel.Text = tostring(value) .. suffix
	end
	render()

	function obj:Set(v, silent)
		v = tonumber(v)
		if not v then
			return
		end
		v = snap(v)
		if v == value then
			return
		end
		value = v
		render()
		setFlag(obj, value)
		if not silent then
			emit(obj, value)
		end
	end
	function obj:Get()
		return value
	end

	local tab = self.Tab
	bindDrag(hit, function(pos)
		local rel = math.clamp((pos.X - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
		obj:Set(min + (max - min) * rel)
	end, function(lock)
		tab:_lock(lock)
	end)

	registerOption(obj, value)
	initCallback(obj, o.Default ~= nil, value)
	return finish(obj, frame)
end

function SectionClass:AddDropdown(o)
	o = o or {}
	local obj = baseElement("Dropdown", o)
	local multi = o.Multi == true
	local options = toStrings(o.Options or o.Values)
	local selected = {}
	local buttons = {}
	local open = false
	local choose, setOpen

	local frame = elementFrame(self, 34, "Dropdown")
	frame.ClipsDescendants = true

	local header = new("TextButton", { Size = UDim2.new(1, 0, 0, 34), ZIndex = 2, Parent = frame })
	hover(frame, header)
	nameLabel(header, o.Name or "Dropdown", 0.5, -10)
	local valueLabel = new("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -28, 0, 0),
		Size = UDim2.new(0.5, -30, 1, 0),
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = header,
	})
	themed(valueLabel, { TextColor3 = "Accent" })
	local arrow = new("TextLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		Text = ">",
		Font = Enum.Font.GothamBold,
		Rotation = 90,
		Parent = header,
	})
	themed(arrow, { TextColor3 = "SubText" })

	local listFrame = new("ScrollingFrame", {
		Position = UDim2.fromOffset(6, 38),
		Size = UDim2.new(1, -12, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 2,
		Parent = frame,
	})
	themed(listFrame, { ScrollBarImageColor3 = "Accent" })
	list(listFrame, 2)

	local function selectedArray()
		local out = {}
		for _, name in ipairs(options) do
			if selected[name] then
				table.insert(out, name)
			end
		end
		return out
	end

	local function current()
		local arr = selectedArray()
		if multi then
			return arr
		end
		return arr[1]
	end

	local function paint(animate)
		local T = Library.Theme
		for _, b in ipairs(buttons) do
			local sel = selected[b.Name] == true
			local props = { BackgroundTransparency = sel and 0.55 or 1, TextColor3 = sel and T.Accent or T.SubText }
			if animate then
				tween(b, 0.12, props)
			else
				b.BackgroundTransparency = props.BackgroundTransparency
				b.TextColor3 = props.TextColor3
			end
		end
		local arr = selectedArray()
		local placeholder = o.Placeholder or "None"
		if #arr == 0 then
			valueLabel.Text = placeholder
		else
			valueLabel.Text = table.concat(arr, ", ")
		end
	end

	local function resize()
		local h = math.min(#options * 28, 140)
		listFrame.Size = UDim2.new(1, -12, 0, h)
		if open then
			tween(frame, 0.18, { Size = UDim2.new(1, 0, 0, 38 + h + 6) })
		end
	end

	local function rebuild()
		for _, b in ipairs(buttons) do
			b:Destroy()
		end
		buttons = {}
		for i, name in ipairs(options) do
			local b = new("TextButton", {
				Name = name,
				LayoutOrder = i,
				Size = UDim2.new(1, -4, 0, 26),
				Text = name,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = listFrame,
			})
			themed(b, { BackgroundColor3 = "ElementHover" })
			corner(b, 5)
			padding(b, 8, 0, 8, 0)
			b.Activated:Connect(function()
				choose(name)
			end)
			table.insert(buttons, b)
		end
		resize()
		paint(false)
	end

	function setOpen(v)
		open = v
		local h = v and (38 + math.min(#options * 28, 140) + 6) or 34
		tween(frame, 0.18, { Size = UDim2.new(1, 0, 0, h) })
		tween(arrow, 0.18, { Rotation = v and -90 or 90 })
	end

	function choose(name)
		if multi then
			selected[name] = not selected[name] or nil
		else
			selected = { [name] = true }
		end
		paint(true)
		setFlag(obj, current())
		emit(obj, current())
		if not multi then
			setOpen(false)
		end
	end

	function obj:Set(value, silent)
		local picked = {}
		if multi then
			if type(value) == "table" then
				for k, v in pairs(value) do
					if type(k) == "number" then
						picked[tostring(v)] = true
					elseif v then
						picked[tostring(k)] = true
					end
				end
			end
		elseif value ~= nil then
			picked[tostring(value)] = true
		end
		selected = {}
		for _, name in ipairs(options) do
			if picked[name] then
				selected[name] = true
			end
		end
		paint(true)
		setFlag(obj, current())
		if not silent then
			emit(obj, current())
		end
	end
	function obj:Get()
		return current()
	end
	function obj:IsSelected(name)
		return selected[tostring(name)] == true
	end
	function obj:Refresh(newOptions, keepSelection)
		options = toStrings(newOptions)
		local kept = {}
		if keepSelection ~= false then
			for _, name in ipairs(options) do
				if selected[name] then
					kept[name] = true
				end
			end
		end
		selected = kept
		rebuild()
		setFlag(obj, current())
	end

	header.Activated:Connect(function()
		setOpen(not open)
	end)

	rebuild()
	obj:Set(o.Default, true)
	registerOption(obj, current())
	initCallback(obj, o.Default ~= nil, current())
	return finish(obj, frame)
end

function SectionClass:AddInput(o)
	o = o or {}
	local obj = baseElement("Input", o)
	local numeric = o.Numeric == true
	local value = o.Default ~= nil and tostring(o.Default) or ""
	local frame = elementFrame(self, 34, "Input")
	nameLabel(frame, o.Name or "Input", 0.5, -14)

	local box = new("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.new(0.5, -8, 0, 24),
		BackgroundTransparency = 0,
		Text = value,
		PlaceholderText = o.Placeholder or "Type here...",
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClipsDescendants = true,
		Parent = frame,
	})
	themed(box, { BackgroundColor3 = "Section", TextColor3 = "Text", PlaceholderColor3 = "SubText" })
	corner(box, 5)
	padding(box, 8, 0, 8, 0)
	local boxStroke = themedStroke(box, "Stroke", 1, 0.2)

	local function typed()
		if numeric then
			return tonumber(value)
		end
		return value
	end

	box:GetPropertyChangedSignal("Text"):Connect(function()
		if numeric then
			local clean = string.gsub(box.Text, "[^%d%.%-]", "")
			if clean ~= box.Text then
				box.Text = clean
			end
		end
	end)
	box.Focused:Connect(function()
		tween(boxStroke, 0.12, { Color = Library.Theme.Accent })
	end)

	function obj:Set(v, silent)
		v = tostring(v == nil and "" or v)
		if numeric then
			local n = tonumber(v)
			if n then
				if o.Min then
					n = math.max(n, o.Min)
				end
				if o.Max then
					n = math.min(n, o.Max)
				end
				v = tostring(n)
			end
		end
		box.Text = v
		if v == value then
			return
		end
		value = v
		setFlag(obj, typed())
		if not silent then
			emit(obj, typed())
		end
	end
	function obj:Get()
		return typed()
	end

	box.FocusLost:Connect(function()
		tween(boxStroke, 0.12, { Color = Library.Theme.Stroke })
		obj:Set(box.Text)
	end)

	registerOption(obj, typed())
	initCallback(obj, o.Default ~= nil, typed())
	return finish(obj, frame)
end

function SectionClass:AddKeybind(o)
	o = o or {}
	local obj = baseElement("Keybind", o)
	local key = toKeyCode(o.Default)
	local listening = false
	local frame = elementFrame(self, 34, "Keybind")
	nameLabel(frame, o.Name or "Keybind", 1, -110)

	local btn = new("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(92, 24),
		BackgroundTransparency = 0,
		Text = key and key.Name or "None",
		TextSize = 12,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = frame,
	})
	themed(btn, { BackgroundColor3 = "Section", TextColor3 = "Accent" })
	corner(btn, 5)
	themedStroke(btn, "Stroke", 1, 0.2)

	function obj:Set(k, silent)
		key = toKeyCode(k)
		btn.Text = key and key.Name or "None"
		setFlag(obj, key)
		if not silent then
			safeSpawn(o.Changed, key)
			for _, fn in ipairs(obj._listeners) do
				safeSpawn(fn, key)
			end
		end
	end
	function obj:Get()
		return key
	end

	btn.Activated:Connect(function()
		if listening then
			return
		end
		listening = true
		Library._listening = true
		btn.Text = "..."
	end)

	self.Window:_connect(UserInputService.InputBegan, function(input, gp)
		if listening then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				listening = false
				task.defer(function()
					Library._listening = false
				end)
				if input.KeyCode == Enum.KeyCode.Escape then
					obj:Set(nil)
				else
					obj:Set(input.KeyCode)
				end
			end
			return
		end
		if gp or Library._listening then
			return
		end
		if key and input.KeyCode == key then
			safeSpawn(o.Callback, key)
		end
	end)

	registerOption(obj, key)
	return finish(obj, frame)
end

function SectionClass:AddColorPicker(o)
	o = o or {}
	local obj = baseElement("ColorPicker", o)
	local color = o.Default or Color3.fromRGB(255, 255, 255)
	local h, s, v = color:ToHSV()
	local open = false

	local frame = elementFrame(self, 34, "ColorPicker")
	frame.ClipsDescendants = true
	local header = new("TextButton", { Size = UDim2.new(1, 0, 0, 34), ZIndex = 2, Parent = frame })
	hover(frame, header)
	nameLabel(header, o.Name or "Color", 1, -60)
	local preview = new("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(34, 18),
		BackgroundColor3 = color,
		Parent = header,
	})
	corner(preview, 5)
	themedStroke(preview, "Stroke", 1, 0)

	local body = new("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(8, 40),
		Size = UDim2.new(1, -16, 0, 124),
		Parent = frame,
	})

	local sv = new("Frame", {
		Size = UDim2.new(1, 0, 0, 100),
		BackgroundColor3 = Color3.fromHSV(h, 1, 1),
		Parent = body,
	})
	corner(sv, 6)
	local white = new("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
		ZIndex = 2,
		Parent = sv,
	})
	corner(white, 6)
	new("UIGradient", { Transparency = NumberSequence.new(0, 1), Parent = white })
	local black = new("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.new(0, 0, 0),
		ZIndex = 3,
		Parent = sv,
	})
	corner(black, 6)
	new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0), Parent = black })
	local cursor = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(s, 0, 1 - v, 0),
		Size = UDim2.fromOffset(12, 12),
		BackgroundColor3 = Color3.new(1, 1, 1),
		ZIndex = 4,
		Parent = sv,
	})
	corner(cursor, 6)
	stroke(cursor, Color3.new(0, 0, 0), 1.5, 0)
	local svHit = new("TextButton", { Size = UDim2.new(1, 0, 1, 0), ZIndex = 5, Parent = sv })

	local hue = new("Frame", {
		Position = UDim2.fromOffset(0, 110),
		Size = UDim2.new(1, 0, 0, 14),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = body,
	})
	corner(hue, 5)
	new("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
		}),
		Parent = hue,
	})
	local hueMarker = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(h, 0, 0.5, 0),
		Size = UDim2.new(0, 4, 1, 6),
		BackgroundColor3 = Color3.new(1, 1, 1),
		ZIndex = 3,
		Parent = hue,
	})
	corner(hueMarker, 2)
	stroke(hueMarker, Color3.new(0, 0, 0), 1, 0)
	local hueHit = new("TextButton", { Size = UDim2.new(1, 0, 1, 0), ZIndex = 5, Parent = hue })

	local function update(fire)
		color = Color3.fromHSV(h, s, v)
		sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		cursor.Position = UDim2.new(s, 0, 1 - v, 0)
		hueMarker.Position = UDim2.new(h, 0, 0.5, 0)
		preview.BackgroundColor3 = color
		setFlag(obj, color)
		if fire then
			emit(obj, color)
		end
	end

	function obj:Set(c, silent)
		if typeof(c) ~= "Color3" then
			return
		end
		h, s, v = c:ToHSV()
		update(not silent)
	end
	function obj:Get()
		return color
	end

	local tab = self.Tab
	local function lock(state)
		tab:_lock(state)
	end
	bindDrag(svHit, function(pos)
		s = math.clamp((pos.X - sv.AbsolutePosition.X) / math.max(sv.AbsoluteSize.X, 1), 0, 1)
		v = 1 - math.clamp((pos.Y - sv.AbsolutePosition.Y) / math.max(sv.AbsoluteSize.Y, 1), 0, 1)
		update(true)
	end, lock)
	bindDrag(hueHit, function(pos)
		h = math.clamp((pos.X - hue.AbsolutePosition.X) / math.max(hue.AbsoluteSize.X, 1), 0, 1)
		update(true)
	end, lock)

	header.Activated:Connect(function()
		open = not open
		tween(frame, 0.18, { Size = UDim2.new(1, 0, 0, open and 172 or 34) })
	end)

	registerOption(obj, color)
	initCallback(obj, o.Default ~= nil, color)
	return finish(obj, frame)
end

-- Tab

function TabClass:_lock(state)
	self.Page.ScrollingEnabled = not state
end

function TabClass:AddSection(secOpts, side)
	if type(secOpts) == "string" then
		secOpts = { Name = secOpts, Side = side }
	end
	secOpts = secOpts or {}
	local name = secOpts.Name or "Section"
	local sideName = secOpts.Side or side

	if self.Window.Columns == 1 then
		sideName = "Left"
	elseif sideName ~= "Left" and sideName ~= "Right" then
		sideName = (self._count.Left <= self._count.Right) and "Left" or "Right"
	end
	self._count[sideName] = self._count[sideName] + 1
	local column = sideName == "Left" and self.LeftColumn or self.RightColumn

	local Section = setmetatable({ Tab = self, Window = self.Window, Name = name, _order = 0 }, SectionClass)

	local frame = new("Frame", {
		Name = name,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = column,
	})
	themed(frame, { BackgroundColor3 = "Section" })
	corner(frame, 8)
	themedStroke(frame, "Stroke", 1, 0.4)
	padding(frame, 8, 8, 8, 8)
	list(frame, 6)

	local titleRow = new("Frame", {
		Name = "Title",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20),
		LayoutOrder = 0,
		Parent = frame,
	})
	local pill = new("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 2, 0.5, 0),
		Size = UDim2.fromOffset(3, 14),
		Parent = titleRow,
	})
	themed(pill, { BackgroundColor3 = "Accent" })
	corner(pill, 2)
	local title = new("TextLabel", {
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -12, 1, 0),
		Text = name,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = titleRow,
	})
	themed(title, { TextColor3 = "Text" })

	Section.Frame = frame
	Section.Content = frame
	function Section:SetName(t)
		title.Text = t
	end
	table.insert(self.Sections, Section)
	return Section
end

-- Window

function WindowClass:_connect(signal, fn)
	local c = signal:Connect(fn)
	table.insert(self._conns, c)
	return c
end

function WindowClass:_applyScale(animate)
	local vp = viewport()
	local fit = 1
	if self._autoScale then
		fit = math.min(1, (vp.X * 0.94) / self._width, (vp.Y * 0.9) / self._height)
		fit = math.max(fit, 0.5)
	end
	self._scale = fit * self._userScale
	if self.Visible then
		if animate then
			tween(self.UIScale, 0.15, { Scale = self._scale })
		else
			self.UIScale.Scale = self._scale
		end
	end
end

function WindowClass:SetScale(n)
	self._autoScale = false
	self._userScale = math.clamp(tonumber(n) or 1, 0.4, 2)
	self:_applyScale(true)
end

function WindowClass:SetUserScale(n)
	self._userScale = math.clamp(tonumber(n) or 1, 0.5, 1.5)
	self:_applyScale(true)
end

function WindowClass:SetVisible(v)
	v = v and true or false
	if self.Visible == v then
		return
	end
	self.Visible = v
	self._token = self._token + 1
	local token = self._token
	if v then
		self.Main.Visible = true
		self.UIScale.Scale = self._scale * 0.92
		tween(self.UIScale, 0.2, { Scale = self._scale }, Enum.EasingStyle.Back)
	else
		tween(self.UIScale, 0.15, { Scale = self._scale * 0.92 })
		task.delay(0.15, function()
			if self._token == token and not self.Destroyed then
				self.Main.Visible = false
			end
		end)
	end
end

function WindowClass:Show()
	self:SetVisible(true)
end

function WindowClass:Hide()
	self:SetVisible(false)
end

function WindowClass:Toggle()
	self:SetVisible(not self.Visible)
end

function WindowClass:SetTitle(t)
	self.TitleLabel.Text = tostring(t)
end

function WindowClass:SetSubTitle(t)
	self.SubTitleLabel.Text = tostring(t)
end

function WindowClass:SetCredit(t)
	self.CreditLabel.Text = tostring(t)
	self.CreditLabel.Visible = tostring(t) ~= ""
end

function WindowClass:SetFooter(v)
	if type(v) == "table" then
		self._footerList = v
	else
		self._footerList = { tostring(v) }
	end
	self._footerIndex = 1
	self.FooterLabel.Text = self._footerList[1] or ""
end

function WindowClass:SelectTab(tab)
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
	local T = Library.Theme
	for _, t in ipairs(self.Tabs) do
		local active = (t == tab)
		t.Active = active
		t.Page.Visible = active
		tween(t.Button, 0.15, { BackgroundTransparency = active and 0.85 or 1 })
		tween(t.Label, 0.15, { TextColor3 = active and T.Accent or T.SubText })
		if t.IconImage then
			tween(t.IconImage, 0.15, { ImageColor3 = active and T.Accent or T.SubText })
		end
	end
	self.ActiveTab = tab
end

function WindowClass:AddTab(tabOpts)
	if type(tabOpts) == "string" then
		tabOpts = { Name = tabOpts }
	end
	tabOpts = tabOpts or {}
	local name = tabOpts.Name or "Tab"
	local Tab = setmetatable({
		Name = name,
		Window = self,
		Sections = {},
		Active = false,
		_count = { Left = 0, Right = 0 },
	}, TabClass)

	local button = new("TextButton", {
		Name = name,
		Size = UDim2.new(0, 0, 1, -6),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		LayoutOrder = #self.Tabs + 1,
		Parent = self.TabScroll,
	})
	themed(button, { BackgroundColor3 = "Accent" })
	corner(button, 7)
	padding(button, 12, 0, 12, 0)
	local btnLayout = list(button, 6, Enum.FillDirection.Horizontal)
	btnLayout.VerticalAlignment = Enum.VerticalAlignment.Center

	if tabOpts.Icon then
		Tab.IconImage = new("ImageLabel", {
			Size = UDim2.fromOffset(16, 16),
			Image = normalizeIcon(tabOpts.Icon),
			LayoutOrder = 1,
			Parent = button,
		})
		themed(Tab.IconImage, {
			ImageColor3 = function(t)
				return Tab.Active and t.Accent or t.SubText
			end,
		})
	end
	local label = new("TextLabel", {
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Text = name,
		LayoutOrder = 2,
		Parent = button,
	})
	themed(label, {
		TextColor3 = function(t)
			return Tab.Active and t.Accent or t.SubText
		end,
	})
	Tab.Button = button
	Tab.Label = label

	local page = new("ScrollingFrame", {
		Name = name,
		Size = UDim2.new(1, 0, 1, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Visible = false,
		Parent = self.Pages,
	})
	themed(page, { ScrollBarImageColor3 = "Accent" })
	padding(page, 12, 4, 12, 12)

	local columns = new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = page,
	})
	list(columns, 8, Enum.FillDirection.Horizontal)

	local single = self.Columns == 1
	local left = new("Frame", {
		Name = "Left",
		BackgroundTransparency = 1,
		Size = single and UDim2.new(1, 0, 0, 0) or UDim2.new(0.5, -4, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 1,
		Parent = columns,
	})
	list(left, 8)
	local right = new("Frame", {
		Name = "Right",
		BackgroundTransparency = 1,
		Size = UDim2.new(0.5, -4, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
		Visible = not single,
		Parent = columns,
	})
	list(right, 8)

	Tab.Page = page
	Tab.LeftColumn = left
	Tab.RightColumn = right

	button.Activated:Connect(function()
		self:SelectTab(Tab)
	end)

	table.insert(self.Tabs, Tab)
	if #self.Tabs == 1 then
		self:SelectTab(Tab)
	end
	return Tab
end

-- แท็บ Home สำเร็จรูป แสดงข้อมูลเซิร์ฟเวอร์และผู้ใช้
function WindowClass:AddHomeTab(h)
	h = h or {}
	local tab = self:AddTab({ Name = h.Name or "Home", Icon = h.Icon })
	local server = tab:AddSection("Server Info", "Left")
	local user = tab:AddSection("User Info", "Right")

	local gameLabel = server:AddLabel("Game : ...")
	server:AddLabel("Server Id : " .. (game.JobId ~= "" and game.JobId or "Studio"))
	local playersLabel = server:AddLabel("Players : -")
	local timeLabel = server:AddLabel("Time : -")

	user:AddLabel("Name : " .. LocalPlayer.Name)
	user:AddLabel("Display : " .. LocalPlayer.DisplayName)
	user:AddLabel("Version : " .. tostring(h.Version or Library.Version))
	user:AddLabel("UserId : " .. LocalPlayer.UserId)

	task.spawn(function()
		local ok, info = pcall(function()
			return MarketplaceService:GetProductInfo(game.PlaceId)
		end)
		gameLabel:Set("Game : " .. ((ok and info and info.Name) or game.Name))
	end)
	task.spawn(function()
		while not Library.Unloaded and not self.Destroyed do
			pcall(function()
				playersLabel:Set("Players : " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers)
				timeLabel:Set("Time : " .. os.date("%H:%M:%S"))
			end)
			task.wait(1)
		end
	end)
	return tab
end

-- แท็บ Settings สำเร็จรูป: ธีม, ขนาด UI, ปุ่มเปิดปิด, คอนฟิก
function WindowClass:AddSettingsTab(s)
	s = s or {}
	local tab = self:AddTab({ Name = s.Name or "Settings", Icon = s.Icon })
	local ui = tab:AddSection("Interface", "Left")

	local names = {}
	for name in pairs(Library.Themes) do
		table.insert(names, name)
	end
	table.sort(names)
	ui:AddDropdown({
		Name = "Theme",
		Options = names,
		Default = Library.ThemeName,
		NoInitCallback = true,
		Callback = function(v)
			Library:SetTheme(v)
		end,
	})
	ui:AddSlider({
		Name = "UI Scale",
		Min = 60,
		Max = 140,
		Default = 100,
		Increment = 5,
		Suffix = "%",
		NoInitCallback = true,
		Callback = function(v)
			self:SetUserScale(v / 100)
		end,
	})
	if not Library.IsMobile then
		ui:AddKeybind({
			Name = "Toggle Key",
			Default = self.ToggleKey,
			Changed = function(k)
				self.ToggleKey = k
			end,
		})
	end
	ui:AddButton({
		Name = "Unload UI",
		Callback = function()
			Library:Unload()
		end,
	})

	local cfg = tab:AddSection("Config", "Right")
	local nameInput = cfg:AddInput({ Name = "Config Name", Default = "default", Placeholder = "name" })
	local configList = cfg:AddDropdown({ Name = "Configs", Options = Library:GetConfigs(), Placeholder = "None" })
	cfg:AddButton({
		Name = "Save Config",
		Callback = function()
			local ok, err = Library:SaveConfig(nameInput:Get())
			Library:Notify({
				Title = "Config",
				Content = ok and "Saved" or tostring(err),
				Type = ok and "Success" or "Error",
			})
			configList:Refresh(Library:GetConfigs())
		end,
	})
	cfg:AddButton({
		Name = "Load Config",
		Callback = function()
			local pick = configList:Get() or nameInput:Get()
			local ok, err = Library:LoadConfig(pick)
			Library:Notify({
				Title = "Config",
				Content = ok and ("Loaded " .. tostring(pick)) or tostring(err),
				Type = ok and "Success" or "Error",
			})
		end,
	})
	cfg:AddButton({
		Name = "Refresh List",
		Callback = function()
			configList:Refresh(Library:GetConfigs())
		end,
	})
	return tab
end

function WindowClass:Destroy()
	if self.Destroyed then
		return
	end
	self.Destroyed = true
	for _, c in ipairs(self._conns) do
		pcall(function()
			c:Disconnect()
		end)
	end
	if self.ToggleButton then
		pcall(function()
			self.ToggleButton:Destroy()
		end)
	end
	pcall(function()
		self.Main:Destroy()
	end)
	for i, w in ipairs(Library.Windows) do
		if w == self then
			table.remove(Library.Windows, i)
			break
		end
	end
end

-- สร้างหน้าต่างหลัก
-- ตัวเลือก: Title, SubTitle, Icon, Theme, Accent, Size, ToggleKey, ToggleButton, Footer, Credit, Columns, ConfigFolder
function Library:CreateWindow(opts)
	if type(opts) == "string" then
		opts = { Title = opts }
	end
	opts = opts or {}
	local gui = self:_ensureGui()

	if opts.Theme then
		self:SetTheme(opts.Theme)
	end
	if typeof(opts.Accent) == "Color3" then
		self:SetAccent(opts.Accent)
	end
	if opts.ConfigFolder then
		self.ConfigFolder = opts.ConfigFolder
	end
	if opts.NotifyPosition then
		self:SetNotifyPosition(opts.NotifyPosition)
	end

	local width, height
	if typeof(opts.Size) == "UDim2" then
		width, height = opts.Size.X.Offset, opts.Size.Y.Offset
	elseif typeof(opts.Size) == "Vector2" then
		width, height = opts.Size.X, opts.Size.Y
	elseif self.IsMobile then
		width, height = 470, 290
	else
		width, height = 580, 380
	end

	local toggleKey = Enum.KeyCode.RightShift
	if opts.ToggleKey == false then
		toggleKey = nil
	elseif opts.ToggleKey ~= nil then
		toggleKey = toKeyCode(opts.ToggleKey) or toggleKey
	end

	local Window = setmetatable({
		Title = opts.Title or self.Name,
		Tabs = {},
		ActiveTab = nil,
		Visible = true,
		Destroyed = false,
		Columns = opts.Columns == 1 and 1 or 2,
		ToggleKey = toggleKey,
		_conns = {},
		_userScale = 1,
		_autoScale = opts.AutoScale ~= false,
		_scale = 1,
		_token = 0,
		_width = width,
		_height = height,
	}, WindowClass)

	local Main = new("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.fromOffset(width, height),
		ClipsDescendants = true,
		Parent = gui,
	})
	themed(Main, { BackgroundColor3 = "Background" })
	corner(Main, 10)
	local mainStroke = stroke(Main, self.Theme.Accent, 1.2, 0.15)
	themed(mainStroke, { Color = "Accent" })
	local UIScale = new("UIScale", { Parent = Main })
	Window.Main = Main
	Window.UIScale = UIScale

	-- ส่วนหัว: โลโก้ ชื่อ ปุ่มย่อ/ปิด
	local Header = new("Frame", {
		Name = "Header",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 58),
		Parent = Main,
	})
	if opts.Icon then
		new("ImageLabel", {
			Size = UDim2.fromOffset(40, 40),
			Position = UDim2.fromOffset(14, 9),
			Image = normalizeIcon(opts.Icon),
			Parent = Header,
		})
	else
		local logo = new("Frame", {
			Size = UDim2.fromOffset(40, 40),
			Position = UDim2.fromOffset(14, 9),
			Parent = Header,
		})
		themed(logo, { BackgroundColor3 = "Accent" })
		corner(logo, 10)
		new("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			Text = string.upper(string.sub(Window.Title, 1, 1)),
			Font = Enum.Font.GothamBold,
			TextSize = 22,
			TextColor3 = Color3.fromRGB(10, 12, 12),
			Parent = logo,
		})
	end

	local titleLabel = new("TextLabel", {
		Position = UDim2.fromOffset(64, 9),
		Size = UDim2.new(1, -140, 0, 22),
		Text = Window.Title,
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = Header,
	})
	themed(titleLabel, { TextColor3 = "Text" })
	local subTitleLabel = new("TextLabel", {
		Position = UDim2.fromOffset(64, 31),
		Size = UDim2.new(1, -140, 0, 16),
		Text = opts.SubTitle or ("User : " .. LocalPlayer.Name),
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = Header,
	})
	themed(subTitleLabel, { TextColor3 = "SubText" })
	Window.TitleLabel = titleLabel
	Window.SubTitleLabel = subTitleLabel

	local function headerButton(text, xOffset)
		local b = new("TextButton", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, xOffset, 0, 15),
			Size = UDim2.fromOffset(28, 28),
			BackgroundTransparency = 0,
			Text = text,
			Font = Enum.Font.GothamBold,
			TextSize = 18,
			Parent = Header,
		})
		themed(b, { BackgroundColor3 = "Element", TextColor3 = "Text" })
		corner(b, 7)
		return b
	end
	local closeBtn = headerButton("×", -12)
	local minBtn = headerButton("–", -46)

	local closeArmed = false
	closeBtn.Activated:Connect(function()
		if closeArmed then
			Window:Destroy()
			if #Library.Windows == 0 then
				Library:Unload()
			end
			return
		end
		-- กดครั้งแรกให้ยืนยันก่อน กันกดพลาดบนมือถือ
		closeArmed = true
		closeBtn.Text = "?"
		tween(closeBtn, 0.15, { BackgroundColor3 = Library.Status.Error })
		task.delay(2, function()
			if closeArmed and not Window.Destroyed then
				closeArmed = false
				closeBtn.Text = "×"
				tween(closeBtn, 0.15, { BackgroundColor3 = Library.Theme.Element })
			end
		end)
	end)
	minBtn.Activated:Connect(function()
		Window:Hide()
		if not Window.ToggleButton and Window.ToggleKey then
			Library:Notify({
				Title = Window.Title,
				Content = "Press " .. Window.ToggleKey.Name .. " to open the UI again",
				Duration = 3,
			})
		end
	end)

	table.insert(Window._conns, makeDraggable(Header, Main, {
		Scale = function()
			return UIScale.Scale
		end,
		Clamp = function(x, y)
			local vp = viewport()
			local mx, my = vp.X / 2 - 50, vp.Y / 2 - 30
			return math.clamp(x, -mx, mx), math.clamp(y, -my, my)
		end,
	}))

	-- แถบแท็บ
	local TabBar = new("Frame", {
		Name = "TabBar",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 58),
		Size = UDim2.new(1, 0, 0, 34),
		Parent = Main,
	})
	local TabScroll = new("ScrollingFrame", {
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -24, 1, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		ScrollingDirection = Enum.ScrollingDirection.X,
		ScrollBarThickness = 0,
		Parent = TabBar,
	})
	local tabLayout = list(TabScroll, 6, Enum.FillDirection.Horizontal)
	tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	Window.TabScroll = TabScroll

	-- พื้นที่แสดงหน้า
	local Pages = new("Frame", {
		Name = "Pages",
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Position = UDim2.fromOffset(0, 96),
		Size = UDim2.new(1, 0, 1, -134),
		Parent = Main,
	})
	Window.Pages = Pages

	-- ส่วนท้าย: คำแนะนำ + เครดิต
	local Footer = new("Frame", {
		Name = "Footer",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 38),
		Parent = Main,
	})
	local footerLine = new("Frame", {
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -24, 0, 1),
		BackgroundTransparency = 0.5,
		Parent = Footer,
	})
	themed(footerLine, { BackgroundColor3 = "Stroke" })
	local footerLabel = new("TextLabel", {
		Position = UDim2.fromOffset(12, 4),
		Size = UDim2.new(1, -24, 0, 16),
		TextSize = 12,
		Parent = Footer,
	})
	themed(footerLabel, { TextColor3 = "SubText" })
	local creditLabel = new("TextLabel", {
		Position = UDim2.fromOffset(12, 20),
		Size = UDim2.new(1, -24, 0, 16),
		TextSize = 12,
		Parent = Footer,
	})
	themed(creditLabel, { TextColor3 = "Accent" })
	Window.FooterLabel = footerLabel
	Window.CreditLabel = creditLabel

	local defaultFooter
	if self.IsMobile then
		defaultFooter = "Tap the floating button to open or close the UI"
	elseif toggleKey then
		defaultFooter = "Press " .. toggleKey.Name .. " to open or close the UI"
	else
		defaultFooter = ""
	end
	Window:SetFooter(opts.Footer or defaultFooter)
	Window:SetCredit(opts.Credit or ("Powered by " .. self.Name))

	-- วนข้อความคำแนะนำถ้าใส่เป็น list
	task.spawn(function()
		while not Window.Destroyed and not Library.Unloaded do
			task.wait(4)
			local items = Window._footerList
			if items and #items > 1 and not Window.Destroyed then
				pcall(function()
					Window._footerIndex = Window._footerIndex % #items + 1
					tween(footerLabel, 0.2, { TextTransparency = 1 })
					task.wait(0.2)
					footerLabel.Text = items[Window._footerIndex]
					tween(footerLabel, 0.2, { TextTransparency = 0 })
				end)
			end
		end
	end)

	-- ปุ่มลอยสำหรับเปิด/ปิด (ค่าเริ่มต้นเปิดเฉพาะมือถือ) ลากย้ายได้
	local showToggle = opts.ToggleButton
	if showToggle == nil then
		showToggle = self.IsMobile
	end
	if showToggle then
		local vp = viewport()
		local tb = new("TextButton", {
			Name = "ToggleButton",
			Size = UDim2.fromOffset(46, 46),
			Position = UDim2.fromOffset(16, math.floor(vp.Y * 0.4)),
			BackgroundTransparency = 0,
			Text = opts.Icon and "" or string.upper(string.sub(Window.Title, 1, 1)),
			Font = Enum.Font.GothamBold,
			TextSize = 20,
			TextColor3 = Color3.fromRGB(10, 12, 12),
			ZIndex = 10,
			Parent = gui,
		})
		themed(tb, { BackgroundColor3 = "Accent" })
		corner(tb, 23)
		stroke(tb, Color3.new(0, 0, 0), 1, 0.6)
		if opts.Icon then
			new("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.fromOffset(30, 30),
				Image = normalizeIcon(opts.Icon),
				Parent = tb,
			})
		end
		Window.ToggleButton = tb
		table.insert(Window._conns, makeDraggable(tb, tb, {
			OnClick = function()
				Window:Toggle()
			end,
			Clamp = function(x, y)
				local v = viewport()
				return math.clamp(x, 0, v.X - 46), math.clamp(y, 0, v.Y - 46)
			end,
		}))
	end

	-- ปุ่มลัดบน PC
	Window:_connect(UserInputService.InputBegan, function(input, gp)
		if gp or Library._listening or Window.Destroyed then
			return
		end
		if Window.ToggleKey and input.KeyCode == Window.ToggleKey then
			Window:Toggle()
		end
	end)

	-- ปรับขนาดให้พอดีหน้าจอ
	local cam = Workspace.CurrentCamera
	if cam then
		Window:_connect(cam:GetPropertyChangedSignal("ViewportSize"), function()
			Window:_applyScale(true)
		end)
	end
	Window:_applyScale(false)
	UIScale.Scale = Window._scale * 0.9
	tween(UIScale, 0.25, { Scale = Window._scale }, Enum.EasingStyle.Back)

	table.insert(self.Windows, Window)
	return Window
end

Library.Create = new
Library.Tween = tween

Env.QuickLibrary = Library
return Library
