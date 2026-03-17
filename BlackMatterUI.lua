local BM_UI = { Version = "1.1.0" }

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local CoreGui = game:GetService("CoreGui")

local STYLE = {
    Primary = Color3.fromRGB(80, 40, 120),
    Background = Color3.fromRGB(20, 20, 25),
    Surface = Color3.fromRGB(30, 30, 35),
    Text = Color3.fromRGB(240, 240, 240),
    Stroke = Color3.fromRGB(255, 255, 255),
    GrayLine = Color3.fromRGB(50, 50, 55)
}

local function getTableCount(t)
    local c = 0
    for _ in pairs(t) do c = c + 1 end
    return c
end

local function Cleanup()
    for _, obj in ipairs(PlayerGui:GetChildren()) do
        if obj.Name == "BM_DevUI" then obj:Destroy() end
    end
end

function BM_UI:Init(title)
    local success, result = pcall(function()
        Cleanup()

        local ScreenGui = Instance.new("ScreenGui", PlayerGui)
        ScreenGui.Name = "BM_DevUI"
        ScreenGui.DisplayOrder = 999999
        ScreenGui.ResetOnSpawn = false

        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if input.KeyCode == Enum.KeyCode.RightControl then
                ScreenGui.Enabled = not ScreenGui.Enabled
            end
        end)

        local Main = Instance.new("Frame", ScreenGui)
        Main.Size = UDim2.new(0, 900, 0, 700)
        Main.Position = UDim2.new(0.5, 0, 0.5, 0)
        Main.AnchorPoint = Vector2.new(0.5, 0.5)
        Main.BackgroundColor3 = STYLE.Background
        Main.BackgroundTransparency = 0.15
        Main.BorderSizePixel = 0
        Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
        
        local Glass = Instance.new("Frame", Main)
        Glass.Size = UDim2.new(1, 0, 1, 0)
        Glass.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Glass.BackgroundTransparency = 0.95
        Glass.ZIndex = 2
        Instance.new("UICorner", Glass).CornerRadius = UDim.new(0, 8)
        
        local Stroke = Instance.new("UIStroke", Main)
        Stroke.Color = STYLE.Stroke
        Stroke.Transparency = 0.8
        Stroke.Thickness = 1.5
        
        Instance.new("UIDragDetector", Main)

        local Title = Instance.new("TextLabel", Main)
        Title.Size = UDim2.new(1, -20, 0, 40)
        Title.Position = UDim2.new(0, 10, 0, 0)
        Title.BackgroundTransparency = 1
        Title.ZIndex = 3
        Title.Text = "  "..(title or "BM_UI")
        Title.TextColor3 = STYLE.Text
        Title.Font = Enum.Font.GothamBold
        Title.TextSize = 18
        Title.TextXAlignment = Enum.TextXAlignment.Left

        local TopLine = Instance.new("Frame", Main)
        TopLine.Size = UDim2.new(1, -40, 0, 1)
        TopLine.Position = UDim2.new(0, 20, 0, 40)
        TopLine.BackgroundColor3 = STYLE.GrayLine
        TopLine.BorderSizePixel = 0
        TopLine.ZIndex = 3

        local SideMenu = Instance.new("Frame", Main)
        SideMenu.Size = UDim2.new(0, 130, 1, -70)
        SideMenu.Position = UDim2.new(0, 10, 0, 60)
        SideMenu.BackgroundTransparency = 1
        SideMenu.ZIndex = 3
        Instance.new("UIListLayout", SideMenu).Padding = UDim.new(0, 6)

        local VLine = Instance.new("Frame", Main)
        VLine.Size = UDim2.new(0, 1, 1, -80)
        VLine.Position = UDim2.new(0, 150, 0, 60)
        VLine.BackgroundColor3 = STYLE.GrayLine
        VLine.BorderSizePixel = 0
        VLine.ZIndex = 3

        local ContentArea = Instance.new("Frame", Main)
        ContentArea.Size = UDim2.new(1, -170, 1, -80)
        ContentArea.Position = UDim2.new(0, 160, 0, 60)
        ContentArea.BackgroundTransparency = 1
        ContentArea.ZIndex = 3

        local UI = {}
        function UI:CreateCategory(name)
            local btn = Instance.new("TextButton", SideMenu)
            btn.Size = UDim2.new(1, 0, 0, 35)
            btn.Text = name
            btn.BackgroundColor3 = STYLE.Surface
            btn.BackgroundTransparency = 0.5
            btn.TextColor3 = STYLE.Text
            btn.ZIndex = 4
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

            local CategoryContainer = Instance.new("Frame", ContentArea)
            CategoryContainer.Size = UDim2.new(1, 0, 1, 0)
            CategoryContainer.BackgroundTransparency = 1
            CategoryContainer.Visible = (#ContentArea:GetChildren() == 1)
            CategoryContainer.ZIndex = 4
            
            if CategoryContainer.Visible then
                btn.BackgroundColor3 = STYLE.Primary
                btn.BackgroundTransparency = 0
            end

            local function CreateScroll(pos)
                local s = Instance.new("ScrollingFrame", CategoryContainer)
                s.Size = UDim2.new(0.5, -10, 1, 0)
                s.Position = pos
                s.BackgroundTransparency = 1
                s.ScrollBarThickness = 0
                s.ScrollBarImageColor3 = STYLE.Primary
                s.ScrollingEnabled = true
                s.ZIndex = 4
                
                local Layout = Instance.new("UIListLayout", s)
                Layout.Padding = UDim.new(0, 6)
                
                local function UpdateCanvas()
                    local contentHeight = Layout.AbsoluteContentSize.Y
                    s.CanvasSize = UDim2.new(0, 0, 0, contentHeight + 20)
                    s.ScrollBarThickness = (contentHeight > s.AbsoluteSize.Y) and 6 or 0
                end
                
                Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)
                s:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateCanvas)
                
                Instance.new("UIPadding", s).PaddingLeft = UDim.new(0, 5)
                return s
            end

            local LeftScroll = CreateScroll(UDim2.new(0, 0, 0, 0))
            local RightScroll = CreateScroll(UDim2.new(0.5, 10, 0, 0))

            btn.MouseButton1Click:Connect(function()
                for _, b in ipairs(SideMenu:GetChildren()) do
                    if b:IsA("TextButton") then
                        TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = STYLE.Surface, BackgroundTransparency = 0.5}):Play()
                    end
                end
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = STYLE.Primary, BackgroundTransparency = 0}):Play()
                for _, p in pairs(ContentArea:GetChildren()) do if p:IsA("Frame") then p.Visible = false end end
                CategoryContainer.Visible = true
            end)

            local Category = {}
            Category.LastContainer = nil

            function Category:CreateCard(title, side)
                local parent = (side == "Right") and RightScroll or LeftScroll
                
                local Card = Instance.new("Frame", parent)
                Card.Name = "Card_" .. title
                Card.Size = UDim2.new(1, -6, 0, 0) -- Height starts at 0
                Card.AutomaticSize = Enum.AutomaticSize.Y -- Card grows as you add items
                Card.BackgroundColor3 = STYLE.Surface
                Card.BackgroundTransparency = 0.2
                Card.BorderSizePixel = 0
                Card.ClipsDescendants = false
                Card.ZIndex = 5
                Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)
                
                local CardTitle = Instance.new("TextLabel", Card)
                CardTitle.Size = UDim2.new(1, -20, 0, 35)
                CardTitle.Position = UDim2.new(0, 10, 0, 0)
                CardTitle.BackgroundTransparency = 1
                CardTitle.Text = title
                CardTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
                CardTitle.Font = Enum.Font.GothamBold
                CardTitle.TextSize = 14
                CardTitle.TextXAlignment = Enum.TextXAlignment.Left
                CardTitle.ZIndex = 6
                
                -- This is the container where Toggles/Buttons go
                local Container = Instance.new("Frame", Card)
                Container.Name = "ComponentHolder"
                Container.Size = UDim2.new(1, -12, 0, 0)
                Container.Position = UDim2.new(0, 6, 0, 40)
                Container.AutomaticSize = Enum.AutomaticSize.Y -- Holder grows too
                Container.BackgroundTransparency = 1
                Container.ClipsDescendants = false
                Container.ZIndex = 7
                
                local Layout = Instance.new("UIListLayout", Container)
                Layout.Padding = UDim.new(0, 8)
                Layout.SortOrder = Enum.SortOrder.LayoutOrder

                -- Padding at the bottom so the last item isn't touching the edge
                local Padding = Instance.new("UIPadding", Container)
                Padding.PaddingBottom = UDim.new(0, 10)
                
                self.LastContainer = Container
                return self
            end

            function Category:CreateGrid(cellSize)
                local parent = self.LastContainer
                cellSize = cellSize or UDim2.new(0.5, -4, 0, 32)
    
                local GridHolder = Instance.new("Frame", parent)
                GridHolder.Name = "GridContainer"
                GridHolder.Size = UDim2.new(1, 0, 0, 0) -- Grows with content
                GridHolder.AutomaticSize = Enum.AutomaticSize.Y
                GridHolder.BackgroundTransparency = 1 -- COMPLETELY TRANSPARENT
                GridHolder.ZIndex = 100
    
               local GridLayout = Instance.new("UIGridLayout", GridHolder)
               GridLayout.CellSize = cellSize or UDim2.new(0.5, -8, 0, 32)
               GridLayout.CellPadding = UDim2.new(0, 6, 0, 6)
               GridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
               self.LastContainer = GridHolder -- Future items (toggles/buttons) will go into this grid
               return self
            end

            function Category:CreateDropdown(dTitle, options, multiSelect, maxSelect, callback)
                local parent = self.LastContainer -- This is the Card's Container
                
                -- Ensure the Card and its Container don't cut off the dropdown
                if parent and parent.Parent then
                    parent.ClipsDescendants = false
                    parent.Parent.ClipsDescendants = false -- The Card itself
                end

                local selected = {}
                local maxAllowed = maxSelect or 1
                
                local Wrapper = Instance.new("Frame", parent)
                Wrapper.Size = UDim2.new(1, 0, 0, 60)
                Wrapper.BackgroundTransparency = 1
                Wrapper.ZIndex = 10 -- Elevated wrapper

                local Label = Instance.new("TextLabel", Wrapper)
                Label.Size = UDim2.new(1, 0, 0, 20)
                Label.Text = dTitle:upper()
                Label.TextColor3 = Color3.fromRGB(255, 255, 255)
                Label.TextTransparency = 0
                Label.Font = Enum.Font.GothamBold
                Label.TextSize = 11
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BackgroundTransparency = 1
                Label.ZIndex = 11

                local DropdownBtn = Instance.new("TextButton", Wrapper)
                DropdownBtn.Size = UDim2.new(1, 0, 0, 32)
                DropdownBtn.Position = UDim2.new(0, 0, 0, 25)
                DropdownBtn.BackgroundColor3 = STYLE.Surface
                DropdownBtn.AutoButtonColor = false
                DropdownBtn.Text = "  Select Options..." 
                DropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                DropdownBtn.Font = Enum.Font.GothamMedium
                DropdownBtn.TextSize = 13
                DropdownBtn.TextXAlignment = Enum.TextXAlignment.Left
                DropdownBtn.ZIndex = 12
                Instance.new("UICorner", DropdownBtn).CornerRadius = UDim.new(0, 6)
                
                local Stroke = Instance.new("UIStroke", DropdownBtn)
                Stroke.Color = STYLE.Stroke
                Stroke.Transparency = 0.8

                -- The List (Crucial: Very high ZIndex to go OVER the card)
                local List = Instance.new("Frame", DropdownBtn)
                List.Size = UDim2.new(1, 0, 0, 0)
                List.Position = UDim2.new(0, 0, 1, 5)
                List.BackgroundColor3 = STYLE.Background
                List.Visible = false
                List.ZIndex = 105 -- Sit above everything else
                Instance.new("UICorner", List).CornerRadius = UDim.new(0, 6)
                
                local ListLayout = Instance.new("UIListLayout", List)
                ListLayout.Padding = UDim.new(0, 5)
                
                local ListPadding = Instance.new("UIPadding", List)
                ListPadding.PaddingTop = UDim.new(0, 5)
                ListPadding.PaddingBottom = UDim.new(0, 5)
                ListPadding.PaddingLeft = UDim.new(0, 5)
                ListPadding.PaddingRight = UDim.new(0, 5)

                local ListStroke = Instance.new("UIStroke", List)
                ListStroke.Color = STYLE.Stroke
                ListStroke.Transparency = 0.7

                local function getActiveCount()
                    local count = 0
                    for _, v in pairs(selected) do if v == true then count = count + 1 end end
                    return count
                end

                local function updateDisplay()
                    local names = {}
                    for _, name in ipairs(options) do
                        if selected[name] then table.insert(names, name) end
                    end
                    DropdownBtn.Text = #names == 0 and "  Select Options..." or "  " .. table.concat(names, ", ")
                end

                DropdownBtn.MouseButton1Click:Connect(function()
                    List.Visible = not List.Visible
                    local listHeight = (#options * 35) + 10 
                    List.Size = List.Visible and UDim2.new(1, 0, 0, listHeight) or UDim2.new(1, 0, 0, 0)
                    
                    -- Push wrapper ZIndex when open to ensure it overlaps subsequent cards
                    Wrapper.ZIndex = List.Visible and 50 or 10
                end)

                for _, name in ipairs(options) do
                    local Item = Instance.new("TextButton", List)
                    Item.Size = UDim2.new(1, 0, 0, 30)
                    Item.BackgroundColor3 = STYLE.Surface
                    Item.BackgroundTransparency = 0.4
                    Item.AutoButtonColor = false
                    Item.Text = "  " .. name
                    Item.TextColor3 = Color3.fromRGB(255, 255, 255)
                    Item.Font = Enum.Font.Gotham
                    Item.TextSize = 13
                    Item.TextXAlignment = Enum.TextXAlignment.Left
                    Item.ZIndex = 105 -- Inside the high-index list
                    Instance.new("UICorner", Item).CornerRadius = UDim.new(0, 6)

                    local Check = Instance.new("TextLabel", Item)
                    Check.Size = UDim2.new(0, 30, 1, 0)
                    Check.Position = UDim2.new(1, -30, 0, 0)
                    Check.BackgroundTransparency = 1
                    Check.Text = "✓"
                    Check.TextColor3 = STYLE.Primary
                    Check.TextTransparency = 0 
                    Check.ZIndex = 102 -- set it to 105 to see it (Hidden by default)

                    Item.MouseButton1Click:Connect(function()
                        if multiSelect then
                            if selected[name] then
                                selected[name] = nil 
                            elseif getActiveCount() < maxAllowed then
                                selected[name] = true
                            end
                        else
                            table.clear(selected)
                            selected[name] = true
                            List.Visible = false
                            Wrapper.ZIndex = 10
                        end
                        
                        for _, child in ipairs(List:GetChildren()) do
                            if child:IsA("TextButton") then
                                local btnName = child.Text:gsub("^%s+", "")
                                local isPicked = selected[btnName]
                                TweenService:Create(child, TweenInfo.new(0.2), {
                                    BackgroundColor3 = isPicked and STYLE.Primary or STYLE.Surface,
                                    BackgroundTransparency = isPicked and 0 or 0.4
                                }):Play()
                                TweenService:Create(child:FindFirstChildOfClass("TextLabel"), TweenInfo.new(0.2), {
                                    TextTransparency = isPicked and 0 or 1
                                }):Play()
                            end
                        end

                        updateDisplay()
                        callback(selected)
                    end)
                end
                return self
            end

            function Category:CreateButton(bTitle, callback)
                local parent = self.LastContainer
                
                if parent and parent.Parent then
                    parent.ClipsDescendants = false
                    parent.Parent.ClipsDescendants = false
                end
                
                local Wrapper = Instance.new("Frame", parent)
                Wrapper.Size = UDim2.new(1, 0, 0, 35)
                Wrapper.BackgroundTransparency = 1
                Wrapper.ZIndex = 10 
                Wrapper.Name = bTitle .. "_Wrapper"

                local Button = Instance.new("TextButton", Wrapper)
                Button.Size = UDim2.new(1, 0, 1, 0)
                Button.BackgroundColor3 = STYLE.Primary
                Button.AutoButtonColor = false
                Button.Text = bTitle
                Button.TextColor3 = Color3.fromRGB(255, 255, 255)
                Button.Font = Enum.Font.GothamBold
                Button.TextSize = 13
                Button.ZIndex = 11 
                Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
                
                local Stroke = Instance.new("UIStroke", Button)
                Stroke.Color = STYLE.Stroke
                Stroke.Transparency = 0.8

                -- Animations
                Button.MouseEnter:Connect(function()
                    TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
                end)

                Button.MouseLeave:Connect(function()
                    TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
                end)

                -- Click Logic
                Button.MouseButton1Down:Connect(function()
                    Button:TweenSize(UDim2.new(1, -4, 1, -4), "Out", "Quad", 0.1, true)
                end)

                Button.MouseButton1Up:Connect(function()
                    Button:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Quad", 0.1, true)
                end)
                
                -- FIXED: Safe execution of callback
                Button.Activated:Connect(function()
                    if type(callback) == "function" then
                        callback()
                    else
                        warn("Button '" .. bTitle .. "' callback is not a function! Received: " .. type(callback))
                    end
                end)

                return self
            end

            function Category:CreateToggle(tTitle, default, callback)
                local enabled = default or false
                local parent = self.LastContainer
                
                local Wrapper = Instance.new("Frame", parent)
                Wrapper.Name = "Toggle_" .. tTitle
                Wrapper.Size = UDim2.new(1, 0, 0, 32)
                Wrapper.BackgroundTransparency = 1
                Wrapper.ZIndex = 102 -- Protocol Applied

                local Label = Instance.new("TextLabel", Wrapper)
                Label.Size = UDim2.new(1, -50, 1, 0)
                Label.BackgroundTransparency = 1
                Label.Text = tTitle
                Label.TextColor3 = Color3.fromRGB(255, 255, 255)
                Label.Font = Enum.Font.GothamMedium
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.ZIndex = 103

                local ToggleBG = Instance.new("TextButton", Wrapper)
                ToggleBG.Size = UDim2.new(0, 38, 0, 20)
                ToggleBG.Position = UDim2.new(1, -38, 0.5, -10)
                ToggleBG.BackgroundColor3 = enabled and STYLE.Primary or Color3.fromRGB(50, 50, 60)
                ToggleBG.Text = ""
                ToggleBG.AutoButtonColor = false
                ToggleBG.ZIndex = 103
                Instance.new("UICorner", ToggleBG).CornerRadius = UDim.new(1, 0)

                local Dot = Instance.new("Frame", ToggleBG)
                Dot.Size = UDim2.new(0, 14, 0, 14)
                Dot.Position = enabled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
                Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Dot.BorderSizePixel = 0
                Dot.ZIndex = 104
                Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

                ToggleBG.MouseButton1Click:Connect(function()
                    enabled = not enabled
                    local targetPos = enabled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
                    local targetCol = enabled and STYLE.Primary or Color3.fromRGB(50, 50, 60)
                    
                    TweenService:Create(Dot, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = targetPos}):Play()
                    TweenService:Create(ToggleBG, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = targetCol}):Play()
                    
                    callback(enabled)
                end)

                return self
            end

            return Category
        end

        function UI:Notify(title, text, type, duration)
            duration = duration or 3
            local colors = {
                Info = Color3.fromRGB(80, 40, 120),
                Success = Color3.fromRGB(40, 120, 80),
                Error = Color3.fromRGB(120, 40, 40)
            }
            local typeColor = colors[type] or colors.Info
            
            local CoreGui = game:GetService("CoreGui")
            local container = CoreGui:FindFirstChild("BM_NotifyContainer")
            if not container then
                container = Instance.new("ScreenGui", CoreGui)
                container.Name = "BM_NotifyContainer"
                container.DisplayOrder = 1000000
                local layout = Instance.new("UIListLayout", container)
                layout.Padding = UDim.new(0, 10)
                layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
                layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
                local padding = Instance.new("UIPadding", container)
                padding.PaddingBottom = UDim.new(0, 20)
                padding.PaddingRight = UDim.new(0, 20)
            end

            local frame = Instance.new("Frame", container)
            frame.Size = UDim2.new(0, 250, 0, 70)
            frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            frame.BorderSizePixel = 0
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
            
            local accent = Instance.new("Frame", frame)
            accent.Size = UDim2.new(0, 4, 1, 0)
            accent.BackgroundColor3 = typeColor
            accent.BorderSizePixel = 0
            
            local tLabel = Instance.new("TextLabel", frame)
            tLabel.Size = UDim2.new(1, -20, 0, 25)
            tLabel.Position = UDim2.new(0, 15, 0, 5)
            tLabel.BackgroundTransparency = 1
            tLabel.Text = title:upper()
            tLabel.TextColor3 = typeColor
            tLabel.Font = Enum.Font.GothamBold
            tLabel.TextSize = 12
            tLabel.TextXAlignment = Enum.TextXAlignment.Left

            local dLabel = Instance.new("TextLabel", frame)
            dLabel.Size = UDim2.new(1, -20, 0, 35)
            dLabel.Position = UDim2.new(0, 15, 0, 30)
            dLabel.BackgroundTransparency = 1
            dLabel.Text = text
            dLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
            dLabel.Font = Enum.Font.Gotham
            dLabel.TextSize = 13
            dLabel.TextXAlignment = Enum.TextXAlignment.Left

            task.delay(duration, function()
                frame:TweenSize(UDim2.new(0, 0, 0, 70), "Out", "Quad", 0.3, true)
                task.wait(0.3)
                frame:Destroy()
            end)
        end

        return UI
    end)

    if not success then
        warn("!!! MECCA ERROR LOGGER !!!")
        warn("The UI failed to initialize: " .. tostring(result))
    else
        return result
    end
end

return BM_UI
