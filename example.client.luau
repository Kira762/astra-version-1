-- Astra example
-- Loads the bundled Astra library directly from GitHub.
-- This avoids relying on script.Parent / ReplicatedStorage.

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
	subtitle = "Example UI - Lucide Icons",
	iconPack = "lucide",
	configuration = {
		autoSave = true,
		autoLoad = true,
		fileName = "ExampleConfig",
	},
})

window:CreateSection({
	name = "Main",
})

local homeTab = window:CreateTab({
	name = "Home",
	icon = "house",
})

homeTab:CreateSection({
	name = "Buttons",
})

homeTab:CreateButton({
	name = "Click Me",
	icon = "play",
	callback = function()
		window:Toast({
			title = "Button clicked",
			subtitle = "Click Me is working.",
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
		})
	end,
})

homeTab:CreateButton({
	name = "With Description",
	description = "This button has a description below it.",
	callback = function()
		window:Toast({
			title = "Button clicked",
			subtitle = "The described button is working.",
		})
	end,
})

homeTab:CreateSection({
	name = "Toggles",
})

homeTab:CreateToggle({
	name = "Basic Toggle",
	icon = "toggle-right",
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
})

homeTab:CreateSlider({
	name = "Basic Slider",
	range = { 0, 100 },
	value = 50,
})

homeTab:CreateSlider({
	name = "With Suffix",
	range = { 0, 360 },
	value = 180,
	increment = 1,
	suffix = "°",
})

homeTab:CreateSlider({
	name = "With Description",
	description = "This slider has a description.",
	range = { 1, 10 },
	value = 5,
})

homeTab:CreateSection({
	name = "Dropdowns",
})

homeTab:CreateDropdown({
	name = "Basic Dropdown",
	options = {
		"Option 1",
		"Option 2",
		"Option 3",
	},
	value = "Option 1",
})

homeTab:CreateDropdown({
	name = "Multi Select",
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
})

inputsTab:CreateInput({
	name = "Basic Input",
	placeholder = "Type here",
})

inputsTab:CreateInput({
	name = "Numeric Input",
	numeric = true,
	value = "42",
})

inputsTab:CreateInput({
	name = "With Description",
	description = "This input has a description.",
	placeholder = "Enter value",
})

inputsTab:CreateSection({
	name = "Keybinds",
})

inputsTab:CreateKeybind({
	name = "Basic Keybind",
	value = Enum.KeyCode.F,
})

inputsTab:CreateKeybind({
	name = "Hold Mode",
	hold = true,
	value = Enum.KeyCode.LeftShift,
})

inputsTab:CreateSection({
	name = "Color Pickers",
})

inputsTab:CreateColorPicker({
	name = "Basic Color",
	color = Color3.fromRGB(96, 205, 255),
})

inputsTab:CreateColorPicker({
	name = "With Alpha",
	color = Color3.fromRGB(255, 100, 100),
	alpha = 0.8,
})

local displayTab = window:CreateTab({
	name = "Display",
	icon = "layout-dashboard",
})

displayTab:CreateSection({
	name = "Stats",
})

local revenueStat = displayTab:CreateStat({
	name = "Revenue",
	prefix = "$",
	value = 1250,
})

local usersStat = displayTab:CreateStat({
	name = "Users",
	value = 128,
})

local statusStat = displayTab:CreateStat({
	name = "Status",
	value = "Online",
})

window:Toast({
	title = "Astra Loaded",
	subtitle = "The bundled library loaded successfully.",
})