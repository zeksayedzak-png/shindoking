-- [[ GUI KING - OBJECT SCANNER ]] --

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ScrollFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local ToggleBtn = Instance.new("TextButton")

-- إعدادات الـ ScreenGui
ScreenGui.Name = "GuiKingScanner"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- زر التشغيل والإطفاء (أعلى اليمين)
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Parent = ScreenGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleBtn.Position = UDim2.new(0.85, 0, 0.05, 0)
ToggleBtn.Size = UDim2.new(0, 100, 0, 40)
ToggleBtn.Text = "GUI KING: ON"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.TextScaled = true

-- الواجهة الرئيسية (سوداء)
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 350, 0, 400)
MainFrame.Active = true
MainFrame.Draggable = true -- تفعيل السحب باللمس

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.Text = "GUI KING - SCANNER"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true

ScrollFrame.Parent = MainFrame
ScrollFrame.Position = UDim2.new(0, 5, 0, 50)
ScrollFrame.Size = UDim2.new(0, 340, 0, 340)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.CanvasSize = UDim2.new(0, 0, 10, 0)

UIListLayout.Parent = ScrollFrame
UIListLayout.Padding = UDim.new(0, 5)

-- وظيفة زر ON/OFF
ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    ToggleBtn.Text = MainFrame.Visible and "GUI KING: ON" or "GUI KING: OFF"
end)

-- دالة لإنشاء عناصر القائمة
local function createItem(obj)
    local itemFrame = Instance.new("Frame")
    local nameLabel = Instance.new("TextLabel")
    local xrayBtn = Instance.new("TextButton")
    local copyBtn = Instance.new("TextButton")

    itemFrame.Size = UDim2.new(1, -10, 0, 60)
    itemFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    itemFrame.Parent = ScrollFrame

    nameLabel.Parent = itemFrame
    nameLabel.Size = UDim2.new(1, 0, 0, 25)
    nameLabel.Text = "Obj: " .. obj.Parent.Name
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left

    xrayBtn.Parent = itemFrame
    xrayBtn.Position = UDim2.new(0, 5, 0, 30)
    xrayBtn.Size = UDim2.new(0, 80, 0, 25)
    xrayBtn.Text = "X-Ray"
    xrayBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)

    copyBtn.Parent = itemFrame
    copyBtn.Position = UDim2.new(0, 95, 0, 30)
    copyBtn.Size = UDim2.new(0, 80, 0, 25)
    copyBtn.Text = "Copy Info"
    copyBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 255)

    -- ميزة X-Ray (Highlight)
    local highlighted = false
    xrayBtn.MouseButton1Click:Connect(function()
        local target = obj.Adornee or obj.Parent
        if not highlighted then
            local hl = Instance.new("Highlight")
            hl.Name = "KingXray"
            hl.FillColor = Color3.new(0, 0, 0) -- هالة سوداء
            hl.OutlineColor = Color3.new(1, 1, 1)
            hl.Parent = target
            highlighted = true
            xrayBtn.Text = "Un-XRay"
        else
            if target:FindFirstChild("KingXray") then
                target.KingXray:Destroy()
            end
            highlighted = false
            xrayBtn.Text = "X-Ray"
        end
    end)

    -- ميزة النسخ
    copyBtn.MouseButton1Click:Connect(function()
        local target = obj.Adornee or obj.Parent
        local info = "Name: " .. target.Name .. 
                     "\nPath: " .. target:GetFullName() .. 
                     "\nPos: " .. tostring(target.Position)
        setclipboard(info)
        copyBtn.Text = "Copied!"
        wait(1)
        copyBtn.Text = "Copy Info"
    end)
end

-- عمل مسح (Scan) لكل الـ BillboardGui في الماب
for _, v in pairs(game.Workspace:GetDescendants()) do
    if v:IsA("BillboardGui") then
        createItem(v)
    end
end

print("GUI KING Loaded Successfully!")
