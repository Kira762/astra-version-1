local a1 = require(script.Parent.network)
local a2 = require(script.Parent.log)

export type AssetId = number | string
export type AssetDownloadUrl = string
export type CacheKey = AssetId
export type ResolvedAsset = AssetId
export type AssetRequestPayload = {
    Url: string,
    Method: string,
}
local a3 = {
    Enum = {
        AssetDownloadUrl = {
            RobloxDownloadUrl = "https://assetdelivery.roblox.com/v1/asset/?id=%d" :: AssetDownloadUrl,
            RoProxyDownloadUrl = "https://assetdelivery.roproxy.com/v1/asset?id=%d" :: AssetDownloadUrl,
        },
    },
}
a3.__index = a3
a3.__type = "assetResolver"
type AssetResolverState = {
    contentCache: { [CacheKey]: string }?,
    contentCacheOrder: { CacheKey }?,
    contentDownloadUrl: AssetDownloadUrl,
    pendingRequests: { [CacheKey]: { thread } },
}
export type AssetResolver = AssetResolverState & {
    resolve: (self: AssetResolver, value: unknown) -> ResolvedAsset?,
    getAssetContentFromUrl: (self: AssetResolver, url: string, cacheKey: CacheKey?, forced: boolean?) -> string?,
    getAssetContentFromId: (self: AssetResolver, id: AssetId, forced: boolean?) -> string?,
}

local a4 = 8

function a3.new(a5: boolean?, a6: AssetDownloadUrl?): AssetResolver
    local a7: { [CacheKey]: string }? = if a5 then {} else nil
    local self = setmetatable(
        {
            contentCache = a7,
            contentCacheOrder = if a5 then {} :: { CacheKey } else nil,
            contentDownloadUrl = a6 or a3.Enum.AssetDownloadUrl.RobloxDownloadUrl,
            pendingRequests = {},
        } :: AssetResolverState,
        a3
    ) :: any
    return self
end

function a3.resolve(a8: AssetResolver, a9: unknown): ResolvedAsset?
    if type(a9) == "number" then
        return a9
    end

    if type(a9) ~= "string" then
        return nil
    end

    if string.sub(a9, 1, 11) == "rbxasset://" or string.sub(a9, 1, 11) == "rbxthumb://" then
        return a9
    end

    local id = tonumber(string.match(a9, "^rbxassetid://(%d+)$"))
    if id then
        return id
    end

    return nil
end

local function a10(a11: unknown): boolean
    if type(a11) ~= "table" then
        return false
    end
    local a12 = a11 :: { Body: unknown, StatusCode: unknown, Success: unknown }
    local a13 = a12.Body
    if type(a13) ~= "string" or #a13 == 0 then
        return false
    end
    if type(a12.StatusCode) == "number" then
        local a14 = a12.StatusCode :: number
        return a14 >= 200 and a14 < 300
    end
    if type(a12.Success) == "boolean" then
        return a12.Success :: boolean
    end
        return false
end

function a3.getAssetContentFromUrl(
    self: AssetResolver,
    a15: string,
    a16: CacheKey?,
    a17: boolean?
): string?
        local a18 = self.contentCache
    if a16 ~= nil and a18 and not a17 then
        local a19 = a18[a16]
        if a19 then
            return a19
        end
    end

            local a20 = self.pendingRequests
    if a16 ~= nil then
        local a21 = a20[a16]
        if a21 then
            if not coroutine.isyieldable() then
                return nil
            end
            local a22 = coroutine.running()
            if not a22 then
                return nil
            end
            table.insert(a21, a22)
            return coroutine.yield()
        end
        a20[a16] = {}
    end

    local a23: string? = nil
    local a24 = a1.getRequestFn()
    if not a24 then
        a2.warn("No request function available to download asset content.")
    else
        local a25, a26 = pcall(
            a24,
            {
                Url = a15,
                Method = "GET",
            } :: AssetRequestPayload
        )
        if a25 and a10(a26) then
            local a27 = (a26 :: { Body: string }).Body
            a23 = a27
            if a16 ~= nil and a18 then
                local a28 = self.contentCacheOrder
                if a28 and a18[a16] == nil then
                    table.insert(a28, a16)
                    local a29 = if #a28 > a4 then table.remove(a28, 1) else nil
                    if a29 ~= nil then
                        a18[a29] = nil
                    end
                end
                a18[a16] = a27
            end
        elseif not a17 then
            a2.warn("Failed to download asset content for url: " .. tostring(a15))
        end
    end

            if a16 ~= nil then
        local a30 = a20[a16]
        a20[a16] = nil
        if a30 then
            for _, a31 in a30 do
                pcall(coroutine.resume, a31, a23)
            end
        end
    end
    return a23
end

function a3.getAssetContentFromId(self: AssetResolver, id: AssetId, a32: boolean?): string?
    local a33 = self:resolve(id)
        if not a33 or type(a33) ~= "number" then
        a2.warn("Invalid asset id: " .. tostring(a33))
        return nil
    end

    local a34 = string.format(self.contentDownloadUrl, a33)
    return self:getAssetContentFromUrl(a34, a33, a32)
end

return a3
