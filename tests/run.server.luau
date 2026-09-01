local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TestEZModule = ReplicatedStorage:FindFirstChild("TestEZ")
if not TestEZModule then
    error("ReplicatedStorage.TestEZ is required. Run `make test-place` or use the Avant Plugin to run .spec tests.")
end

local TestEZ = require(TestEZModule)
local testsRoot = ReplicatedStorage:WaitForChild("Tests")

_G.__ASTRA_TEST_HELPERS = {
    requireUtility = function(name)
        return require(ReplicatedStorage.Astra.utility[name])
    end,
    requireComponent = function(name)
        return require(ReplicatedStorage.Astra.components[name])
    end,
    requireTheme = function(name)
        return require(ReplicatedStorage.Astra.themes[name])
    end,
    requireAstra = function()
        return require(ReplicatedStorage.Astra)
    end,
}
_G.__ASTRA_TEST_VERBOSE_LOGS = _G.__ASTRA_TEST_VERBOSE_LOGS == true

local log = require(ReplicatedStorage.Astra.utility.log)
log.setSuppressPredicate(function()
    return _G.__ASTRA_TEST_VERBOSE_LOGS ~= true
end)

local results = TestEZ.TestBootstrap:run({ testsRoot }, TestEZ.Reporters.TextReporter, {
    showTimingInfo = true,
})

if results.failureCount > 0 then
    error(string.format("%d TestEZ tests failed.", results.failureCount))
end
