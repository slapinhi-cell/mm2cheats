local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService") 
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local espEnabled = true
local gunGetEnabled = true
local killEnabled = false
local flingEnabled = false
local selectedPlayer = nil

local walkSpeedValue = 16
local jumpPowerValue = 50
local flingRadius = 8

------------------------------------------
-- СИСТЕМА УВЕДОМЛЕНИЙ (Левый нижний угол)
------------------------------------------
local notifyGui = Instance.new("ScreenGui")
notifyGui.Name = "UtilityNotifications"
local nSuccess, _ = pcall(function() notifyGui.Parent = CoreGui end)
if not nSuccess then notifyGui.Parent = localPlayer:WaitForChild("PlayerGui") end

local notifyContainer = Instance.new("Frame")
notifyContainer.Size = UDim2.new(0, 300, 0, 300)
notifyContainer.Position = UDim2.new(0, 15, 1, -15)
notifyContainer.AnchorPoint = Vector2.new(0, 1)
notifyContainer.BackgroundTransparency = 1
notifyContainer.Parent = notifyGui

local notifyLayout = Instance.new("UIListLayout")
notifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifyLayout.Padding = UDim.new(0, 6)
notifyLayout.Parent = notifyContainer

local function showNotification(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 40)
    label.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    label.BackgroundTransparency = 0.05
    label.Text = "  " .. text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 20
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = notifyContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = label
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1
    stroke.Parent = label

    task.delay(3, function()
        TweenService:Create(label, TweenInfo.new(0.4), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.4), {Transparency = 1}):Play()
        task.wait(0.4)
        label:Destroy()
    end)
end

------------------------------------------
-- ГЛАВНЫЙ ФРЕЙМ МЕНЮ
------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UtilityGui"
local success, _ = pcall(function() screenGui.Parent = CoreGui end)
if not success then screenGui.Parent = localPlayer:WaitForChild("PlayerGui") end

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainPanel"
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.Active = true
mainFrame.Draggable = false
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = mainFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(255, 255, 255)
frameStroke.Thickness = 1.5
frameStroke.Parent = mainFrame

------------------------------------------
-- ШАПКА ДЛЯ ПЕРЕМЕЩЕНИЯ
------------------------------------------
local topBar = Instance.new("Frame")
topBar.Name = "TopDragBar"
topBar.Size = UDim2.new(1, 0, 0, 32)
topBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
topBar.Parent = mainFrame

local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 12)
topBarCorner.Parent = topBar

local topBarTitle = Instance.new("TextLabel")
topBarTitle.Size = UDim2.new(1, -10, 1, 0)
topBarTitle.Position = UDim2.new(0, 10, 0, 0)
topBarTitle.BackgroundTransparency = 1
topBarTitle.Text = "UTILITY PANEL"
topBarTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
topBarTitle.Font = Enum.Font.GothamBold
topBarTitle.TextSize = 15
topBarTitle.TextXAlignment = Enum.TextXAlignment.Left
topBarTitle.Parent = topBar

-- Drag
local dragging, dragInput, dragStart, startPos
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
topBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local targetSize = UDim2.new(0, 480, 0, 400)
TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = targetSize}):Play()

------------------------------------------
-- БОКОВАЯ ПАНЕЛЬ (ТАБЫ)
------------------------------------------
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 100, 1, -32)
sidebar.Position = UDim2.new(0, 0, 0, 32)
sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
sidebar.Parent = mainFrame

local sideCorner = Instance.new("UICorner")
sideCorner.CornerRadius = UDim.new(0, 12)
sideCorner.Parent = sidebar

local function createTabBtn(name, pos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 86, 0, 40)
    btn.Position = UDim2.new(0.5, -43, 0, pos)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.Parent = sidebar
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = btn
    
    -- Hover
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
    end)
    return btn
end

local mainTabBtn = createTabBtn("MAIN", 12)
local funTabBtn = createTabBtn("FUN", 62)
local miscTabBtn = createTabBtn("MISC", 112)

------------------------------------------
-- КОНТЕНТНЫЕ ОБЛАСТИ
------------------------------------------
local container = Instance.new("Frame")
container.Name = "Container"
container.Position = UDim2.new(0, 115, 0, 42)
container.Size = UDim2.new(1, -130, 1, -56)
container.BackgroundTransparency = 1
container.Parent = mainFrame

local mainPage = Instance.new("Frame")
mainPage.Size = UDim2.new(1, 0, 1, 0)
mainPage.BackgroundTransparency = 1
mainPage.Visible = true
mainPage.Parent = container

local funPage = Instance.new("Frame")
funPage.Size = UDim2.new(1, 0, 1, 0)
funPage.BackgroundTransparency = 1
funPage.Visible = false
funPage.Parent = container

local miscPage = Instance.new("Frame")
miscPage.Size = UDim2.new(1, 0, 1, 0)
miscPage.BackgroundTransparency = 1
miscPage.Visible = false
miscPage.Parent = container

mainTabBtn.MouseButton1Click:Connect(function()
    mainPage.Visible = true
    funPage.Visible = false
    miscPage.Visible = false
    showNotification("Main")
end)

funTabBtn.MouseButton1Click:Connect(function()
    mainPage.Visible = false
    funPage.Visible = true
    miscPage.Visible = false
    showNotification("Fun")
end)

miscTabBtn.MouseButton1Click:Connect(function()
    mainPage.Visible = false
    funPage.Visible = false
    miscPage.Visible = true
    showNotification("Misc")
end)

------------------------------------------
-- ВКЛАДКА MAIN
------------------------------------------
local function createMainBtn(text, pos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 42)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.TextColor3 = Color3.fromRGB(0, 0, 0)
    btn.Parent = mainPage
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(220, 220, 220)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    end)
    
    btn.MouseButton1Click:Connect(function() callback(btn) end)
    return btn
end

createMainBtn("ESP: ON", UDim2.new(0, 5, 0, 0), function(btn)
    espEnabled = not espEnabled
    btn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
    showNotification(espEnabled and "ESP ON" or "ESP OFF")
    if not espEnabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then 
                local h = p.Character:FindFirstChildOfClass("Highlight")
                if h then h:Destroy() end
            end
        end
    end
end)

createMainBtn("AUTOKILL: OFF", UDim2.new(0, 5, 0, 50), function(btn)
    killEnabled = not killEnabled
    btn.Text = killEnabled and "AUTOKILL: ON" or "AUTOKILL: OFF"
    showNotification(killEnabled and "AUTOKILL ON" or "AUTOKILL OFF")
end)

createMainBtn("AUTO GUN: ON", UDim2.new(0, 5, 0, 100), function(btn)
    gunGetEnabled = not gunGetEnabled
    btn.Text = gunGetEnabled and "AUTO GUN: ON" or "AUTO GUN: OFF"
    showNotification(gunGetEnabled and "AUTO GUN ON" or "AUTO GUN OFF")
end)

local function createSmallSlider(labelTxt, pos, min, max, def, callback)
    local lab = Instance.new("TextLabel")
    lab.Size = UDim2.new(1, -10, 0, 22)
    lab.Position = pos
    lab.Text = labelTxt .. ": " .. def
    lab.TextColor3 = Color3.fromRGB(200, 200, 200)
    lab.Font = Enum.Font.GothamMedium
    lab.TextSize = 16
    lab.BackgroundTransparency = 1
    lab.TextXAlignment = Enum.TextXAlignment.Left
    lab.Parent = mainPage

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, -10, 0, 4)
    bg.Position = pos + UDim2.new(0, 0, 0, 26)
    bg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    bg.Parent = mainPage
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 2)
    bgCorner.Parent = bg
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((def-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    fill.Parent = bg
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 2)
    fillCorner.Parent = fill

    local activeConnection
    bg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if activeConnection then activeConnection:Disconnect() end
            
            local function updateValue(moveInput)
                local per = math.clamp((moveInput.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max-min)*per)
                fill.Size = UDim2.new(per, 0, 1, 0)
                lab.Text = labelTxt .. ": " .. val
                callback(val)
            end
            
            updateValue(input)
            
            activeConnection = UserInputService.InputChanged:Connect(function(moveInput)
                if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                    updateValue(moveInput)
                end
            end)
            
            local endConnection
            endConnection = UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                    if activeConnection then activeConnection:Disconnect() end
                    endConnection:Disconnect()
                    showNotification(labelTxt .. ": " .. lab.Text:match("%d+"))
                end
            end)
        end
    end)
end

createSmallSlider("SPEED", UDim2.new(0, 5, 0, 160), 1, 100, walkSpeedValue, function(v) walkSpeedValue = v end)
createSmallSlider("JUMP", UDim2.new(0, 5, 0, 210), 1, 100, jumpPowerValue, function(v) jumpPowerValue = v end)

------------------------------------------
-- ВКЛАДКА FUN
------------------------------------------
local selectedLabel = Instance.new("TextLabel")
selectedLabel.Size = UDim2.new(1, -10, 0, 26)
selectedLabel.Position = UDim2.new(0, 5, 0, 0)
selectedLabel.Text = "TARGET: NONE"
selectedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
selectedLabel.BackgroundTransparency = 1
selectedLabel.Font = Enum.Font.GothamBold
selectedLabel.TextSize = 16
selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
selectedLabel.Parent = funPage

local playerListFrame = Instance.new("ScrollingFrame")
playerListFrame.Size = UDim2.new(1, -10, 0, 150)
playerListFrame.Position = UDim2.new(0, 5, 0, 32)
playerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
playerListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
playerListFrame.BorderSizePixel = 0
playerListFrame.Parent = funPage
local plCorner = Instance.new("UICorner")
plCorner.CornerRadius = UDim.new(0, 6)
plCorner.Parent = playerListFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = playerListFrame

local function updatePlayerList()
    for _, child in pairs(playerListFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local count = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p == localPlayer then continue end
        count = count + 1
        local pBtn = Instance.new("TextButton")
        pBtn.Size = UDim2.new(1, 0, 0, 32)
        pBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        pBtn.Text = p.DisplayName
        pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        pBtn.Font = Enum.Font.GothamMedium
        pBtn.TextSize = 16
        pBtn.TextXAlignment = Enum.TextXAlignment.Center
        pBtn.Parent = playerListFrame
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = pBtn
        
        pBtn.MouseEnter:Connect(function()
            TweenService:Create(pBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
        end)
        pBtn.MouseLeave:Connect(function()
            TweenService:Create(pBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
        end)
        
        pBtn.MouseButton1Click:Connect(function()
            selectedPlayer = p
            selectedLabel.Text = "TARGET: " .. p.Name
            showNotification("TARGET: " .. p.Name)
        end)
    end
    playerListFrame.CanvasSize = UDim2.new(0, 0, 0, count * 36)
end

updatePlayerList()
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(function(p)
    if selectedPlayer == p then
        selectedPlayer = nil
        selectedLabel.Text = "TARGET: NONE"
        flingEnabled = false
    end
    updatePlayerList()
end)

local flingBtn = Instance.new("TextButton")
flingBtn.Size = UDim2.new(1, -10, 0, 42)
flingBtn.Position = UDim2.new(0, 5, 0, 192)
flingBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
flingBtn.Text = "FLING: OFF"
flingBtn.Font = Enum.Font.GothamBold
flingBtn.TextSize = 18
flingBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
flingBtn.Parent = funPage
local fc = Instance.new("UICorner")
fc.CornerRadius = UDim.new(0, 6)
fc.Parent = flingBtn

flingBtn.MouseEnter:Connect(function()
    TweenService:Create(flingBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(220, 220, 220)}):Play()
end)
flingBtn.MouseLeave:Connect(function()
    TweenService:Create(flingBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
end)

flingBtn.MouseButton1Click:Connect(function()
    if not selectedPlayer then 
        showNotification("SELECT A PLAYER FIRST")
        return 
    end
    flingEnabled = not flingEnabled
    flingBtn.Text = flingEnabled and "FLING: ON" or "FLING: OFF"
    showNotification(flingEnabled and "FLING ON" or "FLING OFF")
end)

-- Fling Radius Slider
local radiusLab = Instance.new("TextLabel")
radiusLab.Size = UDim2.new(1, -10, 0, 22)
radiusLab.Position = UDim2.new(0, 5, 0, 240)
radiusLab.Text = "FLING RADIUS: " .. flingRadius
radiusLab.TextColor3 = Color3.fromRGB(200, 200, 200)
radiusLab.Font = Enum.Font.GothamMedium
radiusLab.TextSize = 16
radiusLab.BackgroundTransparency = 1
radiusLab.TextXAlignment = Enum.TextXAlignment.Left
radiusLab.Parent = funPage

local radiusBg = Instance.new("Frame")
radiusBg.Size = UDim2.new(1, -10, 0, 4)
radiusBg.Position = UDim2.new(0, 5, 0, 266)
radiusBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
radiusBg.Parent = funPage
local rbgCorner = Instance.new("UICorner")
rbgCorner.CornerRadius = UDim.new(0, 2)
rbgCorner.Parent = radiusBg

local radiusFill = Instance.new("Frame")
radiusFill.Size = UDim2.new((flingRadius-2)/(30-2), 0, 1, 0)
radiusFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
radiusFill.Parent = radiusBg
local rfillCorner = Instance.new("UICorner")
rfillCorner.CornerRadius = UDim.new(0, 2)
rfillCorner.Parent = radiusFill

local function updateRadius(val)
    flingRadius = val
    radiusLab.Text = "FLING RADIUS: " .. val
    radiusFill.Size = UDim2.new((val-2)/(30-2), 0, 1, 0)
end

local activeConnR
radiusBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if activeConnR then activeConnR:Disconnect() end
        local function update(move)
            local per = math.clamp((move.Position.X - radiusBg.AbsolutePosition.X) / radiusBg.AbsoluteSize.X, 0, 1)
            local val = math.floor(2 + (30-2)*per)
            updateRadius(val)
        end
        update(input)
        activeConnR = UserInputService.InputChanged:Connect(function(move)
            if move.UserInputType == Enum.UserInputType.MouseMovement or move.UserInputType == Enum.UserInputType.Touch then
                update(move)
            end
        end)
        local endConn
        endConn = UserInputService.InputEnded:Connect(function(endInput)
            if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                if activeConnR then activeConnR:Disconnect() end
                endConn:Disconnect()
                showNotification("FLING RADIUS: " .. flingRadius)
            end
        end)
    end
end)

------------------------------------------
-- ВКЛАДКА MISC
------------------------------------------
local function createMiscBtn(text, pos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 42)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.TextColor3 = Color3.fromRGB(0, 0, 0)
    btn.Parent = miscPage
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(220, 220, 220)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    end)
    
    btn.MouseButton1Click:Connect(function() callback(btn) end)
    return btn
end

local infiniteJumpEnabled = false
local noClipEnabled = false
local antiAfkEnabled = false

createMiscBtn("INFINITE JUMP: OFF", UDim2.new(0, 5, 0, 0), function(btn)
    infiniteJumpEnabled = not infiniteJumpEnabled
    btn.Text = infiniteJumpEnabled and "INFINITE JUMP: ON" or "INFINITE JUMP: OFF"
    showNotification(infiniteJumpEnabled and "INFINITE JUMP ON" or "INFINITE JUMP OFF")
end)

createMiscBtn("NOCLIP: OFF", UDim2.new(0, 5, 0, 50), function(btn)
    noClipEnabled = not noClipEnabled
    btn.Text = noClipEnabled and "NOCLIP: ON" or "NOCLIP: OFF"
    showNotification(noClipEnabled and "NOCLIP ON" or "NOCLIP OFF")
    local char = localPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not noClipEnabled
            end
        end
    end
end)

createMiscBtn("ANTI-AFK: OFF", UDim2.new(0, 5, 0, 100), function(btn)
    antiAfkEnabled = not antiAfkEnabled
    btn.Text = antiAfkEnabled and "ANTI-AFK: ON" or "ANTI-AFK: OFF"
    showNotification(antiAfkEnabled and "ANTI-AFK ON" or "ANTI-AFK OFF")
end)

------------------------------------------
-- СКРЫТИЕ ПО CTRL
------------------------------------------
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftControl then
        mainFrame.Visible = not mainFrame.Visible
        showNotification(mainFrame.Visible and "MENU SHOW" or "MENU HIDDEN")
    end
end)

------------------------------------------
-- ОСНОВНОЙ ЦИКЛ
------------------------------------------
task.spawn(function()
    while task.wait(0.1) do
        local char = localPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = walkSpeedValue
                hum.JumpPower = jumpPowerValue
                hum.UseJumpPower = true
            end

            if noClipEnabled then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end

        if espEnabled then
            for _, p in pairs(Players:GetPlayers()) do
                if p == localPlayer then continue end
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local h = p.Character:FindFirstChildOfClass("Highlight") or Instance.new("Highlight", p.Character)
                    h.FillTransparency = 0.5
                    local backpack = p:FindFirstChild("Backpack")
                    local isK = (backpack and backpack:FindFirstChild("Knife")) or p.Character:FindFirstChild("Knife")
                    local isG = (backpack and backpack:FindFirstChild("Gun")) or p.Character:FindFirstChild("Gun")
                    h.FillColor = isK and Color3.new(1,0,0) or (isG and Color3.new(0,0,1) or Color3.new(0,1,0))
                end
            end
        end

        if gunGetEnabled and not flingEnabled and not killEnabled then
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                for _, v in pairs(workspace:GetChildren()) do
                    if v:IsA("Model") and v:FindFirstChild("GunDrop") then
                        v.GunDrop.Position = root.Position
                    end
                end
            end
        end
    end
end)

------------------------------------------
-- FLING CYCLE
------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.1)
        if flingEnabled and selectedPlayer and selectedPlayer.Character and localPlayer.Character then
            local targetRoot = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
            local myRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
            local myHum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
            
            if targetRoot and myRoot then
                if myHum then myHum.Sit = false end
                myRoot.CanCollide = false
                
                local angle = math.random() * 2 * math.pi
                local radius = flingRadius * (0.8 + 0.4 * math.random())
                local offsetX = math.sin(angle) * radius
                local offsetZ = math.cos(angle) * radius
                local offsetY = math.random(-3, 3)
                
                myRoot.CFrame = targetRoot.CFrame * CFrame.new(offsetX, offsetY, offsetZ)
            end
        end
    end
end)

------------------------------------------
-- INFINITE JUMP
------------------------------------------
local jumpBodyVelocity = nil
task.spawn(function()
    while true do
        task.wait(0.05)
        if infiniteJumpEnabled and localPlayer.Character then
            local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum:GetState() ~= Enum.HumanoidStateType.Dead then
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    if hum:GetState() == Enum.HumanoidStateType.Jumping or hum:GetState() == Enum.HumanoidStateType.Freefall then
                        if not jumpBodyVelocity or jumpBodyVelocity.Parent == nil then
                            jumpBodyVelocity = Instance.new("BodyVelocity")
                            jumpBodyVelocity.MaxForce = Vector3.new(0, 1e7, 0)
                            jumpBodyVelocity.Velocity = Vector3.new(0, 30, 0)
                            jumpBodyVelocity.Parent = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                            task.delay(0.1, function()
                                if jumpBodyVelocity then jumpBodyVelocity:Destroy() end
                            end)
                        end
                    end
                end
            end
        else
            if jumpBodyVelocity then
                jumpBodyVelocity:Destroy()
                jumpBodyVelocity = nil
            end
        end
    end
end)

------------------------------------------
-- ANTI-AFK
------------------------------------------
task.spawn(function()
    while true do
        task.wait(10)
        if antiAfkEnabled and localPlayer.Character then
            local root = localPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local oldCF = root.CFrame
                root.CFrame = oldCF * CFrame.new(0.1, 0, 0)
                task.wait(0.1)
                root.CFrame = oldCF
            end
        end
    end
end)

------------------------------------------
-- AUTOKILL
------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.2)
        if killEnabled and not flingEnabled then
            local myChar = localPlayer.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local knife = myChar and myChar:FindFirstChild("Knife")
            
            if myRoot and knife then
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= localPlayer and p.Character then
                        local tRoot = p.Character:FindFirstChild("HumanoidRootPart")
                        local tHum = p.Character:FindFirstChildOfClass("Humanoid")
                        
                        if tRoot and tHum and tHum.Health > 0 and killEnabled and not flingEnabled then
                            myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 1.5)
                            knife:Activate()
                            task.wait(0.15) 
                        end
                    end
                end
            end
        end
    end
end)

showNotification("LOADED | CTRL TO TOGGLE")