# Astra v1 — Usage Guide

Load Astra and build your first window in a few lines.

---

## Load the library

Add one line at the top of your script to pull in Astra. It's in the same repo — just require it like any other file, no links.

```lua
local Astra = require(game:GetService("ReplicatedStorage"):FindFirstChild("Astra"))
```

---

## Build a window

A window is the entry point. Create one, add a tab, and fill it with elements.

```lua
local window = Astra:CreateWindow({
    name = "Example Hub",
    subtitle = "Astra",
})

local tab = window:CreateTab({ name = "Home", icon = "house" })

tab:CreateButton({
    name = "Say hello",
    callback = function()
        window:Notify({ title = "Hello", content = "Your first element works." })
    end,
})

tab:CreateToggle({
    name = "Auto Sprint",
    callback = function(value)
        print("Auto Sprint:", value)
    end,
})
```

The first visible tab opens on its own, so there is nothing else to wire up. Layout is built-in — switch it anytime in **Astra Settings → Bar Layout**.

---

## Turn on saving

Pass a configuration table and the window remembers every value between sessions. Nothing else is required, and each value restores as its original type.

```lua
local window = Astra:CreateWindow({
    name = "Example Hub",
    configuration = {
        autoSave = true,
        autoLoad = true,
        fileName = "ExampleHub",
    },
})
```

### How saving works

Flags, multiple configurations, and reading values back out.

```lua
-- any element with a flag participates in Save/Load
tab:CreateToggle({ name = "Auto Sprint", flag = "autoSprint", value = true })

window:Set("autoSprint", false)
print(window:Get("autoSprint"))
print(window.Flags.autoSprint)

window:Save("Slot2")
window:Load("Slot2")
window:ListConfigs()
window:DeleteConfig("Slot2")
```

Elements with `forgetState = true` are excluded. Elements without a flag are visual-only.

---

## Next steps

Windows, tabs and groups, elements, secure mode — full reference below. See `example.client.luau` for a complete end-to-end example.

### Windows

Titles, tags, themes, and every window method.

| Method | Description |
|---|---|
| `window:CreateTab({ name, icon })` | Create a tab. Returns a `Tab`. |
| `window:CreateSection({ name, icon })` | Top-level section — a `TabSection`. |
| `window:CreateTag({ text, title, icon, color, order })` | Small tag in the window footer. |
| `window:Notify({ title, content, icon, duration })` | Classic notification. |
| `window:Toast({ title, subtitle, icon, duration, position })` | Compact toast. |
| `window:Popup({ title, content, boxes, options })` | Modal popup. Returns `Popup:Close()`. |
| `window:Navigate(tab)` | Select a tab by name or Tab object. |
| `window:Show()` / `window:Hide()` / `window:ToggleHide()` | Visibility. |
| `window:ToggleMinimise()` | Collapse/expand the rail. |
| `window:Save(name?)` / `window:Load(name?)` | Save/load flags. |
| `window:ListConfigs()` | Array of saved config names. |
| `window:DeleteConfig(name)` | Delete a saved config. |
| `window:Get(flag)` / `window:Set(flag, value)` | Read/write by flag. |
| `window:ChangeTheme(theme)` | Swap theme at runtime. |
| `window:SetLocale(id)` / `window:SetTranslator(fn)` / `window:RegisterTranslations(t)` | Localisation. |
| `window:ResolveIcon(value, pack?)` | Icon name → asset id. |
| `window:GetPath()` | Returns the (folder, file) persistence path. |
| `window:Unload()` | Destroy the window. |
| `window:AddSettingsTab({ name, icon })` | Add a sub-tab inside the built-in Settings page. |
| `window.Flags` | Table of every registered flag's current value. |

Popup options: `options = { { text = "Cancel" }, { text = "Confirm", style = "primary" | "danger" | "neutral", callback = fn } }`.

### Tabs and groups

```lua
local tab = window:CreateTab({ name = "Home", icon = "house" })
tab:Select()      -- switch to it
tab:Remove()      -- destroy it

local row = window:CreateGroup()                       -- horizontal row
local col = row:CreateGroup({ direction = "column" }) -- nested column
col:CreateToggle({ name = "Left 1" })
```

Tab methods: `CreateButton`, `CreateToggle`/`CreateSwitch`, `CreateSlider`, `CreateDropdown`, `CreateInput`, `CreateKeybind`, `CreateColorPicker`, `CreateStat`, `CreateProgress`, `CreateConsole`, `CreateSection`, `CreateText`, `CreateDivider`, `CreateGroup`.

### Elements

Every element supports `Moveable` (`:MoveTo`, `:MoveToTop` …) and most support `Lockable` (`:Lock`, `:Unlock`).

```lua
tab:CreateButton({ name = "Click Me", icon = "play", callback = function() end })
tab:CreateSlider({ name = "Sensitivity", range = { 1, 10 }, value = 5, suffix = "x", minimal = true, callback = function(v, dragging) end })
tab:CreateDropdown({ name = "Preset", options = { "Low", "Medium", "High" }, value = "Medium", multiSelect = true, placeholder = "Pick items", callback = function(s) end })
tab:CreateInput({ name = "Name", placeholder = "Type here", numeric = true, clearOnFocus = true, callback = function(t) end })
tab:CreateKeybind({ name = "Toggle Panel", value = Enum.KeyCode.F3, isMenuToggle = true, callback = function(v) end })
tab:CreateColorPicker({ name = "Accent", color = Color3.fromRGB(96, 205, 255), alpha = 0.8, callback = function(c, a) end })
```

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
t:Set(false)          -- fires callback unless skipCallback
t:Set(false, true)    -- silent
```
`CreateSwitch` is an alias.

### Slider
```lua
tab:CreateSlider({
    name = "Sensitivity", flag = "sens",
    range = { 1, 10 }, value = 5, increment = 1, suffix = "x",
    minimal = true,
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
d:Refresh({ "A", "B" })
d:Add("C")
d:Remove("A")
```

### Input
```lua
tab:CreateInput({
    name = "Name", placeholder = "Type here",
    numeric = true, clearOnFocus = true,
    callback = function(text) end,
})
```

### Keybind
```lua
tab:CreateKeybind({
    name = "Toggle Panel", value = Enum.KeyCode.F3,
    isMenuToggle = true, hold = true, holdThreshold = 0.2,
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
s:Set(200)
s:ResetBaseline(0)
```

### Progress
```lua
local p = tab:CreateProgress({ name = "Download", range = { 0, 100 }, value = 35 })
p:Set(80)
p:SetRange(0, 500)
p:SetText("Downloading...")
p:SetIndeterminate(true)
```

### Text / Divider / Console / Group
```lua
local x = tab:CreateText({ name = "Title", text = "Body text", icon = "info" })
x:Set("New body") x:SetTitle("New title")

tab:CreateDivider()  tab:CreateDivider({ text = "or" })  tab:CreateDivider({ line = false })

local con = tab:CreateConsole({ name = "Log", text = "-- ready", height = 130, follow = true, maxLines = 50 })
con:Append("hello") con:Set("reset") con:Get() con:Clear() con:SetHeight(200)

local row = tab:CreateGroup()
local col = row:CreateGroup({ direction = "column" })
col:CreateToggle({ name = "Left 1" })
```

### Built-in Settings (window only)

Every window ships a hidden "Astra Settings" tab (gear action in the topbar). It's window-scoped: it edits this window's own behaviour (layout mode, duplicate-window guard, keybind, etc.), stored per-window — not global.

```lua
local sub = window:AddSettingsTab({ name = "Hotkeys", icon = "keyboard" })
sub:CreateSection({ name = "Combat" })
sub:CreateToggle({ name = "Auto Sprint", flag = "hotkeyAutoSprint", value = true })
```

### Themes

Built-ins: `"default"`, `"amethyst"`, `"cobalt"`, `"ember"`, `"frost"`, `"rose"`.

```lua
window:ChangeTheme("amethyst")
window:ChangeTheme({
    ElementGradient = ColorSequence.new(Color3.fromRGB(20,20,30), Color3.fromRGB(30,30,45)),
    AccentColor = Color3.fromRGB(120, 90, 220),
})
```

### Icons

```lua
Astra.Icons.get("house")
Astra.Icons.get("play", "material")
Astra.Icons.list("lucide")
Astra.Icons.packs() Astra.Icons.count()
window:ResolveIcon("house")
```
`iconPack`: `"lucide" | "material" | "tabler" | "phosphor" | "heroicons" | "feather"`.

### Localisation

```lua
window:RegisterTranslations({ en = { play = "Play" }, de = { play = "Spielen" } })
window:SetLocale("de")
window:SetTranslator(function(source, localeId) return ... end)
```

### Full example

See `example.client.luau` — demonstrates every element end to end with `local window = Astra:CreateWindow` and `local tab = window:CreateTab`.

---

## CreateWindow — all props

```lua
local window = Astra:CreateWindow({
    name = "My UI",              -- title (left side of topbar)
    subtitle = "v1.0",           -- small text next to title
    icon = "house",              -- topbar icon (pack name or asset id)
    iconPack = "lucide",         -- "lucide" | "material" | "tabler" | "phosphor" | "heroicons" | "feather"
    theme = "default",           -- "default" | "amethyst" | "cobalt" | "ember" | "frost" | "rose" | custom table
    profile = "Display Name",    -- optional profile (avatar + name)
    locale = "en",
    translations = { ... },
    configuration = {            -- persistence
        autoSave = true,
        autoLoad = true,
        fileName = "MyConfig",
        customFolder = nil,
    },
})
```
Layout is **not** a CreateWindow prop — switch it in **Astra Settings → Bar Layout**.
