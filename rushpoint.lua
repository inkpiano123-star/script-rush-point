

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")

-- Variables principales
local ESPEnabled = true
local AimbotEnabled = false
local Aimlock = false
local TeamCheck = true
local VisibleCheck = true
local UseFOV = true
local ShowFOVCircle = false
local FOV = 120
local Smoothness = 0.18
local AimPart = "Head"
local AimbotKey = Enum.KeyCode.E
local ThirdPerson = false

-- Stockage ESP
local ESPObjects = {}
local ChamsFolder = Instance.new("Folder")
ChamsFolder.Name = "DipSikChams"
ChamsFolder.Parent = workspace

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = ShowFOVCircle
FOVCircle.Radius = FOV
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 2
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

-- Méthodes de détection spécifiques à Rush Point
function GetValidPlayers()
    local valid = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if TeamCheck then
                if player.Team ~= LocalPlayer.Team then
                    table.insert(valid, player)
                end
            else
                table.insert(valid, player)
            end
        end
    end
    return valid
end

function IsPartVisible(part, player)
    if not VisibleCheck then return true end
    local origin = Camera.CFrame.Position
    local target = part.Position
    local direction = (target - origin).Unit * 500
    local ray = Ray.new(origin, direction)
    local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
    return hit and hit:IsDescendantOf(player.Character)
end

-- ESP via Highlight (plus stable que Drawing pour ce jeu)
function CreateESP(player)
    if ESPObjects[player] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = player.Name .. "_ESP"
    highlight.Adornee = nil
    highlight.FillColor = Color3.fromRGB(255, 50, 50)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = ChamsFolder
    
    -- Boîte Drawing en backup
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Thickness = 2
    box.Filled = false
    
    ESPObjects[player] = {
        Highlight = highlight,
        Box = box,
        Tracer = nil
    }
end

function UpdateESP()
    for player, data in pairs(ESPObjects) do
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            
            -- Mise à jour Highlight
            data.Highlight.Adornee = ESPEnabled and player.Character or nil
            
            -- Mise à jour Drawing Box (méthode alternative)
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local scale = (hrp.Size.Y * 1.5) / (pos.Z * math.tan(math.rad(Camera.FieldOfView * 0.5)) * 2)
                data.Box.Size = Vector2.new(scale * 2, scale * 3)
                data.Box.Position = Vector2.new(pos.X - data.Box.Size.X/2, pos.Y - data.Box.Size.Y/2)
                data.Box.Visible = ESPEnabled
            else
                data.Box.Visible = false
            end
        else
            data.Highlight.Adornee = nil
            data.Box.Visible = false
        end
    end
end

-- Aimbot avancé avec prédiction
function GetClosestTarget()
    local closest = nil
    local shortestDist = FOV
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    for _, player in ipairs(GetValidPlayers()) do
        local char = player.Character
        if char and char:FindFirstChild(AimPart) then
            local part = char[AimPart]
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            
            if onScreen then
                local distance
                if UseFOV then
                    distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                else
                    distance = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                end
                
                if distance < shortestDist then
                    if IsPartVisible(part, player) then
                        closest = {Character = char, Part = part, Distance = distance}
                        shortestDist = distance
                    end
                end
            end
        end
    end
    return closest
end

-- Aimbot avec smoothing
RunService.RenderStepped:Connect(function()
    FOVCircle.Radius = FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    if AimbotEnabled and (Aimlock or UserInputService:IsKeyDown(AimbotKey)) then
        local target = GetClosestTarget()
        if target then
            local targetPos = target.Part.Position
            
            -- Prédiction de mouvement basique
            if target.Character:FindFirstChild("Humanoid") then
                targetPos = targetPos + (target.Character.Humanoid.MoveDirection * 0.2)
            end
            
            local currentCF = Camera.CFrame
            local goalCF = CFrame.new(currentCF.Position, targetPos)
            Camera.CFrame = currentCF:Lerp(goalCF, 1 - Smoothness)
        end
    end
end)

-- Skin/Chams Changer pour les mains
function ApplyHandChams()
    local character = LocalPlayer.Character
    if not character then return end
    
    local function applyToTool(tool)
        for _, part in ipairs(tool:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                -- Crée un Highlight pour les mains/armes
                local cham = Instance.new("Highlight")
                cham.Name = "WeaponCham"
                cham.Adornee = part
                cham.FillColor = Color3.fromRGB(0, 255, 255)
                cham.OutlineColor = Color3.fromRGB(255, 255, 255)
                cham.FillTransparency = 0.3
                cham.OutlineTransparency = 0
                cham.Parent = part
                
                -- Change aussi la texture si possible
                if part:IsA("MeshPart") then
                    part.TextureID = "rbxassetid://your_texture_id_here" -- Remplace par un ID
                end
            end
        end
    end
    
    -- Applique aux outils équipés
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            applyToTool(tool)
        end
    end
    
    -- Applique aux mains
    local rightHand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
    local leftHand = character:FindFirstChild("LeftHand") or character:FindFirstChild("Left Arm")
    
    if rightHand then applyToTool(rightHand) end
    if leftHand then applyToTool(leftHand) end
end

-- Initialisation
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    CreateESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        ESPObjects[player].Highlight:Destroy()
        ESPObjects[player].Box:Remove()
        ESPObjects[player] = nil
    end
end)

RunService.RenderStepped:Connect(UpdateESP)

-- GUI avec toutes les options
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local Window = Library:CreateWindow("Rush Point // DipSik's Covenant V2")

local Tabs = {
    Aimbot = Window:AddTab("Aimbot"),
    Visuals = Window:AddTab("Visuals"),
    Skins = Window:AddTab("Skins/Chams"),
    Misc = Window:AddTab("Divers")
}

-- Tab Aimbot
local AimBox = Tabs.Aimbot:AddLeftGroupbox("Aimbot")
AimBox:AddToggle("AimbotToggle", {
    Text = "Activer Aimbot",
    Default = false,
    Callback = function(value)
        AimbotEnabled = value
    end
})

AimBox:AddToggle("AimlockToggle", {
    Text = "Aimlock (Verrouillage auto)",
    Default = false,
    Callback = function(value)
        Aimlock = value
    end
})

AimBox:AddToggle("TeamCheckToggle", {
    Text = "Vérifier équipe",
    Default = true,
    Callback = function(value)
        TeamCheck = value
    end
})

AimBox:AddToggle("VisibleCheckToggle", {
    Text = "Vérifier visibilité",
    Default = true,
    Callback = function(value)
        VisibleCheck = value
    end
})

AimBox:AddSlider("FOVSlider", {
    Text = "FOV",
    Default = 120,
    Min = 10,
    Max = 500,
    Rounding = 0,
    Callback = function(value)
        FOV = value
    end
})

AimBox:AddSlider("SmoothSlider", {
    Text = "Smoothness",
    Default = 0.18,
    Min = 0.01,
    Max = 1,
    Rounding = 3,
    Callback = function(value)
        Smoothness = value
    end
})

AimBox:AddDropdown("AimPartDropdown", {
    Text = "Partie à viser",
    Default = "Head",
    Values = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
    Callback = function(value)
        AimPart = value
    end
})

AimBox:AddKeybind("AimbotKeybind", {
    Text = "Touche Aimbot",
    Default = Enum.KeyCode.E,
    Callback = function(key)
        AimbotKey = key
    end
})

AimBox:AddToggle("ShowFOVToggle", {
    Text = "Montrer cercle FOV",
    Default = false,
    Callback = function(value)
        ShowFOVCircle = value
        FOVCircle.Visible = value
    end
})

-- Tab Visuals
local VisualsBox = Tabs.Visuals:AddLeftGroupbox("ESP")
VisualsBox:AddToggle("ESPToggle", {
    Text = "Activer ESP",
    Default = true,
    Callback = function(value)
        ESPEnabled = value
    end
})

VisualsBox:AddToggle("BoxESToggle", {
    Text = "Boîtes ESP (Drawing)",
    Default = true,
    Callback = function(value)
        for _, data in pairs(ESPObjects) do
            data.Box.Visible = value and ESPEnabled
        end
    end
})

VisualsBox:AddColorpicker("ESPColor", {
    Text = "Couleur ESP",
    Default = Color3.fromRGB(255, 50, 50),
    Callback = function(value)
        for _, data in pairs(ESPObjects) do
            data.Highlight.FillColor = value
        end
    end
})

-- Tab Skins
local SkinsBox = Tabs.Skins:AddLeftGroupbox("Chams Mains/Armes")
SkinsBox:AddButton("Appliquer Chams Mains", function()
    ApplyHandChams()
end)

SkinsBox:AddColorpicker("HandChamsColor", {
    Text = "Couleur Chams",
    Default = Color3.fromRGB(0, 255, 255),
    Callback = function(value)
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "WeaponCham" and obj:IsA("Highlight") then
                obj.FillColor = value
            end
        end
    end
})

SkinsBox:AddInput("TextureIDInput", {
    Text = "ID Texture (optionnel)",
    Default = "",
    Callback = function(value)
        if value ~= "" then
            -- Applique la texture aux mains
            local character = LocalPlayer.Character
            if character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("MeshPart") then
                        part.TextureID = "rbxassetid://" .. value
                    end
                end
            end
        end
    end
})

-- Tab Divers
local MiscBox = Tabs.Misc:AddLeftGroupbox("Configuration")
MiscBox:AddToggle("ThirdPersonToggle", {
    Text = "Mode troisième personne (expérimental)",
    Default = false,
    Callback = function(value)
        ThirdPerson = value
        if value then
            Camera.CameraType = Enum.CameraType.Scriptable
        else
            Camera.CameraType = Enum.CameraType.Custom
        end
    end
})

MiscBox:AddButton("Refresh ESP", function()
    for player, data in pairs(ESPObjects) do
        data.Highlight:Destroy()
        data.Box:Remove()
    end
    ESPObjects = {}
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESP(player)
        end
    end
end)

MiscBox:AddButton("Unload Script", function()
    Library:Unload()
    ChamsFolder:Destroy()
    FOVCircle:Remove()
    for _, data in pairs(ESPObjects) do
        data.Highlight:Destroy()
        data.Box:Remove()
    end
    print("Script déchargé")
end)

-- Gestion menu
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Insert then
        Library:Toggle()
        UserInputService.MouseIconEnabled = Library.Unhiden
    end
end)

Library:SetWindowKeybind(Enum.KeyCode.Insert)
print("DipSik's Covenant V2 chargé pour Rush Point")
print("Appuie sur INSERT pour le menu")
print("Touche Aimbot: E (changeable)")
