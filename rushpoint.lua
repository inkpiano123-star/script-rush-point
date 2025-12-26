-- NEXUS : Ultimate Rush Point Cheat
-- By DipSik's Covenant

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local Workspace = game:GetService("Workspace")

-- Core Variables
local ESPEnabled = false
local AimbotEnabled = false
local Aimlock = false
local TeamCheck = true
local WallCheck = true
local VisibleCheck = true
local ShowFOV = false
local FOV = 120
local Smoothness = 0.2
local AimPart = "Head"
local AimbotKey = Enum.KeyCode.E
local Holding = false

-- ESP Storage
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "NexusESP"
ESPFolder.Parent = workspace

local ESPCache = {}

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = ShowFOV
FOVCircle.Radius = FOV
FOVCircle.Color = Color3.fromRGB(255, 50, 50)
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

-- Target
local CurrentTarget = nil

-- Load LinoriaLib properly
local success, Library = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
end)

if not success then
    Library = loadstring(game:HttpGet("https://pastebin.com/raw/vq8kU3p2"))()
end

-- Create Window
local Window = Library:CreateWindow("NEXUS | Rush Point")
local Tabs = {
    Aimbot = Window:AddTab("Aimbot"),
    Visuals = Window:AddTab("Visuals"),
    Players = Window:AddTab("Players"),
    Settings = Window:AddTab("Settings")
}

-- Aimbot Tab
local AimGroup = Tabs.Aimbot:AddLeftGroupbox("Aimbot")

AimGroup:AddToggle('AimbotToggle', {
    Text = 'Enable Aimbot',
    Default = false,
    Callback = function(value)
        AimbotEnabled = value
    end
})

AimGroup:AddToggle('AimlockToggle', {
    Text = 'Aimlock Mode',
    Default = false,
    Callback = function(value)
        Aimlock = value
        if value then AimbotEnabled = true end
    end
})

AimGroup:AddToggle('TeamCheckToggle', {
    Text = 'Team Check',
    Default = true,
    Callback = function(value)
        TeamCheck = value
    end
})

AimGroup:AddToggle('WallCheckToggle', {
    Text = 'Wall Check',
    Default = true,
    Callback = function(value)
        WallCheck = value
    end
})

AimGroup:AddToggle('VisibleCheckToggle', {
    Text = 'Visibility Check',
    Default = true,
    Callback = function(value)
        VisibleCheck = value
    end
})

AimGroup:AddToggle('ShowFOVToggle', {
    Text = 'Show FOV Circle',
    Default = false,
    Callback = function(value)
        ShowFOV = value
        FOVCircle.Visible = value
    end
})

AimGroup:AddSlider('FOVSlider', {
    Text = 'FOV Size',
    Default = 120,
    Min = 10,
    Max = 500,
    Rounding = 0,
    Callback = function(value)
        FOV = value
    end
})

AimGroup:AddSlider('SmoothSlider', {
    Text = 'Smoothness',
    Default = 20,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Callback = function(value)
        Smoothness = value / 100
    end
})

AimGroup:AddDropdown('AimPartDropdown', {
    Text = 'Aim Part',
    Default = 'Head',
    Values = {'Head', 'HumanoidRootPart', 'UpperTorso', 'LowerTorso'},
    Callback = function(value)
        AimPart = value
    end
})

AimGroup:AddKeybind('AimbotKeybind', {
    Text = 'Aimbot Key',
    Default = Enum.KeyCode.E,
    Callback = function(key)
        AimbotKey = key
    end
})

AimGroup:AddLabel('Aimbot Mode: Hold key to aim')

-- Visuals Tab
local VisualsGroup = Tabs.Visuals:AddLeftGroupbox("ESP")

VisualsGroup:AddToggle('ESPToggle', {
    Text = 'Enable ESP',
    Default = false,
    Callback = function(value)
        ESPEnabled = value
        if not value then
            for _, esp in pairs(ESPCache) do
                if esp.Highlight then
                    esp.Highlight.Enabled = false
                end
            end
        end
    end
})

VisualsGroup:AddToggle('BoxESToggle', {
    Text = 'Box ESP',
    Default = true,
    Callback = function(value)
        for _, esp in pairs(ESPCache) do
            if esp.Box then
                esp.Box.Visible = value and ESPEnabled
            end
        end
    end
})

VisualsGroup:AddToggle('TracerToggle', {
    Text = 'Tracers',
    Default = false,
    Callback = function(value)
        for _, esp in pairs(ESPCache) do
            if esp.Tracer then
                esp.Tracer.Visible = value and ESPEnabled
            end
        end
    end
})

VisualsGroup:AddToggle('NameESToggle', {
    Text = 'Names',
    Default = true,
    Callback = function(value)
        for _, esp in pairs(ESPCache) do
            if esp.Name then
                esp.Name.Visible = value and ESPEnabled
            end
        end
    end
})

VisualsGroup:AddColorpicker('ESPColor', {
    Text = 'ESP Color',
    Default = Color3.fromRGB(255, 50, 50),
    Callback = function(value)
        for _, esp in pairs(ESPCache) do
            if esp.Highlight then
                esp.Highlight.FillColor = value
                esp.Highlight.OutlineColor = value
            end
            if esp.Box then esp.Box.Color = value end
            if esp.Tracer then esp.Tracer.Color = value end
        end
    end
})

-- Players Tab
local PlayersGroup = Tabs.Players:AddLeftGroupbox("Player List")

local PlayerList = {}
local function UpdatePlayerList()
    PlayersGroup:Clear()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            PlayersGroup:AddLabel(player.Name .. " | " .. (player.Team and player.Team.Name or "No Team"))
        end
    end
end

UpdatePlayerList()
Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)

-- Settings Tab
local SettingsGroup = Tabs.Settings:AddLeftGroupbox("Configuration")

SettingsGroup:AddButton('Refresh ESP', function()
    for player, esp in pairs(ESPCache) do
        if esp.Highlight then esp.Highlight:Destroy() end
        if esp.Box then esp.Box:Remove() end
        if esp.Tracer then esp.Tracer:Remove() end
        if esp.Name then esp.Name:Remove() end
    end
    ESPCache = {}
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESP(player)
        end
    end
end)

SettingsGroup:AddButton('Unload Cheat', function()
    Library:Unload()
    ESPFolder:Destroy()
    FOVCircle:Remove()
    for _, esp in pairs(ESPCache) do
        if esp.Highlight then esp.Highlight:Destroy() end
        if esp.Box then esp.Box:Remove() end
        if esp.Tracer then esp.Tracer:Remove() end
        if esp.Name then esp.Name:Remove() end
    end
    ESPCache = {}
end)

SettingsGroup:AddLabel('Menu Key: Insert')

-- Set window keybind
Library:SetWindowKeybind(Enum.KeyCode.Insert)

-- ESP Functions
function CreateESP(player)
    if ESPCache[player] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = player.Name .. "_ESP"
    highlight.Adornee = nil
    highlight.FillColor = Color3.fromRGB(255, 50, 50)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = false
    highlight.Parent = ESPFolder
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(255, 50, 50)
    box.Thickness = 2
    box.Filled = false
    
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = Color3.fromRGB(255, 50, 50)
    tracer.Thickness = 1
    
    local name = Drawing.new("Text")
    name.Visible = false
    name.Color = Color3.fromRGB(255, 255, 255)
    name.Size = 14
    name.Text = player.Name
    name.Font = 2
    name.Outline = true
    
    ESPCache[player] = {
        Highlight = highlight,
        Box = box,
        Tracer = tracer,
        Name = name
    }
end

function UpdateESP()
    for player, esp in pairs(ESPCache) do
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local character = player.Character
            local hrp = character.HumanoidRootPart
            
            -- Highlight
            if esp.Highlight then
                esp.Highlight.Adornee = character
                esp.Highlight.Enabled = ESPEnabled
            end
            
            -- Screen position
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            
            if onScreen then
                -- Box ESP
                if esp.Box then
                    local scale = 1000 / pos.Z
                    local size = Vector2.new(scale * 2, scale * 3)
                    esp.Box.Size = size
                    esp.Box.Position = Vector2.new(pos.X - size.X/2, pos.Y - size.Y/2)
                    esp.Box.Visible = ESPEnabled
                end
                
                -- Tracer
                if esp.Tracer then
                    esp.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    esp.Tracer.To = Vector2.new(pos.X, pos.Y)
                    esp.Tracer.Visible = ESPEnabled
                end
                
                -- Name
                if esp.Name then
                    esp.Name.Position = Vector2.new(pos.X, pos.Y - 40)
                    esp.Name.Visible = ESPEnabled
                end
            else
                if esp.Box then esp.Box.Visible = false end
                if esp.Tracer then esp.Tracer.Visible = false end
                if esp.Name then esp.Name.Visible = false end
            end
        else
            if esp.Highlight then esp.Highlight.Enabled = false end
            if esp.Box then esp.Box.Visible = false end
            if esp.Tracer then esp.Tracer.Visible = false end
            if esp.Name then esp.Name.Visible = false end
        end
    end
end

-- Aimbot Functions
function GetValidPlayers()
    local valid = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if TeamCheck then
                if not player.Team or player.Team ~= LocalPlayer.Team then
                    table.insert(valid, player)
                end
            else
                table.insert(valid, player)
            end
        end
    end
    return valid
end

function RaycastCheck(origin, target, ignore)
    if not WallCheck then return true end
    
    local direction = (target - origin).Unit
    local distance = (target - origin).Magnitude
    local ray = Ray.new(origin, direction * distance)
    
    local ignoreList = {LocalPlayer.Character, Camera, ESPFolder}
    if ignore then
        table.insert(ignoreList, ignore)
    end
    
    local hit, pos = Workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
    
    if hit then
        local model = hit:FindFirstAncestorOfClass("Model")
        if model and model:FindFirstChild("Humanoid") then
            return true
        end
        return false
    end
    
    return true
end

function GetClosestTarget()
    local closest = nil
    local shortestDist = FOV
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    
    for _, player in ipairs(GetValidPlayers()) do
        local character = player.Character
        if character and character:FindFirstChild(AimPart) then
            local part = character[AimPart]
            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            
            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                
                if distance < shortestDist then
                    if VisibleCheck then
                        if RaycastCheck(Camera.CFrame.Position, part.Position, character) then
                            closest = {
                                Character = character,
                                Part = part,
                                Player = player,
                                Distance = distance
                            }
                            shortestDist = distance
                        end
                    else
                        closest = {
                            Character = character,
                            Part = part,
                            Player = player,
                            Distance = distance
                        }
                        shortestDist = distance
                    end
                end
            end
        end
    end
    
    return closest
end

-- Input Handling
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == AimbotKey then
        Holding = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == AimbotKey then
        Holding = false
        CurrentTarget = nil
    end
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    -- Update FOV Circle
    FOVCircle.Radius = FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    -- Update ESP
    UpdateESP()
    
    -- Aimbot Logic
    if AimbotEnabled then
        local shouldAim = false
        
        if Aimlock then
            shouldAim = true
        elseif Holding then
            shouldAim = true
        end
        
        if shouldAim then
            if not CurrentTarget then
                CurrentTarget = GetClosestTarget()
            end
            
            if CurrentTarget and CurrentTarget.Part then
                -- Verify target is still valid
                if not CurrentTarget.Character or not CurrentTarget.Character:FindFirstChild(AimPart) then
                    CurrentTarget = GetClosestTarget()
                end
                
                if CurrentTarget and CurrentTarget.Part then
                    -- Wall check during aim
                    if WallCheck then
                        if not RaycastCheck(Camera.CFrame.Position, CurrentTarget.Part.Position, CurrentTarget.Character) then
                            CurrentTarget = nil
                            return
                        end
                    end
                    
                    -- Aim smoothing
                    local targetPos = CurrentTarget.Part.Position
                    
                    -- Movement prediction
                    if CurrentTarget.Character:FindFirstChild("Humanoid") then
                        targetPos = targetPos + (CurrentTarget.Character.Humanoid.MoveDirection * 0.1)
                    end
                    
                    local currentCF = Camera.CFrame
                    local goalCF = CFrame.new(currentCF.Position, targetPos)
                    Camera.CFrame = currentCF:Lerp(goalCF, 1 - Smoothness)
                end
            else
                CurrentTarget = GetClosestTarget()
            end
        else
            CurrentTarget = nil
        end
    else
        CurrentTarget = nil
    end
end)

-- Initialize ESP for existing players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

-- Player connections
Players.PlayerAdded:Connect(function(player)
    CreateESP(player)
    UpdatePlayerList()
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPCache[player] then
        if ESPCache[player].Highlight then ESPCache[player].Highlight:Destroy() end
        if ESPCache[player].Box then ESPCache[player].Box:Remove() end
        if ESPCache[player].Tracer then ESPCache[player].Tracer:Remove() end
        if ESPCache[player].Name then ESPCache[player].Name:Remove() end
        ESPCache[player] = nil
    end
    UpdatePlayerList()
end)

-- Notify user
Library:Notify("NEXUS loaded successfully!", 5)
print("NEXUS Cheat Loaded")
print("Menu Key: INSERT")
print("Aimbot Key: E (Hold)")
print("Aimlock: Toggle in menu")
