
local a1 = {}

local a2: { [string]: any } = {}

function a1.singleton(a3: string, a4: () -> any): any
    local a5 = a2[a3]
    if a5 ~= nil then
        return a5
    end
    local a6 = a4()
    a2[a3] = a6
    return a6
end

function a1.get(a7: string): any?
    return a2[a7]
end

function a1.peek(a8: string): boolean
    return a2[a8] ~= nil
end

function a1._forget(a9: string)
    a2[a9] = nil
end

return a1
