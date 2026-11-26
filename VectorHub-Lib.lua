local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local CoreGui          = game:GetService("CoreGui")
local Workspace        = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local library = {
    Version = "1.0",
    WorkspaceName = "Vector Hub",
    flags = {},
    elements = {},
    signals = {},
    subs = {},
    configuration = {
        hideKeybind = Enum.KeyCode.RightShift,
        searchKeybind = Enum.KeyCode.F,
    },
}
library.Flags = library.flags
library.Subs = library.subs

if shared.VectorUILibrary then
    pcall(function() shared.VectorUILibrary.Unload() end)
end
shared.VectorUILibrary = library

local colors = {
    accent     = Color3.fromRGB(34, 94, 255),
    accentDark = Color3.fromRGB(16, 44, 140),
    window     = Color3.fromRGB(3, 3, 5),
    panel      = Color3.fromRGB(9, 9, 12),
    row        = Color3.fromRGB(15, 15, 18),
    rowHover   = Color3.fromRGB(23, 23, 29),
    field      = Color3.fromRGB(22, 22, 27),
    line       = Color3.fromRGB(36, 36, 46),
    text       = Color3.fromRGB(240, 242, 250),
    subtext    = Color3.fromRGB(142, 148, 168),
    tabFill    = Color3.fromRGB(7, 10, 20),
    tabActive  = Color3.fromRGB(11, 21, 50),
    search     = Color3.fromRGB(5, 8, 18),
}
library.colors = colors

local accented, darkAccented, refreshers = {}, {}, {}

local function accent(inst, prop, dark)
    table.insert(dark and darkAccented or accented, { inst, prop })
    inst[prop] = dark and colors.accentDark or colors.accent
    return inst
end

local function onAccent(fn)
    table.insert(refreshers, fn)
end

function library.SetAccent(a, b)
    local c = (a == library) and b or a
    if typeof(c) ~= "Color3" then return end
    colors.accent = c
    colors.accentDark = Color3.new(c.R * 0.45, c.G * 0.45, c.B * 0.45)
    for _, list in ipairs({ accented, darkAccented }) do
        local dark = (list == darkAccented)
        for i = #list, 1, -1 do
            local e = list[i]
            if e[1] and e[1].Parent then
                e[1][e[2]] = dark and colors.accentDark or colors.accent
            else
                table.remove(list, i)
            end
        end
    end
    for _, fn in ipairs(refreshers) do pcall(fn) end
end

local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(library.signals, c)
    return c
end

local function new(class, props, kids)
    local inst = Instance.new(class)
    local parent
    for k, v in pairs(props or {}) do
        if k == "Parent" then parent = v else inst[k] = v end
    end
    for _, kid in ipairs(kids or {}) do kid.Parent = inst end
    inst.Parent = parent
    return inst
end

local function round(parent, r)
    return new("UICorner", { CornerRadius = UDim.new(0, r), Parent = parent })
end

local function outline(parent, color, thickness, transparency)
    return new("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function padding(parent, l, t, r, b)
    t = t or l
    return new("UIPadding", {
        PaddingLeft = UDim.new(0, l), PaddingTop = UDim.new(0, t),
        PaddingRight = UDim.new(0, r or l), PaddingBottom = UDim.new(0, b or t),
        Parent = parent,
    })
end

local function listLayout(parent, gap, dir, ha, va)
    return new("UIListLayout", {
        Padding = UDim.new(0, gap or 0),
        FillDirection = dir or Enum.FillDirection.Vertical,
        HorizontalAlignment = ha or Enum.HorizontalAlignment.Left,
        VerticalAlignment = va or Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = parent,
    })
end

local function textOf(parent, props)
    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.BorderSizePixel = 0
    t.Font = Enum.Font.GothamMedium
    t.TextSize = 14
    t.TextColor3 = colors.text
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.TextTruncate = Enum.TextTruncate.AtEnd
    for k, v in pairs(props or {}) do t[k] = v end
    t.Parent = parent
    return t
end

local function tween(inst, props, dur)
    local t = TweenService:Create(inst, TweenInfo.new(dur or 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function isPress(i)
    return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end

local function isMove(i)
    return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch
end

local function dragSession(input, onMove, onEnd)
    local moveConn = UserInputService.InputChanged:Connect(function(i)
        if isMove(i) then onMove(i.Position) end
    end)
    local endConn
    endConn = input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
            moveConn:Disconnect()
            endConn:Disconnect()
            if onEnd then onEnd() end
        end
    end)
end

local function bindDrag(area, getScroll, onMove)
    connect(area.InputBegan, function(input)
        if not isPress(input) then return end
        local sc = getScroll and getScroll()
        if sc then sc.ScrollingEnabled = false end
        onMove(input.Position)
        dragSession(input, onMove, function()
            if sc then sc.ScrollingEnabled = true end
        end)
    end)
end

local function pick(o, ...)
    for i = 1, select("#", ...) do
        local v = o[select(i, ...)]
        if v ~= nil then return v end
    end
    return nil
end

local function A(obj, a, b)
    if a == obj then return b end
    return a
end

local argOrder = {
    Window      = { "Name", "Theme" },
    Tab         = { "Name", "Image" },
    Section     = { "Name", "Side" },
    Label       = { "Text", "Flag" },
    Toggle      = { "Name", "Value", "Callback", "Flag" },
    Button      = { "Name", "Callback" },
    Slider      = { "Name", "Value", "Callback", "Flag", "Location", "LocationFlag", "UnloadValue", "UnloadFunc", "Min", "Max", "Decimals" },
    Dropdown    = { "Name", "Value", "Callback", "Flag", "Location", "LocationFlag", "UnloadValue", "UnloadFunc", "List" },
    Textbox     = { "Name", "Value", "Callback", "Flag" },
    Keybind     = { "Name", "Value", "Callback", "Flag" },
    Colorpicker = { "Name", "Value", "Callback", "Flag" },
}

local function resolve(kind, first, ...)
    if type(first) == "table" then return first end
    local o = {}
    local map = argOrder[kind]
    local args = table.pack(first, ...)
    for i = 1, args.n do
        if map[i] ~= nil and args[i] ~= nil then o[map[i]] = args[i] end
    end
    return o
end

local function commit(o, value)
    if o.Flag then library.flags[o.Flag] = value end
    if o.Location and o.LocationFlag then o.Location[o.LocationFlag] = value end
end

local function register(o, obj)
    if o.Flag then library.elements[o.Flag] = obj end
end

local function spawnCallback(fn, ...)
    if type(fn) == "function" then task.spawn(fn, ...) end
end

local function mountGui(gui)
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 999
    if syn and syn.protect_gui then pcall(syn.protect_gui, gui) end
    local ok = false
    if gethui then
        ok = pcall(function() gui.Parent = gethui() end)
    end
    if not ok or not gui.Parent then
        ok = pcall(function() gui.Parent = CoreGui end)
    end
    if not ok or not gui.Parent then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end

local function ensureGui()
    if library.gui and library.gui.Parent then return library.gui end
    local gui = Instance.new("ScreenGui")
    gui.Name = "VectorUI"
    mountGui(gui)
    library.gui = gui

    local holder = new("Frame", {
        Name = "Notifications",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -16, 1, -16),
        Size = UDim2.new(0, 280, 1, -32),
        Parent = gui,
    })
    listLayout(holder, 8, nil, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom)
    library.notifyHolder = holder
    return gui
end

local function makeLogo(parent, size, image, letter)
    if image then
        return new("ImageLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(size, size),
            Image = (type(image) == "number") and ("rbxassetid://" .. image) or tostring(image),
            Parent = parent,
        })
    end
    local f = new("Frame", {
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(size, size),
        Parent = parent,
    })
    round(f, math.floor(size * 0.3))
    new("UIGradient", {
        Rotation = 45,
        Color = ColorSequence.new(Color3.fromRGB(120, 170, 255), Color3.fromRGB(20, 50, 210)),
        Parent = f,
    })
    textOf(f, {
        Size = UDim2.fromScale(1, 1),
        Text = letter or "V",
        Font = Enum.Font.GothamBlack,
        TextSize = math.floor(size * 0.58),
        TextXAlignment = Enum.TextXAlignment.Center,
        TextColor3 = Color3.new(1, 1, 1),
    })
    return f
end

function library.Notify(a, b, c, d)
    local o
    if a == library then a, b, c = b, c, d end
    if type(a) == "table" then
        o = a
    else
        o = { Title = a, Text = b, Duration = c }
    end
    ensureGui()
    local toast = new("CanvasGroup", {
        BackgroundColor3 = colors.window,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        GroupTransparency = 1,
        Parent = library.notifyHolder,
    })
    round(toast, 9)
    accent(outline(toast, colors.accent, 1.5), "Color")
    padding(toast, 12, 10)
    listLayout(toast, 3)
    accent(textOf(toast, {
        Text = tostring(o.Title or "Vector Hub"),
        Size = UDim2.new(1, 0, 0, 18),
        Font = Enum.Font.GothamBold,
        LayoutOrder = 1,
    }), "TextColor3")
    if o.Text then
        textOf(toast, {
            Text = tostring(o.Text),
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            TextWrapped = true,
            TextTruncate = Enum.TextTruncate.None,
            TextSize = 13,
            TextColor3 = colors.subtext,
            LayoutOrder = 2,
        })
    end
    tween(toast, { GroupTransparency = 0 }, 0.2)
    task.delay(tonumber(o.Duration) or 4, function()
        if toast.Parent then
            tween(toast, { GroupTransparency = 1 }, 0.25).Completed:Wait()
            toast:Destroy()
        end
    end)
    return toast
end
library.Notification = library.Notify

local function encode(kind, v)
    if kind == "Colorpicker" then
        return { v.R, v.G, v.B }
    elseif kind == "Keybind" then
        return v and v.Name or "None"
    end
    return v
end

local function decode(kind, v)
    if kind == "Colorpicker" then
        if type(v) == "table" and v[1] and v[2] and v[3] then
            return Color3.new(v[1], v[2], v[3])
        end
        return nil
    elseif kind == "Keybind" then
        if v == nil or v == "None" then return nil end
        local ok, key = pcall(function() return Enum.KeyCode[v] end)
        return ok and key or nil
    end
    return v
end

function library.GetConfigJSON()
    local data = {}
    for flag, obj in pairs(library.elements) do
        if obj.Get and obj.Type ~= "Button" and obj.Type ~= "Label" then
            data[flag] = encode(obj.Type, obj.Get())
        end
    end
    return HttpService:JSONEncode(data)
end

function library.LoadConfigJSON(a, b)
    local json = (a == library) and b or a
    local ok, data = pcall(HttpService.JSONDecode, HttpService, json)
    if not ok or type(data) ~= "table" then return false, "JSON ไม่ถูกต้อง" end
    for flag, v in pairs(data) do
        local obj = library.elements[flag]
        if obj and obj.Set and obj.Type ~= "Button" and obj.Type ~= "Label" then
            local value = decode(obj.Type, v)
            if value ~= nil or obj.Type == "Keybind" then
                pcall(obj.Set, obj, value)
            end
        end
    end
    return true
end

local function configPath(name)
    return library.WorkspaceName .. "/" .. tostring(name) .. ".json"
end

function library.SaveConfig(a, b)
    local name = (a == library) and b or a
    if not writefile then return false, "executor ไม่รองรับ writefile" end
    if makefolder and isfolder and not isfolder(library.WorkspaceName) then
        pcall(makefolder, library.WorkspaceName)
    end
    return pcall(writefile, configPath(name), library.GetConfigJSON())
end

function library.LoadConfig(a, b)
    local name = (a == library) and b or a
    if not (readfile and isfile) then return false, "executor ไม่รองรับ readfile" end
    local path = configPath(name)
    if not isfile(path) then return false, "ไม่พบไฟล์คอนฟิก" end
    return library.LoadConfigJSON(readfile(path))
end

function library.ListConfigs()
    local out = {}
    if listfiles and isfolder and isfolder(library.WorkspaceName) then
        local ok, files = pcall(listfiles, library.WorkspaceName)
        if ok then
            for _, f in ipairs(files) do
                local n = string.match(f, "([^/\\]+)%.json$")
                if n then table.insert(out, n) end
            end
        end
    end
    return out
end

local Window, Tab, Section = {}, {}, {}
Window.__index, Tab.__index, Section.__index = Window, Tab, Section

local function newRow(height, clickable)
    local row = Instance.new(clickable and "TextButton" or "Frame")
    row.BackgroundColor3 = colors.row
    row.BorderSizePixel = 0
    row.Size = UDim2.new(1, 0, 0, height)
    if clickable then
        row.Text = ""
        row.AutoButtonColor = false
        connect(row.MouseEnter, function() tween(row, { BackgroundColor3 = colors.rowHover }, 0.12) end)
        connect(row.MouseLeave, function() tween(row, { BackgroundColor3 = colors.row }, 0.12) end)
    end
    round(row, 7)
    return row
end

local function titleBlock(parent, name, sub, x, rightPad, align, topY)
    align = align or Enum.TextXAlignment.Left
    local holder = new("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = topY and Vector2.new(0, 0) or Vector2.new(0, 0.5),
        Position = topY and UDim2.new(0, x, 0, topY) or UDim2.new(0, x, 0.5, 0),
        Size = UDim2.new(1, -(x + rightPad), 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = parent,
    })
    listLayout(holder, 1, nil, (align == Enum.TextXAlignment.Center) and Enum.HorizontalAlignment.Center or Enum.HorizontalAlignment.Left)
    local n = textOf(holder, { Text = name, Size = UDim2.new(1, 0, 0, 17), LayoutOrder = 1, TextXAlignment = align })
    local s
    if sub and sub ~= "" then
        s = textOf(holder, {
            Text = tostring(sub), Size = UDim2.new(1, 0, 0, 14), TextSize = 11,
            TextColor3 = colors.subtext, LayoutOrder = 2, TextXAlignment = align,
        })
    end
    return holder, n, s
end

local function makeKeyChip(parent, initial, onChange, onPress)
    local key = initial
    local listening = false
    local chip = new("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(78, 24),
        BackgroundColor3 = colors.field,
        AutoButtonColor = false,
        Text = "",
        BorderSizePixel = 0,
        Parent = parent,
    })
    round(chip, 6)
    local chipStroke = outline(chip, colors.line, 1)
    local txt = textOf(chip, {
        Size = UDim2.new(1, -8, 1, 0), Position = UDim2.fromOffset(4, 0),
        TextSize = 12, TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = colors.subtext,
    })
    local function show()
        txt.Text = listening and "..." or (key and key.Name or "None")
        txt.TextColor3 = listening and colors.accent or colors.subtext
        chipStroke.Color = listening and colors.accent or colors.line
    end
    show()
    connect(chip.Activated, function()
        listening = true
        show()
    end)
    connect(UserInputService.InputBegan, function(input, gp)
        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                listening = false
                local old = key
                if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
                    key = nil
                else
                    key = input.KeyCode
                end
                show()
                onChange(key, old)
            end
            return
        end
        if not gp and key and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == key then
            onPress(input)
        end
    end)
    return {
        Get = function() return key end,
        Set = function(k, silent)
            local old = key
            key = k
            show()
            if not silent then onChange(key, old) end
        end,
    }
end

function Section:_register(frame, text)
    self._order = self._order + 1
    frame.LayoutOrder = self._order
    frame.Parent = self.content
    local entry = { frame = frame, text = string.lower(text or "") }
    table.insert(self.entries, entry)
    return entry
end

function Section:AddLabel(...)
    local o = resolve("Label", ...)
    local text = tostring(pick(o, "Text", "Value", "Name") or "")
    local lbl = textOf(nil, {
        Text = text,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        TextWrapped = true,
        TextTruncate = Enum.TextTruncate.None,
        TextSize = 13,
        TextColor3 = colors.subtext,
        RichText = pick(o, "Rich", "RichText") and true or false,
    })
    padding(lbl, 4, 3)
    local entry = self:_register(lbl, text)
    local obj = { Type = "Label", Name = text, Options = o, Parent = self, Instance = lbl }
    obj.Set = function(a, b)
        local t = tostring(A(obj, a, b))
        lbl.Text = t
        entry.text = string.lower(t)
        commit(o, t)
        return t
    end
    obj.RawSet = obj.Set
    obj.Get = function() return lbl.Text end
    obj.Update = obj.Get
    obj.Reset = function() lbl.Text = text return text end
    commit(o, text)
    register(o, obj)
    return obj
end

function Section:AddToggle(...)
    local o = resolve("Toggle", ...)
    local name = tostring(pick(o, "Name", "Text") or "Toggle")
    local sub = pick(o, "Sub", "Description", "Subtitle")
    local state = pick(o, "Value", "Enabled", "Default") == true
    local default = state
    local locked = pick(o, "Locked") == true
    local row = newRow(sub and 48 or 38, true)

    local box = new("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 12, 0.5, 0),
        Size = UDim2.fromOffset(22, 22),
        BackgroundColor3 = colors.field,
        BorderSizePixel = 0,
        Parent = row,
    })
    round(box, 6)
    local boxStroke = outline(box, colors.line, 1)
    local check = new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false, Parent = box })
    for _, s in ipairs({ { 6, 45, 7.5, 13 }, { 12, -45, 13.5, 11 } }) do
        local bar = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromOffset(s[3], s[4]),
            Size = UDim2.fromOffset(s[1], 2.5),
            Rotation = s[2],
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            Parent = check,
        })
        round(bar, 2)
    end

    local paint
    local function setState(v, silent)
        v = v and true or false
        if v == state then return state end
        if not silent and o.Condition and not o.Condition(v, state) then return state end
        local old = state
        state = v
        commit(o, state)
        paint()
        if not silent then spawnCallback(o.Callback, state, old) end
        return state
    end

    local holder, nameLabel = titleBlock(row, name, sub, 46, 10)

    local kb = pick(o, "Keybind", "Key", "KeyBind")
    local chipCtl
    if kb then
        local kbo = (type(kb) == "table") and kb or {}
        local initialKey = (typeof(kb) == "EnumItem") and kb or kbo.Value
        chipCtl = makeKeyChip(row, initialKey,
            function(newKey, oldKey)
                if kbo.Flag then library.flags[kbo.Flag] = newKey end
                spawnCallback(kbo.Callback, newKey, oldKey)
            end,
            function(input)
                spawnCallback(kbo.Pressed, input)
                if not locked then setState(not state) end
            end)
        if kbo.Flag then library.flags[kbo.Flag] = initialKey end
        holder.Size = UDim2.new(1, -(46 + 96), 0, 0)
    end

    paint = function(instant)
        local fill = state and colors.accent or colors.field
        local sc = state and colors.accent or colors.line
        if instant then
            box.BackgroundColor3 = fill
            boxStroke.Color = sc
        else
            tween(box, { BackgroundColor3 = fill })
            tween(boxStroke, { Color = sc })
        end
        check.Visible = state
        nameLabel.TextTransparency = locked and 0.55 or 0
    end
    paint(true)
    onAccent(function() paint(true) end)

    connect(row.Activated, function()
        if locked then return end
        setState(not state)
    end)

    self:_register(row, name .. " " .. tostring(sub or ""))
    local obj = { Type = "Toggle", Name = name, Default = default, Options = o, Parent = self, Instance = row }
    obj.Set = function(a, b) return setState(A(obj, a, b)) end
    obj.RawSet = function(a, b) return setState(A(obj, a, b), true) end
    obj.Get = function() return state end
    obj.Update = obj.Get
    obj.Reset = function() return setState(default) end
    obj.SetLocked = function(a, b)
        local v = A(obj, a, b)
        if v == nil then locked = not locked else locked = v and true or false end
        paint(true)
        return locked
    end
    obj.Lock = function() obj.SetLocked(true) return locked end
    obj.Unlock = function() obj.SetLocked(false) return locked end
    obj.SetCondition = function(a, b) o.Condition = A(obj, a, b) return o.Condition end
    obj.Keybind = chipCtl
    commit(o, state)
    register(o, obj)
    if state then task.defer(spawnCallback, o.Callback, state, false) end
    return obj
end

function Section:AddButton(...)
    local o = resolve("Button", ...)
    local name = tostring(pick(o, "Name", "Text") or "Button")
    local sub = pick(o, "Sub", "Description", "Subtitle")
    local locked = pick(o, "Locked") == true
    local presses = 0
    local row = newRow(sub and 48 or 38, true)
    local _, nameLabel = titleBlock(row, name, sub, 0, 0, Enum.TextXAlignment.Center)

    local function press()
        if locked then return end
        if o.Condition and not o.Condition(presses) then return end
        presses = presses + 1
        row.BackgroundColor3 = colors.accentDark
        tween(row, { BackgroundColor3 = colors.rowHover }, 0.35)
        spawnCallback(o.Callback, presses)
    end
    connect(row.Activated, press)

    self:_register(row, name .. " " .. tostring(sub or ""))
    local obj = { Type = "Button", Name = name, Options = o, Parent = self, Instance = row }
    obj.Press = function() press() end
    obj.RawPress = function() spawnCallback(o.Callback, presses) end
    obj.Get = function() return o.Callback, presses end
    obj.Update = function() return name end
    obj.SetText = function(a, b)
        local t = tostring(A(obj, a, b))
        nameLabel.Text = t
        obj.Name = t
        return t
    end
    obj.SetCallback = function(a, b) o.Callback = A(obj, a, b) return o.Callback end
    obj.SetCondition = function(a, b) o.Condition = A(obj, a, b) return o.Condition end
    obj.SetLocked = function(a, b)
        local v = A(obj, a, b)
        if v == nil then locked = not locked else locked = v and true or false end
        nameLabel.TextTransparency = locked and 0.55 or 0
        return locked
    end
    obj.Lock = function() obj.SetLocked(true) return locked end
    obj.Unlock = function() obj.SetLocked(false) return locked end
    return obj
end

function Section:AddSlider(...)
    local o = resolve("Slider", ...)
    local name = tostring(pick(o, "Name", "Text") or "Slider")
    local sub = pick(o, "Sub", "Description", "Subtitle")
    local min = tonumber(pick(o, "Min", "Minimum")) or 0
    local max = tonumber(pick(o, "Max", "Maximum")) or 100
    local decimals = tonumber(pick(o, "Decimals", "Precision", "Precise"))
    if decimals == nil then decimals = ((max - min) > 20) and 0 or 2 end
    local mult = 10 ^ decimals
    local function snap(v)
        v = math.clamp(v, min, max)
        return math.floor(v * mult + 0.5) / mult
    end
    local value = snap(tonumber(pick(o, "Value", "Default")) or min)
    local default = value
    local fmtOpt = pick(o, "Format")
    local function fmt(v)
        if type(fmtOpt) == "function" then
            local ok, r = pcall(fmtOpt, v, value)
            if ok and r ~= nil then return tostring(r) end
        elseif type(fmtOpt) == "string" then
            return (string.gsub(fmtOpt, "%%s", tostring(v)))
        end
        return tostring(v)
    end

    local height = sub and 64 or 52
    local row = newRow(height, false)
    titleBlock(row, name, sub, 12, 84, nil, 8)

    local box = new("TextBox", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -12, 0, 8),
        Size = UDim2.fromOffset(64, 24),
        BackgroundColor3 = colors.field,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        ClearTextOnFocus = true,
        Text = "",
        Parent = row,
    })
    accent(box, "TextColor3")
    round(box, 6)
    outline(box, colors.line, 1)

    local track = new("Frame", {
        Position = UDim2.new(0, 12, 0, height - 18),
        Size = UDim2.new(1, -24, 0, 6),
        BackgroundColor3 = colors.field,
        BorderSizePixel = 0,
        Parent = row,
    })
    round(track, 3)
    local fill = new("Frame", { Size = UDim2.new(0, 0, 1, 0), BorderSizePixel = 0, Parent = track })
    accent(fill, "BackgroundColor3")
    round(fill, 3)
    local knob = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = track,
    })
    round(knob, 7)
    accent(outline(knob, colors.accent, 2), "Color")
    local hit = new("TextButton", {
        BackgroundTransparency = 1,
        Text = "",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 6, 0, height - 15),
        Size = UDim2.new(1, -12, 0, 26),
        Parent = row,
    })

    local function render()
        local a = (max == min) and 0 or (value - min) / (max - min)
        fill.Size = UDim2.new(a, 0, 1, 0)
        knob.Position = UDim2.new(a, 0, 0.5, 0)
        box.Text = fmt(value)
    end

    local function setValue(v, silent)
        v = snap(v)
        if v == value then render() return value end
        local old = value
        value = v
        render()
        commit(o, value)
        if not silent then spawnCallback(o.Callback, value, old) end
        return value
    end

    bindDrag(hit, function() return self.page end, function(pos)
        local a = math.clamp((pos.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
        setValue(min + (max - min) * a)
    end)
    connect(box.FocusLost, function()
        local n = tonumber(string.match(box.Text, "-?%d+%.?%d*"))
        if n == nil then render() return end
        if o.IllegalInput then
            value = n
            commit(o, value)
            render()
        else
            setValue(n)
        end
    end)

    render()
    self:_register(row, name .. " " .. tostring(sub or ""))
    local obj = { Type = "Slider", Name = name, Default = default, Options = o, Parent = self, Instance = row }
    obj.Set = function(a, b) return setValue(A(obj, a, b)) end
    obj.RawSet = function(a, b) return setValue(A(obj, a, b), true) end
    obj.Get = function() return value end
    obj.Update = obj.Get
    obj.Reset = function() return setValue(default) end
    obj.SetConstraints = function(a, b, c)
        if a == obj then a, b = b, c end
        min, max = tonumber(a) or min, tonumber(b) or max
        setValue(value, true)
    end
    obj.SetMin = function(a, b) min = tonumber(A(obj, a, b)) or min setValue(value, true) end
    obj.SetMax = function(a, b) max = tonumber(A(obj, a, b)) or max setValue(value, true) end
    commit(o, value)
    register(o, obj)
    return obj
end

local function resolveList(l, sortOpt)
    if type(l) == "function" then
        local ok, r = pcall(l)
        l = ok and r or {}
    end
    local out = {}
    if typeof(l) == "table" then
        for _, v in ipairs(l) do table.insert(out, tostring(v)) end
    elseif typeof(l) == "Enum" then
        for _, item in ipairs(l:GetEnumItems()) do table.insert(out, item.Name) end
    elseif typeof(l) == "Instance" then
        for _, c in ipairs(l:GetChildren()) do table.insert(out, c.Name) end
    end
    if sortOpt then
        if type(sortOpt) == "function" then
            table.sort(out, sortOpt)
        else
            table.sort(out, function(x, y) return string.lower(x) < string.lower(y) end)
        end
    end
    return out
end

function Section:AddDropdown(...)
    local o = resolve("Dropdown", ...)
    local name = tostring(pick(o, "Name", "Text") or "Dropdown")
    local sub = pick(o, "Sub", "Description", "Subtitle")
    local multi = pick(o, "MultiSelect", "Multi", "Multiple") and true or false
    local blank = tostring(pick(o, "Nothing", "BlankValue", "NoValueString") or "None")
    local sortOpt = pick(o, "Sort")

    local list = resolveList(pick(o, "List", "Items", "Values"), sortOpt)
    local selected, set = nil, {}
    local function toSet(v)
        local s = {}
        if type(v) == "table" then
            for k, x in pairs(v) do
                if x == true and type(k) == "string" then
                    s[k] = true
                elseif type(x) == "string" then
                    s[x] = true
                end
            end
        elseif v ~= nil then
            s[tostring(v)] = true
        end
        return s
    end
    local initial = pick(o, "Value", "Default")
    if multi then
        set = toSet(initial)
    elseif initial ~= nil then
        selected = tostring(initial)
    end
    local default = multi and toSet(initial) or selected

    local function getValue()
        if multi then
            local out, seen = {}, {}
            for _, item in ipairs(list) do
                if set[item] then
                    table.insert(out, item)
                    seen[item] = true
                end
            end
            for k in pairs(set) do
                if not seen[k] then table.insert(out, k) end
            end
            return out
        end
        return selected
    end

    local holder = new("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    listLayout(holder, 4)
    local head = newRow(sub and 48 or 38, true)
    head.LayoutOrder = 1
    head.Parent = holder
    local title = titleBlock(head, name, sub, 12, 0)
    title.Size = UDim2.new(0.5, -12, 0, 0)
    local valueLabel = textOf(head, {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -32, 0, 0),
        Size = UDim2.new(0.35, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Right,
        TextColor3 = colors.subtext,
        TextSize = 13,
    })
    textOf(head, {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -12, 0, 0),
        Size = UDim2.new(0, 14, 1, 0),
        Text = "▼",
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Center,
        Name = "Arrow",
    })
    local arrow = head:FindFirstChild("Arrow")

    local listFrame = new("ScrollingFrame", {
        BackgroundColor3 = colors.field,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Visible = false,
        LayoutOrder = 2,
        Parent = holder,
    })
    accent(listFrame, "ScrollBarImageColor3")
    round(listFrame, 7)
    outline(listFrame, colors.line, 1)
    listLayout(listFrame, 2)
    padding(listFrame, 4)

    local items = {}
    local open = false

    local function display()
        local v = getValue()
        if multi then
            valueLabel.Text = (#v > 0) and table.concat(v, ", ") or blank
        else
            valueLabel.Text = v or blank
        end
    end

    local function paintItems()
        for i, item in ipairs(list) do
            local it = items[i]
            if it then
                local on = (multi and set[item]) or ((not multi) and selected == item)
                it.button.BackgroundTransparency = on and 0.8 or 1
                it.text.TextColor3 = on and colors.accent or colors.text
            end
        end
    end
    onAccent(paintItems)

    local function sizeList()
        listFrame.Size = UDim2.new(1, 0, 0, math.min(#list * 30 + 8, 168))
    end

    local function setOpen(s)
        if s and #list == 0 then return end
        open = s
        listFrame.Visible = s
        if arrow then arrow.Text = s and "▲" or "▼" end
        if s then sizeList() end
    end

    local function commitChange(old, silent)
        local v = getValue()
        commit(o, v)
        display()
        paintItems()
        if not silent then spawnCallback(o.Callback, v, old) end
    end

    local function choose(item)
        local old = getValue()
        if multi then
            set[item] = (not set[item]) or nil
        else
            if selected == item then
                setOpen(false)
                return
            end
            selected = item
            setOpen(false)
        end
        commitChange(old)
    end

    local function rebuild()
        for _, it in pairs(items) do it.button:Destroy() end
        items = {}
        for i, item in ipairs(list) do
            local b = new("TextButton", {
                BackgroundColor3 = colors.accent,
                BackgroundTransparency = 1,
                AutoButtonColor = false,
                Text = "",
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 28),
                LayoutOrder = i,
                Parent = listFrame,
            })
            round(b, 5)
            local t = textOf(b, { Text = item, Size = UDim2.new(1, -16, 1, 0), Position = UDim2.fromOffset(10, 0), TextSize = 13 })
            connect(b.Activated, function() choose(item) end)
            items[i] = { button = b, text = t }
        end
        paintItems()
        if open then sizeList() end
    end

    connect(head.Activated, function() setOpen(not open) end)

    local function setValue(v, silent)
        local old = getValue()
        if multi then
            set = toSet(v)
        else
            selected = (v ~= nil) and tostring(v) or nil
        end
        commitChange(old, silent)
        return getValue()
    end

    rebuild()
    display()
    self:_register(holder, name .. " " .. tostring(sub or ""))
    local obj = { Type = "Dropdown", Name = name, Default = default, Options = o, Parent = self, Instance = holder }
    obj.Set = function(a, b) return setValue(A(obj, a, b)) end
    obj.RawSet = function(a, b) return setValue(A(obj, a, b), true) end
    obj.Update = function() display() paintItems() end
    obj.Get = function() return getValue() end
    obj.Reset = function() return setValue(multi and toSet(default) or default) end
    obj.UpdateList = function(a, b)
        list = resolveList(A(obj, a, b), sortOpt)
        rebuild()
        display()
        return list
    end
    obj.Refresh = obj.UpdateList
    obj.Add = function(a, b)
        table.insert(list, tostring(A(obj, a, b)))
        rebuild()
    end
    obj.Remove = function(a, b)
        local target = tostring(A(obj, a, b))
        for i = #list, 1, -1 do
            if list[i] == target then table.remove(list, i) end
        end
        rebuild()
    end
    obj.Clear = function()
        list = {}
        setOpen(false)
        rebuild()
    end
    obj.Validate = function(a, b)
        local fallback = A(obj, a, b)
        if multi then return true end
        for _, item in ipairs(list) do
            if item == selected then return true end
        end
        setValue(fallback)
        return false
    end
    commit(o, getValue())
    register(o, obj)
    return obj
end

function Section:AddTextbox(...)
    local o = resolve("Textbox", ...)
    local name = tostring(pick(o, "Name", "Text") or "Textbox")
    local sub = pick(o, "Sub", "Description", "Subtitle")
    local numeric = (pick(o, "Type") == "number") or pick(o, "Numeric") == true
    local min, max = tonumber(o.Min), tonumber(o.Max)
    local value = pick(o, "Value", "Default")
    if numeric then
        value = tonumber(value) or 0
    else
        value = (value ~= nil) and tostring(value) or ""
    end
    local default = value

    local row = newRow(sub and 48 or 38, false)
    local title = titleBlock(row, name, sub, 12, 0)
    title.Size = UDim2.new(0.5, -12, 0, 0)
    local box = new("TextBox", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0.42, 0, 0, 26),
        BackgroundColor3 = colors.field,
        BorderSizePixel = 0,
        Text = tostring(value),
        PlaceholderText = tostring(pick(o, "Placeholder") or ""),
        PlaceholderColor3 = colors.subtext,
        TextColor3 = colors.text,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        ClearTextOnFocus = false,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    padding(box, 8, 0)
    round(box, 6)
    local boxStroke = outline(box, colors.line, 1)
    connect(box.Focused, function() tween(boxStroke, { Color = colors.accent }) end)

    local function setValue(v, silent)
        if numeric then
            v = tonumber(v)
            if v == nil then
                box.Text = tostring(value)
                return value
            end
            if min then v = math.max(v, min) end
            if max then v = math.min(v, max) end
        else
            v = tostring(v)
        end
        box.Text = tostring(v)
        if v == value then return value end
        local old = value
        value = v
        commit(o, value)
        if not silent then spawnCallback(o.Callback, value, old) end
        return value
    end
    connect(box.FocusLost, function()
        tween(boxStroke, { Color = colors.line })
        setValue(box.Text)
    end)

    self:_register(row, name .. " " .. tostring(sub or ""))
    local obj = { Type = "Textbox", Name = name, Default = default, Options = o, Parent = self, Instance = box }
    obj.Set = function(a, b) return setValue(A(obj, a, b)) end
    obj.RawSet = function(a, b) return setValue(A(obj, a, b), true) end
    obj.Get = function() return value end
    obj.Update = obj.Get
    obj.Reset = function() return setValue(default) end
    commit(o, value)
    register(o, obj)
    return obj
end

function Section:AddKeybind(...)
    local o = resolve("Keybind", ...)
    local name = tostring(pick(o, "Name", "Text") or "Keybind")
    local sub = pick(o, "Sub", "Description", "Subtitle")
    local initial = pick(o, "Value", "Default")
    local default = initial
    local row = newRow(sub and 48 or 38, false)
    local title = titleBlock(row, name, sub, 12, 0)
    title.Size = UDim2.new(1, -(12 + 96), 0, 0)
    local ctl = makeKeyChip(row, initial,
        function(newKey, oldKey)
            commit(o, newKey)
            spawnCallback(o.Callback, newKey, oldKey)
        end,
        function(input)
            spawnCallback(o.Pressed, input)
        end)
    self:_register(row, name .. " " .. tostring(sub or ""))
    local obj = { Type = "Keybind", Name = name, Default = default, Options = o, Parent = self, Instance = row }
    obj.Set = function(a, b) ctl.Set(A(obj, a, b)) return ctl.Get() end
    obj.RawSet = function(a, b)
        ctl.Set(A(obj, a, b), true)
        commit(o, ctl.Get())
        return ctl.Get()
    end
    obj.Get = function() return ctl.Get() end
    obj.Update = obj.Get
    obj.Reset = function() ctl.Set(default) return ctl.Get() end
    commit(o, initial)
    register(o, obj)
    return obj
end

function Section:AddColorpicker(...)
    local o = resolve("Colorpicker", ...)
    local name = tostring(pick(o, "Name", "Text") or "Color")
    local sub = pick(o, "Sub", "Description", "Subtitle")
    local color = pick(o, "Value", "Default", "Color")
    if typeof(color) ~= "Color3" then color = Color3.fromRGB(255, 255, 255) end
    local default = color
    local h, s, v = color:ToHSV()

    local holder = new("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    listLayout(holder, 4)
    local head = newRow(sub and 48 or 38, true)
    head.LayoutOrder = 1
    head.Parent = holder
    local title = titleBlock(head, name, sub, 12, 0)
    title.Size = UDim2.new(1, -(12 + 56), 0, 0)
    local swatch = new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(34, 20),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Parent = head,
    })
    round(swatch, 6)
    outline(swatch, colors.line, 1)

    local panel = new("Frame", {
        BackgroundColor3 = colors.field,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 132),
        Visible = false,
        LayoutOrder = 2,
        Parent = holder,
    })
    round(panel, 7)
    outline(panel, colors.line, 1)
    padding(panel, 8)

    local sv = new("Frame", {
        Size = UDim2.new(1, -30, 1, 0),
        BackgroundColor3 = Color3.fromHSV(h, 1, 1),
        BorderSizePixel = 0,
        Parent = panel,
    })
    round(sv, 5)
    local white = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Parent = sv })
    round(white, 5)
    new("UIGradient", {
        Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }),
        Parent = white,
    })
    local black = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, Parent = sv })
    round(black, 5)
    new("UIGradient", {
        Rotation = 90,
        Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }),
        Parent = black,
    })
    local svCursor = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(10, 10),
        BackgroundTransparency = 1,
        Parent = sv,
    })
    round(svCursor, 5)
    outline(svCursor, Color3.new(1, 1, 1), 2)
    local svHit = new("TextButton", { BackgroundTransparency = 1, Text = "", Size = UDim2.fromScale(1, 1), ZIndex = 5, Parent = sv })

    local hue = new("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 18, 1, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = panel,
    })
    round(hue, 5)
    local keys = {}
    for i = 0, 6 do
        table.insert(keys, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6, 1, 1)))
    end
    new("UIGradient", { Rotation = 90, Color = ColorSequence.new(keys), Parent = hue })
    local hueCursor = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(1, 4, 0, 4),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = hue,
    })
    round(hueCursor, 2)
    outline(hueCursor, Color3.new(0, 0, 0), 1)
    local hueHit = new("TextButton", { BackgroundTransparency = 1, Text = "", Size = UDim2.fromScale(1, 1), ZIndex = 5, Parent = hue })

    local function render()
        color = Color3.fromHSV(h, s, v)
        swatch.BackgroundColor3 = color
        sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        svCursor.Position = UDim2.new(s, 0, 1 - v, 0)
        hueCursor.Position = UDim2.new(0.5, 0, h, 0)
    end
    local function fire(old, silent)
        commit(o, color)
        if not silent then spawnCallback(o.Callback, color, old) end
    end

    bindDrag(svHit, function() return self.page end, function(pos)
        local old = color
        s = math.clamp((pos.X - sv.AbsolutePosition.X) / math.max(sv.AbsoluteSize.X, 1), 0, 1)
        v = 1 - math.clamp((pos.Y - sv.AbsolutePosition.Y) / math.max(sv.AbsoluteSize.Y, 1), 0, 1)
        render()
        fire(old)
    end)
    bindDrag(hueHit, function() return self.page end, function(pos)
        local old = color
        h = math.clamp((pos.Y - hue.AbsolutePosition.Y) / math.max(hue.AbsoluteSize.Y, 1), 0, 1)
        render()
        fire(old)
    end)
    connect(head.Activated, function() panel.Visible = not panel.Visible end)

    render()
    self:_register(holder, name .. " " .. tostring(sub or ""))
    local obj = { Type = "Colorpicker", Name = name, Default = default, Options = o, Parent = self, Instance = holder }
    local function setColor(c, silent)
        if typeof(c) ~= "Color3" then return color end
        local old = color
        h, s, v = c:ToHSV()
        render()
        fire(old, silent)
        return color
    end
    obj.Set = function(a, b) return setColor(A(obj, a, b)) end
    obj.RawSet = function(a, b) return setColor(A(obj, a, b), true) end
    obj.Get = function() return color end
    obj.Update = obj.Get
    obj.Reset = function() return setColor(default) end
    commit(o, color)
    register(o, obj)
    return obj
end

for _, alias in ipairs({ "CreateToggle", "NewToggle", "Toggle", "Tog" }) do Section[alias] = Section.AddToggle end
for _, alias in ipairs({ "CreateButton", "NewButton", "Button" }) do Section[alias] = Section.AddButton end
for _, alias in ipairs({ "CreateSlider", "NewSlider", "Slider", "Slide", "NumberConstraint" }) do Section[alias] = Section.AddSlider end
for _, alias in ipairs({ "AddDropDown", "NewDropDown", "NewDropdown", "CreateDropdown", "DropDown", "Dropdown", "DD" }) do Section[alias] = Section.AddDropdown end
for _, alias in ipairs({ "AddTextBox", "NewTextBox", "CreateTextBox", "TextBox", "NewTextbox", "CreateTextbox", "Textbox", "Box" }) do Section[alias] = Section.AddTextbox end
for _, alias in ipairs({ "NewKeybind", "CreateKeybind", "Keybind", "Bind" }) do Section[alias] = Section.AddKeybind end
for _, alias in ipairs({ "NewLabel", "CreateLabel", "Label", "Text" }) do Section[alias] = Section.AddLabel end
for _, alias in ipairs({ "AddColorPicker", "NewColorpicker", "NewColorPicker", "CreateColorpicker", "CreateColorPicker" }) do Section[alias] = Section.AddColorpicker end

function Section:SetCollapsed(state)
    self.collapsed = state and true or false
    self.content.Visible = not self.collapsed
    tween(self.chevron, { Rotation = self.collapsed and -90 or 0 }, 0.15)
end
function Section:Collapse() self:SetCollapsed(true) end
function Section:Expand() self:SetCollapsed(false) end
function Section:ToggleCollapsed() self:SetCollapsed(not self.collapsed) end
function Section:IsCollapsed() return self.collapsed end

function Tab:CreateSection(...)
    local o = resolve("Section", ...)
    local name = tostring(pick(o, "Name", "Text") or "Section")
    local side = string.lower(tostring(pick(o, "Side") or ""))
    local column
    if side == "right" then
        column = self.right
    elseif side == "left" then
        column = self.left
    else
        column = (self.count.left <= self.count.right) and self.left or self.right
    end
    if column == self.left then
        self.count.left = self.count.left + 1
    else
        self.count.right = self.count.right + 1
    end

    local frame = new("Frame", {
        BackgroundColor3 = colors.panel,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = #self.sections + 1,
        Parent = column,
    })
    round(frame, 9)
    outline(frame, colors.line, 1, 0.35)
    padding(frame, 10, 8, 10, 10)
    listLayout(frame, 6)

    local header = new("TextButton", {
        BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
        Size = UDim2.new(1, 0, 0, 22), LayoutOrder = 0, Parent = frame,
    })
    textOf(header, { Text = name, Size = UDim2.new(1, -20, 1, 0), Font = Enum.Font.GothamBold })
    local chevron = textOf(header, {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(14, 14), Text = "▼", TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = colors.subtext,
    })
    local content = new("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 1,
        Parent = frame,
    })
    listLayout(content, 6)

    local sec = setmetatable({
        Type = "Section", Name = name, Parent = self, frame = frame, content = content,
        chevron = chevron, page = self.page, entries = {}, _order = 0, collapsed = false,
        Instance = frame, Flags = library.flags,
    }, Section)
    connect(header.Activated, function() sec:ToggleCollapsed() end)
    table.insert(self.sections, sec)
    return sec
end
for _, alias in ipairs({ "AddSection", "NewSection", "Section", "Sec", "S" }) do Tab[alias] = Tab.CreateSection end

function Window:SelectTab(tab)
    if type(tab) == "number" then tab = self.tabs[tab] end
    if not tab then return end
    for _, t in ipairs(self.tabs) do
        local on = (t == tab)
        t.page.Visible = on
        t.underline.Visible = on
        tween(t.button, { BackgroundColor3 = on and colors.tabActive or colors.tabFill }, 0.15)
        tween(t.stroke, { Color = on and colors.accent or colors.accentDark }, 0.15)
    end
    self.activeTab = tab
    self:_applySearch()
end

function Window:_applySearch()
    local q = string.lower(self.searchBox.Text or "")
    q = q:gsub("^%s+", ""):gsub("%s+$", "")
    local tab = self.activeTab
    if not tab then return end
    for _, sec in ipairs(tab.sections) do
        if q == "" then
            sec.frame.Visible = true
            for _, e in ipairs(sec.entries) do e.frame.Visible = true end
        else
            local secMatch = string.find(string.lower(sec.Name), q, 1, true) ~= nil
            local any = secMatch
            for _, e in ipairs(sec.entries) do
                local m = secMatch or (string.find(e.text, q, 1, true) ~= nil)
                e.frame.Visible = m
                any = any or m
            end
            sec.frame.Visible = any
        end
    end
end

function Window:CreateTab(...)
    local o = resolve("Tab", ...)
    local name = tostring(pick(o, "Name", "Text") or "Tab")
    local sub = pick(o, "Sub", "Description", "Subtitle")

    local button = new("TextButton", {
        BackgroundColor3 = colors.tabFill,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        Size = UDim2.new(0, 0, 0, 42),
        AutomaticSize = Enum.AutomaticSize.X,
        LayoutOrder = #self.tabs + 1,
        Parent = self.tabBar,
    })
    round(button, 8)
    local stroke = outline(button, colors.accentDark, 1.5)
    new("UISizeConstraint", { MinSize = Vector2.new(96, 42), Parent = button })
    padding(button, 18, 0)
    listLayout(button, 0, nil, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center)
    textOf(button, {
        Text = name, Size = UDim2.fromOffset(0, 0), AutomaticSize = Enum.AutomaticSize.XY,
        TextTruncate = Enum.TextTruncate.None, TextXAlignment = Enum.TextXAlignment.Center,
        Font = Enum.Font.GothamBold, TextSize = 14, LayoutOrder = 1,
    })
    if sub and sub ~= "" then
        textOf(button, {
            Text = tostring(sub), Size = UDim2.fromOffset(0, 0), AutomaticSize = Enum.AutomaticSize.XY,
            TextTruncate = Enum.TextTruncate.None, TextXAlignment = Enum.TextXAlignment.Center,
            TextSize = 11, TextColor3 = colors.subtext, LayoutOrder = 2,
        })
    end
    local underline = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, -2),
        Size = UDim2.new(0.55, 0, 0, 2),
        BorderSizePixel = 0,
        Visible = false,
        Parent = button,
    })
    accent(underline, "BackgroundColor3")
    round(underline, 1)

    local page = new("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Visible = false,
        Parent = self.pages,
    })
    accent(page, "ScrollBarImageColor3")
    padding(page, 2, 2, 8, 18)
    local cols = new("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = page,
    })
    listLayout(cols, 10, Enum.FillDirection.Horizontal)
    local left = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(0.5, -5, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 1, Parent = cols })
    local right = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(0.5, -5, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, Parent = cols })
    listLayout(left, 8)
    listLayout(right, 8)

    local tab = setmetatable({
        Type = "Tab", Name = name, Parent = self, button = button, stroke = stroke,
        underline = underline, page = page, left = left, right = right,
        sections = {}, count = { left = 0, right = 0 }, Instance = page, Flags = library.flags,
    }, Tab)
    table.insert(self.tabs, tab)
    connect(button.Activated, function() self:SelectTab(tab) end)
    if not self.activeTab then self:SelectTab(tab) end
    return tab
end
for _, alias in ipairs({ "AddTab", "NewTab", "Tab", "T" }) do Window[alias] = Window.CreateTab end

function Window:Toggle(state)
    if state == nil then state = not self.root.Visible end
    self.Visible = state
    if state then
        self.root.Visible = true
        self.scale.Scale = 0.94
        tween(self.scale, { Scale = 1 }, 0.18)
    else
        self.root.Visible = false
    end
end
function Window:Show() self:Toggle(true) end
function Window:Hide() self:Toggle(false) end

function Window:Notify(...) return library.Notify(...) end

function Window:SetTitle(text)
    self.titleLabel.Text = tostring(text)
end

function Window:Destroy()
    library.Unload()
end

local function stripSelf(self, ...)
    if self == library then return ... end
    return self, ...
end

local function createWindow(first, ...)
    local o = resolve("Window", first or {}, ...)
    local name = tostring(pick(o, "Name", "Title") or "Vector Hub")
    local gui = ensureGui()

    local camera = Workspace.CurrentCamera
    local view = gui.AbsoluteSize
    if view.X < 50 or view.Y < 50 then
        view = camera and camera.ViewportSize or Vector2.new(1280, 720)
    end
    local w = math.clamp(view.X - 40, 380, 620)
    local h = math.clamp(view.Y - 50, 260, 400)
    local sz = o.Size
    if typeof(sz) == "Vector2" then
        w, h = sz.X, sz.Y
    elseif typeof(sz) == "UDim2" then
        w, h = sz.X.Offset, sz.Y.Offset
    end

    local root = new("Frame", {
        Name = "Root",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, -math.floor(w / 2), 0.5, -math.floor(h / 2)),
        Size = UDim2.fromOffset(w, h),
        Parent = gui,
    })
    local body = new("Frame", {
        Name = "Body",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        Parent = root,
    })
    local scale = new("UIScale", { Scale = 1, Parent = body })

    local glow = new("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 6, 1, 6),
        Parent = body,
    })
    round(glow, 14)
    accent(outline(glow, colors.accent, 4, 0.8), "Color")

    local main = new("Frame", {
        Name = "Main",
        BackgroundColor3 = colors.window,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Parent = body,
    })
    round(main, 10)
    accent(outline(main, colors.accent, 2), "Color")

    local header = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 56), Parent = main })
    local letter = "V"
    local okc, ch = pcall(function() return utf8.char(utf8.codepoint(name, 1)) end)
    if okc and ch then letter = string.upper(ch) end
    local logo = makeLogo(header, 30, pick(o, "Image", "Logo"), letter)
    logo.Position = UDim2.fromOffset(14, 13)

    local searchW = (w < 480) and 150 or 220
    local titleLabel = textOf(header, {
        Text = name,
        Position = UDim2.fromOffset(52, 0),
        Size = UDim2.new(1, -(52 + searchW + 24), 1, 0),
        Font = Enum.Font.GothamBold,
        TextSize = 20,
    })
    accent(titleLabel, "TextColor3")

    local search = new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(searchW, 36),
        BackgroundColor3 = colors.search,
        BorderSizePixel = 0,
        Parent = header,
    })
    round(search, 9)
    accent(outline(search, colors.accent, 1.5), "Color")
    local icon = new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(36, 36), Parent = search })
    local ring = new("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(17, 16),
        Size = UDim2.fromOffset(10, 10),
        Parent = icon,
    })
    round(ring, 6)
    accent(outline(ring, colors.accent, 2), "Color")
    local handle = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(24, 23),
        Size = UDim2.fromOffset(6, 2),
        Rotation = 45,
        BorderSizePixel = 0,
        Parent = icon,
    })
    accent(handle, "BackgroundColor3")
    round(handle, 1)
    local searchBox = new("TextBox", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(36, 0),
        Size = UDim2.new(1, -44, 1, 0),
        Text = "",
        PlaceholderText = "Search... (Ctrl+F)",
        PlaceholderColor3 = colors.subtext,
        TextColor3 = colors.text,
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ClearTextOnFocus = false,
        Parent = search,
    })

    local tabBar = new("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(14, 58),
        Size = UDim2.new(1, -28, 0, 48),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        Parent = main,
    })
    padding(tabBar, 2)
    listLayout(tabBar, 8, Enum.FillDirection.Horizontal)

    local pages = new("Frame", {
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Position = UDim2.fromOffset(14, 112),
        Size = UDim2.new(1, -28, 1, -124),
        Parent = main,
    })

    local window = setmetatable({
        Type = "Window", Name = name, Library = library, Gui = gui, root = root, body = body,
        main = main, scale = scale, tabBar = tabBar, pages = pages, searchBox = searchBox,
        titleLabel = titleLabel, tabs = {}, Visible = true, Flags = library.flags,
    }, Window)
    library.window = window

    onAccent(function()
        if window.activeTab then
            for _, t in ipairs(window.tabs) do
                local on = (t == window.activeTab)
                t.stroke.Color = on and colors.accent or colors.accentDark
                t.button.BackgroundColor3 = on and colors.tabActive or colors.tabFill
            end
        end
    end)

    connect(searchBox:GetPropertyChangedSignal("Text"), function() window:_applySearch() end)

    connect(header.InputBegan, function(input)
        if not isPress(input) then return end
        local start, startPos = input.Position, root.Position
        dragSession(input, function(p)
            local d = p - start
            root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end)
    end)

    local grip = new("TextButton", {
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -8, 1, -8),
        Size = UDim2.fromOffset(22, 22),
        BackgroundColor3 = colors.window,
        AutoButtonColor = false,
        Text = "",
        BorderSizePixel = 0,
        ZIndex = 10,
        Parent = main,
    })
    round(grip, 11)
    accent(outline(grip, colors.accent, 1.5), "Color")
    for _, spec in ipairs({ { 10, 10.5, 10.5 }, { 5, 14, 14 } }) do
        local bar = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromOffset(spec[2], spec[3]),
            Size = UDim2.fromOffset(spec[1], 2),
            Rotation = -45,
            BorderSizePixel = 0,
            ZIndex = 11,
            Parent = grip,
        })
        accent(bar, "BackgroundColor3")
        round(bar, 1)
    end
    connect(grip.InputBegan, function(input)
        if not isPress(input) then return end
        local start = input.Position
        local w0, h0 = root.Size.X.Offset, root.Size.Y.Offset
        dragSession(input, function(p)
            local d = p - start
            local limit = gui.AbsoluteSize
            local nw = math.clamp(w0 + d.X, 380, math.max(380, limit.X - 10))
            local nh = math.clamp(h0 + d.Y, 260, math.max(260, limit.Y - 10))
            root.Size = UDim2.fromOffset(nw, nh)
        end)
    end)

    local useMobile = o.MobileButton
    if useMobile == nil then
        useMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    end
    if useMobile then
        local mb = new("TextButton", {
            Name = "MobileToggle",
            Text = "",
            AutoButtonColor = false,
            BackgroundColor3 = colors.window,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 14, 0.3, 0),
            Size = UDim2.fromOffset(48, 48),
            Parent = gui,
        })
        round(mb, 12)
        accent(outline(mb, colors.accent, 2), "Color")
        local mlogo = makeLogo(mb, 32, pick(o, "Image", "Logo"), letter)
        mlogo.AnchorPoint = Vector2.new(0.5, 0.5)
        mlogo.Position = UDim2.fromScale(0.5, 0.5)
        connect(mb.InputBegan, function(input)
            if not isPress(input) then return end
            local start, startPos, moved = input.Position, mb.Position, false
            dragSession(input, function(p)
                local d = p - start
                if d.Magnitude > 6 then moved = true end
                if moved then
                    mb.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
                end
            end, function()
                if not moved then window:Toggle() end
            end)
        end)
        window.mobileButton = mb
    end

    connect(UserInputService.InputBegan, function(input, gp)
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if searchBox:IsFocused() then return end
        if input.KeyCode == library.configuration.searchKeybind
            and (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
            if not window.root.Visible then window:Toggle(true) end
            task.spawn(function()
                task.wait()
                searchBox:CaptureFocus()
            end)
            return
        end
        if not gp and input.KeyCode == library.configuration.hideKeybind then
            window:Toggle()
        end
    end)

    return window
end

function library.CreateWindow(...)
    return createWindow(stripSelf(...))
end
for _, alias in ipairs({ "NewWindow", "AddWindow", "Window", "W" }) do library[alias] = library.CreateWindow end

function library.Unload()
    for _, c in ipairs(library.signals) do
        pcall(function() c:Disconnect() end)
    end
    library.signals = {}
    if library.gui then pcall(function() library.gui:Destroy() end) end
    library.gui = nil
    for k in pairs(library.flags) do library.flags[k] = nil end
    for k in pairs(library.elements) do library.elements[k] = nil end
    if shared.VectorUILibrary == library then shared.VectorUILibrary = nil end
    if type(library.UnloadCallback) == "function" then pcall(library.UnloadCallback) end
end

return library, library.flags, library.subs
