# Black Matter UI (v1.1)

A high-performance, dark-themed UI library for Roblox developers designed for speed, aesthetics, and ease of use.

---

## Update Log

### Version 1.1 (Latest)
* **Search System V2**: Overhauled the search logic. The UI now searches for specific text within buttons, toggles, and dropdowns rather than just filtering the card headers.
* **Auto-Cleanup**: Added logic to automatically detect and destroy previous versions of the menu if re-executed (prevents UI stacking).
* **Versioning**: Introduced `_G.BlackMatterVersion` tracking.
* **Critical Update Support**: Built-in support for mandatory dialog notifications.

---

## Features
* **Auto-Layout**: Cards automatically balance between left and right columns for organized layouts.
* **Smart Search**: Real-time filtering that deep-scans text inside every component.
* **Modern UI**: Built-in Toast notifications and smooth `TweenService` animations.
* **Customizable**: Full control over accent colors and window titles.
* **Safety**: Designed to run within `CoreGui` with a `PlayerGui` fallback.

---

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
* Adding resizable menu
* ~~Improve Smart Search (Then looking for a card view it will be looking for a text)~~ [DONE]
* Adding auto Load/Silent load
* Adding change key Binde (Right now the menu is only toggleable using insert)
* Adding support for mobile 
