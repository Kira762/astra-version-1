
local a1 = require(script.Parent.registry)
local a2 = require(script.Parent.defaults)
local a3 = require(script.Parent.persistence)
local a4 = require(script.Parent.appearance)
local a5 = require(script.Parent.behavior)
local a6 = require(script.Parent.performance)

local a7 = {}

a7.__index = a7

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

local a8 = {
    appearance = a4,
    behavior = a5,
    performance = a6,
}

function a7.new(a9: { [string]: any }?): SettingsManager
    local self = setmetatable({
        values = a2.clone(a9),
        listeners = {},
    }, a7)
    return self
end

function a7:get(a10: string): any
    return self.values[a10]
end

function a7:set(a11: string, a12: any): boolean
    local a13 = a1.definition(a11)
    if not a13 then
        return false
    end

    local a14 = a8[a13.domain]
    local a15, a16
    if a14 then
        a15, a16 = a14.validate(a11, a12)
    else
        a15, a16 = true, a12
    end
    if not a15 then
        return false
    end

    local a17 = self.values[a11]
    if a17 == a16 then
        return true
    end

    self.values[a11] = a16
    for _, a18 in self.listeners do
        task.spawn(a18, a11, a16, a17)
    end
    return true
end

function a7:reset(a19: string?): boolean
    if a19 then
        if not a1.definition(a19) then
            return false
        end
        return self:set(a19, a2.values[a19])
    end
    for _, a20 in a1.keys() do
        self:reset(a20)
    end
    return true
end

function a7:onChange(a21: (string, any, any) -> ())
    table.insert(self.listeners, a21)
end

function a7:save(): boolean
    return a3.save(self.values)
end

function a7:load(): boolean
    return a3.load(self.values)
end

return a7
