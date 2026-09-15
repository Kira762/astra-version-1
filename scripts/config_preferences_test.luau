-- [[Input is the library's only element, so the persisted pair under test is a
-- [[text field and a numeric field. Persistence watches flags, not element
-- [[types, so the coalescing/debounce/next-startup contract is unchanged.
local function create()
    local window = Astra:CreateWindow({ name = "Preferences" })
    local tab = window:CreateTab({ name = "Main" })
    local saved = {
        active = tab:CreateInput({ name = "Active", flag = "savedActive", value = "false" }),
        speed = tab:CreateInput({ name = "Speed", flag = "savedSpeed", value = "16", numeric = true }),
    }
    TestPump(1)
    return window, saved
end
local function settings(window)
    window:_buildSettingsUI()
    for _, tab in window._settingsTabs do
        if tab.name == "Persistence" then
            tab:Select()
            TestPump(0.4)
            local found = {}
            for _, element in tab.elements do
                if element.name then found[element.name] = element end
            end
            return found
        end
    end
    error("Persistence settings missing")
end
local window, saved = create()
assert(window.configuration.autoSave and window.configuration.autoLoad, "Save/load defaults are on")
assert(window.configuration.customFolder == "AstraConfigs" and window.configuration.fileName == "Astra-Hub", "Hidden path defaults")
local folder, path = window:GetPath()
assert(path:match("AstraConfigs/Astra%-Hub%.rfld$"), "Default path is used without a configuration prop")
local writes = 0
local originalSave = window.Save
window.Save = function(self, ...)
    writes += 1
    return originalSave(self, ...)
end
for n = 1, 30 do saved.speed:Set(n) end
saved.active:Set("true")
TestPump(0.5)
assert(writes == 1, "Autosave coalesces bursts of changes")
assert(isfile(path), "Autosave writes the default config")
local controls = settings(window)
assert(controls["Auto Save Config"] and controls["Auto Load Config"], "Both switches are in Persistence")
assert(
    controls["Saved Configurations"].value:find("Astra-Hub", 1, true) ~= nil,
    "Saved configuration is exposed in Settings"
)
local savedData = readfile(path)
controls["Auto Save Config"]:Set(false)
controls["Auto Load Config"]:Set(false)
TestPump(0.3)
saved.speed:Set(99)
TestPump(0.5)
assert(readfile(path) == savedData, "Disabled autosave never overwrites or deletes the config")
window:Unload()
window, saved = create()
assert(not window.configuration.autoSave and not window.configuration.autoLoad, "Preferences survive while autosave is off")
assert(saved.speed.value == "16" and saved.active.value == "false", "Disabled autoload leaves defaults")
controls = settings(window)
controls["Auto Load Config"]:Set(true)
TestPump(0.3)
assert(saved.speed.value == "16", "Enabling autoload does not overwrite this session")
window:Unload()
window, saved = create()
assert(saved.speed.value == "30" and saved.active.value == "true", "Next startup restores the saved values")
assert(not window.configuration.autoSave, "Save preference remains independent of load")
assert(Astra.Settings.newManager():set("autoSaveConfig", false), "Settings manager accepts the preference")
controls = settings(window)
controls["Auto Save Config"]:Set(true)
TestPump(0.2)
saved.speed:Set(44)
window:Unload() -- deliberately before the debounce fires
window, saved = create()
assert(saved.speed.value == "44", "Closing promptly flushes the last edit")
window:Unload()
print("CONFIG PREFERENCES: defaults, coalesced saving, independent switches and next-startup loading passed")
