local BM_UI = { Version = "1.0.0" }

-- Services
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Constants for consistent styling
local STYLE = {
    Primary = Color3.fromRGB(60, 120, 255),
    Background = Color3.fromRGB(20, 20, 25),
    Surface = Color3.fromRGB(30, 30, 35),
    Text = Color3.fromRGB(240, 240, 240)
}

function BM_UI:Init(title)
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "BM_DevUI"

    -- Main Window
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 400, 0, 300)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = STYLE.Background
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
    
    -- Draggable
    local drag = Instance.new("UIDragDetector", Main)

    -- Header
    local Header = Instance.new("TextLabel", Main)
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.Text = "  " .. title
    Header.TextColor3 = STYLE.Text
    Header.Font = Enum.Font.GothamBold
    Header.BackgroundTransparency = 1

    -- Container for Tabs/Content
    local Content = Instance.new("ScrollingFrame", Main)
    Content.Size = UDim2.new(1, -20, 1, -50)
    Content.Position = UDim2.new(0, 10, 0, 45)
    Content.BackgroundTransparency = 1
    Instance.new("UIListLayout", Content).Padding = UDim.new(0, 8)

    local UI = {}

    -- Generic Component: Button
    function UI:CreateButton(text, callback)
        local btn = Instance.new("TextButton", Content)
        btn.Size = UDim2.new(1, 0, 0, 35)
        btn.BackgroundColor3 = STYLE.Surface
        btn.Text = text
        btn.TextColor3 = STYLE.Text
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        btn.MouseButton1Click:Connect(callback or function() end)
    end

    -- New Dialog Functionality (as requested)
    function UI:ShowDialog(title, message, autoclose)
        local Overlay = Instance.new("Frame", ScreenGui)
        Overlay.Size = UDim2.new(1, 0, 1, 0)
        Overlay.BackgroundColor3 = Color3.new(0, 0, 0)
        Overlay.BackgroundTransparency = 0.3
        
        local Box = Instance.new("Frame", Overlay)
        Box.Size = UDim2.new(0, 250, 0, 120)
        Box.Position = UDim2.new(0.5, 0, 0.5, 0)
        Box.AnchorPoint = Vector2.new(0.5, 0.5)
        Box.BackgroundColor3 = STYLE.Background
        
        local Txt = Instance.new("TextLabel", Box)
        Txt.Size = UDim2.new(1, 0, 1, 0)
        Txt.Text = title .. "\n" .. message
        Txt.TextColor3 = STYLE.Text
        Txt.BackgroundTransparency = 1

        if autoclose then
            task.wait(2)
            Overlay:Destroy()
        end
    end

    return UI
end

return BM_UI
