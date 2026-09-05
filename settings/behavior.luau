
local a1 = {}

function a1.validate(a2: string, a3: any): (boolean, any)
    if a2 == "toggleKeybind" then
        return typeof(a3) == "EnumItem", a3
    end
    if a2 == "mouseOverride" or a2 == "welcomeToast" or a2 == "antiWindowDuplicate" then
        return type(a3) == "boolean", a3 == true
    end
    return false, nil
end

return a1
