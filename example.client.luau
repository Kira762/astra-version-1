-- Astra multi-tab supported-usage example.
-- This example loads the current bundle with remote icon asset resolution.

local Astra = loadstring(
    game:HttpGet("https://raw.githubusercontent.com/Kira762/astra-version-1/main/version-1.luau")
)()

assert(
    type(Astra) == "table" and type(Astra.CreateWindow) == "function",
    "[Astra] Failed to load Astra bundle."
)

local window = Astra:CreateWindow({
    name = "Astra Example",
    subtitle = "Multi-tab supported API example",
    icon = "sparkles",
    showHeader = true,
})

-- Window tags are rendered beside the window title and remain available in the chrome.
window:CreateTag({
    icon = "tag",
    text = "0.0.14",
})

-- Home: use a tab for overview content and simple state controls.
local home = window:CreateTab({ icon = "house" })
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
local controls = window:CreateTab({ icon = "sliders-horizontal" })
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
local appearance = window:CreateTab({ icon = "palette" })
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
local information = window:CreateTab({ icon = "info" })
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

-- Select the first tab explicitly so the example is deterministic on startup.
home:Select()
