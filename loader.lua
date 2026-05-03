-- loader.lua
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/Shookenblook/Val-Privss/main/loader.lua"))()

local HttpService       = game:GetService("HttpService")
local InsertService     = game:GetService("InsertService")
local Players           = game:GetService("Players")
local StarterGui        = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BASE     = "https://raw.githubusercontent.com/Shookenblook/Val-Privss/main/"
local ASSET_ID = 102617310867201

-- Fetch and run a server script from GitHub
local function runServer(file)
    local ok, code = pcall(function()
        return HttpService:GetAsync(BASE .. file, true)
    end)
    if not ok or type(code) ~= "string" then
        warn("[Loader] Failed to fetch: " .. file)
        return false
    end
    local fn, err = loadstring(code)
    if not fn then
        warn("[Loader] Compile error " .. file .. ": " .. tostring(err))
        return false
    end
    local ok2, err2 = pcall(fn)
    if not ok2 then
        warn("[Loader] Runtime error " .. file .. ": " .. tostring(err2))
        return false
    end
    print("[Loader] Loaded: " .. file)
    return true
end

-- Load the ScreenGui rbxm from Roblox asset
local function loadGui()
    local ok, model = pcall(function()
        return InsertService:LoadAsset(ASSET_ID)
    end)
    if not ok then
        warn("[Loader] Asset load failed: " .. tostring(model))
        warn("[Loader] Make sure " .. ASSET_ID .. " is PUBLIC on create.roblox.com")
        return false
    end
    -- Move everything into StarterGui
    for _, child in ipairs(model:GetChildren()) do
        child.Parent = StarterGui
        print("[Loader] Installed into StarterGui: " .. child.Name)
    end
    model:Destroy()
    return true
end

-- Give StarterGui contents to a specific player right now
local function giveToPlayer(player)
    task.wait(0.5)
    for _, item in ipairs(StarterGui:GetChildren()) do
        local existing = player.PlayerGui:FindFirstChild(item.Name)
        if existing then existing:Destroy() end
        item:Clone().Parent = player:WaitForChild("PlayerGui")
    end
    print("[Loader] GUI given to: " .. player.Name)
end

-- ============================================================
-- BOOT ORDER
-- ============================================================

print("[Loader] Starting Blueblurhub...")

-- 1. Bridge first so MangoRemote exists before GUI loads
local bridgeOk = runServer("bridge.lua")
if not bridgeOk then
    warn("[Loader] Bridge failed — execution won't work")
end

task.wait(0.5)

-- 2. Load the ScreenGui from your rbxm asset
local guiOk = loadGui()
if not guiOk then
    warn("[Loader] GUI failed to load")
end

-- 3. Give to players already in game
for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(giveToPlayer, player)
end

-- 4. Give to future players
Players.PlayerAdded:Connect(function(player)
    task.spawn(giveToPlayer, player)
end)

if bridgeOk and guiOk then
    print("[Loader] Blueblurhub fully deployed!")
else
    warn("[Loader] Deployed with errors — check warnings above")
end
