-- Rush Point : Ombre Définitive (DipSik's Covenant V3)
-- Menu maison + Aimbot/Aimlock dual + Wall Check avancé

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local Workspace = game:GetService("Workspace")

-- Variables principales
local ESPEnabled = true
local AimbotMode = "Toggle" -- "Toggle", "Hold", "Aimlock"
local AimlockEnabled = false
local TeamCheck = true
local WallCheck = true
local VisibleCheck = true
local UseFOV = true
local ShowFOV = false
local FOV = 120
local Smoothness = 0.2
local AimPart = "Head"
local AimbotKey = Enum.KeyCode.E
local MenuKey = Enum.KeyCode.Insert
local MenuVisible = false

-- Stockage ESP
local ESPObjects = {}
local ChamsFolder = Instance.new("Folder")
ChamsFolder.Name = "DipSikChams"
ChamsFolder.Parent = workspace

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = ShowFOV
FOVCircle.Radius = FOV
FOVCircle.Color = Color3.fromRGB(255, 50, 50)
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

-- Cible actuelle
local CurrentTarget = nil
local LastTargetTime = 0

-- Menu GUI maison
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DipSikMenu"
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

-- Frame principale
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 450, 0, 500)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = MenuVisible
MainFrame.Parent = ScreenGui

-- Titre
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
Title.Text = "Rush Point // DipSik's Covenant V3"
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Onglets
local TabsFrame = Instance.new("Frame")
TabsFrame.Name = "TabsFrame"
TabsFrame.Size = UDim2.new(1, 0, 0, 40)
TabsFrame.Position = UDim2.new(0, 0, 0, 40)
TabsFrame.BackgroundTransparency = 1
TabsFrame.Parent = MainFrame

local Tabs = {"Aimbot", "Visuals", "Misc"}
local TabButtons = {}
local CurrentTab = "Aimbot"

for i, tabName in ipairs(Tabs) do
    local TabButton = Instance.new("TextButton")
    TabButton.Name = tabName .. "Tab"
    TabButton.Size = UDim2.new(1/3, 0, 1, 0)
    TabButton.Position = UDim2.new((i-1)/3, 0, 0, 0)
    TabButton.BackgroundColor3 = tabName == "Aimbot" and Color3.fromRGB(40, 40, 60) or Color3.fromRGB(30, 30, 45)
    TabButton.Text = tabName
    TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabButton.TextSize = 14
    TabButton.Font = Enum.Font.Gotham
    TabButton.Parent = TabsFrame
    
    TabButton.MouseButton1Click:Connect(function()
        CurrentTab = tabName
        UpdateTabDisplay()
    end)
    
    TabButtons[tabName] = TabButton
end

-- Contenu
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -20, 1, -100)
ContentFrame.Position = UDim2.new(0, 10, 0, 90)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Fonction pour mettre à jour l'affichage des onglets
function UpdateTabDisplay()
    for tabName, button in pairs(TabButtons) do
        button.BackgroundColor3 = tabName == CurrentTab and Color3.fromRGB(40, 40, 60) or Color3.fromRGB(30, 30, 45)
    end
    
    -- Clear content
    for _, child in ipairs(ContentFrame:GetChildren()) do
        child:Destroy()
    end
    
    if CurrentTab == "Aimbot" then
        CreateAimbotTab()
    elseif CurrentTab == "Visuals" then
        CreateVisualsTab()
    elseif CurrentTab == "Misc" then
        CreateMiscTab()
    end
end

-- Widgets helper functions
local function CreateToggle(name, text, defaultValue, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = name .. "ToggleFrame"
    toggleFrame.Size = UDim2.new(1, 0, 0, 30)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.LayoutOrder = #ContentFrame:GetChildren()
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = name .. "Toggle"
    toggleButton.Size = UDim2.new(0, 20, 0, 20)
    toggleButton.Position = UDim2.new(0, 0, 0, 5)
    toggleButton.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
    toggleButton.Text = ""
    toggleButton.Parent = toggleFrame
    
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Name = name .. "Label"
    toggleLabel.Size = UDim2.new(1, -30, 1, 0)
    toggleLabel.Position = UDim2.new(0, 30, 0, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = text
    toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleLabel.TextSize = 14
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.Parent = toggleFrame
    
    local value = defaultValue
    
    toggleButton.MouseButton1Click:Connect(function()
        value = not value
        toggleButton.BackgroundColor3 = value and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
        callback(value)
    end)
    
    toggleFrame.Parent = ContentFrame
    return {Set = function(newValue) value = newValue; callback(newValue) end}
end

local function CreateSlider(name, text, min, max, defaultValue, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = name .. "SliderFrame"
    sliderFrame.Size = UDim2.new(1, 0, 0, 50)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.LayoutOrder = #ContentFrame:GetChildren()
    
    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Name = name .. "Label"
    sliderLabel.Size = UDim2.new(1, 0, 0, 20)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = text .. ": " .. defaultValue
    sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    sliderLabel.TextSize = 14
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    sliderLabel.Font = Enum.Font.Gotham
    sliderLabel.Parent = sliderFrame
    
    local slider = Instance.new("Frame")
    slider.Name = name .. "Slider"
    slider.Size = UDim2.new(1, 0, 0, 10)
    slider.Position = UDim2.new(0, 0, 0, 25)
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    slider.BorderSizePixel = 0
    slider.Parent = sliderFrame
    
    local fill = Instance.new("Frame")
    fill.Name = name .. "Fill"
    fill.Size = UDim2.new((defaultValue - min)/(max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    local value = defaultValue
    
    local function updateSlider(input)
        local relativeX = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * relativeX)
        fill.Size = UDim2.new(relativeX, 0, 1, 0)
        sliderLabel.Text = text .. ": " .. value
        callback(value)
    end
    
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSlider(input)
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    connection:Disconnect()
                else
                    updateSlider(input)
                end
            end)
        end
    end)
    
    sliderFrame.Parent = ContentFrame
    return {Set = function(newValue) value = newValue; callback(newValue) end}
end

-- Création des onglets
function CreateAimbotTab()
    CreateToggle("AimbotToggle", "Activer Aimbot", false, function(value)
        AimbotMode = value and "Toggle" or "Off"
        if not value then AimlockEnabled = false end
    end)
    
    local modeDropdown = Instance.new("Frame")
    modeDropdown.Name = "ModeDropdownFrame"
    modeDropdown.Size = UDim2.new(1, 0, 0, 60)
    modeDropdown.BackgroundTransparency = 1
    modeDropdown.LayoutOrder = #ContentFrame:GetChildren()
    
    local modeLabel = Instance.new("TextLabel")
    modeLabel.Text = "Mode Aimbot:"
    modeLabel.Size = UDim2.new(1, 0, 0, 20)
    modeLabel.BackgroundTransparency = 1
    modeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    modeLabel.TextSize = 14
    modeLabel.TextXAlignment = Enum.TextXAlignment.Left
    modeLabel.Font = Enum.Font.Gotham
    modeLabel.Parent = modeDropdown
    
    local modes = {"Toggle", "Hold", "Aimlock"}
    local currentMode = 1
    
    local function updateModeDisplay()
        modeLabel.Text = "Mode Aimbot: " .. modes[currentMode]
        AimbotMode = modes[currentMode]
        AimlockEnabled = modes[currentMode] == "Aimlock"
    end
    
    local prevButton = Instance.new("TextButton")
    prevButton.Text = "<"
    prevButton.Size = UDim2.new(0, 40, 0, 30)
    prevButton.Position = UDim2.new(0, 0, 0, 25)
    prevButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    prevButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    prevButton.Parent = modeDropdown
    
    local nextButton = Instance.new("TextButton")
    nextButton.Text = ">"
    nextButton.Size = UDim2.new(0, 40, 0, 30)
    nextButton.Position = UDim2.new(1, -40, 0, 25)
    nextButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    nextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    nextButton.Parent = modeDropdown
    
    prevButton.MouseButton1Click:Connect(function()
        currentMode = currentMode - 1
        if currentMode < 1 then currentMode = #modes end
        updateModeDisplay()
    end)
    
    nextButton.MouseButton1Click:Connect(function()
        currentMode = currentMode + 1
        if currentMode > #modes then currentMode = 1 end
        updateModeDisplay()
    end)
    
    updateModeDisplay()
    modeDropdown.Parent = ContentFrame
    
    CreateToggle("TeamCheckToggle", "Vérifier équipe", TeamCheck, function(value)
        TeamCheck = value
    end)
    
    CreateToggle("WallCheckToggle", "Wall Check", WallCheck, function(value)
        WallCheck = value
    end)
    
    CreateToggle("VisibleCheckToggle", "Vérifier visibilité", VisibleCheck, function(value)
        VisibleCheck = value
    end)
    
    CreateToggle("ShowFOVToggle", "Afficher FOV", ShowFOV, function(value)
        ShowFOV = value
        FOVCircle.Visible = value
    end)
    
    CreateSlider("FOVSlider", "FOV", 10, 500, FOV, function(value)
        FOV = value
    end)
    
    CreateSlider("SmoothSlider", "Smoothness", 1, 100, Smoothness * 100, function(value)
        Smoothness = value / 100
    end)
    
    local partFrame = Instance.new("Frame")
    partFrame.Name = "PartFrame"
    partFrame.Size = UDim2.new(1, 0, 0, 60)
    partFrame.BackgroundTransparency = 1
    partFrame.LayoutOrder = #ContentFrame:GetChildren()
    
    local partLabel = Instance.new("TextLabel")
    partLabel.Text = "Partie visée: " .. AimPart
    partLabel.Size = UDim2.new(1, 0, 0, 20)
    partLabel.BackgroundTransparency = 1
    partLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    partLabel.TextSize = 14
    partLabel.TextXAlignment = Enum.TextXAlignment.Left
    partLabel.Font = Enum.Font.Gotham
    partLabel.Parent = partFrame
    
    local parts = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "RightHand", "LeftHand"}
    local currentPart = 1
    
    for i, part in ipairs(parts) do
        if part == AimPart then currentPart = i end
    end
    
    local function updatePartDisplay()
        AimPart = parts[currentPart]
        partLabel.Text = "Partie visée: " .. AimPart
    end
    
    local partPrev = Instance.new("TextButton")
    partPrev.Text = "<"
    partPrev.Size = UDim2.new(0, 40, 0, 30)
    partPrev.Position = UDim2.new(0, 0, 0, 25)
    partPrev.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    partPrev.TextColor3 = Color3.fromRGB(255, 255, 255)
    partPrev.Parent = partFrame
    
    local partNext = Instance.new("TextButton")
    partNext.Text = ">"
    partNext.Size = UDim2.new(0, 40, 0, 30)
    partNext.Position = UDim2.new(1, -40, 0, 25)
    partNext.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    partNext.TextColor3 = Color3.fromRGB(255, 255, 255)
    partNext.Parent = partFrame
    
    partPrev.MouseButton1Click:Connect(function()
        currentPart = currentPart - 1
        if currentPart < 1 then currentPart = #parts end
        updatePartDisplay()
    end)
    
    partNext.MouseButton1Click:Connect(function()
        currentPart = currentPart + 1
        if currentPart > #parts then currentPart = 1 end
        updatePartDisplay()
    end)
    
    partFrame.Parent = ContentFrame
end

function CreateVisualsTab()
    CreateToggle("ESPToggle", "Activer ESP", ESPEnabled, function(value)
        ESPEnabled = value
    end)
    
    CreateToggle("BoxESToggle", "Boîtes ESP", true, function(value)
        for _, data in pairs(ESPObjects) do
            if data.Box then
                data.Box.Visible = value and ESPEnabled
            end
        end
    end)
    
    CreateToggle("TracerToggle", "Tracers ESP", false, function(value)
        for _, data in pairs(ESPObjects) do
            if data.Tracer then
                data.Tracer.Visible = value and ESPEnabled
            end
        end
    end)
    
    CreateSlider("ESPTransparency", "Transparence ESP", 0, 100, 50, function(value)
        for _, data in pairs(ESPObjects) do
            if data.Highlight then
                data.Highlight.FillTransparency = value / 100
            end
        end
    end)
end

function CreateMiscTab()
    local keyLabel = Instance.new("TextLabel")
    keyLabel.Text = "Touche Aimbot: " .. tostring(AimbotKey):gsub("Enum.KeyCode.", "")
    keyLabel.Size = UDim2.new(1, 0, 0, 30)
    keyLabel.BackgroundTransparency = 1
    keyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyLabel.TextSize = 14
    keyLabel.TextXAlignment = Enum.TextXAlignment.Left
    keyLabel.Font = Enum.Font.Gotham
    keyLabel.LayoutOrder = #ContentFrame:GetChildren()
    keyLabel.Parent = ContentFrame
    
    local keyButton = Instance.new("TextButton")
    keyButton.Text = "Changer touche"
    keyButton.Size = UDim2.new(0, 120, 0, 30)
    keyButton.Position = UDim2.new(0, 0, 0, 35)
    keyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    keyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyButton.Parent = ContentFrame
    
    local listening = false
    keyButton.MouseButton1Click:Connect(function()
        if not listening then
            listening = true
            keyButton.Text = "Appuie sur une touche..."
            keyButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            
            local connection
            connection = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    AimbotKey = input.KeyCode
                    keyLabel.Text = "Touche Aimbot: " .. tostring(AimbotKey):gsub("Enum.KeyCode.", "")
                    keyButton.Text = "Changer touche"
                    keyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
                    listening = false
                    connection:Disconnect()
                end
            end)
        end
    end)
    
    CreateToggle("CrosshairToggle", "Crosshair personnalisé", false, function(value)
        -- Crosshair à implémenter
    end)
    
    local refreshButton = Instance.new("TextButton")
    refreshButton.Text = "Refresh ESP"
    refreshButton.Size = UDim2.new(0, 120, 0, 30)
    refreshButton.Position = UDim2.new(0, 0, 0, 100)
    refreshButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    refreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    refreshButton.Parent = ContentFrame
    
    refreshButton.MouseButton1Click:Connect(function()
        for player, data in pairs(ESPObjects) do
            if data.Highlight then data.Highlight:Destroy() end
            if data.Box then data.Box:Remove() end
            if data.Tracer then data.Tracer:Remove() end
        end
        ESPObjects = {}
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                CreateESP(player)
            end
        end
    end)
end

-- Initialisation du menu
UpdateTabDisplay()

-- Fonctions de gameplay
function GetValidPlayers()
    local valid = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if TeamCheck and player.Team then
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

function RayCastCheck(origin, target, player)
    if not WallCheck then return true end
    
    local direction = (target - origin).Unit
    local distance = (target - origin).Magnitude
    local ray = Ray.new(origin, direction * distance)
    
    local ignoreList = {LocalPlayer.Character, Camera, ChamsFolder}
    local hit, position = Workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
    
    if hit then
        -- Vérifie si on a touché le joueur cible
        local model = hit:FindFirstAncestorOfClass("Model")
        return model and model == player.Character
    end
    
    return true
end

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
                    -- Vérifications
                    local visible = true
                    if VisibleCheck then
                        visible = RayCastCheck(Camera.CFrame.Position, part.Position, player)
                    end
                    
                    if visible then
                        closest = {Character = char, Part = part, Player = player, Distance = distance}
                        shortestDist = distance
                    end
                end
            end
        end
    end
    return closest
end

-- ESP system
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
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Thickness = 2
    box.Filled = false
    
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = Color3.fromRGB(255, 255, 0)
    tracer.Thickness = 1
    
    ESPObjects[player] = {
        Highlight = highlight,
        Box = box,
        Tracer = tracer
    }
end

function UpdateESP()
    for player, data in pairs(ESPObjects) do
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            
            -- Highlight
            if data.Highlight then
                data.Highlight.Adornee = ESPEnabled and player.Character or nil
                data.Highlight.Enabled = ESPEnabled
            end
            
            -- Box Drawing
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                if data.Box then
                    local scale = (hrp.Size.Y * 1.5) / (pos.Z * math.tan(math.rad(Camera.FieldOfView * 0.5)) * 2)
                    data.Box.Size = Vector2.new(scale * 2, scale * 3)
                    data.Box.Position = Vector2.new(pos.X - data.Box.Size.X/2, pos.Y - data.Box.Size.Y/2)
                    data.Box.Visible = ESPEnabled
                end
                
                -- Tracer
                if data.Tracer then
                    data.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    data.Tracer.To = Vector2.new(pos.X, pos.Y)
                    data.Tracer.Visible = ESPEnabled
                end
            else
                if data.Box then data.Box.Visible = false end
                if data.Tracer then data.Tracer.Visible = false end
            end
        else
            if data.Highlight then data.Highlight.Adornee = nil end
            if data.Box then data.Box.Visible = false end
            if data.Tracer then data.Tracer.Visible = false end
        end
    end
end

-- Aimbot core
local AimbotActive = false
local LastInputTime = 0

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == MenuKey then
        MenuVisible = not MenuVisible
        MainFrame.Visible = MenuVisible
        UserInputService.MouseIconEnabled = MenuVisible
    end
    
    if input.KeyCode == AimbotKey and AimbotMode == "Toggle" then
        AimbotActive = not AimbotActive
    end
    
    if input.KeyCode == AimbotKey and AimbotMode == "Hold" then
        AimbotActive = true
        LastInputTime = tick()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == AimbotKey and AimbotMode == "Hold" then
        AimbotActive = false
        CurrentTarget = nil
    end
end)

-- Main loop
RunService.RenderStepped:Connect(function()
    -- Update FOV circle
    FOVCircle.Radius = FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    -- Update ESP
    UpdateESP()
    
    -- Aimbot logic
    local shouldAim = false
    
    if AimbotMode == "Aimlock" and AimlockEnabled then
        shouldAim = true
    elseif AimbotMode == "Toggle" and AimbotActive then
        shouldAim = true
    elseif AimbotMode == "Hold" and AimbotActive then
        shouldAim = true
    end
    
    if shouldAim then
        -- Si pas de cible ou cible invalide, cherche en une nouvelle
        if not CurrentTarget or not CurrentTarget.Character or not CurrentTarget.Character:FindFirstChild(AimPart) or tick() - LastTargetTime > 1 then
            CurrentTarget = GetClosestTarget()
            if CurrentTarget then
                LastTargetTime = tick()
            end
        end
        
        -- Si on a une cible, vise
        if CurrentTarget and CurrentTarget.Part then
            local targetPos = CurrentTarget.Part.Position
            
            -- Prédiction de mouvement
            if CurrentTarget.Character:FindFirstChild("Humanoid") then
                local humanoid = CurrentTarget.Character.Humanoid
                targetPos = targetPos + (humanoid.MoveDirection * 0.15)
            end
            
            -- Vérification mur (optionnelle pendant le lock)
            if WallCheck and VisibleCheck then
                if not RayCastCheck(Camera.CFrame.Position, targetPos, CurrentTarget.Player) then
                    CurrentTarget = nil
                    return
                end
            end
            
            -- Smooth aiming
            local currentCF = Camera.CFrame
            local goalCF = CFrame.new(currentCF.Position, targetPos)
            Camera.CFrame = currentCF:Lerp(goalCF, 1 - Smoothness)
        else
            CurrentTarget = nil
        end
    else
        CurrentTarget = nil
    end
end)

-- Initialisation des joueurs
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
        if ESPObjects[player].Highlight then ESPObjects[player].Highlight:Destroy() end
        if ESPObjects[player].Box then ESPObjects[player].Box:Remove() end
        if ESPObjects[player].Tracer then ESPObjects[player].Tracer:Remove() end
        ESPObjects[player] = nil
    end
end)

-- Notifications
local function Notify(message)
    print("[DipSik's Covenant] " .. message)
end

Notify("Script chargé avec succès!")
Notify("Appuie sur INSERT pour le menu")
Notify("Mode Aimbot: Toggle/Hold/Aimlock")
Notify("Wall Check activé: " .. tostring(WallCheck))
