-- RUSH POINT FORCE CHEAT
-- Minimal script that WORKS

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- SIMPLE VARIABLES
local ESP = true
local AIM = true
local FOV = 250
local SMOOTH = 0.3
local HOLDING = false

-- SIMPLE FOV CIRCLE (FORCED CENTER)
local Circle = Drawing.new("Circle")
Circle.Visible = true
Circle.Radius = FOV
Circle.Color = Color3.fromRGB(255, 0, 0)
Circle.Thickness = 2
Circle.Filled = false
Circle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

-- SIMPLE ESP (BOX ONLY)
local Boxes = {}

function CreateBox(player)
    if Boxes[player] then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Thickness = 2
    box.Filled = false
    
    Boxes[player] = box
end

function UpdateBoxes()
    for player, box in pairs(Boxes) do
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            
            if onScreen then
                local scale = 1000 / pos.Z
                box.Size = Vector2.new(scale * 2, scale * 3)
                box.Position = Vector2.new(pos.X - scale, pos.Y - scale * 1.5)
                box.Visible = ESP
            else
                box.Visible = false
            end
        else
            box.Visible = false
        end
    end
end

-- SIMPLE AIMBOT (FORCED)
function GetTarget()
    local closest = nil
    local closestDist = FOV
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                local humanoid = player.Character.Humanoid
                if humanoid.Health > 0 then
                    -- Try different body parts
                    local parts = {
                        "Head",
                        "HumanoidRootPart", 
                        "UpperTorso",
                        "LowerTorso"
                    }
                    
                    for _, partName in ipairs(parts) do
                        local part = player.Character:FindFirstChild(partName)
                        if part then
                            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                            if onScreen then
                                local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                                if dist < closestDist then
                                    closest = {
                                        Player = player,
                                        Part = part,
                                        Position = part.Position
                                    }
                                    closestDist = dist
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return closest
end

-- KEY BINDS (SIMPLE)
UserInputService.InputBegan:Connect(function(input)
    -- INSERT: Toggle ESP
    if input.KeyCode == Enum.KeyCode.Insert then
        ESP = not ESP
        print("ESP:", ESP and "ON" or "OFF")
        
        -- Show notification
        local msg = Instance.new("Message")
        msg.Text = "ESP: " .. (ESP and "ON" or "OFF")
        msg.Parent = workspace
        game:GetService("Debris"):AddItem(msg, 2)
    end
    
    -- DELETE: Toggle Aimbot
    if input.KeyCode == Enum.KeyCode.Delete then
        AIM = not AIM
        print("AIMBOT:", AIM and "ON" or "OFF")
        
        local msg = Instance.new("Message")
        msg.Text = "AIMBOT: " .. (AIM and "ON" or "OFF")
        msg.Parent = workspace
        game:GetService("Debris"):AddItem(msg, 2)
    end
    
    -- F1: Increase FOV
    if input.KeyCode == Enum.KeyCode.F1 then
        FOV = FOV + 25
        if FOV > 500 then FOV = 500 end
        Circle.Radius = FOV
        print("FOV:", FOV)
    end
    
    -- F2: Decrease FOV
    if input.KeyCode == Enum.KeyCode.F2 then
        FOV = FOV - 25
        if FOV < 50 then FOV = 50 end
        Circle.Radius = FOV
        print("FOV:", FOV)
    end
    
    -- F3: Increase Smooth
    if input.KeyCode == Enum.KeyCode.F3 then
        SMOOTH = SMOOTH + 0.05
        if SMOOTH > 1 then SMOOTH = 1 end
        print("SMOOTH:", SMOOTH)
    end
    
    -- F4: Decrease Smooth
    if input.KeyCode == Enum.KeyCode.F4 then
        SMOOTH = SMOOTH - 0.05
        if SMOOTH < 0.05 then SMOOTH = 0.05 end
        print("SMOOTH:", SMOOTH)
    end
    
    -- Q: Aim Key
    if input.KeyCode == Enum.KeyCode.Q then
        HOLDING = true
    end
    
    -- E: Fly Toggle
    if input.KeyCode == Enum.KeyCode.E then
        FLYING = not FLYING
        print("FLY:", FLYING and "ON" or "OFF")
    end
    
    -- R: Speed Toggle
    if input.KeyCode == Enum.KeyCode.R then
        SPEED = not SPEED
        print("SPEED:", SPEED and "ON" or "OFF")
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Q then
        HOLDING = false
    end
end)

-- MAIN LOOP (FORCED)
RunService.RenderStepped:Connect(function()
    -- Update FOV Circle Position (FORCE CENTER)
    Circle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    Circle.Radius = FOV
    
    -- Update ESP Boxes
    UpdateBoxes()
    
    -- AIMBOT
    if AIM and HOLDING then
        local target = GetTarget()
        if target and target.Part then
            local targetPos = target.Position
            
            -- Add movement prediction
            if target.Player.Character:FindFirstChild("Humanoid") then
                targetPos = targetPos + (target.Player.Character.Humanoid.MoveDirection * 0.2)
            end
            
            -- Force camera to look at target
            local current = Camera.CFrame
            local goal = CFrame.new(current.Position, targetPos)
            Camera.CFrame = current:Lerp(goal, SMOOTH)
        end
    end
    
    -- FLY HACK (SIMPLE)
    if FLYING and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            hrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 1
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            hrp.CFrame = hrp.CFrame - hrp.CFrame.LookVector * 1
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            hrp.CFrame = hrp.CFrame - hrp.CFrame.RightVector * 1
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            hrp.CFrame = hrp.CFrame + hrp.CFrame.RightVector * 1
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            hrp.CFrame = hrp.CFrame + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            hrp.CFrame = hrp.CFrame - Vector3.new(0, 1, 0)
        end
    end
    
    -- SPEED HACK
    if SPEED and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 50
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
    
    -- NOCLIP (ALWAYS ON IF ENABLED)
    if NOCLIP and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- INITIALIZE
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateBox(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    wait(1)
    CreateBox(player)
end)

Players.PlayerRemoving:Connect(function(player)
    if Boxes[player] then
        Boxes[player]:Remove()
        Boxes[player] = nil
    end
end)

-- PRINT CONTROLS
print("========================================")
print("RUSH POINT FORCE CHEAT LOADED")
print("========================================")
print("CONTROLS:")
print("INSERT - Toggle ESP")
print("DELETE - Toggle Aimbot")
print("Q - Hold to Aim")
print("E - Toggle Fly")
print("R - Toggle Speed")
print("F1/F2 - Change FOV Size")
print("F3/F4 - Change Smoothness")
print("========================================")
print("Fly: W/A/S/D + Space/Ctrl")
print("ESP: Red Boxes around players")
print("Aimbot: Hold Q to lock")
print("========================================")

-- SHOW LOAD MESSAGE
local msg = Instance.new("Message")
msg.Text = "CHEAT LOADED\nESP: ON | AIM: ON\nInsert=ESP Delete=Aimbot Q=Aim"
msg.Parent = workspace
game:GetService("Debris"):AddItem(msg, 5)
