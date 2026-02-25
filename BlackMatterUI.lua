local Library = {}
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

function Library:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "Lib_" .. math.random(1000)

    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 400, 0, 300)
    Main.Position = UDim2.new(0.5, -200, 0.5, -150)
    Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Main.Active = true
    Main.Draggable = true

    -- Header
    local Header = Instance.new("TextLabel", Main)
    Header.Size = UDim2.new(1, 0, 0, 35)
    Header.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Header.Text = "  " .. (title or "Roblox UI")
    Header.TextColor3 = Color3.new(1,1,1)
    Header.TextXAlignment = Enum.TextXAlignment.Left
    Header.Font = Enum.Font.GothamBold

    local Container = Instance.new("ScrollingFrame", Main)
    Container.Size = UDim2.new(1, -20, 1, -45)
    Container.Position = UDim2.new(0, 10, 0, 40)
    Container.BackgroundTransparency = 1
    Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    Container.ScrollBarThickness = 2

    local Layout = Instance.new("UIListLayout", Container)
    Layout.Padding = UDim.new(0, 8)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder

    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Container.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y)
    end)

    local Elements = {}

    -- Button (With your custom dialog logic)
    function Elements:CreateButton(text, callback)
        local Btn = Instance.new("TextButton", Container)
        Btn.Size = UDim2.new(1, 0, 0, 35)
        Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        Btn.Text = text
        Btn.TextColor3 = Color3.new(1,1,1)
        Btn.Font = Enum.Font.Gotham
        Btn.AutoButtonColor = true

        Btn.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)
    end

    -- Toggle
    function Elements:CreateToggle(text, callback)
        local Tgl = Instance.new("TextButton", Container)
        Tgl.Size = UDim2.new(1, 0, 0, 35)
        Tgl.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        Tgl.Text = "  " .. text .. ": OFF"
        Tgl.TextColor3 = Color3.new(0.7,0.7,0.7)
        Tgl.TextXAlignment = Enum.TextXAlignment.Left

        local state = false
        Tgl.MouseButton1Click:Connect(function()
            state = not state
            Tgl.Text = "  " .. text .. (state and ": ON" or ": OFF")
            Tgl.TextColor3 = state and Color3.new(0, 1, 0.5) or Color3.new(0.7,0.7,0.7)
            callback(state)
        end)
    end

    return Elements
end

return Library
