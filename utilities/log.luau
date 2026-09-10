local log = {}

type SuppressPredicate = () -> boolean

local function prefix(): boolean
    if typeof(getgenv) ~= "function" then
        return false
    end
    local ok, secureModeSource = pcall(function()
        return getgenv().ASTRA_SECURE
    end)
    return ok and secureModeSource == true
end

local a4: SuppressPredicate = prefix
local a5: SuppressPredicate? = nil

function log.setSecureModeSource(a6: SuppressPredicate?)
    a4 = if type(a6) == "function" then a6 else prefix
end

function log.setSuppressPredicate(a7: SuppressPredicate?)
    a5 = if type(a7) == "function" then a7 else nil
end

local function a8(): boolean
    if a5 and a5() then
        return true
    end
    return a4()
end

function log.warn(...)
    if a8() then
        return
    end
    warn(...)
end

function log.print(...)
    if a8() then
        return
    end
    print(...)
end

return log
