-- [[ GUI KING V2 - ULTIMATE OBJECT SCANNER ]] --

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ScrollFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local ToggleBtn = Instance.new("TextButton")
local RefreshBtn = Instance.new("TextButton")
local CountLabel = Instance.new("TextLabel")

ScreenGui.Name = "GuiKingV2"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- زر التشغيل والإطفاء (أعلى اليمين)
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Parent = ScreenGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleBtn.BorderSizePixel = 2
ToggleBtn.Position = UDim2.new(0.8, 0, 0.05, 0)
ToggleBtn.Size = UDim2.new(0, 120, 0, 40)
ToggleBtn.Text = "GUI KING: ON"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.TextScaled = true

-- الواجهة الرئيسية السوداء
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.2, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 380, 0, 450)
MainFrame.Active = true
MainFrame.Draggable = true -- سحب باللمس

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(30, 0, 0) -- عنابي غامق ملكي
Title.Text = "GUI KING V2 - SCANNER"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true

CountLabel.Parent = MainFrame
CountLabel.Size = UDim2.new(1, 0, 0, 20)
CountLabel.Position = UDim2.new(0, 0, 0, 40)
CountLabel.Text = "Found: 0 Objects"
CountLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
CountLabel.BackgroundTransparency = 1

RefreshBtn.Parent = MainFrame
RefreshBtn.Size = UDim2.new(0, 100, 0, 30)
RefreshBtn.Position = UDim2.new(0.7, 0, 0.01, 5)
RefreshBtn.Text = "REFRESH"
RefreshBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
RefreshBtn.TextColor3 = Color3.new(1, 1, 1)

ScrollFrame.Parent = MainFrame
ScrollFrame.Position = UDim2.new(0, 10, 0, 70)
ScrollFrame.Size = UDim2.new(0, 360, 0, 370)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 5

UIListLayout.Parent = ScrollFrame
UIListLayout.Padding = UDim.new(0, 8)

-- دالة التنظيف لإعادة المسح
local function ClearList()
    for _, item in pairs(ScrollFrame:GetChildren()) do
        if item:IsA("Frame") then item:Destroy() end
    end
end

-- دالة إنشاء العناصر في القائمة
local function createItem(obj)
    local target = obj.Adornee or obj.Parent
    if not target or not target:IsA("BasePart") then return end

    local itemFrame = Instance.new("Frame")
    itemFrame.Size = UDim2.new(1, -10, 0, 70)
    itemFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    itemFrame.Parent = ScrollFrame

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Parent = itemFrame
    nameLabel.Size = UDim2.new(1, -10, 0, 30)
    nameLabel.Position = UDim2.new(0, 5, 0, 0)
    nameLabel.Text = "Item: " .. target.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left

    local xrayBtn = Instance.new("TextButton")
    xrayBtn.Parent = itemFrame
    xrayBtn.Position = UDim2.new(0, 5, 0, 35)
    xrayBtn.Size = UDim2.new(0, 100, 0, 30)
    xrayBtn.Text = "X-Ray (RED)"
    xrayBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    xrayBtn.TextColor3 = Color3.new(1, 1, 1)

    local copyBtn = Instance.new("TextButton")
    copyBtn.Parent = itemFrame
    copyBtn.Position = UDim2.new(0, 115, 0, 35)
    copyBtn.Size = UDim2.new(0, 100, 0, 30)
    copyBtn.Text = "Copy Path"
    copyBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 150)
    copyBtn.TextColor3 = Color3.new(1, 1, 1)

    -- ميزة X-Ray باللون الأحمر
    local highlight = nil
    xrayBtn.MouseButton1Click:Connect(function()
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Parent = target
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.new(1, 1, 1)
            highlight.FillTransparency = 0.5
            xrayBtn.Text = "STOP X-RAY"
            xrayBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        else
            highlight:Destroy()
            highlight = nil
            xrayBtn.Text = "X-Ray (RED)"
            xrayBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        end
    end)

    -- ميزة نسخ المسار العميق
    copyBtn.MouseButton1Click:Connect(function()
        setclipboard(target:GetFullName())
        copyBtn.Text = "COPIED!"
        wait(1)
        copyBtn.Text = "Copy Path"
    end)
end

-- دالة المسح الشامل (The Scanner)
local function FullScan()
    ClearList()
    local count = 0
    -- المسح في Workspace وكل الجروبات
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
            createItem(v)
            count = count + 1
        end
    end
    CountLabel.Text = "Found: " .. count .. " Floating Objects"
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
end

-- تشغيل الأزرار
RefreshBtn.MouseButton1Click:Connect(FullScan)
ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    ToggleBtn.Text = MainFrame.Visible and "GUI KING: ON" or "GUI KING: OFF"
end)

-- المسح الأول عند التشغيل
FullScan()
