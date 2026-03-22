-- 1. SAFE UNLOAD
if getgenv().Library and type(getgenv().Library) == "table" and getgenv().Library.Unload then 
    pcall(function() getgenv().Library:Unload() end)
end

-- Ensure Core Folders Exist
if not isfolder("blackmatter") then makefolder("blackmatter") end
if not isfolder("blackmatter/configs") then makefolder("blackmatter/configs") end

local BM_UI = { 
    Version = "1.8.5", 
    Connections = {}, 
    Flags = {}, 
    ToggleKey = Enum.KeyCode.RightControl,
    ConfigName = "default",
    -- Log file named by date to group daily errors
    LogFile = "blackmatter/logs/errors_" .. os.date("%m_%d_%y") .. ".txt"
}
getgenv().Library = BM_UI

-- [SILENT LOGGER SYSTEM]
function BM_UI:Log(message, level)
    level = level or "info"
    
    -- Print everything to F9 console for live debugging
    local timestamp = os.date("[%H:%M:%S]")
    print(string.format("BM_UI >> %s [%s] %s", timestamp, level:upper(), tostring(message)))

    -- ONLY write to file if it's an error or warning
    if level == "error" or level == "warn" then
        if not isfolder("blackmatter/logs") then makefolder("blackmatter/logs") end
        
        local success, currentLog = pcall(readfile, self.LogFile)
        local formatted = string.format("%s [%s] %s\n", timestamp, level:upper(), tostring(message))
        writefile(self.LogFile, (success and currentLog or "") .. formatted)
    end
end

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local STYLE = {
    Primary = Color3.fromRGB(80, 40, 120),
    PrimaryDark = Color3.fromRGB(40, 20, 60),
    Background = Color3.fromRGB(15, 15, 18),
    Surface = Color3.fromRGB(25, 25, 30),
    Card = Color3.fromRGB(30, 30, 35),
    Text = Color3.fromRGB(240, 240, 240),
    TextGray = Color3.fromRGB(130, 130, 135),
    Error = Color3.fromRGB(220, 50, 50),
}

-- [INTERNAL UTILS]
local function GetCustomFont(fontName, fileName, url)
    local ttfFile = "blackmatter/fonts/" .. fileName
    local jsonFile = "blackmatter/fonts/" .. fontName .. ".json"
    
    local success, err = pcall(function()
        if not isfolder("blackmatter/fonts") then makefolder("blackmatter/fonts") end
        if not isfile(ttfFile) then writefile(ttfFile, game:HttpGet(url)) end
        if not isfile(jsonFile) then
            writefile(jsonFile, HttpService:JSONEncode({
                name = fontName,
                faces = {{ name = "Regular", weight = 400, style = "normal", assetId = getcustomasset(ttfFile) }}
            }))
        end
    end)
    
    if not success then
        BM_UI:Log("Font Load Failure ("..fontName.."): "..tostring(err), "error")
        return Font.fromEnum(Enum.Font.Gotham) -- Fallback
    end
    
    return Font.new(getcustomasset(jsonFile))
end

local QUANTICO_FONT = GetCustomFont("Quantico", "Quantico-Regular.ttf", "https://github.com/linenuxt-ops/BMatterUI-Roblox-Library/raw/refs/heads/main/font/Quantico-Regular.ttf")
local MODAK_FONT = GetCustomFont("Modak", "Modak-Regular.ttf", "https://github.com/linenuxt-ops/BMatterUI-Roblox-Library/raw/refs/heads/main/font/Modak-Regular.ttf")

-- [BUILT-IN UTILITIES]
function BM_UI:AntiAFK(state)
    if state then
        if getgenv().BM_AFK_Conn then getgenv().BM_AFK_Conn:Disconnect() end
        getgenv().BM_AFK_Conn = game:GetService("Players").LocalPlayer.Idled:Connect(function()
            game:GetService("VirtualUser"):CaptureController()
            game:GetService("VirtualUser"):ClickButton2(Vector2.new())
            BM_UI:Log("Anti-AFK: Prevented Kick", "info")
        end)
    else
        if getgenv().BM_AFK_Conn then 
            getgenv().BM_AFK_Conn:Disconnect() 
            getgenv().BM_AFK_Conn = nil
        end
    end
end

function BM_UI:ServerHop()
    local HttpService = game:GetService("HttpService")
    local TP = game:GetService("TeleportService")
    local Servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100"))
    
    for _, s in pairs(Servers.data) do
        if s.playing < s.maxPlayers and s.id ~= game.JobId then
            TP:TeleportToPlaceInstance(game.PlaceId, s.id)
            break
        end
    end
end

function BM_UI:SmallServerHop()
    local HttpService = game:GetService("HttpService")
    local TP = game:GetService("TeleportService")
    -- Sort order "Asc" (Ascending) gets the lowest player counts first
    local Servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    
    for _, s in pairs(Servers.data) do
        if s.playing < s.maxPlayers and s.id ~= game.JobId then
            TP:TeleportToPlaceInstance(game.PlaceId, s.id)
            break
        end
    end
end

function BM_UI:Init(title)
    local MainFrame
    local Sidebar
    local ContainerArea
    local Drag -- Declare it here!
    local API = {} 

    local initSuccess, initError = pcall(function()
        local ScreenGui = Instance.new("ScreenGui", PlayerGui)
        ScreenGui.Name = "BM_DevUI"
        ScreenGui.ResetOnSpawn = false
        BM_UI.MainGui = ScreenGui

        local Main = Instance.new("Frame", ScreenGui)
        MainFrame = Main
        Main.Size = UDim2.new(0, 600, 0, 450)
        Main.Position = UDim2.new(0.5, -300, 0.5, -225) 
        Main.BackgroundColor3 = STYLE.Background
        Main.ClipsDescendants = true
        Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
        
        Drag = Instance.new("UIDragDetector", Main)

        -- [RESIZE LOGIC]
        local ResizeHandle = Instance.new("Frame", Main)
        ResizeHandle.Size = UDim2.new(0, 20, 0, 20)
        ResizeHandle.Position = UDim2.new(1, -15, 1, -15)
        ResizeHandle.AnchorPoint = Vector2.new(0.5, 0.5)
        ResizeHandle.BackgroundTransparency = 1
        ResizeHandle.ZIndex = 100

        local VisualHandle = Instance.new("Frame", ResizeHandle)
        VisualHandle.Size = UDim2.new(1, 0, 1, 0)
        VisualHandle.BackgroundColor3 = STYLE.Primary
        VisualHandle.BackgroundTransparency = 0.5
        Instance.new("UICorner", VisualHandle).CornerRadius = UDim.new(1, 0)

        local resizing = false
        local startPos, startSize

        ResizeHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing = true
                Drag.Enabled = false
                startPos = UserInputService:GetMouseLocation()
                startSize = Main.AbsoluteSize
            end
        end)

        table.insert(BM_UI.Connections, UserInputService.InputChanged:Connect(function(input)
            if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
                local currentMousePos = UserInputService:GetMouseLocation()
                local delta = currentMousePos - startPos
                Main.Size = UDim2.new(0, math.max(450, startSize.X + delta.X), 0, math.max(350, startSize.Y + delta.Y))
            end
        end))

        table.insert(BM_UI.Connections, UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing = false
                Drag.Enabled = true
            end
        end))

        -- Title & Layout
        local TitleLabel = Instance.new("TextLabel", Main)
        TitleLabel.Size = UDim2.new(0, 0, 0, 30)
        TitleLabel.Position = UDim2.new(0, 15, 0, 5)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Text = (title or "BLACK MATTER"):upper()
        TitleLabel.TextColor3 = STYLE.Text
        TitleLabel.FontFace = MODAK_FONT
        TitleLabel.TextSize = 25
        TitleLabel.AutomaticSize = Enum.AutomaticSize.X

        Sidebar = Instance.new("Frame", Main)
        Sidebar.Size = UDim2.new(0, 140, 1, -50)
        Sidebar.Position = UDim2.new(0, 10, 0, 45)
        Sidebar.BackgroundTransparency = 1
        Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 5)

        ContainerArea = Instance.new("Frame", Main)
        ContainerArea.Size = UDim2.new(1, -170, 1, -55)
        ContainerArea.Position = UDim2.new(0, 160, 0, 45)
        ContainerArea.BackgroundTransparency = 1

        -- Toggle logic
        table.insert(BM_UI.Connections, UserInputService.InputBegan:Connect(function(input, gpe)
            if not gpe and input.KeyCode == BM_UI.ToggleKey then
                Main.Visible = not Main.Visible
            end
        end))
    end)

    if not initSuccess then
        BM_UI:Log("UI INIT CRASH: " .. tostring(initError), "error")
        if BM_UI.MainGui then BM_UI.MainGui:Destroy() end
        return nil
    end

    function API:CreateCategory(name)
        local CatBtn = Instance.new("TextButton", Sidebar)
        CatBtn.Size = UDim2.new(1, 0, 0, 34)
        CatBtn.BackgroundTransparency = 1
        CatBtn.Text = name:upper()
        CatBtn.TextColor3 = STYLE.TextGray
        CatBtn.FontFace = QUANTICO_FONT
        CatBtn.TextSize = 16
        CatBtn.TextXAlignment = Enum.TextXAlignment.Left -- Align text to left
        Instance.new("UICorner", CatBtn).CornerRadius = UDim.new(0, 6)

        -- Add Padding so text doesn't touch the very edge
        local btnPadding = Instance.new("UIPadding", CatBtn)
        btnPadding.PaddingLeft = UDim.new(0, 15) -- Initial push to the right

        -- The Selection Indicator (Half-Circle)
        local Indicator = Instance.new("Frame", CatBtn)
        Indicator.Size = UDim2.new(0, 4, 0.6, 0) -- Thin bar
        Indicator.Position = UDim2.new(0, -15, 0.2, 0) -- Hidden off to the left initially
        Indicator.BackgroundColor3 = STYLE.Primary
        Indicator.BorderSizePixel = 0
        Indicator.BackgroundTransparency = 1 -- Hidden by default
        Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0) -- Rounded edges

        local Page = Instance.new("Frame", ContainerArea)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        
        -- Default selection check
        local isFirst = (#ContainerArea:GetChildren() == 1)
        Page.Visible = isFirst
        if isFirst then
            CatBtn.TextColor3 = STYLE.Text
            CatBtn.BackgroundTransparency = 0.8
            CatBtn.BackgroundColor3 = STYLE.PrimaryDark
            Indicator.BackgroundTransparency = 0
            Indicator.Position = UDim2.new(0, -10, 0.2, 0) -- Slightly visible
            btnPadding.PaddingLeft = UDim.new(0, 20) -- Pushed more to the right
        end

        local function CreateColumn(pos)
            local Col = Instance.new("ScrollingFrame", Page)
            Col.Size = UDim2.new(0.5, -5, 1, 0)
            Col.Position = pos
            Col.BackgroundTransparency = 1
            Col.ScrollBarThickness = 0
            Col.AutomaticCanvasSize = Enum.AutomaticSize.Y
            Instance.new("UIListLayout", Col).Padding = UDim.new(0, 8)
            return Col
        end

        local LeftCol = CreateColumn(UDim2.new(0, 0, 0, 0))
        local RightCol = CreateColumn(UDim2.new(0.5, 5, 0, 0))

        CatBtn.MouseButton1Click:Connect(function()
            -- Reset all other buttons
            for _, v in pairs(ContainerArea:GetChildren()) do v.Visible = false end
            for _, v in pairs(Sidebar:GetChildren()) do 
                if v:IsA("TextButton") then 
                    v.TextColor3 = STYLE.TextGray 
                    v.BackgroundTransparency = 1
                    local otherIndicator = v:FindFirstChild("Frame")
                    local otherPadding = v:FindFirstChild("UIPadding")
                    if otherIndicator then
                        TweenService:Create(otherIndicator, TweenInfo.new(0.3), {BackgroundTransparency = 1, Position = UDim2.new(0, -15, 0.2, 0)}):Play()
                    end
                    if otherPadding then
                        TweenService:Create(otherPadding, TweenInfo.new(0.3), {PaddingLeft = UDim.new(0, 15)}):Play()
                    end
                end 
            end

            -- Activate this button
            Page.Visible = true
            CatBtn.TextColor3 = STYLE.Text
            CatBtn.BackgroundColor3 = STYLE.PrimaryDark
            
            -- Animate Selection Effects
            TweenService:Create(CatBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.8}):Play()
            TweenService:Create(Indicator, TweenInfo.new(0.3, Enum.EasingStyle.Back), {BackgroundTransparency = 0, Position = UDim2.new(0, -10, 0.2, 0)}):Play()
            TweenService:Create(btnPadding, TweenInfo.new(0.3), {PaddingLeft = UDim.new(0, 20)}):Play()
        end)

        local CompAPI = {}

        -- Internal method to create elements inside a parent container
        local function AddElementsToContainer(ParentFrame, isDropdown)
            local InnerAPI = {}
            local ItemSurface = isDropdown and STYLE.Card or STYLE.Surface

            function InnerAPI:AddServerHopButton()
                return self:AddButton("Server Hop", function()
                    BM_UI:ServerHop()
                end)
            end

            function InnerAPI:AddSmallServerButton()
                return self:AddButton("Small Server Hop", function()
                    BM_UI:SmallServerHop()
                end)
            end

            function InnerAPI:AddAntiAFKToggle(flag)
                return self:AddToggle("Anti-AFK", flag or "anti_afk", false, function(state)
                    BM_UI:AntiAFK(state)
                end)
            end
            

            function InnerAPI:AddButton(text, callback)
                local b = Instance.new("TextButton", ParentFrame)
                b.Size = UDim2.new(1, 0, 0, 30)
                b.BackgroundColor3 = ItemSurface
                b.Text = text
                b.TextColor3 = STYLE.Text
                b.FontFace = QUANTICO_FONT
                b.TextSize = 15
                Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
                b.MouseButton1Click:Connect(function() pcall(callback) end)
                return b
            end

            function InnerAPI:AddToggle(text, flag, default, callback)
                BM_UI.Flags[flag] = BM_UI.Flags[flag] or default or false
                local state = BM_UI.Flags[flag]

                local TFrame = Instance.new("TextButton", ParentFrame)
                TFrame.Size = UDim2.new(1, 0, 0, 30)
                TFrame.BackgroundColor3 = ItemSurface
                TFrame.Text = ""
                Instance.new("UICorner", TFrame).CornerRadius = UDim.new(0, 4)

                local TText = Instance.new("TextLabel", TFrame)
                TText.Size = UDim2.new(1, -40, 1, 0)
                TText.Position = UDim2.new(0, 10, 0, 0)
                TText.BackgroundTransparency = 1
                TText.Text = text
                TText.TextColor3 = STYLE.Text
                TText.FontFace = QUANTICO_FONT
                TText.TextSize = 15
                TText.TextXAlignment = Enum.TextXAlignment.Left

                local Switch = Instance.new("Frame", TFrame)
                Switch.Size = UDim2.new(0, 28, 0, 14)
                Switch.Position = UDim2.new(1, -35, 0.5, -7)
                Switch.BackgroundColor3 = state and STYLE.Primary or STYLE.Background
                Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

                local Dot = Instance.new("Frame", Switch)
                Dot.Size = UDim2.new(0, 10, 0, 10)
                Dot.Position = state and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
                Dot.BackgroundColor3 = STYLE.Text
                Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

                TFrame.MouseButton1Click:Connect(function()
                    state = not state
                    BM_UI.Flags[flag] = state
                    TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = state and STYLE.Primary or STYLE.Background}):Play()
                    TweenService:Create(Dot, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)}):Play()
                    pcall(callback, state)
                end)
                return TFrame
            end

            function InnerAPI:AddSlider(text, flag, min, max, default, callback)
                -- Safety check for flag
                if not flag then 
                    flag = text:gsub("%s+", "") .. "_Slider" 
                    BM_UI:Log("Warning: Slider '"..text.."' is missing a flag. Using: "..flag, "warn")
                end
                
                BM_UI.Flags[flag] = BM_UI.Flags[flag] or default or min
                local val = BM_UI.Flags[flag]

                local SFrame = Instance.new("Frame", ParentFrame)
                SFrame.Size = UDim2.new(1, 0, 0, 45)
                SFrame.BackgroundColor3 = ItemSurface -- Uses the surface color defined in your factory
                Instance.new("UICorner", SFrame).CornerRadius = UDim.new(0, 4)

                local SText = Instance.new("TextLabel", SFrame)
                SText.Size = UDim2.new(1, -60, 0, 20)
                SText.Position = UDim2.new(0, 10, 0, 5)
                SText.BackgroundTransparency = 1
                SText.Text = text
                SText.TextColor3 = STYLE.Text
                SText.FontFace = QUANTICO_FONT
                SText.TextSize = 13
                SText.TextXAlignment = Enum.TextXAlignment.Left

                local ValText = Instance.new("TextLabel", SFrame)
                ValText.Size = UDim2.new(0, 50, 0, 20)
                ValText.Position = UDim2.new(1, -55, 0, 5)
                ValText.BackgroundTransparency = 1
                ValText.Text = tostring(val)
                ValText.TextColor3 = STYLE.Primary
                ValText.FontFace = QUANTICO_FONT
                ValText.TextSize = 13
                ValText.TextXAlignment = Enum.TextXAlignment.Right

                local BarBack = Instance.new("Frame", SFrame)
                BarBack.Size = UDim2.new(1, -20, 0, 4)
                BarBack.Position = UDim2.new(0, 10, 0, 32)
                BarBack.BackgroundColor3 = STYLE.Background
                Instance.new("UICorner", BarBack)

                local BarFill = Instance.new("Frame", BarBack)
                BarFill.Size = UDim2.new(math.clamp((val - min) / (max - min), 0, 1), 0, 1, 0)
                BarFill.BackgroundColor3 = STYLE.Primary
                Instance.new("UICorner", BarFill)

                local dragging = false
                
                local function update()
                    local mousePos = UserInputService:GetMouseLocation().X
                    local barPos = BarBack.AbsolutePosition.X
                    local barWidth = BarBack.AbsoluteSize.X
                    local percent = math.clamp((mousePos - barPos) / barWidth, 0, 1)
                    
                    local snappedVal = math.floor(min + (max - min) * percent)
                    BM_UI.Flags[flag] = snappedVal
                    ValText.Text = tostring(snappedVal)
                    
                    TweenService:Create(BarFill, TweenInfo.new(0.1), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
                    pcall(callback, snappedVal)
                end

                SFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        
                        -- Disable Menu Dragging while sliding
                        if Drag then Drag.Enabled = false end 
                        
                        update()
                    end
                end)

                table.insert(BM_UI.Connections, UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        update()
                    end
                end))

                table.insert(BM_UI.Connections, UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                        
                        -- Re-enable Menu Dragging when finished
                        if Drag then Drag.Enabled = true end
                    end
                end))

                return SFrame
            end
            
            return InnerAPI
        end

        function CompAPI:CreateCard(title, side)
            local Col = (side == "Right" and RightCol or LeftCol)
            local Card = Instance.new("Frame", Col)
            Card.Size = UDim2.new(1, -5, 0, 0)
            Card.BackgroundColor3 = STYLE.Card
            Card.AutomaticSize = Enum.AutomaticSize.Y
            Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)
            
            local Padding = Instance.new("UIPadding", Card)
            Padding.PaddingTop, Padding.PaddingBottom = UDim.new(0, 8), UDim.new(0, 8)
            Padding.PaddingLeft, Padding.PaddingRight = UDim.new(0, 10), UDim.new(0, 10)

            local CTitle = Instance.new("TextLabel", Card)
            CTitle.Size = UDim2.new(1, 0, 0, 20)
            CTitle.Text = title:upper()
            CTitle.TextColor3 = STYLE.Text
            CTitle.FontFace = QUANTICO_FONT
            CTitle.TextSize = 16
            CTitle.TextXAlignment = Enum.TextXAlignment.Left
            CTitle.BackgroundTransparency = 1

            local Content = Instance.new("Frame", Card)
            Content.Size = UDim2.new(1, 0, 0, 0)
            Content.Position = UDim2.new(0, 0, 0, 25)
            Content.BackgroundTransparency = 1
            Content.AutomaticSize = Enum.AutomaticSize.Y
            Instance.new("UIListLayout", Content).Padding = UDim.new(0, 5)

            return AddElementsToContainer(Content, false)
        end

        function CompAPI:CreateDropdown(text, side)
            local Col = (side == "Right" and RightCol or LeftCol)
            
            local DropFrame = Instance.new("Frame", Col)
            DropFrame.Size = UDim2.new(1, -5, 0, 36)
            DropFrame.BackgroundColor3 = STYLE.Surface
            DropFrame.ClipsDescendants = true
            Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 6)

            local Label = Instance.new("TextButton", DropFrame)
            Label.Size = UDim2.new(1, 0, 0, 36)
            Label.BackgroundTransparency = 1
            Label.Text = "  " .. text:upper()
            Label.TextColor3 = STYLE.Text
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.FontFace = QUANTICO_FONT
            Label.TextSize = 16

            local Indicator = Instance.new("TextLabel", Label)
            Indicator.Size = UDim2.new(0, 20, 0, 20)
            -- Use AnchorPoint to ensure it rotates around its center
            Indicator.AnchorPoint = Vector2.new(0.5, 0.5)
            Indicator.Position = UDim2.new(1, -15, 0.5, 0) 
            Indicator.Text = "▶"
            Indicator.TextColor3 = STYLE.Text
            Indicator.BackgroundTransparency = 1
            Indicator.Rotation = 0

            local Content = Instance.new("Frame", DropFrame)
            Content.Position = UDim2.new(0, 5, 0, 36)
            Content.Size = UDim2.new(1, -10, 0, 0)
            Content.BackgroundTransparency = 1
            Content.AutomaticSize = Enum.AutomaticSize.Y
            local CList = Instance.new("UIListLayout", Content)
            CList.Padding = UDim.new(0, 5)

            local expanded = false
            Label.MouseButton1Click:Connect(function()
                expanded = not expanded
                
                -- Rotate the indicator instead of changing text
                TweenService:Create(Indicator, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                    Rotation = expanded and 90 or 0
                }):Play()

                task.wait() -- Small wait for layout engine
                TweenService:Create(DropFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                    Size = expanded and UDim2.new(1, -5, 0, 45 + CList.AbsoluteContentSize.Y) or UDim2.new(1, -5, 0, 36)
                }):Play()
            end)

            return AddElementsToContainer(Content, true)
        end

        return CompAPI
    end

    return API 
end

function BM_UI:Unload()
    if BM_UI.MainGui then BM_UI.MainGui:Destroy() end
    for _, connection in pairs(BM_UI.Connections) do if connection then connection:Disconnect() end end
    BM_UI.Connections = {}
    getgenv().Library = nil
end

return BM_UI
