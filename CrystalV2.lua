-- Workspace.SpawnedGems Group ESP & Smart Teleport Tracker (Advanced Value Search)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 1. إنشاء الواجهة
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GemsTrackerGUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 370)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -185)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- شريط العنوان
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -145, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Gems Scanner"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- زر الانتقال لأغلى كريستالة (TP Top $)
local TpTopBtn = Instance.new("TextButton")
TpTopBtn.Size = UDim2.new(0, 68, 0, 26)
TpTopBtn.Position = UDim2.new(1, -138, 0.5, -13)
TpTopBtn.BackgroundColor3 = Color3.fromRGB(180, 130, 0)
TpTopBtn.Text = "TP Top $"
TpTopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TpTopBtn.TextSize = 10
TpTopBtn.Font = Enum.Font.GothamBold
TpTopBtn.Parent = TitleBar

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 6)
TopCorner.Parent = TpTopBtn

-- زر التحديث Refresh
local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0, 60, 0, 26)
RefreshBtn.Position = UDim2.new(1, -65, 0.5, -13)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
RefreshBtn.Text = "Refresh"
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.TextSize = 10
RefreshBtn.Font = Enum.Font.GothamBold
RefreshBtn.Parent = TitleBar

local RefreshCorner = Instance.new("UICorner")
RefreshCorner.CornerRadius = UDim.new(0, 6)
RefreshCorner.Parent = RefreshBtn

-- قائمة التمرير
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -58)
ScrollFrame.Position = UDim2.new(0, 10, 0, 48)
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

-- 2. تحريك الواجهة بالسحب
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

-- 3. دالة بحث مرنة ومتقدمة لجلب السعر (Value)
local function getGemValue(gem)
    -- البحث عن أية قيمة باسم Value أو Price أو GemValue في كل أطفال المودل
    for _, obj in pairs(gem:GetDescendants()) do
        if (obj.Name == "Value" or obj.Name == "Price" or obj.Name == "GemValue") then
            if obj:IsA("ValueBase") then
                return tonumber(obj.Value) or 0
            elseif obj:IsA("TextLabel") or obj:IsA("StringValue") then
                local num = string.match(obj.Text or obj.Value, "%d+")
                if num then return tonumber(num) end
            end
        end
    end
    return 0
end

-- 4. دالة استخراج أجزاء الكريستالة
local function getAllParts(gem)
    local parts = {}
    if gem:IsA("BasePart") then
        table.insert(parts, gem)
    end
    for _, descendant in pairs(gem:GetDescendants()) do
        if descendant:IsA("BasePart") then
            table.insert(parts, descendant)
        end
    end
    return parts
end

-- 5. الانتقال للكريستالة
local function teleportToNearest(gem)
    local char = LocalPlayer.Character
    if not (char and char:FindFirstChild("HumanoidRootPart")) then return end

    local parts = getAllParts(gem)
    if #parts == 0 then return end

    local myPos = char.HumanoidRootPart.Position
    local nearestPart = parts[1]
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

-- 6. نظام ESP
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

    local gemVal = getGemValue(gem)
    local espItems = {}

    for _, part in pairs(parts) do
        local highlight = Instance.new("Highlight")
        highlight.Adornee = part
        highlight.FillColor = Color3.fromRGB(0, 255, 150)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.4
        highlight.Parent = part

        local billboard = Instance.new("BillboardGui")
        billboard.Adornee = part
        billboard.Size = UDim2.new(0, 120, 0, 38)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = part

        local distanceText = Instance.new("TextLabel")
        distanceText.Size = UDim2.new(1, 0, 0, 18)
        distanceText.Position = UDim2.new(0, 0, 0, 0)
        distanceText.BackgroundTransparency = 1
        distanceText.TextColor3 = Color3.fromRGB(0, 255, 150)
        distanceText.TextStrokeTransparency = 0
        distanceText.TextSize = 11
        distanceText.Font = Enum.Font.GothamBold
        distanceText.Text = gem.Name .. " [0m]"
        distanceText.Parent = billboard

        local priceText = Instance.new("TextLabel")
        priceText.Size = UDim2.new(1, 0, 0, 16)
        priceText.Position = UDim2.new(0, 0, 0, 18)
        priceText.BackgroundTransparency = 1
        priceText.TextColor3 = Color3.fromRGB(255, 215, 0)
        priceText.TextStrokeTransparency = 0
        priceText.TextSize = 11
        priceText.Font = Enum.Font.GothamBold
        priceText.Text = "$" .. tostring(gemVal)
        priceText.Parent = billboard

        table.insert(espItems, {
            Part = part,
            Highlight = highlight,
            Billboard = billboard,
            TextLabel = distanceText
        })
    end

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

-- 7. تحديث القائمة
local function updateGemsList()
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local spawnedGems = Workspace:FindFirstChild("SpawnedGems")
    if not spawnedGems then return end

    local gemsTable = {}
    for _, gem in pairs(spawnedGems:GetChildren()) do
        -- تأكيد وجود أجزاء قبل إضافتها للقائمة
        if #getAllParts(gem) > 0 then
            table.insert(gemsTable, {
                Object = gem,
                Value = getGemValue(gem)
            })
        end
    end

    -- فرز حسب الأعلى سعراً
    table.sort(gemsTable, function(a, b)
        return a.Value > b.Value
    end)

    for idx, data in ipairs(gemsTable) do
        local gem = data.Object
        local val = data.Value

        local ItemFrame = Instance.new("Frame")
        ItemFrame.Size = UDim2.new(1, 0, 0, 42)
        ItemFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        ItemFrame.BorderSizePixel = 0
        ItemFrame.LayoutOrder = idx
        ItemFrame.Parent = ScrollFrame

        local ItemCorner = Instance.new("UICorner")
        ItemCorner.CornerRadius = UDim.new(0, 6)
        ItemCorner.Parent = ItemFrame

        local GemName = Instance.new("TextLabel")
        GemName.Size = UDim2.new(1, -125, 0, 20)
        GemName.Position = UDim2.new(0, 10, 0, 2)
        GemName.BackgroundTransparency = 1
        GemName.Text = gem.Name
        GemName.TextColor3 = Color3.fromRGB(230, 230, 230)
        GemName.TextSize = 11
        GemName.Font = Enum.Font.GothamBold
        GemName.TextXAlignment = Enum.TextXAlignment.Left
        GemName.TextTruncate = Enum.TextTruncate.AtEnd
        GemName.Parent = ItemFrame

        local GemPriceLabel = Instance.new("TextLabel")
        GemPriceLabel.Size = UDim2.new(1, -125, 0, 16)
        GemPriceLabel.Position = UDim2.new(0, 10, 0, 22)
        GemPriceLabel.BackgroundTransparency = 1
        GemPriceLabel.Text = "Price: $" .. tostring(val)
        GemPriceLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        GemPriceLabel.TextSize = 10
        GemPriceLabel.Font = Enum.Font.Gotham
        GemPriceLabel.TextXAlignment = Enum.TextXAlignment.Left
        GemPriceLabel.Parent = ItemFrame

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

-- زر الانتقال لأعلى سعر
TpTopBtn.MouseButton1Click:Connect(function()
    local spawnedGems = Workspace:FindFirstChild("SpawnedGems")
    if not spawnedGems then return end

    local topGem = nil
    local maxVal = -1

    for _, gem in pairs(spawnedGems:GetChildren()) do
        local val = getGemValue(gem)
        if val > maxVal then
            maxVal = val
            topGem = gem
        end
    end

    if topGem then
        teleportToNearest(topGem)
    end
end)

RefreshBtn.MouseButton1Click:Connect(updateGemsList)

-- البدء
updateGemsList()
