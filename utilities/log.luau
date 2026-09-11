local log = {}

type SuppressPredicate = () -> boolean

local function defaultSecureModePredicate(): boolean
    if typeof(getgenv) ~= "function" then
        return false
    end
    local ok, secureModeSource = pcall(function()
        return getgenv().ASTRA_SECURE
    end)
    return ok and secureModeSource == true
end

local secureModePredicate: SuppressPredicate = defaultSecureModePredicate
local suppressPredicate: SuppressPredicate? = nil

function log.setSecureModeSource(source: SuppressPredicate?)
    secureModePredicate = if type(source) == "function" then source else defaultSecureModePredicate
end

function log.setSuppressPredicate(predicate: SuppressPredicate?)
    suppressPredicate = if type(predicate) == "function" then predicate else nil
end

local function shouldSuppress(): boolean
    if suppressPredicate and suppressPredicate() then
        return true
    end
    return secureModePredicate()
end

function log.warn(...)
    if shouldSuppress() then
        return
    end
    warn(...)
end

function log.print(...)
    if shouldSuppress() then
        return
    end
    print(...)
end

return log
