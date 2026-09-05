-- Behavior settings domain (settings/behavior.luau).
--
-- Validation for interaction/behavioral settings: the toggle keybind, cursor
-- override, welcome toast, and the anti-duplicate-window guard.

local behavior = {}

behavior.keys = {
    toggleKeybind = true,
    mouseOverride = true,
    welcomeToast = true,
    antiWindowDuplicate = true,
}

function behavior.validate(key: string, value: any): (boolean, any)
    if key == "toggleKeybind" then
        return typeof(value) == "EnumItem", value
    end
    if key == "mouseOverride" or key == "welcomeToast" or key == "antiWindowDuplicate" then
        return type(value) == "boolean", value == true
    end
    return false, nil
end

return behavior
