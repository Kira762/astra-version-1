
local a1 = {}

function a1.validate(a2: string, a3: any): (boolean, any)
    if a2 == "keepOnScreen" or a2 == "showProfile" or a2 == "showFullUsername" then
        return type(a3) == "boolean", a3 == true
    end
    if a2 == "layoutMode" then
        if a3 == "top" or a3 == "sidebar" or a3 == "collapsedSidebar" then
            return true, a3
        end
        return false, nil
    end
    if a2 == "activeSubTab" then
        return type(a3) == "number" and a3 >= 1, math.floor(a3)
    end
    return false, nil
end

return a1
