-- Version: 0.0.3
-- Astra multi-tab supported-usage example.
-- This example loads the current bundle with remote icon asset resolution.

local Astra = loadstring(
    game:HttpGet(
        "https://raw.githubusercontent.com/Kira762/astra-version-1/main/version-1.luau"
    )
)()

assert(
    type(Astra) == "table" and type(Astra.CreateWindow) == "function",
    "[Astra] Failed to load Astra bundle."
)

local window = Astra:CreateWindow({
    name = "Astra Example",
    subtitle = "Multi-tab supported API example",
})

-- Keep each tab reference local and create it through the Window receiver.
-- Every element is then created through its Tab receiver.
local home = window:CreateTab({
    name = "Home",
    icon = "house",
})
home:CreateSection({ name = "Overview" })
home:CreateText({
    name = "Welcome",
    text = "This window demonstrates several independent Astra tabs.",
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

local controls = window:CreateTab({
    name = "Controls",
    icon = "sliders-horizontal",
})
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

local appearance = window:CreateTab({
    name = "Appearance",
    icon = "palette",
})
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

local information = window:CreateTab({
    name = "Information",
    icon = "info",
})
information:CreateText({
    name = "Supported usage",
    text = "Tabs are created with window:CreateTab, and controls with tab:Create... methods.",
})
information:CreateButton({
    name = "Show notification",
    callback = function()
        window:Toast({ title = "Astra", subtitle = "All example tabs are available." })
    end,
})

-- Select the first tab explicitly so the example is deterministic on startup.
home:Select()
