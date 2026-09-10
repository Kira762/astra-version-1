local state = require(script.state)
local registry = require(script.registry)
local loader = require(script.loader)

local core = {
    state = state,
    registry = registry,
    loader = loader,
}

return core
