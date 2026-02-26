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
local CURSOR_DRAG = "rbxassetid://163023520" 
local CURSOR_RESIZE = "rbxassetid://13404403816"

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

    -- Main Window (Now a CanvasGroup for smooth fading)
    local Main = Instance.new("CanvasGroup", ScreenGui)
    Main.Name = "Main"
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Main.BorderSizePixel = 0
    -- Start slightly lower and invisible
    local FinalPos = UDim2.new(0.5, -225, 0.5, -150)
    Main.Position = UDim2.new(0.5, -225, 0.5, -100) 
    Main.Size = UDim2.new(0, 450, 0, 300)
    Main.Active = true
    Main.ClipsDescendants = true
    Main.GroupTransparency = 1 -- Start hidden

    local function PlayIntro()
        -- 1. Create a temporary "Welcome" label for the tour feel
        local WelcomeLabel = Instance.new("TextLabel", Main)
        WelcomeLabel.Size = UDim2.new(1, 0, 1, 0)
        WelcomeLabel.BackgroundTransparency = 1
        WelcomeLabel.Font = Enum.Font.GothamBold
        WelcomeLabel.Text = "Welcome to " .. (title or "BMLibrary")
        WelcomeLabel.TextColor3 = THEME_COLOR
        WelcomeLabel.TextSize = 24
        WelcomeLabel.ZIndex = 100
        WelcomeLabel.TextTransparency = 1

        -- 2. Fade Window In & Slide Up
        TweenService:Create(Main, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = FinalPos,
            GroupTransparency = 0
        }):Play()

        -- 3. Quick Text Reveal
        TweenService:Create(WelcomeLabel, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
        
        task.delay(1.2, function()
            TweenService:Create(WelcomeLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
            task.wait(0.5)
            WelcomeLabel:Destroy()
        end)
    end

    -- Run the intro
    task.spawn(PlayIntro)

    -- Resize Icon
    local ResizeIcon = Instance.new("TextLabel", Main)
    ResizeIcon.Name = "ResizeIcon"
    ResizeIcon.BackgroundTransparency = 1
    ResizeIcon.Position = UDim2.new(1, -15, 1, -15)
    ResizeIcon.Size = UDim2.new(0, 15, 0, 15)
    ResizeIcon.Font = Enum.Font.GothamBold
    ResizeIcon.Text = "◢" 
    ResizeIcon.TextColor3 = Color3.fromRGB(80, 40, 110)
    ResizeIcon.TextSize = 16
    ResizeIcon.ZIndex = 5

    local ResizeHandle = Instance.new("TextButton", Main)
    ResizeHandle.Name = "ResizeHandle"
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

    -- Sidebar
    local Sidebar = Instance.new("ScrollingFrame", Main)
    Sidebar.Name = "Sidebar"
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

    -- Page Container
    local PageFolder = Instance.new("Frame", Main)
    PageFolder.Name = "Pages"
    PageFolder.Position = UDim2.new(0, 130, 0, 45)
    PageFolder.Size = UDim2.new(1, -140, 1, -55)
    PageFolder.BackgroundTransparency = 1

    -- Logic
    local draggingSize, dragging = false, false
    local startPos, startSize, dragStart, startPosDrag

    ResizeHandle.MouseEnter:Connect(function() Mouse.Icon = CURSOR_RESIZE ResizeIcon.TextColor3 = THEME_COLOR end)
    ResizeHandle.MouseLeave:Connect(function() if not draggingSize then Mouse.Icon = "" ResizeIcon.TextColor3 = Color3.fromRGB(80, 40, 110) end end)

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
            startPos = input.Position
            startSize = Main.Size
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
        TabBtn.Text, TabBtn.Font, TabBtn.TextSize = name, Enum.Font.GothamSemibold, 12
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabBtn.BorderSizePixel = 0
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 4)

        local Page = Instance.new("ScrollingFrame", PageFolder)
        Page.Name = name .. "_Page"
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
                if b:IsA("TextButton") then
                    b.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
                    b.TextColor3 = Color3.fromRGB(150, 150, 150)
                end
            end
            Page.Visible, TabBtn.BackgroundColor3, TabBtn.TextColor3 = true, Color3.fromRGB(40, 35, 50), Color3.new(1, 1, 1)
        end

        TabBtn.MouseButton1Click:Connect(Switch)
        if Tabs.ActivePage == nil then Tabs.ActivePage = name Switch() end

        local Elements = {}

        function Elements:CreateLabel(text, align)
            local Label = Instance.new("TextLabel", Page)
            Label.Size = UDim2.new(1, -5, 0, 20)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = Color3.fromRGB(200, 200, 200)
            Label.Font = Enum.Font.GothamSemibold
            Label.TextSize = 13
            
            if align == "Center" or align == "Middle" then
                Label.TextXAlignment = Enum.TextXAlignment.Center
            elseif align == "Right" then
                Label.TextXAlignment = Enum.TextXAlignment.Right
            else
                Label.TextXAlignment = Enum.TextXAlignment.Left
            end
        end

        function Elements:CreateInput(text, placeholder, callback)
            local Container = Instance.new("Frame", Page)
            Container.Size, Container.BackgroundTransparency = UDim2.new(1, -5, 0, 32), 1
            
            local Label = Instance.new("TextLabel", Container)
            Label.Size = UDim2.new(0.4, 0, 1, 0)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = Color3.new(1, 1, 1)
            Label.Font, Label.TextSize, Label.TextXAlignment = Enum.Font.GothamSemibold, 13, Enum.TextXAlignment.Left

            local BoxContainer = Instance.new("Frame", Container)
            BoxContainer.Size = UDim2.new(0.55, 0, 0, 28)
            BoxContainer.Position = UDim2.new(1, 0, 0.5, 0)
            BoxContainer.AnchorPoint = Vector2.new(1, 0.5)
            BoxContainer.BackgroundColor3 = ELEMENT_BG
            Instance.new("UICorner", BoxContainer).CornerRadius = UDim.new(0, 4)
            
            local Stroke = Instance.new("UIStroke", BoxContainer)
            Stroke.Thickness, Stroke.Color, Stroke.ApplyStrokeMode = 1, Color3.fromRGB(45, 45, 50), Enum.ApplyStrokeMode.Border

            local Box = Instance.new("TextBox", BoxContainer)
            Box.Size = UDim2.new(1, -10, 1, 0)
            Box.Position = UDim2.new(0, 5, 0, 0)
            Box.BackgroundTransparency = 1
            Box.Text, Box.PlaceholderText = "", placeholder or "..."
            Box.TextColor3, Box.Font, Box.TextSize = Color3.new(1, 1, 1), Enum.Font.GothamSemibold, 12
            Box.ClearTextOnFocus = false

            Box.Focused:Connect(function() TweenService:Create(Stroke, TweenInfo.new(0.2), {Color = THEME_COLOR}):Play() end)
            Box.FocusLost:Connect(function() 
                TweenService:Create(Stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(45, 45, 50)}):Play() 
                if callback then callback(Box.Text) end 
            end)
        end

       function Elements:CreateCheckbox(text, default, callback)
    local state = default or false
    local Container = Instance.new("TextButton", Page)
    Container.Size = UDim2.new(1, -5, 0, 32) -- Full height to prevent overlapping
    Container.BackgroundTransparency = 1
    Container.Text = ""
    
    local Label = Instance.new("TextLabel", Container)
    Label.Size = UDim2.new(1, -35, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.new(1,1,1)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Box = Instance.new("Frame", Container)
    Box.Size = UDim2.new(0, 20, 0, 20)
    Box.Position = UDim2.new(1, -22, 0.5, -10)
    Box.BackgroundColor3 = ELEMENT_BG
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)
    
    local Stroke = Instance.new("UIStroke", Box)
    Stroke.Thickness = 1
    Stroke.Color = Color3.fromRGB(60, 60, 65)

    local CheckMark = Instance.new("TextLabel", Box)
    CheckMark.Size = UDim2.new(1, 0, 1, 0)
    CheckMark.BackgroundTransparency = 1
    CheckMark.Text = "✓"
    CheckMark.TextColor3 = THEME_COLOR
    CheckMark.Font = Enum.Font.GothamBold
    CheckMark.TextSize = 14
    CheckMark.TextTransparency = state and 0 or 1
    CheckMark.Rotation = state and 0 or -45 -- Initial rotation for animation

    local function Update()
        -- Pop Animation
        Box.Size = UDim2.new(0, 16, 0, 16) -- Shrink
        TweenService:Create(Box, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0, 20, 0, 20)}):Play() -- Pop back
        
        -- Checkmark Animation
        local targetTransparency = state and 0 or 1
        local targetRotation = state and 0 or -45
        
        TweenService:Create(CheckMark, TweenInfo.new(0.2), {
            TextTransparency = targetTransparency,
            Rotation = targetRotation
        }):Play()
        
        TweenService:Create(Stroke, TweenInfo.new(0.2), {
            Color = state and THEME_COLOR or Color3.fromRGB(60, 60, 65)
        }):Play()

        if callback then callback(state) end
    end

    Container.MouseButton1Click:Connect(function()
        state = not state
        Update()
    end)
    
    -- Set initial state without running full animation instantly
    CheckMark.TextTransparency = state and 0 or 1
    Stroke.Color = state and THEME_COLOR or Color3.fromRGB(60, 60, 65)
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
            CLayout.SortOrder, CLayout.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0, 5)

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
                TweenService:Create(AnimContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize, GroupTransparency = isOpen and 0 or 1}):Play()
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
