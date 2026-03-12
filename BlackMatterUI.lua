local BMLibrary = {
    Version = 3.5
}

-- Theme Configuration
local THEME_COLOR = Color3.fromRGB(80, 120, 255) -- Main Accent Color
local ELEMENT_BG = Color3.fromRGB(25, 25, 30)   -- Element Background
local TOGGLE_OFF = Color3.fromRGB(45, 45, 50)   -- Toggle Off State
local SLIDER_BG = Color3.fromRGB(35, 35, 40)    -- Slider Background

-- Services
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Mouse = game:GetService("Players").LocalPlayer:GetMouse()

local ActiveConnections = {}

local function RegisterConnection(conn)
    table.insert(ActiveConnections, conn)
    return conn
end

local function ForceCleanup()
    for _, conn in ipairs(ActiveConnections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    table.clear(ActiveConnections)
    for _, child in ipairs(CoreGui:GetChildren()) do
        if child.Name == "BMLibrary_Root" then child:Destroy() end
    end
end

function BMLibrary:CreateWindow(title)
    ForceCleanup()
    task.wait(0.2)

    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "BMLibrary_Root"
    ScreenGui.ResetOnSpawn = false
    
    local Main = Instance.new("CanvasGroup", ScreenGui)
    Main.Name = "Main"
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Main.Size = UDim2.new(0, 650, 0, 500)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Active = true
    Main.ClipsDescendants = true

    local Sidebar = Instance.new("ScrollingFrame", Main)
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 120, 1, -35)
    Sidebar.Position = UDim2.new(0, 0, 0, 35)
    Sidebar.BackgroundTransparency = 1
    Sidebar.ScrollBarThickness = 2
    local SidebarLayout = Instance.new("UIListLayout", Sidebar)
    SidebarLayout.Padding = UDim.new(0, 5)

    local PageFolder = Instance.new("Folder", Main)
    PageFolder.Name = "Pages"

    -- Title Bar / Draggable Logic
    local TitleLabel = Instance.new("TextButton", Main)
    TitleLabel.Size = UDim2.new(1, 0, 0, 35)
    TitleLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    TitleLabel.BorderSizePixel = 0
    TitleLabel.Text = "  " .. (title or "BMLibrary")
    TitleLabel.TextColor3 = Color3.new(1, 1, 1)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local dragging, dragStart, startPos
    RegisterConnection(TitleLabel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end))
    RegisterConnection(UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))
    RegisterConnection(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end))

    local Tabs = { ActivePage = nil }

    function Tabs:CreateCategory(name)
        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(1, -10, 0, 30)
        TabBtn.BackgroundColor3 = ELEMENT_BG
        TabBtn.Text = name
        TabBtn.TextColor3 = Color3.new(1, 1, 1)
        TabBtn.Font = Enum.Font.GothamSemibold
        TabBtn.TextSize = 12
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 4)
        
        local Page = Instance.new("ScrollingFrame", PageFolder)
        Page.Name = name .. "_Page"
        Page.Size = UDim2.new(1, -130, 1, -45)
        Page.Position = UDim2.new(0, 125, 0, 40)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2
        local PageLayout = Instance.new("UIListLayout", Page)
        PageLayout.Padding = UDim.new(0, 8)

        TabBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(PageFolder:GetChildren()) do p.Visible = false end
            Page.Visible = true
        end)

        local Elements = {}
        
        function Elements:CreateKeybind(text, default, callback)
            local binding = false
            local currentKey = default or Enum.KeyCode.F
            
            local Container = Instance.new("Frame", Page)
            Container.Size, Container.BackgroundTransparency = UDim2.new(1, -5, 0, 32), 1
            
            local Label = Instance.new("TextLabel", Container)
            Label.Size = UDim2.new(0.4, 0, 1, 0)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = Color3.new(1, 1, 1)
            Label.Font, Label.TextSize, Label.TextXAlignment = Enum.Font.GothamSemibold, 13, Enum.TextXAlignment.Left

            local BindBtn = Instance.new("TextButton", Container)
            BindBtn.Size = UDim2.new(0.55, 0, 0, 28)
            BindBtn.Position = UDim2.new(1, 0, 0.5, 0)
            BindBtn.AnchorPoint = Vector2.new(1, 0.5)
            BindBtn.BackgroundColor3 = ELEMENT_BG
            BindBtn.Text = currentKey.Name
            BindBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            BindBtn.Font, BindBtn.TextSize = Enum.Font.GothamSemibold, 12
            Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 4)

            local Stroke = Instance.new("UIStroke", BindBtn)
            Stroke.Thickness, Stroke.Color = 1, Color3.fromRGB(45, 45, 50)

            BindBtn.MouseButton1Click:Connect(function()
                if binding then return end
                binding = true
                BindBtn.Text = "..."
                Stroke.Color = THEME_COLOR
                
                local connection
                connection = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode
                        BindBtn.Text = currentKey.Name
                        Stroke.Color = Color3.fromRGB(45, 45, 50)
                        binding = false
                        if callback then callback(currentKey) end
                        connection:Disconnect()
                    end
                end)
            end)
        end

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
            Container.Size = UDim2.new(1, -5, 0, 32)
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
            Stroke.Thickness, Stroke.Color = 1, Color3.fromRGB(60, 60, 65)

            local CheckMark = Instance.new("TextLabel", Box)
            CheckMark.Size = UDim2.new(1, 0, 1, 0)
            CheckMark.BackgroundTransparency = 1
            CheckMark.Text = "✓"
            CheckMark.TextColor3 = THEME_COLOR
            CheckMark.Font = Enum.Font.GothamBold
            CheckMark.TextSize = 14
            CheckMark.TextTransparency = state and 0 or 1
            CheckMark.Rotation = state and 0 or -45

            local function Update()
                Box.Size = UDim2.new(0, 16, 0, 16)
                TweenService:Create(Box, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0, 20, 0, 20)}):Play()
                TweenService:Create(CheckMark, TweenInfo.new(0.2), {TextTransparency = state and 0 or 1, Rotation = state and 0 or -45}):Play()
                TweenService:Create(Stroke, TweenInfo.new(0.2), {Color = state and THEME_COLOR or Color3.fromRGB(60, 60, 65)}):Play()
                if callback then callback(state) end
            end

            Container.MouseButton1Click:Connect(function() state = not state Update() end)
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

        function Elements:CreateColorPicker(text, default, callback)
            local h, s, v = default:ToHSV()
            local PickingColor = false

            local PickerFrame = Instance.new("Frame", Page)
            PickerFrame.Size, PickerFrame.BackgroundTransparency = UDim2.new(1, -5, 0, 35), 1
            
            local Label = Instance.new("TextLabel", PickerFrame)
            Label.Size, Label.BackgroundTransparency = UDim2.new(1, -45, 1, 0), 1
            Label.Text, Label.TextColor3, Label.Font, Label.TextSize, Label.TextXAlignment = text, Color3.new(1,1,1), Enum.Font.GothamSemibold, 13, Enum.TextXAlignment.Left
            
            local ColorBox = Instance.new("TextButton", PickerFrame)
            ColorBox.Size, ColorBox.Position = UDim2.new(0, 35, 0, 25), UDim2.new(1, -35, 0.5, -12)
            ColorBox.BackgroundColor3 = default
            ColorBox.Text = ""
            Instance.new("UICorner", ColorBox).CornerRadius = UDim.new(0, 4)
            local BoxStroke = Instance.new("UIStroke", ColorBox)
            BoxStroke.Thickness, BoxStroke.Color = 1.5, Color3.new(1,1,1)

            local Popup = Instance.new("Frame", Main)
            Popup.Name = "ColorPopup"
            Popup.Size, Popup.Visible, Popup.BackgroundColor3, Popup.Active, Popup.ZIndex = UDim2.new(0, 260, 0, 170), false, Color3.fromRGB(25, 25, 30), true, 500
            Instance.new("UICorner", Popup).CornerRadius = UDim.new(0, 8)
            local PopStroke = Instance.new("UIStroke", Popup)
            PopStroke.Thickness, PopStroke.Color = 1, Color3.fromRGB(60, 60, 65)

            local HueBar = Instance.new("Frame", Popup)
            HueBar.Size, HueBar.Position, HueBar.ZIndex = UDim2.new(0, 15, 0, 130), UDim2.new(0, 12, 0, 20), 501
            local HueGrad = Instance.new("UIGradient", HueBar)
            HueGrad.Rotation = 90
            HueGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1,0,0)), 
                ColorSequenceKeypoint.new(0.17, Color3.new(1,1,0)), 
                ColorSequenceKeypoint.new(0.33, Color3.new(0,1,0)), 
                ColorSequenceKeypoint.new(0.5, Color3.new(0,1,1)), 
                ColorSequenceKeypoint.new(0.67, Color3.new(0,0,1)), 
                ColorSequenceKeypoint.new(0.83, Color3.new(1,0,1)), 
                ColorSequenceKeypoint.new(1, Color3.new(1,0,0))
            })
            Instance.new("UICorner", HueBar).CornerRadius = UDim.new(0, 4)

            local SV = Instance.new("ImageLabel", Popup)
            SV.Size, SV.Position, SV.ZIndex, SV.Image, SV.BackgroundColor3 = UDim2.new(0, 110, 0, 130), UDim2.new(0, 35, 0, 20), 501, "rbxassetid://4155801252", Color3.fromHSV(h, 1, 1)
            Instance.new("UICorner", SV).CornerRadius = UDim.new(0, 4)

            local Cursor = Instance.new("Frame", SV)
            Cursor.Size, Cursor.AnchorPoint, Cursor.ZIndex, Cursor.BackgroundColor3, Cursor.Position = UDim2.new(0, 8, 0, 8), Vector2.new(0.5, 0.5), 502, Color3.new(1,1,1), UDim2.new(s, 0, 1-v, 0)
            Instance.new("UICorner", Cursor).CornerRadius = UDim.new(1, 0)
            local CursorStroke = Instance.new("UIStroke", Cursor)
            CursorStroke.Thickness, CursorStroke.Color = 1, Color3.new(0,0,0)

            local HexInput = Instance.new("TextBox", Popup)
            HexInput.Size, HexInput.Position, HexInput.ZIndex = UDim2.new(0, 85, 0, 28), UDim2.new(0, 160, 0, 20), 501
            HexInput.BackgroundColor3, HexInput.TextColor3, HexInput.Font, HexInput.TextSize = Color3.fromRGB(40, 40, 45), Color3.new(1,1,1), Enum.Font.GothamSemibold, 11
            HexInput.PlaceholderText = "#FFFFFF"
            HexInput.Text = "#" .. default:ToHex():upper()
            Instance.new("UICorner", HexInput).CornerRadius = UDim.new(0, 4)

            local R_T = Instance.new("TextLabel", Popup)
            R_T.Size, R_T.Position, R_T.ZIndex, R_T.BackgroundTransparency = UDim2.new(0, 80, 0, 20), UDim2.new(0, 165, 0, 55), 501, 1
            R_T.TextColor3, R_T.Font, R_T.TextSize, R_T.TextXAlignment = Color3.fromRGB(200, 200, 200), Enum.Font.GothamSemibold, 12, Enum.TextXAlignment.Left
            
            local G_T = R_T:Clone(); G_T.Parent = Popup; G_T.Position = UDim2.new(0, 165, 0, 75)
            local B_T = R_T:Clone(); B_T.Parent = Popup; B_T.Position = UDim2.new(0, 165, 0, 95)

            local function Update(skipHex)
                local color = Color3.fromHSV(h, s, v)
                ColorBox.BackgroundColor3 = color
                SV.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                R_T.Text = "R: " .. math.floor(color.R * 255)
                G_T.Text = "G: " .. math.floor(color.G * 255)
                B_T.Text = "B: " .. math.floor(color.B * 255)
                if not skipHex then HexInput.Text = "#" .. color:ToHex():upper() end
                if callback then callback(color) end
            end

            HexInput.FocusLost:Connect(function()
                local text = HexInput.Text:gsub("#", "")
                local success, result = pcall(function() return Color3.fromHex(text) end)
                if success and result then
                    h, s, v = result:ToHSV()
                    Cursor.Position = UDim2.new(s, 0, 1-v, 0)
                    Update(false)
                end
            end)

            local dH, dSV = false, false
            HueBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dH = true end end)
            SV.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dSV = true end end)
            
            UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    if dH then 
                        h = 1 - math.clamp((input.Position.Y - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y, 0, 1) 
                        Update()
                    elseif dSV then 
                        s = math.clamp((input.Position.X - SV.AbsolutePosition.X) / SV.AbsoluteSize.X, 0, 1) 
                        v = 1 - math.clamp((input.Position.Y - SV.AbsolutePosition.Y) / SV.AbsoluteSize.Y, 0, 1) 
                        Cursor.Position = UDim2.new(s, 0, 1-v, 0) 
                        Update() 
                    end
                end
            end)
            
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dH, dSV = false, false end end)

            ColorBox.MouseButton1Click:Connect(function()
                if not Popup.Visible then
                    local rx, ry = ColorBox.AbsolutePosition.X - Main.AbsolutePosition.X, ColorBox.AbsolutePosition.Y - Main.AbsolutePosition.Y
                    Popup.Position = UDim2.new(0, rx - 270, 0, ry)
                    Popup.Visible = true
                else
                    Popup.Visible = false
                end
            end)

            Update()
        end

        return Elements
    end

    return Tabs
end

return BMLibrary
