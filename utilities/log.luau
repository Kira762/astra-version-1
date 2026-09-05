local log = {}

type SuppressPredicate = () -> boolean

-- Default secure-mode source reads the same environment flag core/state reads.
-- Inlined here (instead of requiring core/state) so log stays a leaf module:
-- core/state registers a richer source through log.setSecureModeSource.
local function defaultSecureModeSource(): boolean
    if typeof(getgenv) ~= "function" then
        return false
    end
    local ok, val = pcall(function()
        return getgenv().ASTRA_SECURE
    end)
    return ok and val == true
end

local secureModeSource: SuppressPredicate = defaultSecureModeSource
local suppressPredicate: SuppressPredicate? = nil

function log.setSecureModeSource(source: SuppressPredicate?)
    secureModeSource = if type(source) == "function" then source else defaultSecureModeSource
end

function log.setSuppressPredicate(predicate: SuppressPredicate?)
    suppressPredicate = if type(predicate) == "function" then predicate else nil
end

local function shouldSuppress(): boolean
    if suppressPredicate and suppressPredicate() then
        return true
    end
    return secureModeSource()
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
