# Astra v1 — Usage Guide

How to load Astra, build windows, and use every element, method, and option.
All props accept the `camelCase` names shown below (most also accept
`PascalCase` aliases). Icons are looked up by name from the selected icon pack
(`ResolveIcon` also accepts a raw asset id number).

---

## Loading the library

`version-1.luau` and `example.client.luau` live in the same repo — no external
links. Pick the loader that matches your environment (behaviour is identical):

```lua
-- Studio / Rojo: Astra is a ModuleScript in ReplicatedStorage (from library_entrypoint.luau)
local Astra = require(game:GetService("ReplicatedStorage"):FindFirstChild("Astra"))
local window = Astra:CreateWindow({ name = "My UI", subtitle = "v1.0" })
```

```lua
-- Executor / LocalScript: version-1.luau sits next to this script (local file)
local Astra: any = nil
if typeof(readfile) == "function" and typeof(isfile) == "function" and isfile("version-1.luau") then
    local source = readfile("version-1.luau")
    local loadFn = assert(loadstring(source))
    Astra = assert(loadFn())
end
local window = Astra:CreateWindow({ name = "My UI", subtitle = "v1.0" })
```

The bundled example `example.client.luau` already does the local-first
resolution chain (`ReplicatedStorage` → sibling `version-1` ModuleScript →
`readfile+loadstring`/`io.open`) with zero `HttpGet` — just copy that header
if you need a standalone loader. Only one window may be alive at a time;
creating a new window unloads the previous one unless `antiWindowDuplicate` is
disabled (see Settings below).

## CreateWindow

```lua
local window = Astra:CreateWindow({
    name = "My UI",              -- window title (left side of topbar)
    subtitle = "v1.0",           -- small text next to the title
    icon = "house",              -- topbar icon (pack name or asset id)
    iconPack = "lucide",         -- "lucide" | "material" | "tabler" | "phosphor" | "heroicons" | "feather"
    theme = "default",           -- "default" | "amethyst" | "cobalt" | "ember" | "frost" | "rose" | custom table
    profile = "Display Name",    -- optional profile (avatar + name) in the sidebar/topbar
    locale = "en",               -- default locale id
    translations = { ... },      -- optional translation table
    configuration = {            -- persistence
        autoSave = true,         -- save flags when toggles/sliders/etc change
        autoLoad = true,         -- restore flags automatically on creation
        fileName = "MyConfig",   -- default config name
        customFolder = nil,      -- optional custom storage folder
    },
})
```

## Window methods

| Method | Description |
|---|---|
| `window:CreateTab({ name, icon })` | Create a tab. Returns a `Tab`. |
| `window:CreateSection({ name, icon })` | Top-level (window-level) section — a `TabSection`. |
| `window:CreateTag({ text, title, icon, color, order })` | Small tag shown in the window footer. Returns `Tag`. |
| `window:Notify({ title, content, icon, duration })` | Classic notification. |
| `window:Toast({ title, subtitle, subtitleAbove, icon, avatar, duration, position, minWidth })` | Compact toast. |
| `window:Popup({ title, subtitle, icon, content, boxes, options, dismissable })` | Modal popup. Returns a `Popup` (has `:Close()`). |
| `window:Navigate(tab)` | Select a tab by name or Tab object. |
| `window:Show()` / `window:Hide()` / `window:ToggleHide()` | Visibility. |
| `window:ToggleMinimise()` | Collapse/expand the rail. |
| `window:Save(name?)` / `window:Load(name?)` | Save/load the current flag set under a config name. |
| `window:ListConfigs()` | Array of saved config names. |
| `window:DeleteConfig(name)` | Delete a saved config. |
| `window:Get(flag)` / `window:Set(flag, value)` | Read/write a control by its `flag`. |
| `window:ChangeTheme(theme)` | Swap theme at runtime. |
| `window:SetLocale(id)` / `window:SetTranslator(fn)` / `window:RegisterTranslations(t)` | Localisation. |
| `window:ResolveIcon(value, pack?)` | Icon name/asset id → asset id. |
| `window:GetPath()` | Returns the (folder, file) persistence path. |
| `window:Unload()` | Destroy the window and disconnect everything. |
| `window:AddSettingsTab({ name, icon })` | Add a sub-tab inside the built-in Settings page (see below). |
| `window.Flags` | Table of every registered flag's current value. |

Popup options: `options = { { text = "Cancel" }, { text = "Confirm", style = "primary" | "danger" | "neutral", callback = fn } }`.

## Tabs

```lua
local tab = window:CreateTab({ name = "Home", icon = "house" })
tab:Select()      -- switch to it
tab:Remove()      -- destroy it
```

Tab methods (all take a props table and return the element):
`CreateButton`, `CreateToggle`, `CreateSwitch`, `CreateSlider`,
`CreateDropdown`, `CreateInput`, `CreateKeybind`, `CreateColorPicker`,
`CreateStat`, `CreateProgress`, `CreateConsole`, `CreateSection`, `CreateText`,
`CreateDivider`, `CreateGroup`.

## Elements

Every element supports `Moveable` (`:MoveTo(index)`, `:MoveToTop()`,
`:MoveToBottom()`, `:MoveUp()`, `:MoveDown()`) and most support `Lockable`
(`:Lock(reason?)`, `:Unlock()`, `:IsLocked()`).

Common props on interactive elements: `name`, `description`, `icon`, `flag`
(config key), `value` (initial), `forgetState` (don't persist), `callback`.

### Button
```lua
tab:CreateButton({
    name = "Click Me", icon = "play",
    description = "Optional helper text",
    callback = function() print("clicked") end,
})
```

### Toggle / Switch
```lua
local t = tab:CreateToggle({
    name = "Auto Sprint", flag = "autoSprint", value = true,
    callback = function(on) print(on) end,
})
t:Set(false)          -- programmatically change (fires callback unless skipCallback)
t:Set(false, true)    -- change silently
```
`CreateSwitch` is an alias of `CreateToggle`.

### Slider
```lua
tab:CreateSlider({
    name = "Sensitivity", flag = "sens",
    range = { 1, 10 }, value = 5, increment = 1, suffix = "x",
    minimal = true, -- compact style
    callback = function(value, dragging) end,
})
```

### Dropdown
```lua
local d = tab:CreateDropdown({
    name = "Preset", options = { "Low", "Medium", "High" }, value = "Medium",
    multiSelect = true, placeholder = "Pick items",
    callback = function(selected) end,
})
d:Refresh({ "A", "B" })   -- replace options
d:Add("C")                -- append one option
d:Remove("A")             -- drop one option
```
Multi-select values are arrays.

### Input
```lua
tab:CreateInput({
    name = "Name", placeholder = "Type here",
    numeric = true,        -- digits only
    clearOnFocus = true,
    callback = function(text) end,
})
```

### Keybind
```lua
tab:CreateKeybind({
    name = "Toggle Panel", value = Enum.KeyCode.F3,
    isMenuToggle = true,   -- acts as a toggle for the window visibility
    hold = true, holdThreshold = 0.2, -- hold-mode keybind
    callback = function(value) end, onChanged = function(key) end,
})
```

### ColorPicker
```lua
local c = tab:CreateColorPicker({
    name = "Accent", color = Color3.fromRGB(96, 205, 255), alpha = 0.8,
    callback = function(color, alpha) end,
})
c:SetAlpha(0.5)
```

### Stat
```lua
local s = tab:CreateStat({ name = "Kills", value = 128, prefix = "", suffix = " kills" })
s:Set(200)                -- animated odometer update
s:ResetBaseline(0)        -- reset change-display baseline
```
Extra props: `display` ("value"|"change"), `compact`, `changeMode`,
`changeBaseline`, `numberEasing`.

### Progress
```lua
local p = tab:CreateProgress({ name = "Download", range = { 0, 100 }, value = 35 })
p:Set(80)                     -- advance
p:SetRange(0, 500)            -- rescale
p:SetText("Downloading...")   -- custom label
p:SetIndeterminate(true)      -- pulse animation
```
Also: `steps = 5` (stepped bar), `format` (custom text), `showValue`,
`:Get()`, `:GetPercentage()`.

### Text
```lua
local x = tab:CreateText({ name = "Title", text = "Body text", icon = "info" })
x:Set("New body") / x:SetTitle("New title")
```

### Divider
```lua
tab:CreateDivider()                        -- plain line
tab:CreateDivider({ text = "or" })         -- labelled
tab:CreateDivider({ line = false })        -- spacing only
```

### Console
```lua
local con = tab:CreateConsole({
    name = "Log", text = "-- ready", height = 130,
    follow = true,   -- autoscroll
    maxLines = 50,
})
con:Append("hello")   -- appends a line
con:Set("reset")      -- replace all content
con:Get() con:Clear() con:SetHeight(200)
con:Copy()            -- copies to clipboard if setclipboard exists
```

### Group
```lua
local row = tab:CreateGroup()                       -- horizontal row
local col = row:CreateGroup({ direction = "column" }) -- nested column
col:CreateToggle({ name = "Left 1" })
```
Groups support `CreateButton`, `CreateToggle`, `CreateSwitch`, `CreateStat`,
`CreateSlider`, `CreateDropdown`, `CreateSection`, `CreateText`,
`CreateDivider`, and nested `CreateGroup`.

## Built-in Settings (window only)

Every window ships a hidden "Astra Settings" tab (opened via the gear action in
the topbar). It is **window-scoped, not global**: it edits this window's own
behaviour (layout mode, duplicate-window guard, animation toggles, keybind,
etc.), stored per-window through the config file — it is not a shared
global-state system and is not a place to add user feature settings. It is only
accessible through the window's settings (gear) action, not through public
methods.

Use `window:AddSettingsTab` to add your own sub-tab *inside* that page if you
need window-scoped preference controls:

```lua
local sub = window:AddSettingsTab({ name = "Hotkeys", icon = "keyboard" })
sub:CreateSection({ name = "Combat" })
sub:CreateToggle({ name = "Auto Sprint", flag = "hotkeyAutoSprint", value = true })
sub:CreateSlider({ name = "Sensitivity", range = { 1, 10 }, value = 5 })
```
Elements created on a settings sub-tab use the normal flag/persistence
pipeline (`window:Get`/`window:Set`, autosave), so they behave exactly like
elements on any other tab.

## Flags & persistence

Any element with a `flag` participates in Save/Load:

```lua
window:Set("autoSprint", false)  -- set control by flag
print(window:Get("autoSprint"))  -- read control value
print(window.Flags.autoSprint)   -- same via the Flags table
window:Save("Slot2")             -- snapshot current flags to "Slot2"
window:Load("Slot2")             -- restore
```

Elements with `forgetState = true` are excluded from persistence. Elements
without a flag are visual-only (not registered in `window.controls`).

## Themes

Built-ins: `"default"`, `"amethyst"`, `"cobalt"`, `"ember"`, `"frost"`,
`"rose"`.

```lua
window:ChangeTheme("amethyst")
-- or a custom table (unknown keys inherit from default):
window:ChangeTheme({
    ElementGradient = ColorSequence.new(Color3.fromRGB(20,20,30), Color3.fromRGB(30,30,45)),
    AccentColor = Color3.fromRGB(120, 90, 220),
})
```
Useful keys: `WindowColor`/`ElementGradient` (ColorSequence gradients),
`CardSurface`, `ElementStroke`, `ContentColor`, `TitlingColor`, `AccentColor`,
`ElementTransparency`, `ElementCornerRadius`, `TabColor`, `Font`, `TitleFont`
(full list in `themes/default.luau`).

## Icons

```lua
Astra.Icons.get("house")                 -- from the default pack
Astra.Icons.get("play", "material")      -- from a specific pack
Astra.Icons.list("lucide")               -- names in a pack
Astra.Icons.packs() Astra.Icons.count()  -- catalog info
window:ResolveIcon("house")              -- via a window (uses its pack)
```
`iconPack` constants: `"lucide" | "material" | "tabler" | "phosphor" | "heroicons" | "feather"`.

## Localisation

```lua
window:RegisterTranslations({
    en = { play = "Play" },
    de = { play = "Spielen" },
})
window:SetLocale("de")
window:SetTranslator(function(source, localeId) return ... end)
```
Any string prop wrapped by the locale system resolves through the active
translator.

## Full example

See `example.client.luau` — it demonstrates every element, groups, tags,
notifications, popups, consoles, stats, and config save/load end to end.
