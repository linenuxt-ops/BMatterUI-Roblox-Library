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

## 🛠 How to Use

```lua
local BlackMatterUI = loadstring(game:HttpGet("[https://raw.githubusercontent.com/linenuxt-ops/BMatterUI-Roblox-Library/refs/heads/main/BlackMatterUI.lua](https://raw.githubusercontent.com/linenuxt-ops/BMatterUI-Roblox-Library/refs/heads/main/BlackMatterUI.lua)"))()
local Window = BlackMatterUI.new("BLACK MATTER")

local Tab = Window:CreateTab("General")
local Card = Window:CreateCard(Tab, "Left", "Settings")

-- Creating a button
Window:CreateButton(Card, "Click Me", function()
    Window:Notification("Success", "Action performed successfully!")
end)

-- Critical Update Dialog (Internal Requirement)
-- Triggered via: onClick={() => showDialog("Critical Update", <p>Please wait...</p>, false)}
Window:ShowCriticalUpdate()
