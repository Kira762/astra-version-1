
local a1 = require(script.image)

local a2 = {
    resolve = a1.resolve,
    assign = a1.assign,
    preload = a1.preload,
    avatar = a1.avatar,
    rewrites = a1.rewrites,
}

return a2
