
local a1 = {}

local a2: { [string]: any } = {}

function a1.getSettings(a3: string): any?
    return a2[a3]
end

function a1.putSettings(a4: string, a5: any)
    a2[a4] = a5
end

function a1.invalidateSettings(a6: string?)
    if a6 then
        a2[a6] = nil
    else
        table.clear(a2)
    end
end

return a1
