-- Appearance settings domain (settings/appearance.luau).
--
-- Validation and normalization for the visual/window appearance settings.
-- Settings are internal configuration, not UI elements; the window consumes
-- these through the manager.

local appearance = {}

appearance.keys = {
    keepOnScreen = true,
    showProfile = true,
    showFullUsername = true,
    layoutMode = true,
}

function appearance.validate(key: string, value: any): (boolean, any)
    if key == "keepOnScreen" or key == "showProfile" or key == "showFullUsername" then
        return type(value) == "boolean", value == true
    end
    if key == "layoutMode" then
        if value == "top" or value == "sidebar" or value == "collapsedSidebar" then
            return true, value
        end
        return false, nil
    end
    return false, nil
end

return appearance
