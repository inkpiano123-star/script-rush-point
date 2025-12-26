-- NEXUS X - Rush Point Bypass Edition
-- Force brute pour faire fonctionner ESP + Aimbot

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local Workspace = game:GetService("Workspace")

-- FORÇAGE DES VARIABLES
local ESPEnabled = true
local AimbotEnabled = true
local TeamCheck = false -- Désactivé car Rush Point bloque souvent Team
local WallCheck = false -- Désactivé pour la fiabilité
local ShowFOV = true
local FOV = 200
local Smoothness = 0.35
local AimKey = Enum.KeyCode.LeftAlt -- Touche alternative qui passe souvent
local MenuKey = Enum.KeyCode.RightControl

-- FOV FORCÉ
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Radius = FOV
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

-- MÉTHODE ESP ALTERNATIVE (BillboardGui au lieu de Drawing)
local ESPCache = {}
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "NexusESP"
ESPFolder.Parent = workspace

-- GUI LINORIA (ancien GUI comme tu voulais)
local success, Library = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
end)

if not success then
    -- Fallback si Linoria échoue
    Library = loadstring(game:HttpGet("https://pastebin.com/raw/vq8kU3p2"))()
end

local Window = Library:CreateWindow("NEXUS X | Rush Point")
local Tabs = {
    Main = Window:AddTab("Main"),
    Visuals = Window:AddTab("Visuals"),
    Settings = Window:AddTab("Settings")
}

-- MAIN TAB
local AimbotSection = Tabs.Main:AddLeftGroupbox("Aimbot")

AimbotSection:AddToggle('AimbotToggle', {
    Text = 'Enable Aimbot',
    Default = true,
    Callback = function(value)
        AimbotEnabled = value
    end
})

AimbotSection:AddSlider('FOVSlider', {
    Text = 'FOV Size',
    Default = 200,
    Min = 50,
    Max = 500,
    Rounding = 0,
    Callback = function(value)
        FOV = value
    end
})

AimbotSection:AddSlider('SmoothSlider', {
    Text = 'Smoothness',
    Default = 35,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Callback = function(value)
        Smoothness = value / 100
    end
})

AimbotSection:AddDropdown('AimPartDropdown', {
    Text = 'Aim Priority',
    Default = 'Closest',
    Values = {'Closest', 'Head', 'Torso', 'Random'},
    Callback = function(value)
        AimPriority = value
    end
})

AimbotSection:AddKeybind('AimbotKeybind', {
    Text = 'Aimbot Key',
    Default = Enum.KeyCode.LeftAlt,
    Callback = function(key)
        AimKey = key
    end
})

-- VISUALS TAB
local VisualsSection = Tabs.Visuals:AddLeftGroupbox("ESP")

VisualsSection:AddToggle('ESPToggle', {
    Text = 'Enable ESP',
    Default = true,
    Callback = function(value)
        ESPEnabled = value
        if not value then
            -- Cache tous les ESP
            for _, esp in pairs(ESPCache) do
                if esp.Billboard then
                    esp.Billboard.Enabled = false
                end
                if esp.DrawingBox then
                    esp.DrawingBox.Visible = false
                end
            end
        end
    end
})

VisualsSection:AddToggle('BoxESToggle', {
    Text = 'Box ESP',
    Default = true,
    Callback = function(value)
        for _, esp in pairs(ESPCache) do
            if esp.DrawingBox then
                esp.DrawingBox.Visible = value and ESPEnabled
            end
        end
    end
})

VisualsSection:AddToggle('NameESToggle', {
    Text = 'Show Names',
    Default = true,
    Callback = function(value)
        for _, esp in pairs(ESPCache) do
            if esp.Billboard then
                esp.Billboard.Enabled = value and ESPEnabled
            end
        end
    end
})

VisualsSection:AddToggle('HealthESToggle', {
    Text = 'Show Health',
    Default = true,
    Callback = function(value)
        for _, esp in pairs(ESPCache) do
            if esp.HealthLabel then
                esp.HealthLabel.Visible = value and ESPEnabled
            end
        end
    end
})

VisualsSection:AddColorpicker('ESPColor', {
    Text = 'ESP Color',
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(value)
        for _, esp in pairs(ESPCache) do
            if esp.DrawingBox then
                esp.DrawingBox.Color = value
            end
            if esp.Billboard then
                esp.Billboard.Frame.BackgroundColor3 = value
            end
        end
    end
})

-- SETTINGS TAB
local SettingsSection = Tabs.Settings:AddLeftGroupbox("Configuration")

SettingsSection:AddToggle('TeamCheckToggle', {
    Text = 'Team Check (May break ESP)',
    Default = false,
    Callback = function(value)
        TeamCheck = value
    end
})

SettingsSection:AddToggle('WallCheckToggle', {
    Text = 'Wall Check',
    Default = false,
    Callback = function(value)
        WallCheck = value
    end
})

SettingsSection:AddToggle('ShowFOVToggle', {
    Text = 'Show FOV Circle',
    Default = true,
    Callback = function(value)
        ShowFOV = value
        FOVCircle.Visible = value
    end
})

SettingsSection:AddButton('Refresh ESP', function()
    -- Force refresh ESP
    for _, esp in pairs(ESPCache) do
        if esp.Billboard then esp.Billboard:Destroy() end
        if esp.DrawingBox then esp.DrawingBox:Remove() end
        if esp.HealthLabel then esp.HealthLabel:Remove() end
    end
    ESPCache = {}
    
    -- Recréer ESP pour tous les joueurs
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESP(player)
        end
    end
end)

SettingsSection:AddButton('Force Aimbot Test', function()
    -- Test l'aimbot immédiatement
    local target = FindBestTarget()
    if target then
        Library:Notify("Aimbot working! Target: " .. target.Player.Name, 3)
    else
        Library:Notify("No target found in FOV", 3)
    end
end)

SettingsSection:AddLabel("Menu Key: RightControl")
SettingsSection:AddLabel("Aimbot Key: LeftAlt (Hold)")

-- SET WINDOW KEYBIND
Library:SetWindowKeybind(MenuKey)

-- MÉTHODE ESP AGGRESSIVE (double système)
function CreateESP(player)
    if ESPCache[player] then return end
    
    -- MÉTHODE 1: BillboardGui (plus stable pour Rush Point)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = player.Name .. "_ESP"
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = false
    billboard.Adornee = nil
    billboard.Parent = ESPFolder
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    frame.BackgroundTransparency = 0.6
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    frame.Parent = billboard
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = billboard
    
    -- MÉTHODE 2: Drawing (backup)
    local drawingBox = Drawing.new("Square")
    drawingBox.Visible = false
    drawingBox.Color = Color3.fromRGB(255, 0, 0)
    drawingBox.Thickness = 2
    drawingBox.Filled = false
    
    local healthLabel = Drawing.new("Text")
    healthLabel.Visible = false
    healthLabel.Color = Color3.fromRGB(0, 255, 0)
    healthLabel.Size = 12
    healthLabel.Font = 2
    healthLabel.Outline = true
    
    ESPCache[player] = {
        Billboard = billboard,
        DrawingBox = drawingBox,
        HealthLabel = healthLabel,
        Player = player
    }
end

function UpdateESP()
    for player, esp in pairs(ESPCache) do
        if player and player.Character then
            -- Trouver n'importe quelle partie pour la position
            local root = player.Character:FindFirstChild("HumanoidRootPart") or
                        player.Character:FindFirstChild("Head") or
                        player.Character:FindFirstChild("UpperTorso")
            
            if not root then
                -- Scan agressif pour trouver une partie
                for _, child in ipairs(player.Character:GetChildren()) do
                    if child:IsA("BasePart") then
                        root = child
                        break
                    end
                end
            end
            
            if root then
                -- Billboard ESP
                if esp.Billboard then
                    esp.Billboard.Adornee = root
                    esp.Billboard.Enabled = ESPEnabled
                    
                    -- Mettre à jour la santé
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    if humanoid then
                        esp.HealthLabel.Text = "HP: " .. math.floor(humanoid.Health)
                        local healthPercent = humanoid.Health / humanoid.MaxHealth
                        if healthPercent > 0.6 then
                            esp.HealthLabel.Color = Color3.fromRGB(0, 255, 0)
                        elseif healthPercent > 0.3 then
                            esp.HealthLabel.Color = Color3.fromRGB(255, 255, 0)
                        else
                            esp.HealthLabel.Color = Color3.fromRGB(255, 0, 0)
                        end
                    end
                end
                
                -- Drawing ESP (backup)
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    if esp.DrawingBox then
                        local scale = 1000 / pos.Z
                        esp.DrawingBox.Size = Vector2.new(scale * 2, scale * 3)
                        esp.DrawingBox.Position = Vector2.new(pos.X - scale, pos.Y - scale * 1.5)
                        esp.DrawingBox.Visible = ESPEnabled
                    end
                    
                    if esp.HealthLabel then
                        esp.HealthLabel.Position = Vector2.new(pos.X, pos.Y + 50)
                        esp.HealthLabel.Visible = ESPEnabled
                    end
                else
                    if esp.DrawingBox then esp.DrawingBox.Visible = false end
                    if esp.HealthLabel then esp.HealthLabel.Visible = false end
                end
            else
                if esp.Billboard then esp.Billboard.Enabled = false end
                if esp.DrawingBox then esp.DrawingBox.Visible = false end
                if esp.HealthLabel then esp.HealthLabel.Visible = false end
            end
        else
            if esp.Billboard then esp.Billboard.Enabled = false end
            if esp.DrawingBox then esp.DrawingBox.Visible = false end
            if esp.HealthLabel then esp.HealthLabel.Visible = false end
        end
    end
end

-- AIMBOT AGGRESSIF (force la détection)
function FindBestTarget()
    local bestTarget = nil
    local closestDistance = FOV
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            -- Skip team check si désactivé ou si problème
            if not TeamCheck or (player.Team ~= LocalPlayer.Team) then
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    local humanoid = player.Character.Humanoid
                    if humanoid.Health > 0 then
                        -- FORCE la recherche de parties
                        local partsToCheck = {}
                        
                        -- Priorité 1: Parties normales
                        local normalParts = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}
                        for _, partName in ipairs(normalParts) do
                            local part = player.Character:FindFirstChild(partName)
                            if part then
                                table.insert(partsToCheck, {Part = part, Priority = 3})
                            end
                        end
                        
                        -- Priorité 2: Membres
                        local limbParts = {"LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg"}
                        for _, partName in ipairs(limbParts) do
                            local part = player.Character:FindFirstChild(partName)
                            if part then
                                table.insert(partsToCheck, {Part = part, Priority = 2})
                            end
                        end
                        
                        -- Priorité 3: N'importe quelle BasePart
                        if #partsToCheck == 0 then
                            for _, child in ipairs(player.Character:GetChildren()) do
                                if child:IsA("BasePart") then
                                    table.insert(partsToCheck, {Part = child, Priority = 1})
                                    break
                                end
                            end
                        end
                        
                        -- Vérifier chaque partie
                        for _, partData in ipairs(partsToCheck) do
                            local part = partData.Part
                            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                            
                            if onScreen then
                                local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                                
                                if distance < closestDistance then
                                    -- Wall check optionnel
                                    if WallCheck then
                                        local origin = Camera.CFrame.Position
                                        local target = part.Position
                                        local direction = (target - origin).Unit
                                        local ray = Ray.new(origin, direction * 500)
                                        local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera, ESPFolder})
                                        
                                        if hit and hit:IsDescendantOf(player.Character) then
                                            bestTarget = {
                                                Player = player,
                                                Part = part,
                                                Position = part.Position,
                                                Distance = distance,
                                                Priority = partData.Priority
                                            }
                                            closestDistance = distance
                                        end
                                    else
                                        bestTarget = {
                                            Player = player,
                                            Part = part,
                                            Position = part.Position,
                                            Distance = distance,
                                            Priority = partData.Priority
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
    end
    
    return bestTarget
end

-- GESTION DES INPUTS
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

-- BOUCLE PRINCIPALE ULTRA-AGGRESSIVE
RunService.RenderStepped:Connect(function()
    -- Force FOV update
    FOVCircle.Radius = FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    -- Force ESP update
    UpdateESP()
    
    -- FORCE AIMBOT
    if AimbotEnabled and Aiming then
        local target = FindBestTarget()
        
        if target and target.Part then
            -- Position cible avec prédiction
            local targetPos = target.Position
            
            -- Ajouter de la prédiction de mouvement
            if target.Player.Character:FindFirstChild("Humanoid") then
                local humanoid = target.Player.Character.Humanoid
                targetPos = targetPos + (humanoid.MoveDirection * 0.2)
            end
            
            -- Calcul du smoothing FORCÉ
            local currentCF = Camera.CFrame
            local goalCF = CFrame.new(currentCF.Position, targetPos)
            
            -- Appliquer le smoothing agressif
            Camera.CFrame = currentCF:Lerp(goalCF, Smoothness)
            
            -- Debug visuel
            if target.Player.Character:FindFirstChild("Head") then
                local head = target.Player.Character.Head
                local pos = Camera:WorldToViewportPoint(head.Position)
                
                -- Créer un point de cible visuel
                if not ESPCache[target.Player].TargetDot then
                    local dot = Drawing.new("Circle")
                    dot.Visible = true
                    dot.Radius = 5
                    dot.Color = Color3.fromRGB(0, 255, 0)
                    dot.Thickness = 3
                    dot.Filled = true
                    ESPCache[target.Player].TargetDot = dot
                end
                
                ESPCache[target.Player].TargetDot.Position = Vector2.new(pos.X, pos.Y)
            end
        else
            -- Nettoyer les points de cible
            for _, esp in pairs(ESPCache) do
                if esp.TargetDot then
                    esp.TargetDot.Visible = false
                end
            end
        end
    else
        -- Nettoyer les points de cible quand pas d'aimbot
        for _, esp in pairs(ESPCache) do
            if esp.TargetDot then
                esp.TargetDot.Visible = false
            end
        end
    end
end)

-- INITIALISATION FORCÉE
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    wait(0.5) -- Attendre que le character charge
    CreateESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPCache[player] then
        if ESPCache[player].Billboard then ESPCache[player].Billboard:Destroy() end
        if ESPCache[player].DrawingBox then ESPCache[player].DrawingBox:Remove() end
        if ESPCache[player].HealthLabel then ESPCache[player].HealthLabel:Remove() end
        if ESPCache[player].TargetDot then ESPCache[player].TargetDot:Remove() end
        ESPCache[player] = nil
    end
end)

-- MESSAGE DE DÉMARRAGE AGGRESSIF
Library:Notify("NEXUS X LOADED - Rush Point Bypass Active", 5)

print("╔══════════════════════════════════════╗")
print("║      NEXUS X - RUSH POINT BYPASS     ║")
print("╠══════════════════════════════════════╣")
print("║ ESP: DOUBLE SYSTEM (Forced)          ║")
print("║ • BillboardGui + Drawing Backup      ║")
print("║ • Names + Health + Box               ║")
print("╠══════════════════════════════════════╣")
print("║ AIMBOT: AGGRESSIVE SCAN              ║")
print("║ • Scans ALL body parts               ║")
print("║ • Priority system                    ║")
print("║ • Visual target indicator            ║")
print("╠══════════════════════════════════════╣")
print("║ CONTROLS:                            ║")
print("║ • Menu: Right Control                ║")
print("║ • Aimbot: Hold Left Alt              ║")
print("║ • Change keys in menu                ║")
print("╚══════════════════════════════════════╝")

-- TEST AUTOMATIQUE APRÈS 3 SECONDES
wait(3)
local targetCount = 0
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        targetCount = targetCount + 1
    end
end
print("[TEST] Players found:", targetCount)
print("[TEST] ESP Created:", #ESPCache)
print("[TEST] Aimbot ready:", AimbotEnabled)

if targetCount > 0 then
    Library:Notify("Found " .. targetCount .. " potential targets", 3)
end
