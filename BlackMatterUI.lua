local BMLibrary = {
    Version = 1.0 -- Update this number when you push a big update
}

local CoreGui = game:GetService("CoreGui")
local GUI_NAME = "BMLibrary_Root"

-- Logic to check if an old version exists and remove it
local function RefreshUI(newVersion)
    local existing = CoreGui:FindFirstChild(GUI_NAME)
    if existing then
        local oldVersion = existing:GetAttribute("Version") or 0
        -- If the existing UI version is lower or equal, we replace it
        if newVersion >= oldVersion then
            existing:Destroy()
            return false -- Proceed to create new UI
        else
            -- If a newer version is somehow already running, don't overwrite it
            return true 
        end
    end
    return false
end

function BMLibrary:CreateWindow(title)
    if RefreshUI(self.Version) then 
        warn("BMLibrary: A newer version is already running.")
        return nil 
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = GUI_NAME
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.SetAttribute(ScreenGui, "Version", self.Version)

    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 400, 0, 300)
    Main.Position = UDim2.new(0.5, -200, 0.5, -150)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true

    -- Header
    local Header = Instance.new("TextLabel", Main)
    Header.Size = UDim2.new(1, 0, 0, 35)
    Header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Header.Text = "  " .. (title or "BMLibrary")
    Header.TextColor3 = Color3.new(1,1,1)
    Header.TextXAlignment = Enum.TextXAlignment.Left
    Header.Font = Enum.Font.GothamBold
    Header.TextSize = 14

    local Container = Instance.new("ScrollingFrame", Main)
    Container.Size = UDim2.new(1, -20, 1, -45)
    Container.Position = UDim2.new(0, 10, 0, 40)
    Container.BackgroundTransparency = 1
    Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    Container.ScrollBarThickness = 2
    Container.BorderSizePixel = 0

    local Layout = Instance.new("UIListLayout", Container)
    Layout.Padding = UDim.new(0, 8)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder

    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Container.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y)
    end)

    local Elements = {}

    -- Button Implementation
    function Elements:CreateButton(text, callback)
        local Btn = Instance.new("TextButton", Container)
        Btn.Size = UDim2.new(1, 0, 0, 35)
        Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        Btn.Text = text
        Btn.TextColor3 = Color3.new(1,1,1)
        Btn.Font = Enum.Font.Gotham
        Btn.BorderSizePixel = 0
        Btn.AutoButtonColor = true

        Btn.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)
    end

    return Elements
end

return BMLibrary
