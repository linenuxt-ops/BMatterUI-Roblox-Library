local BMLibrary = {
    Version = 3.6
}

-- Services
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Mouse = Players.LocalPlayer:GetMouse()

-- Theme Defaults
local THEME_COLOR = Color3.fromRGB(180, 50, 255) 
local TOGGLE_OFF = Color3.fromRGB(45, 45, 45)
local SLIDER_BG = Color3.fromRGB(45, 45, 45)
local ELEMENT_BG = Color3.fromRGB(30, 30, 35)

-- Utility: Cleanup existing GUIs
local function ForceCleanup()
    local existing = CoreGui:FindFirstChild("BMLibrary_Root")
    if existing then existing:Destroy() end
end

-- Dialog System (Requirement: onClick syntax)
local function showDialog(title, content, canClose)
    local root = CoreGui:FindFirstChild("BMLibrary_Root")
    if not root then return end
    
    local Overlay = Instance.new("TextButton", root)
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    Overlay.BackgroundTransparency = 0.5
    Overlay.Text = ""
    Overlay.AutoButtonColor = false

    local Dialog = Instance.new("Frame", Overlay)
    Dialog.Size = UDim2.new(0, 280, 0, 150)
    Dialog.Position = UDim2.new(0.5, 0, 0.5, 0)
    Dialog.AnchorPoint = Vector2.new(0.5, 0.5)
    Dialog.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Instance.new("UICorner", Dialog)
    
    local T = Instance.new("TextLabel", Dialog)
    T.Text = title
    T.Size = UDim2.new(1, 0, 0, 40)
    T.TextColor3 = Color3.new(1, 1, 1)
    T.Font = Enum.Font.GothamBold
    T.BackgroundTransparency = 1

    local C = Instance.new("TextLabel", Dialog)
    C.Text = typeof(content) == "string" and content or "Action Required"
    C.Position = UDim2.new(0, 15, 0, 45)
    C.Size = UDim2.new(1, -30, 0, 60)
    C.TextColor3 = Color3.fromRGB(200, 200, 200)
    C.Font = Enum.Font.Gotham
    C.TextWrapped = true
    C.BackgroundTransparency = 1

    if not canClose then
        -- Optional: Logic to keep dialog open until a process finishes
    else
        Overlay.MouseButton1Click:Connect(function() Overlay:Destroy() end)
    end
end

-- Main Window
function BMLibrary:CreateWindow(title, customSize)
    ForceCleanup()
    
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "BMLibrary_Root"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Main = Instance.new("Frame", ScreenGui)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Size = customSize or UDim2.new(0, 450, 0, 300)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Instance.new("UICorner", Main)

    -- Header / Drag Handle
    local TitleLabel = Instance.new("TextButton", Main)
    TitleLabel.Name = "TitleHandle"
    TitleLabel.Size = UDim2.new(1, 0, 0, 35)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "    " .. (title or "BMLibrary")
    TitleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Search Bar
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

    -- Sidebar & Page Folder
    local Sidebar = Instance.new("ScrollingFrame", Main)
    Sidebar.Position = UDim2.new(0, 5, 0, 70)
    Sidebar.Size = UDim2.new(0, 110, 1, -75)
    Sidebar.BackgroundTransparency = 1
    Sidebar.ScrollBarThickness = 0

    local SidebarLayout = Instance.new("UIListLayout", Sidebar)
    SidebarLayout.Padding = UDim.new(0, 5)

    local PageFolder = Instance.new("Frame", Main)
    PageFolder.Position = UDim2.new(0, 130, 0, 45)
    PageFolder.Size = UDim2.new(1, -140, 1, -55)
    PageFolder.BackgroundTransparency = 1

    -- Logic: Dragging
    local dragging, dragStart, startPos
    TitleLabel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    -- Logic: Search Filtering
    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local filter = SearchInput.Text:lower()
        for _, btn in pairs(Sidebar:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.Visible = btn.Text:lower():find(filter) ~= nil
            end
        end
    end)

    local Tabs = { ActivePage = nil }

    function Tabs:CreateCategory(name)
        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(1, -5, 0, 30)
        TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        TabBtn.Text = name
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabBtn.Font = Enum.Font.GothamSemibold
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 4)

        local Page = Instance.new("ScrollingFrame", PageFolder)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.Visible = false
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = THEME_COLOR

        local PageLayout = Instance.new("UIListLayout", Page)
        PageLayout.Padding = UDim.new(0, 6)

        local function Switch()
            for _, p in pairs(PageFolder:GetChildren()) do p.Visible = false end
            for _, b in pairs(Sidebar:GetChildren()) do
                if b:IsA("TextButton") then b.TextColor3 = Color3.fromRGB(150, 150, 150) end
            end
            Page.Visible = true
            TabBtn.TextColor3 = THEME_COLOR
        end

        TabBtn.MouseButton1Click:Connect(Switch)
        if not Tabs.ActivePage then Tabs.ActivePage = name Switch() end

        local Elements = {}

        -- Button with your required onClick showDialog format
        function Elements:CreateButton(text, callback)
            local Btn = Instance.new("TextButton", Page)
            Btn.Size = UDim2.new(1, -5, 0, 32)
            Btn.BackgroundColor3 = ELEMENT_BG
            Btn.Text = text
            Btn.TextColor3 = Color3.new(1, 1, 1)
            Instance.new("UICorner", Btn)

            Btn.MouseButton1Click:Connect(function()
                if callback then callback() end
            end)
        end

        -- Add other elements (Slider, Toggle, etc.) here as needed
        return Elements
    end

    -- External access to the dialog
    function Tabs:ShowUpdateDialog()
        -- Directly using your requested logic
        showDialog("Critical Update", "Please wait...", false)
    end

    return Tabs
end

return BMLibrary
