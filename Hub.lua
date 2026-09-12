-- Safe mobile clean up of any running instance under PlayerGui
local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
if PlayerGui:FindFirstChild("TrollHubUI") then
    PlayerGui.TrollHubUI:Destroy()
end

-- Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Global States
getgenv().AntiFling = false
getgenv().FlingTarget = ""
getgenv().LoopFling = false
local walkSpeedValue = 100 

-- Create ScreenGui directly into PlayerGui (Delta Android/iOS Safe Zone)
local TrollHubUI = Instance.new("ScreenGui")
TrollHubUI.Name = "TrollHubUI"
TrollHubUI.Parent = PlayerGui
TrollHubUI.ResetOnSpawn = false

-- Open/Close Top Banner Button
local MainToggle = Instance.new("TextButton")
MainToggle.Name = "MainToggle"
MainToggle.Parent = TrollHubUI
MainToggle.Size = UDim2.new(0, 130, 0, 35)
MainToggle.Position = UDim2.new(0.02, 0, 0.2, 0)
MainToggle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
MainToggle.Font = Enum.Font.SourceSansBold
MainToggle.Text = "Toggle Menu"
MainToggle.TextSize = 16
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 6)
MainCorner.Parent = MainToggle

-- Main Menu Panel
local MainPanel = Instance.new("Frame")
MainPanel.Name = "MainPanel"
MainPanel.Parent = TrollHubUI
MainPanel.Size = UDim2.new(0, 250, 0, 380)
MainPanel.Position = UDim2.new(0.02, 0, 0.26, 0)
MainPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainPanel.Visible = true
local PanelCorner = Instance.new("UICorner")
PanelCorner.CornerRadius = UDim.new(0, 8)
PanelCorner.Parent = MainPanel

-- Title
local Title = Instance.new("TextLabel")
Title.Parent = MainPanel
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "🧌 TROLLING HUB"
Title.TextColor3 = Color3.fromRGB(255, 170, 0)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.BackgroundTransparency = 1

-- Mobile Dragging Handler
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragStart = input.Position startPos = frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    frame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
    UIS.InputChanged:Connect(function(input) if input == dragInput and dragging then local delta = input.Position - dragStart frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
end
makeDraggable(MainToggle)
makeDraggable(MainPanel)

-- Menu visibility toggle
MainToggle.MouseButton1Click:Connect(function() MainPanel.Visible = not MainPanel.Visible end)
MainToggle.TouchTap:Connect(function() MainPanel.Visible = not MainPanel.Visible end)

-- Helper function to generate buttons
local function createButton(text, yPos, color, parent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 210, 0, 35)
    btn.Position = UDim2.new(0, 20, 0, yPos)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 15
    btn.Text = text
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = btn
    btn.Parent = parent
    return btn
end

-- ==================== FEATURE 1: ANTI-FLING ====================
local AntiFlingBtn = createButton("Anti-Fling: OFF", 50, Color3.fromRGB(150, 40, 40), MainPanel)

local function runAntiFling()
    task.spawn(function()
        while getgenv().AntiFling do
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if hrp.Velocity.Magnitude > 50 or hrp.RotVelocity.Magnitude > 50 then
                        hrp.Velocity, hrp.RotVelocity = Vector3.zero, Vector3.zero
                    end
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character then
                            for _, part in ipairs(p.Character:GetChildren()) do
                                if part:IsA("BasePart") then part.CanCollide = false end
                            end
                        end
                    end
                end
            end)
            task.wait(0.1)
        end
    end)
end

local function toggleAntiFlingAction()
    getgenv().AntiFling = not getgenv().AntiFling
    if getgenv().AntiFling then
        AntiFlingBtn.Text = "Anti-Fling: ON"
        AntiFlingBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
        runAntiFling()
    else
        AntiFlingBtn.Text = "Anti-Fling: OFF"
        AntiFlingBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
        pcall(function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character then
                    for _, part in ipairs(p.Character:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = true end end
                end
            end
        end)
    end
end
AntiFlingBtn.MouseButton1Click:Connect(toggleAntiFlingAction)
AntiFlingBtn.TouchTap:Connect(toggleAntiFlingAction)

-- ==================== FEATURE 2: SPEED HACK (WITH INPUT BOX) ====================
local SpeedBtn = createButton("Super Speed: OFF", 95, Color3.fromRGB(150, 40, 40), MainPanel)

local SpeedInput = Instance.new("TextBox")
SpeedInput.Parent = MainPanel
SpeedInput.Size = UDim2.new(0, 210, 0, 25)
SpeedInput.Position = UDim2.new(0, 20, 0, 133) 
SpeedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.Font = Enum.Font.SourceSans
SpeedInput.Text = "100"
SpeedInput.PlaceholderText = "Enter Speed (e.g. 150)"
SpeedInput.TextSize = 14
local SpeedInputCorner = Instance.new("UICorner")
SpeedInputCorner.CornerRadius = UDim.new(0, 5)
SpeedInputCorner.Parent = SpeedInput

SpeedInput:GetPropertyChangedSignal("Text"):Connect(function()
    local num = tonumber(SpeedInput.Text)
    if num then walkSpeedValue = num end
end)

local speedActive = false
local function toggleSpeedAction()
    speedActive = not speedActive
    if speedActive then
        SpeedBtn.Text = "Super Speed: ON"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
        task.spawn(function()
            while speedActive do
                pcall(function()
                    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.WalkSpeed = walkSpeedValue end
                end)
                task.wait(0.1)
            end
        end)
    else
        SpeedBtn.Text = "Super Speed: OFF"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
        pcall(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end)
    end
end
SpeedBtn.MouseButton1Click:Connect(toggleSpeedAction)
SpeedBtn.TouchTap:Connect(toggleSpeedAction)

-- ==================== FEATURE 3: JUMP BOOST ====================
local JumpBtn = createButton("Super Jump: OFF", 165, Color3.fromRGB(150, 40, 40), MainPanel)
local jumpActive = false
local function toggleJumpAction()
    jumpActive = not jumpActive
    if jumpActive then
        JumpBtn.Text = "Super Jump: ON"
        JumpBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
        task.spawn(function()
            while jumpActive do
                pcall(function()
                    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.JumpPower = 150 end
                end)
                task.wait(0.1)
            end
        end)
    else
        JumpBtn.Text = "Super Jump: OFF"
        JumpBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
        pcall(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = 50 end
        end)
    end
end
JumpBtn.MouseButton1Click:Connect(toggleJumpAction)
JumpBtn.TouchTap:Connect(toggleJumpAction)

-- ==================== FEATURE 4: BUFFED FLING TARGET ====================
local TargetInput = Instance.new("TextBox")
TargetInput.Parent = MainPanel
TargetInput.Size = UDim2.new(0, 210, 0, 30)
TargetInput.Position = UDim2.new(0, 20, 0, 210)
TargetInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TargetInput.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetInput.Font = Enum.Font.SourceSans
TargetInput.Text = ""
TargetInput.PlaceholderText = "Target Username (Short okay)"
TargetInput.TextSize = 14
local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 5)
InputCorner.Parent = TargetInput

local FlingBtn = createButton("Fling Target: OFF", 245, Color3.fromRGB(150, 40, 40), MainPanel)

local function getTarget(str)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #str) == str:lower() or p.DisplayName:lower():sub(1, #str) == str:lower() then
            return p
        end
    end
    return nil
end

local function toggleFlingAction()
    getgenv().LoopFling = not getgenv().LoopFling
    if getgenv().LoopFling then
        local targetPlayer = getTarget(TargetInput.Text)
        if targetPlayer and targetPlayer ~= LocalPlayer then
