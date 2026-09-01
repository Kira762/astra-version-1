local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Astra = require(ReplicatedStorage.Astra)

return function(window: Astra.Window, tab: Astra.Tab)
        local railSection: Astra.TabSection = window:CreateSection({ name = "General" })
    railSection:Remove()

    local progress: Astra.Progress = tab:CreateProgress({ name = "Progress" })
    progress:Set(0.5)
    local progressValue: number = progress:Get()
    local progressRatio: number = progress:GetPercentage()
    progress:SetRange(0, 10)
    progress:SetText("halfway")
    progress:SetText(nil)     progress:SetIndeterminate(true)
    progress:Remove()

    local console: Astra.Console = tab:CreateConsole({ name = "Console" })
    console:Set("body")
    console:Append("line")
    console:Clear()
    local consoleBody: string = console:Get()
    local copied: boolean = console:Copy()
    console:SetHeight(160)
    console:Remove()

        local button: Astra.Button = tab:CreateButton({ name = "Button" })
    local toggle: Astra.Toggle = tab:CreateToggle({ name = "Toggle" })
    local slider: Astra.Slider = tab:CreateSlider({ name = "Slider" })
    local dropdown: Astra.Dropdown = tab:CreateDropdown({ name = "Dropdown" })
    local input: Astra.Input = tab:CreateInput({ name = "Input" })
    local keybind: Astra.Keybind = tab:CreateKeybind({ name = "Keybind" })
    local colorPicker: Astra.ColorPicker = tab:CreateColorPicker({ name = "Colour" })

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
