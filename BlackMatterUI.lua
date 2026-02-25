local BMLibrary = {
    Version = 3.2
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

    local Main = Instance.new("Frame", ScreenGui)
    Main.Name = "Main"
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, -225, 0.5, -150)
    Main.Size = UDim2.new(0, 450, 0, 300)
    Main.Active = true
    Main.ClipsDescendants = true

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

    local Sidebar = Instance.new("ScrollingFrame", Main)
    Sidebar.Position = UDim2.new(0, 5, 0, 40)
    Sidebar.Size = UDim2.new(0, 110, 1, -45)
    Sidebar.BackgroundTransparency = 1
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 0

    local SidebarLayout = Instance.new("UIListLayout", Sidebar)
    SidebarLayout.Padding = UDim.new(0, 5)
    SidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Sidebar.CanvasSize = UDim2.new(0, 0, 0, SidebarLayout.AbsoluteContentSize.Y)
    end)

    local PageFolder = Instance.new("Frame", Main)
    PageFolder.Name = "Pages"
    PageFolder.Position = UDim2.new(0, 130, 0, 45)
    PageFolder.Size = UDim2.new(1, -140, 1, -55)
    PageFolder.BackgroundTransparency = 1

    -- Simple Dragging Logic
    local dragging, dragStart, startPosDrag
    TitleLabel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPosDrag = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPosDrag.X.Scale, startPosDrag.X.Offset + delta.X, startPosDrag.Y.Scale, startPosDrag.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

    local Tabs = { ActivePage = nil }

    function Tabs:CreateCategory(name)
        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(1, -5, 0, 30)
        TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        TabBtn.Text, TabBtn.Font, TabBtn.TextSize = name, Enum.Font.GothamSemibold, 12
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabBtn.BorderSizePixel = 0
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 4)

        local Page = Instance.new("ScrollingFrame", PageFolder)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency, Page.BorderSizePixel = 1, 0
        Page.Visible = false
        Page.ScrollBarThickness, Page.ScrollBarImageColor3 = 2, THEME_COLOR

        local PageLayout = Instance.new("UIListLayout", Page)
        PageLayout.Padding = UDim.new(0, 6)
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)

        local function Switch()
            for _, p in pairs(PageFolder:GetChildren()) do p.Visible = false end
            for _, b in pairs(Sidebar:GetChildren()) do 
                if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(25, 25, 30) b.TextColor3 = Color3.fromRGB(150, 150, 150) end
            end
            Page.Visible = true
            TabBtn.BackgroundColor3, TabBtn.TextColor3 = Color3.fromRGB(40, 35, 50), Color3.new(1, 1, 1)
        end

        TabBtn.MouseButton1Click:Connect(Switch)
        if Tabs.ActivePage == nil then Tabs.ActivePage = name Switch() end

        local Elements = {}

        -- Sonata Style Input Text
        function Elements:CreateInput(text, placeholder, callback)
            local InputFrame = Instance.new("Frame", Page)
            InputFrame.Size, InputFrame.BackgroundTransparency = UDim2.new(1, -5, 0, 45), 1
            
            local Label = Instance.new("TextLabel", InputFrame)
            Label.Size, Label.BackgroundTransparency, Label.Text = UDim2.new(1, 0, 0, 15), 1, text
            Label.TextColor3, Label.Font, Label.TextSize, Label.TextXAlignment = Color3.fromRGB(200, 200, 200), Enum.Font.GothamSemibold, 11, Enum.TextXAlignment.Left
            
            local BoxContainer = Instance.new("Frame", InputFrame)
            BoxContainer.Size, BoxContainer.Position = UDim2.new(1, 0, 0, 26), UDim2.new(0, 0, 0, 18)
            BoxContainer.BackgroundColor3 = ELEMENT_BG
            Instance.new("UICorner", BoxContainer).CornerRadius = UDim.new(0, 4)
            
            local Stroke = Instance.new("UIStroke", BoxContainer)
            Stroke.Thickness, Stroke.Color, Stroke.ApplyStrokeMode = 1, Color3.fromRGB(45, 45, 50), Enum.ApplyStrokeMode.Border

            local Box = Instance.new("TextBox", BoxContainer)
            Box.Size, Box.BackgroundTransparency = UDim2.new(1, -10, 1, 0), 1
            Box.Position = UDim2.new(0, 5, 0, 0)
            Box.Text, Box.PlaceholderText = "", placeholder or "Enter text..."
            Box.TextColor3, Box.PlaceholderColor3 = Color3.new(1, 1, 1), Color3.fromRGB(100, 100, 100)
            Box.Font, Box.TextSize, Box.TextXAlignment = Enum.Font.GothamSemibold, 12, Enum.TextXAlignment.Left
            Box.ClearTextOnFocus = false

            Box.Focused:Connect(function() TweenService:Create(Stroke, TweenInfo.new(0.2), {Color = THEME_COLOR}):Play() end)
            Box.FocusLost:Connect(function() 
                TweenService:Create(Stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(45, 45, 50)}):Play() 
                if callback then callback(Box.Text) end 
            end)
        end

        function Elements:CreateButton(text, callback)
            local Btn = Instance.new("TextButton", Page)
            Btn.BackgroundColor3, Btn.Size = ELEMENT_BG, UDim2.new(1, -5, 0, 32)
            Btn.Font, Btn.Text, Btn.TextColor3, Btn.TextSize = Enum.Font.GothamSemibold, text, Color3.fromRGB(200, 200, 200), 13
            Btn.BorderSizePixel = 0
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
            Btn.MouseButton1Click:Connect(function() if callback then callback() end end)
        end

        function Elements:CreateToggle(text, default, callback)
            local state = default
            local Container = Instance.new("TextButton", Page)
            Container.Size, Container.BackgroundTransparency, Container.Text = UDim2.new(1, -5, 0, 30), 1, ""
            local Label = Instance.new("TextLabel", Container)
            Label.Size, Label.BackgroundTransparency, Label.Text = UDim2.new(1, -50, 1, 0), 1, text
            Label.TextColor3, Label.Font, Label.TextSize, Label.TextXAlignment = Color3.new(1,1,1), Enum.Font.GothamSemibold, 13, Enum.TextXAlignment.Left
            local Outer = Instance.new("Frame", Container)
            Outer.Size, Outer.Position, Outer.BackgroundColor3 = UDim2.new(0, 38, 0, 20), UDim2.new(1, -40, 0.5, -10), TOGGLE_OFF
            Instance.new("UICorner", Outer).CornerRadius = UDim.new(1, 0)
            local Inner = Instance.new("Frame", Outer)
            Inner.Size, Inner.Position, Inner.BackgroundColor3 = UDim2.new(0, 14, 0, 14), UDim2.new(0, 3, 0.5, -7), Color3.new(1,1,1)
            Instance.new("UICorner", Inner).CornerRadius = UDim.new(1, 0)
            local function Update()
                local targetPos = state and UDim2.new(0, 21, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
                TweenService:Create(Inner, TweenInfo.new(0.2), {Position = targetPos}):Play()
                TweenService:Create(Outer, TweenInfo.new(0.2), {BackgroundColor3 = state and THEME_COLOR or TOGGLE_OFF}):Play()
                if callback then callback(state) end
            end
            Container.MouseButton1Click:Connect(function() state = not state Update() end)
            Update()
        end

        function Elements:CreateSlider(text, min, max, default, callback)
            local SliderFrame = Instance.new("Frame", Page)
            SliderFrame.Size, SliderFrame.BackgroundTransparency = UDim2.new(1, -5, 0, 50), 1
            local Label = Instance.new("TextLabel", SliderFrame)
            Label.Size, Label.BackgroundTransparency, Label.Text = UDim2.new(1, 0, 0, 20), 1, text
            Label.TextColor3, Label.Font, Label.TextSize, Label.TextXAlignment = Color3.new(1,1,1), Enum.Font.GothamSemibold, 13, Enum.TextXAlignment.Left
            local ValueLabel = Instance.new("TextLabel", SliderFrame)
            ValueLabel.Size, ValueLabel.BackgroundTransparency, ValueLabel.Text = UDim2.new(1, 0, 0, 20), 1, tostring(default)
            ValueLabel.TextColor3, ValueLabel.Font, ValueLabel.TextSize, ValueLabel.TextXAlignment = Color3.fromRGB(200, 200, 200), Enum.Font.GothamSemibold, 12, Enum.TextXAlignment.Right
            local SliderBack = Instance.new("Frame", SliderFrame)
            SliderBack.Size, SliderBack.Position, SliderBack.BackgroundColor3 = UDim2.new(1, 0, 0, 6), UDim2.new(0, 0, 0, 30), SLIDER_BG
            Instance.new("UICorner", SliderBack).CornerRadius = UDim.new(0, 4)
            local SliderFill = Instance.new("Frame", SliderBack)
            SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            SliderFill.BackgroundColor3 = THEME_COLOR
            Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(0, 4)
            local function Update(input)
                local pos = math.clamp((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * pos)
                SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                ValueLabel.Text = tostring(val)
                if callback then callback(val) end
            end
            local sdragging = false
            SliderBack.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sdragging = true Update(input) end end)
            UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sdragging = false end end)
            UserInputService.InputChanged:Connect(function(input) if sdragging and input.UserInputType == Enum.UserInputType.MouseMovement then Update(input) end end)
        end

        function Elements:CreateDropdown(text, list, callback)
            local Container = Instance.new("Frame", Page)
            Container.Size, Container.BackgroundTransparency = UDim2.new(1, -5, 0, 35), 1
            local CLayout = Instance.new("UIListLayout", Container)
            CLayout.Padding = UDim.new(0, 5)

            local MainBtn = Instance.new("TextButton", Container)
            MainBtn.Size, MainBtn.BackgroundColor3, MainBtn.Text = UDim2.new(1, 0, 0, 35), ELEMENT_BG, "  " .. text .. " : Select"
            MainBtn.TextColor3, MainBtn.Font, MainBtn.TextSize, MainBtn.TextXAlignment = Color3.new(1,1,1), Enum.Font.GothamSemibold, 13, Enum.TextXAlignment.Left
            Instance.new("UICorner", MainBtn).CornerRadius = UDim.new(0, 4)

            local AnimContainer = Instance.new("CanvasGroup", Container)
            AnimContainer.Size, AnimContainer.BackgroundTransparency, AnimContainer.GroupTransparency = UDim2.new(1, 0, 0, 0), 1, 1
            local ItemList = Instance.new("Frame", AnimContainer)
            ItemList.Size, ItemList.BackgroundTransparency = UDim2.new(1, 0, 1, 0), 1
            Instance.new("UIListLayout", ItemList).Padding = UDim.new(0, 2)

            local isOpen = false
            MainBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                local targetSize = isOpen and UDim2.new(1, 0, 0, #list * 32) or UDim2.new(1, 0, 0, 0)
                TweenService:Create(AnimContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = targetSize, GroupTransparency = isOpen and 0 or 1}):Play()
            end)

            for _, item in pairs(list) do
                local itm = Instance.new("TextButton", ItemList)
                itm.Size, itm.BackgroundColor3, itm.Text, itm.TextColor3 = UDim2.new(1, 0, 0, 30), Color3.fromRGB(25, 25, 30), item, Color3.fromRGB(200, 200, 200)
                itm.Font, itm.TextSize, itm.BorderSizePixel = Enum.Font.GothamSemibold, 12, 0
                Instance.new("UICorner", itm).CornerRadius = UDim.new(0, 4)
                itm.MouseButton1Click:Connect(function()
                    MainBtn.Text = "  " .. text .. " : " .. item
                    if callback then callback(item) end
                    isOpen = false
                    TweenService:Create(AnimContainer, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 0), GroupTransparency = 1}):Play()
                end)
            end
            CLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Container.Size = UDim2.new(1, -5, 0, CLayout.AbsoluteContentSize.Y) end)
        end

        return Elements
    end

    return Tabs
end

return BMLibrary
