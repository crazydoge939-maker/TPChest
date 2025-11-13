local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local debounce = false -- для ограничения частоты нажатий

-- Создаем ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportChestGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Создаем кнопку
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0.5, -100, 0.9, -25)
button.Text = "Телепортировать чехлы"
button.Parent = screenGui

local maxTeleports = 5 -- ограничение по количеству телепортированных моделей за раз
local teleportCount = 0
local teleporting = false -- флаг для остановки телепортации

button.MouseButton1Click:Connect(function()
    if debounce then return end
    debounce = true
    teleportCount = 0
    teleporting = true -- включаем процесс телепортации

    -- Запускаем цикл телепортации каждую секунду
    spawn(function()
        while teleporting and teleportCount < maxTeleports do
            -- Получаем все модели "chests" в Workspace
            local chestsModels = {}
            for _, model in pairs(workspace:GetDescendants()) do
                if model:IsA("Model") and model.Name == "chests" then
                    table.insert(chestsModels, model)
                end
            end

            if #chestsModels == 0 then
                break -- если сундуков нет, выходим
            end

            -- Выбираем случайный сундук
            local randomIndex = math.random(1, #chestsModels)
            local chestModel = chestsModels[randomIndex]

            -- Телепортируем все части модели
            for _, part in pairs(chestModel:GetChildren()) do
                if part:IsA("BasePart") then
                    local newPosition = humanoidRootPart.Position + Vector3.new(0, 3, 0)
                    -- Ограничение по высоте
                    local y = newPosition.Y
                    if y < 115 then y = 115 end
                    if y > 180 then y = 180 end
                    part.CFrame = CFrame.new(newPosition.X, y, newPosition.Z)
                end
            end

            teleportCount = teleportCount + 1
            wait(1) -- задержка в 1 секунду
        end
        debounce = false -- снимаем блокировку после завершения
        teleporting = false -- завершаем цикл
    end)
end)
