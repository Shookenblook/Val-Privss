-- Blueblurhub Loader
-- Shookenblook/Val-Privss

local InsertService = game:GetService("InsertService")
local Players       = game:GetService("Players")
local StarterGui    = game:GetService("StarterGui")

local GUI_ASSET_ID  = 78145948946458

-- Load the .rbxm from Roblox
local ok, model = pcall(function()
    return InsertService:LoadAsset(GUI_ASSET_ID)
end)

if not ok then
    warn("[Loader] Failed to load asset: " .. tostring(model))
    return
end

-- Install everything into StarterGui
for _, child in ipairs(model:GetChildren()) do
    child.Parent = StarterGui
    print("[Loader] Installed: " .. child.Name)
end
model:Destroy()

-- Give to players already in game
local function giveToPlayer(player)
    task.wait(0.5)
    for _, item in ipairs(StarterGui:GetChildren()) do
        local existing = player.PlayerGui:FindFirstChild(item.Name)
        if existing then existing:Destroy() end
        item:Clone().Parent = player:WaitForChild("PlayerGui")
    end
    print("[Loader] Given to: " .. player.Name)
end

for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(giveToPlayer, player)
end

Players.PlayerAdded:Connect(function(player)
    task.spawn(giveToPlayer, player)
end)

print("[Loader] Done.")
