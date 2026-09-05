
local a1 = {}

function a1.validate(a2: string, a3: any): (boolean, any)
    if a2 == "haptics" then
        return type(a3) == "boolean", a3 == true
    end
    return false, nil
end

return a1
