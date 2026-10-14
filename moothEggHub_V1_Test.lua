-- Smooth Egg Hub V1 | Save The Egg
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "SmoothEggHub"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(280, 190)
frame.Position = UDim2.new(0.5, -140, 0.5, -95)
frame.BackgroundColor3 = Color3.fromRGB(30, 20, 45)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius =
    UDim.new(0, 12)

local function button(text, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(250, 45)
    b.Position = UDim2.fromOffset(15, y)
    b.BackgroundColor3 = Color3.fromRGB(130, 75, 220)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 17
    b.Font = Enum.Font.GothamBold
    b.Text = text
    b.Parent = frame

    Instance.new("UICorner", b).CornerRadius =
        UDim.new(0, 8)

    return b
end

local eggButton = button("BEST EGG TP", 20)
local baseButton = button("MY BASE TP", 75)

local status = Instance.new("TextLabel")
status.Size = UDim2.fromOffset(250, 35)
status.Position = UDim2.fromOffset(15, 135)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.new(1, 1, 1)
status.TextScaled = true
status.Text = "Ready"
status.Parent = frame

local function teleport(part)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if root and part then
        root.CFrame = part.CFrame + Vector3.new(0, 5, 0)
        status.Text = "Teleport versucht!"
    end
end

local function findEgg()
    local best
    local bestValue = -math.huge

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("egg") then
            local part

            if obj:IsA("BasePart") then
                part = obj
            elseif obj:IsA("Model") then
                part = obj.PrimaryPart
                    or obj:FindFirstChildWhichIsA("BasePart", true)
            end

            if part then
                local value = obj:GetAttribute("Value")
                    or obj:GetAttribute("Price")
                    or obj:GetAttribute("RarityValue")

                if type(value) == "number" and value > bestValue then
                    best = part
                    bestValue = value
                end
            end
        end
    end

    return best
end

eggButton.MouseButton1Click:Connect(function()
    local egg = findEgg()

    if egg then
        teleport(egg)
    else
        status.Text = "Kein bewertetes Ei gefunden"
    end
end)

baseButton.MouseButton1Click:Connect(function()
    local base

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("base") then
            local owner = obj:GetAttribute("Owner")
                or obj:GetAttribute("OwnerUserId")

            if tostring(owner) == tostring(player.UserId)
                or tostring(owner) == player.Name then

                if obj:IsA("BasePart") then
                    base = obj
                elseif obj:IsA("Model") then
                    base = obj.PrimaryPart
                        or obj:FindFirstChildWhichIsA("BasePart", true)
                end

                if base then break end
            end
        end
    end

    if base then
        teleport(base)
    else
        status.Text = "Eigene Basis nicht gefunden"
    end
end)
