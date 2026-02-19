local BlackMatterUI = {}
BlackMatterUI.__index = BlackMatterUI

local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

function BlackMatterUI.new(titleText)
    local self = setmetatable({}, BlackMatterUI)
    
    -- --- VERSION CONTROL ---
    local MENU_ID = "BlackMatterUI_Edition"
    local VERSION_NUMBER = 7.0 

    -- Prevents multiple instances of the same UI from running
    if _G.BlackMatterVersion and _G.BlackMatterVersion >= VERSION_NUMBER then
        local old = CoreGui:FindFirstChild(MENU_ID) or Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild(MENU_ID)
        if old then old:Destroy() end
    end
    _G.BlackMatterVersion = VERSION_NUMBER

    -- --- UI CONSTRUCTION ---
    self.MainUI = Instance.new("ScreenGui")
    self.MainUI.Name = MENU_ID
    self.MainUI.ResetOnSpawn = false
    pcall(function() self.MainUI.Parent = CoreGui end)
    if not self.MainUI.Parent then self.MainUI.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

    self.PickingColor = false
    self.Pages = {}
    self.ActiveToasts = {}

    -- --- MAIN FRAME ---
    local MainFrame = Instance.new("Frame", self.MainUI)
    MainFrame.Size, MainFrame.Position = UDim2.new(0, 750, 0, 500), UDim2.new(0.5, -375, 0.5, -250)
    MainFrame.BackgroundColor3, MainFrame.BackgroundTransparency = Color3.fromRGB(10, 12, 25), 0.15
    MainFrame.Active = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
    
    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Thickness, MainStroke.Color, MainStroke.Transparency = 1.8, Color3.fromRGB(120, 80, 255), 0.5
    self.Accent = MainStroke

    -- Dragging Logic
    local dragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not self.PickingColor then
            dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

    -- Sidebar & Search
    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Size, Sidebar.BackgroundColor3 = UDim2.new(0, 180, 1, 0), Color3.fromRGB(15, 15, 35)
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)
    
    local Title = Instance.new("TextLabel", Sidebar)
    Title.Size, Title.BackgroundTransparency = UDim2.new(1, 0, 0, 65), 1
    Title.Text, Title.TextColor3, Title.Font, Title.TextSize = titleText or "BLACKMATTER", Color3.fromRGB(180, 150, 255), Enum.Font.GothamBold, 18

    self.Nav = Instance.new("Frame", Sidebar)
    self.Nav.Size, self.Nav.Position, self.Nav.BackgroundTransparency = UDim2.new(1, 0, 1, -75), UDim2.new(0, 0, 0, 70), 1
    local NavLayout = Instance.new("UIListLayout", self.Nav)
    NavLayout.Padding, NavLayout.HorizontalAlignment = UDim.new(0, 8), Enum.HorizontalAlignment.Center

    self.Content = Instance.new("Frame", MainFrame)
    self.Content.Size, self.Content.Position, self.Content.BackgroundTransparency = UDim2.new(1, -180, 1, -60), UDim2.new(0, 180, 0, 60), 1

    -- Toggle visibility with Insert
    UIS.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode.Insert then self.MainUI.Enabled = not self.MainUI.Enabled end
    end)

    return self
end

-- --- LIBRARY METHODS ---

function BlackMatterUI:Notification(title, message)
    local ToastFrame = Instance.new("Frame", self.MainUI)
    ToastFrame.Size, ToastFrame.Position = UDim2.new(0, 260, 0, 70), UDim2.new(1, 30, 1, -100)
    ToastFrame.BackgroundColor3, ToastFrame.BackgroundTransparency = Color3.fromRGB(15, 20, 45), 0.1
    Instance.new("UICorner", ToastFrame).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", ToastFrame).Color = self.Accent.Color
    
    local t = Instance.new("TextLabel", ToastFrame)
    t.Size, t.Position, t.BackgroundTransparency = UDim2.new(1,-20,0,30), UDim2.new(0,15,0,8), 1
    t.Text, t.TextColor3, t.Font, t.TextSize = title:upper(), Color3.new(1,1,1), Enum.Font.GothamBold, 14
    t.TextXAlignment = Enum.TextXAlignment.Left

    local m = Instance.new("TextLabel", ToastFrame)
    m.Size, m.Position, m.BackgroundTransparency = UDim2.new(1,-20,0,30), UDim2.new(0,15,0,32), 1
    m.Text, m.TextColor3, m.Font, m.TextSize = message, Color3.new(1,1,1), Enum.Font.Gotham, 12
    m.TextXAlignment = Enum.TextXAlignment.Left

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

function BlackMatterUI:CreateTab(name)
    local TabBtn = Instance.new("TextButton", self.Nav)
    TabBtn.Size = UDim2.new(0, 150, 0, 38)
    TabBtn.BackgroundColor3, TabBtn.BackgroundTransparency = self.Accent.Color, 0.9
    TabBtn.Text, TabBtn.TextColor3, TabBtn.Font, TabBtn.TextSize = name, Color3.new(0.9,0.9,0.9), Enum.Font.Gotham, 14
    Instance.new("UICorner", TabBtn)

    local Page = Instance.new("Frame", self.Content)
    Page.Size, Page.BackgroundTransparency, Page.Visible = UDim2.new(1, 0, 1, 0), 1, false

    local function CreateCol(pos)
        local Scroll = Instance.new("ScrollingFrame", Page)
        Scroll.Size, Scroll.Position, Scroll.BackgroundTransparency = UDim2.new(0.5, -10, 1, -10), pos, 1
        Scroll.CanvasSize, Scroll.ScrollBarThickness = UDim2.new(0,0,0,0), 2
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

return BlackMatterUI
