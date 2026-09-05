
local icons = {}

icons.BASE = "https://raw.githubusercontent.com/Haijo12/sisys_ididh/main"

local packLoaders = {
    lucide = function()
        return require(script.lucide)
    end,
    material = function()
        return require(script.material)
    end,
    tabler = function()
        return require(script.tabler)
    end,
    phosphor = function()
        return require(script.phosphor)
    end,
    heroicons = function()
        return require(script.heroicons)
    end,
    feather = function()
        return require(script.feather)
    end,
}

local loadedPacks: { [string]: { [string]: string } } = {}

icons.Lucide = "lucide"
icons.Material = "material"
icons.Tabler = "tabler"
icons.Phosphor = "phosphor"
icons.Heroicons = "heroicons"
icons.Feather = "feather"

setmetatable(icons, {
    __index = function(self, pack: string)
        local loader = packLoaders[pack]
        if not loader then
            return nil
        end
        local data = loader()
        loadedPacks[pack] = data
        rawset(self, pack, data)
        return data
    end,
})

local function packTable(pack: string?): { [string]: string }?
    pack = pack or "lucide"
    if type(pack) ~= "string" then
        return nil
    end
    local cached = loadedPacks[pack]
    if cached then
        return cached
    end
    local loader = packLoaders[pack]
    if not loader then
        return nil
    end
    local data = loader()
    loadedPacks[pack] = data
    rawset(icons, pack, data)
    return data
end

function icons.isPack(pack: string?): boolean
    return pack ~= nil and type(pack) == "string" and packLoaders[pack] ~= nil
end

function icons.get(name: string, pack: string?): string?
    pack = pack or "lucide"
    local data = packTable(pack)
    if not data then
        warn("[Icons] Unknown pack: " .. pack)
        return nil
    end
    return data[name]
end

local customAssetFolder = "custom_asset"
local customAssetCache: { [string]: string } = {}

function icons.resolve(value: (string | number)?, pack: string?): (string | number)?
    if value == nil or value == 0 or value == "" then
        return value
    end
    if type(value) ~= "string" then
        return value
    end
    if string.match(value, "^rbxassetid://")
        or string.match(value, "^rbxasset://")
        or string.match(value, "^rbxthumb://")
        or string.match(value, "^https?://")
    then
        return value
    end
    local cached = customAssetCache[value]
    if cached then
        return cached
    end
    local env = getfenv and getfenv() or _G
    if type(env.getcustomasset) == "function" then
        local exts = { ".png", ".jpg", ".jpeg", ".webp", "" }
        for _, ext in exts do
            local filePath = customAssetFolder .. "/" .. value .. ext
            local ok, uri = pcall(env.getcustomasset, filePath)
            if ok and type(uri) == "string" and uri ~= "" then
                customAssetCache[value] = uri
                return uri
            end
        end
    end
    return icons.get(value, pack) or value
end

function icons.getByPack(pack: string, name: string): string?
    return icons.get(name, pack)
end

function icons.list(pack: string?): { string }
    pack = pack or "lucide"
    local data = packTable(pack)
    if not data then
        return {}
    end
    local result = {}
    for name in data do
        table.insert(result, name)
    end
    table.sort(result)
    return result
end

function icons.packs(): { string }
    return { "lucide", "material", "tabler", "phosphor", "heroicons", "feather" }
end

function icons.count(pack: string?): number
    pack = pack or "lucide"
    local data = packTable(pack)
    if not data then
        return 0
    end
    local n = 0
    for _ in data do
        n += 1
    end
    return n
end

return icons
