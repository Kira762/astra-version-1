local a1 = {}

local a2 = 2166136261
local a3 = 16777619

local function a4(a5: string): number
    local a6 = a2
    for a7 = 1, #a5 do
        a6 = bit32.bxor(a6, string.byte(a5, a7))
                local a8 = a6 % 65536
        local a9 = (a6 - a8) / 65536
        a6 = (((a9 * a3) % 65536) * 65536 + a8 * a3) % 4294967296
    end
    return a6
end

function a1.deriveFlagFromName(a10: string): string
    local a11 = a10:gsub("(%S+)", function(w: string): string
        return w:sub(1, 1):upper() .. w:sub(2, -1)
    end):gsub("[^%w]", "")

            if a11 == "" and a10 ~= "" then
        return string.format("Flag%08x", a4(a10))
    end

    return a11
end

return a1
