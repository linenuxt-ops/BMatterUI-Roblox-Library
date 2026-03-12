local BM_UI = { Version = "1.0.0" }

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local STYLE = {
    Primary = Color3.fromRGB(60, 120, 255),
    Background = Color3.fromRGB(20, 20, 25),
    Surface = Color3.fromRGB(30, 30, 35),
    Text = Color3.fromRGB(240, 240, 240)
}

local function Cleanup()
    for _, obj in ipairs(CoreGui:GetChildren()) do
        if obj.Name == "BM_DevUI" then obj:Destroy() end
    end
end

function BM_UI:Init(title)
    Cleanup()
    
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "BM_DevUI"

    -- Main Window (Larger Size)
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 800, 0, 600)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = STYLE.Background
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
    local drag = Instance.new("UIDragDetector", Main)

    -- Title Text
    local TitleLabel = Instance.new("TextLabel", Main)
    TitleLabel.Size = UDim2.new(1, 0, 0, 40)
    TitleLabel.Text = "  " .. title
    TitleLabel.TextColor3 = STYLE.Text
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 18
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Sidebar (Adjusted position below title)
    local SideMenu = Instance.new("Frame", Main)
    SideMenu.Size = UDim2.new(0, 130, 1, -40)
    SideMenu.Position = UDim2.new(0, 0, 0, 40)
    SideMenu.BackgroundColor3 = STYLE.Surface
    Instance.new("UICorner", SideMenu).CornerRadius = UDim.new(0, 8)
    local SideLayout = Instance.new("UIListLayout", SideMenu)
    SideLayout.Padding = UDim.new(0, 5)

    -- Container for Pages (Adjusted position below title)
    local ContentArea = Instance.new("Frame", Main)
    ContentArea.Size = UDim2.new(1, -140, 1, -50)
    ContentArea.Position = UDim2.new(0, 135, 0, 45)
    ContentArea.BackgroundTransparency = 1

    local UI = {}
    local HideKey = Enum.KeyCode.LeftControl
    
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == HideKey then Main.Visible = not Main.Visible end
    end)

    function UI:SetHideKey(newKey) HideKey = newKey end

    function UI:CreateCategory(name)
        local btn = Instance.new("TextButton", SideMenu)
        btn.Size = UDim2.new(1, 0, 0, 35)
        btn.Text = name
        btn.BackgroundColor3 = STYLE.Primary
        btn.TextColor3 = STYLE.Text
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

        local Page = Instance.new("ScrollingFrame", ContentArea)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 5)

        btn.MouseButton1Click:Connect(function()
            for _, p in pairs(ContentArea:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
            Page.Visible = true
        end)

        local Category = {}
        function Category:CreateKeybind(text, default, callback)
            local kbtn = Instance.new("TextButton", Page)
            kbtn.Size = UDim2.new(1, 0, 0, 35)
            kbtn.Text = text .. ": " .. default.Name
            kbtn.BackgroundColor3 = STYLE.Surface
            kbtn.TextColor3 = STYLE.Text
            kbtn.MouseButton1Click:Connect(function()
                kbtn.Text = "Press a key..."
                local conn; conn = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        kbtn.Text = text .. ": " .. input.KeyCode.Name
                        callback(input.KeyCode)
                        conn:Disconnect()
                    end
                end)
            end)
        end
        return Category
    end

    return UI
end

return BM_UI
