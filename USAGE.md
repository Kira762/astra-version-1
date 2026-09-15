# Astra v1 — Usage Guide

Load Astra and build your first window in a few lines.

---

## Load the library

Two ways in, depending on where you run:

```lua
-- Studio / Rojo (recommended): Astra is a ModuleScript in ReplicatedStorage
local Astra = require(game:GetService("ReplicatedStorage").Astra)
```

```lua
-- Executor: the example loads the bundle from the repo and compiles it.
-- This is what example.client.luau does:
local bundleSource = game:HttpGet("https://raw.githubusercontent.com/Kira762/astra-version-1/main/version-1.luau")
local compile = loadstring or load
local bundleLoader = compile(bundleSource)
local Astra = bundleLoader()
```

The bundle (`version-1.luau`) is a generated artifact — require/load the single
bundle, never the modular tree, when running outside Rojo.

---

## Build a window

A window is the entry point. Create one, add a tab, and fill it with elements.

```lua
local window = Astra:CreateWindow({
    name = "Example Hub",
    subtitle = "Astra",
})

local tab = window:CreateTab({ name = "Home", icon = "house" })

tab:CreateInput({
    name = "Nickname",
    placeholder = "Type your name",
    callback = function(value)
        window:Notify({ title = "Hello", content = "You typed: " .. value })
    end,
})

tab:CreateInput({
    name = "Walk speed",
    placeholder = "16",
    numeric = true,
    callback = function(value)
        print("Walk speed:", value)
    end,
})
```

Input is the library's only element, and its field box sizes itself from the text
it shows — the placeholder while it is empty, the typed text once it is not.

The first visible tab opens on its own, so there is nothing else to wire up. Layout is built-in — switch it anytime in **Settings → Appearance → Bar Layout**.

---

## Built-in saving preferences

Saving no longer needs a `configuration` table in normal window usage. Open
**Settings → Persistence** to change **Auto Save Config** and **Auto Load Config**.
Both default to on for a new installation. Your choices are stored separately
from control values, even while Auto Save Config is off.

- Auto Save Config saves supported control values after a short coalescing delay.
- Auto Load Config restores the default configuration on the next startup.
  Turning it on does not replace values in the current session.
- Turning either off does not delete saved configurations.
- Stable, unique flags are recommended for controls that should be restored.
- File persistence requires a runtime with writable storage.

Default storage identifiers are internal and are not displayed in Settings.
The default configuration is shared by windows using the defaults; unrelated hubs
should use separate named presets or legacy configuration overrides to avoid
sharing values. Existing scripts with a `configuration` table remain accepted for
compatibility, but saved built-in save/load preferences take precedence.

### How saving works

Flags, multiple configurations, and reading values back out.

```lua
-- any input with a flag participates in Save/Load
tab:CreateInput({ name = "Nickname", flag = "nickname", value = "Player" })

window:Set("nickname", "Player two")
print(window:Get("nickname"))
print(window.Flags.nickname)

window:Save("Slot2")
window:Load("Slot2")
window:ListConfigs()
window:DeleteConfig("Slot2")
```

Inputs with `forgetState = true` are excluded. An input may derive its flag from
its name; an explicit unique flag makes restores stable when labels change.

---

## Next steps

Windows, tabs and the Input element — full reference below. See `example.client.luau` for a complete end-to-end example.

### Windows

Titles, themes, and every window method.

| Method | Description |
|---|---|
| `window:CreateTab({ name, icon })` | Create a tab. Returns a `Tab`. |
| `window:Notify({ title, content, icon, duration })` | Classic notification; opens on the entrance queue (see [Startup performance](#startup-performance)). |
| `window:Toast({ title, subtitle, icon, duration, position, ... })` | Compact toast; same queue, same one-at-a-time arrivals. |
| `window:Popup({ title, content, boxes, options, ... })` | Modal popup. Returns `Popup:Close()`. |
| `window:Navigate(tab)` | Select a tab by name or Tab object. |
| `window:Show()` / `window:Hide()` / `window:ToggleHide()` | Visibility. |
| `window:ToggleMinimise()` | Collapse/expand the rail. |
| `window:Close()` | Animated close (confirm popup is added by the topbar action); unloads the window when the transition finishes. |
| `window:Save(name?)` / `window:Load(name?)` | Save/load flags. |
| `window:ListConfigs()` | Array of saved config names. |
| `window:DeleteConfig(name)` | Delete a saved config. |
| `window:Get(flag)` / `window:Set(flag, value)` | Read/write by flag. |
| `window:ChangeTheme(theme)` | Swap theme at runtime. |
| `window:SetLocale(id)` / `window:SetTranslator(fn)` / `window:RegisterTranslations(t)` | Localisation. |
| `window:ResolveIcon(value, pack?)` | Icon name → asset id. |
| `window:GetPath()` | Returns the (folder, file) persistence path. |
| `window:Unload()` | Destroy the window. |
| `window.Flags` | Table of every registered flag's current value. |

Additional runtime helpers (used by the library internals, safe for extensions):
`window:Create(className, props, themeBindings?)` (instance factory with theme
and locale binding), `window:Connect(signal, fn)` /
`window:ConnectFor(element, signal, fn)` / `window:Disconnect(connection)` /
`window:DisconnectMany(list)`, `window:DestroySubtree(instance)` /
`window:DestroySubtrees(list)`, `window:CreateGlow(parent, color, blurRadius, transparency)`,
`window:CreateHoverOverlay(parent)`, `window:StyleElementBody(frame)` /
`window:StyleElementPanel(frame)`, `window:SaveSettings()` /
`window:LoadSettings()`, `window:SetProfile(profile)` — fills the profile card from real data with nothing invented: pass a string (or `nil`) to set/replace just the subtitle line (legacy behaviour: `nil` falls back to the `@username` line and leaves the host's key/whitelist rows alone), or a table for the whole payload:

```lua
window:SetProfile({
    subtitle = "Beta tester",              -- optional, replaces the @username line
    key = "ASTRA-XXXX-XXXX",               -- optional, masked until "Reveal profile details"
    tier = "PREMIUM",                      -- optional, the header pill's word (else PREMIUM / FREEMIUM from membership)
    whitelist = { status = "Active", daysLeft = 14 },  -- or expiresAt = os.time() + n
})
```

Fields you leave out read `—` on the card, and the whole row set stays masked until the window's **Reveal profile details** setting is on (the panel's own values always come from the player and the running server — never from this table).

Popup options: `options = { { text = "Cancel" }, { text = "Confirm", style = "primary" | "danger" | "neutral", callback = fn } }`.
Popup props: `title`, `subtitle`, `icon`, `content`, `boxes`, `options`, `dismissable`.

### Tabs

```lua
local tab = window:CreateTab({ name = "Home", icon = "house" })
tab:Select()      -- switch to it
tab:Deselect()    -- switch away
tab:Remove()      -- destroy it
```

Tab methods: `CreateInput`, `Select`, `Deselect` and `Remove`. `CreateInput` is
the whole element surface — there are no groups, sections or containers to nest
it in, so a tab page is a flat column of input cards.

### Elements

Input is the library's only element. It supports `Moveable` (`:MoveTo`,
`:MoveToTop`, `:MoveToBottom`, `:MoveUp`, `:MoveDown`) and `Lockable` (`:Lock`,
`:Unlock`, `:IsLocked`), plus the optional `icon` and `description` props every
card understands.

### Input

```lua
local field = tab:CreateInput({
    name = "Name",                      -- card title (locale-bound)
    icon = "user-round",                -- optional, from any pack
    description = "Shown to friends.",  -- optional in-card line
    placeholder = "Type here",          -- the hint, and what sizes an empty field
    value = "Initial",                  -- optional starting text
    flag = "nickname",                  -- optional; takes part in Save/Load
    numeric = false,                    -- digits, minus and the 1.5^-3 exponent form
    clearOnFocus = false,               -- clear on focus, restore the value on an empty blur
    forgetState = false,                -- exclude from persistence
    callback = function(text) end,
})

field:Set("New value")           -- fires the callback
field:Set("New value", true)     -- silent
field:SetPlaceholder("New hint") -- retype the hint; the box re-measures
field:MoveTo(1)                  -- also MoveToTop / MoveToBottom / MoveUp / MoveDown
field:Lock("Reason shown on the description line")
field:Unlock()
print(field.value, field:IsLocked())
```

**The field box sizes itself from the text it shows.** While the field is empty
the box measures its placeholder; as soon as something is typed it measures the
typed text instead. The measurement is that text's width at the field's 15px
size plus 30px of padding, clamped between a 70px floor (an empty field stays
tappable) and a ceiling of `min(220, 55% of the page width)` — so a short hint
renders as a short box, a long hint as a long box, and a narrow page caps both.
The title row gives up exactly the width the box took, so the two never collide.

Every trigger that can change the measurement re-measures the box:

| Trigger | What changed |
|---|---|
| typing, or `Set` | the typed text replaces the placeholder as the measure |
| clearing the field | the placeholder becomes the measure again |
| `SetPlaceholder(text)` | the hint — and so the empty field's width — is retyped at runtime |
| `window:SetLocale(id)` | a translated hint is rarely the same length |
| `window:ChangeTheme(theme)` | the font is a theme token, so the same text can measure differently |
| the page changing width | a layout switch or a window resize moves the 55% ceiling |

An unchanged measurement costs nothing: the new width is compared with the one
the box already has before anything is written, so a re-measure that lands on
the same number creates no tween.

```lua
-- Short, medium and long hints render as short, medium and long boxes.
tab:CreateInput({ name = "Short", placeholder = "Name" })
tab:CreateInput({ name = "Medium", placeholder = "Enter your display name" })
tab:CreateInput({ name = "Long", placeholder = "Type the full name of the loadout you want to apply" })

-- Retype a hint at runtime and its empty field follows.
local field = tab:CreateInput({ name = "Retyped", placeholder = "Short" })
field:SetPlaceholder("A much longer hint than before")
```

### Built-in Settings (window only)

Every window ships a built-in Settings group (gear action in the topbar). Clicking the gear switches into settings mode — only the settings tabs are shown — and clicking it again returns to the previous tab. It's window-scoped: it edits this window's own behaviour, stored per-window — not global.

Input is the library's only element, so the panel is typed rather than clicked:
every setting is a field whose box shows the value that is active now, and
committing new text applies it. Switches read `On`/`Off` (and accept
`true`/`false`, `yes`/`no`, `1`/`0`, `enabled`/`disabled`); choices accept their
label or their key (`frost`, `Frost`); a value a setting cannot honour snaps the
field back to what is active and raises a notification saying why, so the panel
never displays something the window is not using.

The settings tabs are:

| Tab | Contents |
|---|---|
| **General** | Toggle Keybind (type a key name, e.g. `K` or `F3`), the window-behaviour switches (unlock cursor while open, welcome toast, prevent duplicate windows, keep window on screen, draggable capsule), Haptics, Animation speed (`Relaxed` / `Normal` / `Snappy` / `Instant`), and Reset Positions (type `window`, `capsule` or `both`). |
| **Appearance** | Theme and Bar Layout (`Default Topbar` / `Sidebar (Responsive)` / `Collapsed Sidebar`) — both confirmed by a popup before they apply — plus the profile card controls (Show profile / Profile side / Reveal profile details). |
| **Persistence** | Auto Save Config / Auto Load Config switches, the Saved Configurations list, a Configuration Name field, and a Config Action field (type `save`, `load`, `delete` or `list`). |
| **About** | Library info and links, as description lines. |

The window and its profile card (a compact 260x420 card — the default
window's height) are centred as one unit: with the card on, the window rests
half a card (136px) off the screen centre on the opposite side of it, so
window + 12px gap + card line up in the middle together. That resting
centre is re-derived on the first show, on every hide/show restore and whenever
the card's state changes (toggle, side, viewport, a player turning up late), and
"Keep window on screen" clamps the pair rather than the window alone, so a drag
can push neither of them off the edge. A position you dragged to is respected —
auto-centring never overrides it; typing `window` (or `both`) into **Reset
Positions** recentres the pair, and `capsule` puts the minimised bar back.

There is no sub-tab API: these tabs are built by the window itself
(`Window:_buildSettingsUI`), not by user code.

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
Astra.Icons.get("house")                -- searched in every pack, priority order
Astra.Icons.get("material:home")        -- exactly this pack (`pack:name`)
Astra.Icons.get("home", "tabler")       -- the optional pack argument does the same
Astra.Icons.getByPack("tabler", "home")
Astra.Icons.resolve("house")            -- a URL / asset id, ready for an Image
Astra.Icons.list("lucide")
Astra.Icons.packs() Astra.Icons.count() Astra.Icons.isPack("feather")
Astra.Icons.priority() Astra.Icons.loaded()      -- the search order / packs read so far
Astra.Icons.refreshCustom()                      -- re-read custom_asset/
window:ResolveIcon("house")             -- searches all packs
window:ResolveIcon("feather:home")      -- selects one exact icon
```
No window-wide `iconPack` option is needed.

**Name-only lookup.** A bare name is searched in every pack, in a fixed order —
lucide, material, tabler, phosphor, heroicons, feather (`Astra.Icons.priority()`) —
and the first pack that has it wins. Nothing to pick, nothing to configure: lucide
spells the home glyph `house`, material has no `house` but has `home`, so both
`get("house")` and `get("home")` work, the latter from material. A name that exists
in several packs always answers from the earlier pack. The search is lazy: a pack's
table is read on first lookup, and only the packs up to the hit are read, so a lucide
name costs one pack. `Astra.Icons.loaded()` tells you which packs a session has read.

**Qualified names.** When it has to be a specific pack, qualify it —
`get("tabler:home")`, `resolve("lucide:house")`, `window:ResolveIcon("material:home")`
— or pass the pack as the second argument. An explicit pack is never overruled by the
order: if that pack has no such icon the request resolves to nothing (and `resolve`
hands back the value it was given). Names, pack names and the `pack:` prefix are
matched exactly as written; `Home`, `HOME` and `Lucide:house` are not `home`, and no
lookup is lowercased, corrected or fuzzed. An unknown pack name warns once per pack
and answers nothing, rather than substituting a pack you did not ask for.

**All-pack window lookup.** `window:ResolveIcon(name)` searches every pack, just
like `Astra.Icons.resolve`. `ResolveIcon(name, pack)` and `pack:name` still select
one exact pack when desired. Window and element icons can mix packs freely.
The old window-wide `iconPack` property is no longer used.

Icon names resolve to 48x48 PNGs that ship in this repo under
`assets/icons/<pack>-pack/`; the resolver maps them onto the repo's raw-GitHub URL
(or your executor's `getcustomasset` override when one is provided), so no
`rbxassetid` lookups are needed. Values already usable as-is — numbers,
`rbxassetid://…`, `rbxasset://…`, `rbxthumb://…`, `http(s)://…` — pass through
untouched, and an unresolved value comes back unchanged. See
[the visual icon catalog](assets/icons/README.md) for previews and copyable names across all six packs.

**Custom assets.** A `custom_asset/` folder next to your script takes precedence
over the packs at resolve time: one file per icon name, in `.png`, `.jpg`, `.jpeg`,
`.webp` (tried in that order) or with no extension, subfolders allowed —
`custom_asset/brand/house.png` is asked for as `get("brand/house")`. With an executor
that provides `listfiles` the folder is indexed once and looked up by name, so names
you have no file for cost nothing; without it the resolver keeps the historic
extension probe. Either way a file is imported at most once per runtime, misses are
remembered, and `Astra.Icons.refreshCustom()` re-reads the folder after you add or
remove files. Qualified names are never shadowed by the folder.

### Motion (animation)

Astra's window transitions — hover, element reveal, the window entrance, the
result flashes, every card's entrance and dismissal — run through one service,
so your own animations can use the same timing and answer the same
"Animation speed" setting the user picked in Performance → Motion. (The
entrance queue that spaces the notification and toast arrivals paces itself
through `Motion.step`, so it stretches and shortens with that setting too;
the only curves outside the vocabulary are two delayed glow beats, and those rescale with the
profile as well.)

```lua
-- Animate with the library's own specs.
Astra.Motion.tween(frame, { BackgroundTransparency = 0.5 }, "snappy")

-- Specs: instant, fast, snappy, normal, smooth, emphasized, pop, glide,
-- exit, spring, settle, spin, drift. A TweenInfo works anywhere a name does.
--
-- The vocabulary is a system: entrances decelerate (Out), exits accelerate
-- (`exit` is In — a dismissal is quicker than its entrance), lateral state
-- moves ease InOut (`glide` — the window folding into its capsule), and the
-- playful surfaces get a small Back overshoot (`pop` for the shell, `settle`
-- for small elements, `spring` for drag landings).
Astra.Motion.tween(stroke, { Color = Color3.new(1, 1, 1) }, TweenInfo.new(0.3))

-- Settle work after the animation, without racing a synchronous completion.
Astra.Motion.tween(panel, { Position = target }, "smooth", function()
    panel.Visible = false
end)

-- Steer the whole interface.
Astra.Motion.setProfile("relaxed")     -- relaxed | normal | snappy | instant
Astra.Motion.setTimeScale(0.8)         -- custom multiplier instead
Astra.Motion.setEnabled(false)         -- apply targets immediately, no tweens
Astra.Motion.step(0.035)               -- cascade pacing, scaled like the rest
Astra.Motion.cancel(frame)             -- stop what the service owns here
```

`motion.tween` never animates a property that is already at its target (a call
whose properties are all satisfied creates no tween at all) and cancels an
in-flight tween it would fight with, so repeated calls from an event handler
cannot stack competing animations on the same property.

### Localisation

```lua
window:RegisterTranslations({ en = { play = "Play" }, de = { play = "Spielen" } })
window:SetLocale("de")
window:SetTranslator(function(source, localeId) return ... end)
```

### Full example

See `example.client.luau` — an Input-only example that loads the bundle with the
remote loader and puts the sizing recipe on screen: short, medium and long
placeholders side by side, a field whose typed value is wider than its hint, a
numeric field, a `SetPlaceholder` pair that retypes one field from another, and
a flagged field that persists.

---

## CreateWindow — all props

```lua
local window = Astra:CreateWindow({
    name = "My UI",              -- title (left side of topbar)
    subtitle = "v1.0",           -- small text next to title
    icon = "house",              -- topbar icon (pack name or asset id)
    theme = "default",           -- built-in name (10 built-ins, see Themes below) or custom table
    showName = "Astra",          -- name shown when the window is minimised to the capsule (default "Astra")
    showIconOnly = false,        -- capsule shows only the icon, no name
    fallbackFont = Enum.Font.Gotham,  -- font used when the brand font cannot load
    translator = function(source, localeId) return ... end,  -- optional custom translator
    locale = "en",
    translations = { ... },
})
```
Layout is **not** a CreateWindow prop — switch it in **Settings → Appearance → Bar Layout**.

### Startup performance

Window construction is staged across frames. Large initial batches of `CreateTab`
and `Create…` calls yield at completed-control boundaries after roughly 4 ms of
work or 120 new instances. These are cooperative limits, not a hard frame-time
cap: a single expensive control can exceed them. Calls still return fully built
objects, but may yield while creating the initial UI.

Automatic show happens on the next frame — one deferred tick plus one heartbeat,
so the caller's first synchronous `CreateTab` calls land before the shell
appears — and the remaining constructors keep streaming in behind the
already-visible window in small budget-limited batches until the build goes
quiet, so the opening tween keeps receiving frames. `window:Hide()` before the
first reveal cancels auto-show; `window:Show()` can still be called explicitly.

The arrival itself is staged rather than instant: the window's shell (frame, surface,
corner, topbar) animates in first, the page's controls cascade in one control per beat
a beat later, and overlays follow the content. `window:Notify` and `window:Toast` are
therefore queued — the card is *built* on its own turn, one entrance at a time, with a
cooldown between two of them — instead of all landing on the frame the window opens
on. A backlog stays bounded: past six waiting requests the oldest one that has not
been built yet is dropped. Nothing else about the two calls changed (they still accept
the same props and their cards still dismiss on click, on timeout, and on the visible
cap), and with the speed profile set to **Instant** the queue keeps the order but drops
the pauses, so a host that fires a notification per loaded module gets a cascade
instead of a freeze either way.

Search controls are created the first time search opens. Additional built-in
settings tabs are created on first settings access, and their controls remain lazy
until each tab is selected. Controls added to inactive tabs wait until that tab is
shown before running their reveal animations.
