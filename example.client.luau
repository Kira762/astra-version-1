-- Astra example — loads version-1.luau from the same repo, no external HTTP links.
-- Works like any other file connection: tries DataModel require first (Studio/Rojo),
-- then local filesystem readfile+loadstring (executor), no HttpGet at all.

local Astra: any = nil
do
	-- 1) Studio / Rojo: Astra lives in ReplicatedStorage as ModuleScript (library_entrypoint)
	local ok, mod = pcall(function()
		return game:GetService("ReplicatedStorage"):FindFirstChild("Astra")
	end)
	if ok and mod and mod:IsA("ModuleScript") then
		local ok2, result = pcall(require, mod)
		if ok2 and type(result) == "table" then
			Astra = result
		end
	end

	-- 2) Sibling ModuleScript: version-1 placed next to this LocalScript
	if not Astra then
		local sibling = script.Parent:FindFirstChild("version-1")
			or script.Parent:FindFirstChild("version_1")
			or script:FindFirstChild("version-1")
		if sibling and sibling:IsA("ModuleScript") then
			local ok2, result = pcall(require, sibling)
			if ok2 and type(result) == "table" then
				Astra = result
			else
				-- Wax bundle is a loadstring bundle, not a normal ModuleScript.
				-- Fall through to readfile+loadstring path.
			end
		end
	end

	-- 3) Filesystem: read version-1.luau from same folder and loadstring it (exploit / plain Lua)
	if not Astra then
		local source: string? = nil

		-- Executor readfile/isfile
		if typeof(readfile) == "function" and typeof(isfile) == "function" then
			for _, path in { "version-1.luau", "./version-1.luau", "astra-version-1/version-1.luau" } do
				local ok2, exists = pcall(isfile, path)
				if ok2 and exists then
					local ok3, content = pcall(readfile, path)
					if ok3 and type(content) == "string" and #content > 0 then
						source = content
						break
					end
				end
			end
		end

		-- Plain Lua io fallback (for testing outside Roblox)
		if not source and typeof(io) == "table" and io.open then
			for _, path in { "version-1.luau", "./version-1.luau" } do
				local file = (pcall(io.open, path, "r") and io.open(path, "r")) :: any
				if file then
					local ok2, content = pcall(function()
						return (file :: any):read("*a")
					end)
					pcall(function()
						(file :: any):close()
					end)
					if ok2 and type(content) == "string" and #content > 0 then
						source = content
						break
					end
				end
			end
		end

		assert(source, "[Astra] Could not find version-1.luau locally. Place version-1.luau next to example.client.luau or put the Astra ModuleScript in ReplicatedStorage.")

		local loadFn, loadErr = loadstring(source :: string)
		assert(type(loadFn) == "function", "Astra bundle failed to compile: " .. tostring(loadErr))
		local ok2, result = pcall(loadFn :: any)
		assert(ok2, "Astra bundle failed to run: " .. tostring(result))
		Astra = result
	end
end

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

local homeTab = window:CreateTab({ name = "Home", icon = "house" })

homeTab:CreateSection({ name = "Buttons" })

homeTab:CreateButton({
	name = "Click Me",
	icon = "play",
	callback = function()
		window:Toast({ title = "Button clicked", subtitle = "Click Me is working." })
	end,
})

homeTab:CreateButton({
	name = "With Icon",
	icon = "settings",
	callback = function()
		window:Toast({ title = "Button clicked", subtitle = "The icon button is working." })
	end,
})

homeTab:CreateButton({
	name = "With Description",
	description = "This button has a description below it.",
	callback = function()
		window:Toast({ title = "Button clicked", subtitle = "The described button is working." })
	end,
})

homeTab:CreateSection({ name = "Toggles" })

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

homeTab:CreateSection({ name = "Sliders" })

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

homeTab:CreateSection({ name = "Dropdowns" })

homeTab:CreateDropdown({
	name = "Basic Dropdown",
	options = { "Option 1", "Option 2", "Option 3" },
	value = "Option 1",
})

homeTab:CreateDropdown({
	name = "Multi Select",
	multiSelect = true,
	options = { "A", "B", "C", "D" },
	value = { "A", "C" },
	placeholder = "Pick items",
})

homeTab:CreateDropdown({
	name = "With Description",
	description = "This dropdown has a description.",
	options = { "Low", "Medium", "High" },
	value = "Medium",
})

local inputsTab = window:CreateTab({ name = "Inputs", icon = "keyboard" })

inputsTab:CreateSection({ name = "Text Inputs" })

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

inputsTab:CreateSection({ name = "Keybinds" })

inputsTab:CreateKeybind({
	name = "Basic Keybind",
	value = Enum.KeyCode.F,
})

inputsTab:CreateKeybind({
	name = "Hold Mode",
	hold = true,
	value = Enum.KeyCode.LeftShift,
})

inputsTab:CreateSection({ name = "Color Pickers" })

inputsTab:CreateColorPicker({
	name = "Basic Color",
	color = Color3.fromRGB(96, 205, 255),
})

inputsTab:CreateColorPicker({
	name = "With Alpha",
	color = Color3.fromRGB(255, 100, 100),
	alpha = 0.8,
})

local displayTab = window:CreateTab({ name = "Display", icon = "layout-dashboard" })

displayTab:CreateSection({ name = "Stats" })

local revenueStat = displayTab:CreateStat({
	name = "Revenue",
	prefix = "$",
	value = 12400,
})

local killsStat = displayTab:CreateStat({
	name = "Kills",
	value = 128,
})

displayTab:CreateButton({
	name = "Update Stats",
	callback = function()
		revenueStat:Set(revenueStat.value + math.random(500, 3000))
		killsStat:Set(killsStat.value + math.random(1, 20))
	end,
})

displayTab:CreateSection({ name = "Progress" })

displayTab:CreateProgress({
	name = "Download",
	range = { 0, 100 },
	value = 35,
})

displayTab:CreateProgress({
	name = "Steps",
	steps = 5,
	value = 2,
})

displayTab:CreateProgress({
	name = "Loading",
	indeterminate = true,
})

displayTab:CreateSection({ name = "Text" })

displayTab:CreateText({
	name = "Title",
	text = "This is a text element with a title and body.",
})

displayTab:CreateText({
	text = "This is body text only.",
})

displayTab:CreateText({
	name = "With Icon",
	text = "This text has an icon.",
	icon = "house",
})

displayTab:CreateSection({ name = "Dividers" })

displayTab:CreateDivider()

displayTab:CreateDivider({ text = "or" })

displayTab:CreateDivider({ text = "spaced", spacing = 24 })

displayTab:CreateDivider({ line = false, spacing = 20 })

displayTab:CreateSection({ name = "Console" })

local displayConsole = displayTab:CreateConsole({
	name = "Console",
	text = "-- output lands here",
	height = 130,
	follow = true,
	maxLines = 50,
})

displayTab:CreateButton({
	name = "Log Line",
	callback = function()
		displayConsole:Append(string.format("[%s] New entry", os.date("%H:%M:%S")))
	end,
})

displayTab:CreateButton({
	name = "Clear Console",
	callback = function()
		displayConsole:Clear()
	end,
})

displayTab:CreateSection({ name = "Groups" })

local groupRow = displayTab:CreateGroup()

local leftColumn = groupRow:CreateGroup({ direction = "column" })
leftColumn:CreateToggle({ name = "Left Toggle 1", value = true })
leftColumn:CreateToggle({ name = "Left Toggle 2" })

local rightColumn = groupRow:CreateGroup({ direction = "column" })
rightColumn:CreateToggle({ name = "Right Toggle 1", value = true })
rightColumn:CreateToggle({ name = "Right Toggle 2" })

local utilityTab = window:CreateTab({ name = "Utility", icon = "search" })

utilityTab:CreateSection({ name = "Notifications" })

utilityTab:CreateButton({
	name = "Send Notification",
	callback = function()
		window:Notify({
			title = "Hello",
			content = "This is a notification.",
			icon = "settings",
		})
	end,
})

utilityTab:CreateButton({
	name = "Send Toast",
	callback = function()
		window:Toast({
			title = "Saved",
			icon = "settings",
		})
	end,
})

utilityTab:CreateButton({
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

utilityTab:CreateSection({ name = "Tags" })

window:CreateTag({
	text = "v1.0.0",
	title = "Version",
	color = Color3.fromRGB(96, 205, 255),
})

utilityTab:CreateSection({ name = "Window Controls" })

utilityTab:CreateButton({
	name = "Hide Window",
	callback = function()
		window:Hide()
	end,
})

utilityTab:CreateButton({
	name = "Save Config",
	callback = function()
		window:Save()
	end,
})

utilityTab:CreateButton({
	name = "Load Config",
	callback = function()
		window:Load()
	end,
})

utilityTab:CreateButton({
	name = "List Configs",
	callback = function()
		local configs = window:ListConfigs()
		for _, configName in configs do
		end
	end,
})

local advancedTab = window:CreateTab({ name = "Advanced", icon = "sliders-horizontal" })

advancedTab:CreateSection({ name = "Runtime Controls" })

advancedTab:CreateToggle({
	name = "Performance Mode",
	icon = "gauge",
	description = "Prefer lower visual overhead while keeping the interface responsive.",
	value = false,
})

advancedTab:CreateToggle({
	name = "Auto Refresh",
	icon = "refresh-cw",
	description = "Refresh placeholder data automatically every few seconds.",
	value = true,
})

advancedTab:CreateDropdown({
	name = "Refresh Interval",
	icon = "timer",
	options = { "5 seconds", "15 seconds", "30 seconds", "1 minute" },
	value = "15 seconds",
})

advancedTab:CreateSlider({
	name = "Update Frequency",
	icon = "activity",
	description = "Adjust how often the example would poll for new data.",
	range = { 1, 60 },
	value = 15,
	increment = 1,
	suffix = " sec",
})

advancedTab:CreateSection({ name = "Developer Tools" })

advancedTab:CreateInput({
	name = "Workspace Name",
	icon = "folder-open",
	description = "A placeholder input for a project or workspace identifier.",
	placeholder = "example-workspace",
})

advancedTab:CreateKeybind({
	name = "Toggle Developer Panel",
	icon = "terminal",
	value = Enum.KeyCode.F3,
})

advancedTab:CreateColorPicker({
	name = "Accent Preview",
	icon = "palette",
	color = Color3.fromRGB(96, 205, 255),
	alpha = 0.9,
})

advancedTab:CreateSection({ name = "Execution" })

local taskProgress = advancedTab:CreateProgress({
	name = "Task Progress",
	icon = "loader-circle",
	range = { 0, 100 },
	value = 68,
})

advancedTab:CreateButton({
	name = "Run Placeholder Task",
	icon = "circle-play",
	description = "Simulates a task and advances the progress indicator.",
	callback = function()
		taskProgress:Set(math.min(100, taskProgress.value + 8))
	end,
})

advancedTab:CreateButton({
	name = "Reset Task",
	icon = "rotate-ccw",
	callback = function()
		taskProgress:Set(0)
	end,
})

local activityTab = window:CreateTab({ name = "Activity", icon = "activity" })

activityTab:CreateSection({ name = "Recent Activity" })

activityTab:CreateText({
	name = "Today",
	icon = "calendar-days",
	text = "Your placeholder activity feed can show events, status changes, and recent actions here.",
})

local eventConsole = activityTab:CreateConsole({
	name = "Event Stream",
	icon = "radio-tower",
	text = "[system] Waiting for activity...",
	height = 150,
	follow = true,
	maxLines = 80,
})

activityTab:CreateButton({
	name = "Add Activity Event",
	icon = "circle-plus",
	callback = function()
		eventConsole:Append(string.format("[%s] Placeholder event received", os.date("%H:%M:%S")))
	end,
})

activityTab:CreateButton({
	name = "Clear Activity",
	icon = "trash-2",
	callback = function()
		eventConsole:Clear()
	end,
})

activityTab:CreateSection({ name = "Filters" })

activityTab:CreateToggle({
	name = "Show System Events",
	icon = "server",
	value = true,
})

activityTab:CreateToggle({
	name = "Show User Events",
	icon = "user-round",
	value = true,
})

activityTab:CreateDropdown({
	name = "Activity Range",
	icon = "calendar-range",
	options = { "Today", "This week", "This month", "All time" },
	value = "Today",
})

local aboutTab = window:CreateTab({ name = "About", icon = "info" })

aboutTab:CreateSection({ name = "Astra Example" })

aboutTab:CreateText({
	name = "Component Showcase",
	icon = "sparkles",
	text = "A detailed placeholder window demonstrating tabs, actions, forms, progress, statistics, notifications, groups, tags, and console output with the Lucide icon pack.",
})

aboutTab:CreateDivider({ text = "Resources" })

aboutTab:CreateButton({
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

aboutTab:CreateButton({
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

aboutTab:CreateSection({ name = "Environment" })

local aboutGroup = aboutTab:CreateGroup({ direction = "column" })

aboutGroup:CreateStat({
	name = "Version",
	value = 100,
	prefix = "v",
	suffix = ".0.0",
	icon = "tag",
})
aboutGroup:CreateText({
	name = "Icon Pack",
	text = "Lucide",
	icon = "library",
})
aboutGroup:CreateStat({
	name = "Status",
	value = 1,
	suffix = " ready",
	icon = "circle-check",
})

aboutTab:CreateSection({ name = "Tags" })

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
