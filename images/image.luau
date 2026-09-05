local a1 = require(script.Parent.Parent.cache.imageCache)
local a2 = require(script.Parent.Parent.core.state)

type AvatarCallback = imageCache.AvatarCallback
type PreloadCallback = imageCache.PreloadCallback

local a3 = {}

a3.rewrites = a1.rewrites
a3.onBlock = nil :: ((unknown) -> ())?

type PendingProperties = { [string]: boolean }

a3.pending = {} :: { [number]: { [Instance]: PendingProperties } }

local a4 = false

local a5: { [string]: boolean } = {
    Image = true,
    HoverImage = true,
    PressedImage = true,
}

local function a6(a7: unknown): number?
    if type(a7) == "number" then
        return a7
    elseif type(a7) == "string" then
        return tonumber(string.match(a7, "^rbxassetid://(%d+)$"))
    end
    return nil
end

local function a8(a9: unknown): string
    if a3.onBlock then
        a3.onBlock(a9)
    end
    return ""
end

function a3.preload(a10: PreloadCallback?): (boolean, number)
    a4 = false
    return a1.preload(function(a11, a12)
        a4 = true
        table.clear(a3.pending)
        if a10 then
            a10(a11, a12)
        end
    end)
end

function a3.avatar(a13: number, a14: AvatarCallback?): string
    local a15 = `rbxthumb://type=AvatarHeadShot&id={a13}&w=48&h=48`
    if not a2.secureMode then
        if a14 then
            task.defer(a14, a15)
        end
        return a15
    end

    return a1.avatar(a13, a14)
end

function a3.assign(a16: Instance, a17: string, a18: unknown)
    local a19 = a16 :: any
    if not a5[a17] then
        a19[a17] = a18
        return
    end

    local a20 = type(a18) == "string" and string.match(a18, "^https?://") ~= nil
    if a20 then
        a19[a17] = a1.remote(a18 :: string, function(a21)
            if a16.Parent then
                a19[a17] = a21 or ""
            end
        end)
    else
        a19[a17] = a3.resolve(a18)
    end
    if a2.secureMode and not a4 then
        local id = a6(a18)
        if id and not a3.rewrites[id] then
            local a22 = a3.pending[id]
            if not a22 then
                a22 = setmetatable({}, { __mode = "k" }) :: any
                a3.pending[id] = a22
            end
            local a23 = a22[a16]
            if not a23 then
                a23 = {}
                a22[a16] = a23
            end
            a23[a17] = true
        end
    end
end

a1.onCached = function(id: number)
    local a24 = a3.pending[id]
    if not a24 then
        return
    end
    local a25 = a3.rewrites[id]
    if a25 then
        for a26, a27 in a24 do
            if a26.Parent then
                local a28 = a26 :: any
                for a29 in a27 do
                    a28[a29] = a25
                end
            end
        end
    end
    a3.pending[id] = nil
end

function a3.resolve(a30: unknown): string
    if a30 == nil or a30 == 0 or a30 == "" then
        return ""
    end

    if type(a30) == "string" then
        if string.match(a30, "^https?://") then
            return a1.remote(a30)
        end
        if string.sub(a30, 1, 11) == "rbxasset://" then
            return a30
        end
        if string.sub(a30, 1, 11) == "rbxthumb://" then
            return if a2.secureMode then a8(a30) else a30
        end
    end

    local id: number? = nil
    if type(a30) == "number" then
        id = a30
    elseif type(a30) == "string" then
        id = tonumber(string.match(a30, "^rbxassetid://(%d+)$"))
    end

    local a31 = if id then a3.rewrites[id] else nil
    if a31 then
        return a31
    end

    if a2.secureMode then
        return a8(a30)
    end

    if type(a30) == "number" then
        return "rbxassetid://" .. a30
    end
    if type(a30) == "string" then
        return a30
    end

    return a8(a30)
end

return a3
