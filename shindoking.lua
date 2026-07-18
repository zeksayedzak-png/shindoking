-- [[ GUI KING V3 - THE GLOBAL RADAR ]] --

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ScrollFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local ToggleBtn = Instance.new("TextButton")
local RefreshBtn = Instance.new("TextButton")
local CountLabel = Instance.new("TextLabel")

ScreenGui.Name = "GuiKingGlobal"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- زر التشغيل (أعلى اليمين)
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Parent = ScreenGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ToggleBtn.BorderColor3 = Color3.fromRGB(255, 0, 0)
ToggleBtn.BorderSizePixel = 2
ToggleBtn.Position = UDim2.new(0.85, 0, 0.05, 0)
ToggleBtn.Size = UDim2.new(0, 100, 0, 40)
ToggleBtn.Text = "KING: ON"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.TextScaled = true

-- الواجهة الرئيسية
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
MainFrame.BorderSizePixel = 1
MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 400, 0, 500)
MainFrame.Active = true
MainFrame.Draggable = true

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
Title.Text = "GUI KING V3 - GLOBAL SCAN"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true

CountLabel.Parent = MainFrame
CountLabel.Size = UDim2.new(1, 0, 0, 25)
CountLabel.Position = UDim2.new(0, 0, 0, 45)
CountLabel.Text = "Scanning all services..."
CountLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
CountLabel.BackgroundTransparency = 1

RefreshBtn.Parent = MainFrame
RefreshBtn.Size = UDim2.new(0, 80, 0, 30)
RefreshBtn.Position = UDim2.new(0.78, 0, 0.015, 0)
RefreshBtn.Text = "REFRESH"
RefreshBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
RefreshBtn.TextColor3 = Color3.new(1, 1, 1)

ScrollFrame.Parent = MainFrame
ScrollFrame.Position = UDim2.new(0, 10, 0, 80)
ScrollFrame.Size = UDim2.new(0, 380, 0, 410)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 4

UIListLayout.Parent = ScrollFrame
UIListLayout.Padding = UDim.new(0, 10)

-- دالة لإضافة العناصر للقائمة
local function createEntry(obj)
    local parentName = obj.Parent and obj.Parent.Name or "Unknown"
    local location = obj:FindFirstAncestorOfClass("DataModel") and "Active" or "Storage"
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 80)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.Parent = ScrollFrame

    local nameText = Instance.new("TextLabel")
    nameText.Parent = frame
    nameText.Size = UDim2.new(1, 0, 0, 30)
    nameText.Text = " [" .. obj.ClassName .. "] " .. parentName
    nameText.TextColor3 = Color3.new(1, 1, 1)
    nameText.TextXAlignment = Enum.TextXAlignment.Left
    nameText.BackgroundTransparency = 1

    local xrayBtn = Instance.new("TextButton")
    xrayBtn.Parent = frame
    xrayBtn.Position = UDim2.new(0.02, 0, 0.45, 0)
    xrayBtn.Size = UDim2.new(0, 120, 0, 30)
    xrayBtn.Text = "X-RAY (RED)"
    xrayBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    xrayBtn.TextColor3 = Color3.new(1, 1, 1)

    local copyBtn = Instance.new("TextButton")
    copyBtn.Parent = frame
    copyBtn.Position = UDim2.new(0.35, 5, 0.45, 0)
    copyBtn.Size = UDim2.new(0, 120, 0, 30)
    copyBtn.Text = "COPY PATH"
    copyBtn.BackgroundColor3 = Color3.fromRGB(0, 50, 100)
    copyBtn.TextColor3 = Color3.new(1, 1, 1)

    -- ميزة X-Ray
    local highlight = nil
    xrayBtn.MouseButton1Click:Connect(function()
        local target = obj.Adornee or obj.Parent
        if not target:IsDescendantOf(game.Workspace) then
            xrayBtn.Text = "IN STORAGE"
            wait(1)
            xrayBtn.Text = "X-RAY (RED)"
            return
        end

        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Parent = target
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.new(1, 1, 1)
            xrayBtn.Text = "OFF X-RAY"
            xrayBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        else
            highlight:Destroy()
            highlight = nil
            xrayBtn.Text = "X-RAY (RED)"
            xrayBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
        end
    end)

    -- ميزة النسخ
    copyBtn.MouseButton1Click:Connect(function()
        setclipboard(obj:GetFullName())
        copyBtn.Text = "COPIED!"
        wait(1)
        copyBtn.Text = "COPY PATH"
    end)
end

-- الماسح العالمي الشامل
local function GlobalScan()
    for _, item in pairs(ScrollFrame:GetChildren()) do
        if item:IsA("Frame") then item:Destroy() end
    end
    
    local count = 0
    -- قائمة الخدمات التي سنبحث فيها
    local services = {game.Workspace, game.ReplicatedStorage, game.Players, game.StarterGui}

    for _, service in pairs(services) do
        for _, v in pairs(service:GetDescendants()) do
            if v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
                createEntry(v)
                count = count + 1
            end
        end
        task.wait(0.1) -- حماية من الـ Lag أثناء الانتقال بين الخدمات
    end
    
    CountLabel.Text = "Found: " .. count .. " Objects in Global Scan"
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
end

-- الأزرار
RefreshBtn.MouseButton1Click:Connect(GlobalScan)
ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    ToggleBtn.Text = MainFrame.Visible and "KING: ON" or "KING: OFF"
end)

-- بدء المسح
GlobalScan()
