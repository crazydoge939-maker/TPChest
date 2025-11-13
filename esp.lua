local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local runService = game:GetService("RunService")
local isTeleporting = false
local teleportConnection = nil

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

local function startTeleportCycle()
    isTeleporting = true
    -- Цикл телепортации
    teleportConnection = runService.Heartbeat:Connect(function()
        if not isTeleporting then
            teleportConnection:Disconnect()
            return
        end

        -- Находим все сундуки
        local chestsModels = {}
        for _, model in pairs(workspace:GetDescendants()) do
            if model:IsA("Model") and model.Name == "chests" then
                table.insert(chestsModels, model)
            end
        end

        if #chestsModels == 0 then
            return
        end

        -- Выбираем случайный сундук
        local randomChest = chestsModels[math.random(1, #chestsModels)]
        local targetPosition = nil

        -- Находим центральную точку модели или первую часть
        if #randomChest:GetChildren() > 0 then
            local firstPart = randomChest:GetChildren()[1]
            if firstPart:IsA("BasePart") then
                targetPosition = firstPart.Position
            end
        end

        if targetPosition then
            -- Телепортируем игрока
            local newY = targetPosition.Y
            if newY < 115 then newY = 115 end
            if newY > 180 then newY = 180 end

            humanoidRootPart.CFrame = CFrame.new(targetPosition.X, newY, targetPosition.Z)
        end
    end)
end

local function stopTeleportCycle()
    isTeleporting = false
    if teleportConnection then
        teleportConnection:Disconnect()
        teleportConnection = nil
    end
end

button.MouseButton1Click:Connect(function()
    if isTeleporting then
        -- Остановить цикл
        stopTeleportCycle()
        button.Text = "Начать телепорт к сундукам"
    else
        -- Начать цикл
        startTeleportCycle()
        button.Text = "Остановить телепорт"
    end
end)
