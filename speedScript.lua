-- Smart Speed Training GUI (Arcade + Neon Blue + In_Use logic)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
local toxicShakes = playerInfo:WaitForChild("Inventory"):WaitForChild("Drinks"):WaitForChild("T")

---------------------------------------------------
-- GUI Setup (Arcade + Neon Blue)
---------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TrainingTracker"
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 260, 0, 160)
Frame.Position = UDim2.new(0.05, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
Frame.BorderSizePixel = 2
Frame.BorderColor3 = Color3.fromRGB(0, 200, 255)
Frame.Parent = ScreenGui

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

local Title = makeLabel(5, "⚡ Training Tracker", Color3.fromRGB(0, 255, 255), 22)
local SpeedLabel = makeLabel(40, "Speed Level: ...")
local XPLabel = makeLabel(65, "Speed XP: ...", Color3.fromRGB(0, 255, 200))
local ToxicLabel = makeLabel(90, "Toxic Shakes: ...", Color3.fromRGB(0, 180, 255))

-- Toggle button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Position = UDim2.new(0.1, 0, 0, 120)
ToggleButton.Size = UDim2.new(0.8, 0, 0, 30)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 40, 80)
ToggleButton.BorderSizePixel = 2
ToggleButton.BorderColor3 = Color3.fromRGB(0, 200, 255)
ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 255)
ToggleButton.Text = "Start Training"
ToggleButton.Font = Enum.Font.Arcade
ToggleButton.TextSize = 20
ToggleButton.Parent = Frame

---------------------------------------------------
-- GUI Update Logic
---------------------------------------------------
local function updateGUI()
    SpeedLabel.Text = "Speed Level: " .. tostring(speedLevel.Value)
    XPLabel.Text = "Speed XP: " .. tostring(speedXP.Value)
    ToxicLabel.Text = "Toxic Shakes: " .. tostring(toxicShakes.Value)
end

speedLevel.Changed:Connect(updateGUI)
speedXP.Changed:Connect(updateGUI)
toxicShakes.Changed:Connect(updateGUI)
updateGUI()

---------------------------------------------------
-- Smart Training Loop (respects In_Use)
---------------------------------------------------
local training = false

local function waitUntilFree(inUseValue)
    while inUseValue.Value and training do
        task.wait(0.2)
    end
end

local function trainingLoop()
    while training do
        -- Try Bag1
        if not inUse1.Value then
            root.CFrame = torso1.CFrame
            punch1:FireServer()
            waitUntilFree(inUse1)
            task.wait(0.5)
        end

        -- Try Bag2
        if not inUse2.Value then
            root.CFrame = torso2.CFrame
            punch2:FireServer()
            waitUntilFree(inUse2)
            task.wait(0.5)
        end
    end
end

ToggleButton.MouseButton1Click:Connect(function()
    training = not training
    if training then
        ToggleButton.Text = "Stop Training"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 80, 160)
        task.spawn(trainingLoop)
    else
        ToggleButton.Text = "Start Training"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 40, 80)
    end
end)
