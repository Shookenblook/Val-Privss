-- ============================================================
-- Blueblurhub Loader
-- Shookenblook/Val-Privss
-- ============================================================

local HttpService   = game:GetService("HttpService")
local InsertService = game:GetService("InsertService")
local Players       = game:GetService("Players")
local StarterGui    = game:GetService("StarterGui")

local GUI_ASSET_ID = 78145948946458
local RAW_BASE     = "https://raw.githubusercontent.com/Shookenblook/Val-Privss/main/"

-- ============================================================
-- FETCH WITH BETTER ERROR HANDLING
-- ============================================================

local function fetch(filename)
    local url = RAW_BASE .. filename
    print("[Loader] Fetching: " .. url)
    
    -- Check HTTP is enabled first
    if not HttpService.HttpEnabled then
        warn("[Loader] HTTP is DISABLED! Go to Game Settings → Security → Allow HTTP Requests")
        return nil
    end
    
    local ok, result = pcall(function()
        return HttpService:GetAsync(url, true)
    end)
    
    if not ok then
        warn("[Loader] GetAsync failed: " .. tostring(result))
        return nil
    end
    
    if type(result) ~= "string" then
        warn("[Loader] Got nil/non-string response for: " .. filename)
        warn("[Loader] Check the file exists at: " .. url)
        return nil
    end
    
    if #result == 0 then
        warn("[Loader] Empty response for: " .. filename)
        return nil
    end
    
    print("[Loader] Fetched " .. filename .. " (" .. #result .. " bytes)")
    return result
end

-- ============================================================
-- LOAD BRIDGE
-- ============================================================

local function loadBridge()
    print("[Loader] Loading bridge...")
    local code = fetch("bridge.lua")
    if not code then
        warn("[Loader] Could not fetch bridge.lua")
        warn("[Loader] Make sure bridge.lua exists in your repo at:")
        warn("[Loader] " .. RAW_BASE .. "bridge.lua")
        return false
    end
    
    local fn, compileErr = loadstring(code)
    if not fn then
        warn("[Loader] bridge.lua compile error: " .. tostring(compileErr))
        return false
    end
    
    local ok, runtimeErr = pcall(fn)
    if not ok then
        warn("[Loader] bridge.lua runtime error: " .. tostring(runtimeErr))
        return false
    end
    
    print("[Loader] Bridge loaded OK")
    return true
end

-- ============================================================
-- LOAD GUI
-- ============================================================

local function loadGui()
    print("[Loader] Loading GUI asset " .. GUI_ASSET_ID .. "...")
    
    local ok, result = pcall(function()
        return InsertService:LoadAsset(GUI_ASSET_ID)
    end)
    
    if not ok then
        warn("[Loader] InsertService failed: " .. tostring(result))
        warn("[Loader] Make sure asset " .. GUI_ASSET_ID .. " is set to PUBLIC on create.roblox.com")
        return false
    end
    
    local count = 0
    for _, child in ipairs(result:GetChildren()) do
        child.Parent = StarterGui
        count = count + 1
        print("[Loader] Installed: " .. child.Name)
    end
    result:Destroy()
    
    if count == 0 then
        warn("[Loader] Asset loaded but had no children!")
        return false
    end
    
    print("[Loader] GUI installed (" .. count .. " items)")
    return true
end

-- ============================================================
-- GIVE GUI TO PLAYER
-- ============================================================

local function giveToPlayer(player)
    task.wait(1)
    local given = 0
    for _, item in ipairs(StarterGui:GetChildren()) do
        local existing = player.PlayerGui:FindFirstChild(item.Name)
        if existing then existing:Destroy() end
        item:Clone().Parent = player:WaitForChild("PlayerGui")
        given = given + 1
    end
    if given > 0 then
        print("[Loader] Gave " .. given .. " GUI item(s) to " .. player.Name)
    end
end

-- ============================================================
-- BOOT
-- ============================================================

print("[Loader] Starting...")
print("[Loader] Base URL: " .. RAW_BASE)
print("[Loader] Asset ID: " .. GUI_ASSET_ID)

-- Quick connectivity test
local testOk = pcall(function()
    HttpService:GetAsync("https://raw.githubusercontent.com", true)
end)
if not testOk then
    warn("[Loader] Cannot reach GitHub! HTTP may be disabled or blocked.")
    warn("[Loader] Enable: Game Settings → Security → Allow HTTP Requests")
end

local bridgeOk = loadBridge()
if not bridgeOk then
    warn("[Loader] Bridge failed — scripts may not execute")
end

task.wait(0.5)

local guiOk = loadGui()
if not guiOk then
    warn("[Loader] GUI failed — check asset ID and permissions")
end

for _, p in ipairs(Players:GetPlayers()) do
    task.spawn(giveToPlayer, p)
end

Players.PlayerAdded:Connect(function(player)
    task.spawn(giveToPlayer, player)
end)

if bridgeOk and guiOk then
    print("[Loader] Blueblurhub deployed successfully!")
else
    warn("[Loader] Deployed with errors — check warnings above")
end
