
local a1 = {}

local a2: { [string]: boolean } = {}

local a3 = {
    state = true,
    registry = true,
}

function a1.load(a4: string)
    assert(a3[a4], "Astra core loader: unknown module '" .. tostring(a4) .. "'")
    if a2[a4] then
        return nil
    end
    a2[a4] = true
    local ok, a5 = pcall(function()
        return require((script :: any).Parent[a4])
    end)
    a2[a4] = nil
    if not ok then
        error(a5, 0)
    end
    return a5
end

function a1.service(a6: string, a7: () -> any)
    local a8 = a1.load("registry")
    a8.registerFactory(a6, a7)
    return a8
end

return a1
