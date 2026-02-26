local BMLibrary = {
    Version = 3.5
}

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Mouse = game:GetService("Players").LocalPlayer:GetMouse()

-- Theme Colors
local THEME_COLOR = Color3.fromRGB(180, 50, 255) 
local TOGGLE_OFF = Color3.fromRGB(45, 45, 45)
local SLIDER_BG = Color3.fromRGB(45, 45, 45)
local ELEMENT_BG = Color3.fromRGB(30, 30, 35)

-- Standard Cursor Assets
local CURSOR_RESIZE = "rbxassetid://13404403816"

local function ForceCleanup()
    for _, child in ipairs(CoreGui:GetChildren()) do
        if child.Name == "BMLibrary_Root" then
            child:Destroy()
        end
    end
end

function BMLibrary:CreateWindow(title)
    ForceCleanup()
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BMLibrary_Root"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Main Window
    local Main = Instance.new("Frame", ScreenGui)
    Main.Name = "Main"
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Size = UDim2.new(0, 0, 0, 0) 
    Main.Active = true
    Main.ClipsDescendants = true
    Main.BackgroundTransparency = 1

    -- Intro Animation
    TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 450, 0, 300),
        BackgroundTransparency = 0
    }):Play()

    -- Resize Icon
    local ResizeIcon = Instance.new("TextLabel", Main)
    ResizeIcon.BackgroundTransparency = 1
    ResizeIcon.Position = UDim2.new(1, -15, 1, -15)
    ResizeIcon.Size = UDim2.new(0, 15, 0, 15)
    ResizeIcon.Font = Enum.Font.GothamBold
    ResizeIcon.Text = "◢" 
    ResizeIcon.TextColor3 = Color3.fromRGB(80, 40, 110)
    ResizeIcon.TextSize = 16
    ResizeIcon.ZIndex = 5

    local ResizeHandle = Instance.new("TextButton", Main)
    ResizeHandle.Size = UDim2.new(0, 30, 0, 30)
    ResizeHandle.Position = UDim2.new(1, -30, 1, -30)
    ResizeHandle.BackgroundTransparency = 1
    ResizeHandle.Text = ""
    ResizeHandle.ZIndex = 100

    -- Header Title (Drag Handle)
    local TitleLabel = Instance.new("TextButton", Main)
    TitleLabel.Name = "TitleHandle"
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Size = UDim2.new(1, 0, 0, 35)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = "    " .. (title or "BMLibrary")
    TitleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local HorizontalLine = Instance.new("Frame", Main)
    HorizontalLine.Position = UDim2.new(0, 0, 0, 35)
    HorizontalLine.Size = UDim2.new(1, 0, 0, 1)
    HorizontalLine.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    HorizontalLine.BorderSizePixel = 0

    local VerticalLine = Instance.new("Frame", Main)
    VerticalLine.Position = UDim2.new(0, 120, 0, 36)
    VerticalLine.Size = UDim2.new(0, 1, 1, -36)
    VerticalLine.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    VerticalLine.BorderSizePixel = 0

    -- Sidebar Search
    local SearchContainer = Instance.new("Frame", Main)
    SearchContainer.Position = UDim2.new(0, 5, 0, 40)
    SearchContainer.Size = UDim2.new(0, 110, 0, 25)
    SearchContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Instance.new("UICorner", SearchContainer).CornerRadius = UDim.new(0, 4)

    local SearchInput = Instance.new("TextBox", SearchContainer)
    SearchInput.Size = UDim2.new(1, -10, 1, 0)
    SearchInput.Position = UDim2.new(0, 5, 0, 0)
    SearchInput.BackgroundTransparency = 1
    SearchInput.PlaceholderText = "Search..."
    SearchInput.Text = ""
    SearchInput.TextColor3 = Color3.new(1, 1, 1)
    SearchInput.Font = Enum.Font.GothamSemibold
    SearchInput.TextSize = 11
    SearchInput.TextXAlignment = Enum.TextXAlignment.Left

    -- Sidebar
    local Sidebar = Instance.new("ScrollingFrame", Main)
    Sidebar.Position = UDim2.new(0, 5, 0, 70)
    Sidebar.Size = UDim2.new(0, 110, 1, -75)
    Sidebar.BackgroundTransparency = 1
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 0

    local SidebarLayout = Instance.new("UIListLayout", Sidebar)
    SidebarLayout.Padding = UDim.new(0, 5)

    -- Page Container
    local PageFolder = Instance.new("Frame", Main)
    PageFolder.Position = UDim2.new(0, 130, 0, 45)
    PageFolder.Size = UDim2.new(1, -140, 1, -55)
    PageFolder.BackgroundTransparency = 1

    -- Corrected Drag & Resize Logic
    local draggingSize, dragging = false, false
    local dragStart, startPosDrag, startSize

    TitleLabel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPosDrag = Main.Position
        end
    end)

    ResizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSize = true
            dragStart = input.Position
            startSize = Main.Size
            startPosDrag = Main.Position -- We need this to offset the anchor shift
        end
    end)


UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        if dragging then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPosDrag.X.Scale, startPosDrag.X.Offset + delta.X, startPosDrag.Y.Scale, startPosDrag.Y.Offset + delta.Y)
        
        elseif draggingSize then
            local delta = input.Position - dragStart
            
            local newSizeX = math.max(300, startSize.X.Offset + delta.X)
            local newSizeY = math.max(200, startSize.Y.Offset + delta.Y)

            Main.Size = UDim2.new(0, newSizeX, 0, newSizeY)

            local changeX = (newSizeX - startSize.X.Offset) / 2
            local changeY = (newSizeY - startSize.Y.Offset) / 2

            Main.Position = UDim2.new(
                startPosDrag.X.Scale, 
                startPosDrag.X.Offset + changeX, 
                startPosDrag.Y.Scale, 
                startPosDrag.Y.Offset + changeY
            )
        end
    end
end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging, draggingSize = false, false
        end
    end)

    -- Search Logic
    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local filter = SearchInput.Text:lower()
        for _, btn in pairs(Sidebar:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.Visible = btn.Text:lower():find(filter) ~= nil
            end
        end
    end)

    local Tabs = { ActivePage = nil, TabCount = 0 }

    function Tabs:CreateCategory(name)
        self.TabCount = self.TabCount + 1
        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(1, -5, 0, 30)
        TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        TabBtn.Text, TabBtn.Font, TabBtn.TextSize = name, Enum.Font.GothamSemibold, 12
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabBtn.BorderSizePixel = 0
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 4)

        local Page = Instance.new("ScrollingFrame", PageFolder)
        Page.Name = name .. "_Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency, Page.Visible, Page.ScrollBarThickness = 1, false, 2
        Page.ScrollBarImageColor3 = THEME_COLOR

        local PageLayout = Instance.new("UIListLayout", Page)
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local function Switch()
            for _, p in pairs(PageFolder:GetChildren()) do p.Visible = false end
            for _, b in pairs(Sidebar:GetChildren()) do 
                if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(25, 25, 30) b.TextColor3 = Color3.fromRGB(150, 150, 150) end
            end
            Page.Visible, TabBtn.BackgroundColor3, TabBtn.TextColor3 = true, Color3.fromRGB(40, 35, 50), Color3.new(1, 1, 1)
        end

        TabBtn.MouseButton1Click:Connect(Switch)
        if self.ActivePage == nil then self.ActivePage = name Switch() end

        local Elements = { Count = 0 }

        function Elements:CreateLabel(text, align)
            self.Count = self.Count + 1
            local Label = Instance.new("TextLabel", Page)
            Label.LayoutOrder = self.Count
            Label.Size = UDim2.new(1, -5, 0, 20)
            Label.BackgroundTransparency, Label.Text = 1, text
            Label.TextColor3, Label.Font, Label.TextSize = Color3.fromRGB(200, 200, 200), Enum.Font.GothamSemibold, 13
            Label.TextXAlignment = Enum.TextXAlignment[align or "Left"]
        end

        function Elements:CreateCheckbox(text, default, callback)
            self.Count = self.Count + 1
            local state = default or false
            local Container = Instance.new("TextButton", Page)
            Container.LayoutOrder, Container.Size, Container.BackgroundTransparency, Container.Text = self.Count, UDim2.new(1, -5, 0, 32), 1, ""
            
            local Label = Instance.new("TextLabel", Container)
            Label.Size, Label.BackgroundTransparency, Label.Text = UDim2.new(1, -35, 1, 0), 1, text
            Label.TextColor3, Label.Font, Label.TextSize, Label.TextXAlignment = Color3.new(1,1,1), Enum.Font.GothamSemibold, 13, Enum.TextXAlignment.Left
            
            local Box = Instance.new("Frame", Container)
            Box.Size, Box.Position, Box.BackgroundColor3 = UDim2.new(0, 20, 0, 20), UDim2.new(1, -22, 0.5, -10), ELEMENT_BG
            Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)
            
            local Stroke = Instance.new("UIStroke", Box)
            Stroke.Color = state and THEME_COLOR or Color3.fromRGB(60, 60, 65)

            local CheckMark = Instance.new("TextLabel", Box)
            CheckMark.Size, CheckMark.BackgroundTransparency, CheckMark.Text = UDim2.new(1, 0, 1, 0), 1, "✓"
            CheckMark.TextColor3, CheckMark.Font, CheckMark.TextSize = THEME_COLOR, Enum.Font.GothamBold, 14
            CheckMark.TextTransparency = state and 0 or 1

            Container.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(CheckMark, TweenInfo.new(0.2), {TextTransparency = state and 0 or 1}):Play()
                TweenService:Create(Stroke, TweenInfo.new(0.2), {Color = state and THEME_COLOR or Color3.fromRGB(60, 60, 65)}):Play()
                if callback then callback(state) end
            end)
        end

        function Elements:CreateToggle(text, default, callback)
            self.Count = self.Count + 1
            local state = default or false
            local Container = Instance.new("TextButton", Page)
            Container.LayoutOrder, Container.Size, Container.BackgroundTransparency, Container.Text = self.Count, UDim2.new(1, -5, 0, 32), 1, ""
            
            local Label = Instance.new("TextLabel", Container)
            Label.Size, Label.BackgroundTransparency, Label.Text = UDim2.new(1, -50, 1, 0), 1, text
            Label.TextColor3, Label.Font, Label.TextSize, Label.TextXAlignment = Color3.new(1,1,1), Enum.Font.GothamSemibold, 13, Enum.TextXAlignment.Left
            
            local Outer = Instance.new("Frame", Container)
            Outer.Size, Outer.Position, Outer.BackgroundColor3 = UDim2.new(0, 38, 0, 20), UDim2.new(1, -40, 0.5, -10), (state and THEME_COLOR or TOGGLE_OFF)
            Instance.new("UICorner", Outer).CornerRadius = UDim.new(1, 0)
            
            local Inner = Instance.new("Frame", Outer)
            Inner.Size, Inner.Position = UDim2.new(0, 14, 0, 14), UDim2.new(0, state and 21 or 3, 0.5, -7)
            Inner.BackgroundColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", Inner).CornerRadius = UDim.new(1, 0)
            
            Container.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(Inner, TweenInfo.new(0.2), {Position = UDim2.new(0, state and 21 or 3, 0.5, -7)}):Play()
                TweenService:Create(Outer, TweenInfo.new(0.2), {BackgroundColor3 = state and THEME_COLOR or TOGGLE_OFF}):Play()
                if callback then callback(state) end
            end)
        end

        return Elements
    end

    return Tabs
end

return BMLibrary
