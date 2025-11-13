local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local runService = game:GetService("RunService")
local teleporting = false -- чтобы стартовать/остановить цикл

-- Создаем ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportChestGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Создаем кнопку
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0.5, -100, 0.9, -25)
button.Text = "Начать телепорт к сундукам"
button.Parent = screenGui

local stopButton = Instance.new("TextButton")
stopButton.Size = UDim2.new(0, 200, 0, 50)
stopButton.Position = UDim2.new(0.5, -100, 0.8, -25)
stopButton.Text = "Остановить"
stopButton.Parent = screenGui
stopButton.Visible = false

local function getAllChests()
    local chests = {}
    for _, model in pairs(workspace:GetDescendants()) do
        if model:IsA("Model") and model.Name == "chests" then
            table.insert(chests, model)
        end
    end
    return chests
end

local function teleportToRandomChest()
    local chests = getAllChests()
    if #chests == 0 then return end
    local randomChest = chests[math.random(1, #chests)]
    -- Телепортируемся к случайному сундуку
    for _, part in pairs(randomChest:GetChildren()) do
        if part:IsA("BasePart") then
            local y = part.Position.Y
            -- Ограничение по высоте
            if y < 115 then y = 115 end
            if y > 180 then y = 180 end
            humanoidRootPart.CFrame = CFrame.new(part.Position.X, y + 3, part.Position.Z)
            break -- Телепортируемся к первому базовому компоненту
        end
    end
end

local teleportCoroutine = nil

button.MouseButton1Click:Connect(function()
    if teleporting then return end
    teleporting = true
    button.Visible = false
    stopButton.Visible = true

    teleportCoroutine = coroutine.create(function()
        while teleporting do
            teleportToRandomChest()
            wait(1) -- интервал в 1 секунду
        end
    end)
    coroutine.resume(teleportCoroutine)
end)

stopButton.MouseButton1Click:Connect(function()
    teleporting = false
    button.Visible = true
    stopButton.Visible = false
end)
