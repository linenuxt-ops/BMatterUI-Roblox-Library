local BlackMatterUI = {}
BlackMatterUI.__index = BlackMatterUI

local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

function BlackMatterUI.new(titleText)
    local self = setmetatable({}, BlackMatterUI)
    
    local MENU_ID = "BlackMatterUI_Edition"
    local VERSION_NUMBER = 7.9 -- Incremented for the aesthetic resize update

    local existing = CoreGui:FindFirstChild(MENU_ID) or Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild(MENU_ID)
    if existing then
        existing:Destroy()
    end
    
    _G.BlackMatterVersion = VERSION_NUMBER

    self.MainUI = Instance.new("ScreenGui")
    self.MainUI.Name = MENU_ID
    self.MainUI.ResetOnSpawn = false
    pcall(function() self.MainUI.Parent = CoreGui end)
    if not self.MainUI.Parent then self.MainUI.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

    self.PickingColor = false
    self.Pages = {}
    self.ActiveToasts = {}
    self.FirstTabCreated = false

    -- Main Window
    local MainFrame = Instance.new("Frame", self.MainUI)
    MainFrame.Name = "MainFrame"
    MainFrame.Size, MainFrame.Position = UDim2.new(0, 750, 0, 500), UDim2.new(0.5, -375, 0.5, -250)
    MainFrame.BackgroundColor3, MainFrame.BackgroundTransparency = Color3.fromRGB(10, 12, 25), 0.15
    MainFrame.Active = true
    MainFrame.ClipsDescendants = true -- CRITICAL: This makes the circle "slice" look like part of the corner
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
    self.MainFrame = MainFrame 
    
    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Thickness, MainStroke.Color, MainStroke.Transparency = 1.8, Color3.fromRGB(120, 80, 255), 0.5
    self.Accent = MainStroke

    -- ROUNDED RESIZE HANDLE (Slice of circle)
    local ResizeHandle = Instance.new("ImageButton", MainFrame)
    ResizeHandle.Name = "ResizeHandle"
    ResizeHandle.Size = UDim2.new(0, 30, 0, 30)
    ResizeHandle.Position = UDim2.new(1, -15, 1, -15) -- Offset so only the top-left quarter of the circle shows
    ResizeHandle.BackgroundTransparency = 1
    ResizeHandle.Image = "rbxassetid://6031064368" -- High quality circle
    ResizeHandle.ImageColor3 = Color3.fromRGB(120, 80, 255)
    ResizeHandle.ImageTransparency = 0.7
    ResizeHandle.ZIndex = 100

    -- Search Bar Logic
    local SearchFrame = Instance.new("Frame", MainFrame)
    SearchFrame.Name = "SearchFrame"
    SearchFrame.Size, SearchFrame.Position = UDim2.new(1, -210, 0, 35), UDim2.new(0, 195, 0, 15)
    SearchFrame.BackgroundColor3, SearchFrame.BackgroundTransparency = Color3.fromRGB(30,30,60), 0.5
    SearchFrame.ZIndex = 10
    Instance.new("UICorner", SearchFrame).CornerRadius = UDim.new(0, 8)

    local SearchInput = Instance.new("TextBox", SearchFrame)
    SearchInput.Size, SearchInput.Position, SearchInput.BackgroundTransparency = UDim2.new(1, -10, 1, 0), UDim2.new(0, 10, 0, 0), 1
    SearchInput.Text, SearchInput.PlaceholderText, SearchInput.TextColor3 = "", "Search features...", Color3.new(1,1,1)
    SearchInput.Font, SearchInput.TextSize, SearchInput.TextXAlignment = Enum.Font.Gotham, 13, Enum.TextXAlignment.Left
    SearchInput.ZIndex = 11

    -- [Search Input Logic remains same as your previous code...]
    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchInput.Text:lower()
        for _, page in pairs(self.Pages) do
            for _, col in pairs({page.Left, page.Right}) do
                for _, card in pairs(col:GetChildren()) do
                    if card:IsA("Frame") then
                        if query == "" then card.Visible = true continue end
                        local foundMatch = false
                        if card.Name:lower():find(query) then foundMatch = true end
                        local content = card:FindFirstChild("Frame")
                        if content and not foundMatch then
                            for _, element in pairs(content:GetChildren()) do
                                if (element:IsA("TextButton") or element:IsA("TextLabel")) then
                                    if element.Text:lower():find(query) then foundMatch = true break end
                                elseif element:IsA("Frame") or element:IsA("CanvasGroup") then
                                    local subLabel = element:FindFirstChildWhichIsA("TextLabel")
                                    if subLabel and subLabel.Text:lower():find(query) then foundMatch = true break end
                                end
                            end
                        end
                        card.Visible = foundMatch
                    end
                end
            end
        end
    end)

    -- Sidebar
    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Size, Sidebar.BackgroundColor3 = UDim2.new(0, 180, 1, 0), Color3.fromRGB(15, 15, 35)
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)
    
    local Title = Instance.new("TextLabel", Sidebar)
    Title.Size, Title.BackgroundTransparency = UDim2.new(1, 0, 0, 65), 1
    Title.Text = titleText or "BLACKMATTER"
    Title.TextColor3, Title.Font, Title.TextSize = Color3.fromRGB(180, 150, 255), Enum.Font.GothamBold, 18

    self.Nav = Instance.new("Frame", Sidebar)
    self.Nav.Size, self.Nav.Position, self.Nav.BackgroundTransparency = UDim2.new(1, 0, 1, -75), UDim2.new(0, 0, 0, 70), 1
    local NavLayout = Instance.new("UIListLayout", self.Nav)
    NavLayout.Padding, NavLayout.HorizontalAlignment = UDim.new(0, 8), Enum.HorizontalAlignment.Center

    self.Content = Instance.new("Frame", MainFrame)
    self.Content.Name = "Content"
    self.Content.Size, self.Content.Position, self.Content.BackgroundTransparency = UDim2.new(1, -180, 1, -60), UDim2.new(0, 180, 0, 60), 1

    -- DRAGGING & RESIZING LOGIC
    local dragging, resizing = false, false
    local dragStart, startPos, startSize

    MainFrame.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not self.PickingColor then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)

    ResizeHandle.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            resizing = true
            dragStart = input.Position
            startSize = MainFrame.Size
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then resizing = false end
            end)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                local delta = input.Position - dragStart
                MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            elseif resizing then
                local delta = input.Position - dragStart
                local newX = math.max(450, startSize.X.Offset + delta.X)
                local newY = math.max(350, startSize.Y.Offset + delta.Y)
                MainFrame.Size = UDim2.new(0, newX, 0, newY)
            end
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            resizing = false
        end
    end)

    UIS.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode.Insert then self.MainUI.Enabled = not self.MainUI.Enabled end
    end)

    return self
end

function BlackMatterUI:ShowCriticalUpdate()
    local function showDialog(title, content, isVisible)
        self:Notification(title, "Please wait...")
        print("Dialog Triggered: " .. title)
    end
    showDialog("Critical Update", nil, false)
end

function BlackMatterUI:CreateTab(name)
    local TabBtn = Instance.new("TextButton", self.Nav)
    TabBtn.Size = UDim2.new(0, 150, 0, 38)
    TabBtn.BackgroundColor3, TabBtn.BackgroundTransparency = self.Accent.Color, 0.9
    TabBtn.Text, TabBtn.TextColor3, TabBtn.Font, TabBtn.TextSize = name, Color3.new(0.9,0.9,0.9), Enum.Font.Gotham, 14
    Instance.new("UICorner", TabBtn)

    local Page = Instance.new("Frame", self.Content)
    Page.Name = name .. "_Page"
    Page.Size, Page.BackgroundTransparency, Page.Visible = UDim2.new(1, 0, 1, 0), 1, false

    local function CreateCol(pos)
        local Scroll = Instance.new("ScrollingFrame", Page)
        Scroll.Size, Scroll.Position, Scroll.BackgroundTransparency = UDim2.new(0.5, -10, 1, -10), pos, 1
        Scroll.CanvasSize, Scroll.ScrollBarThickness = UDim2.new(0,0,0,0), 2
        Scroll.ScrollBarImageColor3 = self.Accent.Color
        local Layout = Instance.new("UIListLayout", Scroll)
        Layout.Padding, Layout.HorizontalAlignment = UDim.new(0, 15), Enum.HorizontalAlignment.Center
        local Pad = Instance.new("UIPadding", Scroll)
        Pad.PaddingLeft, Pad.PaddingTop = UDim.new(0, 0), UDim.new(0, 10)
        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Scroll.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 20)
        end)
        return Scroll
    end

    local Left = CreateCol(UDim2.new(0, 2, 0, 5))
    local Right = CreateCol(UDim2.new(0.5, 5, 0, 5))

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(self.Pages) do p.Frame.Visible = false; p.Btn.BackgroundTransparency = 0.9 end
        Page.Visible = true; TabBtn.BackgroundTransparency = 0.6
    end)

    self.Pages[name] = {Frame = Page, Left = Left, Right = Right, Btn = TabBtn}

    if not self.FirstTabCreated then
        self.FirstTabCreated = true
        Page.Visible = true
        TabBtn.BackgroundTransparency = 0.6
    end

    return self.Pages[name]
end

function BlackMatterUI:CreateCard(tab, side, title)
    local parent = (side:lower() == "left") and tab.Left or tab.Right
    local Card = Instance.new("Frame", parent)
    Card.Name = title
    Card.BackgroundColor3, Card.Size = Color3.fromRGB(15, 15, 30), UDim2.new(1, -8, 0, 40)
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 10)
    local CardStroke = Instance.new("UIStroke", Card)
    CardStroke.Color, CardStroke.Transparency = self.Accent.Color, 0.7
    
    local CardTitle = Instance.new("TextLabel", Card)
    CardTitle.Size, CardTitle.Position, CardTitle.BackgroundTransparency = UDim2.new(1, -20, 0, 30), UDim2.new(0, 15, 0, 5), 1
    CardTitle.Text, CardTitle.TextColor3, CardTitle.Font, CardTitle.TextSize = title:upper(), Color3.new(0.6, 0.6, 0.6), Enum.Font.GothamBold, 11
    CardTitle.TextXAlignment = Enum.TextXAlignment.Left

    local Content = Instance.new("Frame", Card)
    Content.Size, Content.Position, Content.BackgroundTransparency = UDim2.new(1, -30, 1, -45), UDim2.new(0, 15, 0, 35), 1
    local Layout = Instance.new("UIListLayout", Content)
    Layout.Padding = UDim.new(0, 12)
    
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Card.Size = UDim2.new(1, -8, 0, Layout.AbsoluteContentSize.Y + 50)
    end)
    return Content
end

function BlackMatterUI:CreateDropdown(parent, text, list, callback)
    local selectedOptions = {}
    local isOpen = false
    
    local Container = Instance.new("Frame", parent)
    Container.Size, Container.BackgroundTransparency = UDim2.new(1, 0, 0, 35), 1
    local CLayout = Instance.new("UIListLayout", Container)
    CLayout.SortOrder, CLayout.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0, 5)

    local MainBtn = Instance.new("TextButton", Container)
    MainBtn.Size, MainBtn.BackgroundColor3, MainBtn.Text = UDim2.new(1, 0, 0, 35), Color3.fromRGB(35, 35, 65), "  " .. text .. " : None"
    MainBtn.TextColor3, MainBtn.Font, MainBtn.TextSize, MainBtn.TextXAlignment = Color3.new(1,1,1), Enum.Font.Gotham, 13, Enum.TextXAlignment.Left
    Instance.new("UICorner", MainBtn).CornerRadius = UDim.new(0, 8)
    
    local AnimContainer = Instance.new("CanvasGroup", Container)
    AnimContainer.Size, AnimContainer.BackgroundTransparency, AnimContainer.GroupTransparency = UDim2.new(1, 0, 0, 0), 1, 1
    
    local ItemList = Instance.new("Frame", AnimContainer)
    ItemList.Size, ItemList.BackgroundColor3 = UDim2.new(1, 0, 1, 0), Color3.fromRGB(20, 20, 45)
    Instance.new("UIListLayout", ItemList)
    Instance.new("UICorner", ItemList).CornerRadius = UDim.new(0, 8)

    local function UpdateText()
        if #selectedOptions == 0 then
            MainBtn.Text = "  " .. text .. " : None"
        else
            MainBtn.Text = "  " .. text .. " : [" .. table.concat(selectedOptions, ", ") .. "]"
        end
        callback(selectedOptions)
    end

    local clear = Instance.new("TextButton", ItemList)
    clear.Size, clear.BackgroundTransparency, clear.Text, clear.TextColor3 = UDim2.new(1, 0, 0, 30), 1, "Clear All", Color3.fromRGB(255, 100, 100)
    clear.Font, clear.TextSize = Enum.Font.GothamBold, 12
    clear.MouseButton1Click:Connect(function()
        table.clear(selectedOptions)
        for _, child in pairs(ItemList:GetChildren()) do
            if child:IsA("TextButton") and child ~= clear then child.TextColor3 = Color3.new(0.8, 0.8, 0.8) end
        end
        UpdateText()
    end)

    for _, item in pairs(list) do
        local itm = Instance.new("TextButton", ItemList)
        itm.Size, itm.BackgroundTransparency, itm.Text, itm.TextColor3 = UDim2.new(1, 0, 0, 30), 1, item, Color3.new(0.8,0.8,0.8)
        itm.Font, itm.TextSize = Enum.Font.Gotham, 12
        itm.MouseButton1Click:Connect(function()
            local foundIndex = table.find(selectedOptions, item)
            if foundIndex then
                table.remove(selectedOptions, foundIndex)
                itm.TextColor3 = Color3.new(0.8, 0.8, 0.8)
            else
                table.insert(selectedOptions, item)
                itm.TextColor3 = self.Accent.Color
            end
            UpdateText()
        end)
    end

    MainBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local targetSize = isOpen and UDim2.new(1, 0, 0, (#list + 1) * 32) or UDim2.new(1, 0, 0, 0)
        TweenService:Create(AnimContainer, TweenInfo.new(0.3), {Size = targetSize, GroupTransparency = isOpen and 0 or 1}):Play()
    end)

    CLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Container.Size = UDim2.new(1, 0, 0, CLayout.AbsoluteContentSize.Y) end)
end

function BlackMatterUI:CreateColorPicker(parent, text, default, callback)
    local h, s, v = default:ToHSV()
    local PickerFrame = Instance.new("Frame", parent)
    PickerFrame.Size, PickerFrame.BackgroundTransparency = UDim2.new(1, 0, 0, 35), 1
    
    local Label = Instance.new("TextLabel", PickerFrame)
    Label.Size, Label.BackgroundTransparency = UDim2.new(1, -45, 1, 0), 1
    Label.Text, Label.TextColor3, Label.Font, Label.TextSize, Label.TextXAlignment = text, Color3.new(1,1,1), Enum.Font.Gotham, 13, Enum.TextXAlignment.Left
    
    local ColorBox = Instance.new("TextButton", PickerFrame)
    ColorBox.Size, ColorBox.Position = UDim2.new(0, 35, 0, 25), UDim2.new(1, -35, 0.5, -12)
    ColorBox.BackgroundColor3 = default
    ColorBox.Text = ""
    Instance.new("UICorner", ColorBox).CornerRadius = UDim.new(0, 6)
    local BoxStroke = Instance.new("UIStroke", ColorBox)
    BoxStroke.Thickness, BoxStroke.Color = 1.5, Color3.new(1,1,1)

    local Popup = Instance.new("Frame", self.MainFrame)
    Popup.Name = "ColorPopup"
    Popup.Size, Popup.Visible, Popup.BackgroundColor3, Popup.Active, Popup.ZIndex = UDim2.new(0, 200, 0, 180), false, Color3.fromRGB(30, 30, 30), true, 500
    Instance.new("UICorner", Popup).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", Popup).Color = Color3.fromRGB(80, 80, 80)

    local HueBar = Instance.new("Frame", Popup)
    HueBar.Size, HueBar.Position, HueBar.ZIndex = UDim2.new(0, 15, 0, 150), UDim2.new(0, 10, 0, 15), 501
    local HueGrad = Instance.new("UIGradient", HueBar)
    HueGrad.Rotation = 90
    HueGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(1,0,0)), ColorSequenceKeypoint.new(0.17, Color3.new(1,1,0)), ColorSequenceKeypoint.new(0.33, Color3.new(0,1,0)), ColorSequenceKeypoint.new(0.5, Color3.new(0,1,1)), ColorSequenceKeypoint.new(0.67, Color3.new(0,0,1)), ColorSequenceKeypoint.new(0.83, Color3.new(1,0,1)), ColorSequenceKeypoint.new(1, Color3.new(1,0,0))})
    Instance.new("UICorner", HueBar).CornerRadius = UDim.new(0, 4)

    local SV = Instance.new("ImageLabel", Popup)
    SV.Size, SV.Position, SV.ZIndex, SV.Image, SV.BackgroundColor3 = UDim2.new(0, 150, 0, 150), UDim2.new(0, 35, 0, 15), 501, "rbxassetid://4155801252", Color3.fromHSV(h, 1, 1)
    Instance.new("UICorner", SV).CornerRadius = UDim.new(0, 4)

    local Cursor = Instance.new("Frame", SV)
    Cursor.Size, Cursor.AnchorPoint, Cursor.ZIndex, Cursor.BackgroundColor3, Cursor.Position = UDim2.new(0, 8, 0, 8), Vector2.new(0.5, 0.5), 502, Color3.new(1,1,1), UDim2.new(s, 0, 1-v, 0)
    Instance.new("UICorner", Cursor).CornerRadius = UDim.new(1, 0)

    local function Update()
        local color = Color3.fromHSV(h, s, v)
        ColorBox.BackgroundColor3 = color
        SV.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        callback(color)
    end

    local dH, dSV = false, false
    HueBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dH = true self.PickingColor = true end end)
    SV.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dSV = true self.PickingColor = true end end)
    
    UIS.InputChanged:Connect(function(input)
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
    
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dH, dSV, self.PickingColor = false, false, false end end)

    ColorBox.MouseButton1Click:Connect(function()
        local rx, ry = ColorBox.AbsolutePosition.X - self.MainFrame.AbsolutePosition.X, ColorBox.AbsolutePosition.Y - self.MainFrame.AbsolutePosition.Y
        Popup.Position = UDim2.new(0, rx - 210, 0, ry)
        Popup.Visible = not Popup.Visible
    end)
    Update()
end

function BlackMatterUI:CreateButton(parent, text, callback)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size, Btn.BackgroundColor3 = UDim2.new(1, 0, 0, 32), Color3.fromRGB(30, 30, 60)
    Btn.Text, Btn.TextColor3, Btn.Font, Btn.TextSize = text, Color3.new(1,1,1), Enum.Font.Gotham, 13
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", Btn).Color = self.Accent.Color
    Btn.MouseButton1Click:Connect(callback)
end

function BlackMatterUI:CreateToggle(parent, text, default, callback)
    local state = default
    local Container = Instance.new("TextButton", parent)
    Container.Size, Container.BackgroundTransparency, Container.Text = UDim2.new(1, 0, 0, 30), 1, ""
    local Label = Instance.new("TextLabel", Container)
    Label.Size, Label.BackgroundTransparency, Label.Text = UDim2.new(1, -50, 1, 0), 1, text
    Label.TextColor3, Label.Font, Label.TextSize = Color3.new(1,1,1), Enum.Font.Gotham, 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Outer = Instance.new("Frame", Container)
    Outer.Size, Outer.Position, Outer.BackgroundColor3 = UDim2.new(0, 38, 0, 20), UDim2.new(1, -40, 0.5, -10), Color3.fromRGB(45, 45, 45)
    Instance.new("UICorner", Outer).CornerRadius = UDim.new(1, 0)
    local Inner = Instance.new("Frame", Outer)
    Inner.Size, Inner.Position = UDim2.new(0, 14, 0, 14), UDim2.new(0, 3, 0.5, -7)
    Inner.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", Inner).CornerRadius = UDim.new(1, 0)

    local function Update()
        local targetPos = state and UDim2.new(0, 21, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        local targetCol = state and self.Accent.Color or Color3.fromRGB(45, 45, 45)
        TweenService:Create(Inner, TweenInfo.new(0.2), {Position = targetPos}):Play()
        TweenService:Create(Outer, TweenInfo.new(0.2), {BackgroundColor3 = targetCol}):Play()
        callback(state)
    end
    Container.MouseButton1Click:Connect(function() state = not state Update() end)
    Update()
end

function BlackMatterUI:Notification(title, message)
    local ToastFrame = Instance.new("Frame", self.MainUI)
    ToastFrame.Size, ToastFrame.Position = UDim2.new(0, 260, 0, 70), UDim2.new(1, 30, 1, -100)
    ToastFrame.BackgroundColor3, ToastFrame.BackgroundTransparency = Color3.fromRGB(15, 20, 45), 0.1
    ToastFrame.ZIndex = 100
    Instance.new("UICorner", ToastFrame).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", ToastFrame).Color = self.Accent.Color
    
    local t = Instance.new("TextLabel", ToastFrame)
    t.Size, t.Position, t.BackgroundTransparency = UDim2.new(1,-20,0,30), UDim2.new(0,15,0,8), 1
    t.Text, t.TextColor3, t.Font, t.TextSize = title:upper(), Color3.new(1,1,1), Enum.Font.GothamBold, 14
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.ZIndex = 101

    local m = Instance.new("TextLabel", ToastFrame)
    m.Size, m.Position, m.BackgroundTransparency = UDim2.new(1,-20,0,30), UDim2.new(0,15,0,32), 1
    m.Text, m.TextColor3, m.Font, m.TextSize = message, Color3.new(1,1,1), Enum.Font.Gotham, 12
    m.TextXAlignment = Enum.TextXAlignment.Left
    m.ZIndex = 101

    table.insert(self.ActiveToasts, ToastFrame)
    local function UpdateToasts()
        for i, frame in ipairs(self.ActiveToasts) do
            local targetPos = UDim2.new(1, -290, 1, -100 - ((#self.ActiveToasts - i) * 80))
            TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Position = targetPos}):Play()
        end
    end
    UpdateToasts()
    task.delay(3.5, function()
        for i, f in ipairs(self.ActiveToasts) do if f == ToastFrame then table.remove(self.ActiveToasts, i) break end end
        TweenService:Create(ToastFrame, TweenInfo.new(0.5), {Position = UDim2.new(1, 30, ToastFrame.Position.Y.Scale, ToastFrame.Position.Y.Offset), BackgroundTransparency = 1}):Play()
        UpdateToasts() task.wait(0.5) ToastFrame:Destroy()
    end)
end

return BlackMatterUI
