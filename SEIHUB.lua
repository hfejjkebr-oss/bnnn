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
