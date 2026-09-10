
local behavior = {}

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
