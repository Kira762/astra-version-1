
local managerModule = require(script.manager)
local registryModule = require(script.registry)
local defaultsModule = require(script.defaults)
local persistenceModule = require(script.persistence)

local settings = {
    manager = managerModule,
    registry = registryModule,
    defaults = defaultsModule,
    persistence = persistence,
}

function settings.newManager(newManager: { [string]: any }?)
    return managerModule.new(newManager)
end

function settings.readPersisted(key: string, default: any): any
    return persistenceModule.read(key, default)
end

return settings
