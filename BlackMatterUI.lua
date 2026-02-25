local BMLibrary = {
    Version = 1.9
}

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Mouse = game:GetService("Players").LocalPlayer:GetMouse()

-- Standard Cursor Assets
local CURSOR_DRAG = "rbxassetid://163023520" -- Dragon/Grab (Reliable ID)
local CURSOR_RESIZE = "rbxassetid://13404403816" -- Diagonal Resize

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
    Main.ClipsDescendants = true

    -- LARGER Resize Handle (Bottom Right)
    local ResizeHandle = Instance.new("TextButton", Main) -- Changed to TextButton for better hit detection
    ResizeHandle.Name = "ResizeHandle"
    ResizeHandle.Size = UDim2.new(0, 30, 0, 30) -- Larger hit area
    ResizeHandle.Position = UDim2.new(1, -30, 1, -30)
    ResizeHandle.BackgroundTransparency = 1
    ResizeHandle.Text = ""
    ResizeHandle.ZIndex = 100

    -- Header Title (Drag Handle)
    local TitleLabel = Instance.new("TextButton", Main) -- Changed to Button to ensure cursor works
    TitleLabel.Name = "TitleHandle"
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 0, 0, 0)
    TitleLabel.Size = UDim2.new(1, 0, 0, 35)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = "   " .. (title or "BMLibrary")
    TitleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Horizontal Gray Line
    local HorizontalLine = Instance.new("Frame", Main)
    HorizontalLine.Position = UDim2.new(0, 0, 0, 35)
    HorizontalLine.Size = UDim2.new(1, 0, 0, 1)
    HorizontalLine.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    HorizontalLine.BorderSizePixel = 0

    -- Vertical Gray Separator
    local VerticalLine = Instance.new("Frame", Main)
    VerticalLine.Position = UDim2.new(0, 120, 0, 36)
    VerticalLine.Size = UDim2.new(0, 1, 1, -36)
    VerticalLine.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    VerticalLine.BorderSizePixel = 0

    -- [RESIZING LOGIC]
    local draggingSize = false
    local startPos, startSize

    ResizeHandle.MouseEnter:Connect(function() Mouse.Icon = CURSOR_RESIZE end)
    ResizeHandle.MouseLeave:Connect(function() if not draggingSize then Mouse.Icon = "" end end)

    ResizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSize = true
            startPos = input.Position
            startSize = Main.Size
        end
    end)

    -- [DRAGGING LOGIC]
    local dragging = false
    local dragStart, startPosDrag

    TitleLabel.MouseEnter:Connect(function() Mouse.Icon = CURSOR_DRAG end)
    TitleLabel.MouseLeave:Connect(function() if not dragging then Mouse.Icon = "" end end)

    TitleLabel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPosDrag = Main.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if draggingSize then
                local delta = input.Position - startPos
                Main.Size = UDim2.new(0, math.max(300, startSize.X.Offset + delta.X), 0, math.max(200, startSize.Y.Offset + delta.Y))
            elseif dragging then
                local delta = input.Position - dragStart
                Main.Position = UDim2.new(startPosDrag.X.Scale, startPosDrag.X.Offset + delta.X, startPosDrag.Y.Scale, startPosDrag.Y.Offset + delta.Y)
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSize = false
            dragging = false
            Mouse.Icon = ""
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
        TabBtn.TextSize = 12
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 4)

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

        if Tabs.ActivePage == nil then
            Tabs.ActivePage = name
            Switch()
        end

        local Elements = {}

        function Elements:CreateButton(text, callback)
            local Btn = Instance.new("TextButton", Page)
            Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            Btn.Size = UDim2.new(1, -5, 0, 32)
            Btn.Font = Enum.Font.GothamSemibold
            Btn.Text = text
            Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            Btn.TextSize = 13
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)

            local Stroke = Instance.new("UIStroke", Btn)
            Stroke.Color = Color3.fromRGB(100, 40, 100)
            Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

            Btn.MouseButton1Click:Connect(callback)
        end

        return Elements
    end

    return Tabs
end

return BMLibrary
