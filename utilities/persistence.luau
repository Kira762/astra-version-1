local persistence = {}

local a2 = require(script.Parent.persistenceConfig)
local a3 = require(script.Parent.persistenceSettings)

persistence.getPath = a2.getPath
persistence.save = a2.save
persistence.load = a2.load
persistence.applyTo = a2.applyTo
persistence.list = a2.list
persistence.delete = a2.delete
persistence.getSettingsPath = a3.getSettingsPath
persistence.saveSettings = a3.saveSettings
persistence.loadSettings = a3.loadSettings

return persistence
