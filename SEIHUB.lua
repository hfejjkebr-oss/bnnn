if not game:IsLoaded() then game.Loaded:Wait() end

if getgenv().__UniLoader then return end
getgenv().__UniLoader = true

local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local ICON = "rbxassetid://99118312841228"

local Scripts = {
    [994732206] = {
        name = "Blox Fruits",
        url = "https://api.jnkie.com/api/v1/luascripts/public/7066270102f5b648ad248cd330904b6b75428e5d0113494072fdcecf4fa50f61/download",
    },

    [3756501373] = {
        name = "MeMe Sea",
        url = "https://api.jnkie.com/api/v1/luascripts/public/51fba4670166d0b32677ed7955d631771520555be2f5424bbaab5aae9a4a883d/download",
        kaitun_url = "https://api.jnkie.com/api/v1/luascripts/public/ca52b2916309c6a0621618cddfb4591d4acf616bfb41720b89ebcd260d4c1bb2/download",
    },
}

local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Icon = ICON,
            Duration = duration or 5,
        })
    end)
end

local entry = Scripts[game.GameId]

if not entry then
    getgenv().__UniLoader = nil
    Players.LocalPlayer:Kick("Map Not Supported")
    return
end

local url = entry.url
local mode = "Normal"
local Script_Mode = getgenv().Script_Mode

if Script_Mode == "kaitun_Script" and entry.kaitun_url then
    url = entry.kaitun_url
    mode = "Kaitun"
end

local ok, err = pcall(function()
    loadstring(game:HttpGet(url))()
end)

if ok then
    notify("Success", entry.name .. " " .. mode .. " loaded!")
else
    getgenv().__UniLoader = nil
    warn("[Loader] " .. tostring(err))
end
