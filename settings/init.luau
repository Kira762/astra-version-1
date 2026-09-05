
local a1 = require(script.manager)
local a2 = require(script.registry)
local a3 = require(script.defaults)
local a4 = require(script.persistence)

local a5 = {
    manager = a1,
    registry = a2,
    defaults = a3,
    persistence = a4,
}

function a5.newManager(a6: { [string]: any }?)
    return a1.new(a6)
end

function a5.readPersisted(a7: string, a8: any): any
    return a4.read(a7, a8)
end

return a5
