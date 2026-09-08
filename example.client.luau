-- Astra example
-- Loads the bundled Astra library directly from GitHub.
-- Demonstrates the new icon system across the UI.

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
	name = "Astra",
	subtitle = "Example UI - New Icon System",
	icon = "sparkles",
	iconPack = "lucide",

	configuration = {
		autoSave = true,
		autoLoad = true,
		fileName = "ExampleConfig",
	},
})

window:CreateSection({
	name = "Main",
	icon = "layout-dashboard",
})

local homeTab = window:CreateTab({
	name = "Home",
	icon = "house",
})

homeTab:CreateSection({
	name = "Buttons",
	icon = "mouse-pointer-click",
})

homeTab:CreateButton({
	name = "Click Me",
	icon = "play",
	callback = function()
		window:Toast({
			title = "Button clicked",
			subtitle = "Click Me is working.",
			icon = "circle-check",
		})
	end,
})

homeTab:CreateButton({
	name = "With Icon",
	icon = "settings",
	callback = function()
		window:Toast({
			title = "Button clicked",
			subtitle = "The icon button is working.",
			icon = "settings",
		})
	end,
})

homeTab:CreateButton({
	name = "With Description",
	description = "This button has a description below it.",
	icon = "file-text",
	callback = function()
		window:Toast({
			title = "Button clicked",
			subtitle = "The described button is working.",
			icon = "file-text",
		})
	end,
})

homeTab:CreateSection({
	name = "Toggles",
	icon = "toggle-right",
})

homeTab:CreateToggle({
	name = "Basic Toggle",
	icon = "power",
	value = true,
})

homeTab:CreateToggle({
	name = "Described Toggle",
	icon = "bell",
	description = "This toggle has a description.",
})

homeTab:CreateToggle({
	name = "Flagged Toggle",
	icon = "flag",
	flag = "MyFlag",
	value = false,
})

homeTab:CreateSection({
	name = "Sliders",
	icon = "sliders-horizontal",
})

homeTab:CreateSlider({
	name = "Basic Slider",
	icon = "sliders-horizontal",
	range = { 0, 100 },
	value = 50,
})

homeTab:CreateSlider({
	name = "With Suffix",
	icon = "rotate-3d",
	range = { 0, 360 },
	value = 180,
	increment = 1,
	suffix = "°",
})

homeTab:CreateSlider({
	name = "With Description",
	icon = "gauge",
	description = "This slider has a description.",
	range = { 1, 10 },
	value = 5,
})

homeTab:CreateSection({
	name = "Dropdowns",
	icon = "list-filter",
})

homeTab:CreateDropdown({
	name = "Basic Dropdown",
	icon = "list",
	options = {
		"Option 1",
		"Option 2",
		"Option 3",
	},
	value = "Option 1",
})

homeTab:CreateDropdown({
	name = "Multi Select",
	icon = "list-checks",
	multiSelect = true,
	options = {
		"A",
		"B",
		"C",
		"D",
	},
	value = {
		"A",
		"C",
	},
	placeholder = "Pick items",
})

homeTab:CreateDropdown({
	name = "With Description",
	icon = "list-filter",
	description = "This dropdown has a description.",
	options = {
		"Low",
		"Medium",
		"High",
	},
	value = "Medium",
})

local inputsTab = window:CreateTab({
	name = "Inputs",
	icon = "keyboard",
})

inputsTab:CreateSection({
	name = "Text Inputs",
	icon = "text-cursor-input",
})

inputsTab:CreateInput({
	name = "Basic Input",
	icon = "type",
	placeholder = "Type here",
})

inputsTab:CreateInput({
	name = "Numeric Input",
	icon = "hash",
	numeric = true,
	value = "42",
})

inputsTab:CreateInput({
	name = "With Description",
	icon = "file-pen",
	description = "This input has a description.",
	placeholder = "Enter value",
})

inputsTab:CreateSection({
	name = "Keybinds",
	icon = "keyboard",
})

inputsTab:CreateKeybind({
	name = "Basic Keybind",
	icon = "key",
	value = Enum.KeyCode.F,
})

inputsTab:CreateKeybind({
	name = "Hold Mode",
	icon = "hand",
	hold = true,
	value = Enum.KeyCode.LeftShift,
})

inputsTab:CreateSection({
	name = "Color Pickers",
	icon = "palette",
})

inputsTab:CreateColorPicker({
	name = "Basic Color",
	icon = "paintbrush",
	color = Color3.fromRGB(96, 205, 255),
})

inputsTab:CreateColorPicker({
	name = "With Alpha",
	icon = "blend",
	color = Color3.fromRGB(255, 100, 100),
	alpha = 0.8,
})

local displayTab = window:CreateTab({
	name = "Display",
	icon = "layout-dashboard",
})

displayTab:CreateSection({
	name = "Stats",
	icon = "chart-no-axes-combined",
})

local revenueStat = displayTab:CreateStat({
	name = "Revenue",
	icon = "dollar-sign",
	prefix = "$",
	value = 1250,
})

local usersStat = displayTab:CreateStat({
	name = "Users",
	icon = "users",
	value = 128,
})

local statusStat = displayTab:CreateStat({
	name = "Status",
	icon = "activity",
	value = "Online",
})

window:Toast({
	title = "Astra Loaded",
	subtitle = "The bundled library loaded successfully.",
	icon = "circle-check",
})