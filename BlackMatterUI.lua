local BMLibrary = {
    Version = 1.3
}

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

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
    ScreenGui:SetAttribute("BMLib_Version", self.Version)

    -- Main Window
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, -250, 0.5, -175)
    Main.Size = UDim2.new(0, 500, 0, 350)
    Main.ClipsDescendants = true
    Main.Active = true
    Main.Draggable = true

    -- Top Accent Gradient (The "Deck" stays on top)
    local Accent = Instance.new("Frame", Main)
    Accent.Size = UDim2.new(1, 0, 0, 2)
    Accent.BorderSizePixel = 0
    local Grad = Instance.new("UIGradient", Accent)
    Grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 50, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 80, 200))
    }

    -- Title
    local Title = Instance.new("TextLabel", Main)
    Title.Position = UDim2.new(0, 15, 0, 8)
    Title.Size = UDim2.new(0, 200, 0, 25)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = title or "BMLibrary"
    Title.TextColor3 = Color3.fromRGB(230, 230, 230)
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left

    -- Sidebar (Left)
    local Sidebar = Instance.new("ScrollingFrame", Main)
    Sidebar.Name = "Sidebar"
    Sidebar.Position = UDim2.new(0, 0, 0, 40)
    Sidebar.Size = UDim2.new(0, 130, 1, -40)
    Sidebar.BackgroundTransparency = 1
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 0
    
    local SidebarLayout = Instance.new("UIListLayout", Sidebar)
    SidebarLayout.Padding = UDim.new(0, 5)
    SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- Vertical Gray Separator
    local Separator = Instance.new("Frame", Main)
    Separator.Name = "Separator"
    Separator.Position = UDim2.new(0, 130, 0, 45) -- Starts below header area
    Separator.Size = UDim2.new(0, 1, 1, -55)
    Separator.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Separator.BorderSizePixel = 0

    -- Container for all Tab Pages
    local PageFolder = Instance.new("Frame", Main)
    PageFolder.Name = "Pages"
    PageFolder.Position = UDim2.new(0, 140, 0, 45)
    PageFolder.Size = UDim2.new(1, -150, 1, -55)
    PageFolder.BackgroundTransparency = 1

    local Tabs = {
        ActiveTab = nil,
        Pages = {}
    }

    function Tabs:CreateCategory(name)
        local TabButton = Instance.new("TextButton", Sidebar)
        TabButton.Size = UDim2.new(0, 110, 0, 30)
        TabButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        TabButton.Text = name
        TabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabButton.Font = Enum.Font.GothamSemibold
        TabButton.TextSize = 12
        Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 4)

        local Page = Instance.new("ScrollingFrame", PageFolder)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Color3.fromRGB(180, 50, 255)
        
        local PageLayout = Instance.new("UIListLayout", Page)
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder

        -- Switch Function
        local function OpenTab()
            for _, p in pairs(PageFolder:GetChildren()) do p.Visible = false end
            for _, b in pairs(Sidebar:GetChildren()) do 
                if b:IsA("TextButton") then 
                    TweenService:Create(b, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150, 150, 150), BackgroundColor3 = Color3.fromRGB(25, 25, 30)}):Play()
                end 
            end
            Page.Visible = true
            TweenService:Create(TabButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = Color3.fromRGB(40, 35, 50)}):Play()
        end

        TabButton.MouseButton1Click:Connect(OpenTab)

        -- If first tab, open it
        if Tabs.ActiveTab == nil then
            Tabs.ActiveTab = name
            OpenTab()
        end

        local Elements = {}

        function Elements:CreateButton(text, callback)
            local Btn = Instance.new("TextButton", Page)
            Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            Btn.Size = UDim2.new(1, -5, 0, 32)
            Btn.Font = Enum.Font.Gotham
            Btn.Text = text
            Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            Btn.TextSize = 13
            Btn.AutoButtonColor = false
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)

            local Stroke = Instance.new("UIStroke", Btn)
            Stroke.Color = Color3.fromRGB(100, 40, 100)
            Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

            Btn.MouseEnter:Connect(function()
                TweenService:Create(Stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(255, 80, 200)}):Play()
            end)
            Btn.MouseLeave:Connect(function()
                TweenService:Create(Stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(100, 40, 100)}):Play()
            end)

            Btn.MouseButton1Click:Connect(callback)
        end

        return Elements
    end

    return Tabs
end

return BMLibrary
