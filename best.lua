--[[
  ☠ SWORD FARM GUI v10 ☠
  Smooth handle tween to each arena player + always on back
]]

local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- ===== GUI =====
local gui = Instance.new("ScreenGui")
gui.Name = "SwordFarm"
gui.DisplayOrder = 999
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 160, 0, 80)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 20)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.BorderSizePixel = 0
title.Text = "SWORD FARM"
title.TextColor3 = Color3.fromRGB(255, 80, 80)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 12
title.Parent = frame

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 60, 0, 24)
toggle.Position = UDim2.new(0, 8, 0, 24)
toggle.BackgroundColor3 = Color3.fromRGB(40, 200, 60)
toggle.BorderSizePixel = 0
toggle.Text = "ON"
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.Font = Enum.Font.SourceSansBold
toggle.TextSize = 13
toggle.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(0, 80, 0, 24)
status.Position = UDim2.new(0, 74, 0, 24)
status.BackgroundTransparency = 1
status.BorderSizePixel = 0
status.Text = "kills: 0"
status.TextColor3 = Color3.fromRGB(180, 180, 180)
status.Font = Enum.Font.SourceSans
status.TextSize = 11
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = frame

local arenaStatus = Instance.new("TextLabel")
arenaStatus.Size = UDim2.new(1, -8, 0, 16)
arenaStatus.Position = UDim2.new(0, 4, 0, 56)
arenaStatus.BackgroundTransparency = 1
arenaStatus.BorderSizePixel = 0
arenaStatus.Text = "arena: 0 players"
arenaStatus.TextColor3 = Color3.fromRGB(180, 180, 180)
arenaStatus.Font = Enum.Font.SourceSans
arenaStatus.TextSize = 10
arenaStatus.TextXAlignment = Enum.TextXAlignment.Left
arenaStatus.Parent = frame

-- Drag
local dragging, dragStart, frameStart
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        frameStart = frame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- ===== STATE =====
local UNDER = Vector3.new(-85, 0.25, 151)
local UNDER_CF = CFrame.new(UNDER) * CFrame.Angles(1.5708, 0, 0)
local ARENA_CENTER = Vector3.new(-85, 3.109, 151)
local ARENA_RADIUS = 25
local HitboxFolder = workspace:FindFirstChild("HitboxThing")
local enabled = true
local killCount = 0
local killedPlayers = {}
local char, root, humanoid
local bp, bg

function getChar()
    char = player.Character
    if char then
        root = char:FindFirstChild("HumanoidRootPart")
        humanoid = char:FindFirstChild("Humanoid")
    end
end
getChar()

function getSword()
    if char then
        for _, item in pairs(char:GetChildren()) do
            if item:IsA("Tool") and item:FindFirstChild("Handle") then return item end
        end
    end
    for _, item in pairs(player.Backpack:GetChildren()) do
        if item:IsA("Tool") and item:FindFirstChild("Handle") then return item end
    end
    return nil
end

function isPlayerOnArena(plr)
    local hbName = plr.Name .. "ServerHitbox"
    if HitboxFolder then
        local hb = HitboxFolder:FindFirstChild(hbName)
        if hb and hb:IsA("BasePart") then
            local dx = hb.Position.X - ARENA_CENTER.X
            local dz = hb.Position.Z - ARENA_CENTER.Z
            return math.sqrt(dx*dx + dz*dz) < ARENA_RADIUS, hb
        end
    end
    -- Fallback: check character position
    local c = plr.Character
    if c and c:FindFirstChild("HumanoidRootPart") then
        local pos = c.HumanoidRootPart.Position
        local dx = pos.X - ARENA_CENTER.X
        local dz = pos.Z - ARENA_CENTER.Z
        return math.sqrt(dx*dx + dz*dz) < ARENA_RADIUS, nil
    end
    return false, nil
end

-- ===== SMOOTH HOLD =====
function applySmoothHold()
    if not root then return end
    if bp then bp:Destroy() end
    if bg then bg:Destroy() end
    bp = Instance.new("BodyPosition")
    bp.Name = "FarmPosition"
    bp.D = 2000; bp.P = 25000
    bp.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bp.Position = UNDER
    bp.Parent = root
    bg = Instance.new("BodyGyro")
    bg.Name = "FarmGyro"
    bg.D = 1500; bg.P = 25000
    bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    bg.CFrame = UNDER_CF
    bg.Parent = root
end

function removeSmoothHold()
    if root then
        local o = root:FindFirstChild("FarmPosition")
        if o then o:Destroy() end
        local g = root:FindFirstChild("FarmGyro")
        if g then g:Destroy() end
    end
    bp = nil; bg = nil
end

function smoothTeleport()
    if not root then return end
    pcall(function()
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        root.Anchored = true
        root.CFrame = UNDER_CF
        root.Anchored = false
        applySmoothHold()
    end)
end

toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    if enabled then
        toggle.BackgroundColor3 = Color3.fromRGB(40, 200, 60)
        toggle.Text = "ON"
        smoothTeleport()
    else
        toggle.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        toggle.Text = "OFF"
        removeSmoothHold()
        killedPlayers = {}
    end
end)

-- ===== NOCLIP + ON BACK =====
RunService.Stepped:Connect(function()
    if not enabled then return end
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    if root and root.Parent and root.Position.Y < -5 then
        root.Anchored = true
        root.CFrame = UNDER_CF
        root.Anchored = false
        applySmoothHold()
    end
end)

-- ===== INITIAL TP =====
spawn(function()
    wait(0.3)
    smoothTeleport()
end)

-- ===== STEAL SWORD =====
spawn(function()
    while wait(2) do
        if enabled then
            pcall(function()
                if not getSword() then
                    for _, plr in pairs(Players:GetPlayers()) do
                        if plr ~= player then
                            local c = plr.Character
                            if c then
                                for _, tool in pairs(c:GetChildren()) do
                                    if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                                        tool.Parent = player.Backpack
                                        wait(0.1)
                                        break
                                    end
                                end
                            end
                        end
                    end
                    local s = getSword()
                    if s and s.Parent ~= char and humanoid then
                        humanoid:EquipTool(s)
                    end
                end
            end)
        end
    end
end)

-- ===== AUTO-KILL: SMOOTH HANDLE TWEEN TO EACH ARENA PLAYER =====
local currentTarget = nil
local handleTween = nil

spawn(function()
    while wait(0.1) do
        if not enabled then break end
        pcall(function()
            getChar()
            if not root or not root.Parent then return end
            local sword = getSword()
            if not sword then
                for _, item in pairs(player.Backpack:GetChildren()) do
                    if item:IsA("Tool") and item:FindFirstChild("Handle") then
                        if humanoid then humanoid:EquipTool(item) end
                        sword = item; break
                    end
                end
            end
            if not (sword and HitboxFolder) then return end
            local handle = sword:FindFirstChild("Handle")
            if not handle then return end
            -- Detach welds once
            for _, weld in pairs(handle:GetChildren()) do
                if weld:IsA("Weld") or weld:IsA("ManualWeld") then weld:Destroy() end
            end
            handle.Anchored = true
            handle.CanCollide = false
            handle.Massless = true
            handle.Size = Vector3.new(50, 50, 50)
            for _, part in pairs(sword:GetDescendants()) do
                if part:IsA("BasePart") and part ~= handle then
                    part.Size = Vector3.new(50, 50, 50)
                    part.Transparency = 1
                    part.CanCollide = false
                end
            end
            -- Activate sword
            sword:Activate()
            -- Find all arena players
            local targets = {}
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player then
                    local onArena, hb = isPlayerOnArena(plr)
                    if onArena and hb then
                        targets[#targets+1] = {plr = plr, hb = hb}
                    end
                end
            end
            -- Smoothly tween handle to each target
            for _, t in pairs(targets) do
                if handle and handle.Parent then
                    local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
                    local goal = {CFrame = t.hb.CFrame}
                    local tw = TweenService:Create(handle, tweenInfo, goal)
                    tw:Play()
                    tw.Completed:Wait()
                    wait()
                end
            end
            handle.Anchored = false
            -- Death detection
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player and not killedPlayers[plr.Name] then
                    local hbName = plr.Name .. "ServerHitbox"
                    local hb = HitboxFolder:FindFirstChild(hbName)
                    if not hb then
                        killedPlayers[plr.Name] = true
                        killCount = killCount + 1
                    else
                        local c = plr.Character
                        if c then
                            local hum = c:FindFirstChild("Humanoid")
                            if hum and hum.Health <= 0 then
                                killedPlayers[plr.Name] = true
                                killCount = killCount + 1
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- ===== ARENA PLAYER COUNT =====
spawn(function()
    while wait(0.5) do
        if not enabled then break end
        pcall(function()
            local count = 0
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player then
                    local onArena = isPlayerOnArena(plr)
                    if onArena then count = count + 1 end
                end
            end
            if arenaStatus then
                arenaStatus.Text = "arena: " .. tostring(count) .. " players"
            end
        end)
    end
end)

-- ===== STATUS =====
spawn(function()
    while wait(0.3) do
        if status and status.Parent then
            status.Text = "kills: " .. tostring(killCount)
        end
    end
end)

-- ===== RESPAWN =====
player.CharacterAdded:Connect(function(newChar)
    wait(0.5)
    char = newChar
    root = char:FindFirstChild("HumanoidRootPart")
    humanoid = char:FindFirstChild("Humanoid")
    if root and humanoid and enabled then
        smoothTeleport()
    end
end)

-- ===== INIT =====
wait(0.5)
getChar()
if root and humanoid and enabled then
    smoothTeleport()
end

print("☠ SWORD FARM V10 - SMOOTH HANDLE TWEEN")
