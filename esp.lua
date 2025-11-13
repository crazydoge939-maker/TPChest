local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local runService = game:GetService("RunService")
local teleporting = false -- чтобы стартовать/остановить цикл

-- Создаем ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportChestGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Создаем кнопку для запуска
local startButton = Instance.new("TextButton")
startButton.Size = UDim2.new(0, 200, 0, 50)
startButton.Position = UDim2.new(0.5, -100, 0.9, -25)
startButton.Text = "Start TP to Chest"
startButton.Parent = screenGui

-- Создаем кнопку для остановки
local stopButton = Instance.new("TextButton")
stopButton.Size = UDim2.new(0, 200, 0, 50)
stopButton.Position = UDim2.new(0.5, -100, 0.8, -25)
stopButton.Text = "Stop TP to Chest"
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

local function findAccessibleChest(chests)
    local accessibleChests = {}
    for _, chest in pairs(chests) do
        local accessible = false
        for _, part in pairs(chest:GetChildren()) do
            if part:IsA("BasePart") then
                local y = part.Position.Y
                if y >= 115 and y <= 180 then
                    accessible = true
                    break
                end
            end
        end
        if accessible then
            table.insert(accessibleChests, chest)
        end
    end
    return accessibleChests
end

local function getNearestProximityPrompt(position, radius)
    local closestPrompt = nil
    local closestDistance = math.huge
    for _, prompt in pairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local distance = (prompt.Parent.HumanoidRootPart.Position - position).magnitude
            if distance <= radius then
                if distance < closestDistance then
                    closestDistance = distance
                    closestPrompt = prompt
                end
            end
        end
    end
    return closestPrompt
end

local function activatePrompt(prompt)
    if prompt and prompt.Enabled then
        prompt:InputHoldBegin()
        wait(0.5)
        prompt:InputHoldEnd()
    end
end

local function teleportToChest(chest)
    -- Проверка высоты сундука
    local canTeleport = false
    for _, part in pairs(chest:GetChildren()) do
        if part:IsA("BasePart") then
            local y = part.Position.Y
            if y >= 115 and y <= 180 then
                canTeleport = true
                -- Телепортируемся к части сундука
                local targetY = y
                if targetY < 115 then targetY = 115 end
                if targetY > 180 then targetY = 180 end
                humanoidRootPart.CFrame = CFrame.new(part.Position.X, targetY + 3, part.Position.Z)
                break
            end
        end
    end
end

local function cycle()
    while teleporting do
        -- Поиск ближайшего prompt в радиусе 15
        local prompt = getNearestProximityPrompt(humanoidRootPart.Position, 15)
        if prompt then
            -- Активация prompt
            activatePrompt(prompt)
        end

        -- Поиск сундуков и телепортация к допустимому
        local chests = getAllChests()
        local accessibleChests = findAccessibleChest(chests)
        if #accessibleChests > 0 then
            -- Выбираем случайный сундук из доступных
            local chest = accessibleChests[math.random(1, #accessibleChests)]
            teleportToChest(chest)
        end

        wait(1)
    end
end

local function startTeleportCycle()
    if teleporting then return end
    teleporting = true
    startButton.Visible = false
    stopButton.Visible = true
    coroutine.wrap(cycle)()
end

local function stopTeleportCycle()
    teleporting = false
    startButton.Visible = true
    stopButton.Visible = false
end

startButton.MouseButton1Click:Connect(startTeleportCycle)
stopButton.MouseButton1Click:Connect(stopTeleportCycle)
