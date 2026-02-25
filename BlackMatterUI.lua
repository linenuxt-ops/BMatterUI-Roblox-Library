local BMLibrary = {
    Version = 1.5
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
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, -225, 0.5, -150)
    Main.Size = UDim2.new(0, 450, 0, 300)
    Main.Active = true
    Main.Draggable = true

    -- Purple/Pink Gradient Border (The Deck)
    local Accent = Instance.new("Frame", Main)
    Accent.Name = "Accent"
    Accent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Accent.BorderSizePixel = 0
    Accent.Size = UDim2.new(1, 0, 0, 2)
    
    local Gradient = Instance.new("UIGradient", Accent)
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 50, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 80, 200))
    }

    -- Header Title
    local TitleLabel = Instance.new("TextLabel", Main)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 12, 0, 5)
    TitleLabel.Size = UDim2.new(0, 200, 0, 30)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = title or "BMLibrary"
    TitleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Sidebar (Left side)
    local Sidebar = Instance.new("ScrollingFrame", Main)
    Sidebar.Name = "Sidebar"
    Sidebar.Position = UDim2.new(0, 5, 0, 40)
    Sidebar.Size = UDim2.new(0, 110, 1, -50)
    Sidebar.BackgroundTransparency = 1
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 0
    Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)

    local SidebarLayout = Instance.new("UIListLayout", Sidebar)
    SidebarLayout.Padding = UDim.new(0, 5)
    SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    -- Auto-resize Sidebar Canvas
    SidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Sidebar.CanvasSize = UDim2.new(0, 0, 0, SidebarLayout.AbsoluteContentSize.Y)
    end)

    -- Gray Vertical Separator
    local Separator = Instance.new("Frame", Main)
    Separator.Name = "Separator"
    Separator.Position = UDim2.new(0, 120, 0, 40)
    Separator.Size = UDim2.new(0, 1, 1, -50)
    Separator.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    Separator.BorderSizePixel = 0

    -- Pages Container
    local PageFolder = Instance.new("Frame", Main)
    PageFolder.Name = "Pages"
    PageFolder.Position = UDim2.new(0, 130, 0, 40)
    PageFolder.Size = UDim2.new(1, -140, 1, -50)
    PageFolder.BackgroundTransparency = 1

    local Tabs = { ActivePage = nil }

    function Tabs:CreateCategory(name)
        -- Sidebar Button
        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(1, -5, 0, 30)
        TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        TabBtn.Font = Enum.Font.GothamSemibold
        TabBtn.Text = name
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabBtn.TextSize = 12
        TabBtn.BorderSizePixel = 0
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 4)

        -- The Content Page
        local Page = Instance.new("ScrollingFrame", PageFolder)
        Page.Name = name .. "_Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Color3.fromRGB(180, 50, 255)

        local PageLayout = Instance.new("UIListLayout", Page)
        PageLayout.Padding = UDim.new(0, 6)
        
        -- Auto-resize Page Canvas
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y)
        end)

        local function Switch()
            for _, p in pairs(PageFolder:GetChildren()) do p.Visible = false end
            for _, b in pairs(Sidebar:GetChildren()) do 
                if b:IsA("TextButton") then
                    b.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
                    b.TextColor3 = Color3.fromRGB(150, 150, 150)
                end
            end
            Page.Visible = true
            TabBtn.BackgroundColor3 = Color3.fromRGB(40, 35, 50)
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end

        TabBtn.MouseButton1Click:Connect(Switch)

        -- Load first tab automatically
        if Tabs.ActivePage == nil then
            Tabs.ActivePage = name
            Switch()
        end

        local Elements = {}

        function Elements:CreateButton(text, callback)
            local Btn = Instance.new("TextButton", Page)
            Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            Btn.BorderSizePixel = 0
            Btn.Size = UDim2.new(1, -5, 0, 32)
            Btn.Font = Enum.Font.GothamSemibold
            Btn.Text = text
            Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            Btn.TextSize = 13
            Btn.AutoButtonColor = false
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)

            local Stroke = Instance.new("UIStroke", Btn)
            Stroke.Color = Color3.fromRGB(100, 40, 100)
            Stroke.Thickness = 1
            Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

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

    return Tabs
end

return BMLibrary
