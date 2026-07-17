-- إنشاء الواجهة (ScreenGui)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BossRadar_Final"
ScreenGui.Parent = game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- الإطار الرئيسي (مربع، أسود، ناعم الحواف)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10) -- أسود
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -110)
MainFrame.Size = UDim2.new(0, 220, 0, 250) -- شكل مربعي
MainFrame.Active = true
MainFrame.Draggable = true -- تفعيل السحب للهاتف

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim1.new(0, 15) -- حواف ناعمة
UICorner.Parent = MainFrame

-- العنوان
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "رادار لافتات البوص"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

-- زر التشغيل/الإطفاء (ON/OFF)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = MainFrame
ToggleBtn.Position = UDim2.new(0.1, 0, 0.2, 0)
ToggleBtn.Size = UDim2.new(0.8, 0, 0, 35)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0) -- أحمر في البداية
ToggleBtn.Text = "ESP: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
local BtnCorner = Instance.new("UICorner", ToggleBtn)
BtnCorner.CornerRadius = UDim1.new(0, 8)

-- قائمة التمرير (لأزرار النقل)
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Parent = MainFrame
ScrollFrame.Position = UDim2.new(0.1, 0, 0.4, 0)
ScrollFrame.Size = UDim2.new(0.8, 0, 0.5, 0)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 2
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local Layout = Instance.new("UIListLayout", ScrollFrame)
Layout.Padding = UDim.new(0, 5)

-- متغيرات التحكم
local espActive = false
local currentESPs = {}

-- وظيفة إنشاء الرصد (ESP)
function createESP(targetPart, bossName)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "MissionESP"
    billboard.Parent = targetPart
    billboard.AlwaysOnTop = true -- لتعمل مثل الـ X-Ray
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.ExtentsOffset = Vector3.new(0, 5, 0)

    local label = Instance.new("TextLabel", billboard)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.TextColor3 = Color3.fromRGB(0, 255, 0) -- أخضر
    label.TextStrokeTransparency = 0
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold

    -- تحديث المسافة
    task.spawn(function()
        while billboard.Parent do
            local playerPos = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if playerPos then
                local dist = math.floor((targetPart.Position - playerPos.Position).Magnitude)
                label.Text = bossName .. "\n[" .. dist .. "m]"
            end
            task.wait(0.1)
        end
    end)
    return billboard
end

-- وظيفة تحديث الأزرار والرصد
function refreshMissions()
    -- مسح الأزرار القديمة
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    -- البحث في المسار الذي حددته
    local missionsFolder = workspace:FindFirstChild("bossdropmission") and workspace.bossdropmission:FindFirstChild("missions")
    
    if missionsFolder then
        for _, bossFolder in pairs(missionsFolder:GetChildren()) do
            local bossName = bossFolder.Name
            -- محاولة الوصول لـ Part المطلوب
            local success, targetPart = pcall(function() 
                return bossFolder.missiongiver.Part 
            end)

            if success and targetPart then
                -- إنشاء زر الانتقال في القائمة
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 30)
                row.BackgroundTransparency = 0.8
                row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                row.Parent = ScrollFrame
                Instance.new("UICorner", row)

                local nameTxt = Instance.new("TextLabel", row)
                nameTxt.Text = bossName
                nameTxt.Size = UDim2.new(0.7, 0, 1, 0)
                nameTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
                nameTxt.BackgroundTransparency = 1
                nameTxt.TextSize = 10

                local tpBtn = Instance.new("TextButton", row)
                tpBtn.Text = "نقل"
                tpBtn.Size = UDim2.new(0.25, 0, 0.8, 0)
                tpBtn.Position = UDim2.new(0.7, 0, 0.1, 0)
                tpBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
                tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                Instance.new("UICorner", tpBtn)

                tpBtn.MouseButton1Click:Connect(function()
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = targetPart.CFrame * CFrame.new(0, 5, 0)
                end)
            end
        end
    end
end

-- تفعيل الزر الرئيسي
ToggleBtn.MouseButton1Click:Connect(function()
    espActive = not espActive
    if espActive then
        ToggleBtn.Text = "ESP: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        
        -- تشغيل الـ ESP لكل لافتة
        local missionsFolder = workspace.bossdropmission.missions
        for _, bossFolder in pairs(missionsFolder:GetChildren()) do
            pcall(function()
                local part = bossFolder.missiongiver.Part
                local esp = createESP(part, bossFolder.Name)
                table.insert(currentESPs, esp)
            end)
        end
    else
        ToggleBtn.Text = "ESP: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        for _, v in pairs(currentESPs) do if v then v:Destroy() end end
        currentESPs = {}
    end
end)

-- تشغيل البحث لأول مرة
refreshMissions()
