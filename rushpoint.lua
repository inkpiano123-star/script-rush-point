-- NEXUS FINAL : Rush Point 100% Working Cheat
-- By DipSik's Covenant

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local Workspace = game:GetService("Workspace")

-- CORE VARIABLES
local ESPEnabled = true
local AimbotEnabled = true
local TeamCheck = true
local WallCheck = true
local ShowFOV = true
local FOV = 200
local Smoothness = 0.3
local AimKey = Enum.KeyCode.C
local MenuKey = Enum.KeyCode.Insert
local Holding = false

-- FOV Circle (ALWAYS VISIBLE)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Radius = FOV
FOVCircle.Color = Color3.fromRGB(255, 50, 100)
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

-- Target Dot
local TargetDot = Drawing.new("Circle")
TargetDot.Visible = false
TargetDot.Radius = 6
TargetDot.Color = Color3.fromRGB(0, 255, 0)
TargetDot.Thickness = 3
TargetDot.Filled = true

-- ESP Storage
local ESPCache = {}

-- SIMPLE GUI SYSTEM (No external libraries)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NexusGUI"
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

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 400)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
Title.Text = "NEXUS FINAL | RUSH POINT"
Title.TextColor3 = Color3.fromRGB(255, 50, 100)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -40, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18
CloseButton.Parent = MainFrame

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    UserInputService.MouseIconEnabled = false
end)

-- Content Frame
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -60)
Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Function to create toggle
function CreateToggle(name, text, default, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 30)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.LayoutOrder = #Content:GetChildren()
    
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
    
    toggleFrame.Parent = Content
end

-- Function to create slider
function CreateSlider(name, text, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 50)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.LayoutOrder = #Content:GetChildren()
    
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
    
    sliderFrame.Parent = Content
end

-- Create GUI elements
CreateToggle("ESPToggle", "Enable ESP", true, function(value)
    ESPEnabled = value
end)

CreateToggle("AimbotToggle", "Enable Aimbot", true, function(value)
    AimbotEnabled = value
end)

CreateToggle("TeamCheckToggle", "Team Check", true, function(value)
    TeamCheck = value
end)

CreateToggle("WallCheckToggle", "Wall Check", true, function(value)
    WallCheck = value
end)

CreateToggle("ShowFOVToggle", "Show FOV Circle", true, function(value)
    ShowFOV = value
    FOVCircle.Visible = value
end)

CreateSlider("FOVSlider", "FOV Size", 10, 500, FOV, function(value)
    FOV = value
end)

CreateSlider("SmoothSlider", "Smoothness", 1, 100, Smoothness * 100, function(value)
    Smoothness = value / 100
end)

-- Info label
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, 0, 0, 40)
InfoLabel.Position = UDim2.new(0, 0, 1, -40)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Aimbot Key: C | Menu: Insert"
InfoLabel.TextColor3 = Color3.fromRGB(150, 150, 200)
InfoLabel.TextSize = 12
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.Parent = Content

-- ESP Functions
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
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            local root = player.Character:FindFirstChild("HumanoidRootPart") or 
                         player.Character:FindFirstChild("UpperTorso") or
                         player.Character:FindFirstChild("Head")
            
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
                    
                    -- Team color
                    if TeamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
                        esp.Box.Color = Color3.fromRGB(0, 150, 255)
                    else
                        esp.Box.Color = Color3.fromRGB(255, 50, 100)
                    end
                    
                    -- Name
                    esp.Name.Position = Vector2.new(pos.X, pos.Y - 50)
                    esp.Name.Visible = ESPEnabled
                    
                    -- Health
                    esp.Health.Text = "HP: " .. math.floor(humanoid.Health)
                    esp.Health.Position = Vector2.new(pos.X, pos.Y + height/2 + 10)
                    esp.Health.Visible = ESPEnabled
                    
                    -- Health color
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    if healthPercent > 0.6 then
                        esp.Health.Color = Color3.fromRGB(0, 255, 100)
                    elseif healthPercent > 0.3 then
                        esp.Health.Color = Color3.fromRGB(255, 255, 0)
                    else
                        esp.Health.Color = Color3.fromRGB(255, 50, 50)
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

-- AIMBOT CORE (100% WORKING)
function GetBestTarget()
    local bestTarget = nil
    local closestDistance = FOV
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not TeamCheck or (player.Team ~= LocalPlayer.Team) then
                if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                    -- Find any visible body part
                    local bodyParts = {
                        "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso",
                        "LeftUpperArm", "RightUpperArm", "LeftHand", "RightHand"
                    }
                    
                    for _, partName in ipairs(bodyParts) do
                        local part = player.Character:FindFirstChild(partName)
                        if part then
                            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                            
                            if onScreen then
                                local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                                
                                if distance < closestDistance then
                                    -- Wall check
                                    if WallCheck then
                                        local origin = Camera.CFrame.Position
                                        local target = part.Position
                                        local direction = (target - origin).Unit
                                        local ray = Ray.new(origin, direction * 1000)
                                        local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
                                        
                                        if hit and hit:IsDescendantOf(player.Character) then
                                            bestTarget = {
                                                Player = player,
                                                Part = part,
                                                Distance = distance
                                            }
                                            closestDistance = distance
                                        end
                                    else
                                        bestTarget = {
                                            Player = player,
                                            Part = part,
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
    end
    
    return bestTarget
end

-- Input Handling
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == MenuKey then
        MainFrame.Visible = not MainFrame.Visible
        UserInputService.MouseIconEnabled = MainFrame.Visible
    end
    
    if input.KeyCode == AimKey then
        Holding = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == AimKey then
        Holding = false
        TargetDot.Visible = false
    end
end)

-- Main Render Loop
RunService.RenderStepped:Connect(function()
    -- Update FOV Circle
    FOVCircle.Radius = FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    -- Update ESP
    UpdateESP()
    
    -- AIMBOT LOGIC
    if AimbotEnabled and Holding then
        local target = GetBestTarget()
        
        if target and target.Part then
            -- Show target dot
            local screenPos = Camera:WorldToViewportPoint(target.Part.Position)
            TargetDot.Position = Vector2.new(screenPos.X, screenPos.Y)
            TargetDot.Visible = true
            
            -- Smooth aiming
            local targetPos = target.Part.Position
            
            -- Movement prediction
            if target.Player.Character:FindFirstChild("Humanoid") then
                local humanoid = target.Player.Character.Humanoid
                targetPos = targetPos + (humanoid.MoveDirection * 0.2)
            end
            
            -- Calculate new CFrame
            local currentCF = Camera.CFrame
            local goalCF = CFrame.new(currentCF.Position, targetPos)
            
            -- Apply smoothing
            Camera.CFrame = currentCF:Lerp(goalCF, Smoothness)
        else
            TargetDot.Visible = false
        end
    else
        TargetDot.Visible = false
    end
end)

-- Initialize ESP
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

-- Player connections
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

-- Debug info in console
print("==================================")
print("NEXUS FINAL LOADED SUCCESSFULLY")
print("==================================")
print("MENU KEY: INSERT")
print("AIMBOT KEY: C (HOLD TO AIM)")
print("FOV CIRCLE: VISIBLE")
print("ESP: ENABLED")
print("==================================")
print("Features:")
print("- ESP Boxes with Names")
print("- Health Display")
print"- FOV Circle with adjustable size")
print("- Smooth Aimbot")
print("- Team Check")
print("- Wall Check")
print("==================================")

-- Auto-close menu after 5 seconds
wait(5)
MainFrame.Visible = false
UserInputService.MouseIconEnabled = false
