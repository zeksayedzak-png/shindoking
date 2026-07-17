-- إنشاء الواجهة بصلاحيات أعلى لضمان الظهور
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BossTrackerV2"
-- محاولة وضع السكربت في CoreGui أو PlayerGui حسب المتاح
local parent = game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Parent = parent

-- الواجهة الرئيسية
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local ToggleButton = Instance.new("TextButton")
local ScrollFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

-- إعدادات الواجهة (مربعة وسوداء وناعمة)
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Position = UDim2.new(0.5, -110, 0.4, -150)
MainFrame.Size = UDim2.new(0, 220, 0, 320)
MainFrame.Active = true
MainFrame.ClipsDescendants = true

UICorner.CornerRadius = UDim1.new(0, 15)
UICorner.Parent = MainFrame

-- جعل الواجهة قابلة للسحب باللمس (كود مخصص للهاتف)
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

-- العنوان
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "رادار اللافتات"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold

-- زر ON/OFF
ToggleButton.Parent = MainFrame
ToggleButton.Position = UDim2.new(0.1, 0, 0.15, 0)
ToggleButton.Size = UDim2.new(0.8, 0, 0, 40)
ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
ToggleButton.Text = "ESP: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 14
Instance.new("UICorner", ToggleButton).CornerRadius = UDim1.new(0, 10)

-- قائمة السكرول
ScrollFrame.Parent = MainFrame
ScrollFrame.Position = UDim2.new(0.05, 0, 0.32, 0)
ScrollFrame.Size = UDim2.new(0.9, 0, 0.63, 0)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.ScrollBarThickness = 2

UIListLayout.Parent = ScrollFrame
UIListLayout.Padding = UDim.new(0, 8)

local espEnabled = false
local espFolders = {}

-- وظيفة البحث عن المسار والتأكد من وجوده
local function getMissionsFolder()
    local bossDrop = workspace:WaitForChild("bossdropmission", 5)
    if bossDrop then
        return bossDrop:WaitForChild("missions", 5)
    end
    return nil
end

-- إنشاء الـ ESP
local function createESP(part, name)
    if not part then return end
    local bgui = Instance.new("BillboardGui", part)
    bgui.Name = "BossESP_UI"
    bgui.AlwaysOnTop = true
    bgui.Size = UDim2.new(0, 100, 0, 40)
    bgui.ExtentsOffset = Vector3.new(0, 4, 0)

    local label = Instance.new("TextLabel", bgui)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.TextColor3 = Color3.fromRGB(0, 255, 255)
    label.TextStrokeTransparency = 0.5
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold

    task.spawn(function()
        while bgui.Parent do
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local dist = math.floor((part.Position - char.HumanoidRootPart.Position).Magnitude)
                label.Text = name .. "\n[" .. dist .. "m]"
            end
            task.wait(0.2)
        end
    end)
    return bgui
end

-- زر التفعيل
ToggleButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        ToggleButton.Text = "ESP: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
        
        local missions = getMissionsFolder()
        if missions then
            for _, bossFolder in pairs(missions:GetChildren()) do
                pcall(function()
                    local target = bossFolder.missiongiver.Part
                    local esp = createESP(target, bossFolder.Name)
                    table.insert(espFolders, esp)
                end)
            end
        end
    else
        ToggleButton.Text = "ESP: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        for _, v in pairs(espFolders) do if v then v:Destroy() end end
        espFolders = {}
    end
end)

-- تحديث قائمة الأزرار للانتقال
local function refreshList()
    for _, v in pairs(ScrollFrame:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
    
    local missions = getMissionsFolder()
    if missions then
        for _, bossFolder in pairs(missions:GetChildren()) do
            local bossName = bossFolder.Name
            
            local item = Instance.new("Frame")
            item.Size = UDim2.new(1, 0, 0, 35)
            item.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            item.Parent = ScrollFrame
            Instance.new("UICorner", item).CornerRadius = UDim1.new(0, 8)
            
            local nLabel = Instance.new("TextLabel", item)
            nLabel.Text = bossName
            nLabel.Size = UDim2.new(0.6, 0, 1, 0)
            nLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nLabel.BackgroundTransparency = 1
            nLabel.TextSize = 12
            
            local tp = Instance.new("TextButton", item)
            tp.Text = "نقل"
            tp.Size = UDim2.new(0.3, 0, 0.7, 0)
            tp.Position = UDim2.new(0.65, 0, 0.15, 0)
            tp.BackgroundColor3 = Color3.fromRGB(60, 60, 180)
            tp.TextColor3 = Color3.fromRGB(255, 255, 255)
            Instance.new("UICorner", tp).CornerRadius = UDim1.new(0, 5)
            
            tp.MouseButton1Click:Connect(function()
                pcall(function()
                    local targetPos = bossFolder.missiongiver.Part.CFrame
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = targetPos * CFrame.new(0, 4, 0)
                end)
            end)
        end
    end
end

refreshList()
print("Script Loaded Successfully!")
