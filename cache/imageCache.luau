local a1 = require(script.Parent.Parent.utilities.filesystem)
local a2 = require(script.Parent.Parent.utilities.path)
local a3 = require(script.Parent.Parent.core.state)
local a4 = require(script.Parent.Parent.utilities.constants)
local a5 = require(script.Parent.Parent.images.windowIcons)

export type RewriteMap = { [number]: string }
export type CacheSettledCallback = (failed: number, failedRoles: { string }) -> ()
export type PreloadCallback = CacheSettledCallback
export type AvatarCallback = (uri: string) -> ()
export type OnCachedCallback = (id: number) -> ()
export type ThumbnailEntry = {
    state: string?,
    imageUrl: string?,
}
export type ThumbnailResponse = {
    data: { ThumbnailEntry }?,
}
local a6 = {}

type RemoteCallback = (uri: string?) -> ()

local a7 = a3.fileSystemManager:getRootFolder()
local a8 = a3.fileSystemManager:getAssetsFolder()
local a9 = a3.assetResolver

local a10 = "https://raw.githubusercontent.com/Kira762/astra-version-1/main/assets/"
local a11 = 48
local a12 =
    "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=%d&size=%dx%d&format=Png&isCircular=false"

local a13: { [number]: string } = {}
local a14 = a5.manifest()
for a15 in a14 do
    a13[a15] = a10 .. tostring(a15) .. ".png"
end
local a16 = 0
for _ in a13 do
    a16 += 1
end

a6.rewrites = {} :: RewriteMap
a6.onCached = nil :: OnCachedCallback?
local a17 = "\137PNG\r\n\26\n"
local a18: { [string]: string } = {}
local a19: { [string]: { RemoteCallback } } = {}

local function a20(a21: string, a22: string): string?
        if type(getfenv().getcustomasset) ~= "function" or typeof(a1.isfile) ~= "function" then
        return nil
    end
    if not a1.isfile(a21) then
        pcall(a1.ensureFolder, a7)
        pcall(a1.ensureFolder, a8)
        local a23 = a9:getAssetContentFromUrl(a22, a21, false)
                        if not a23 or string.sub(a23, 1, 8) ~= a17 then
            return nil
        end
        if not pcall(a1.writefile, a21, a23) then
            return nil
        end
    end
    local ok, a24 = pcall(getfenv().getcustomasset, a21)
    return if ok and type(a24) == "string" then a24 else nil
end

local function a25(a26: string): string
    local a27 = 0
    for a28 = 1, #a26 do
        a27 = (a27 * 33 + string.byte(a26, a28)) % 2147483647
    end
    return a2.join(a8, "icon_" .. tostring(a27) .. ".png")
end

function a6.remote(a29: string, a30: RemoteCallback?): string
    local a31 = getfenv()
    if type(a31.getcustomasset) ~= "function" or typeof(a1.isfile) ~= "function" then
        if a30 then
            task.defer(a30, nil)
        end
        return ""
    end

    local a32 = a18[a29]
    if a32 then
        if a30 then
            task.defer(a30, a32)
        end
        return a32
    end

    local a33 = a25(a29)
    if a1.isfile(a33) then
        local ok, a34 = pcall(a31.getcustomasset, a33)
        if ok and type(a34) == "string" then
            a18[a29] = a34
            if a30 then
                task.defer(a30, a34)
            end
            return a34
        end
    end

    local a35 = a19[a29]
    if not a35 then
        a35 = {}
        a19[a29] = a35
        task.spawn(function()
            local a36 = a20(a33, a29)
            if a36 then
                a18[a29] = a36
            end
            local a37 = a19[a29]
            a19[a29] = nil
            if a37 then
                for _, a38 in a37 do
                    pcall(a38, a36)
                end
            end
        end)
    end
    if a30 then
        table.insert(a35, a30)
    end
    return ""
end

local function a39(a40: number): string
    return a2.join(a8, "avatar_" .. tostring(a40) .. ".png")
end

local function a41(a42: string): string?
    local a43, a44 = pcall(function()
        return a3.httpService:JSONDecode(a42)
    end)
    if not a43 or type(a44) ~= "table" then
        return nil
    end

    local a45 = (a44 :: ThumbnailResponse).data
    if type(a45) ~= "table" then
        return nil
    end

    local a46 = a45[1]
    if type(a46) ~= "table" then
        return nil
    end

    local a47 = a46 :: ThumbnailEntry
    if a47.state == "Completed" and type(a47.imageUrl) == "string" then
        return a47.imageUrl
    end

    return nil
end

local function a48(a49: number): string?
    local a50: string? = nil
    for a51 = 1, 4 do
                local a52 = a9:getAssetContentFromUrl(
            string.format(a12, a49, a11, a11),
            "avatar:" .. tostring(a49),
            a51 > 1
        )
        if a52 then
            local a53 = a41(a52)
            if a53 then
                a50 = a53
                break
            end
        end
        if a51 < 4 then
            task.wait(0.3)
        end
    end
    if not a50 then
        return nil
    end

    return a20(a39(a49), a50)
end

local a54: { [number]: { AvatarCallback } } = {}
local a55: { [number]: boolean } = {}

function a6.preload(a56: PreloadCallback?): (boolean, number)
    local a57 = getfenv()
    if type(a57.getcustomasset) ~= "function" or typeof(a1.isfile) ~= "function" then
        if a56 then
            task.defer(a56, a16, a5.roleList())
        end
        return false, a16
    end

    local a58 = a6.rewrites
    table.clear(a58)
    local function a59()
        if not a56 then
            return
        end
        local a60 = 0
        local a61 = {}
        for id in a13 do
            if not a58[id] then
                a60 += 1
                table.insert(a61, a5.roleForId(id))
            end
        end
        table.sort(a61)
        a56(a60, a61)
    end

    local a62, a63 = 0, 0
    local a64 = true     for id, a65 in a13 do
        local a66 = a2.join(a8, tostring(id) .. ".png")
        local a67: string? = nil
        if a1.isfile(a66) then
            local ok, a68 = pcall(a57.getcustomasset, a66)
            a67 = if ok and type(a68) == "string" then a68 else nil
        end
        if a67 then
                        a58[id] = a67
        else
                        a63 += 1
            a62 += 1
            task.spawn(function()
                local a69 = a20(a66, a65)
                if a69 then
                    a58[id] = a69
                    if a6.onCached then
                                                pcall(a6.onCached, id)
                    end
                end
                a62 -= 1
                if a62 == 0 and not a64 then
                    a59()
                end
            end)
        end
    end

    a64 = false
    if a62 == 0 then
        a59()
    end

    return a63 == 0, a63
end

function a6.avatar(a70: unknown, a71: AvatarCallback?): string
    if type(a70) ~= "number" then
        return ""
    end

        if typeof(a1.isfile) ~= "function" then
        return ""
    end

    local a72 = a39(a70)
    if a1.isfile(a72) then
        local ok, a73 = pcall(getfenv().getcustomasset, a72)
        if ok and type(a73) == "string" then
            return a73
        end
    end

        if a55[a70] then
        return ""
    end

            local a74 = a54[a70]
    if a74 then
        if a71 then
            table.insert(a74, a71)
        end
        return ""
    end

    if a71 then
        a54[a70] = { a71 }
        task.spawn(function()
            local a75 = a48(a70)
            local a76 = a54[a70]
            a54[a70] = nil
            if not a75 then
                a55[a70] = true
            end
            if a76 then
                for _, a77 in a76 do
                    pcall(a77, a75 or "")
                end
            end
        end)
    end

    return ""
end

return a6
