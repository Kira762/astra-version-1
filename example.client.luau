local Astra = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kira762/astra-version-1/main/version-1.luau"))()

local AstraLucidePack = Astra.Icons.Lucide

local window = Astra:CreateWindow({
    name = "Astra",
    subtitle = "Example UI - Lucide Icons",
    iconPack = AstraLucidePack,
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

window:Navigate("Home")
