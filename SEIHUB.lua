if not game:IsLoaded() then game.Loaded:Wait() end

if getgenv().__UniLoader then return end
getgenv().__UniLoader = true

local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local ICON = "rbxassetid://99118312841228"

local Scripts = {
    [994732206] = {
        name = "Blox Fruits",
        url = "https://api.jnkie.com/api/v1/luascripts/public/64ab49bd8e2783d20595f5b70f2d81debd338648a4b8343056c0add3dbeb38f2/download",
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

local ok, err = pcall(function()
    loadstring(game:HttpGet(entry.url))()
end)

if ok then
    notify("Success", entry.name .. " loaded!")
else
    getgenv().__UniLoader = nil
    warn("[Loader] " .. tostring(err))
end
