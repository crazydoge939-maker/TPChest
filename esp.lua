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
startButton.Text = "Начать телепорт к сундукам"
startButton.Parent = screenGui

-- Создаем кнопку для остановки
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

local function teleportToRandomAccessibleChest()
    local chests = getAllChests()
    local accessibleChests = findAccessibleChest(chests)
    if #accessibleChests == 0 then return end

    local randomChest = accessibleChests[math.random(1, #accessibleChests)]
    for _, part in pairs(randomChest:GetChildren()) do
        if part:IsA("BasePart") then
            local y = part.Position.Y
            -- Ограничение по высоте
            if y < 115 then y = 115 end
            if y > 180 then y = 180 end
            humanoidRootPart.CFrame = CFrame.new(part.Position.X, y + 3, part.Position.Z)
            break
        end
    end
end

local teleportCoroutine = nil

local function startTeleportCycle()
    if teleporting then return end
    teleporting = true
    startButton.Visible = false
    stopButton.Visible = true

    teleportCoroutine = coroutine.create(function()
        while teleporting do
            teleportToRandomAccessibleChest()
            wait(1)
        end
    end)
    coroutine.resume(teleportCoroutine)
end

local function stopTeleportCycle()
    teleporting = false
    startButton.Visible = true
    stopButton.Visible = false
end

startButton.MouseButton1Click:Connect(startTeleportCycle)
stopButton.MouseButton1Click:Connect(stopTeleportCycle)

-- =======================
-- Автоматическая активация ProximityPrompt
-- =======================

local promptRadius = 15 -- радиус поиска сундука

while true do
    local chests = {}
    for _, model in pairs(workspace:GetDescendants()) do
        if model:IsA("Model") and model.Name == "chests" then
            for _, part in pairs(model:GetChildren()) do
                if part:IsA("BasePart") then
                    local prompt = part:FindFirstChildOfClass("ProximityPrompt")
                    if prompt then
                        table.insert(chests, {part = part, prompt = prompt})
                    end
                end
            end
        end
    end

    local closestChest = nil
    local minDistance = math.huge

    for _, chest in pairs(chests) do
        local distance = (chest.part.Position - humanoidRootPart.Position).Magnitude
        if distance <= promptRadius and distance < minDistance then
            minDistance = distance
            closestChest = chest
        end
    end

    if closestChest and closestChest.prompt then
        -- Активируем ProximityPrompt
        -- В Roblox для автоматической активации можно вызвать: 
        -- closestChest.prompt:InputBegan() или установить свойство Triggered
        -- Но самый надежный способ - вызвать :InputBegan с нужными параметрами
        -- Или, если есть API, вызвать: closestChest.prompt:InputBegan({UserInputType = Enum.UserInputType.Touch})
        -- В данном случае попробуем имитировать активирование:
        if not closestChest.prompt.Triggered then
            closestChest.prompt:InputBegan({UserInputType = Enum.UserInputType.Touch})
        end
    end

    wait(1)
end
