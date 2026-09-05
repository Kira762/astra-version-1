
local a1 = {}

a1.values = {
    toggleKeybind = Enum.KeyCode.K,
    mouseOverride = true,
    keepOnScreen = true,
    welcomeToast = true,
    haptics = true,
    showProfile = true,
    showFullUsername = false,
    antiWindowDuplicate = true,
    layoutMode = "top",    activeSubTab = 1,
}

function a1.clone(a2: { [string]: any }?): { [string]: any }
    local a3 = table.clone(a1.values)
    if a2 then
        for a4, a5 in a2 do
            a3[a4] = a5
        end
    end
    return a3
end

return a1
