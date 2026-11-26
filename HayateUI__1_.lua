local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local TextService      = game:GetService("TextService")
local CoreGui          = game:GetService("CoreGui")
local Workspace        = game:GetService("Workspace")
local ContentProvider  = game:GetService("ContentProvider")
local Debris           = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer

local library = {
    Version = "1.0",
    WorkspaceName = "QuickX Hub",
    flags = {},
    elements = {},
    signals = {},
    subs = {},
    configuration = {
        -- ชื่อและโลโก้ของ UI (เปลี่ยนที่นี่ที่เดียว หรือส่ง Name / Image มาตอน CreateWindow ก็ได้)
        name = "QuickX Hub",
        logo = "rbxassetid://132029940467197",   -- QuickX Hub
        hideKeybind = Enum.KeyCode.RightShift,
        searchKeybind = Enum.KeyCode.F,
        -- ขนาดหน้าต่างเป็น "สัดส่วนของหน้าจอ" (จอใหญ่ = เหมือนรูปตัวอย่าง กว้าง ~54% สูง ~60%)
        windowFraction = Vector2.new(0.54, 0.60),
        -- จอเล็ก (มือถือที่สูง ~400px) จะค่อย ๆ เพิ่มสัดส่วนนี้ เพื่อไม่ให้ตัวหนังสือเล็กเกินไป
        windowFractionSmall = Vector2.new(0.78, 0.88),
        minScale = 0.55,
        maxScale = 3,
        -- ลูกศรเล็ก ๆ ที่หัว Section (ในรูปไม่มี จึงปิดไว้ แตะที่ชื่อ Section ยังพับ/ขยายได้)
        showSectionArrow = false,
        -- เสียงของ UI (เปิด/ปิดหน้าต่าง, Toggle, ปุ่ม, แท็บ, แจ้งเตือน)
        --   ปิดทั้งหมด : library.configuration.sounds.enabled = false
        --   ปรับความดัง: library.configuration.sounds.volume = 0.5   (1 = ปกติ)
        sounds = {
            enabled = true,
            volume = 1,
            -- เสียงพื้นฐาน: ไล่ลองตามลำดับ ตัวไหนโหลดได้ก็ใช้ตัวนั้น
            -- ถ้าไม่มีเสียง ให้ใส่ rbxassetid:// ของเสียงที่ใช้งานได้ไว้เป็นตัวแรก
            -- อยากใช้เสียงของตัวเอง: ใส่ id ไว้เป็นตัวแรก หรือเรียก library.SetSound("rbxassetid://...")
            base = {
                "rbxassetid://6026984224",
                "rbxassetid://6895079853",
                "rbxassetid://421058925",
                "rbxasset://sounds/electronicpingshort.wav",
                "rbxasset://sounds/switch3.wav",
                "rbxasset://sounds/button.wav",
            },
            -- ทุกเหตุการณ์ใช้เสียงพื้นฐานเดียวกัน แต่ปรับโทน (speed) / ความดัง (volume) ให้ต่างกัน
            -- อยากใช้เสียงเฉพาะ ให้ใส่ id = "rbxassetid://..." ในเหตุการณ์นั้น
            events = {
                open   = { speed = 1.25, volume = 0.7 },   -- เปิดหน้าต่าง
                close  = { speed = 0.8,  volume = 0.7 },   -- ปิดหน้าต่าง
                on     = { speed = 1.3,  volume = 0.55 },  -- Toggle เปิด
                off    = { speed = 0.9,  volume = 0.5 },   -- Toggle ปิด
                click  = { speed = 1.05, volume = 0.5 },   -- ปุ่ม / Dropdown / พับ Section
                tab    = { speed = 1.15, volume = 0.4 },   -- เปลี่ยนแท็บ
                notify = { speed = 0.95, volume = 0.6 },   -- แจ้งเตือน
            },
        },
    },
}
library.Flags = library.flags
library.Subs = library.subs

if shared.MapoUILibrary then
    pcall(function() shared.MapoUILibrary.Unload() end)
end
shared.MapoUILibrary = library

-- Colors sampled from the reference screenshot (deep blue accent, pure black window, flat grey rows)
local colors = {
    accent     = Color3.fromRGB(10, 62, 250),
    accentDark = Color3.fromRGB(6, 26, 112),
    window     = Color3.fromRGB(0, 0, 0),
    panel      = Color3.fromRGB(9, 10, 10),
    row        = Color3.fromRGB(20, 20, 20),     -- buttons, dropdown rows, checkbox
    rowHover   = Color3.fromRGB(29, 29, 29),
    rowSoft    = Color3.fromRGB(13, 14, 14),     -- slider row (barely lighter than the panel)
    field      = Color3.fromRGB(27, 28, 32),
    box        = Color3.fromRGB(30, 31, 35),     -- number box next to a slider
    track      = Color3.fromRGB(34, 34, 34),     -- empty part of a slider
    line       = Color3.fromRGB(46, 48, 58),
    text       = Color3.fromRGB(240, 240, 242),
    subtext    = Color3.fromRGB(150, 152, 158),
    sub        = Color3.fromRGB(205, 207, 214),  -- small second line under a name
    tabFill    = Color3.fromRGB(0, 0, 3),
    tabActive  = Color3.fromRGB(3, 6, 18),
    tabLine    = Color3.fromRGB(40, 56, 108),    -- border of tabs that are not selected
    search     = Color3.fromRGB(7, 9, 12),
}
library.colors = colors

-- ขนาดทั้งหมดในไฟล์นี้เป็น "หน่วยตอนออกแบบ" (ก่อนซูม) วัดสัดส่วนมาจากรูปตัวอย่าง (หน้าต่าง 1029x648 ÷ 1.8)
-- จากนั้น UIScale จะขยายให้พอดีกับจอ PC / มือถือ (ดู fitScale ใน createWindow)
local UI = {
    winW = 572, winH = 360,         -- ขนาดหน้าต่าง (อัตราส่วน ~1.59 : 1 เท่ารูปตัวอย่าง)
    minW = 380, minH = 250,         -- ขนาดเล็กสุดตอนลากปรับขนาด
    header = 48,                    -- height of the top bar (logo / title / search)
    pad = 12,                       -- left/right edge of the content
    tabH = 27, tabMinW = 77, tabGap = 10.5,
    colGap = 13, secGap = 16,       -- gap between the two columns / between sections
    contentGap = 9,                 -- gap between rows inside a section
    rowH = 34, rowHSub = 45,        -- normal row / row with a small second line (toggle, textbox, keybind)
    btnH = 26, btnHSub = 30,        -- button row
    ddH = 30, ddHSub = 34,          -- dropdown row
    textName = 11, textSub = 10, textSection = 11,
}
library.ui = UI

-- Enum.Font.GothamSemibold ไม่มีในบางเวอร์ชัน → ลองใช้ ถ้าไม่มีก็ถอยไป GothamMedium
local FONT_SEMI = Enum.Font.GothamMedium
pcall(function() FONT_SEMI = Enum.Font.GothamSemibold end)

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
    t.TextSize = UI.textName
    t.TextColor3 = colors.text
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.TextTruncate = Enum.TextTruncate.AtEnd
    for k, v in pairs(props or {}) do t[k] = v end
    t.Parent = parent
    return t
end

-- วัดความกว้างข้อความ (ใช้คำนวณความกว้างแท็บ)
local function measure(text, size, font)
    local ok, v = pcall(function()
        return TextService:GetTextSize(text, size, font, Vector2.new(10000, 10000))
    end)
    if ok and v then return v.X end
    return #text * size * 0.6
end

local function tween(inst, props, dur, style, dir)
    local t = TweenService:Create(inst, TweenInfo.new(dur or 0.16, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
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
    gui.Name = "MapoUI"
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
    library.notifyScale = new("UIScale", { Scale = 1, Parent = holder })
    return gui
end

-- ===== ระบบเสียง =====
local soundCache = {}

local function asList(v)
    if type(v) == "table" then return v end
    if type(v) == "string" and v ~= "" then return { v } end
    return {}
end

-- true = โหลดได้, false = โหลดไม่ได้, nil = ตรวจไม่ได้ (เช่น executor ไม่รองรับ PreloadAsync)
local function probeSound(id)
    local ok, loaded = pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = id
        s.Volume = 0
        s.Parent = ensureGui()
        Debris:AddItem(s, 15)
        ContentProvider:PreloadAsync({ s })
        local good = s.IsLoaded and s.TimeLength > 0
        s:Destroy()
        return good
    end)
    if not ok then return nil end
    return loaded
end

-- คืน id ที่ใช้งานได้ (nil ถ้ายังตรวจไม่เสร็จ) และเริ่มตรวจเบื้องหลังครั้งแรกครั้งเดียว
local function sourceFor(key)
    local st = soundCache[key]
    if st then return st.id end
    st = { id = nil }
    soundCache[key] = st
    task.spawn(function()
        local list = asList(key)
        for _, id in ipairs(list) do
            if probeSound(id) ~= false then
                st.id = id
                return
            end
        end
        if #list > 0 then
            warn("[QuickX Hub] โหลดเสียงไม่สำเร็จ — ใส่ rbxassetid ของเสียงที่ใช้ได้ใน library.configuration.sounds.base")
        end
    end)
    return nil
end

function library.PreloadSounds()
    local cfg = library.configuration.sounds
    if type(cfg) ~= "table" or cfg.enabled == false then return end
    sourceFor(cfg.base)
    for _, ev in pairs(cfg.events or {}) do
        if ev.id then sourceFor(ev.id) end
    end
end

-- เปลี่ยนเสียงพื้นฐานทั้ง UI ตอนรันสคริปต์: library.SetSound("rbxassetid://ไอดีเสียง")
function library.SetSound(id)
    local cfg = library.configuration.sounds
    if type(cfg) ~= "table" then return end
    if type(id) == "number" then id = "rbxassetid://" .. id end
    if type(id) == "string" and id ~= "" then
        cfg.base = { id }
        sourceFor(cfg.base)
    end
end

-- library.PlaySound("open" | "close" | "on" | "off" | "click" | "tab" | "notify")
function library.PlaySound(a, b)
    local cfg = library.configuration.sounds
    if type(cfg) ~= "table" or cfg.enabled == false then return end
    local ev = cfg.events and cfg.events[A(library, a, b)]
    if not ev then return end
    local gui = library.gui
    if not gui or not gui.Parent then return end
    local id = sourceFor(ev.id or cfg.base)
    if not id then return end
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = id
        s.Volume = math.clamp((tonumber(ev.volume) or 0.5) * (tonumber(cfg.volume) or 1), 0, 10)
        s.PlaybackSpeed = tonumber(ev.speed) or 1
        s.Parent = gui
        s:Play()
        Debris:AddItem(s, 5)
    end)
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
    -- ใช้สัดส่วน (scale) ทั้งหมด เพื่อให้โลโก้ย่อ/ขยายตามขนาดที่ตั้งทีหลังได้ (เช่นปุ่มมือถือ)
    new("UICorner", { CornerRadius = UDim.new(0.3, 0), Parent = f })
    new("UIGradient", {
        Rotation = 45,
        Color = ColorSequence.new(Color3.fromRGB(120, 170, 255), Color3.fromRGB(20, 50, 210)),
        Parent = f,
    })
    new("UIPadding", {
        PaddingLeft = UDim.new(0.17, 0), PaddingRight = UDim.new(0.17, 0),
        PaddingTop = UDim.new(0.17, 0), PaddingBottom = UDim.new(0.17, 0),
        Parent = f,
    })
    textOf(f, {
        Size = UDim2.fromScale(1, 1),
        Text = letter or "H",
        Font = Enum.Font.GothamBlack,
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextColor3 = Color3.new(1, 1, 1),
    })
    return f
end

-- Small blue gear: round body + 6 teeth + a hole in the middle. d = body size, bg = color shown inside the hole.
local function makeGear(parent, cx, cy, d, bg)
    local tooth = d * 0.24
    local full = d + tooth * 2
    local gear = new("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(cx, cy),
        Size = UDim2.fromOffset(full, full),
        Parent = parent,
    })
    for _, rot in ipairs({ 0, 60, 120 }) do
        local bar = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(full, d * 0.32),
            Rotation = rot,
            BorderSizePixel = 0,
            Parent = gear,
        })
        accent(bar, "BackgroundColor3")
    end
    local body = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(d, d),
        BorderSizePixel = 0,
        Parent = gear,
    })
    accent(body, "BackgroundColor3")
    new("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = body })
    local hole = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(d * 0.42, d * 0.42),
        BackgroundColor3 = bg,
        BorderSizePixel = 0,
        Parent = gear,
    })
    new("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = hole })
    return gear
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
    local duration = tonumber(o.Duration) or 4

    -- wrap = ช่องใน layout (ใช้ยุบความสูงตอนหายไป) / toast = ตัวการ์ดที่เลื่อนเข้า-ออก
    local wrap = new("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = library.notifyHolder,
    })
    local toast = new("CanvasGroup", {
        BackgroundColor3 = colors.window,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(70, 0),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        GroupTransparency = 1,
        Parent = wrap,
    })
    round(toast, 9)
    accent(outline(toast, colors.accent, 1.5), "Color")
    padding(toast, 12, 10)
    listLayout(toast, 3)
    accent(textOf(toast, {
        Text = tostring(o.Title or library.configuration.name or "QuickX Hub"),
        Size = UDim2.new(1, 0, 0, 18),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
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

    -- แถบเวลาที่ค่อย ๆ หดลงตามระยะเวลาแจ้งเตือน
    local barTrack = new("Frame", {
        BackgroundColor3 = colors.line,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 3),
        LayoutOrder = 3,
        Parent = toast,
    })
    round(barTrack, 2)
    local bar = new("Frame", { BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), Parent = barTrack })
    accent(bar, "BackgroundColor3")
    round(bar, 2)

    library.PlaySound("notify")
    tween(toast, { GroupTransparency = 0 }, 0.28, Enum.EasingStyle.Quad)
    tween(toast, { Position = UDim2.fromOffset(0, 0) }, 0.45, Enum.EasingStyle.Quint)
    tween(bar, { Size = UDim2.fromScale(0, 1) }, duration, Enum.EasingStyle.Linear)

    task.delay(duration, function()
        if not wrap.Parent or not library.gui then return end
        if toast.Parent then
            tween(toast, { GroupTransparency = 1, Position = UDim2.fromOffset(70, 0) }, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            task.wait(0.3)
        end
        if not wrap.Parent or not library.gui then return end
        -- ยุบความสูงช่องของการ์ด เพื่อให้การ์ดอื่นเลื่อนลงมาแทนอย่างนุ่มนวล
        local k = (library.notifyScale and library.notifyScale.Scale) or 1
        local h = wrap.AbsoluteSize.Y / math.max(k, 0.05)
        wrap.AutomaticSize = Enum.AutomaticSize.None
        wrap.ClipsDescendants = true
        wrap.Size = UDim2.new(1, 0, 0, h)
        tween(wrap, { Size = UDim2.new(1, 0, 0, 0) }, 0.22, Enum.EasingStyle.Quint)
        task.wait(0.24)
        wrap:Destroy()
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

-- plain = true  -> no visible background (toggle rows sit directly on the section panel)
local function newRow(height, clickable, plain)
    local row = Instance.new(clickable and "TextButton" or "Frame")
    row.BackgroundColor3 = colors.row
    row.BackgroundTransparency = plain and 1 or 0
    row.BorderSizePixel = 0
    row.Size = UDim2.new(1, 0, 0, height)
    if clickable then
        row.Text = ""
        row.AutoButtonColor = false
        if plain then
            connect(row.MouseEnter, function() tween(row, { BackgroundTransparency = 0.6 }, 0.12) end)
            connect(row.MouseLeave, function() tween(row, { BackgroundTransparency = 1 }, 0.12) end)
        else
            connect(row.MouseEnter, function() tween(row, { BackgroundColor3 = colors.rowHover }, 0.12) end)
            connect(row.MouseLeave, function() tween(row, { BackgroundColor3 = colors.row }, 0.12) end)
        end
    end
    round(row, 3)
    return row
end

local function titleBlock(parent, name, sub, x, rightPad, align, topY, subSize)
    align = align or Enum.TextXAlignment.Left
    local holder = new("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = topY and Vector2.new(0, 0) or Vector2.new(0, 0.5),
        Position = topY and UDim2.new(0, x, 0, topY) or UDim2.new(0, x, 0.5, 0),
        Size = UDim2.new(1, -(x + rightPad), 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = parent,
    })
    listLayout(holder, 0, nil, (align == Enum.TextXAlignment.Center) and Enum.HorizontalAlignment.Center or Enum.HorizontalAlignment.Left)
    -- name = bold white, second line = slightly smaller and a little dimmer (same as the reference)
    local n = textOf(holder, { Text = name, Size = UDim2.new(1, 0, 0, 14), LayoutOrder = 1, TextXAlignment = align, Font = Enum.Font.GothamBold, TextSize = UI.textName })
    local s
    if sub and sub ~= "" then
        s = textOf(holder, {
            Text = tostring(sub), Size = UDim2.new(1, 0, 0, 13), TextSize = subSize or UI.textSub,
            Font = FONT_SEMI, TextColor3 = colors.sub, LayoutOrder = 2, TextXAlignment = align,
        })
    end
    return holder, n, s
end

local function makeKeyChip(parent, initial, onChange, onPress)
    local key = initial
    local listening = false
    local chip = new("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(60, 19),
        BackgroundColor3 = colors.field,
        AutoButtonColor = false,
        Text = "",
        BorderSizePixel = 0,
        Parent = parent,
    })
    round(chip, 4)
    local chipStroke = outline(chip, colors.line, 1)
    local txt = textOf(chip, {
        Size = UDim2.new(1, -8, 1, 0), Position = UDim2.fromOffset(4, 0),
        TextSize = 10, TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = colors.subtext,
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
        TextSize = 10,
        TextColor3 = colors.subtext,
        RichText = pick(o, "Rich", "RichText") and true or false,
    })
    padding(lbl, 3, 2)
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
    local row = newRow(sub and UI.rowHSub or UI.rowH, true, true)

    -- dark rounded square with no border (the reference has no outline when it is off)
    local box = new("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 3, 0.5, 0),
        Size = UDim2.fromOffset(24, 24),
        BackgroundColor3 = colors.row,
        BorderSizePixel = 0,
        Parent = row,
    })
    round(box, 7)
    local boxStroke = outline(box, colors.row, 1)
    local check = new("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        Visible = false,
        Parent = box,
    })
    local checkScale = new("UIScale", { Scale = 0.01, Parent = check })
    for _, s in ipairs({ { 6, 45, 8.5, 14 }, { 12, -45, 14.5, 12 } }) do
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

    -- ผู้ใช้กดเอง (คลิกแถว / กดคีย์ลัด) → สลับสถานะ + เล่นเสียง on/off
    local function userToggle()
        if locked then return end
        local before = state
        local after = setState(not state)
        if after ~= before then library.PlaySound(after and "on" or "off") end
    end

    -- the text starts well to the right of the checkbox, like the reference
    local holder, nameLabel = titleBlock(row, name, sub, 44, 8)

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
                userToggle()
            end)
        if kbo.Flag then library.flags[kbo.Flag] = initialKey end
        holder.Size = UDim2.new(1, -(44 + 72), 0, 0)
    end

    paint = function(instant)
        local fill = state and colors.accent or colors.row
        local sc = state and colors.accent or colors.row
        if instant then
            box.BackgroundColor3 = fill
            boxStroke.Color = sc
            check.Visible = state
            checkScale.Scale = state and 1 or 0.01
        else
            tween(box, { BackgroundColor3 = fill }, 0.22, Enum.EasingStyle.Quint)
            tween(boxStroke, { Color = sc }, 0.22, Enum.EasingStyle.Quint)
            if state then
                -- เครื่องหมายถูกเด้งขึ้นมา (Back = เกินนิดแล้วเด้งกลับ)
                check.Visible = true
                checkScale.Scale = 0.2
                tween(checkScale, { Scale = 1 }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            else
                tween(checkScale, { Scale = 0.01 }, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                task.delay(0.17, function()
                    if not state then check.Visible = false end
                end)
            end
        end
        nameLabel.TextTransparency = locked and 0.55 or 0
    end
    paint(true)
    onAccent(function() paint(true) end)

    connect(row.Activated, userToggle)

    self:_register(row, name .. " " .. tostring(sub or ""))
    local obj = { Type = "Toggle", Name = name, Default = default, Options = o, Parent = self, Instance = row }
    obj.Set = function(a, b) return setState(A(obj, a, b)) end
    obj.RawSet = function(a, b) return setState(A(obj, a, b), true) end
    obj.Get = function() return state end
    obj.Update = obj.Get
    obj.Reset = function() return setState(default) end
    -- obj:Toggle() / obj.Flip() = สลับสถานะ (เรียก Callback ตามปกติ, ไม่มีเสียงเพราะเป็นการสั่งจากสคริปต์)
    obj.Toggle = function() return setState(not state) end
    obj.Flip = obj.Toggle
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
    local row = newRow(sub and UI.btnHSub or UI.btnH, true)
    local _, nameLabel = titleBlock(row, name, sub, 0, 0, Enum.TextXAlignment.Center)

    local function press()
        if locked then return end
        if o.Condition and not o.Condition(presses) then return end
        presses = presses + 1
        library.PlaySound("click")
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

    -- Layout copied from the reference: name + small line on the top left, number box on the top right,
    -- thin track along the bottom (inset from both sides), solid knob with no white ring.
    local height = sub and 46 or 36
    local row = newRow(height, false)
    row.BackgroundColor3 = colors.rowSoft
    titleBlock(row, name, sub, 17, 70, nil, 4, 9)

    local box = new("TextBox", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -8, 0, 4),
        Size = UDim2.fromOffset(54, 22),
        BackgroundColor3 = colors.box,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        ClearTextOnFocus = true,
        Text = "",
        Parent = row,
    })
    accent(box, "TextColor3")
    round(box, 3)
    outline(box, colors.line, 1, 0.45)

    local track = new("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 30, 0, height - 8),
        Size = UDim2.new(1, -56, 0, 4),
        BackgroundColor3 = colors.track,
        BorderSizePixel = 0,
        Parent = row,
    })
    round(track, 2)
    local fill = new("Frame", { Size = UDim2.new(0, 0, 1, 0), BorderSizePixel = 0, Parent = track })
    accent(fill, "BackgroundColor3")
    round(fill, 2)
    local knob = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(11, 11),
        BorderSizePixel = 0,
        Parent = track,
    })
    accent(knob, "BackgroundColor3")
    new("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = knob })
    local hit = new("TextButton", {
        BackgroundTransparency = 1,
        Text = "",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 20, 0, height - 8),
        Size = UDim2.new(1, -36, 0, 22),
        Parent = row,
    })

    local function render(instant)
        local a = (max == min) and 0 or (value - min) / (max - min)
        local fs, kp = UDim2.new(a, 0, 1, 0), UDim2.new(a, 0, 0.5, 0)
        if instant then
            fill.Size = fs
            knob.Position = kp
        else
            tween(fill, { Size = fs }, 0.1, Enum.EasingStyle.Quad)
            tween(knob, { Position = kp }, 0.1, Enum.EasingStyle.Quad)
        end
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
    -- ลูกบิดขยายตอนจับ แล้วหดกลับตอนปล่อย
    connect(hit.InputBegan, function(input)
        if not isPress(input) then return end
        tween(knob, { Size = UDim2.fromOffset(16, 16) }, 0.2, Enum.EasingStyle.Back)
        local c
        c = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                c:Disconnect()
                tween(knob, { Size = UDim2.fromOffset(11, 11) }, 0.22, Enum.EasingStyle.Quint)
            end
        end)
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

    render(true)
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
    local head = newRow(sub and UI.ddHSub or UI.ddH, true)
    head.LayoutOrder = 1
    head.Parent = holder
    local title = titleBlock(head, name, sub, 9, 0)
    title.Size = UDim2.new(0.55, -9, 0, 0)
    -- the chosen value starts at 55% of the row (bold grey), like the reference
    local valueLabel = textOf(head, {
        Position = UDim2.new(0.55, 0, 0, 0),
        Size = UDim2.new(0.45, -32, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Color3.fromRGB(160, 162, 166),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
    })
    -- big solid white triangle on the right (drawn with 6 stacked bars so it needs no font or image)
    local arrow = new("Frame", {
        Name = "Arrow",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1, -16.5, 0.5, 0),
        Size = UDim2.fromOffset(11, 6),
        Parent = head,
    })
    for i = 0, 5 do
        new("Frame", {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.new(0.5, 0, 0, i),
            Size = UDim2.fromOffset(11 - 2 * i, 1),
            Parent = arrow,
        })
    end

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
    round(listFrame, 5)
    outline(listFrame, colors.line, 1)
    listLayout(listFrame, 2)
    padding(listFrame, 3)

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
        listFrame.Size = UDim2.new(1, 0, 0, math.min(#list * 24 + 6, 132))
    end

    local openToken = 0
    local function setOpen(s)
        if s and #list == 0 then return end
        s = s and true or false
        if s == open then return end
        open = s
        openToken = openToken + 1
        local token = openToken
        if arrow then tween(arrow, { Rotation = s and 180 or 0 }, 0.25, Enum.EasingStyle.Quint) end
        if s then
            listFrame.Visible = true
            tween(listFrame, { Size = UDim2.new(1, 0, 0, math.min(#list * 24 + 6, 132)) }, 0.26, Enum.EasingStyle.Quint)
        else
            tween(listFrame, { Size = UDim2.new(1, 0, 0, 0) }, 0.18, Enum.EasingStyle.Quint)
            task.delay(0.19, function()
                if token == openToken and not open then listFrame.Visible = false end
            end)
        end
    end

    local function commitChange(old, silent)
        local v = getValue()
        commit(o, v)
        display()
        paintItems()
        if not silent then spawnCallback(o.Callback, v, old) end
    end

    local function choose(item)
        library.PlaySound("click")
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
                Size = UDim2.new(1, 0, 0, 22),
                LayoutOrder = i,
                Parent = listFrame,
            })
            round(b, 4)
            local t = textOf(b, { Text = item, Size = UDim2.new(1, -12, 1, 0), Position = UDim2.fromOffset(8, 0), TextSize = 10 })
            connect(b.Activated, function() choose(item) end)
            items[i] = { button = b, text = t }
        end
        paintItems()
        if open then sizeList() end
    end

    connect(head.Activated, function()
        library.PlaySound("click")
        setOpen(not open)
    end)

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

    local row = newRow(sub and UI.rowHSub or UI.rowH, false)
    local title = titleBlock(row, name, sub, 8, 0)
    title.Size = UDim2.new(0.5, -8, 0, 0)
    local box = new("TextBox", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.new(0.42, 0, 0, 22),
        BackgroundColor3 = colors.field,
        BorderSizePixel = 0,
        Text = tostring(value),
        PlaceholderText = tostring(pick(o, "Placeholder") or ""),
        PlaceholderColor3 = colors.subtext,
        TextColor3 = colors.text,
        Font = Enum.Font.GothamMedium,
        TextSize = 10,
        ClearTextOnFocus = false,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    padding(box, 6, 0)
    round(box, 4)
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
    local row = newRow(sub and UI.rowHSub or UI.rowH, false)
    local title = titleBlock(row, name, sub, 8, 0)
    title.Size = UDim2.new(1, -(8 + 72), 0, 0)
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
    local head = newRow(sub and UI.rowHSub or UI.rowH, true)
    head.LayoutOrder = 1
    head.Parent = holder
    local title = titleBlock(head, name, sub, 8, 0)
    title.Size = UDim2.new(1, -(8 + 44), 0, 0)
    local swatch = new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(28, 16),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Parent = head,
    })
    round(swatch, 4)
    outline(swatch, colors.line, 1)

    local panel = new("Frame", {
        BackgroundColor3 = colors.field,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 108),
        Visible = false,
        LayoutOrder = 2,
        Parent = holder,
    })
    round(panel, 5)
    outline(panel, colors.line, 1)
    padding(panel, 6)

    local sv = new("Frame", {
        Size = UDim2.new(1, -22, 1, 0),
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
        Size = UDim2.new(0, 14, 1, 0),
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

function Section:SetCollapsed(state, instant)
    state = state and true or false
    if state == self.collapsed then return end
    self.collapsed = state
    local content = self.content
    tween(self.chevron, { Rotation = state and -90 or 0 }, 0.22, Enum.EasingStyle.Quint)
    self._ctoken = (self._ctoken or 0) + 1
    local token = self._ctoken

    -- k = ตัวคูณซูมของหน้าต่าง (header สูง 20 หน่วยเสมอ) ใช้แปลงความสูงจริงเป็นหน่วยตอนออกแบบ
    local k = self.header.AbsoluteSize.Y / 18
    if k < 0.1 then instant = true end
    if content.Visible and content.AutomaticSize == Enum.AutomaticSize.Y then
        self._fullH = content.AbsoluteSize.Y / math.max(k, 0.1)
    end
    local full = self._fullH

    local function settle(hidden)
        content.AutomaticSize = Enum.AutomaticSize.Y
        content.Size = UDim2.new(1, 0, 0, 0)
        content.ClipsDescendants = false
        content.Visible = not hidden
    end

    if instant or not full or full < 2 then
        settle(state)
        return
    end

    if state then
        if content.AutomaticSize == Enum.AutomaticSize.Y then
            content.AutomaticSize = Enum.AutomaticSize.None
            content.Size = UDim2.new(1, 0, 0, full)
        end
        content.ClipsDescendants = true
        tween(content, { Size = UDim2.new(1, 0, 0, 0) }, 0.24, Enum.EasingStyle.Quint)
        task.delay(0.25, function()
            if token == self._ctoken and self.collapsed then settle(true) end
        end)
    else
        if not content.Visible then
            content.AutomaticSize = Enum.AutomaticSize.None
            content.Size = UDim2.new(1, 0, 0, 0)
            content.Visible = true
        end
        content.ClipsDescendants = true
        tween(content, { Size = UDim2.new(1, 0, 0, full) }, 0.3, Enum.EasingStyle.Quint)
        task.delay(0.31, function()
            if token == self._ctoken and not self.collapsed then settle(false) end
        end)
    end
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
    -- flat dark panel: small corners, no border line (same as the reference)
    round(frame, 4)
    padding(frame, 14, 3, 14, 8)
    listLayout(frame, 4)

    local header = new("TextButton", {
        BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
        Size = UDim2.new(1, 0, 0, 18), LayoutOrder = 0, Parent = frame,
    })
    textOf(header, {
        Text = name, Size = UDim2.new(1, -20, 1, 0), TextSize = UI.textSection,
        Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1),
    })
    local chevron = textOf(header, {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(14, 14), Text = "▼", TextSize = 8,
        TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = colors.subtext,
        Visible = library.configuration.showSectionArrow == true,
    })
    local content = new("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 1,
        Parent = frame,
    })
    listLayout(content, UI.contentGap)

    local sec = setmetatable({
        Type = "Section", Name = name, Parent = self, frame = frame, content = content,
        chevron = chevron, header = header, page = self.page, entries = {}, _order = 0, collapsed = false,
        Instance = frame, Flags = library.flags,
    }, Section)
    connect(header.Activated, function()
        library.PlaySound("click")
        sec:ToggleCollapsed()
    end)
    table.insert(self.sections, sec)
    return sec
end
for _, alias in ipairs({ "AddSection", "NewSection", "Section", "Sec", "S" }) do Tab[alias] = Tab.CreateSection end

function Window:SelectTab(tab)
    if type(tab) == "number" then tab = self.tabs[tab] end
    if not tab then return end
    local prev = self.activeTab
    local newIdx, prevIdx = 0, 0
    for i, t in ipairs(self.tabs) do
        if t == tab then newIdx = i end
        if t == prev then prevIdx = i end
    end
    for _, t in ipairs(self.tabs) do
        local on = (t == tab)
        t.page.Visible = on
        tween(t.button, { BackgroundColor3 = on and colors.tabActive or colors.tabFill }, 0.2, Enum.EasingStyle.Quint)
        tween(t.stroke, { Color = on and colors.accent or colors.tabLine }, 0.2, Enum.EasingStyle.Quint)
        if on then
            if prev ~= tab then
                -- underline grows out from the middle of the selected tab
                t.underline.Size = UDim2.new(0, 0, 0, 2)
                t.underline.Visible = true
                tween(t.underline, { Size = UDim2.new(0.7, 0, 0, 2) }, 0.32, Enum.EasingStyle.Quint)
                -- หน้าเนื้อหาสไลด์เข้ามาตามทิศที่แท็บอยู่ (ซ้าย/ขวา)
                if prev then
                    local dir = (newIdx > prevIdx) and 1 or -1
                    t.page.Position = UDim2.fromOffset(dir * 26, 0)
                    tween(t.page, { Position = UDim2.fromOffset(0, 0) }, 0.34, Enum.EasingStyle.Quint)
                end
            end
        else
            t.underline.Visible = false
        end
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
    if sub ~= nil then sub = tostring(sub) end
    if sub == "" then sub = nil end

    -- ความกว้างแท็บคำนวณจากข้อความ ครั้งเดียวตอนสร้าง (ขั้นต่ำเท่ากันทุกแท็บ เหมือนในรูป)
    -- ไม่ใช้ AutomaticSize / UIListLayout กับตัวปุ่ม → กดเลือกแล้วแท็บจะไม่ขยายใหญ่อีก
    local nameSize, subSize = 10, 10
    local textW = measure(name, nameSize, Enum.Font.GothamBold)
    if sub then textW = math.max(textW, measure(sub, subSize, FONT_SEMI)) end
    local width = math.max(UI.tabMinW, math.ceil(textW) + 16)

    local button = new("TextButton", {
        BackgroundColor3 = colors.tabFill,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        Size = UDim2.fromOffset(width, UI.tabH),
        LayoutOrder = #self.tabs + 1,
        Parent = self.tabBar,
    })
    round(button, 5)
    -- thin grey-blue border; the selected tab gets the bright accent border + underline
    local stroke = outline(button, colors.tabLine, 1.2)

    -- ข้อความอยู่ใน content (มี layout ของตัวเอง) ส่วน underline เป็นลูกของปุ่มโดยตรง
    -- จึงไม่ถูก layout นับรวม และมีขนาดเป็นพิกเซลคงที่
    local content = new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = button })
    listLayout(content, 0, nil, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center)
    textOf(content, {
        Text = name, Size = UDim2.new(1, -8, 0, 12), LayoutOrder = 1,
        TextTruncate = Enum.TextTruncate.None, TextXAlignment = Enum.TextXAlignment.Center,
        Font = Enum.Font.GothamBold, TextSize = nameSize,
    })
    if sub then
        textOf(content, {
            Text = sub, Size = UDim2.new(1, -8, 0, 11), LayoutOrder = 2,
            TextTruncate = Enum.TextTruncate.None, TextXAlignment = Enum.TextXAlignment.Center,
            Font = FONT_SEMI, TextSize = subSize, TextColor3 = colors.sub,
        })
    end
    local underline = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, -2),
        Size = UDim2.new(0.7, 0, 0, 2),
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
        ScrollBarThickness = 2,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Visible = false,
        Parent = self.pages,
    })
    accent(page, "ScrollBarImageColor3")
    padding(page, 2, 2, 3, 14)
    local cols = new("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = page,
    })
    listLayout(cols, UI.colGap, Enum.FillDirection.Horizontal)
    local half = math.floor(UI.colGap / 2)
    local left = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(0.5, -half, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 1, Parent = cols })
    local right = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(0.5, -half, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, Parent = cols })
    listLayout(left, UI.secGap)
    listLayout(right, UI.secGap)

    local tab = setmetatable({
        Type = "Tab", Name = name, Parent = self, button = button, stroke = stroke,
        underline = underline, page = page, left = left, right = right,
        sections = {}, count = { left = 0, right = 0 }, Instance = page, Flags = library.flags,
    }, Tab)
    table.insert(self.tabs, tab)
    -- เอาเมาส์ชี้แท็บที่ยังไม่ถูกเลือก → สว่างขึ้นเล็กน้อย
    connect(button.MouseEnter, function()
        if self.activeTab ~= tab then
            tween(button, { BackgroundColor3 = colors.tabFill:Lerp(colors.tabActive, 0.5) }, 0.15)
        end
    end)
    connect(button.MouseLeave, function()
        if self.activeTab ~= tab then
            tween(button, { BackgroundColor3 = colors.tabFill }, 0.15)
        end
    end)
    connect(button.Activated, function()
        if self.activeTab ~= tab then library.PlaySound("tab") end
        self:SelectTab(tab)
    end)
    if not self.activeTab then self:SelectTab(tab) end
    return tab
end
for _, alias in ipairs({ "AddTab", "NewTab", "Tab", "T" }) do Window[alias] = Window.CreateTab end

-- window:Toggle()        สลับเปิด/ปิด
-- window:Toggle(true)    เปิด      window:Toggle(false)  ปิด
-- window:Toggle(x, true) ตัวที่สอง = silent (ไม่เล่นเสียง)
function Window:Toggle(state, silent)
    if state == nil then state = not self.Visible end
    state = state and true or false
    if state == self.Visible then return state end
    self.Visible = state
    self._anim = (self._anim or 0) + 1
    local token = self._anim
    local root, body, main, scale = self.root, self.body, self.main, self.scale
    local glow, fit = self.glowStroke, self.fit

    if not silent then library.PlaySound(state and "open" or "close") end

    -- ปุ่มลอยบนมือถือเด้งตอนกด
    if self.mobileScale then
        self.mobileScale.Scale = 0.72
        tween(self.mobileScale, { Scale = 1 }, 0.38, Enum.EasingStyle.Back)
    end

    if state then
        if not root.Visible then
            -- เริ่มจากเล็ก + จาง + ต่ำลงเล็กน้อย แล้วเด้งขึ้นมา
            scale.Scale = fit * 0.88
            main.GroupTransparency = 1
            body.Position = UDim2.new(0.5, 0, 0.5, 22)
            if glow then glow.Transparency = 1 end
            root.Visible = true
        end
        tween(scale, { Scale = fit }, 0.42, Enum.EasingStyle.Back)
        tween(body, { Position = UDim2.fromScale(0.5, 0.5) }, 0.4, Enum.EasingStyle.Quint)
        tween(main, { GroupTransparency = 0 }, 0.28, Enum.EasingStyle.Quad)
        if glow then tween(glow, { Transparency = 0.8 }, 0.55, Enum.EasingStyle.Quad) end
    else
        tween(scale, { Scale = fit * 0.9 }, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        tween(body, { Position = UDim2.new(0.5, 0, 0.5, 14) }, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        tween(main, { GroupTransparency = 1 }, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        if glow then tween(glow, { Transparency = 1 }, 0.2) end
        task.delay(0.24, function()
            if self._anim == token and not self.Visible then root.Visible = false end
        end)
    end
    return state
end
function Window:Show(silent) return self:Toggle(true, silent) end
function Window:Hide(silent) return self:Toggle(false, silent) end
function Window:IsVisible() return self.Visible end

-- ฟังก์ชัน Toggle ระดับ library (ใช้กับหน้าต่างล่าสุดที่สร้าง)
--   library:Toggle() / library.Toggle()   สลับเปิด/ปิด
--   library:Toggle(true) / library:Toggle(false)
--   library:Show() / library:Hide() / library:IsVisible()
function library.Toggle(a, b)
    local w = library.window
    if not w then return nil end
    return w:Toggle(A(library, a, b))
end
function library.Show() if library.window then return library.window:Toggle(true) end end
function library.Hide() if library.window then return library.window:Toggle(false) end end
function library.IsVisible() return library.window ~= nil and library.window.Visible end

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

local function currentView(gui)
    local view = gui.AbsoluteSize
    if view.X < 50 or view.Y < 50 then
        local camera = Workspace.CurrentCamera
        view = camera and camera.ViewportSize or Vector2.new(1280, 720)
    end
    return view
end

-- ตัวคูณขยายให้หน้าต่างพอดีกับหน้าจอ (ใช้ได้ทั้ง PC และมือถือ)
--  • จอใหญ่ (สูง >= 900px)  : หน้าต่างกว้าง ~54% สูง ~60% ของจอ  = สัดส่วนเดียวกับรูปตัวอย่าง
--  • จอเล็ก (สูง <= 420px)  : ค่อย ๆ เพิ่มเป็น ~78% x 88% เพื่อให้ตัวหนังสืออ่านออก
-- ปรับได้ที่ library.configuration.windowFraction / windowFractionSmall / minScale / maxScale
local function fitScale(view, w, h)
    local cfg = library.configuration
    local t = math.clamp((900 - view.Y) / 480, 0, 1)
    local big, small = cfg.windowFraction, cfg.windowFractionSmall
    local fx = big.X + (small.X - big.X) * t
    local fy = big.Y + (small.Y - big.Y) * t
    local s = math.min(view.X * fx / w, view.Y * fy / h)
    return math.clamp(s, cfg.minScale, cfg.maxScale)
end

local function createWindow(first, ...)
    local o = resolve("Window", first or {}, ...)
    local name = tostring(pick(o, "Name", "Title") or library.configuration.name or "QuickX Hub")
    local gui = ensureGui()

    -- baseW/baseH = ขนาด "ตอนออกแบบ" (ก่อนซูม) ส่วน dw/dh คือขนาดปัจจุบัน (ลาก grip เปลี่ยนได้)
    local baseW, baseH = UI.winW, UI.winH
    local sz = o.Size
    if typeof(sz) == "Vector2" then
        baseW, baseH = sz.X, sz.Y
    elseif typeof(sz) == "UDim2" then
        baseW, baseH = sz.X.Offset, sz.Y.Offset
    end
    local dw, dh = baseW, baseH
    local fit = 1
    local fixedScale = tonumber(o.Scale)

    -- root = กรอบที่มีขนาดจริงบนจอ (ใช้ลาก/ย้าย), body = เนื้อหาขนาดตอนออกแบบ + UIScale
    local root = new("Frame", {
        Name = "Root",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(dw, dh),
        Parent = gui,
    })
    local body = new("Frame", {
        Name = "Body",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(dw, dh),
        Parent = root,
    })
    local scale = new("UIScale", { Scale = 1, Parent = body })

    local glow = new("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 5, 1, 5),
        Parent = body,
    })
    round(glow, 9)
    local glowStroke = accent(outline(glow, colors.accent, 3, 0.88), "Color")

    -- main เป็น CanvasGroup เพื่อให้ทั้งหน้าต่างจางเข้า/ออกพร้อมกันได้ (GroupTransparency)
    local main = new("CanvasGroup", {
        Name = "Main",
        BackgroundColor3 = colors.window,
        BorderSizePixel = 0,
        GroupTransparency = 0,
        Size = UDim2.fromScale(1, 1),
        Parent = body,
    })
    round(main, 5)
    accent(outline(main, colors.accent, 1.6), "Color")

    -- ===== หัวหน้าต่าง: โลโก้ + ชื่อ + ช่องค้นหา =====
    local header = new("Frame", { Name = "Header", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, UI.header), Parent = main })
    local letter = "H"
    local okc, ch = pcall(function() return utf8.char(utf8.codepoint(name, 1)) end)
    if okc and ch then letter = string.upper(ch) end
    local logo = makeLogo(header, 26, pick(o, "Image", "Logo") or library.configuration.logo, letter)
    logo.AnchorPoint = Vector2.new(0, 0.5)
    logo.Position = UDim2.new(0, 11, 0.5, 0)

    local searchW = (baseW < 450) and 104 or 152
    local titleLabel = textOf(header, {
        Text = name,
        Position = UDim2.fromOffset(43, 0),
        Size = UDim2.new(1, -(43 + searchW + 18), 1, 0),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
    })
    accent(titleLabel, "TextColor3")

    local search = new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(searchW, 31),
        BackgroundColor3 = colors.search,
        BorderSizePixel = 0,
        Parent = header,
    })
    round(search, 6)
    -- thin border (the reference is much thinner and softer than a full-bright line)
    accent(outline(search, colors.accent, 1.2, 0.35), "Color")
    -- two small blue gears instead of a magnifier (that is the icon in the reference)
    local icon = new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(30, 31), Parent = search })
    makeGear(icon, 14.5, 13, 5.8, colors.search)
    makeGear(icon, 20.5, 19.5, 3.6, colors.search)
    local searchBox = new("TextBox", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(30, 0),
        Size = UDim2.new(1, -36, 1, 0),
        Text = "",
        PlaceholderText = "Search... (Ctrl+F)",
        PlaceholderColor3 = Color3.fromRGB(172, 174, 180),
        TextColor3 = colors.text,
        Font = FONT_SEMI,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ClearTextOnFocus = false,
        Parent = search,
    })

    -- ===== แถบแท็บ + พื้นที่เนื้อหา =====
    local tabBar = new("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(10, UI.header - 2),
        Size = UDim2.new(1, -20, 0, UI.tabH + 4),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        Parent = main,
    })
    padding(tabBar, 2)
    listLayout(tabBar, UI.tabGap, Enum.FillDirection.Horizontal)

    local pagesTop = UI.header + UI.tabH + 12
    local pages = new("Frame", {
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Position = UDim2.fromOffset(UI.pad, pagesTop),
        Size = UDim2.new(1, -2 * UI.pad, 1, -(pagesTop + 8)),
        Parent = main,
    })

    local window = setmetatable({
        Type = "Window", Name = name, Library = library, Gui = gui, root = root, body = body,
        main = main, glowStroke = glowStroke, scale = scale, tabBar = tabBar, pages = pages, searchBox = searchBox,
        titleLabel = titleLabel, tabs = {}, Visible = true, Flags = library.flags, fit = 1,
    }, Window)
    library.window = window

    -- ===== ขนาด / การย่อขยายตามหน้าจอ =====
    local function applySize()
        root.Size = UDim2.fromOffset(math.floor(dw * fit + 0.5), math.floor(dh * fit + 0.5))
        body.Size = UDim2.fromOffset(dw, dh)
        scale.Scale = fit
        window.fit = fit
        if library.notifyScale then
            library.notifyScale.Scale = math.clamp(fit * 0.7, 0.85, 1.6)
        end
        local mb = window.mobileButton
        if mb then
            local px = math.floor(math.clamp(50 * fit, 40, 96) + 0.5)
            mb.Size = UDim2.fromOffset(px, px)
        end
    end

    local function refit()
        local view = currentView(gui)
        if fixedScale then
            fit = math.clamp(fixedScale, 0.3, 5)
        elseif o.AutoScale == false then
            fit = 1
        else
            fit = fitScale(view, baseW, baseH)
        end
        -- ไม่ให้หน้าต่างล้นจอ
        dw = math.min(dw, math.max(UI.minW, (view.X - 10) / fit))
        dh = math.min(dh, math.max(UI.minH, (view.Y - 10) / fit))
        applySize()
    end

    -- window:SetScale(1.2) = บังคับตัวคูณเอง, window:SetScale(nil) = กลับไปปรับอัตโนมัติ
    window.SetScale = function(a, b)
        fixedScale = tonumber(A(window, a, b))
        refit()
        return fit
    end

    onAccent(function()
        if window.activeTab then
            for _, t in ipairs(window.tabs) do
                local on = (t == window.activeTab)
                t.stroke.Color = on and colors.accent or colors.tabLine
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

    -- ===== ปุ่มมุมขวาล่าง: ลากเพื่อปรับขนาดหน้าต่าง (ไอคอนแว่นขยายเหมือนในรูป) =====
    -- gripHit ใหญ่กว่าไอคอน เพื่อให้นิ้วแตะง่ายบนมือถือ
    local gripHit = new("TextButton", {
        Name = "ResizeGrip",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, 0, 1, 0),
        Size = UDim2.fromOffset(28, 28),
        BackgroundTransparency = 1,
        AutoButtonColor = false,
        Text = "",
        BorderSizePixel = 0,
        ZIndex = 10,
        Parent = main,
    })
    -- Solid blue square tucked into the bottom-right corner (the window corner rounds it off),
    -- with a light "zoom in" icon: ring + plus + handle. Same look as the reference.
    local grip = new("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, 0, 1, 0),
        Size = UDim2.fromOffset(17, 17),
        BorderSizePixel = 0,
        ZIndex = 10,
        Parent = gripHit,
    })
    accent(grip, "BackgroundColor3")
    round(grip, 5)
    local ink = Color3.fromRGB(214, 218, 255)
    local gring = new("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(7.5, 7.5),
        Size = UDim2.fromOffset(9, 9),
        ZIndex = 11,
        Parent = grip,
    })
    round(gring, 5)
    outline(gring, ink, 1.1)
    for _, spec in ipairs({ { 4, 1.2 }, { 1.2, 4 } }) do
        new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromOffset(7.5, 7.5),
            Size = UDim2.fromOffset(spec[1], spec[2]),
            BackgroundColor3 = ink,
            BorderSizePixel = 0,
            ZIndex = 11,
            Parent = grip,
        })
    end
    local ghandle = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(12.6, 12.6),
        Size = UDim2.fromOffset(4.5, 1.2),
        Rotation = 45,
        BackgroundColor3 = ink,
        BorderSizePixel = 0,
        ZIndex = 11,
        Parent = grip,
    })
    round(ghandle, 1)

    connect(gripHit.InputBegan, function(input)
        if not isPress(input) then return end
        local start, startPos = input.Position, root.Position
        local w0, h0 = dw, dh
        local sw, sh = root.Size.X.Offset, root.Size.Y.Offset
        dragSession(input, function(p)
            local d = p - start
            local limit = currentView(gui)
            dw = math.clamp(w0 + d.X / fit, UI.minW, math.max(UI.minW, (limit.X - 10) / fit))
            dh = math.clamp(h0 + d.Y / fit, UI.minH, math.max(UI.minH, (limit.Y - 10) / fit))
            applySize()
            -- root ยึดกึ่งกลาง จึงเลื่อนตำแหน่งครึ่งหนึ่งของที่ขยาย เพื่อให้มุมซ้ายบนอยู่ที่เดิม
            local nw, nh = root.Size.X.Offset, root.Size.Y.Offset
            root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (nw - sw) / 2, startPos.Y.Scale, startPos.Y.Offset + (nh - sh) / 2)
        end)
    end)

    -- ===== ปุ่มเปิด/ปิดสำหรับมือถือ =====
    local useMobile = o.MobileButton
    if useMobile == nil then
        useMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    end
    if useMobile then
        local mb = new("TextButton", {
            Name = "MobileToggle",
            Text = "",
            AutoButtonColor = false,
            BackgroundColor3 = Color3.fromRGB(2, 5, 16),
            BorderSizePixel = 0,
            Position = UDim2.new(0, 14, 0.3, 0),
            Size = UDim2.fromOffset(48, 48),
            Parent = gui,
        })
        new("UICorner", { CornerRadius = UDim.new(0.22, 0), Parent = mb })
        -- the reference has no thick border: dark rounded square, soft thin edge, logo fills the whole button
        accent(outline(mb, colors.accent, 1.2, 0.6), "Color")
        local logoImage = pick(o, "Image", "Logo") or library.configuration.logo
        local mlogo = makeLogo(mb, 32, logoImage, letter)
        mlogo.AnchorPoint = Vector2.new(0.5, 0.5)
        mlogo.Position = UDim2.fromScale(0.5, 0.5)
        if logoImage then
            mlogo.Size = UDim2.fromScale(1, 1)
            new("UICorner", { CornerRadius = UDim.new(0.22, 0), Parent = mlogo })
        else
            mlogo.Size = UDim2.fromScale(0.8, 0.8)
        end
        window.mobileScale = new("UIScale", { Scale = 1, Parent = mlogo })
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

    refit()
    connect(gui:GetPropertyChangedSignal("AbsoluteSize"), refit)

    connect(UserInputService.InputBegan, function(input, gp)
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if searchBox:IsFocused() then return end
        if input.KeyCode == library.configuration.searchKeybind
            and (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
            if not window.Visible then window:Toggle(true) end
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

    -- อนิเมชันตอนเปิดครั้งแรก (ไม่มีเสียง จะได้ไม่ดังตอนรันสคริปต์)
    -- ปิดได้ด้วย CreateWindow({ Intro = false })
    pcall(library.PreloadSounds)
    if o.Intro ~= false then
        window.Visible = false
        root.Visible = false
        window:Toggle(true, true)
    end

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
    if shared.MapoUILibrary == library then shared.MapoUILibrary = nil end
    if type(library.UnloadCallback) == "function" then pcall(library.UnloadCallback) end
end

return library, library.flags, library.subs
