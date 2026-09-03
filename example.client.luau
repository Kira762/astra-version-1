local bundleSource = game:HttpGet("https://raw.githubusercontent.com/Kira762/astra-version-1/main/version-1.luau")
local bundleLoader, bundleError = loadstring(bundleSource)
assert(type(bundleLoader) == "function", "Astra bundle failed to compile: " .. tostring(bundleError))

local Astra = bundleLoader()
assert(type(Astra) == "table", "Astra bundle did not return its API table")
assert(Astra.Icons and Astra.Icons.lucide, "Astra bundle is missing the lucide icon pack")

local window = Astra:CreateWindow({
    name = "Astra",
    subtitle = "Example UI - Lucide Icons",
    iconPack = "lucide",
    sidebarLayout = true,
    configuration = {
        autoSave = true,
        autoLoad = true,
        fileName = "ExampleConfig",
    },
})

window:CreateSection({ name = "Main" })

local home = window:CreateTab({ name = "Home", icon = "house" })

home:CreateSection({ name = "Buttons" })

home:CreateButton({
    name = "Click Me",
    icon = "play",
})

home:CreateButton({
    name = "With Icon",
    icon = "settings",
})

home:CreateButton({
    name = "With Description",
    description = "This button has a description below it.",
})

home:CreateSection({ name = "Toggles" })

home:CreateToggle({
    name = "Basic Toggle",
    icon = "toggle-right",
    value = true,
})

home:CreateToggle({
    name = "Described Toggle",
    icon = "bell",
    description = "This toggle has a description.",
})

home:CreateToggle({
    name = "Flagged Toggle",
    icon = "flag",
    flag = "MyFlag",
    value = false,
})

home:CreateSection({ name = "Sliders" })

home:CreateSlider({
    name = "Basic Slider",
    range = { 0, 100 },
    value = 50,
})

home:CreateSlider({
    name = "With Suffix",
    range = { 0, 360 },
    value = 180,
    increment = 1,
    suffix = "°",
})

home:CreateSlider({
    name = "With Description",
    description = "This slider has a description.",
    range = { 1, 10 },
    value = 5,
})

home:CreateSection({ name = "Dropdowns" })

home:CreateDropdown({
    name = "Basic Dropdown",
    options = { "Option 1", "Option 2", "Option 3" },
    value = "Option 1",
})

home:CreateDropdown({
    name = "Multi Select",
    multiSelect = true,
    options = { "A", "B", "C", "D" },
    value = { "A", "C" },
    placeholder = "Pick items",
})

home:CreateDropdown({
    name = "With Description",
    description = "This dropdown has a description.",
    options = { "Low", "Medium", "High" },
    value = "Medium",
})

local inputs = window:CreateTab({ name = "Inputs", icon = "keyboard" })

inputs:CreateSection({ name = "Text Inputs" })

inputs:CreateInput({
    name = "Basic Input",
    placeholder = "Type here",
})

inputs:CreateInput({
    name = "Numeric Input",
    numeric = true,
    value = "42",
})

inputs:CreateInput({
    name = "With Description",
    description = "This input has a description.",
    placeholder = "Enter value",
})

inputs:CreateSection({ name = "Keybinds" })

inputs:CreateKeybind({
    name = "Basic Keybind",
    value = Enum.KeyCode.F,
})

inputs:CreateKeybind({
    name = "Hold Mode",
    hold = true,
    value = Enum.KeyCode.LeftShift,
})

inputs:CreateSection({ name = "Color Pickers" })

inputs:CreateColorPicker({
    name = "Basic Color",
    color = Color3.fromRGB(96, 205, 255),
})

inputs:CreateColorPicker({
    name = "With Alpha",
    color = Color3.fromRGB(255, 100, 100),
    alpha = 0.8,
})

local display = window:CreateTab({ name = "Display", icon = "layout-dashboard" })

display:CreateSection({ name = "Stats" })

local stat1 = display:CreateStat({
    name = "Revenue",
    prefix = "$",
    value = 12400,
})

local stat2 = display:CreateStat({
    name = "Kills",
    value = 128,
})

display:CreateButton({
    name = "Update Stats",
    callback = function()
        stat1:Set(stat1.value + math.random(500, 3000))
        stat2:Set(stat2.value + math.random(1, 20))
    end,
})

display:CreateSection({ name = "Progress" })

display:CreateProgress({
    name = "Download",
    range = { 0, 100 },
    value = 35,
})

display:CreateProgress({
    name = "Steps",
    steps = 5,
    value = 2,
})

display:CreateProgress({
    name = "Loading",
    indeterminate = true,
})

display:CreateSection({ name = "Text" })

display:CreateText({
    name = "Title",
    text = "This is a text element with a title and body.",
})

display:CreateText({
    text = "This is body text only.",
})

display:CreateText({
    name = "With Icon",
    text = "This text has an icon.",
    icon = "house",
})

display:CreateSection({ name = "Dividers" })

display:CreateDivider()

display:CreateDivider({ text = "or" })

display:CreateDivider({ text = "spaced", spacing = 24 })

display:CreateDivider({ line = false, spacing = 20 })

display:CreateSection({ name = "Console" })

local console = display:CreateConsole({
    name = "Console",
    text = "-- output lands here",
    height = 130,
    follow = true,
    maxLines = 50,
})

display:CreateButton({
    name = "Log Line",
    callback = function()
        console:Append(string.format("[%s] New entry", os.date("%H:%M:%S")))
    end,
})

display:CreateButton({
    name = "Clear Console",
    callback = function()
        console:Clear()
    end,
})

display:CreateSection({ name = "Groups" })

local grid = display:CreateGroup()

local left = grid:CreateGroup({ direction = "column" })
left:CreateToggle({ name = "Left Toggle 1", value = true })
left:CreateToggle({ name = "Left Toggle 2" })

local right = grid:CreateGroup({ direction = "column" })
right:CreateToggle({ name = "Right Toggle 1", value = true })
right:CreateToggle({ name = "Right Toggle 2" })

local utility = window:CreateTab({ name = "Utility", icon = "search" })

utility:CreateSection({ name = "Notifications" })

utility:CreateButton({
    name = "Send Notification",
    callback = function()
        window:Notify({
            title = "Hello",
            content = "This is a notification.",
            icon = "settings",
        })
    end,
})

utility:CreateButton({
    name = "Send Toast",
    callback = function()
        window:Toast({
            title = "Saved",
            icon = "settings",
        })
    end,
})

utility:CreateButton({
    name = "Open Popup",
    callback = function()
        window:Popup({
            title = "Are you sure?",
            content = "This action cannot be undone.",
            icon = "x",
            options = {
                { text = "Cancel" },
                { text = "Confirm", style = "danger" },
            },
        })
    end,
})

utility:CreateSection({ name = "Tags" })

window:CreateTag({
    text = "v1.0.0",
    title = "Version",
    color = Color3.fromRGB(96, 205, 255),
})

utility:CreateSection({ name = "Window Controls" })

utility:CreateButton({
    name = "Hide Window",
    callback = function()
        window:Hide()
    end,
})

utility:CreateButton({
    name = "Save Config",
    callback = function()
        window:Save()
    end,
})

utility:CreateButton({
    name = "Load Config",
    callback = function()
        window:Load()
    end,
})

utility:CreateButton({
    name = "List Configs",
    callback = function()
        local configs = window:ListConfigs()
        for _, name in configs do
        end
    end,
})

local advanced = window:CreateTab({ name = "Advanced", icon = "sliders-horizontal" })

advanced:CreateSection({ name = "Runtime Controls" })

advanced:CreateToggle({
    name = "Performance Mode",
    icon = "gauge",
    description = "Prefer lower visual overhead while keeping the interface responsive.",
    value = false,
})

advanced:CreateToggle({
    name = "Auto Refresh",
    icon = "refresh-cw",
    description = "Refresh placeholder data automatically every few seconds.",
    value = true,
})

advanced:CreateDropdown({
    name = "Refresh Interval",
    icon = "timer",
    options = { "5 seconds", "15 seconds", "30 seconds", "1 minute" },
    value = "15 seconds",
})

advanced:CreateSlider({
    name = "Update Frequency",
    icon = "activity",
    description = "Adjust how often the example would poll for new data.",
    range = { 1, 60 },
    value = 15,
    increment = 1,
    suffix = " sec",
})

advanced:CreateSection({ name = "Developer Tools" })

advanced:CreateInput({
    name = "Workspace Name",
    icon = "folder-open",
    description = "A placeholder input for a project or workspace identifier.",
    placeholder = "example-workspace",
})

advanced:CreateKeybind({
    name = "Toggle Developer Panel",
    icon = "terminal",
    value = Enum.KeyCode.F3,
})

advanced:CreateColorPicker({
    name = "Accent Preview",
    icon = "palette",
    color = Color3.fromRGB(96, 205, 255),
    alpha = 0.9,
})

advanced:CreateSection({ name = "Execution" })

local advancedProgress = advanced:CreateProgress({
    name = "Task Progress",
    icon = "loader-circle",
    range = { 0, 100 },
    value = 68,
})

advanced:CreateButton({
    name = "Run Placeholder Task",
    icon = "circle-play",
    description = "Simulates a task and advances the progress indicator.",
    callback = function()
        advancedProgress:Set(math.min(100, advancedProgress.value + 8))
    end,
})

advanced:CreateButton({
    name = "Reset Task",
    icon = "rotate-ccw",
    callback = function()
        advancedProgress:Set(0)
    end,
})

local activity = window:CreateTab({ name = "Activity", icon = "activity" })

activity:CreateSection({ name = "Recent Activity" })

activity:CreateText({
    name = "Today",
    icon = "calendar-days",
    text = "Your placeholder activity feed can show events, status changes, and recent actions here.",
})

local activityConsole = activity:CreateConsole({
    name = "Event Stream",
    icon = "radio-tower",
    text = "[system] Waiting for activity...",
    height = 150,
    follow = true,
    maxLines = 80,
})

activity:CreateButton({
    name = "Add Activity Event",
    icon = "circle-plus",
    callback = function()
        activityConsole:Append(string.format("[%s] Placeholder event received", os.date("%H:%M:%S")))
    end,
})

activity:CreateButton({
    name = "Clear Activity",
    icon = "trash-2",
    callback = function()
        activityConsole:Clear()
    end,
})

activity:CreateSection({ name = "Filters" })

activity:CreateToggle({
    name = "Show System Events",
    icon = "server",
    value = true,
})

activity:CreateToggle({
    name = "Show User Events",
    icon = "user-round",
    value = true,
})

activity:CreateDropdown({
    name = "Activity Range",
    icon = "calendar-range",
    options = { "Today", "This week", "This month", "All time" },
    value = "Today",
})

local about = window:CreateTab({ name = "About", icon = "info" })

about:CreateSection({ name = "Astra Example" })

about:CreateText({
    name = "Component Showcase",
    icon = "sparkles",
    text = "A detailed placeholder window demonstrating tabs, actions, forms, progress, statistics, notifications, groups, tags, and console output with the Lucide icon pack.",
})

about:CreateDivider({ text = "Resources" })

about:CreateButton({
    name = "View Documentation",
    icon = "book-open",
    description = "Placeholder action for opening the project documentation.",
    callback = function()
        window:Toast({
            title = "Documentation",
            subtitle = "This is a placeholder action.",
            icon = "book-open",
        })
    end,
})

about:CreateButton({
    name = "Check for Updates",
    icon = "cloud-download",
    callback = function()
        window:Notify({
            title = "You are up to date",
            content = "The example is running the latest placeholder build.",
            icon = "circle-check",
        })
    end,
})

about:CreateSection({ name = "Environment" })

local environment = about:CreateGroup({ direction = "column" })

environment:CreateStat({
    name = "Version",
    value = 100,
    prefix = "v",
    suffix = ".0.0",
    icon = "tag",
})
environment:CreateText({
    name = "Icon Pack",
    text = "Lucide",
    icon = "library",
})
environment:CreateStat({
    name = "Status",
    value = 1,
    suffix = " ready",
    icon = "circle-check",
})

about:CreateSection({ name = "Tags" })

window:CreateTag({
    text = "Lucide",
    icon = "sparkles",
    color = Color3.fromRGB(156, 125, 255),
})

window:CreateTag({
    text = "Sidebar",
    icon = "panel-left",
    color = Color3.fromRGB(96, 205, 255),
})

window:CreateTag({
    text = "Demo",
    icon = "badge-check",
    color = Color3.fromRGB(80, 210, 160),
})

window:Navigate("Home")
