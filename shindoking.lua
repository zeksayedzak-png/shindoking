-- إنشاء الواجهة الأساسية
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local ToggleButton = Instance.new("TextButton")
local ScrollFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

-- إعدادات الواجهة (مربعة، سوداء، ناعمة)
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "BossTrackerGUI"

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- أسود غامق
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -100)
MainFrame.Size = UDim2.new(0, 220, 0, 300)
MainFrame.Active = true
MainFrame.Draggable = true -- تفعيل السحب للهواتف

UICorner.CornerRadius = UDim1.new(0, 15)
UICorner.Parent = MainFrame

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "رادار اللافتات"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.TextSize = 20

-- زر التشغيل والإطفاء (On/Off)
ToggleButton.Parent = MainFrame
ToggleButton.Position = UDim2.new(0.1, 0, 0.15, 0)
ToggleButton.Size = UDim2.new(0.8, 0, 0, 35)
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- أحمر (Off)
ToggleButton.Text = "ESP: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim1.new(0, 8)
ToggleCorner.Parent = ToggleButton

-- قائمة البوصات (Scrolling List)
ScrollFrame.Parent = MainFrame
ScrollFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
ScrollFrame.Size = UDim2.new(0.9, 0, 0.65, 0)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
ScrollFrame.ScrollBarThickness = 4

UIListLayout.Parent = ScrollFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- متغيرات التحكم
local espEnabled = false
local espObjects = {}

-- وظيفة الرصد (ESP)
function createESP(part, bossName)
    local bgui = Instance.new("BillboardGui")
    bgui.Name = "BossESP"
    bgui.Parent = part
    bgui.AlwaysOnTop = true
    bgui.Size = UDim2.new(0, 200, 0, 50)
    bgui.ExtentsOffset = Vector3.new(0, 3, 0)

    local label = Instance.new("TextLabel")
    label.Parent = bgui
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.TextColor3 = Color3.fromRGB(255, 255, 0) -- أصفر
    label.TextStrokeTransparency = 0
    label.TextSize = 15
    
    -- تحديث المسافة باستمرار
    task.spawn(function()
        while bgui.Parent do
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local dist = math.floor((part.Position - char.HumanoidRootPart.Position).Magnitude)
                label.Text = bossName .. "\n[" .. dist .. "m]"
            end
            task.wait(0.1)
        end
    end)
    
    return bgui
end

-- وظيفة تحديث القائمة والرصد
function updateMissions()
    -- تنظيف القائمة القديمة
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    local missionPath = workspace:FindFirstChild("bossdropmission")
    if missionPath then
        missionPath = missionPath:FindFirstChild("missions")
    end

    if missionPath then
        for _, bossFolder in pairs(missionPath:GetChildren()) do
            local bossName = bossFolder.Name
            local targetPart = bossFolder:FindFirstChild("missiongiver") and bossFolder.missiongiver:FindFirstChild("Part")
            
            if targetPart then
                -- إضافة زر للنقل في القائمة
                local itemFrame = Instance.new("Frame")
                itemFrame.Size = UDim2.new(1, -10, 0, 30)
                itemFrame.BackgroundTransparency = 0.8
                itemFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
                itemFrame.Parent = ScrollFrame
                
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Text = bossName
                nameLabel.Size = UDim2.new(0.6, 0, 1, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.TextColor3 = Color3.fromRGB(255,255,255)
                nameLabel.Parent = itemFrame
                
                local tpBtn = Instance.new("TextButton")
                tpBtn.Text = "نقل"
                tpBtn.Size = UDim2.new(0.35, 0, 0.8, 0)
                tpBtn.Position = UDim2.new(0.6, 0, 0.1, 0)
                tpBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
                tpBtn.Parent = itemFrame
                
                Instance.new("UICorner", tpBtn).CornerRadius = UDim1.new(0, 5)

                tpBtn.MouseButton1Click:Connect(function()
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = targetPart.CFrame * CFrame.new(0, 3, 0)
                end)
            end
        end
    end
end

-- تفعيل/إيقاف الرصد
ToggleButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        ToggleButton.Text = "ESP: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        -- إنشاء ESP لكل لافتة
        local missionPath = workspace.bossdropmission.missions
        for _, bossFolder in pairs(missionPath:GetChildren()) do
            local targetPart = bossFolder:FindFirstChild("missiongiver") and bossFolder.missiongiver:FindFirstChild("Part")
            if targetPart then
                local esp = createESP(targetPart, bossFolder.Name)
                table.insert(espObjects, esp)
            end
        end
    else
        ToggleButton.Text = "ESP: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        for _, obj in pairs(espObjects) do
            if obj then obj:Destroy() end
        end
        espObjects = {}
    end
end)

-- تشغيل التحديث لأول مرة
updateMissions()
