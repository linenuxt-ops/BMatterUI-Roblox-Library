# Black Matter UI (v1.0)

A high-performance, dark-themed UI library for Roblox cheat developers.

## Features
* **Auto-Layout:** Cards automatically balance between left and right columns.
* **Smart Search:** Real-time filtering for features.
* **Modern UI:** Built-in Toast notifications and smooth Tweens.
* **Customizable:** Change accent colors on the fly.

## How to Use
```lua
local ZeroUI = loadstring(game:HttpGet("YOUR_RAW_URL_HERE"))()
local Window = ZeroUI.new("ZeroUI Test")

local Tab = Window:CreateTab("General")
local Card = Window:CreateCard(Tab, "Left", "Settings")

Window:CreateButton(Card, "Click Me", function()
    Window:Notification("Success", "Button was clicked!")
end)
```
## Future Plans
* Improving the UI
* Adding a key system
* Adding more components
* Adding resizable menu
* Improve Smart Search (Then looking for a card view it will be looking for a text)
* Adding auto Load/Silent load
* Adding change key Binde (Right now the menu is only toggleable using insert)
* Adding support for mobile
