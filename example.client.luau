local bundleUrl = "https://raw.githubusercontent.com/Kira762/astra-version-1/main/version-1.luau"
local function fetchBundle(url)
    if not game then
        return false, "game is unavailable"
    end

    -- Keep the method bound to `game`. Some executors expose HttpGet through
    -- userdata/metamethods and calling a detached `game.HttpGet` can become a
    -- nil-call even though `game:HttpGet(...)` works normally.
    if type(game.HttpGet) == "function" then
        return pcall(function()
            return game:HttpGet(url)
        end)
    end
    if type(game.HttpGetAsync) == "function" then
        return pcall(function()
            return game:HttpGetAsync(url)
        end)
    end
    return false, "this executor does not provide game:HttpGet or game:HttpGetAsync"
end

local requestOk, bundleSource = fetchBundle(bundleUrl)
assert(requestOk and type(bundleSource) == "string", "[Astra] Failed to download the Astra bundle: " .. tostring(bundleSource))
local compile = loadstring or load
assert(type(compile) == "function", "[Astra] This executor does not provide loadstring/load.")
local compileOk, bundleLoader, compileError = pcall(compile, bundleSource)
assert(compileOk, "[Astra] Bundle compilation raised an error: " .. tostring(bundleLoader))
assert(type(bundleLoader) == "function", "[Astra] Bundle compilation failed: " .. tostring(compileError))
local runOk, Astra = pcall(bundleLoader)
assert(runOk, "[Astra] Bundle startup raised an error: " .. tostring(Astra))

assert(
    type(Astra) == "table" and type(Astra.CreateWindow) == "function",
    "[Astra] Failed to load Astra bundle."
)

local window = Astra:CreateWindow({
    name = "Astra",
    subtitle = "Multi-tab supported API example",
})

-- Window tags are rendered beside the window title and remain available in the chrome.
window:CreateTag({
    icon = "tag",
    text = "0.0.36",
    color = Color3.fromRGB(96, 205, 255),
})

-- Home: use a tab for overview content and simple state controls.
local home = window:CreateTab({ name = "Home", icon = "house" })
home:CreateSection({ name = "Overview" })
home:CreateText({
    name = "Welcome",
    text = "Create tabs from the Window, then create elements from each Tab.",
})
home:CreateButton({
    name = "Say hello",
    callback = function()
        window:Notify({ title = "Hello", content = "The Home tab is working." })
    end,
})
home:CreateToggle({
    name = "Enable feature",
    value = true,
    callback = function(value)
        window:Notify({
            title = "Feature",
            content = if value then "Feature enabled." else "Feature disabled.",
        })
    end,
})

-- Controls: use input elements for values, choices, and user text.
local controls = window:CreateTab({ name = "Controls", icon = "sliders-horizontal" })
controls:CreateSection({ name = "Input elements" })
controls:CreateSlider({
    name = "Volume",
    range = { 0, 100 },
    value = 50,
    increment = 1,
    callback = function(value)
        window:Toast({ title = "Volume", subtitle = tostring(value) })
    end,
})
controls:CreateDropdown({
    name = "Mode",
    options = { "Default", "Performance", "Visual" },
    value = "Default",
    callback = function(value)
        window:Notify({ title = "Mode changed", content = tostring(value) })
    end,
})
controls:CreateInput({
    name = "Display name",
    placeholder = "Enter a name",
    callback = function(value)
        window:Toast({ title = "Name updated", subtitle = tostring(value) })
    end,
})

-- Appearance: use visual elements for colors, dividers, and explanatory text.
local appearance = window:CreateTab({ name = "Appearance", icon = "palette" })
appearance:CreateSection({ name = "Visual elements" })
appearance:CreateColorPicker({
    name = "Accent color",
    color = Color3.fromRGB(96, 205, 255),
    callback = function(value)
        window:Toast({ title = "Accent color updated", subtitle = tostring(value) })
    end,
})
appearance:CreateDivider()
appearance:CreateText({
    name = "Layout",
    text = "Use this tab for visual and theme-related controls.",
})

-- Information: document the Window, Tab, and element creation pattern.
local information = window:CreateTab({ name = "Information", icon = "info" })
information:CreateSection({ name = "Usage" })
information:CreateText({
    name = "Create a tab",
    text = 'local tab = window:CreateTab({ icon = "settings" })',
})
information:CreateText({
    name = "Create an element",
    text = 'tab:CreateButton({ name = "Action", callback = function() end })',
})
information:CreateText({
    name = "Select a tab",
    text = "Call tab:Select() to display a tab. This example selects Home on startup.",
})
information:CreateButton({
    name = "Show notification",
    callback = function()
        window:Toast({ title = "Astra", subtitle = "All example tabs are available." })
    end,
})
information:CreateSection({ name = "Additional elements" })
information:CreateProgress({
    name = "Progress",
    range = { 0, 100 },
    value = 68,
    steps = 10,
    suffix = "%",
})
information:CreateStat({
    name = "Active tests",
    value = 20,
    suffix = " tabs",
})
information:CreateKeybind({
    name = "Test shortcut",
    value = Enum.KeyCode.RightShift,
    callback = function()
        window:Toast({ title = "Shortcut", subtitle = "Test shortcut activated" })
    end,
})
local console = information:CreateConsole({
    name = "Test console",
    text = "A console element for displaying diagnostic lines.",
    height = 90,
})
console:Append("Changelog and element tests are ready.")
local elementGroup = information:CreateGroup({ direction = "column" })
elementGroup:CreateButton({
    name = "Group action",
    callback = function()
        window:Toast({ title = "Group", subtitle = "Grouped element action completed" })
    end,
})
elementGroup:CreateToggle({
    name = "Grouped toggle",
    value = true,
    callback = function(value)
        window:Toast({ title = "Grouped toggle", subtitle = if value then "Enabled" else "Disabled" })
    end,
})

-- Changelog: a dedicated tab so release news is always visible in the main window.
local changelogTab = window:CreateTab({ name = "Changelog", icon = "history" })
local changelog = changelogTab:CreateChangelog({
    name = "Recent changes",
    description = "Structured release notes with categorized changes.",
    entries = {
        {
            version = "0.0.36",
            date = "2026-09-11",
            title = "Executor compatibility diagnostics",
            description = "Guarded HTTP retrieval and bundle execution so missing executor APIs no longer produce an opaque nil-call.",
            changes = {
                { symbol = "~", category = "Fixed", text = "Added explicit checks for HttpGet, compilation, and bundle startup." },
            },
        },
        {
            version = "0.0.35",
            date = "2026-09-11",
            title = "Bundle loader diagnostics",
            description = "Improved startup errors so executor and bundle-loading failures are reported clearly.",
            changes = {
                { symbol = "~", category = "Fixed", text = "Replaced the opaque nil-call startup path with explicit loader validation." },
            },
        },
        {
            version = "0.0.34",
            date = "2026-09-11",
            title = "Tab visibility safeguard",
            description = "All twenty example tab selectors now remain available even when an optional test element cannot be constructed.",
            changes = {
                { symbol = "~", category = "Fixed", text = "Prevented one failed optional element from stopping later tabs from loading." },
            },
        },
        {
            version = "0.0.33",
            date = "2026-09-11",
            title = "Grouped toggle fix",
            description = "Fixed grouped toggles failing during construction and standardized release symbols.",
            changes = {
                { symbol = "~", category = "Fixed", text = "Grouped toggles now inherit the parent tab flag helper correctly." },
                { symbol = "~", category = "Changelog", text = "Release entries now use + for additions, - for removals, and ~ for fixes." },
            },
        },
        {
            version = "0.0.31",
            date = "2026-09-11",
            title = "Expanded element examples",
            description = "Added more supported elements to the example client for API and layout testing.",
            changes = {
                { symbol = "+", category = "Added", text = "Added progress, stat, keybind, console, and grouped element examples." },
                { symbol = "~", category = "Example", text = "The example now documents more element combinations without console output calls." },
            },
        },
        {
            version = "0.0.30",
            date = "2026-09-11",
            title = "Changelog element",
            description = "Added the Changelog element to Astra.",
            changes = {
                { symbol = "+", category = "Added", text = "CreateChangelog is now available on tabs." },
                { symbol = "~", category = "Compatibility", text = "Supports lowercase and PascalCase properties." },
            },
        },
    },
})
changelogTab:CreateButton({
    name = "Add test news",
    callback = function()
        changelog:Add({
            version = "Test",
            date = "Live",
            title = "Runtime update",
            changes = {
                { symbol = "+", text = "This release note was added at runtime." },
            },
        })
        window:Toast({ title = "Changelog", subtitle = "New entry added" })
    end,
})

-- Additional test tabs: twenty main-window tabs with varied elements.
local testTabs = {
    { name = "Dashboard", icon = "layout-dashboard" },
    { name = "Analytics", icon = "chart-no-axes-combined" },
    { name = "Profile", icon = "user-round" },
    { name = "Security", icon = "shield" },
    { name = "Network", icon = "wifi" },
    { name = "Audio", icon = "volume-2" },
    { name = "Display", icon = "monitor" },
    { name = "Shortcuts", icon = "keyboard" },
    { name = "Notifications", icon = "bell" },
    { name = "Storage", icon = "hard-drive" },
    { name = "Automation", icon = "bot" },
    { name = "Advanced", icon = "wrench" },
    { name = "Debug", icon = "bug" },
    { name = "Logs", icon = "scroll-text" },
    { name = "Experiments", icon = "flask-conical" },
}

for index, details in ipairs(testTabs) do
    local tab = window:CreateTab({ name = details.name, icon = details.icon })
    -- Keep the tab selector registered even if an optional element has an
    -- environment-specific constructor issue; this lets the remaining tabs load.
    local ok = pcall(function()
        tab:CreateSection({ name = "Test elements" })
        tab:CreateText({
            name = "Test tab " .. tostring(index),
            text = "This tab is part of the twenty-tab loading and layout test.",
        })
        tab:CreateButton({
            name = "Run test action",
            callback = function()
                window:Toast({ title = details.name, subtitle = "Action completed" })
            end,
        })

        if index % 4 == 1 then
            tab:CreateToggle({
            name = "Enabled",
            value = index % 3 == 0,
            callback = function(value)
                window:Toast({ title = details.name, subtitle = if value then "Enabled" else "Disabled" })
            end,
            })
            tab:CreateSlider({
            name = "Intensity",
            range = { 0, 100 },
            value = index * 5,
            increment = 5,
            callback = function(value)
                window:Toast({ title = details.name, subtitle = "Intensity: " .. tostring(value) })
            end,
            })
        elseif index % 4 == 2 then
            tab:CreateDropdown({
            name = "Preset",
            options = { "Low", "Medium", "High" },
            value = "Medium",
            callback = function(value)
                window:Toast({ title = details.name, subtitle = "Preset: " .. tostring(value) })
            end,
            })
            tab:CreateInput({
            name = "Label",
            placeholder = "Test input",
            callback = function(value)
                window:Toast({ title = details.name, subtitle = "Label: " .. tostring(value) })
            end,
            })
        elseif index % 4 == 3 then
            tab:CreateColorPicker({
            name = "Color",
            color = Color3.fromHSV(index / #testTabs, 0.7, 1),
            callback = function(value)
                window:Toast({ title = details.name, subtitle = "Color updated: " .. tostring(value) })
            end,
            })
            tab:CreateDivider()
        else
            tab:CreateText({ name = "Status", text = "Ready for testing." })
            tab:CreateToggle({
            name = "Experimental mode",
            value = false,
            callback = function(value)
                window:Toast({ title = details.name, subtitle = if value then "Experimental mode on" else "Experimental mode off" })
            end,
            })
        end
    end
end

-- Select the first tab explicitly so the example is deterministic on startup.
home:Select()
