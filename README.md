# Black Matter UI (v1.1)

## How to Use

```lua
local BlackMatterUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/linenuxt-ops/BMatterUI-Roblox-Library/refs/heads/main/BlackMatterUI.lua"))()
local Window = BlackMatterUI:CreateWindow("BLACK MATTER")

local GeneralTab = Window:CreateCategory("General")

GeneralTab:CreateButton("Click Me", function()
    print("The button was clicked!")
end)

GeneralTab:CreateColorPicker("Accent Color", Color3.fromRGB(180, 50, 255), function(newColor)
    print("Color changed to: " .. tostring(newColor))
end)

GeneralTab:CreateButton("Check for Updates", function()
    Window:ShowCriticalUpdate() 
end)

GeneralTab:CreateToggle("Enable Feature", false, function(state)
    print("Toggle is now: ", state)
end)

GeneralTab:CreateSlider("Walkspeed", 16, 100, 16, function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)

GeneralTab:CreateInput("User Note", "Type here...", function(text)
    print("User entered text: " .. text)
end)

GeneralTab:CreateCheckbox("Anti-AFK", true, function(state)
    if state then
        print("Anti-AFK is now ON")
    else
        print("Anti-AFK is now OFF")
    end
end)
```
---

 ## Future Plans
* Improving the UI
* Adding a key system
* Adding more components
* Adding auto Load/Silent load
* Adding change key Binde (Right now the menu is only toggleable using insert)
* Adding support for mobile 
