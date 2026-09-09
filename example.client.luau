-- Astra v1
-- Comprehensive 20-tab usage / stress-test example.
-- Every callback is intentionally lightweight and mostly placeholder-based.
-- This file is designed to exercise the public Astra API without creating
-- another UI system.

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
	subtitle = "20-Tab Comprehensive Usage",
	icon = "sparkles",
	iconPack = "lucide",

	configuration = {
		autoSave = true,
		autoLoad = true,
		fileName = "Astra20TabExample",
	},
})

window:CreateSection({
	name = "Main",
	icon = "layout-dashboard",
})

----------------------------------------------------------------
-- 1. HOME
----------------------------------------------------------------

local homeTab = window:CreateTab({
	name = "Home",
	icon = "house",
})

homeTab:CreateSection({
	name = "Overview",
	icon = "layout-dashboard",
})

homeTab:CreateText({
	name = "Welcome",
	text = "Astra comprehensive 20-tab API and UI stress test.",
	icon = "info",
})

homeTab:CreateButton({
	name = "Test Button",
	icon = "play",
	callback = function()
		print("[Astra Test] Home button pressed")
	end,
})

homeTab:CreateToggle({
	name = "Example Toggle",
	icon = "toggle-right",
	flag = "homeExampleToggle",
	value = true,
	callback = function(value)
		print("[Astra Test] Home toggle:", value)
	end,
})

homeTab:CreateDivider({
	text = "Quick Settings",
})

homeTab:CreateDropdown({
	name = "Example Mode",
	icon = "list",
	options = {
		"Default",
		"Performance",
		"Visual",
	},
	value = "Default",
	flag = "homeMode",
	callback = function(value)
		print("[Astra Test] Home mode:", value)
	end,
})

----------------------------------------------------------------
-- 2. BUTTONS
----------------------------------------------------------------

local buttonsTab = window:CreateTab({
	name = "Buttons",
	icon = "mouse-pointer-click",
})

buttonsTab:CreateSection({
	name = "Button Variants",
	icon = "mouse-pointer-click",
})

buttonsTab:CreateButton({
	name = "Basic Button",
	icon = "play",
	callback = function()
		print("[Astra Test] Basic button")
	end,
})

buttonsTab:CreateButton({
	name = "Icon Button",
	icon = "settings",
	callback = function()
		print("[Astra Test] Icon button")
	end,
})

buttonsTab:CreateButton({
	name = "Described Button",
	icon = "file-text",
	description = "Button with helper text for testing layout spacing.",
	callback = function()
		print("[Astra Test] Described button")
	end,
})

buttonsTab:CreateButton({
	name = "Another Button",
	icon = "refresh-cw",
	callback = function()
		print("[Astra Test] Refresh button")
	end,
})

----------------------------------------------------------------
-- 3. TOGGLES
----------------------------------------------------------------

local togglesTab = window:CreateTab({
	name = "Toggles",
	icon = "toggle-right",
})

togglesTab:CreateSection({
	name = "Toggle Controls",
	icon = "toggle-right",
})

togglesTab:CreateToggle({
	name = "Basic Toggle",
	icon = "power",
	flag = "toggleBasic",
	value = true,
	callback = function(value)
		print("[Astra Test] Basic toggle:", value)
	end,
})

togglesTab:CreateToggle({
	name = "Disabled State Test",
	icon = "shield-check",
	flag = "toggleSecond",
	value = false,
	callback = function(value)
		print("[Astra Test] Second toggle:", value)
	end,
})

togglesTab:CreateToggle({
	name = "Described Toggle",
	icon = "bell",
	description = "Used to test longer element descriptions.",
	flag = "toggleDescribed",
	value = true,
	callback = function(value)
		print("[Astra Test] Described toggle:", value)
	end,
})

togglesTab:CreateToggle({
	name = "Extra Toggle",
	icon = "zap",
	flag = "toggleExtra",
	value = false,
	callback = function(value)
		print("[Astra Test] Extra toggle:", value)
	end,
})

----------------------------------------------------------------
-- 4. SLIDERS
----------------------------------------------------------------

local slidersTab = window:CreateTab({
	name = "Sliders",
	icon = "sliders-horizontal",
})

slidersTab:CreateSection({
	name = "Numeric Sliders",
	icon = "sliders-horizontal",
})

slidersTab:CreateSlider({
	name = "Percentage",
	icon = "percent",
	flag = "sliderPercentage",
	range = { 0, 100 },
	value = 50,
	increment = 1,
	suffix = "%",
	callback = function(value)
		print("[Astra Test] Percentage:", value)
	end,
})

slidersTab:CreateSlider({
	name = "Volume",
	icon = "volume-2",
	flag = "sliderVolume",
	range = { 0, 100 },
	value = 75,
	increment = 5,
	suffix = "%",
})

slidersTab:CreateSlider({
	name = "Distance",
	icon = "ruler",
	flag = "sliderDistance",
	range = { 1, 500 },
	value = 100,
	increment = 1,
	suffix = " studs",
})

slidersTab:CreateSlider({
	name = "Minimal Slider",
	icon = "gauge",
	flag = "sliderMinimal",
	range = { 1, 10 },
	value = 5,
	minimal = true,
})

----------------------------------------------------------------
-- 5. DROPDOWNS
----------------------------------------------------------------

local dropdownsTab = window:CreateTab({
	name = "Dropdowns",
	icon = "list-filter",
})

dropdownsTab:CreateSection({
	name = "Single Select",
	icon = "list",
})

local basicDropdown = dropdownsTab:CreateDropdown({
	name = "Basic Dropdown",
	icon = "list",
	flag = "dropdownBasic",
	options = {
		"Option A",
		"Option B",
		"Option C",
		"Option D",
	},
	value = "Option A",
	callback = function(value)
		print("[Astra Test] Basic dropdown:", value)
	end,
})

dropdownsTab:CreateDropdown({
	name = "Difficulty",
	icon = "gauge",
	flag = "dropdownDifficulty",
	options = {
		"Easy",
		"Normal",
		"Hard",
		"Extreme",
	},
	value = "Normal",
})

dropdownsTab:CreateSection({
	name = "Multi Select",
	icon = "list-checks",
})

dropdownsTab:CreateDropdown({
	name = "Multiple Options",
	icon = "list-checks",
	flag = "dropdownMulti",
	multiSelect = true,
	options = {
		"Alpha",
		"Beta",
		"Gamma",
		"Delta",
	},
	value = {
		"Alpha",
		"Gamma",
	},
	placeholder = "Pick items",
})

buttonsTab:CreateDivider()

----------------------------------------------------------------
-- 6. INPUTS
----------------------------------------------------------------

local inputsTab = window:CreateTab({
	name = "Inputs",
	icon = "keyboard",
})

inputsTab:CreateSection({
	name = "Text Inputs",
	icon = "text-cursor-input",
})

inputsTab:CreateInput({
	name = "Name Input",
	icon = "type",
	flag = "inputName",
	placeholder = "Enter a name",
	callback = function(value)
		print("[Astra Test] Name:", value)
	end,
})

inputsTab:CreateInput({
	name = "Numeric Input",
	icon = "hash",
	flag = "inputNumber",
	numeric = true,
	value = "42",
	callback = function(value)
		print("[Astra Test] Number:", value)
	end,
})

inputsTab:CreateInput({
	name = "Described Input",
	icon = "file-pen",
	flag = "inputDescription",
	description = "Longer description layout test.",
	placeholder = "Type something...",
})

inputsTab:CreateInput({
	name = "Clear On Focus",
	icon = "eraser",
	flag = "inputClear",
	clearOnFocus = true,
	placeholder = "Focus me",
})

----------------------------------------------------------------
-- 7. KEYBINDS
----------------------------------------------------------------

local keybindsTab = window:CreateTab({
	name = "Keybinds",
	icon = "keyboard",
})

keybindsTab:CreateSection({
	name = "Keybind Tests",
	icon = "key",
})

keybindsTab:CreateKeybind({
	name = "Basic Keybind",
	icon = "key",
	flag = "keybindBasic",
	value = Enum.KeyCode.F,
	callback = function(value)
		print("[Astra Test] Basic keybind:", value)
	end,
})

keybindsTab:CreateKeybind({
	name = "Hold Keybind",
	icon = "hand",
	flag = "keybindHold",
	hold = true,
	value = Enum.KeyCode.LeftShift,
	callback = function(value)
		print("[Astra Test] Hold keybind:", value)
	end,
})

keybindsTab:CreateKeybind({
	name = "Menu Keybind",
	icon = "menu",
	flag = "keybindMenu",
	value = Enum.KeyCode.RightShift,
	isMenuToggle = true,
})

keybindsTab:CreateKeybind({
	name = "Threshold Test",
	icon = "timer",
	flag = "keybindThreshold",
	hold = true,
	holdThreshold = 0.2,
	value = Enum.KeyCode.LeftControl,
})

----------------------------------------------------------------
-- 8. COLORS
----------------------------------------------------------------

local colorsTab = window:CreateTab({
	name = "Colors",
	icon = "palette",
})

colorsTab:CreateSection({
	name = "Color Pickers",
	icon = "palette",
})

colorsTab:CreateColorPicker({
	name = "Primary Color",
	icon = "paintbrush",
	flag = "colorPrimary",
	color = Color3.fromRGB(96, 205, 255),
})

colorsTab:CreateColorPicker({
	name = "Secondary Color",
	icon = "paintbrush-vertical",
	flag = "colorSecondary",
	color = Color3.fromRGB(180, 100, 255),
	alpha = 1,
})

colorsTab:CreateColorPicker({
	name = "Transparent Color",
	icon = "blend",
	flag = "colorTransparent",
	color = Color3.fromRGB(255, 100, 100),
	alpha = 0.5,
})

colorsTab:CreateColorPicker({
	name = "Green Color",
	icon = "droplets",
	flag = "colorGreen",
	color = Color3.fromRGB(100, 220, 130),
	alpha = 0.8,
})

----------------------------------------------------------------
-- 9. STATS
----------------------------------------------------------------

local statsTab = window:CreateTab({
	name = "Stats",
	icon = "chart-no-axes-combined",
})

statsTab:CreateSection({
	name = "Statistics",
	icon = "chart-column",
})

local statUsers = statsTab:CreateStat({
	name = "Users",
	icon = "users",
	value = 128,
})

local statRevenue = statsTab:CreateStat({
	name = "Revenue",
	icon = "dollar-sign",
	prefix = "$",
	value = 1250,
})

local statStatus = statsTab:CreateStat({
	name = "Status",
	icon = "activity",
	value = "Online",
})

local statScore = statsTab:CreateStat({
	name = "Score",
	icon = "trophy",
	value = 9842,
	suffix = " pts",
})

statUsers:Set(256)
statRevenue:ResetBaseline(1000)
statScore:Set(10000)

----------------------------------------------------------------
-- 10. MIXED
----------------------------------------------------------------

local mixedTab = window:CreateTab({
	name = "Mixed",
	icon = "layers-3",
})

mixedTab:CreateSection({
	name = "Mixed Controls",
	icon = "layers-3",
})

mixedTab:CreateText({
	name = "Mixed Header",
	text = "Several different element types in one tab.",
	icon = "info",
})

mixedTab:CreateToggle({
	name = "Mixed Toggle",
	icon = "power",
	flag = "mixedToggle",
	value = true,
})

mixedTab:CreateSlider({
	name = "Mixed Slider",
	icon = "sliders-horizontal",
	flag = "mixedSlider",
	range = { 0, 100 },
	value = 35,
	suffix = "%",
})

mixedTab:CreateDropdown({
	name = "Mixed Dropdown",
	icon = "list",
	flag = "mixedDropdown",
	options = {
		"Low",
		"Medium",
		"High",
	},
	value = "Medium",
})

mixedTab:CreateInput({
	name = "Mixed Input",
	icon = "type",
	flag = "mixedInput",
	placeholder = "Mixed input",
})

mixedTab:CreateButton({
	name = "Mixed Action",
	icon = "play",
	callback = function()
		print("[Astra Test] Mixed action")
	end,
})

----------------------------------------------------------------
-- 11. DESCRIPTIONS
----------------------------------------------------------------

local descriptionsTab = window:CreateTab({
	name = "Descriptions",
	icon = "file-text",
})

descriptionsTab:CreateSection({
	name = "Description Layout Tests",
	icon = "file-text",
})

descriptionsTab:CreateText({
	name = "Long Text",
	icon = "align-left",
	text = "This is a longer body of text intended to test wrapping, spacing, alignment, and vertical sizing inside the current layout.",
})

descriptionsTab:CreateButton({
	name = "Described Button",
	icon = "mouse-pointer-click",
	description = "This description is intentionally long enough to exercise the element's text layout.",
	callback = function()
		print("[Astra Test] Description button")
	end,
})

descriptionsTab:CreateToggle({
	name = "Described Toggle",
	icon = "toggle-right",
	description = "This toggle has a longer description to test how controls behave with additional text.",
	flag = "descriptionToggle",
})

descriptionsTab:CreateSlider({
	name = "Described Slider",
	icon = "gauge",
	description = "Slider description layout test.",
	flag = "descriptionSlider",
	range = { 1, 10 },
	value = 5,
})

descriptionsTab:CreateDropdown({
	name = "Described Dropdown",
	icon = "list-filter",
	description = "Dropdown description layout test.",
	flag = "descriptionDropdown",
	options = {
		"One",
		"Two",
		"Three",
	},
	value = "One",
})

----------------------------------------------------------------
-- 12. FLAGS
----------------------------------------------------------------

local flagsTab = window:CreateTab({
	name = "Flags",
	icon = "flag",
})

flagsTab:CreateSection({
	name = "Persistence / Flags",
	icon = "save",
})

flagsTab:CreateToggle({
	name = "Flag Toggle",
	icon = "toggle-right",
	flag = "flagToggle",
	value = true,
})

flagsTab:CreateSlider({
	name = "Flag Slider",
	icon = "sliders-horizontal",
	flag = "flagSlider",
	range = { 0, 100 },
	value = 25,
})

flagsTab:CreateDropdown({
	name = "Flag Dropdown",
	icon = "list",
	flag = "flagDropdown",
	options = {
		"Alpha",
		"Beta",
		"Gamma",
	},
	value = "Beta",
})

flagsTab:CreateInput({
	name = "Flag Input",
	icon = "type",
	flag = "flagInput",
	placeholder = "Saved input",
})

flagsTab:CreateText({
	name = "Flag Readback",
	icon = "database",
	text = "Use window:Get(flag) / window:Set(flag, value) to test flag state.",
})

----------------------------------------------------------------
-- 13. FORMS
----------------------------------------------------------------

local formsTab = window:CreateTab({
	name = "Forms",
	icon = "list-checks",
})

formsTab:CreateSection({
	name = "Form Controls",
	icon = "list-checks",
})

formsTab:CreateInput({
	name = "Username",
	icon = "user",
	flag = "formUsername",
	placeholder = "Username",
})

formsTab:CreateInput({
	name = "Age",
	icon = "hash",
	flag = "formAge",
	numeric = true,
	placeholder = "Number",
})

formsTab:CreateDropdown({
	name = "Category",
	icon = "folder",
	flag = "formCategory",
	options = {
		"General",
		"Testing",
		"Development",
	},
	value = "General",
})

formsTab:CreateToggle({
	name = "Enable Form",
	icon = "check",
	flag = "formEnabled",
	value = true,
})

formsTab:CreateButton({
	name = "Submit Placeholder",
	icon = "send",
	callback = function()
		print("[Astra Test] Form submitted")
	end,
})

----------------------------------------------------------------
-- 14. DISPLAY
----------------------------------------------------------------

local displayTab = window:CreateTab({
	name = "Display",
	icon = "layout-dashboard",
})

displayTab:CreateSection({
	name = "Display Elements",
	icon = "monitor",
})

displayTab:CreateText({
	name = "Display Text",
	icon = "info",
	text = "Display-oriented elements below are intended for visual testing.",
})

local progress = displayTab:CreateProgress({
	name = "Progress",
	icon = "loader",
	range = { 0, 100 },
	value = 35,
})

progress:SetText("Testing...")
progress:Set(65)

displayTab:CreateStat({
	name = "FPS",
	icon = "gauge",
	value = 60,
	suffix = " FPS",
})

displayTab:CreateStat({
	name = "Ping",
	icon = "wifi",
	value = 42,
	suffix = " ms",
})

displayTab:CreateDivider()

----------------------------------------------------------------
-- 15. CONTROLS
----------------------------------------------------------------

local controlsTab = window:CreateTab({
	name = "Controls",
	icon = "gamepad-2",
})

controlsTab:CreateSection({
	name = "Gameplay Controls",
	icon = "gamepad-2",
})

controlsTab:CreateToggle({
	name = "Auto Run",
	icon = "person-standing",
	flag = "controlAutoRun",
})

controlsTab:CreateToggle({
	name = "Auto Jump",
	icon = "move-up",
	flag = "controlAutoJump",
})

controlsTab:CreateSlider({
	name = "Walk Speed",
	icon = "gauge",
	flag = "controlWalkSpeed",
	range = { 1, 100 },
	value = 16,
	increment = 1,
})

controlsTab:CreateSlider({
	name = "Jump Power",
	icon = "arrow-up",
	flag = "controlJumpPower",
	range = { 1, 150 },
	value = 50,
	increment = 1,
})

controlsTab:CreateDropdown({
	name = "Movement Mode",
	icon = "navigation",
	flag = "controlMovementMode",
	options = {
		"Normal",
		"Fast",
		"Precision",
	},
	value = "Normal",
})

----------------------------------------------------------------
-- 16. ADVANCED
----------------------------------------------------------------

local advancedTab = window:CreateTab({
	name = "Advanced",
	icon = "settings-2",
})

advancedTab:CreateSection({
	name = "Advanced API Tests",
	icon = "settings-2",
})

advancedTab:CreateButton({
	name = "Change Theme Example",
	icon = "palette",
	callback = function()
		print("[Astra Test] Theme button pressed")
	end,
})

advancedTab:CreateButton({
	name = "Save Configuration",
	icon = "save",
	callback = function()
		print("[Astra Test] Save placeholder")
		window:Save()
	end,
})

advancedTab:CreateButton({
	name = "Load Configuration",
	icon = "folder-open",
	callback = function()
		print("[Astra Test] Load placeholder")
		window:Load()
	end,
})

advancedTab:CreateButton({
	name = "List Configurations",
	icon = "files",
	callback = function()
		local configs = window:ListConfigs()

		for _, configName in ipairs(configs) do
			print("[Astra Test] Config:", configName)
		end
	end,
})

advancedTab:CreateText({
	name = "Advanced Info",
	icon = "info",
	text = "This tab exercises public window-level functions without replacing Astra internals.",
})

----------------------------------------------------------------
-- 17. STRESS TEST
----------------------------------------------------------------

local stressTab = window:CreateTab({
	name = "Stress Test",
	icon = "gauge",
})

stressTab:CreateSection({
	name = "Moderate Element Load",
	icon = "gauge",
})

for index = 1, 8 do
	stressTab:CreateToggle({
		name = "Stress Toggle " .. index,
		icon = "toggle-right",
		flag = "stressToggle" .. index,
		value = index % 2 == 0,
	})
end

for index = 1, 5 do
	stressTab:CreateSlider({
		name = "Stress Slider " .. index,
		icon = "sliders-horizontal",
		flag = "stressSlider" .. index,
		range = { 0, 100 },
		value = index * 10,
		increment = 1,
		suffix = "%",
	})
end

stressTab:CreateSection({
	name = "Stress Dropdowns",
	icon = "list-filter",
})

for index = 1, 3 do
	stressTab:CreateDropdown({
		name = "Stress Dropdown " .. index,
		icon = "list",
		flag = "stressDropdown" .. index,
		options = {
			"Option 1",
			"Option 2",
			"Option 3",
			"Option 4",
		},
		value = "Option 1",
	})
end

----------------------------------------------------------------
-- 18. LAYOUT TEST
----------------------------------------------------------------

local layoutTab = window:CreateTab({
	name = "Layout Test",
	icon = "panels-top-left",
})

layoutTab:CreateSection({
	name = "Layout Composition",
	icon = "panels-top-left",
})

layoutTab:CreateText({
	name = "Layout Description",
	icon = "info",
	text = "Use this tab while testing Sidebar, Topbar, and other built-in layouts.",
})

layoutTab:CreateButton({
	name = "Layout Button",
	icon = "layout-template",
	callback = function()
		print("[Astra Test] Layout button")
	end,
})

local layoutGroup = layoutTab:CreateGroup()

layoutGroup:CreateToggle({
	name = "Group Toggle",
	flag = "layoutGroupToggle",
})

layoutGroup:CreateButton({
	name = "Group Button",
	icon = "play",
	callback = function()
		print("[Astra Test] Group button")
	end,
})

local layoutColumn = layoutGroup:CreateGroup({
	direction = "column",
})

layoutColumn:CreateSlider({
	name = "Grouped Slider",
	flag = "layoutGroupedSlider",
	range = { 0, 100 },
	value = 50,
})

layoutColumn:CreateDropdown({
	name = "Grouped Dropdown",
	flag = "layoutGroupedDropdown",
	options = {
		"Left",
		"Center",
		"Right",
	},
	value = "Center",
})

----------------------------------------------------------------
-- 19. SETTINGS TEST
----------------------------------------------------------------

local settingsTestTab = window:CreateTab({
	name = "Settings Test",
	icon = "settings",
})

settingsTestTab:CreateSection({
	name = "Built-in Settings Test",
	icon = "settings",
})

settingsTestTab:CreateText({
	name = "Purpose",
	icon = "info",
	text = "Use this normal tab to verify that entering Astra Settings and returning here restores the correct selected tab.",
})

settingsTestTab:CreateToggle({
	name = "Settings Test Toggle",
	icon = "toggle-right",
	flag = "settingsTestToggle",
	value = true,
})

settingsTestTab:CreateSlider({
	name = "Settings Test Slider",
	icon = "sliders-horizontal",
	flag = "settingsTestSlider",
	range = { 0, 100 },
	value = 50,
})

settingsTestTab:CreateDropdown({
	name = "Settings Test Dropdown",
	icon = "list",
	flag = "settingsTestDropdown",
	options = {
		"First",
		"Second",
		"Third",
	},
	value = "First",
})

settingsTestTab:CreateButton({
	name = "Settings Placeholder",
	icon = "settings",
	callback = function()
		print("[Astra Test] Settings test button")
	end,
})

----------------------------------------------------------------
-- 20. ABOUT
----------------------------------------------------------------

local aboutTab = window:CreateTab({
	name = "About",
	icon = "circle-help",
})

aboutTab:CreateSection({
	name = "Astra",
	icon = "sparkles",
})

aboutTab:CreateText({
	name = "Usage Example",
	icon = "book-open",
	text = "This example intentionally contains 20 normal tabs and a wide range of Astra elements for regression, layout, state, and persistence testing.",
})

aboutTab:CreateText({
	name = "Element Coverage",
	icon = "blocks",
	text = "Buttons, Toggles, Sliders, Dropdowns, Inputs, Keybinds, ColorPickers, Stats, Progress, Console, Text, Dividers, Groups, and Sections.",
})

aboutTab:CreateButton({
	name = "Print Current Flags",
	icon = "terminal",
	callback = function()
		for flag, value in pairs(window.Flags) do
			print("[Astra Flag]", flag, value)
		end
	end,
})

aboutTab:CreateButton({
	name = "Print Persistence Path",
	icon = "folder",
	callback = function()
		local folder, file = window:GetPath()
		print("[Astra Test] Config path:", folder, file)
	end,
})

----------------------------------------------------------------
-- END
----------------------------------------------------------------

print("[Astra Test] 20-tab example loaded successfully.")
print("[Astra Test] Tabs:", 20)