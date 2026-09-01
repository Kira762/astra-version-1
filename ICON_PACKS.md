# Astra Icon Packs

Astra now exposes the catalog from [Haijo12/roblox-icons](https://github.com/Haijo12/roblox-icons) through `astra.Icons`. The catalog contains PNG assets from six open-source icon families and returns raw GitHub URLs that can be passed directly to Astra component `icon` properties.

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

```lua
local Astra = require(path.to.astra)

local window = Astra:CreateWindow({
    Title = "Icon demo",
})

local settingsIcon = Astra.Icons.get("settings", "lucide")
local searchIcon = Astra.Icons.getByPack("tabler", "search")

window:AddTab({
    Name = "Settings",
    Icon = settingsIcon,
})

window:AddButton({
    Name = "Search",
    Icon = searchIcon,
})
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

Use one primary pack per surface. Prefer Lucide for the main Astra shell, Tabler when the UI needs a larger vocabulary, Phosphor when visual weight needs to vary, Heroicons when solid/outline pairing is intentional, Feather for lightweight utility controls, and Material only when the surrounding design already follows Material conventions. Avoid mixing packs for equivalent actions such as `settings`, `search`, or `close`, because stroke geometry and optical weight differ between families.

The upstream repository retains each icon family’s original license. Keep the upstream attribution and license files when redistributing the catalog.
