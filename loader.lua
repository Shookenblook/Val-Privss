-- loader.lua
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/Shookenblook/Val-Privss/main/loader.lua"))()

local HttpService   = game:GetService("HttpService")
local InsertService = game:GetService("InsertService")
local Players       = game:GetService("Players")
local StarterGui    = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BASE = "https://raw.githubusercontent.com/Shookenblook/Val-Privss/main/"
local ASSET_ID = 78145948946458 -- your .rbxm asset ID

-- Fetch a lua file from GitHub
local function fetch(file)
    local ok, result = pcall(function()
        return HttpService:GetAsync(BASE .. file, true)
    end)
    if not ok or type(result) ~= "string" or #result == 0 then
        warn("[Loader] Failed to fetch: " .. file)
        return nil
    end
    print("[Loader] Fetched: " .. file)
    return result
end

-- Run a server script from GitHub
local function runServer(file)
    local code = fetch(file)
    if not code then return false end
    local fn, err = loadstring(code)
    if not fn then
        warn("[Loader] Compile error in " .. file .. ": " .. tostring(err))
        return false
    end
    local ok, runtimeErr = pcall(fn)
    if not ok then
        warn("[Loader] Runtime error in " .. file .. ": " .. tostring(runtimeErr))
        return false
    end
    print("[Loader] Server script ran: " .. file)
    return true
end

-- Inject a LocalScript into a player
local function injectLocal(player, file, name)
    local code = fetch(file)
    if not code then return end
    local ls = Instance.new("LocalScript")
    ls.Name = name or file
    ls.Source = code
    ls.Parent = player:WaitForChild("PlayerGui")
    print("[Loader] Injected " .. file .. " into " .. player.Name)
end

-- Give all LocalScripts to a player
local function giveToPlayer(player)
    task.wait(0.5)
    injectLocal(player, "gui.lua",   "BlueblurhubGUI")
    injectLocal(player, "drag.lua",  "BlueblurhubDrag")
    injectLocal(player, "clear.lua", "BlueblurhubClear")
    injectLocal(player, "r6.lua",    "BlueblurhubR6")
end

-- ============================================================
-- BOOT
-- ============================================================

print("[Loader] Starting Blueblurhub...")

-- 1. Run server bridge
runServer("bridge.lua")

-- 2. Run R6 server script
runServer("r6server.lua")

-- 3. Give GUI to current players
for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(giveToPlayer, player)
end

-- 4. Give GUI to future players
Players.PlayerAdded:Connect(function(player)
    task.spawn(giveToPlayer, player)
end)

print("[Loader] Done.")
