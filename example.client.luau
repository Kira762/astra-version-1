local a1 = game:HttpGet("https://raw.githubusercontent.com/Kira762/astra-version-1/main/version-1.luau")
local a2, a3 = loadstring(a1)
assert(type(a2) == "function", "Astra bundle failed to compile: " .. tostring(a3))

local a4 = a2()
assert(type(a4) == "table", "Astra bundle did not return its API table")
assert(a4.Icons and a4.Icons.lucide, "Astra bundle is missing the lucide icon pack")

local window = a4:CreateWindow({
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

local a5 = window:CreateTab({ name = "Home", icon = "house" })

a5:CreateSection({ name = "Buttons" })

a5:CreateButton({
    name = "Click Me",
    icon = "play",
    callback = function()
        window:Toast({ title = "Button clicked", subtitle = "Click Me is working." })
    end,
})

a5:CreateButton({
    name = "With Icon",
    icon = "settings",
    callback = function()
        window:Toast({ title = "Button clicked", subtitle = "The icon button is working." })
    end,
})

a5:CreateButton({
    name = "With Description",
    description = "This button has a description below it.",
    callback = function()
        window:Toast({ title = "Button clicked", subtitle = "The described button is working." })
    end,
})

a5:CreateSection({ name = "Toggles" })

a5:CreateToggle({
    name = "Basic Toggle",
    icon = "toggle-right",
    value = true,
})

a5:CreateToggle({
    name = "Described Toggle",
    icon = "bell",
    description = "This toggle has a description.",
})

a5:CreateToggle({
    name = "Flagged Toggle",
    icon = "flag",
    flag = "MyFlag",
    value = false,
})

a5:CreateSection({ name = "Sliders" })

a5:CreateSlider({
    name = "Basic Slider",
    range = { 0, 100 },
    value = 50,
})

a5:CreateSlider({
    name = "With Suffix",
    range = { 0, 360 },
    value = 180,
    increment = 1,
    suffix = "°",
})

a5:CreateSlider({
    name = "With Description",
    description = "This slider has a description.",
    range = { 1, 10 },
    value = 5,
})

a5:CreateSection({ name = "Dropdowns" })

a5:CreateDropdown({
    name = "Basic Dropdown",
    options = { "Option 1", "Option 2", "Option 3" },
    value = "Option 1",
})

a5:CreateDropdown({
    name = "Multi Select",
    multiSelect = true,
    options = { "A", "B", "C", "D" },
    value = { "A", "C" },
    placeholder = "Pick items",
})

a5:CreateDropdown({
    name = "With Description",
    description = "This dropdown has a description.",
    options = { "Low", "Medium", "High" },
    value = "Medium",
})

local a6 = window:CreateTab({ name = "Inputs", icon = "keyboard" })

a6:CreateSection({ name = "Text Inputs" })

a6:CreateInput({
    name = "Basic Input",
    placeholder = "Type here",
})

a6:CreateInput({
    name = "Numeric Input",
    numeric = true,
    value = "42",
})

a6:CreateInput({
    name = "With Description",
    description = "This input has a description.",
    placeholder = "Enter value",
})

a6:CreateSection({ name = "Keybinds" })

a6:CreateKeybind({
    name = "Basic Keybind",
    value = Enum.KeyCode.F,
})

a6:CreateKeybind({
    name = "Hold Mode",
    hold = true,
    value = Enum.KeyCode.LeftShift,
})

a6:CreateSection({ name = "Color Pickers" })

a6:CreateColorPicker({
    name = "Basic Color",
    color = Color3.fromRGB(96, 205, 255),
})

a6:CreateColorPicker({
    name = "With Alpha",
    color = Color3.fromRGB(255, 100, 100),
    alpha = 0.8,
})

local a7 = window:CreateTab({ name = "Display", icon = "layout-dashboard" })

a7:CreateSection({ name = "Stats" })

local a8 = a7:CreateStat({
    name = "Revenue",
    prefix = "$",
    value = 12400,
})

local a9 = a7:CreateStat({
    name = "Kills",
    value = 128,
})

a7:CreateButton({
    name = "Update Stats",
    callback = function()
        a8:Set(a8.value + math.random(500, 3000))
        a9:Set(a9.value + math.random(1, 20))
    end,
})

a7:CreateSection({ name = "Progress" })

a7:CreateProgress({
    name = "Download",
    range = { 0, 100 },
    value = 35,
})

a7:CreateProgress({
    name = "Steps",
    steps = 5,
    value = 2,
})

a7:CreateProgress({
    name = "Loading",
    indeterminate = true,
})

a7:CreateSection({ name = "Text" })

a7:CreateText({
    name = "Title",
    text = "This is a text element with a title and body.",
})

a7:CreateText({
    text = "This is body text only.",
})

a7:CreateText({
    name = "With Icon",
    text = "This text has an icon.",
    icon = "house",
})

a7:CreateSection({ name = "Dividers" })

a7:CreateDivider()

a7:CreateDivider({ text = "or" })

a7:CreateDivider({ text = "spaced", spacing = 24 })

a7:CreateDivider({ line = false, spacing = 20 })

a7:CreateSection({ name = "Console" })

local a10 = a7:CreateConsole({
    name = "Console",
    text = "-- output lands here",
    height = 130,
    follow = true,
    maxLines = 50,
})

a7:CreateButton({
    name = "Log Line",
    callback = function()
        a10:Append(string.format("[%s] New entry", os.date("%H:%M:%S")))
    end,
})

a7:CreateButton({
    name = "Clear Console",
    callback = function()
        a10:Clear()
    end,
})

a7:CreateSection({ name = "Groups" })

local a11 = a7:CreateGroup()

local a12 = a11:CreateGroup({ direction = "column" })
a12:CreateToggle({ name = "Left Toggle 1", value = true })
a12:CreateToggle({ name = "Left Toggle 2" })

local a13 = a11:CreateGroup({ direction = "column" })
a13:CreateToggle({ name = "Right Toggle 1", value = true })
a13:CreateToggle({ name = "Right Toggle 2" })

local a14 = window:CreateTab({ name = "Utility", icon = "search" })

a14:CreateSection({ name = "Notifications" })

a14:CreateButton({
    name = "Send Notification",
    callback = function()
        window:Notify({
            title = "Hello",
            content = "This is a notification.",
            icon = "settings",
        })
    end,
})

a14:CreateButton({
    name = "Send Toast",
    callback = function()
        window:Toast({
            title = "Saved",
            icon = "settings",
        })
    end,
})

a14:CreateButton({
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

a14:CreateSection({ name = "Tags" })

window:CreateTag({
    text = "v1.0.0",
    title = "Version",
    color = Color3.fromRGB(96, 205, 255),
})

a14:CreateSection({ name = "Window Controls" })

a14:CreateButton({
    name = "Hide Window",
    callback = function()
        window:Hide()
    end,
})

a14:CreateButton({
    name = "Save Config",
    callback = function()
        window:Save()
    end,
})

a14:CreateButton({
    name = "Load Config",
    callback = function()
        window:Load()
    end,
})

a14:CreateButton({
    name = "List Configs",
    callback = function()
        local a15 = window:ListConfigs()
        for _, a16 in a15 do
        end
    end,
})

local a17 = window:CreateTab({ name = "Advanced", icon = "sliders-horizontal" })

a17:CreateSection({ name = "Runtime Controls" })

a17:CreateToggle({
    name = "Performance Mode",
    icon = "gauge",
    description = "Prefer lower visual overhead while keeping the interface responsive.",
    value = false,
})

a17:CreateToggle({
    name = "Auto Refresh",
    icon = "refresh-cw",
    description = "Refresh placeholder data automatically every few seconds.",
    value = true,
})

a17:CreateDropdown({
    name = "Refresh Interval",
    icon = "timer",
    options = { "5 seconds", "15 seconds", "30 seconds", "1 minute" },
    value = "15 seconds",
})

a17:CreateSlider({
    name = "Update Frequency",
    icon = "activity",
    description = "Adjust how often the example would poll for new data.",
    range = { 1, 60 },
    value = 15,
    increment = 1,
    suffix = " sec",
})

a17:CreateSection({ name = "Developer Tools" })

a17:CreateInput({
    name = "Workspace Name",
    icon = "folder-open",
    description = "A placeholder input for a project or workspace identifier.",
    placeholder = "example-workspace",
})

a17:CreateKeybind({
    name = "Toggle Developer Panel",
    icon = "terminal",
    value = Enum.KeyCode.F3,
})

a17:CreateColorPicker({
    name = "Accent Preview",
    icon = "palette",
    color = Color3.fromRGB(96, 205, 255),
    alpha = 0.9,
})

a17:CreateSection({ name = "Execution" })

local a18 = a17:CreateProgress({
    name = "Task Progress",
    icon = "loader-circle",
    range = { 0, 100 },
    value = 68,
})

a17:CreateButton({
    name = "Run Placeholder Task",
    icon = "circle-play",
    description = "Simulates a task and advances the progress indicator.",
    callback = function()
        a18:Set(math.min(100, a18.value + 8))
    end,
})

a17:CreateButton({
    name = "Reset Task",
    icon = "rotate-ccw",
    callback = function()
        a18:Set(0)
    end,
})

local a19 = window:CreateTab({ name = "Activity", icon = "activity" })

a19:CreateSection({ name = "Recent Activity" })

a19:CreateText({
    name = "Today",
    icon = "calendar-days",
    text = "Your placeholder activity feed can show events, status changes, and recent actions here.",
})

local a20 = a19:CreateConsole({
    name = "Event Stream",
    icon = "radio-tower",
    text = "[system] Waiting for activity...",
    height = 150,
    follow = true,
    maxLines = 80,
})

a19:CreateButton({
    name = "Add Activity Event",
    icon = "circle-plus",
    callback = function()
        a20:Append(string.format("[%s] Placeholder event received", os.date("%H:%M:%S")))
    end,
})

a19:CreateButton({
    name = "Clear Activity",
    icon = "trash-2",
    callback = function()
        a20:Clear()
    end,
})

a19:CreateSection({ name = "Filters" })

a19:CreateToggle({
    name = "Show System Events",
    icon = "server",
    value = true,
})

a19:CreateToggle({
    name = "Show User Events",
    icon = "user-round",
    value = true,
})

a19:CreateDropdown({
    name = "Activity Range",
    icon = "calendar-range",
    options = { "Today", "This week", "This month", "All time" },
    value = "Today",
})

local a21 = window:CreateTab({ name = "About", icon = "info" })

a21:CreateSection({ name = "Astra Example" })

a21:CreateText({
    name = "Component Showcase",
    icon = "sparkles",
    text = "A detailed placeholder window demonstrating tabs, actions, forms, progress, statistics, notifications, groups, tags, and console output with the Lucide icon pack.",
})

a21:CreateDivider({ text = "Resources" })

a21:CreateButton({
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

a21:CreateButton({
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

a21:CreateSection({ name = "Environment" })

local a22 = a21:CreateGroup({ direction = "column" })

a22:CreateStat({
    name = "Version",
    value = 100,
    prefix = "v",
    suffix = ".0.0",
    icon = "tag",
})
a22:CreateText({
    name = "Icon Pack",
    text = "Lucide",
    icon = "library",
})
a22:CreateStat({
    name = "Status",
    value = 1,
    suffix = " ready",
    icon = "circle-check",
})

a21:CreateSection({ name = "Tags" })

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
