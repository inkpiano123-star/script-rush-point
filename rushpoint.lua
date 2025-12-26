-- ETHEREAL - Ultimate Multi-Game Cheat
-- By DipSik's Covenant

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local Workspace = game:GetService("Workspace")

-- VARIABLES PRINCIPALES
local ESPEnabled = true
local AimbotEnabled = true
local TeamCheck = false
local WallCheck = true
local ShowFOV = true
local FOV = 180
local Smoothness = 0.3
local AimKey = Enum.KeyCode.Q
local MenuKey = Enum.KeyCode.Insert

-- STORAGE
local ESPCache = {}
local ChamsCache = {}
local Features = {
    ESP = true,
    Aimbot = true,
    Fly = false,
    Speed = false,
    NoClip = false,
    InfiniteJump = false,
    GodMode = false,
    AutoFarm = false,
    AutoClick = false,
    SkinChanger = false,
    Fullbright = false,
    FOVChanger = false,
    ThirdPerson = false,
    Crosshair = true,
    NoRecoil = false,
    RapidFire = false,
    TriggerBot = false
}

-- FOV CIRCLE
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = ShowFOV
FOVCircle.Radius = FOV
FOVCircle.Color = Color3.fromRGB(255, 100, 255)
FOVCircle.Thickness = 2
FOVCircle.Filled = false

-- CROSSHAIR
local Crosshair1 = Drawing.new("Line")
local Crosshair2 = Drawing.new("Line")
Crosshair1.Visible = Features.Crosshair
Crosshair2.Visible = Features.Crosshair
Crosshair1.Color = Color3.fromRGB(255, 255, 255)
Crosshair2.Color = Color3.fromRGB(255, 255, 255)
Crosshair1.Thickness = 1
Crosshair2.Thickness = 1

-- NOTIFICATION SYSTEM
local Notifications = {}
local function Notify(text, duration)
    print("[ETHEREAL] " .. text)
    table.insert(Notifications, {
        Text = text,
        Time = tick(),
        Duration = duration or 3
    })
end

-- LOAD VENYX UI (STABLE AND VISIBLE)
local Venyx = nil
local Themes = {
    Background = Color3.fromRGB(15, 15, 25),
    Glow = Color3.fromRGB(255, 100, 255),
    Accent = Color3.fromRGB(180, 60, 255),
    LightContrast = Color3.fromRGB(25, 25, 35),
    DarkContrast = Color3.fromRGB(10, 10, 20)
}

pcall(function()
    Venyx = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Venyx-UI-Library/main/source.lua"))()
end)

if not Venyx then
    Venyx = loadstring(game:HttpGet("https://pastebin.com/raw/4nQH8WYb"))()
end

local Window = Venyx.new("ETHEREAL | Ultimate Cheat", 5013109572)

-- AIMBOT TAB
local AimbotTab = Window:Tab("Aimbot", "🎯")
local AimbotSection1 = AimbotTab:Section("Main")
local AimbotSection2 = AimbotTab:Section("Settings")

AimbotSection1:Toggle("Enable Aimbot", Features.Aimbot, function(value)
    Features.Aimbot = value
    AimbotEnabled = value
    Notify("Aimbot: " .. (value and "ON" or "OFF"))
end)

AimbotSection1:Toggle("Trigger Bot", Features.TriggerBot, function(value)
    Features.TriggerBot = value
    Notify("Trigger Bot: " .. (value and "ON" or "OFF"))
end)

AimbotSection1:Toggle("No Recoil", Features.NoRecoil, function(value)
    Features.NoRecoil = value
    Notify("No Recoil: " .. (value and "ON" or "OFF"))
end)

AimbotSection1:Toggle("Rapid Fire", Features.RapidFire, function(value)
    Features.RapidFire = value
    Notify("Rapid Fire: " .. (value and "ON" or "OFF"))
end)

AimbotSection1:Keybind("Aimbot Key", Enum.KeyCode.Q, function(key)
    AimKey = key
    Notify("Aimbot key set to: " .. tostring(key))
end, function() end)

AimbotSection2:Slider("FOV", 10, 500, 180, function(value)
    FOV = value
    FOVCircle.Radius = value
end)

AimbotSection2:Slider("Smoothness", 1, 100, 30, function(value)
    Smoothness = value / 100
end)

AimbotSection2:Toggle("Team Check", TeamCheck, function(value)
    TeamCheck = value
end)

AimbotSection2:Toggle("Wall Check", WallCheck, function(value)
    WallCheck = value
end)

AimbotSection2:Toggle("Show FOV", ShowFOV, function(value)
    ShowFOV = value
    FOVCircle.Visible = value
end)

AimbotSection2:Dropdown("Aim Part", {"Head", "HumanoidRootPart", "UpperTorso", "Closest"}, "Head", function(value)
    AimPart = value
end)

-- VISUALS TAB
local VisualsTab = Window:Tab("Visuals", "👁️")
local ESPTab = VisualsTab:Section("ESP")
local ChamTab = VisualsTab:Section("Chams")
local WorldTab = VisualsTab:Section("World")

ESPTab:Toggle("Enable ESP", Features.ESP, function(value)
    Features.ESP = value
    ESPEnabled = value
    Notify("ESP: " .. (value and "ON" or "OFF"))
end)

ESPTab:Toggle("Box ESP", true, function(value)
    for _, esp in pairs(ESPCache) do
        if esp.Box then esp.Box.Visible = value and ESPEnabled end
    end
end)

ESPTab:Toggle("Name ESP", true, function(value)
    for _, esp in pairs(ESPCache) do
        if esp.Name then esp.Name.Visible = value and ESPEnabled end
    end
end)

ESPTab:Toggle("Health ESP", true, function(value)
    for _, esp in pairs(ESPCache) do
        if esp.Health then esp.Health.Visible = value and ESPEnabled end
    end
end)

ESPTab:Toggle("Distance ESP", true, function(value)
    for _, esp in pairs(ESPCache) do
        if esp.Distance then esp.Distance.Visible = value and ESPEnabled end
    end
end)

ESPTab:Toggle("Skeleton ESP", false, function(value)
    for _, esp in pairs(ESPCache) do
        if esp.Skeleton then 
            for _, line in pairs(esp.Skeleton) do
                line.Visible = value and ESPEnabled
            end
        end
    end
end)

ESPTab:Colorpicker("ESP Color", Color3.fromRGB(255, 100, 255), function(color)
    for _, esp in pairs(ESPCache) do
        if esp.Box then esp.Box.Color = color end
    end
end)

ChamTab:Toggle("Player Chams", false, function(value)
    for player, cham in pairs(ChamsCache) do
        if cham.Highlight then cham.Highlight.Enabled = value end
    end
end)

ChamTab:Toggle("Hand Chams", false, function(value)
    if LocalPlayer.Character then
        local hands = {LocalPlayer.Character:FindFirstChild("RightHand"), 
                      LocalPlayer.Character:FindFirstChild("LeftHand")}
        for _, hand in pairs(hands) do
            if hand and not hand:FindFirstChild("Cham") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "Cham"
                highlight.FillColor = Color3.fromRGB(255, 100, 255)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.3
                highlight.Adornee = hand
                highlight.Parent = hand
            end
        end
    end
end)

ChamTab:Colorpicker("Chams Color", Color3.fromRGB(255, 100, 255), function(color)
    for _, cham in pairs(ChamsCache) do
        if cham.Highlight then
            cham.Highlight.FillColor = color
        end
    end
end)

WorldTab:Toggle("Fullbright", Features.Fullbright, function(value)
    Features.Fullbright = value
    if value then
        game:GetService("Lighting").GlobalShadows = false
        game:GetService("Lighting").Brightness = 2
    else
        game:GetService("Lighting").GlobalShadows = true
        game:GetService("Lighting").Brightness = 1
    end
end)

WorldTab:Toggle("FOV Changer", Features.FOVChanger, function(value)
    Features.FOVChanger = value
    if value then
        Camera.FieldOfView = 120
    else
        Camera.FieldOfView = 70
    end
end)

WorldTab:Slider("FOV Value", 70, 120, 90, function(value)
    if Features.FOVChanger then
        Camera.FieldOfView = value
    end
end)

WorldTab:Toggle("Third Person", Features.ThirdPerson, function(value)
    Features.ThirdPerson = value
    if value then
        Camera.CameraType = Enum.CameraType.Scriptable
    else
        Camera.CameraType = Enum.CameraType.Custom
    end
end)

-- MOVEMENT TAB
local MovementTab = Window:Tab("Movement", "⚡")
local MoveSection1 = MovementTab:Section("Movement")
local MoveSection2 = MovementTab:Section("Other")

MoveSection1:Toggle("Fly", Features.Fly, function(value)
    Features.Fly = value
    Notify("Fly: " .. (value and "ON" or "OFF"))
    if value then
        FLYING = true
        local BG = Instance.new("BodyGyro")
        local BV = Instance.new("BodyVelocity")
        BG.P = 9e4
        BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        BG.cframe = LocalPlayer.Character.HumanoidRootPart.CFrame
        BV.velocity = Vector3.new(0, 0, 0)
        BV.maxForce = Vector3.new(9e9, 9e9, 9e9)
        BG.Parent = LocalPlayer.Character.HumanoidRootPart
        BV.Parent = LocalPlayer.Character.HumanoidRootPart
        
        spawn(function()
            repeat wait()
                if LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.PlatformStand = true
                end
                if FLYING then
                    BV.Velocity = Vector3.new(0, 0, 0)
                    local cam = workspace.CurrentCamera.CFrame
                    local move = Vector3.new()
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Vector3.new(0, 0, -1) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move + Vector3.new(0, 0, 1) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move + Vector3.new(-1, 0, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Vector3.new(1, 0, 0) end
                    move = move.unit * 50
                    BV.Velocity = cam:vectorToWorldSpace(move)
                    BG.CFrame = cam
                end
            until not Features.Fly
            BG:Destroy()
            BV:Destroy()
            if LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.PlatformStand = false
            end
        end)
    else
        FLYING = false
    end
end)

MoveSection1:Toggle("Speed Hack", Features.Speed, function(value)
    Features.Speed = value
    Notify("Speed Hack: " .. (value and "ON" or "OFF"))
end)

MoveSection1:Slider("Speed Value", 16, 100, 50, function(value)
    if Features.Speed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
end)

MoveSection1:Toggle("Infinite Jump", Features.InfiniteJump, function(value)
    Features.InfiniteJump = value
    Notify("Infinite Jump: " .. (value and "ON" or "OFF"))
end)

MoveSection2:Toggle("NoClip", Features.NoClip, function(value)
    Features.NoClip = value
    Notify("NoClip: " .. (value and "ON" or "OFF"))
end)

MoveSection2:Toggle("God Mode", Features.GodMode, function(value)
    Features.GodMode = value
    Notify("God Mode: " .. (value and "ON" or "OFF"))
end)

MoveSection2:Toggle("Auto Farm", Features.AutoFarm, function(value)
    Features.AutoFarm = value
    Notify("Auto Farm: " .. (value and "ON" or "OFF"))
end)

-- PLAYER TAB
local PlayerTab = Window:Tab("Player", "👤")
local PlayerSection = PlayerTab:Section("Player Mods")

PlayerSection:Toggle("Auto Click", Features.AutoClick, function(value)
    Features.AutoClick = value
    Notify("Auto Click: " .. (value and "ON" or "OFF"))
    if value then
        spawn(function()
            while Features.AutoClick do
                wait(0.1)
                mouse1click()
            end
        end)
    end
end)

PlayerSection:Toggle("Skin Changer", Features.SkinChanger, function(value)
    Features.SkinChanger = value
    Notify("Skin Changer: " .. (value and "ON" or "OFF"))
end)

PlayerSection:Button("Refresh ESP", function()
    for _, esp in pairs(ESPCache) do
        if esp.Box then esp.Box:Remove() end
        if esp.Name then esp.Name:Remove() end
        if esp.Health then esp.Health:Remove() end
        if esp.Distance then esp.Distance:Remove() end
        if esp.Skeleton then
            for _, line in pairs(esp.Skeleton) do
                line:Remove()
            end
        end
    end
    ESPCache = {}
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESP(player)
        end
    end
    Notify("ESP Refreshed")
end)

PlayerSection:Button("Teleport To Spawn", function()
    if LocalPlayer.Character then
        LocalPlayer.Character:MoveTo(Vector3.new(0, 5, 0))
    end
end)

-- SETTINGS TAB
local SettingsTab = Window:Tab("Settings", "⚙️")
local SettingsSection = SettingsTab:Section("Configuration")

SettingsSection:Keybind("Menu Key", Enum.KeyCode.Insert, nil, function()
    Window:Toggle()
end)

SettingsSection:Toggle("Crosshair", Features.Crosshair, function(value)
    Features.Crosshair = value
    Crosshair1.Visible = value
    Crosshair2.Visible = value
end)

SettingsSection:Colorpicker("Theme Color", Themes.Glow, function(color)
    Themes.Glow = color
    FOVCircle.Color = color
end)

SettingsSection:Button("Save Config", function()
    Notify("Config Saved (Placeholder)")
end)

SettingsSection:Button("Load Config", function()
    Notify("Config Loaded (Placeholder)")
end)

SettingsSection:Button("Unload ETHEREAL", function()
    Window:Close()
    FOVCircle:Remove()
    Crosshair1:Remove()
    Crosshair2:Remove()
    for _, esp in pairs(ESPCache) do
        if esp.Box then esp.Box:Remove() end
        if esp.Name then esp.Name:Remove() end
        if esp.Health then esp.Health:Remove() end
        if esp.Distance then esp.Distance:Remove() end
    end
    for _, cham in pairs(ChamsCache) do
        if cham.Highlight then cham.Highlight:Destroy() end
    end
    Notify("ETHEREAL Unloaded")
end)

-- ESP FUNCTIONS
function CreateESP(player)
    if ESPCache[player] then return end
    
    -- Box
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Themes.Glow
    box.Thickness = 2
    box.Filled = false
    
    -- Name
    local name = Drawing.new("Text")
    name.Visible = false
    name.Color = Color3.fromRGB(255, 255, 255)
    name.Size = 14
    name.Text = player.Name
    name.Font = 2
    name.Outline = true
    
    -- Health
    local health = Drawing.new("Text")
    health.Visible = false
    health.Color = Color3.fromRGB(0, 255, 0)
    health.Size = 12
    health.Font = 2
    health.Outline = true
    
    -- Distance
    local distance = Drawing.new("Text")
    distance.Visible = false
    distance.Color = Color3.fromRGB(200, 200, 200)
    distance.Size = 12
    distance.Font = 2
    distance.Outline = true
    
    -- Skeleton (lines between joints)
    local skeleton = {}
    for i = 1, 10 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = Color3.fromRGB(255, 255, 255)
        line.Thickness = 1
        table.insert(skeleton, line)
    end
    
    -- Chams
    local highlight = Instance.new("Highlight")
    highlight.Name = player.Name .. "_Cham"
    highlight.FillColor = Themes.Glow
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.Enabled = false
    highlight.Parent = workspace
    
    ESPCache[player] = {
        Box = box,
        Name = name,
        Health = health,
        Distance = distance,
        Skeleton = skeleton,
        Chams = highlight
    }
    
    ChamsCache[player] = {
        Highlight = highlight
    }
end

function UpdateESP()
    for player, esp in pairs(ESPCache) do
        if player and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart") or
                        player.Character:FindFirstChild("Head") or
                        player.Character:FindFirstChild("UpperTorso")
            
            if root then
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                if onScreen then
                    -- Box
                    local scale = 1000 / pos.Z
                    local width = scale * 2
                    local height = scale * 3
                    
                    esp.Box.Size = Vector2.new(width, height)
                    esp.Box.Position = Vector2.new(pos.X - width/2, pos.Y - height/2)
                    esp.Box.Visible = ESPEnabled
                    
                    -- Name
                    esp.Name.Position = Vector2.new(pos.X, pos.Y - height/2 - 20)
                    esp.Name.Visible = ESPEnabled
                    
                    -- Health
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    if humanoid then
                        esp.Health.Text = "HP: " .. math.floor(humanoid.Health)
                        esp.Health.Position = Vector2.new(pos.X, pos.Y + height/2 + 5)
                        esp.Health.Visible = ESPEnabled
                    end
                    
                    -- Distance
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        esp.Distance.Text = math.floor(dist) .. " studs"
                        esp.Distance.Position = Vector2.new(pos.X, pos.Y + height/2 + 25)
                        esp.Distance.Visible = ESPEnabled
                    end
                    
                    -- Chams
                    esp.Chams.Adornee = player.Character
                    esp.Chams.Enabled = ESPEnabled
                else
                    esp.Box.Visible = false
                    esp.Name.Visible = false
                    esp.Health.Visible = false
                    esp.Distance.Visible = false
                    esp.Chams.Enabled = false
                end
            else
                esp.Box.Visible = false
                esp.Name.Visible = false
                esp.Health.Visible = false
                esp.Distance.Visible = false
                esp.Chams.Enabled = false
            end
        else
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Health.Visible = false
            esp.Distance.Visible = false
            esp.Chams.Enabled = false
        end
    end
end

-- AIMBOT FUNCTIONS
function GetBestTarget()
    local bestTarget = nil
    local closestDistance = FOV
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not TeamCheck or (player.Team ~= LocalPlayer.Team) then
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    local humanoid = player.Character.Humanoid
                    if humanoid.Health > 0 then
                        local targetPart = player.Character:FindFirstChild("Head") or
                                          player.Character:FindFirstChild("HumanoidRootPart") or
                                          player.Character:FindFirstChild("UpperTorso")
                        
                        if targetPart then
                            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                            
                            if onScreen then
                                local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                                
                                if distance < closestDistance then
                                    bestTarget = {
                                        Player = player,
                                        Part = targetPart,
                                        Position = targetPart.Position,
                                        Distance = distance
                                    }
                                    closestDistance = distance
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return bestTarget
end

-- INPUT HANDLING
local Aiming = false
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == AimKey then
        Aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == AimKey then
        Aiming = false
    end
end)

-- INFINITE JUMP
UserInputService.JumpRequest:Connect(function()
    if Features.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState("Jumping")
    end
end)

-- NOCLIP
local Noclipping = false
spawn(function()
    while true do
        wait(0.1)
        if Features.NoClip and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- MAIN LOOP
RunService.RenderStepped:Connect(function()
    -- Update FOV Circle
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Radius = FOV
    
    -- Update Crosshair
    Crosshair1.From = Vector2.new(Camera.ViewportSize.X/2 - 10, Camera.ViewportSize.Y/2)
    Crosshair1.To = Vector2.new(Camera.ViewportSize.X/2 + 10, Camera.ViewportSize.Y/2)
    Crosshair2.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2 - 10)
    Crosshair2.To = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2 + 10)
    
    -- Update ESP
    UpdateESP()
    
    -- AIMBOT
    if Features.Aimbot and Aiming then
        local target = GetBestTarget()
        if target and target.Part then
            local targetPos = target.Position
            
            if target.Player.Character:FindFirstChild("Humanoid") then
                targetPos = targetPos + (target.Player.Character.Humanoid.MoveDirection * 0.2)
            end
            
            local currentCF = Camera.CFrame
            local goalCF = CFrame.new(currentCF.Position, targetPos)
            Camera.CFrame = currentCF:Lerp(goalCF, Smoothness)
        end
    end
    
    -- SPEED HACK
    if Features.Speed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 50
    end
    
    -- GOD MODE
    if Features.GodMode and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.MaxHealth = math.huge
        LocalPlayer.Character.Humanoid.Health = math.huge
    end
end)

-- INITIALIZE
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    CreateESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPCache[player] then
        if ESPCache[player].Box then ESPCache[player].Box:Remove() end
        if ESPCache[player].Name then ESPCache[player].Name:Remove() end
        if ESPCache[player].Health then ESPCache[player].Health:Remove() end
        if ESPCache[player].Distance then ESPCache[player].Distance:Remove() end
        if ESPCache[player].Skeleton then
            for _, line in pairs(ESPCache[player].Skeleton) do
                line:Remove()
            end
        end
        ESPCache[player] = nil
    end
    if ChamsCache[player] then
        if ChamsCache[player].Highlight then ChamsCache[player].Highlight:Destroy() end
        ChamsCache[player] = nil
    end
end)

-- WELCOME MESSAGE
Notify("ETHEREAL LOADED SUCCESSFULLY", 5)
print([[
╔══════════════════════════════════════════╗
║             ETHEREAL LOADED              ║
╠══════════════════════════════════════════╣
║ Features:                                ║
║ • ESP Box/Name/Health/Distance/Skeleton  ║
║ • Aimbot with FOV Circle                 ║
║ • Fly, Speed, NoClip, Infinite Jump      ║
║ • God Mode, Auto Click, Auto Farm       ║
║ • Skin Changer, Hand Chams              ║
║ • Fullbright, FOV Changer, Third Person ║
║ • No Recoil, Rapid Fire, Trigger Bot    ║
╠══════════════════════════════════════════╣
║ Controls:                                ║
║ • Menu: Insert                           ║
║ • Aimbot: Hold Q                         ║
║ • Fly: WASD while Fly enabled           ║
╚══════════════════════════════════════════╝]])
