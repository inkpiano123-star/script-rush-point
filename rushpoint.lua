-- Rush Point : Ombre et Précision (Par DipSik's Covenant, adapté)
-- Supprime l'auto-join Discord, fixe l'ESP et l'Aimbot.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Variables de l'arme
local ESPEnabled = false
local AimbotEnabled = false
local AimPart = "Head"
local Smoothness = 0.15
local FOV = 100
local AimbotKey = Enum.KeyCode.Q -- Change la touche ici (Q par défaut)

-- Table pour stocker les boîtes ESP
local ESPBoxes = {}

-- Fonction pour créer une boîte ESP
function CreateESPBox(player)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(255, 0, 0)
    Box.Thickness = 2
    Box.Filled = false
    ESPBoxes[player] = Box
end

-- Fonction pour mettre à jour l'ESP
function UpdateESP()
    for player, box in pairs(ESPBoxes) do
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local scale = (player.Character.HumanoidRootPart.Size.Y * 2) / (pos.Z * math.tan(math.rad(Camera.FieldOfView * 0.5)))
                box.Size = Vector2.new(scale, scale * 1.5)
                box.Position = Vector2.new(pos.X - box.Size.X / 2, pos.Y - box.Size.Y / 2)
                box.Visible = ESPEnabled and player.Team ~= LocalPlayer.Team
            else
                box.Visible = false
            end
        else
            box.Visible = false
        end
    end
end

-- Connexion pour l'ESP
RunService.RenderStepped:Connect(UpdateESP)

-- Fonction pour obtenir l'ennemi le plus proche du curseur
function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = FOV
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(AimPart) and player.Team ~= LocalPlayer.Team then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character[AimPart].Position)
            if onScreen then
                local mousePos = UserInputService:GetMouseLocation()
                local distance = (Vector2.new(pos.X, pos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                if distance < shortestDistance then
                    closestPlayer = player.Character
                    shortestDistance = distance
                end
            end
        end
    end
    return closestPlayer
end

-- Aimbot
RunService.RenderStepped:Connect(function()
    if AimbotEnabled and UserInputService:IsKeyDown(AimbotKey) then
        local target = GetClosestPlayer()
        if target and target:FindFirstChild(AimPart) then
            local targetPos = target[AimPart].Position
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos):Lerp(Camera.CFrame, Smoothness)
        end
    end
end)

-- Initialisation des boîtes ESP pour les joueurs existants
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESPBox(player)
    end
end

-- Création des boîtes pour les nouveaux joueurs
Players.PlayerAdded:Connect(function(player)
    CreateESPBox(player)
end)

-- Suppression des boîtes quand un joueur quitte
Players.PlayerRemoving:Connect(function(player)
    if ESPBoxes[player] then
        ESPBoxes[player]:Remove()
        ESPBoxes[player] = nil
    end
end)

-- GUI Simple avec la bibliothèque LinoriaLib
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local Window = Library:CreateWindow("Rush Point // DipSik's Covenant")
local Tabs = {
    Main = Window:AddTab("Principal"),
    Visuals = Window:AddTab("Visuels")
}

local MainBox = Tabs.Main:AddLeftGroupbox("Aimbot")
MainBox:AddToggle("AimbotToggle", {
    Text = "Activer Aimbot",
    Default = false,
    Callback = function(value)
        AimbotEnabled = value
    end
})
MainBox:AddSlider("SmoothSlider", {
    Text = "Smoothness",
    Default = 0.15,
    Min = 0.01,
    Max = 1,
    Rounding = 2,
    Callback = function(value)
        Smoothness = value
    end
})
MainBox:AddDropdown("AimPartDropdown", {
    Text = "Partie à viser",
    Default = "Head",
    Values = {"Head", "HumanoidRootPart", "Torso"},
    Callback = function(value)
        AimPart = value
    end
})

local VisualsBox = Tabs.Visuals:AddLeftGroupbox("ESP")
VisualsBox:AddToggle("ESPToggle", {
    Text = "Activer ESP (Chams Box)",
    Default = false,
    Callback = function(value)
        ESPEnabled = value
    end
})

-- Gestion du menu (Insert pour afficher/cacher)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Insert then
        Library:Toggle()
        UserInputService.MouseIconEnabled = Library.Unhiden
    end
end)

Library:SetWindowKeybind(Enum.KeyCode.Insert)
print("DipSik's Covenant chargé. Appuie sur INSERT pour le menu.")
