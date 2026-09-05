-- Default settings values (settings/defaults.luau).
--
-- These mirror the defaults the window previously embedded inline. The
-- manager clones this table per window so instances never share state.

local defaults = {}

defaults.values = {
    toggleKeybind = Enum.KeyCode.K,
    mouseOverride = true,
    keepOnScreen = true,
    welcomeToast = true,
    haptics = true,
    showProfile = true,
    showFullUsername = false,
    antiWindowDuplicate = true,
    layoutMode = "top", -- replaced by the window's actual initial layout mode
    activeSubTab = 1,
}

function defaults.clone(overrides: { [string]: any }?): { [string]: any }
    local cloned = table.clone(defaults.values)
    if overrides then
        for key, value in overrides do
            cloned[key] = value
        end
    end
    return cloned
end

return defaults
