
local manager = require(script.Parent.registry)
local values = require(script.Parent.defaults)
local listeners = require(script.Parent.persistence)
local validate = require(script.Parent.appearance)
local dirty = require(script.Parent.behavior)
local performanceDomain = require(script.Parent.performance)

local SettingsManager = {}

SettingsManager.__index = SettingsManager

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
    appearance = validate,
    behavior = dirty,
    performance = performanceDomain,
}

function SettingsManager.new(overrides: { [string]: any }?): SettingsManager
    local self = setmetatable({
        values = values.clone(overrides),
        listeners = {},
    }, SettingsManager)
    return self
end

function SettingsManager:get(key: string): any
    return self.values[key]
end

function SettingsManager:set(key: string, value: any): boolean
    local definition = manager.definition(key)
    if not definition then
        return false
    end

    local domainValidator = domains[definition.domain]
    local ok, validated
    if domainValidator then
        ok, validated = domainValidator.validate(key, value)
    else
        ok, validated = true, value
    end
    if not ok then
        return false
    end

    local oldValue = self.values[key]
    if oldValue == validated then
        return true
    end

    self.values[key] = validated
    for _, listener in self.listeners do
        task.spawn(listener, key, validated, oldValue)
    end
    return true
end

function SettingsManager:reset(key: string?): boolean
    if key then
        if not manager.definition(key) then
            return false
        end
        return self:set(key, values.values[key])
    end
    for _, key in manager.keys() do
        self:reset(key)
    end
    return true
end

function SettingsManager:onChange(listener: (string, any, any) -> ())
    table.insert(self.listeners, listener)
end

function SettingsManager:save(): boolean
    return listeners.save(self.values)
end

function SettingsManager:load(): boolean
    local snapshot = table.clone(self.values)
    local ok = listeners.load(self.values)
    if not ok then
        return ok
    end

    -- Notify listeners only for values that actually changed, matching the
    -- (key, newValue, oldValue) contract of :set(). Persisted values are
    -- written into self.values first; callbacks fire afterwards.
    for _, key in manager.keys() do
        local newValue = self.values[key]
        if snapshot[key] ~= newValue then
            for _, listener in self.listeners do
                task.spawn(listener, key, newValue, snapshot[key])
            end
        end
    end
    return ok
end

return SettingsManager
