-- Performance settings domain (settings/performance.luau).
--
-- Validation for performance-related settings. Haptics is classified here
-- because enabling it allocates HapticEffect instances; disabling it tears
-- them down.

local performance = {}

function performance.validate(key: string, value: any): (boolean, any)
    if key == "haptics" then
        return type(value) == "boolean", value == true
    end
    return false, nil
end

return performance
