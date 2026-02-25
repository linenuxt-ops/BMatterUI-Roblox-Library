local BMLibrary = {
    Version = 1.1 -- Keep this number updated
}

local CoreGui = game:GetService("CoreGui")

-- IMPROVED: Stronger cleanup logic
local function ForceCleanup()
    for _, child in ipairs(CoreGui:GetChildren()) do
        -- Checks for the specific name OR any GUI that has a "Version" attribute from us
        if child.Name == "BMLibrary_Root" or child.Name == "BlackMatterUI_Root" or child:GetAttribute("BMLib_Version") then
            child:Destroy()
        end
    end
end

function BMLibrary:CreateWindow(title)
    -- Run cleanup BEFORE doing anything else
    ForceCleanup()
    task.wait(0.1) -- Short delay to ensure destruction is processed

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BMLibrary_Root"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false
    -- Identify this GUI for future cleanup
    ScreenGui:SetAttribute("BMLib_Version", self.Version)

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

    function Elements:CreateButton(text, callback)
        local Btn = Instance.new("TextButton", Container)
        Btn.Size = UDim2.new(1, 0, 0, 35)
        Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        Btn.Text = text
        Btn.TextColor3 = Color3.new(1,1,1)
        Btn.Font = Enum.Font.Gotham
        Btn.BorderSizePixel = 0

        Btn.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)
    end

    return Elements
end

return BMLibrary
