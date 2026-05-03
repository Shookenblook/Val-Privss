-- ============================================================
-- Blueblurhub Loader — Force GUI Load
-- Shookenblook/Val-Privss
-- ============================================================

local HttpService   = game:GetService("HttpService")
local InsertService = game:GetService("InsertService")
local Players       = game:GetService("Players")
local StarterGui    = game:GetService("StarterGui")
local SS            = game:GetService("ServerScriptService")
local RS            = game:GetService("ReplicatedStorage")

local GUI_ASSET_ID = 78145948946458
local RAW_BASE     = "https://raw.githubusercontent.com/Shookenblook/Val-Privss/main/"

-- ============================================================
-- FETCH
-- ============================================================

local function fetch(filename)
    local url = RAW_BASE .. filename
    print("[Loader] Fetching: " .. url)
    local ok, result = pcall(function()
        return HttpService:GetAsync(url, true)
    end)
    if not ok or type(result) ~= "string" or #result == 0 then
        warn("[Loader] Failed to fetch: " .. filename .. " | " .. tostring(result))
        return nil
    end
    print("[Loader] Got " .. #result .. " bytes: " .. filename)
    return result
end

-- ============================================================
-- LOAD BRIDGE
-- ============================================================

local function loadBridge()
    local code = fetch("bridge.lua")
    if not code then return false end
    local fn, err = loadstring(code)
    if not fn then
        warn("[Loader] Bridge compile error: " .. tostring(err))
        return false
    end
    local ok, err2 = pcall(fn)
    if not ok then
        warn("[Loader] Bridge runtime error: " .. tostring(err2))
        return false
    end
    print("[Loader] Bridge OK")
    return true
end

-- ============================================================
-- FORCE GIVE GUI TO ONE PLAYER
-- Injects a LocalScript into their PlayerGui that
-- downloads and builds the GUI entirely on the client
-- ============================================================

local function forceGiveGui(player)
    -- This LocalScript runs on the client and force-loads the GUI
    local injector = Instance.new("LocalScript")
    injector.Name = "BlueblurhubLoader"

    -- We build the LocalScript source as a string
    -- It will HttpGet the GUI lua file and run it on the client
    injector.Source = [[
        local HttpService = game:GetService("HttpService")
        local Players     = game:GetService("Players")
        local LP          = Players.LocalPlayer

        -- Wait for PlayerGui
        local PlayerGui = LP:WaitForChild("PlayerGui")

        -- Remove old instance if exists
        local old = PlayerGui:FindFirstChild("Blueblurhub")
        if old then old:Destroy() end

        -- Force load the GUI script from GitHub
        local url = "https://raw.githubusercontent.com/Shookenblook/Val-Privss/main/gui.lua"
        local ok, code = pcall(function()
            return game:HttpGet(url, true)
        end)

        if not ok or type(code) ~= "string" or #code == 0 then
            warn("[GUI Loader] Failed to fetch gui.lua: " .. tostring(code))
            return
        end

        local fn, err = loadstring(code)
        if not fn then
            warn("[GUI Loader] Compile error: " .. tostring(err))
            return
        end

        local ok2, err2 = pcall(fn)
        if not ok2 then
            warn("[GUI Loader] Runtime error: " .. tostring(err2))
        else
            print("[GUI Loader] GUI loaded successfully!")
        end
    ]]

    injector.Parent = player:WaitForChild("PlayerGui")
    print("[Loader] GUI injector sent to: " .. player.Name)
end

-- ============================================================
-- ALSO TRY ASSET METHOD AS BACKUP
-- ============================================================

local function tryAssetLoad()
    local ok, model = pcall(function()
        return InsertService:LoadAsset(GUI_ASSET_ID)
    end)
    if not ok then
        warn("[Loader] Asset load failed (expected if on client): " .. tostring(model))
        return false
    end
    for _, child in ipairs(model:GetChildren()) do
        child.Parent = StarterGui
        print("[Loader] Asset installed: " .. child.Name)
    end
    model:Destroy()
    return true
end

-- ============================================================
-- BOOT
-- ============================================================

print("[Loader] Blueblurhub starting...")
print("[Loader] RAW_BASE: " .. RAW_BASE)

-- Load bridge first
local bridgeOk = loadBridge()
if not bridgeOk then
    warn("[Loader] Bridge failed — execution will not work")
end

task.wait(0.5)

-- Try asset load into StarterGui first
local assetOk = tryAssetLoad()

-- Force inject GUI into every current player
for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(forceGiveGui, player)
end

-- Force inject GUI into future players
Players.PlayerAdded:Connect(function(player)
    task.spawn(forceGiveGui, player)
end)

print("[Loader] Done. Bridge=" .. tostring(bridgeOk) .. " Asset=" .. tostring(assetOk))
