-- CHEAT RUSH POINT - SYSTÈME NOUVEAU
-- GUI simple + fonctions basiques qui MARCHENT

-- INITIALISATION
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- VARIABLES SIMPLES
local ESP_ACTIF = false
local AIM_ACTIF = false
local FLY_ACTIF = false
local SPEED_ACTIF = false
local FOV = 150
local SMOOTH = 0.2

-- CRÉATION DU GUI (ULTRA-SIMPLE)
local ScreenGUI = Instance.new("ScreenGui")
ScreenGUI.Name = "CheatMenu"
ScreenGUI.DisplayOrder = 999

if gethui then
    ScreenGUI.Parent = gethui()
else
    ScreenGUI.Parent = game.CoreGui
end

-- FRAME PRINCIPALE
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 300, 0, 400)
Main.Position = UDim2.new(0.5, -150, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.fromRGB(0, 150, 255)
Main.Visible = false
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGUI

-- TITRE
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
Title.Text = "CHEAT RUSH POINT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

-- LISTE DES OPTIONS
local OptionsFrame = Instance.new("ScrollingFrame")
OptionsFrame.Size = UDim2.new(1, -10, 1, -50)
OptionsFrame.Position = UDim2.new(0, 5, 0, 45)
OptionsFrame.BackgroundTransparency = 1
OptionsFrame.BorderSizePixel = 0
OptionsFrame.ScrollBarThickness = 6
OptionsFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
OptionsFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
OptionsFrame.Parent = Main

-- FONCTION POUR AJOUTER UNE OPTION
local function AddOption(text, default, callback)
    local optionFrame = Instance.new("Frame")
    optionFrame.Size = UDim2.new(1, 0, 0, 35)
    optionFrame.BackgroundTransparency = 1
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.3, 0, 0, 25)
    button.Position = UDim2.new(0, 5, 0, 5)
    button.BackgroundColor3 = default and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
    button.Text = default and "ACTIF" or "INACTIF"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 12
    button.Font = Enum.Font.GothamBold
    button.Parent = optionFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0.32, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "  " .. text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = optionFrame
    
    local state = default
    
    button.MouseButton1Click:Connect(function()
        state = not state
        button.BackgroundColor3 = state and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
        button.Text = state and "ACTIF" or "INACTIF"
        callback(state)
        
        -- Notification
        local notif = Instance.new("TextLabel")
        notif.Size = UDim2.new(0, 200, 0, 30)
        notif.Position = UDim2.new(0.5, -100, 1, 10)
        notif.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        notif.Text = text .. ": " .. (state and "ON" or "OFF")
        notif.TextColor3 = Color3.fromRGB(255, 255, 255)
        notif.TextSize = 14
        notif.Font = Enum.Font.Gotham
        notif.Parent = Main
        game:GetService("Debris"):AddItem(notif, 1)
    end)
    
    optionFrame.Parent = OptionsFrame
    OptionsFrame.CanvasSize = UDim2.new(0, 0, 0, #OptionsFrame:GetChildren() * 40)
    
    return optionFrame
end

-- AJOUT DES OPTIONS
AddOption("ESP Joueurs", false, function(state)
    ESP_ACTIF = state
    print("ESP:", state)
end)

AddOption("Aimbot (Maintenir C)", false, function(state)
    AIM_ACTIF = state
    print("Aimbot:", state)
end)

AddOption("Fly Hack", false, function(state)
    FLY_ACTIF = state
    print("Fly:", state)
end)

AddOption("Speed Hack", false, function(state)
    SPEED_ACTIF = state
    print("Speed:", state)
end)

AddOption("NoClip", false, function(state)
    NOCLIP_ACTIF = state
    print("NoClip:", state)
end)

AddOption("God Mode", false, function(state)
    GODMODE_ACTIF = state
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        if state then
            LP.Character.Humanoid.MaxHealth = math.huge
            LP.Character.Humanoid.Health = math.huge
        else
            LP.Character.Humanoid.MaxHealth = 100
            LP.Character.Humanoid.Health = 100
        end
    end
end)

-- BOUTON FERMER
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -40, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18
CloseButton.Parent = Main

CloseButton.MouseButton1Click:Connect(function()
    Main.Visible = false
    UIS.MouseIconEnabled = false
end)

-- OUVERTURE DU MENU
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        Main.Visible = not Main.Visible
        UIS.MouseIconEnabled = Main.Visible
    end
end)

-- ESP SIMPLE
local ESPBoxes = {}

function UpdateESP()
    if not ESP_ACTIF then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                -- Créer une boîte ESP simple
                if not ESPBoxes[player] then
                    local box = Instance.new("SelectionBox")
                    box.Name = "ESPBox"
                    box.Color3 = Color3.fromRGB(255, 0, 0)
                    box.LineThickness = 0.05
                    box.Adornee = hrp
                    box.Parent = hrp
                    ESPBoxes[player] = box
                else
                    ESPBoxes[player].Adornee = hrp
                    ESPBoxes[player].Visible = true
                end
            end
        end
    end
end

-- AIMBOT SIMPLE
local AIM_HOLDING = false

UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.C then
        AIM_HOLDING = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.C then
        AIM_HOLDING = false
    end
end)

function SimpleAimbot()
    if not AIM_ACTIF or not AIM_HOLDING then return end
    
    local closest = nil
    local closestDist = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (hrp.Position - Camera.CFrame.Position).Magnitude
                if dist < closestDist then
                    closest = hrp
                    closestDist = dist
                end
            end
        end
    end
    
    if closest then
        -- Pointage simple vers le joueur
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Position)
    end
end

-- FLY HACK SIMPLE
function SimpleFly()
    if not FLY_ACTIF or not LP.Character then return end
    
    local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local speed = 2
    
    if UIS:IsKeyDown(Enum.KeyCode.W) then
        hrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector * speed
    end
    if UIS:IsKeyDown(Enum.KeyCode.S) then
        hrp.CFrame = hrp.CFrame - hrp.CFrame.LookVector * speed
    end
    if UIS:IsKeyDown(Enum.KeyCode.A) then
        hrp.CFrame = hrp.CFrame - hrp.CFrame.RightVector * speed
    end
    if UIS:IsKeyDown(Enum.KeyCode.D) then
        hrp.CFrame = hrp.CFrame + hrp.CFrame.RightVector * speed
    end
    if UIS:IsKeyDown(Enum.KeyCode.Space) then
        hrp.CFrame = hrp.CFrame + Vector3.new(0, speed, 0)
    end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
        hrp.CFrame = hrp.CFrame - Vector3.new(0, speed, 0)
    end
end

-- SPEED HACK
function UpdateSpeed()
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        if SPEED_ACTIF then
            LP.Character.Humanoid.WalkSpeed = 50
        else
            LP.Character.Humanoid.WalkSpeed = 16
        end
    end
end

-- NOCLIP
function UpdateNoClip()
    if NOCLIP_ACTIF and LP.Character then
        for _, part in pairs(LP.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

-- BOUCLE PRINCIPALE
RunService.Heartbeat:Connect(function()
    -- Mettre à jour les hacks
    UpdateESP()
    SimpleAimbot()
    SimpleFly()
    UpdateSpeed()
    UpdateNoClip()
    
    -- Nettoyer les ESP des joueurs qui ont quitté
    for player, box in pairs(ESPBoxes) do
        if not player or not player.Character then
            box:Destroy()
            ESPBoxes[player] = nil
        end
    end
end)

-- INITIALISATION
print("==================================")
print("CHEAT RUSH POINT CHARGÉ")
print("==================================")
print("Insert: Ouvre le menu")
print("C: Maintenir pour aimbot")
print("==================================")
print("ESP: Boîtes rouges")
print("Aimbot: Lock sur joueurs")
print("Fly: WASD + Space/Ctrl")
print("Speed: Course rapide")
print("==================================")

-- NOTIFICATION DE DÉMARRAGE
local StartupMsg = Instance.new("Message")
StartupMsg.Text = "CHEAT CHARGÉ\nInsert = Menu\nC = Aimbot"
StartupMsg.Parent = workspace
game:GetService("Debris"):AddItem(StartupMsg, 3)
