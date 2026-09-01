# Astra Icon Packs

Astra now exposes the catalog from [Haijo12/sisys_ididh](https://github.com/Haijo12/sisys_ididh) through `astra.Icons`. The catalog contains PNG assets from six open-source icon families and returns raw GitHub URLs that can be passed directly to Astra component `icon` properties.

> **Default rule:** use **Lucide** for new Astra UI. It provides a clean, minimal, consistent outline style and is the best visual match for Astra’s existing controls.

## Pack selection guide

| Icon pack | Best use in Astra | Visual guidance | License | Count |
|---|---|---|---|---:|
| `lucide` | Default UI, navigation, actions, settings, status controls | Clean, minimal outline icons; recommended default | ISC | 1,776 |
| `tabler` | Dense dashboards, advanced tools, analytics, developer utilities | Broadest catalog and modern outline treatment | MIT | 5,130 |
| `phosphor` | Product-facing UI that needs expressive hierarchy | Flexible family with multiple weights represented by the source set | MIT | 1,512 |
| `heroicons` | Tailwind-style interfaces, compact navigation, outline/solid emphasis | Use when outline and solid variants are useful | MIT | 648 |
| `feather` | Small, simple utility controls and legacy Feather-matched UI | Very minimal 24px stroke icons; smaller catalog | MIT | 287 |
| `material` | Material Design-style layouts or Google ecosystem conventions | Stronger filled/Google visual language; use intentionally rather than mixing casually | Apache 2.0 | 2,266 |

## Usage

Set exactly one pack on the window, then pass plain icon names to tabs and components. The exported constants make the configuration readable:

```lua
local Astra = require(path.to.astra)
local Lucide = Astra.Icons.Lucide

local window = Astra:CreateWindow({
    name = "Example Hub",
    subtitle = "Astra Gen2",
    iconPack = Lucide,
})

local tab = window:CreateTab({
    name = "Home",
    icon = "house",
})

tab:CreateButton({
    name = "Settings",
    icon = "settings",
})
```

Every icon-bearing component uses the window’s selected pack, including tabs, buttons, toggles, sliders, inputs, dropdowns, keybinds, color pickers, stats, progress indicators, sections, tags, text, notifications, toasts, popups, and actions. Existing asset IDs, Roblox asset URIs, and direct URLs continue to pass through unchanged.

A window accepts **one pack only**. If both `iconPack` and `IconPack` are supplied, or if `iconPack` is given a table/list containing multiple packs, Astra raises an error. Use one of the supported values: `Lucide`, `Material`, `Tabler`, `Phosphor`, `Heroicons`, or `Feather`. If no pack is supplied, Astra defaults to Lucide.

The direct catalog methods remain available for discovery and tooling, but do not mix packs within a window’s normal component configuration:

```lua
local icon = Astra.Icons.get("arrow-right", Astra.Icons.Lucide)
```

The pack argument is optional and defaults to `lucide`:

```lua
local icon = Astra.Icons.get("arrow-right")
```

For runtime discovery, use `packs`, `list`, and `count`:

```lua
for _, pack in Astra.Icons.packs() do
    print(pack, Astra.Icons.count(pack))
end

local names = Astra.Icons.list("feather")
```

`get` and `getByPack` return `nil` when a pack or icon name is unavailable. Icon names use lowercase **kebab-case**, such as `settings`, `arrow-right`, `circle-check`, and `panel-left`.

## Astra built-in icons

Astra’s internal close, minimize, maximize, settings, search, chevron, check, dot, configuration, logo, and banner assets remain on Astra’s existing numeric asset IDs. This preserves secure-mode preloading and backward compatibility. Use `Astra.Icons` for custom component icons and new UI instead of replacing those internal IDs blindly.

## Consistency rules

Use exactly one pack per window. Prefer Lucide for the main Astra shell, Tabler when the UI needs a larger vocabulary, Phosphor when visual weight needs to vary, Heroicons when solid/outline pairing is intentional, Feather for lightweight utility controls, and Material only when the surrounding design already follows Material conventions. Avoid mixing packs for equivalent actions such as `settings`, `search`, or `close`, because stroke geometry and optical weight differ between families.

The upstream repository retains each icon family’s original license. Keep the upstream attribution and license files when redistributing the catalog.
