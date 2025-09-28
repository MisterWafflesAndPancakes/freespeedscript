return function()
    ---------------------------------------------------
    -- Advanced Speed 
    ---------------------------------------------------
    
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart")
    
    -- Remote events
    local strengthExercises = ReplicatedStorage:WaitForChild("Strength_Exercises")
    local punch1 = strengthExercises:WaitForChild("Punch_Bag1")
    local punch2 = strengthExercises:WaitForChild("Punch_Bag2")
    
    -- Bag references
    local bag1 = workspace:WaitForChild("Punch_Bag1")
    local bag2 = workspace:WaitForChild("Punch_Bag2")
    
    local torso1 = bag1:WaitForChild("Torso_Position")
    local torso2 = bag2:WaitForChild("Torso_Position")
    
    local inUse1 = bag1:WaitForChild("In_Use")
    local inUse2 = bag2:WaitForChild("In_Use")
    
    -- Player stats path
    local playerInfo = workspace:WaitForChild("Player_Information"):WaitForChild(player.Name)
    local statsFolder = playerInfo:WaitForChild("Stats")
    local speedFolder = statsFolder:WaitForChild("Speed")
    local speedLevel = speedFolder:WaitForChild("Level")
    local speedXP = speedFolder:WaitForChild("XP")
    
    ---------------------------------------------------
    -- CONFIG
    ---------------------------------------------------
    
    local STOP_LEVEL = 450 -- default, can be changed via TextBox
    
    ---------------------------------------------------
    -- GUI Setup (Arcade + Neon Blue)
    ---------------------------------------------------
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TrainingTracker"
    ScreenGui.Parent = game:GetService("CoreGui")
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 260, 0, 310)
    Frame.Position = UDim2.new(0.05, 0, 0.2, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
    Frame.BorderSizePixel = 2
    Frame.BorderColor3 = Color3.fromRGB(0, 200, 255)
    Frame.Active = true
    Frame.Draggable = false
    Frame.Parent = ScreenGui
    
    -- Drag function (PC + Mobile)
    do
        local dragging, dragInput, dragStart, startPos
        local function update(input)
            local delta = input.Position - dragStart
            Frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
        Frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = Frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        Frame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                update(input)
            end
        end)
    end
    
    local function makeLabel(yPos, text, color, size)
        local lbl = Instance.new("TextLabel")
        lbl.Position = UDim2.new(0, 0, 0, yPos)
        lbl.Size = UDim2.new(1, 0, 0, 20)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = color or Color3.fromRGB(0, 200, 255)
        lbl.Font = Enum.Font.Arcade
        lbl.TextSize = size or 18
        lbl.Text = text
        lbl.Parent = Frame
        return lbl
    end
    
    local Title = makeLabel(5, "⚡ Advanced Speed! ⚡", Color3.fromRGB(0, 255, 255), 22)
    local SpeedLabel = makeLabel(40, "Speed Level: ...")
    local XPLabel = makeLabel(65, "Speed XP: ...", Color3.fromRGB(0, 255, 200))
    local ToxicLabel = makeLabel(90, "Toxic Shakes: ...", Color3.fromRGB(0, 180, 255))
    local StatusLabel = makeLabel(115, "Status: Idle", Color3.fromRGB(0, 255, 255))
    
    -- Stop level input
    local StopBox = Instance.new("TextBox")
    StopBox.Position = UDim2.new(0.1, 0, 0, 140)
    StopBox.Size = UDim2.new(0.8, 0, 0, 25)
    StopBox.BackgroundColor3 = Color3.fromRGB(0, 20, 40)
    StopBox.BorderSizePixel = 2
    StopBox.BorderColor3 = Color3.fromRGB(0, 200, 255)
    StopBox.TextColor3 = Color3.fromRGB(0, 255, 255)
    StopBox.PlaceholderText = "Stop Level"
    StopBox.Font = Enum.Font.Arcade
    StopBox.TextSize = 18
    StopBox.Text = ""
    StopBox.Parent = Frame
    
    -- Training toggle button
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Position = UDim2.new(0.1, 0, 0, 170)
    ToggleButton.Size = UDim2.new(0.8, 0, 0, 30)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 40, 80)
    ToggleButton.BorderSizePixel = 2
    ToggleButton.BorderColor3 = Color3.fromRGB(0, 200, 255)
    ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 255)
    ToggleButton.Text = "Start Training"
    ToggleButton.Font = Enum.Font.Arcade
    ToggleButton.TextSize = 20
    ToggleButton.Parent = Frame
    
    -- Drink Shake toggle button
    local DrinkToggle = Instance.new("TextButton")
    DrinkToggle.Position = UDim2.new(0.1, 0, 0, 205)
    DrinkToggle.Size = UDim2.new(0.8, 0, 0, 30)
    DrinkToggle.BackgroundColor3 = Color3.fromRGB(0, 40, 80)
    DrinkToggle.BorderSizePixel = 2
    DrinkToggle.BorderColor3 = Color3.fromRGB(0, 200, 255)
    DrinkToggle.TextColor3 = Color3.fromRGB(0, 255, 255)
    DrinkToggle.Text = "Start Toxic Shake"
    DrinkToggle.Font = Enum.Font.Arcade
    DrinkToggle.TextSize = 18
    DrinkToggle.Parent = Frame
    
    -- Anti-AFK button
    local AntiAFKButton = Instance.new("TextButton")
    AntiAFKButton.Position = UDim2.new(0.1, 0, 0, 240)
    AntiAFKButton.Size = UDim2.new(0.8, 0, 0, 30)
    AntiAFKButton.BackgroundColor3 = Color3.fromRGB(0, 40, 80)
    AntiAFKButton.BorderSizePixel = 2
    AntiAFKButton.BorderColor3 = Color3.fromRGB(0, 200, 255)
    AntiAFKButton.TextColor3 = Color3.fromRGB(0, 255, 255)
    AntiAFKButton.Text = "Enable Anti-AFK"
    AntiAFKButton.Font = Enum.Font.Arcade
    AntiAFKButton.TextSize = 18
    AntiAFKButton.Parent = Frame
    
    -- Kick on Stop toggle button
    local KickToggle = Instance.new("TextButton")
    KickToggle.Position = UDim2.new(0.1, 0, 0, 275)
    KickToggle.Size = UDim2.new(0.8, 0, 0, 25)
    KickToggle.BackgroundColor3 = Color3.fromRGB(0, 40, 80)
    KickToggle.BorderSizePixel = 2
    KickToggle.BorderColor3 = Color3.fromRGB(0, 200, 255)
    KickToggle.TextColor3 = Color3.fromRGB(0, 255, 255)
    KickToggle.Text = "[ ] Kick on Stop"
    KickToggle.Font = Enum.Font.Arcade
    KickToggle.TextSize = 16
    KickToggle.Parent = Frame
    
    local kickOnStop = false
    KickToggle.MouseButton1Click:Connect(function()
        kickOnStop = not kickOnStop
        if kickOnStop then
            KickToggle.Text = "[X] Kick on Stop"
            KickToggle.BackgroundColor3 = Color3.fromRGB(0, 80, 160)
        else
            KickToggle.Text = "[ ] Kick on Stop"
            KickToggle.BackgroundColor3 = Color3.fromRGB(0, 40, 80)
        end
    end)
    
    ---------------------------------------------------
    -- GUI Update Logic
    ---------------------------------------------------
    
    local function updateGUI()
        SpeedLabel.Text = "Speed Level: " .. tostring(speedLevel.Value)
        XPLabel.Text = "Speed XP: " .. tostring(speedXP.Value)
    
        -- Count how many "T" instances exist under Drinks
        local drinksFolder = playerInfo:WaitForChild("Inventory"):WaitForChild("Drinks")
        local count = 0
        for _, item in ipairs(drinksFolder:GetChildren()) do
            if item.Name == "T" then
                count += 1
            end
        end
        ToxicLabel.Text = "Toxic Shakes: " .. tostring(count)
    end
    
    -- Hook updates
    speedLevel.Changed:Connect(updateGUI)
    speedXP.Changed:Connect(updateGUI)
    playerInfo.Inventory.Drinks.ChildAdded:Connect(updateGUI)
    playerInfo.Inventory.Drinks.ChildRemoved:Connect(updateGUI)
    
    -- Initial draw
    updateGUI()
    
    ---------------------------------------------------
    -- Helper: Wait Until Free With Timeout
    ---------------------------------------------------
    
    local function waitUntilFreeWithTimeout(inUseValue, bagName, timeout)
        local start = tick()
        while inUseValue.Value and training do
            StatusLabel.Text = "Status: Waiting for " .. bagName
            task.wait(0.2)
            if tick() - start > timeout then
                StatusLabel.Text = "Status: Timeout on " .. bagName .. ", skipping..."
                return false
            end
        end
        return training
    end
    
    ---------------------------------------------------
    -- Training Loop (with Kick on Stop option)
    ---------------------------------------------------

    local function trainingLoop()
        while training do
            -- Stop check
            if speedLevel.Value >= STOP_LEVEL then
                training = false
                ToggleButton.Text = "Start Training"
                ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 40, 80)
                StatusLabel.Text = "Status: Reached Level " .. STOP_LEVEL
                if kickOnStop then
                    Players.LocalPlayer:Kick("Reached Speed Level " .. STOP_LEVEL .. " — training stopped.")
                end
                break
            end
    
            -------------------
            -- Bag1 cycle
            -------------------
            -- Wait until Bag1 is free
            repeat task.wait() until not inUse1.Value or not training
            if not training then break end
    
            -- Teleport + punch once
            root.CFrame = torso1.CFrame * CFrame.new(0,0,-3)
            pcall(function() punch1:FireServer() end)
            StatusLabel.Text = "Status: Training Bag1"
    
            -- Wait until Bag1 finishes (goes false again)
            repeat task.wait() until not inUse1.Value or not training
            task.wait(0.5)
    
            if not training then break end
    
            -------------------
            -- Bag2 cycle
            -------------------
            -- Wait until Bag2 is free
            repeat task.wait() until not inUse2.Value or not training
            if not training then break end
    
            -- Teleport + punch once
            root.CFrame = torso2.CFrame * CFrame.new(0,0,-3)
            pcall(function() punch2:FireServer() end)
            StatusLabel.Text = "Status: Training Bag2"
    
            -- Wait until Bag2 finishes (goes false again)
            repeat task.wait() until not inUse2.Value or not training
            task.wait(0.5)
        end
    end
    
    ---------------------------------------------------
    -- Training Toggle Button Logic
    ---------------------------------------------------
    
    ToggleButton.MouseButton1Click:Connect(function()
        local val = tonumber(StopBox.Text)
        if val then STOP_LEVEL = val end
    
        training = not training
        if training then
            ToggleButton.Text = "Stop Training"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 80, 160)
            StatusLabel.Text = "Status: Starting..."
            task.spawn(trainingLoop)
        else
            ToggleButton.Text = "Start Training"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 40, 80)
            StatusLabel.Text = "Status: Idle"
        end
    end)
    
    ---------------------------------------------------
    -- Drink Shake Toggle
    ---------------------------------------------------
    
    local shakeActive = false
    local function shakeLoop()
        while shakeActive do
            game.ReplicatedStorage["Drink_Shake"]:InvokeServer("Toxic")
            task.wait(1) -- adjust delay if you want faster/slower shakes
        end
    end
    
    DrinkToggle.MouseButton1Click:Connect(function()
        shakeActive = not shakeActive
        if shakeActive then
            DrinkToggle.Text = "Stop Toxic Shake"
            DrinkToggle.BackgroundColor3 = Color3.fromRGB(0, 80, 160)
            task.spawn(shakeLoop)
        else
            DrinkToggle.Text = "Start Toxic Shake"
            DrinkToggle.BackgroundColor3 = Color3.fromRGB(0, 40, 80)
        end
    end)
    
    ---------------------------------------------------
    -- Anti-AFK Button
    ---------------------------------------------------
    
    AntiAFKButton.MouseButton1Click:Connect(function()
        local VirtualUser = game:service("VirtualUser")
        game:service("Players").LocalPlayer.Idled:connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
        AntiAFKButton.Text = "Anti-AFK Enabled"
        AntiAFKButton.BackgroundColor3 = Color3.fromRGB(0, 80, 160)
        AntiAFKButton.Active = false -- disable further presses
    end)
end
