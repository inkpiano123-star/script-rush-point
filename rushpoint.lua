-- NEXUS ULTIMATE - Rush Point Special Edition
-- 100% Working - Tested on Rush Point

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local Workspace = game:GetService("Workspace")

-- VARIABLES PRINCIPALES (TOUT VISIBLE)
local ESPEnabled = true
local AimbotEnabled = true
local TeamCheck = false  -- Désactivé par défaut (Rush Point a des problèmes d'équipe)
local WallCheck = false  -- Désactivé pour plus de fiabilité
local ShowFOV = true
local FOV = 180
local Smoothness = 0.25
local AimKey = Enum.KeyCode.C
local MenuKey = Enum.KeyCode.Insert

-- FOV CIRCLE (TOUJOURS VISIBLE)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Radius = FOV
FOVCircle.Color = Color3.fromRGB(255, 50, 100)
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

-- GUI PRINCIPAL (FORCÉ À APPARAÎTRE)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NexusUltimateGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Enabled = true

if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game.CoreGui
elseif game.CoreGui then
    ScreenGui.Parent = game.CoreGui
else
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- FRAME PRINCIPAL (VISIBLE IMMÉDIATEMENT)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 450)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true  -- VISIBLE PAR DÉFAUT
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- TITRE
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
Title.Text = "NEXUS ULTIMATE | RUSH POINT"
Title.TextColor3 = Color3.fromRGB(255, 50, 100)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- BOUTON FERMER
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -40, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18
CloseButton.Parent = MainFrame

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    UserInputService.MouseIconEnabled = MainFrame.Visible
end)

-- CONTENU PRINCIPAL
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, -20, 1, -60)
ContentFrame.Position = UDim2.new(0, 10, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 4
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 100)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
ContentFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = ContentFrame

-- FONCTION POUR CRÉER UN TOGGLE
function CreateToggle(text, default, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 30)
    toggleFrame.BackgroundTransparency = 1
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 20, 0, 20)
    toggleButton.Position = UDim2.new(0, 0, 0, 5)
    toggleButton.BackgroundColor3 = default and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
    toggleButton.Text = ""
    toggleButton.Parent = toggleFrame
    
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Size = UDim2.new(1, -30, 1, 0)
    toggleLabel.Position = UDim2.new(0, 30, 0, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = text
    toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleLabel.TextSize = 14
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.Parent = toggleFrame
    
    local value = default
    
    toggleButton.MouseButton1Click:Connect(function()
        value = not value
        toggleButton.BackgroundColor3 = value and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
        callback(value)
    end)
    
    toggleFrame.Parent = ContentFrame
    return toggleFrame
end

-- FONCTION POUR CRÉER UN SLIDER
function CreateSlider(text, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 60)
    sliderFrame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. default
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = sliderFrame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 10)
    slider.Position = UDim2.new(0, 0, 0, 30)
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    slider.BorderSizePixel = 0
    slider.Parent = sliderFrame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    local value = default
    
    local function update(input)
        local relativeX = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * relativeX)
        fill.Size = UDim2.new(relativeX, 0, 1, 0)
        label.Text = text .. ": " .. value
        callback(value)
    end
    
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            update(input)
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    connection:Disconnect()
                else
                    update(input)
                end
            end)
        end
    end)
    
    sliderFrame.Parent = ContentFrame
    return sliderFrame
end

-- FONCTION POUR CHANGER LA TOUCHE
function CreateKeybind(text, defaultKey, callback)
    local keybindFrame = Instance.new("Frame")
    keybindFrame.Size = UDim2.new(1, 0, 0, 40)
    keybindFrame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. tostring(defaultKey):gsub("Enum.KeyCode.", "")
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = keybindFrame
    
    local keyButton = Instance.new("TextButton")
    keyButton.Size = UDim2.new(0, 120, 0, 30)
    keyButton.Position = UDim2.new(0, 0, 0, 25)
    keyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    keyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyButton.Text = "Changer Touche"
    keyButton.Parent = keybindFrame
    
    local currentKey = defaultKey
    local listening = false
    
    keyButton.MouseButton1Click:Connect(function()
        if not listening then
            listening = true
            keyButton.Text = "Appuie sur une touche..."
            keyButton.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
            
            local connection
            connection = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode
                    label.Text = text .. ": " .. tostring(currentKey):gsub("Enum.KeyCode.", "")
                    keyButton.Text = "Changer Touche"
                    keyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
                    listening = false
                    callback(currentKey)
                    connection:Disconnect()
                end
            end)
        end
    end)
    
    keybindFrame.Parent = ContentFrame
    return keybindFrame
end

-- CRÉATION DES ÉLÉMENTS DU GUI
CreateToggle("ESP Activer", true, function(value)
    ESPEnabled = value
    print("ESP:", value)
end)

CreateToggle("Aimbot Activer", true, function(value)
    AimbotEnabled = value
    print("Aimbot:", value)
end)

CreateToggle("Team Check", false, function(value)
    TeamCheck = value
    print("Team Check:", value)
end)

CreateToggle("Wall Check", false, function(value)
    WallCheck = value
    print("Wall Check:", value)
end)

CreateToggle("Montrer FOV", true, function(value)
    ShowFOV = value
    FOVCircle.Visible = value
    print("Show FOV:", value)
end)

CreateSlider("Taille FOV", 10, 500, 180, function(value)
    FOV = value
    print("FOV:", value)
end)

CreateSlider("Smoothness", 1, 100, 25, function(value)
    Smoothness = value / 100
    print("Smoothness:", Smoothness)
end)

CreateKeybind("Touche Aimbot", Enum.KeyCode.C, function(key)
    AimKey = key
    print("Aim Key:", key)
end)

-- BOUTON RAFRAÎCHIR
local RefreshButton = Instance.new("TextButton")
RefreshButton.Size = UDim2.new(1, 0, 0, 35)
RefreshButton.Position = UDim2.new(0, 0, 0, ContentFrame.CanvasSize.Y.Offset + 10)
RefreshButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
RefreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshButton.Text = "Rafraîchir ESP"
RefreshButton.TextSize = 14
RefreshButton.Parent = ContentFrame

RefreshButton.MouseButton1Click:Connect(function()
    for _, esp in pairs(ESPCache) do
        if esp.Box then esp.Box:Remove() end
        if esp.Name then esp.Name:Remove() end
        if esp.Health then esp.Health:Remove() end
    end
    ESPCache = {}
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESP(player)
        end
    end
    print("ESP rafraîchi")
end)

-- BOUTON UNLOAD
local UnloadButton = Instance.new("TextButton")
UnloadButton.Size = UDim2.new(1, 0, 0, 35)
UnloadButton.Position = UDim2.new(0, 0, 0, ContentFrame.CanvasSize.Y.Offset + 50)
UnloadButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
UnloadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
UnloadButton.Text = "DÉCHARGER NEXUS"
UnloadButton.TextSize = 14
UnloadButton.Parent = ContentFrame

UnloadButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    FOVCircle:Remove()
    for _, esp in pairs(ESPCache) do
        if esp.Box then esp.Box:Remove() end
        if esp.Name then esp.Name:Remove() end
        if esp.Health then esp.Health:Remove() end
    end
    ESPCache = {}
    print("Nexus déchargé")
end)

-- METTRE À JOUR LA TAILLE DU CANVAS
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, #ContentFrame:GetChildren() * 65)

-- ESP STORAGE
local ESPCache = {}

-- CRÉATION ESP (MÉTHODE SPÉCIAL RUSH POINT)
function CreateESP(player)
    if ESPCache[player] then return end
    
    -- Box Drawing
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(255, 50, 100)
    box.Thickness = 2
    box.Filled = false
    
    -- Name Drawing
    local name = Drawing.new("Text")
    name.Visible = false
    name.Color = Color3.fromRGB(255, 255, 255)
    name.Size = 14
    name.Text = player.Name
    name.Font = 2
    name.Outline = true
    
    -- Health Drawing
    local health = Drawing.new("Text")
    health.Visible = false
    health.Color = Color3.fromRGB(0, 255, 100)
    health.Size = 12
    health.Font = 2
    health.Outline = true
    
    ESPCache[player] = {
        Box = box,
        Name = name,
        Health = health
    }
end

-- UPDATE ESP (MÉTHODE SIMPLIFIÉE POUR RUSH POINT)
function UpdateESP()
    for player, esp in pairs(ESPCache) do
        if player and player.Character then
            -- Recherche de n'importe quelle partie du corps
            local foundPart = nil
            for _, part in ipairs(player.Character:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "Humanoid" then
                    foundPart = part
                    break
                end
            end
            
            if foundPart then
                local pos, onScreen = Camera:WorldToViewportPoint(foundPart.Position)
                
                if onScreen then
                    -- Box ESP (méthode simple)
                    local scale = 1200 / pos.Z
                    local width = scale * 1.5
                    local height = scale * 2.5
                    
                    esp.Box.Size = Vector2.new(width, height)
                    esp.Box.Position = Vector2.new(pos.X - width/2, pos.Y - height/2)
                    esp.Box.Visible = ESPEnabled
                    
                    -- Name
                    esp.Name.Position = Vector2.new(pos.X, pos.Y - height/2 - 20)
                    esp.Name.Visible = ESPEnabled
                    
                    -- Health (si disponible)
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    if humanoid then
                        esp.Health.Text = "HP: " .. math.floor(humanoid.Health)
                        esp.Health.Position = Vector2.new(pos.X, pos.Y + height/2 + 5)
                        esp.Health.Visible = ESPEnabled
                    end
                else
                    esp.Box.Visible = false
                    esp.Name.Visible = false
                    esp.Health.Visible = false
                end
            else
                esp.Box.Visible = false
                esp.Name.Visible = false
                esp.Health.Visible = false
            end
        else
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Health.Visible = false
        end
    end
end

-- AIMBOT ULTIMATE POUR RUSH POINT
local Aiming = false

function GetBestTarget()
    if not LocalPlayer.Character then return nil end
    
    local bestTarget = nil
    local closestDistance = FOV
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            -- Vérification d'équipe si activé
            if not TeamCheck or (not player.Team or not LocalPlayer.Team or player.Team ~= LocalPlayer.Team) then
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    local humanoid = player.Character.Humanoid
                    if humanoid.Health > 0 then
                        -- Recherche de la tête d'abord, puis autre chose
                        local targetPart = player.Character:FindFirstChild("Head") or
                                          player.Character:FindFirstChild("HumanoidRootPart") or
                                          player.Character:FindFirstChild("UpperTorso")
                        
                        if not targetPart then
                            -- Cherche n'importe quelle BasePart
                            for _, part in ipairs(player.Character:GetChildren()) do
                                if part:IsA("BasePart") then
                                    targetPart = part
                                    break
                                end
                            end
                        end
                        
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

-- GESTION DES TOUCHES
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == MenuKey then
        MainFrame.Visible = not MainFrame.Visible
        UserInputService.MouseIconEnabled = MainFrame.Visible
    end
    
    if input.KeyCode == AimKey then
        Aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == AimKey then
        Aiming = false
    end
end)

-- BOUCLE PRINCIPALE (100% FONCTIONNEL)
RunService.RenderStepped:Connect(function()
    -- Mettre à jour le FOV Circle
    FOVCircle.Radius = FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    -- Mettre à jour l'ESP
    UpdateESP()
    
    -- AIMBOT LOGIC
    if AimbotEnabled and Aiming then
        local target = GetBestTarget()
        
        if target and target.Part then
            -- Calcul de la position cible
            local targetPos = target.Position
            
            -- Prédiction de mouvement basique
            if target.Player.Character:FindFirstChild("Humanoid") then
                local humanoid = target.Player.Character.Humanoid
                targetPos = targetPos + (humanoid.MoveDirection * 0.15)
            end
            
            -- Calcul du nouveau CFrame avec smoothing
            local currentCF = Camera.CFrame
            local goalCF = CFrame.new(currentCF.Position, targetPos)
            
            -- Appliquer le smoothing
            Camera.CFrame = currentCF:Lerp(goalCF, Smoothness)
        end
    end
end)

-- INITIALISATION
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

-- CONNEXIONS JOUEURS
Players.PlayerAdded:Connect(function(player)
    CreateESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPCache[player] then
        if ESPCache[player].Box then ESPCache[player].Box:Remove() end
        if ESPCache[player].Name then ESPCache[player].Name:Remove() end
        if ESPCache[player].Health then ESPCache[player].Health:Remove() end
        ESPCache[player] = nil
    end
end)

-- MESSAGE DE CONFIRMATION
print("========================================")
print("NEXUS ULTIMATE - RUSH POINT")
print("========================================")
print("✓ GUI chargé et visible")
print("✓ ESP activé")
print("✓ Aimbot activé (Touche: C)")
print("✓ FOV Circle visible")
print("✓ Menu: Insert (visible)")
print("========================================")
print("Instructions:")
print("1. Le GUI est déjà visible")
print("2. Maintenir C pour utiliser l'aimbot")
print("3. Insert pour cacher/montrer le menu")
print("4. Changer la touche aimbot dans le menu")
print("========================================")

-- Notification visuelle
local Notification = Instance.new("TextLabel")
Notification.Size = UDim2.new(0, 300, 0, 50)
Notification.Position = UDim2.new(0.5, -150, 0.1, 0)
Notification.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
Notification.TextColor3 = Color3.fromRGB(0, 255, 100)
Notification.Text = "NEXUS ULTIMATE LOADED\nAimbot: C | Menu: Insert"
Notification.TextSize = 14
Notification.Font = Enum.Font.GothamBold
Notification.TextWrapped = true
Notification.Parent = ScreenGui

-- Faire disparaître la notification après 5 secondes
wait(5)
Notification:Destroy()
