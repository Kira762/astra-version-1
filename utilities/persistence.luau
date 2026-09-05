local a1 = {}

local a2 = require(script.Parent.persistenceConfig)
local a3 = require(script.Parent.persistenceSettings)

a1.getPath = a2.getPath
a1.save = a2.save
a1.load = a2.load
a1.applyTo = a2.applyTo
a1.list = a2.list
a1.delete = a2.delete
a1.getSettingsPath = a3.getSettingsPath
a1.saveSettings = a3.saveSettings
a1.loadSettings = a3.loadSettings

return a1
