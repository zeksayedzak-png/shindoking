-- Workspace.SpawnedGems Group ESP & Smart Teleport Tracker
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 1. إنشاء الواجهة الشفافة
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GemsTrackerGUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 360)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -180) -- منتصف الشاشة
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- واجهة سوداء
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- شريط العنوان (قابل للتحريك)
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -70, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Gems Scanner (Drag)"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- زر التحديث Refresh
local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0, 60, 0, 26)
RefreshBtn.Position = UDim2.new(1, -65, 0.5, -13)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
RefreshBtn.Text = "Refresh"
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.TextSize = 11
RefreshBtn.Font = Enum.Font.GothamBold
RefreshBtn.Parent = TitleBar

local RefreshCorner = Instance.new("UICorner")
RefreshCorner.CornerRadius = UDim.new(0, 6)
RefreshCorner.Parent = RefreshBtn

-- قائمة التمرير (Scroll Frame)
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -55)
ScrollFrame.Position = UDim2.new(0, 10, 0, 45)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollFrame

-- 2. تحريك الواجهة بالسحب من العنوان
local dragging = false
local dragStart = nil
local startPos = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- 3. دالة استخراج جميع أجزاء الكريستالة (سواء كانت قطعة واحدة أو عدة أجزاء داخل Cluster)
local function getAllParts(gem)
    local parts = {}
    if gem:IsA("BasePart") then
        table.insert(parts, gem)
    else
        for _, descendant in pairs(gem:GetDescendants()) do
            if descendant:IsA("BasePart") then
                table.insert(parts, descendant)
            end
        end
    end
    return parts
end

-- 4. نظام الانتقال إلى أقرب كريستالة في المجموعة (Smart TP)
local function teleportToNearest(gem)
    local char = LocalPlayer.Character
    if not (char and char:FindFirstChild("HumanoidRootPart")) then return end

    local parts = getAllParts(gem)
    if #parts == 0 then return end

    local myPos = char.HumanoidRootPart.Position
    local nearestPart = nil
    local minDistance = math.huge

    for _, part in pairs(parts) do
        local dist = (myPos - part.Position).Magnitude
        if dist < minDistance then
            minDistance = dist
            nearestPart = part
        end
    end

    if nearestPart then
        char.HumanoidRootPart.CFrame = CFrame.new(nearestPart.Position + Vector3.new(0, 3, 0))
    end
end

-- 5. نظام ESP متطور لكل أجزاء الكريستالة المشتركة
local activeESPs = {}

local function removeESP(gem)
    if activeESPs[gem] then
        for _, item in pairs(activeESPs[gem].Items) do
            if item.Highlight then item.Highlight:Destroy() end
            if item.Billboard then item.Billboard:Destroy() end
        end
        if activeESPs[gem].Connection then activeESPs[gem].Connection:Disconnect() end
        activeESPs[gem] = nil
    end
end

local function createESP(gem)
    if activeESPs[gem] then
        removeESP(gem)
        return false
    end

    local parts = getAllParts(gem)
    if #parts == 0 then return false end

    local espItems = {}

    for _, part in pairs(parts) do
        -- إضاءة كل جزء
        local highlight = Instance.new("Highlight")
        highlight.Adornee = part
        highlight.FillColor = Color3.fromRGB(0, 255, 150)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.4
        highlight.Parent = part

        -- نص المسافة فوق كل جزء
        local billboard = Instance.new("BillboardGui")
        billboard.Adornee = part
        billboard.Size = UDim2.new(0, 100, 0, 25)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = part

        local distanceText = Instance.new("TextLabel")
        distanceText.Size = UDim2.new(1, 0, 1, 0)
        distanceText.BackgroundTransparency = 1
        distanceText.TextColor3 = Color3.fromRGB(0, 255, 150)
        distanceText.TextStrokeTransparency = 0
        distanceText.TextSize = 12
        distanceText.Font = Enum.Font.GothamBold
        distanceText.Text = gem.Name .. " [0m]"
        distanceText.Parent = billboard

        table.insert(espItems, {
            Part = part,
            Highlight = highlight,
            Billboard = billboard,
            TextLabel = distanceText
        })
    end

    -- تحديث المسافات بخفة لتفادي اللاق
    local lastUpdate = 0
    local connection = RunService.Heartbeat:Connect(function()
        if tick() - lastUpdate > 0.1 then
            lastUpdate = tick()
            if gem and gem.Parent and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local myPos = LocalPlayer.Character.HumanoidRootPart.Position
                for _, item in pairs(espItems) do
                    if item.Part and item.Part.Parent then
                        local dist = math.floor((myPos - item.Part.Position).Magnitude)
                        item.TextLabel.Text = gem.Name .. " [" .. tostring(dist) .. "m]"
                    end
                end
            else
                removeESP(gem)
            end
        end
    end)

    activeESPs[gem] = {
        Items = espItems,
        Connection = connection
    }
    return true
end

-- 6. تحديث قائمة العرض بالواجهة
local function updateGemsList()
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local spawnedGems = Workspace:FindFirstChild("SpawnedGems")
    if not spawnedGems then return end

    for _, gem in pairs(spawnedGems:GetChildren()) do
        local ItemFrame = Instance.new("Frame")
        ItemFrame.Size = UDim2.new(1, 0, 0, 40)
        ItemFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        ItemFrame.BorderSizePixel = 0
        ItemFrame.Parent = ScrollFrame

        local ItemCorner = Instance.new("UICorner")
        ItemCorner.CornerRadius = UDim.new(0, 6)
        ItemCorner.Parent = ItemFrame

        local partsCount = #getAllParts(gem)
        local GemName = Instance.new("TextLabel")
        GemName.Size = UDim2.new(1, -115, 1, 0)
        GemName.Position = UDim2.new(0, 10, 0, 0)
        GemName.BackgroundTransparency = 1
        GemName.Text = gem.Name .. " (" .. tostring(partsCount) .. ")"
        GemName.TextColor3 = Color3.fromRGB(220, 220, 220)
        GemName.TextSize = 12
        GemName.Font = Enum.Font.Gotham
        GemName.TextXAlignment = Enum.TextXAlignment.Left
        GemName.Parent = ItemFrame

        -- زر الانتقال Teleport
        local TpBtn = Instance.new("TextButton")
        TpBtn.Size = UDim2.new(0, 45, 0, 26)
        TpBtn.Position = UDim2.new(1, -105, 0.5, -13)
        TpBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
        TpBtn.Text = "TP"
        TpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        TpBtn.TextSize = 11
        TpBtn.Font = Enum.Font.GothamBold
        TpBtn.Parent = ItemFrame

        local TpCorner = Instance.new("UICorner")
        TpCorner.CornerRadius = UDim.new(0, 6)
        TpCorner.Parent = TpBtn

        TpBtn.MouseButton1Click:Connect(function()
            teleportToNearest(gem)
        end)

        -- زر الـ ESP
        local EspBtn = Instance.new("TextButton")
        EspBtn.Size = UDim2.new(0, 50, 0, 26)
        EspBtn.Position = UDim2.new(1, -55, 0.5, -13)
        EspBtn.Text = "ESP"
        EspBtn.TextSize = 11
        EspBtn.Font = Enum.Font.GothamBold
        EspBtn.Parent = ItemFrame

        local EspCorner = Instance.new("UICorner")
        EspCorner.CornerRadius = UDim.new(0, 6)
        EspCorner.Parent = EspBtn

        if activeESPs[gem] then
            EspBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            EspBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            EspBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            EspBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end

        EspBtn.MouseButton1Click:Connect(function()
            local isEnabled = createESP(gem)
            if isEnabled then
                EspBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
                EspBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                EspBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                EspBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
        end)
    end
end

RefreshBtn.MouseButton1Click:Connect(updateGemsList)

-- أول فحص تلقائي عند تشغيل السكريبت
updateGemsList()
