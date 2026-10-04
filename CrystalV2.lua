-- =====================================================
-- 🎯 SMART ITEM ESP & TRACKER (MOBILE OPTIMIZED)
-- 📱 واجهة سحب للجوّال مع تتبع المسافة الذكي
-- =====================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- =====================================================
-- المتغيرات الأساسية
-- =====================================================
local espEnabled = false
local trackedObjects = {} -- {Instance = {Highlight, Billboard, DistanceLabel}}

-- =====================================================
-- إنشاء الواجهة للجوّال
-- =====================================================
local function createUI()
    if LocalPlayer.PlayerGui:FindFirstChild("ItemTrackerGui") then
        LocalPlayer.PlayerGui.ItemTrackerGui:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ItemTrackerGui"
    screenGui.Parent = LocalPlayer.PlayerGui
    screenGui.ResetOnSpawn = false

    -- النافذة الرئيسية في منتصف الشاشة
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 180, 0, 100)
    mainFrame.Position = UDim2.new(0.5, -90, 0.4, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    mainFrame.BackgroundTransparency = 0.15
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Parent = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

    -- إطار تحديد أنيق
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 200, 255)
    stroke.Thickness = 1.5
    stroke.Parent = mainFrame

    -- العنوان
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "🎯 Item Tracker"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.Parent = mainFrame

    -- زر التشغيل والإيقاف (ON/OFF)
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0.85, 0, 0, 42)
    toggleBtn.Position = UDim2.new(0.075, 0, 0.45, 0)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    toggleBtn.Text = "ESP: OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 14
    toggleBtn.Parent = mainFrame
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

    -- =====================================================
    -- وظيفة السحب بالإصبع (Touch Dragging)
    -- =====================================================
    local dragging, dragStart, startPos = false, nil, nil

    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- =====================================================
    -- حدث زر التشغيل
    -- =====================================================
    toggleBtn.MouseButton1Click:Connect(function()
        espEnabled = not espEnabled
        if espEnabled then
            toggleBtn.Text = "ESP: ON"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
        else
            toggleBtn.Text = "ESP: OFF"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
            -- إزالة جميع المؤشرات فور الإيقاف
            for obj, data in pairs(trackedObjects) do
                if data.Highlight then data.Highlight:Destroy() end
                if data.Billboard then data.Billboard:Destroy() end
            end
            trackedObjects = {}
        end
    end)
end

-- =====================================================
-- دالة إنشاء الـ ESP واللوحة البصرية فوق العنصر
-- =====================================================
local function createESP(targetObj)
    if not targetObj or trackedObjects[targetObj] then return end

    local primaryPart = targetObj:IsA("BasePart") and targetObj or targetObj:FindFirstChildWhichIsA("BasePart", true)
    if not primaryPart then return end

    -- 1. التظليل الضوئي عبر الجدران
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = targetObj
    highlight.FillColor = Color3.fromRGB(0, 255, 180)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.4
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = targetObj

    -- 2. واجهة النص والمسافة فوق الكائن
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard"
    billboard.Adornee = primaryPart
    billboard.Size = UDim2.new(0, 150, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = targetObj

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = targetObj.Name .. "\n[0m]"
    label.TextColor3 = Color3.fromRGB(255, 255, 0)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextStrokeTransparency = 0
    label.Parent = billboard

    trackedObjects[targetObj] = {
        Highlight = highlight,
        Billboard = billboard,
        Label = label,
        Part = primaryPart
    }
end

-- =====================================================
-- دالة مسح الأماكن المطلوبة بدقة
-- =====================================================
local function scanTargets()
    if not espEnabled then return end

    local targets = {}

    -- 1. مسح Workspace.PlotRunes
    local plotRunes = workspace:FindFirstChild("PlotRunes")
    if plotRunes then
        for _, child in ipairs(plotRunes:GetChildren()) do
            table.insert(targets, child)
        end
    end

    -- 2. مسح ReplicatedStorage (RuneModels & MeteorTemplate & Shell)
    local repStorage = game:GetService("ReplicatedStorage")
    
    local runeModels = repStorage:FindFirstChild("RuneModels")
    if runeModels then
        for _, child in ipairs(runeModels:GetChildren()) do
            table.insert(targets, child)
        end
    end

    local meteor = repStorage:FindFirstChild("MeteorTemplate")
    if meteor then
        table.insert(targets, meteor)
        local shell = meteor:FindFirstChild("Shell")
        if shell then table.insert(targets, shell) end
    end

    -- تطبيق التتبع على كل الكائنات المكتشفة
    for _, obj in ipairs(targets) do
        createESP(obj)
    end
end

-- =====================================================
-- حلقة التحديث المستمر لحساب المسافات وتنظيف الكائنات
-- =====================================================
RunService.RenderStepped:Connect(function()
    if not espEnabled then return end

    -- إجراء مسح سريع دوري
    scanTargets()

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    for obj, data in pairs(trackedObjects) do
        -- التأكد من أن الكائن لا يزال موجوداً في اللعبة
        if not obj or not obj.Parent or not data.Part or not data.Part.Parent then
            if data.Highlight then data.Highlight:Destroy() end
            if data.Billboard then data.Billboard:Destroy() end
            trackedObjects[obj] = nil
        else
            if hrp then
                -- حساب المسافة بالأمتار/البللوكات (Studs)
                local distance = math.floor((data.Part.Position - hrp.Position).Magnitude)
                data.Label.Text = string.format("%s\n[%dm]", obj.Name, distance)
            end
        end
    end
end)

-- =====================================================
-- تشغيل الواجهة
-- =====================================================
createUI()
print("✅ Smart Tracker Loaded Successfully!")
