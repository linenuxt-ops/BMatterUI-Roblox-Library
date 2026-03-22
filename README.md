# Black Matter UI (v1.1)

## How to Use

```lua
task.wait(0.1)

-- Load the library
local success, BM_UI = pcall(function() 
    return loadstring(readfile("ui.lua"))() 
end)

if not success or not BM_UI then 
    warn("BM_UI: Failed to load ui.lua. Make sure the file exists!") 
    return 
end

-- Initialize the Menu
local menu = BM_UI:Init("BLACK MATTER")

-- 1. Create Categories
local combatTab = menu:CreateCategory("Combat")
local visualTab = menu:CreateCategory("Visuals")
local miscTab   = menu:CreateCategory("Misc")

-- 2. Create Cards
local combatCard = combatTab:CreateCard("Main Features", "Left")
local serverCard = combatTab:CreateCard("Server Utils", "Right")
local espCard    = visualTab:CreateCard("ESP Settings", "Left")
local worldCard  = visualTab:CreateCard("World Visuals", "Right")
local playerCard = miscTab:CreateCard("Player Actions", "Left")

-- 3. Add Elements
combatCard:AddToggle("Auto Execute", "auto_exec", false, function(val)
    print("Auto Exec status:", val)
end)

-- Use the new BUILT-IN utility buttons for Server Hopping
serverCard:AddSmallServerButton() 
serverCard:AddServerHopButton()

worldCard:AddSlider("Speed", "world_speed", 0, 100, 50, function(val) 
    print("Speed set to:", val)
end)

espCard:AddToggle("Enable ESP", "esp_toggle", false, function(state)
    print("ESP Status:", state)
end)

playerCard:AddButton("Reset Character", function()
    local char = game.Players.LocalPlayer.Character
    if char then char:BreakJoints() end
end)

-- 4. Testing Dropdowns & Built-in Anti-AFK
local extraDrop = miscTab:CreateDropdown("Extra Settings", "Right")

-- Use the new BUILT-IN utility toggle for Anti-AFK
extraDrop:AddAntiAFKToggle("anti_afk_flag")

extraDrop:AddButton("Save & Print Config", function()
    BM_UI:SaveConfig("manual_save")
    print("--- Current Flags ---")
    for flag, value in pairs(BM_UI.Flags) do
        print(tostring(flag) .. " -> " .. tostring(value))
    end
end)

print("BM_UI: Menu Fully Initialized!")
```
---

 ## Future Plans
* Improving the UI
* Adding a key system
* Adding more components
* Adding auto Load/Silent load
* Adding change key Binde (Right now the menu is only toggleable using insert)
* Adding support for mobile 
