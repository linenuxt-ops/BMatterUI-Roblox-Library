local BMLibrary = {
    Version = 1.2
}

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- Cleanup logic to kill previous versions
local function ForceCleanup()
    for _, child in ipairs(CoreGui:GetChildren()) do
        if child.Name == "BMLibrary_Root" or child:GetAttribute("BMLib_Version") then
            child:Destroy()
        end
    end
end

function BMLibrary:CreateWindow(title)
    ForceCleanup()
    task.wait(0.05)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BMLibrary_Root"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui:SetAttribute("BMLib_Version", self.Version)

    -- Main Window
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20) -- Very dark blue/black
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, -200, 0.5, -150)
    Main.Size = UDim2.new(0, 400, 0, 300)
    Main.Active = true
    Main.Draggable = true

    -- Purple Gradient Border (Top)
    local Accent = Instance.new("Frame")
    Accent.Name = "Accent"
    Accent.Parent = Main
    Accent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Accent.BorderSizePixel = 0
    Accent.Size = UDim2.new(1, 0, 0, 2)
    
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 50, 255)), -- Purple
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 80, 200))  -- Pink
    }
    Gradient.Parent = Accent

    -- Header Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = Main
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 12, 0, 5)
    Title.Size = UDim2.new(1, -24, 0, 30)
    Title.Font = Enum.Font.GothamBold
    Title.Text = title or "BMLibrary"
    Title.TextColor3 = Color3.fromRGB(220, 220, 220)
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left

    -- Container
    local Container = Instance.new("ScrollingFrame")
    Container.Name = "Container"
    Container.Parent = Main
    Container.Active = true
    Container.BackgroundTransparency = 1
    Container.BorderSizePixel = 0
    Container.Position = UDim2.new(0, 10, 0, 40)
    Container.Size = UDim2.new(1, -20, 1, -50)
    Container.ScrollBarThickness = 3
    Container.ScrollBarImageColor3 = Color3.fromRGB(180, 50, 255)

    local Layout = Instance.new("UIListLayout")
    Layout.Parent = Container
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 6)

    local Elements = {}

    function Elements:CreateButton(text, callback)
        local Btn = Instance.new("TextButton")
        Btn.Name = text .. "_Btn"
        Btn.Parent = Container
        Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        Btn.BorderSizePixel = 0
        Btn.Size = UDim2.new(1, -5, 0, 32)
        Btn.Font = Enum.Font.GothamSemibold
        Btn.Text = text
        Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        Btn.TextSize = 13
        Btn.AutoButtonColor = false

        -- Button Corner
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 4)
        Corner.Parent = Btn

        -- Darker pink border for buttons
        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Color3.fromRGB(100, 40, 100)
        Stroke.Thickness = 1
        Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        Stroke.Parent = Btn

        -- Hover Effects
        Btn.MouseEnter:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 40, 55)}):Play()
            TweenService:Create(Stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(255, 80, 200)}):Play()
        end)
        
        Btn.MouseLeave:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 35)}):Play()
            TweenService:Create(Stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(100, 40, 100)}):Play()
        end)

        Btn.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)
    end

    return Elements
end

return BMLibrary
