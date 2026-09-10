-- Astra supported-usage example.
-- This example intentionally uses only the documented public API and avoids
-- optional icon, custom-theme, and advanced persistence paths.

local Astra = loadstring(
	game:HttpGet(
		"https://raw.githubusercontent.com/Kira762/astra-version-1/61136e9/version-1.luau"
	)
)()

assert(
	type(Astra) == "table" and type(Astra.CreateWindow) == "function",
	"[Astra] Failed to load Astra bundle."
)

local window = Astra:CreateWindow({
	name = "Astra Example",
	subtitle = "Supported API example",
})

window:CreateSection({
	name = "Overview",
})

local home = window:CreateTab({
	name = "Home",
})

home:CreateSection({
	name = "Basic controls",
})

home:CreateText({
	name = "Welcome",
	text = "This window uses only Astra's supported public API.",
})

home:CreateButton({
	name = "Button",
	callback = function()
		print("Astra button pressed")
	end,
})

home:CreateToggle({
	name = "Enable feature",
	value = true,
	callback = function(value)
		print("Feature enabled:", value)
	end,
})

home:CreateSlider({
	name = "Volume",
	range = { 0, 100 },
	value = 50,
	increment = 1,
	callback = function(value)
		print("Volume:", value)
	end,
})

home:CreateDropdown({
	name = "Mode",
	options = { "Default", "Performance", "Visual" },
	value = "Default",
	callback = function(value)
		print("Mode:", value)
	end,
})

home:CreateInput({
	name = "Name",
	placeholder = "Enter a name",
	callback = function(value)
		print("Name:", value)
	end,
})

home:CreateColorPicker({
	name = "Accent color",
	color = Color3.fromRGB(96, 205, 255),
	callback = function(value)
		print("Accent color changed:", value)
	end,
})

home:CreateDivider()

print("[Astra] Supported usage example loaded successfully.")
