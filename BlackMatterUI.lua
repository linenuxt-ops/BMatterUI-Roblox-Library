local BM_UI = { Version = "1.0.0" }

-- Services
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local STYLE = {
    Primary = Color3.fromRGB(60, 120, 255),
    Background = Color3.fromRGB(20, 20, 25),
    Surface = Color3.fromRGB(30, 30, 35),
    Text = Color3.fromRGB(240, 240, 240)
}

function BM_UI:Init(title)
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "BM_DevUI"

    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 400, 0, 300)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = STYLE.Background
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
    local drag = Instance.new("UIDragDetector", Main)

    -- Window Toggle Logic
    local HideKey = Enum.KeyCode.LeftControl
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == HideKey then
            Main.Visible = not Main.Visible
        end
    end)

    local UI = {}
    
    function UI:SetHideKey(newKey)
        HideKey = newKey
    end

    -- Category/Page System
    function UI:CreateCategory(name)
        -- In a real library, this would switch between ScrollingFrames
        -- For now, it returns a table that creates components inside the Main frame
        local Category = {}
        
        function Category:CreateKeybind(text, default, callback)
            local btn = Instance.new("TextButton", Main)
            btn.Size = UDim2.new(0, 380, 0, 35)
            btn.Text = text .. ": " .. default.Name
            btn.BackgroundColor3 = STYLE.Surface
            btn.TextColor3 = STYLE.Text
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            
            btn.MouseButton1Click:Connect(function()
                btn.Text = "Press a key..."
                local conn
                conn = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        btn.Text = text .. ": " .. input.KeyCode.Name
                        callback(input.KeyCode)
                        conn:Disconnect()
                    end
                end)
            end)
        end
        return Category
    end

    function UI:CreateButton(text, callback)
        local btn = Instance.new("TextButton", Main)
        btn.Size = UDim2.new(0, 380, 0, 35)
        btn.BackgroundColor3 = STYLE.Surface
        btn.Text = text
        btn.TextColor3 = STYLE.Text
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        btn.MouseButton1Click:Connect(callback or function() end)
    end

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
