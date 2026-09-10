local fs = require(script.Parent.Parent.utilities.filesystem)
local pathUtil = require(script.Parent.Parent.utilities.path)
local coreState = require(script.Parent.Parent.core.state)
local constants = require(script.Parent.Parent.utilities.constants)
local windowIcons = require(script.Parent.Parent.images.windowIcons)

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
local memoryHits = {}

type RemoteCallback = (uri: string?) -> ()

local diskHits = memoryCache.fileSystemManager:getRootFolder()
local assetsFolder = memoryCache.fileSystemManager:getAssetsFolder()
local assetResolver = memoryCache.assetResolver

local githubBase = "https://raw.githubusercontent.com/Kira762/astra-version-1/main/assets/"
local avatarSize = 48
local thumbnailUrl =
    "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=%d&size=%dx%d&format=Png&isCircular=false"

local remoteUrls: { [number]: string } = {}
local manifest = maxMemory.manifest()
for id in manifest do
    remoteUrls[id] = githubBase .. tostring(id) .. ".png"
end
local totalIcons = 0
for _ in remoteUrls do
    totalIcons += 1
end

memoryHits.rewrites = {} :: RewriteMap
memoryHits.onCached = nil :: OnCachedCallback?
local pngSignature = "\137PNG\r\n\26\n"
local uriCache: { [string]: string } = {}
local pendingCallbacks: { [string]: { RemoteCallback } } = {}

local function downloadAndRegister(diskPath: string, url: string): string?
        if type(getfenv().getcustomasset) ~= "function" or typeof(state.isfile) ~= "function" then
        return nil
    end
    if not state.isfile(diskPath) then
        pcall(state.ensureFolder, diskHits)
        pcall(state.ensureFolder, assetsFolder)
        local content = assetResolver:getAssetContentFromUrl(url, diskPath, false)
                        if not content or string.sub(content, 1, 8) ~= pngSignature then
            return nil
        end
        if not pcall(state.writefile, diskPath, content) then
            return nil
        end
    end
    local ok, uri = pcall(getfenv().getcustomasset, diskPath)
    return if ok and type(uri) == "string" then uri else nil
end

local function diskPathForUrl(url: string): string
    local hash = 0
    for i = 1, #url do
        hash = (hash * 33 + string.byte(url, i)) % 2147483647
    end
    return imageCache.join(assetsFolder, "icon_" .. tostring(hash) .. ".png")
end

function memoryHits.remote(url: string, callback: RemoteCallback?): string
    local env = getfenv()
    if type(env.getcustomasset) ~= "function" or typeof(state.isfile) ~= "function" then
        if callback then
            task.defer(callback, nil)
        end
        return ""
    end

    local cached = uriCache[url]
    if cached then
        if callback then
            task.defer(callback, cached)
        end
        return cached
    end

    local diskPath = diskPathForUrl(url)
    if state.isfile(diskPath) then
        local ok, uri = pcall(env.getcustomasset, diskPath)
        if ok and type(uri) == "string" then
            uriCache[url] = uri
            if callback then
                task.defer(callback, uri)
            end
            return uri
        end
    end

    local queue = pendingCallbacks[url]
    if not queue then
        queue = {}
        pendingCallbacks[url] = queue
        task.spawn(function()
            local uri = downloadAndRegister(diskPath, url)
            if uri then
                uriCache[url] = uri
            end
            local callbacks = pendingCallbacks[url]
            pendingCallbacks[url] = nil
            if callbacks then
                for _, cb in callbacks do
                    pcall(cb, uri)
                end
            end
        end)
    end
    if callback then
        table.insert(queue, callback)
    end
    return ""
end

local function avatarDiskPath(userId: number): string
    return imageCache.join(assetsFolder, "avatar_" .. tostring(userId) .. ".png")
end

local function parseThumbnailResponse(json: string): string?
    local ok, data = pcall(function()
        return memoryCache.httpService:JSONDecode(json)
    end)
    if not ok or type(data) ~= "table" then
        return nil
    end

    local entries = (data :: ThumbnailResponse).data
    if type(entries) ~= "table" then
        return nil
    end

    local entry = entries[1]
    if type(entry) ~= "table" then
        return nil
    end

    local entry = entry :: ThumbnailEntry
    if entry.state == "Completed" and type(entry.imageUrl) == "string" then
        return entry.imageUrl
    end

    return nil
end

local function fetchAvatarUrl(userId: number): string?
    local imageUrl: string? = nil
    for attempt = 1, 4 do
                local json = assetResolver:getAssetContentFromUrl(
            string.format(thumbnailUrl, userId, avatarSize, avatarSize),
            "avatar:" .. tostring(userId),
            attempt > 1
        )
        if json then
            local url = parseThumbnailResponse(json)
            if url then
                imageUrl = url
                break
            end
        end
        if attempt < 4 then
            task.wait(0.3)
        end
    end
    if not imageUrl then
        return nil
    end

    return downloadAndRegister(avatarDiskPath(userId), imageUrl)
end

local avatarPending: { [number]: { AvatarCallback } } = {}
local avatarFailed: { [number]: boolean } = {}

function memoryHits.preload(callback: PreloadCallback?): (boolean, number)
    local env = getfenv()
    if type(env.getcustomasset) ~= "function" or typeof(state.isfile) ~= "function" then
        if callback then
            task.defer(callback, totalIcons, maxMemory.roleList())
        end
        return false, totalIcons
    end

    local rewrites = memoryHits.rewrites
    table.clear(rewrites)
    local function notifyFailed()
        if not callback then
            return
        end
        local failedCount = 0
        local failedRoles = {}
        for id in remoteUrls do
            if not rewrites[id] then
                failedCount += 1
                table.insert(failedRoles, maxMemory.roleForId(id))
            end
        end
        table.sort(failedRoles)
        callback(failedCount, failedRoles)
    end

    local pending, failedCount = 0, 0
    local settled = true     for id, url in remoteUrls do
        local diskPath = imageCache.join(assetsFolder, tostring(id) .. ".png")
        local uri: string? = nil
        if state.isfile(diskPath) then
            local ok, uri = pcall(env.getcustomasset, diskPath)
            uri = if ok and type(uri) == "string" then uri else nil
        end
        if uri then
                        rewrites[id] = uri
        else
                        failedCount += 1
            pending += 1
            task.spawn(function()
                local uri = downloadAndRegister(diskPath, url)
                if uri then
                    rewrites[id] = uri
                    if memoryHits.onCached then
                                                pcall(memoryHits.onCached, id)
                    end
                end
                pending -= 1
                if pending == 0 and not settled then
                    notifyFailed()
                end
            end)
        end
    end

    settled = false
    if pending == 0 then
        notifyFailed()
    end

    return failedCount == 0, failedCount
end

function memoryHits.avatar(userId: unknown, callback: AvatarCallback?): string
    if type(userId) ~= "number" then
        return ""
    end

        if typeof(state.isfile) ~= "function" then
        return ""
    end

    local diskPath = avatarDiskPath(userId)
    if state.isfile(diskPath) then
        local ok, uri = pcall(getfenv().getcustomasset, diskPath)
        if ok and type(uri) == "string" then
            return uri
        end
    end

        if avatarFailed[userId] then
        return ""
    end

            local callbacks = avatarPending[userId]
    if callbacks then
        if callback then
            table.insert(callbacks, callback)
        end
        return ""
    end

    if callback then
        avatarPending[userId] = { callback }
        task.spawn(function()
            local uri = fetchAvatarUrl(userId)
            local callbacks = avatarPending[userId]
            avatarPending[userId] = nil
            if not uri then
                avatarFailed[userId] = true
            end
            if callbacks then
                for _, cb in callbacks do
                    pcall(cb, uri or "")
                end
            end
        end)
    end

    return ""
end

return memoryHits
