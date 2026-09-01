local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rayfield = require(ReplicatedStorage.Rayfield)

return function(window: Rayfield.Window, tab: Rayfield.Tab)
        local railSection: Rayfield.TabSection = window:CreateSection({ name = "General" })
    railSection:Remove()

    local progress: Rayfield.Progress = tab:CreateProgress({ name = "Progress" })
    progress:Set(0.5)
    local progressValue: number = progress:Get()
    local progressRatio: number = progress:GetPercentage()
    progress:SetRange(0, 10)
    progress:SetText("halfway")
    progress:SetText(nil)     progress:SetIndeterminate(true)
    progress:Remove()

    local console: Rayfield.Console = tab:CreateConsole({ name = "Console" })
    console:Set("body")
    console:Append("line")
    console:Clear()
    local consoleBody: string = console:Get()
    local copied: boolean = console:Copy()
    console:SetHeight(160)
    console:Remove()

        local button: Rayfield.Button = tab:CreateButton({ name = "Button" })
    local toggle: Rayfield.Toggle = tab:CreateToggle({ name = "Toggle" })
    local slider: Rayfield.Slider = tab:CreateSlider({ name = "Slider" })
    local dropdown: Rayfield.Dropdown = tab:CreateDropdown({ name = "Dropdown" })
    local input: Rayfield.Input = tab:CreateInput({ name = "Input" })
    local keybind: Rayfield.Keybind = tab:CreateKeybind({ name = "Keybind" })
    local colorPicker: Rayfield.ColorPicker = tab:CreateColorPicker({ name = "Colour" })

    button:Lock("needs a key")
    toggle:Lock()
    slider:Lock()
    dropdown:Lock()
    input:Lock()
    keybind:Lock()
    colorPicker:Lock()

    button:Unlock()
    local locked: boolean = toggle:IsLocked()

    return progressValue, progressRatio, consoleBody, copied, locked
end
