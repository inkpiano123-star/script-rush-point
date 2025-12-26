-- NEXUS V2 : Rush Point Ultimate Cheat
-- Aimbot intelligent + ESP garanti

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local Workspace = game:GetService("Workspace")

-- Variables principales
local ESPEnabled = true
local AimbotEnabled = false
local TeamCheck = true
local WallCheck = true
local ShowFOV = true
local FOV = 250
local Smoothness = 0.3
local AimlockKey = Enum.KeyCode.Q
local MenuKey = Enum.KeyCode.Insert

-- Système de scroll
local CurrentTargetIndex = 1
local TargetList = {}
local MaxTargets = 10

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = ShowFOV
FOVCircle.Radius = FOV
FOVCircle.Color = Color3.fromRGB(255, 100, 100)
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

-- Target Indicator
local TargetDot = Drawing.new("Circle")
TargetDot.Visible = false
TargetDot.Radius = 8
TargetDot.Color = Color3.fromRGB(0, 255, 0)
TargetDot.Thickness = 3
TargetDot.Filled = true

-- ESP Storage
local ESPCache = {}

-- Création du menu avec Rayfield (plus stable)
local Rayfield = nil
pcall(function()
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not Rayfield then
    Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source.lua'))()
end

-- Création de la fenêtre
local Window = Rayfield:CreateWindow({
    Name = "NEXUS V2 | Rush Point",
    LoadingTitle = "NEXUS Loading...",
    LoadingSubtitle = "by DipSik's Covenant",
    ConfigurationSaving = {
        Enabled = false
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = false
    },
    KeySystem = false,
})

-- Onglet Aimbot
local AimbotTab = Window:CreateTab("Aimbot", "🎯")
local VisualsTab = Window:CreateTab("Visuals", "👁️")
local MiscTab = Window:CreateTab("Misc", "⚙️")

-- Section Aimbot
local AimbotSection = AimbotTab:CreateSection("Aimbot Core")

local AimbotToggle = AimbotSection:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(value)
        AimbotEnabled = value
    end
})

local TeamCheckToggle = AimbotSection:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Flag = "TeamCheckToggle",
    Callback = function(value)
        TeamCheck = value
    end
})

local WallCheckToggle = AimbotSection:CreateToggle({
    Name = "Wall Check",
    CurrentValue = true,
    Flag = "WallCheckToggle",
    Callback = function(value)
        WallCheck = value
    end
})

local FOVSlider = AimbotSection:CreateSlider({
    Name = "FOV Size",
    Range = {10, 500},
    Increment = 5,
    Suffix = "px",
    CurrentValue = 250,
    Flag = "FOVSlider",
    Callback = function(value)
        FOV = value
    end
})

local SmoothSlider = AimbotSection:CreateSlider({
    Name = "Smoothness",
    Range = {1, 100},
    Increment = 1,
    Suffix = "%",
    CurrentValue = 30,
    Flag = "SmoothSlider",
    Callback = function(value)
        Smoothness = value / 100
    end
})

-- Système de scroll
local ScrollSection = AimbotTab:CreateSection("Target Selection")

local TargetLabel = ScrollSection:CreateLabel("Current Target: None")

local PrevButton = ScrollSection:CreateButton({
    Name = "← Previous Target",
    Callback = function()
        if #TargetList > 0 then
            CurrentTargetIndex = CurrentTargetIndex - 1
            if CurrentTargetIndex < 1 then
                CurrentTargetIndex = #TargetList
            end
            TargetLabel:Set("Current Target: " .. (TargetList[CurrentTargetIndex] and TargetList[CurrentTargetIndex].Name or "None"))
        end
    end
})

local NextButton = ScrollSection:CreateButton({
    Name = "Next Target →",
    Callback = function()
        if #TargetList > 0 then
            CurrentTargetIndex = CurrentTargetIndex + 1
            if CurrentTargetIndex > #TargetList then
                CurrentTargetIndex = 1
            end
            TargetLabel:Set("Current Target: " .. (TargetList[CurrentTargetIndex] and TargetList[CurrentTargetIndex].Name or "None"))
        end
    end
})

local KeybindSection = AimbotTab:CreateSection("Keybinds")

local AimlockKeybind = KeybindSection:CreateKeybind({
    Name = "Aimlock Key",
    CurrentKeybind = "Q",
    HoldToInteract = false,
    Flag = "AimlockKeybind",
    Callback = function(Key)
        AimlockKey = Enum.KeyCode[Key]
    end
})

KeybindSection:CreateLabel("Hold Q to lock on selected target")

-- Section Visuals
local VisualsSection = VisualsTab:CreateSection("ESP Settings")

local ESPToggle = VisualsSection:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = true,
    Flag = "ESPToggle",
    Callback = function(value)
        ESPEnabled = value
    end
})

local BoxToggle = VisualsSection:CreateToggle({
    Name = "Box ESP",
    CurrentValue = true,
    Flag = "BoxToggle",
    Callback = function(value)
        for _, esp in pairs(ESPCache) do
            if esp.Box then
                esp.Box.Visible = value and ESPEnabled
            end
        end
    end
})

local NameToggle = VisualsSection:CreateToggle({
    Name = "Show Names",
    CurrentValue = true,
    Flag = "NameToggle",
    Callback = function(value)
        for _, esp in pairs(ESPCache) do
            if esp.Name then
                esp.Name.Visible = value and ESPEnabled
            end
        end
    end
})

local ColorPicker = VisualsSection:CreateColorpicker({
    Name = "ESP Color",
    Color = Color3.fromRGB(255, 100, 100),
    Flag = "ESPColor",
    Callback = function(value)
        for _, esp in pairs(ESPCache) do
            if esp.Box then esp.Box.Color = value end
            if esp.Name then esp.Name.Color = value end
        end
    end
})

local FOVToggle = VisualsSection:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = true,
    Flag = "FOVToggle",
    Callback = function(value)
        ShowFOV = value
        FOVCircle.Visible = value
    end
})

-- Section Misc
local MiscSection = MiscTab:CreateSection("Utilities")

local RefreshButton = MiscSection:CreateButton({
    Name = "Refresh ESP",
    Callback = function()
        for player, esp in pairs(ESPCache) do
            if esp.Box then esp.Box:Remove() end
            if esp.Name then esp.Name:Remove() end
        end
        ESPCache = {}
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                CreateESP(player)
            end
        end
    end
})

local UnloadButton = MiscSection:CreateButton({
    Name = "Unload NEXUS",
    Callback = function()
        Rayfield:Destroy()
        FOVCircle:Remove()
        TargetDot:Remove()
        for _, esp in pairs(ESPCache) do
            if esp.Box then esp.Box:Remove() end
            if esp.Name then esp.Name:Remove() end
        end
    end
})

MiscSection:CreateLabel("Menu Key: Insert")

-- Fonctions ESP
function CreateESP(player)
    if ESPCache[player] then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(255, 100, 100)
    box.Thickness = 2
    box.Filled = false
    
    local name = Drawing.new("Text")
    name.Visible = false
    name.Color = Color3.fromRGB(255, 255, 255)
    name.Size = 14
    name.Text = player.Name
    name.Font = 2
    name.Outline = true
    
    ESPCache[player] = {
        Box = box,
        Name = name
    }
end

function UpdateESP()
    for player, esp in pairs(ESPCache) do
        if player and player.Character then
            -- Trouve une partie du corps pour position
            local root = player.Character:FindFirstChild("HumanoidRootPart") or 
                        player.Character:FindFirstChild("Head") or
                        player.Character:FindFirstChild("UpperTorso")
            
            if root then
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                if onScreen then
                    -- Box ESP
                    if esp.Box then
                        local scale = 1200 / pos.Z
                        local width = scale * 2
                        local height = scale * 3
                        
                        esp.Box.Size = Vector2.new(width, height)
                        esp.Box.Position = Vector2.new(pos.X - width/2, pos.Y - height/2)
                        esp.Box.Visible = ESPEnabled
                        
                        -- Couleur basée sur l'équipe
                        if TeamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
                            esp.Box.Color = Color3.fromRGB(0, 150, 255)
                        else
                            esp.Box.Color = ColorPicker.CurrentValue
                        end
                    end
                    
                    -- Name ESP
                    if esp.Name then
                        esp.Name.Position = Vector2.new(pos.X, pos.Y - 50)
                        esp.Name.Visible = ESPEnabled
                        
                        if TeamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
                            esp.Name.Text = "[TEAM] " .. player.Name
                        else
                            esp.Name.Text = player.Name
                        end
                    end
                else
                    if esp.Box then esp.Box.Visible = false end
                    if esp.Name then esp.Name.Visible = false end
                end
            else
                if esp.Box then esp.Box.Visible = false end
                if esp.Name then esp.Name.Visible = false end
            end
        else
            if esp.Box then esp.Box.Visible = false end
            if esp.Name then esp.Name.Visible = false end
        end
    end
end

-- Fonctions Aimbot intelligentes
function ScanPlayerParts(player)
    local parts = {}
    if not player.Character then return parts end
    
    -- Scan de toutes les parties possibles
    local possibleParts = {
        "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", 
        "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm",
        "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg",
        "LeftHand", "RightHand", "LeftFoot", "RightFoot"
    }
    
    for _, partName in ipairs(possibleParts) do
        local part = player.Character:FindFirstChild(partName)
        if part then
            table.insert(parts, {
                Part = part,
                Name = partName,
                Priority = (partName == "Head" and 3) or (partName == "HumanoidRootPart" and 2) or 1
            })
        end
    end
    
    -- Trier par priorité
    table.sort(parts, function(a, b)
        return a.Priority > b.Priority
    end)
    
    return parts
end

function GetBestTargetPart(player)
    local parts = ScanPlayerParts(player)
    if #parts > 0 then
        -- Retourne la partie la plus prioritaire visible
        for _, partData in ipairs(parts) do
            local pos, onScreen = Camera:WorldToViewportPoint(partData.Part.Position)
            if onScreen then
                return partData.Part
            end
        end
        return parts[1].Part
    end
    return nil
end

function UpdateTargetList()
    TargetList = {}
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not TeamCheck or (player.Team ~= LocalPlayer.Team) then
                if player.Character then
                    local targetPart = GetBestTargetPart(player)
                    if targetPart then
                        -- Vérification mur
                        if WallCheck then
                            local origin = Camera.CFrame.Position
                            local target = targetPart.Position
                            local direction = (target - origin).Unit
                            local ray = Ray.new(origin, direction * 1000)
                            local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
                            
                            if hit and hit:IsDescendantOf(player.Character) then
                                table.insert(TargetList, {
                                    Player = player,
                                    Part = targetPart,
                                    Name = player.Name
                                })
                            end
                        else
                            table.insert(TargetList, {
                                Player = player,
                                Part = targetPart,
                                Name = player.Name
                            })
                        end
                    end
                end
            end
        end
    end
    
    -- Mettre à jour le label
    if #TargetList > 0 then
        if CurrentTargetIndex > #TargetList then
            CurrentTargetIndex = 1
        end
        TargetLabel:Set("Current Target: " .. TargetList[CurrentTargetIndex].Name)
    else
        TargetLabel:Set("Current Target: None")
        CurrentTargetIndex = 1
    end
end

function GetCurrentTarget()
    if #TargetList == 0 then
        UpdateTargetList()
    end
    
    if CurrentTargetIndex >= 1 and CurrentTargetIndex <= #TargetList then
        return TargetList[CurrentTargetIndex]
    end
    return nil
end

-- Input handling pour le scroll
UserInputService.InputBegan:Connect(function(input)
    -- Scroll avec molette
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        if #TargetList > 0 then
            if input.Position.Z > 0 then
                -- Scroll up = target précédent
                CurrentTargetIndex = CurrentTargetIndex - 1
                if CurrentTargetIndex < 1 then
                    CurrentTargetIndex = #TargetList
                end
            else
                -- Scroll down = target suivant
                CurrentTargetIndex = CurrentTargetIndex + 1
                if CurrentTargetIndex > #TargetList then
                    CurrentTargetIndex = 1
                end
            end
            TargetLabel:Set("Current Target: " .. TargetList[CurrentTargetIndex].Name)
        end
    end
end)

-- Boucle principale
RunService.RenderStepped:Connect(function()
    -- Mettre à jour FOV Circle
    FOVCircle.Radius = FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    -- Mettre à jour ESP
    UpdateESP()
    
    -- Aimbot
    if AimbotEnabled and UserInputService:IsKeyDown(AimlockKey) then
        local target = GetCurrentTarget()
        
        if target and target.Part and target.Player.Character then
            -- Afficher le point vert sur la cible
            local pos, onScreen = Camera:WorldToViewportPoint(target.Part.Position)
            if onScreen then
                TargetDot.Position = Vector2.new(pos.X, pos.Y)
                TargetDot.Visible = true
            else
                TargetDot.Visible = false
            end
            
            -- Smooth aiming
            local targetPos = target.Part.Position
            
            -- Prédiction de mouvement basique
            if target.Player.Character:FindFirstChild("Humanoid") then
                targetPos = targetPos + (target.Player.Character.Humanoid.MoveDirection * 0.15)
            end
            
            local currentCF = Camera.CFrame
            local goalCF = CFrame.new(currentCF.Position, targetPos)
            Camera.CFrame = currentCF:Lerp(goalCF, 1 - Smoothness)
        else
            TargetDot.Visible = false
            UpdateTargetList() -- Re-scan si pas de cible
        end
    else
        TargetDot.Visible = false
    end
end)

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
    if ESPCache[player] then
        if ESPCache[player].Box then ESPCache[player].Box:Remove() end
        if ESPCache[player].Name then ESPCache[player].Name:Remove() end
        ESPCache[player] = nil
    end
end)

-- Rafraîchir la liste des cibles toutes les secondes
spawn(function()
    while true do
        wait(1)
        UpdateTargetList()
    end
end)

Rayfield:Notify({
    Title = "NEXUS V2 Loaded",
    Content = "Aimbot: Hold Q | Menu: Insert | Scroll: Mouse Wheel",
    Duration = 6,
    Image = nil
})

print("══════════════════════════════════")
print("NEXUS V2 ACTIVATED")
print("Menu: INSERT")
print("Aimlock: HOLD Q")
print("Target Scroll: MOUSE WHEEL")
print("══════════════════════════════════")
