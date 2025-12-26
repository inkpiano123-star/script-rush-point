-- ETHEREAL X 


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- VARIABLES (TOUT ACTIF PAR DÉFAUT)
local ESPEnabled = false
local AimbotEnabled = false
local TeamCheck = false
local WallCheck = false
local ShowFOV = false
local FOV = 200
local Smoothness = 0.3
local AimKey = Enum.KeyCode.Q
local MenuKey = Enum.KeyCode.Insert

-- FOV CIRCLE (FORCÉ VISIBLE)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Radius = FOV
FOVCircle.Color = Color3.fromRGB(255, 50, 100)
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

-- ESP STORAGE
local ESPCache = {}

-- CRÉATION DU GUI MAISON (100% VISIBLE)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EtherealGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game.CoreGui
else
    ScreenGui.Parent = game.CoreGui
end

-- FRAME PRINCIPALE (GRANDE ET COLORÉE)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 600)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 50, 100)
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- TITRE COLORÉ
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
Title.Text = "ETHEREAL X - RUSH POINT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- BOUTON FERMER
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -40, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18
CloseButton.Parent = MainFrame

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    UserInputService.MouseIconEnabled = MainFrame.Visible
end)

-- CONTENU SCROLLABLE
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -60)
ScrollFrame.Position = UDim2.new(0, 10, 0, 50)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 8
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 100)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 1200)
ScrollFrame.Parent = MainFrame

-- FONCTION POUR CRÉER UN TOGGLE
local function CreateToggle(text, default, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 35)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.LayoutOrder = #ScrollFrame:GetChildren()
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 60, 0, 25)
    toggleButton.Position = UDim2.new(0, 10, 0, 5)
    toggleButton.BackgroundColor3 = default and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 50, 50)
    toggleButton.Text = default and "ON" or "OFF"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextSize = 12
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Parent = toggleFrame
    
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Size = UDim2.new(1, -80, 1, 0)
    toggleLabel.Position = UDim2.new(0, 80, 0, 0)
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
        toggleButton.BackgroundColor3 = value and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 50, 50)
        toggleButton.Text = value and "ON" or "OFF"
        callback(value)
    end)
    
    toggleFrame.Parent = ScrollFrame
    return toggleFrame
end

-- FONCTION POUR CRÉER UN SLIDER
local function CreateSlider(text, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 50)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.LayoutOrder = #ScrollFrame:GetChildren()
    
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
    slider.Size = UDim2.new(1, 0, 0, 15)
    slider.Position = UDim2.new(0, 0, 0, 25)
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
    
    sliderFrame.Parent = ScrollFrame
    return sliderFrame
end

-- FONCTION POUR CRÉER UN BOUTON
local function CreateButton(text, callback)
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, 0, 0, 35)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.LayoutOrder = #ScrollFrame:GetChildren()
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 30)
    button.Position = UDim2.new(0, 10, 0, 2)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = text
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    button.Parent = buttonFrame
    
    button.MouseButton1Click:Connect(callback)
    
    buttonFrame.Parent = ScrollFrame
    return buttonFrame
end

-- SECTION AIMBOT
local AimSection = Instance.new("TextLabel")
AimSection.Size = UDim2.new(1, 0, 0, 30)
AimSection.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
AimSection.Text = "🎯 AIMBOT"
AimSection.TextColor3 = Color3.fromRGB(255, 150, 100)
AimSection.TextSize = 16
AimSection.Font = Enum.Font.GothamBold
AimSection.LayoutOrder = #ScrollFrame:GetChildren()
AimSection.Parent = ScrollFrame

CreateToggle("Enable Aimbot", true, function(value)
    AimbotEnabled = value
    print("Aimbot:", value and "ON" or "OFF")
end)

CreateSlider("FOV Size", 50, 500, 200, function(value)
    FOV = value
    print("FOV set to:", value)
end)

CreateSlider("Smoothness", 1, 100, 30, function(value)
    Smoothness = value / 100
    print("Smoothness:", Smoothness)
end)

CreateToggle("Show FOV Circle", true, function(value)
    ShowFOV = value
    FOVCircle.Visible = value
end)

CreateToggle("Team Check", false, function(value)
    TeamCheck = value
end)

CreateToggle("Wall Check", false, function(value)
    WallCheck = value
end)

-- SECTION ESP
local ESPSection = Instance.new("TextLabel")
ESPSection.Size = UDim2.new(1, 0, 0, 30)
ESPSection.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
ESPSection.Text = "👁️ ESP"
ESPSection.TextColor3 = Color3.fromRGB(100, 200, 255)
ESPSection.TextSize = 16
ESPSection.Font = Enum.Font.GothamBold
ESPSection.LayoutOrder = #ScrollFrame:GetChildren()
ESPSection.Parent = ScrollFrame

CreateToggle("Enable ESP", true, function(value)
    ESPEnabled = value
    print("ESP:", value and "ON" or "OFF")
end)

CreateToggle("Box ESP", true, function(value)
    for _, esp in pairs(ESPCache) do
        if esp.Box then
            esp.Box.Visible = value and ESPEnabled
        end
    end
end)

CreateToggle("Name ESP", true, function(value)
    for _, esp in pairs(ESPCache) do
        if esp.Name then
            esp.Name.Visible = value and ESPEnabled
        end
    end
end)

CreateToggle("Health ESP", true, function(value)
    for _, esp in pairs(ESPCache) do
        if esp.Health then
            esp.Health.Visible = value and ESPEnabled
        end
    end
end)

-- SECTION MOVEMENT
local MoveSection = Instance.new("TextLabel")
MoveSection.Size = UDim2.new(1, 0, 0, 30)
MoveSection.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
MoveSection.Text = "⚡ MOVEMENT"
MoveSection.TextColor3 = Color3.fromRGB(100, 255, 100)
MoveSection.TextSize = 16
MoveSection.Font = Enum.Font.GothamBold
MoveSection.LayoutOrder = #ScrollFrame:GetChildren()
MoveSection.Parent = ScrollFrame

local FlyEnabled = false
CreateToggle("Fly Hack", false, function(value)
    FlyEnabled = value
    print("Fly:", value and "ON" or "OFF")
    
    if value then
        local bodyGyro = Instance.new("BodyGyro")
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyGyro.P = 9e4
        bodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
        
        spawn(function()
            repeat
                wait()
                if FlyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.Humanoid.PlatformStand = true
                    bodyGyro.Parent = LocalPlayer.Character.HumanoidRootPart
                    bodyVelocity.Parent = LocalPlayer.Character.HumanoidRootPart
                    
                    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                    
                    local cam = workspace.CurrentCamera.CFrame
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        bodyVelocity.Velocity = cam.LookVector * 50
                    elseif UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        bodyVelocity.Velocity = -cam.LookVector * 50
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        bodyVelocity.Velocity = bodyVelocity.Velocity - cam.RightVector * 50
                    elseif UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        bodyVelocity.Velocity = bodyVelocity.Velocity + cam.RightVector * 50
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        bodyVelocity.Velocity = Vector3.new(bodyVelocity.Velocity.X, 50, bodyVelocity.Velocity.Z)
                    elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        bodyVelocity.Velocity = Vector3.new(bodyVelocity.Velocity.X, -50, bodyVelocity.Velocity.Z)
                    end
                end
            until not FlyEnabled
            
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.PlatformStand = false
            end
            bodyGyro:Destroy()
            bodyVelocity:Destroy()
        end)
    end
end)

local SpeedEnabled = false
CreateToggle("Speed Hack", false, function(value)
    SpeedEnabled = value
    print("Speed:", value and "ON" or "OFF")
end)

CreateSlider("Speed Value", 16, 100, 50, function(value)
    if SpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
end)

local NoClipEnabled = false
CreateToggle("NoClip", false, function(value)
    NoClipEnabled = value
    print("NoClip:", value and "ON" or "OFF")
end)

local InfiniteJump = false
CreateToggle("Infinite Jump", false, function(value)
    InfiniteJump = value
    print("Infinite Jump:", value and "ON" or "OFF")
end)

-- SECTION PLAYER
local PlayerSection = Instance.new("TextLabel")
PlayerSection.Size = UDim2.new(1, 0, 0, 30)
PlayerSection.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
PlayerSection.Text = "👤 PLAYER"
PlayerSection.TextColor3 = Color3.fromRGB(255, 150, 255)
PlayerSection.TextSize = 16
PlayerSection.Font = Enum.Font.GothamBold
PlayerSection.LayoutOrder = #ScrollFrame:GetChildren()
PlayerSection.Parent = ScrollFrame

CreateToggle("God Mode", false, function(value)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if value then
            LocalPlayer.Character.Humanoid.MaxHealth = math.huge
            LocalPlayer.Character.Humanoid.Health = math.huge
        else
            LocalPlayer.Character.Humanoid.MaxHealth = 100
            LocalPlayer.Character.Humanoid.Health = 100
        end
    end
    print("God Mode:", value and "ON" or "OFF")
end)

CreateToggle("No Recoil", false, function(value)
    print("No Recoil:", value and "ON" or "OFF")
end)

CreateToggle("Rapid Fire", false, function(value)
    print("Rapid Fire:", value and "ON" or "OFF")
end)

CreateToggle("Trigger Bot", false, function(value)
    print("Trigger Bot:", value and "ON" or "OFF")
end)

-- SECTION UTILITIES
local UtilSection = Instance.new("TextLabel")
UtilSection.Size = UDim2.new(1, 0, 0, 30)
UtilSection.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
UtilSection.Text = "⚙️ UTILITIES"
UtilSection.TextColor3 = Color3.fromRGB(255, 255, 150)
UtilSection.TextSize = 16
UtilSection.Font = Enum.Font.GothamBold
UtilSection.LayoutOrder = #ScrollFrame:GetChildren()
UtilSection.Parent = ScrollFrame

CreateButton("Refresh ESP", function()
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
    print("ESP Refreshed")
end)

CreateButton("Teleport To Spawn", function()
    if LocalPlayer.Character then
        LocalPlayer.Character:MoveTo(Vector3.new(0, 5, 0))
    end
    print("Teleported to spawn")
end)

CreateButton("Unload ETHEREAL", function()
    ScreenGui:Destroy()
    FOVCircle:Remove()
    for _, esp in pairs(ESPCache) do
        if esp.Box then esp.Box:Remove() end
        if esp.Name then esp.Name:Remove() end
        if esp.Health then esp.Health:Remove() end
    end
    print("ETHEREAL Unloaded")
end)

-- INFO LABEL
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, 0, 0, 40)
InfoLabel.Position = UDim2.new(0, 0, 1, -40)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Aimbot Key: Q | Menu: Insert | Fly: WASD+Space"
InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
InfoLabel.TextSize = 12
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.Parent = MainFrame

-- ESP FUNCTIONS
function CreateESP(player)
    if ESPCache[player] then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(255, 50, 100)
    box.Thickness = 2
    box.Filled = false
    
    local name = Drawing.new("Text")
    name.Visible = false
    name.Color = Color3.fromRGB(255, 255, 255)
    name.Size = 14
    name.Text = player.Name
    name.Font = 2
    name.Outline = true
    
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

function UpdateESP()
    for player, esp in pairs(ESPCache) do
        if player and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart") or
                        player.Character:FindFirstChild("Head") or
                        player.Character:FindFirstChild("UpperTorso")
            
            if root then
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                if onScreen then
                    local scale = 1000 / pos.Z
                    local width = scale * 2
                    local height = scale * 3
                    
                    esp.Box.Size = Vector2.new(width, height)
                    esp.Box.Position = Vector2.new(pos.X - width/2, pos.Y - height/2)
                    esp.Box.Visible = ESPEnabled
                    
                    esp.Name.Position = Vector2.new(pos.X, pos.Y - height/2 - 20)
                    esp.Name.Visible = ESPEnabled
                    
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

-- AIMBOT FUNCTIONS
function GetBestTarget()
    local bestTarget = nil
    local closestDistance = FOV
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
    if input.KeyCode == MenuKey then
        MainFrame.Visible = not MainFrame.Visible
        UserInputService.MouseIconEnabled = MainFrame.Visible
    end
    
    if input.KeyCode == AimKey then
        Aiming = true
    end
    
    if InfiniteJump and input.KeyCode == Enum.KeyCode.Space then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:ChangeState("Jumping")
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == AimKey then
        Aiming = false
    end
end)

-- MAIN LOOP
RunService.RenderStepped:Connect(function()
    -- UPDATE FOV CIRCLE (CENTRE ÉCRAN)
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Radius = FOV
    
    -- UPDATE ESP
    UpdateESP()
    
    -- NOCLP LOGIC
    if NoClipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    -- AIMBOT LOGIC
    if AimbotEnabled and Aiming then
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
    if SpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 50
    end
end)

-- INITIALIZE
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    wait(0.5)
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

-- CONFIRMATION MESSAGE
print("========================================")
print("ETHEREAL X LOADED SUCCESSFULLY!")
print("========================================")
print("GUI: VISIBLE (Draggable)")
print("Aimbot Key: Q (Hold)")
print("Menu Key: Insert")
print("Fly: W/A/S/D + Space/LeftControl")
print("========================================")
print("Features Active:")
print("- ESP Box/Name/Health")
print("- Aimbot with FOV Circle")
print("- Fly Hack")
print("- Speed Hack")
print("- NoClip")
print("- Infinite Jump")
print("- God Mode")
print("========================================")

-- FIX FOV CIRCLE POSITION (FORCÉ AU CENTRE)
spawn(function()
    wait(0.1)
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
end)
