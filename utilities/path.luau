local a1 = {}

function a1.join(a2: string, a3: string?): string
    if not a3 or a3 == "" then
        return a2
    end

    return a2 .. "/" .. a3
end

local function a4(a5: string): string
    local a6
    repeat
        a6 = a5
        a5 = a5:gsub("%.%.", "")
    until a5 == a6
    return a5
end

function a1.sanitizeFolder(a7: unknown): string
    local a8 = tostring(a7):gsub("\\", "/"):gsub('[:<>"|?*%c]', "")
    a8 = a4(a8):gsub("/+", "/")
    return (a8:gsub("^/+", ""))
end

function a1.sanitizeFile(a9: unknown): string
    local a10 = tostring(a9):gsub("[/\\]", ""):gsub('[:<>"|?*%c]', "")
    return a4(a10)
end

function a1.basename(a11: unknown): string
    return tostring(a11):match("[^/\\]+$") or tostring(a11)
end

function a1.stripExtension(a12: unknown, a13: string?): string
    if a13 and a13 ~= "" then
        local a14 = tostring(a12)
        if a14:sub(-#a13) == a13 then
            return a14:sub(1, -#a13 - 1)
        end
        return a14
    end

    local a15 = tostring(a12):match("^(.+)%.%w+$")
    return a15 or tostring(a12)
end

return a1
