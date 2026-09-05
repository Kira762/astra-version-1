local a1 = {}

type SuppressPredicate = () -> boolean

local function a2(): boolean
    if typeof(getgenv) ~= "function" then
        return false
    end
    local ok, a3 = pcall(function()
        return getgenv().ASTRA_SECURE
    end)
    return ok and a3 == true
end

local a4: SuppressPredicate = a2
local a5: SuppressPredicate? = nil

function a1.setSecureModeSource(a6: SuppressPredicate?)
    a4 = if type(a6) == "function" then a6 else a2
end

function a1.setSuppressPredicate(a7: SuppressPredicate?)
    a5 = if type(a7) == "function" then a7 else nil
end

local function a8(): boolean
    if a5 and a5() then
        return true
    end
    return a4()
end

function a1.warn(...)
    if a8() then
        return
    end
    warn(...)
end

function a1.print(...)
    if a8() then
        return
    end
    print(...)
end

return a1
