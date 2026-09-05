
local a1 = {}

local a2: { [string]: any } = {}
local a3: { [string]: () -> any } = {}

function a1.register(a4: string, a5: any)
    a2[a4] = a5
end

function a1.registerFactory(a6: string, a7: () -> any)
    a3[a6] = a7
end

function a1.get(a8: string): any?
    local a9 = a2[a8]
    if a9 ~= nil then
        return a9
    end
    local a10 = a3[a8]
    if a10 then
        local a11 = a10()
        a2[a8] = a11
        return a11
    end
    return nil
end

function a1.names(): { string }
    local a12 = {}
    for a13 in a2 do
        table.insert(a12, a13)
    end
    for a14 in a3 do
        if a2[a14] == nil then
            table.insert(a12, a14)
        end
    end
    table.sort(a12)
    return a12
end

return a1
