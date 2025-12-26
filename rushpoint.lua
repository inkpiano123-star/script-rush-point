-- Rush Point: Ombre et Domination
-- Par DipSik's Covenant

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- Variables du système
local ESPEnabled = false
local AimbotEnabled = false
local NoRecoilEnabled = false
local SpeedEnabled = false
local SpeedMultiplier = 1.5
local AimbotKey = Enum.KeyCode.E
local Smoothness = 0.15
local AimPart = "Head"
local FOV = 70
local VisibleCheck = true
local TeamCheck = true

-- Pattern de Recoil (exemple pour une arme, à ajuster)
local RecoilPattern = {
    Vector2.new(0, 2),
    Vector2.new(-1, 3),
    Vector2.new(1, 4),
    Vector2.new(-2, 3),
    Vector2.new(2, 5)
}
local RecoilIndex = 1

-- GUI (Interface Graphique)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local Window = Library:CreateWindow("Rush Point // DipSik's Covenant")
local Tabs = {
    Main = Window:AddTab("Principal"),
    Visuals = Window:AddTab("Visuels"),
    Misc = Window:AddTab("Divers")
}

-- Fonction pour obtenir les ennemis
function GetEnemies()
    local enemies = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if TeamCheck then
                if player.Team ~= LocalPlayer.Team then
                    table.insert(enemies, player)
                end
            else
                table.insert(enemies, player)
            end
        end
    end
    return enemies
end

-- Fonction pour obtenir le joueur le plus proche du centre de l'écran
function GetClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = FOV
    for _, player in ipairs(GetEnemies()) do
        local character = player.Character
        if character and character:FindFirstChild(AimPart) then
            local partPos, onScreen = Camera:WorldToViewportPoint(character[AimPart].Position)
            if onScreen then
                local mousePos = UserInputService:GetMouseLocation()
                local distance = (Vector2.new(partPos.X, partPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                if distance < shortestDistance then
                    if VisibleCheck then
                        -- Vérification de la visibilité (raycast simplifié)
                        local origin = Camera.CFrame.Position
                        local destination = character[AimPart].Position
                        local direction = (destination - origin).Unit
                        local ray = Ray.new(origin, direction * 1000)
                        local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
                        if hit and hit:IsDescendantOf(character) then
                            closestPlayer = character
                            shortestDistance = distance
                        end
                    else
                        closestPlayer = character
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- Aimbot
RunService.RenderStepped:Connect(function()
    if AimbotEnabled and UserInputService:IsKeyDown(AimbotKey) then
        local target = GetClosestPlayerToCursor()
        if target and target:FindFirstChild(AimPart) then
            local targetPos = target[AimPart].Position
            local currentCameraPos = Camera.CFrame.Position
            local newCFrame = CFrame.new(currentCameraPos, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(newCFrame, Smoothness)
        end
    end
end)

-- No Recoil
local oldRecoil
if NoRecoilEnabled then
    oldRecoil = hookfunction(require(LocalPlayer.PlayerScripts.CombatFramework).Recoil, function(...)
        return nil -- Annule le recul
    end)
end

-- Speed Hack
RunService.Heartbeat:Connect(function()
    if SpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16 * SpeedMultiplier
    end
end)

-- ESP (Drawing)
local drawings = {}
function UpdateESP()
    for _, drawing in pairs(drawings) do
        drawing:Remove()
    end
    drawings = {}
    
    if not ESPEnabled then return end
    
    for _, player in ipairs(GetEnemies()) do
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local rootPart = character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            if onScreen then
                -- Box ESP
                local box = Drawing.new("Square")
                box.Visible = true
                box.Color = Color3.fromRGB(255, 0, 0)
                box.Thickness = 2
                box.Size = Vector2.new(100, 200)
                box.Position = Vector2.new(pos.X - 50, pos.Y - 100)
                table.insert(drawings, box)
                
                -- Name ESP
                local name = Drawing.new("Text")
                name.Visible = true
                name.Color = Color3.fromRGB(255, 255, 255)
                name.Size = 16
                name.Text = player.Name
                name.Position = Vector2.new(pos.X, pos.Y - 120)
                table.insert(drawings, name)
            end
        end
    end
end

RunService.RenderStepped:Connect(UpdateESP)

-- Skin Changer (exemple pour l'arme principale)
function ChangeSkin(skinName)
    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if tool then
        for _, part in ipairs(tool:GetDescendants()) do
            if part:IsA("MeshPart") or part:IsA("Part") then
                part.TextureID = "http://www.roblox.com/asset/?id=" .. skinName
            end
        end
    end
end

-- GUI Configuration
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
    Text = "Activer ESP",
    Default = false,
    Callback = function(value)
        ESPEnabled = value
    end
})

local MiscBox = Tabs.Misc:AddLeftGroupbox("Mouvement")
MiscBox:AddToggle("SpeedToggle", {
    Text = "Speed Hack",
    Default = false,
    Callback = function(value)
        SpeedEnabled = value
    end
})

MiscBox:AddSlider("SpeedSlider", {
    Text = "Multiplicateur de vitesse",
    Default = 1.5,
    Min = 1,
    Max = 5,
    Rounding = 1,
    Callback = function(value)
        SpeedMultiplier = value
    end
})

MiscBox:AddButton("Skin Changer (Gold)", function()
    ChangeSkin("123456789") -- Remplace par un ID réel
end)

-- Gestion du menu (Insert pour afficher/cacher)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Insert then
        Library:Toggle()
        if not gameProcessed then
            -- Rendre la souris visible quand le menu est ouvert
            UserInputService.MouseIconEnabled = Library.Unhiden
        end
    end
end)

-- Initialisation
Library:SetWindowKeybind(Enum.KeyCode.Insert)
print("DipSik's Covenant chargé. Appuie sur INSERT pour le menu.")
