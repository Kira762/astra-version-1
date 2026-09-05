local a1 = require(script.Parent.filesystem)
local a2 = require(script.Parent.path)

local a3 = "Astra"

local a4 = {}
a4.__index = a4

export type FileSystemManager = {
    root: string,
    assets: string,
    getPath: (self: FileSystemManager, subpath: string?) -> string,
    getAssetsFolder: (self: FileSystemManager, subfolder: string?) -> string,
    getRootFolder: (self: FileSystemManager) -> string,
}

function a4.new(a5: string?): FileSystemManager
        local a6 = a5 or a3
    local self = setmetatable({
        root = a6,
        assets = a6 .. "/Assets",
    }, a4) :: any
    pcall(a1.ensureFolder, self.root)
    pcall(a1.ensureFolder, self.assets)

    return self
end

function a4:getPath(a7: string?): string
    return a2.join(self.root, a7)
end

function a4:getAssetsFolder(a8: string?): string
    if a8 then
        local a9 = a2.join(self.assets, a8)
        pcall(a1.ensureFolder, a9)
        return a9
    end
    return self.assets
end

function a4:getRootFolder(): string
    return self.root
end

return a4
