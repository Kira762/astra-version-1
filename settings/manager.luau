-- Settings manager (settings/manager.luau).
--
-- Central settings API over the built-in registry: get/set/reset with
-- validation, default handling, and change notifications. Each window owns a
-- manager-scoped settings table so instances never share state. Settings are
-- an internal configuration system; UI renders them, but they are not
-- elements themselves.

local registry = require(script.Parent.registry)
local defaults = require(script.Parent.defaults)
local persistence = require(script.Parent.persistence)
local appearance = require(script.Parent.appearance)
local behavior = require(script.Parent.behavior)
local performance = require(script.Parent.performance)

local manager = {}

manager.__index = manager

export type SettingsManager = {
    values: { [string]: any },
    listeners: { [any]: (string, any, any) -> () },
    get: (self: SettingsManager, key: string) -> any,
    set: (self: SettingsManager, key: string, value: any) -> boolean,
    reset: (self: SettingsManager, key: string?) -> boolean,
    onChange: (self: SettingsManager, listener: (string, any, any) -> ()) -> (),
    save: (self: SettingsManager) -> boolean,
    load: (self: SettingsManager) -> boolean,
}

local domains = {
    appearance = appearance,
    behavior = behavior,
    performance = performance,
}

function manager.new(initialOverrides: { [string]: any }?): SettingsManager
    local self = setmetatable({
        values = defaults.clone(initialOverrides),
        listeners = {},
    }, manager)
    return self
end

function manager:get(key: string): any
    return self.values[key]
end

-- Validate + write a setting. Returns true when the value was applied.
-- Notification fires only for accepted changes to a different value.
function manager:set(key: string, value: any): boolean
    local definition = registry.definition(key)
    if not definition then
        return false
    end

    local domain = domains[definition.domain]
    local valid, normalized
    if domain then
        valid, normalized = domain.validate(key, value)
    else
        valid, normalized = true, value
    end
    if not valid then
        return false
    end

    local previous = self.values[key]
    if previous == normalized then
        return true
    end

    self.values[key] = normalized
    for _, listener in self.listeners do
        task.spawn(listener, key, normalized, previous)
    end
    return true
end

-- Restore one setting (or all with no key) to its default value.
function manager:reset(key: string?): boolean
    if key then
        if not registry.definition(key) then
            return false
        end
        return self:set(key, defaults.values[key])
    end
    for _, definedKey in registry.keys() do
        self:reset(definedKey)
    end
    return true
end

function manager:onChange(listener: (string, any, any) -> ())
    table.insert(self.listeners, listener)
end

function manager:save(): boolean
    return persistence.save(self.values)
end

function manager:load(): boolean
    return persistence.load(self.values)
end

return manager
