# Astra v1 — Module & Local Reference

A guide to every module in the modular tree and the meaning of its important
locals. After the minification pass, locals inside function bodies are renamed
to short names (`a1`, `a2`, … `a275`); this document explains what each
numbered local holds, per file, so future reviews don't have to reverse-engineer
the names. Top-level (file-scope) locals keep meaningful names — only
function-body locals were shortened.

Legend: locals are listed in declaration order per file/function. `self`
fields (`self.x`) are named as-is and not minified.

---

## Root

### `Types.luau`
Type definitions only (`export type ...`). No runtime locals.

### `library_entrypoint.luau`
Public API singleton. Key top-level locals:
- `a1..a6` — required modules (`core.state`, `core.init`, `components.window`, `Types`, `functions.init`, `icons`).
- `a7..a10` — singleton bookkeeping: existing-window guard, CreateWindow dispatcher, anti-duplicate flag (persisted via settings), export table.
Exported names (unchanged): `CreateWindow`, `Icons`, `Core`, `Settings`, `ChangeTheme`, `SetLocale`, `SetTranslator`, `RegisterTranslations`, `Unload`.

### `example.client.luau`
Usage example — not minified logic-wise; demonstrates window/tab/element creation and `AddSettingsTab`.

---

## core/

### `core/init.luau`
- `a1..a2` — requires (registry, loader).
- Exposes `require`-by-name helper used by the rest of the tree.

### `core/state.luau`
Shared runtime singletons:
- `a1..a9` — Roblox services (`players`, `runService`, `tweenService`, `httpService`, `guiContainer`, `inputService`, `userInputService`, `hapticService` where available).
- `brandFont` — font resolver honoring the platform's brand font override.
- Table fields: `localPlayer`, `services`, `fsManager`, `fontManager`, `assetResolver`.

### `core/registry.luau`
- `a1..a3` — name→module map, lazy getter, registration list. `registerFactory` lets components override element factories.

### `core/loader.luau`
- `a1..a4` — cache of loaded modules, require path resolver (handles init-folder `script` vs `script.Parent` anchoring), preload queue.

---

## components/

### `components/window.luau` (the largest module; class `Window`, minified as `a17`)
Constructor/`new` locals:
- `a2..a5` — `core.state`, `functions.colors`, `functions.textMetrics`, `utilities.layouts`.
- `a6..a14` — zIndex/display-order constants, default window props, layout-mode resolution.
- `a15` — `core.state` runtime table (services, localPlayer, tweenService…).
- `a4.toColorSequence` — gradient coercion helper for theme values.

Notable instance fields set in `new`: `screenGui`, `main`, `elements`,
`tabList`, `sidebar`, `settings` (plain table with `activeSubTab`),
`_settingsTabs`, `_settingsActiveSubTab`, `settingsCard`, `settingsCardStroke`,
`_settingsCardBuilt`, `_settingsLayoutActive`.

Method map (name preserved through minification):
- `_buildSettingsCard` — locals `a221` (isTopLayout), `a222` (card Frame), `a223` (stroke from StyleElementBody), `a224` (rfSettings tab).
- `_destroySettingsCard` — `a225` unused; re-parents rfSettings page, destroys card.
- `_setSettingsSubTabsVisible` — `a225` (visible flag), `a226` (hasSubTabs).
- `_selectSettingsSubTab` — `a227` (target index), `a228` (instant/no tween), `a229` (tabs array), `a230` (descriptor), `a231` (isSelected), `a232` (TweenInfo or nil), `a233` (target transparency).
- `AddSettingsTab` — `a234` (props); builds strip button + ScrollingFrame page, returns virtual tab delegating to rfSettings.
- `StyleElementBody` — `a327` (target frame); applies gradient/corner/stroke, returns stroke.
- `_buildCompactRow` — `a328` (tab), `a329` (name), `a330` (zIndex), `a331` (row frame), `a332` (stroke), `a333` (button).
- `StyleElementPanel` — `a334` (frame), `a335` (stroke).

### `components/sidebar.luau`
Profile/avatar machinery:
- `avatarGenerations`, `avatarReady` — weak-keyed side tables (generation guard, reveal state). No custom Instance fields.
- `setProfileShown(window, shown, info)` — tweens avatar/name/subtitle; nil-safe; themed plate fallback when the image never resolved.
- `buildProfile` — three unified branches (sidebar footer / topbar right-anchored / collapsed avatar-only).
- `reflowProfile`, `applyWidth` — layout responders per layout mode.

### `components/drag.luau`
- `utility` — `core.state` alias. Locals `a1..a8` — drag input state (start pos, delta thresholds, RenderStepped connection).

### `components/action.luau`, `chrome.luau`, `tabSelector.luau`
Small window-furniture classes; top-level `utility` require + constructor locals for created frames/buttons.

### `components/notification.luau`, `toast.luau`, `popup.luau`
Overlay queues: `a1..a4` — container frame, TweenInfo presets, queue table, active-instance guard.

### `components/search.luau`
Fuzzy search overlay: locals for candidate list, scoring weights, debounce connection.

---

## elements/

All element classes share the pattern:
- First local — `require(...core.state)` alias.
- `new(tab, props)` — locals for normalized props, created frame, and connections.
- `_setShown`, `_refreshTheme`, `Set`/`Set_`-style setters keep their public names.

Per-element specifics:
- `toggle.luau` — track/knob frames, accent tween locals.
- `slider.luau` — fill frame, handle, drag math locals (`a1..a12`: range min/max, step, value normalization).
- `dropdown.luau` — button, list frame, option buttons, highlight.
- `input.luau` — TextBox, placeholder/focus locals, validation callback.
- `keybind.luau` — listening state flag, input connection.
- `colorpicker.luau` — HSV state, drag locals for hue/sv areas.
- `tab.luau` — tab class: `tabPage` (ScrollingFrame), `_register(element)` pipeline into `window.controls[flag]`, selector button visuals.
- `group.luau`, `section.luau`, `tabSection.luau` — container classes with UIListLayout locals.
- `console.luau` — output buffer table, max-lines constant, print hook.
- `descriptor.luau`, `divider.luau`, `progress.luau`, `stat.luau`, `tag.luau`, `text.luau`, `button.luau` — simple display/interaction elements.

---

## settings/

- `init.luau` — module wiring: `a1..a3` (registry, defaults, manager), exports `manager.new`, `registry`, `defaults`, `persistence`.
- `registry.luau` — per-key definitions: `definition` entries `{ default, validate, domain }`; `activeSubTab` added (domain `appearance`).
- `defaults.luau` — flat default values table (includes `activeSubTab = 1`).
- `manager.luau` — `newManager(props)`: `a1..a5` (values table, listener list, validate fn, save queue); `set(key, value)` routes through validate + listeners, returns false for unknown keys.
- `persistence.luau` — save/load orchestration over `utilities.persistenceSettings`/`persistenceWrite`.
- `appearance.luau`, `behavior.luau`, `performance.luau` — per-domain validation tables keyed by setting name.

---

## functions/

- `init.luau` — re-export table.
- `colors.luau` — `toColorSequence` (Color3→ColorSequence), lerp/firstColor helpers.
- `textMetrics.luau` — text-width estimation via `TextService`.
- `flagNames.luau` — control-flag (config key) sanitizer/uniquer.

---

## images/ & cache/

- `image.luau` — `assign` (guarded property write), `avatar(userId, callback)` — returns cached URI or `""`, fires callback after fetch; empty final URI → caller uses plate fallback.
- `windowIcons.luau` — asset-id registry for built-in chrome icons (settings, close, minimize, profile placeholder).
- `cache/imageCache.luau` — disk/memory cache; `pcall(callback, uri or "")` at the end of the retry chain.
- `cache/moduleCache.luau`, `persistenceCache.luau`, `init.luau` — generic memoization layers.

---

## icons/

- `init.luau` — public surface (`get`, `resolve`, `getByPack`, `list`, `packs`, `count`, `isPack`) with lazy metatables per pack.
- `lucide/feather/material/phosphor/heroicons/tabler.luau` — pure data tables `{ name = "...", path = "..." }`. Names are public lookup keys; never renamed.

---

## themes/

- `init.luau` — resolution engine: `a4` (module table), `a5` (ColorSequence-key whitelist), `coerceValue`, `firstColor`, `deriveStrokes` (`a9` = luminance-based stroke deriver), `resolve` (clones `default`, overlays chosen theme).
- `default.luau` + 5 themes — theme tables. All keys include `CardSurface` (Color3, settings-card background) added in the `2ecd628` fix.

---

## utilities/ (selected)

- `constants.luau` — static constants incl. `icons` map (with `profileAvatarPlaceholder`).
- `persistenceSettings.luau` — settings JSON encode/decode; `activeSubTab` round-trips here.
- `persistenceWrite.luau` — atomic write helper.
- `persistenceConfig.luau`, `persistencePaths.luau` — window-config serialization and key paths.
- `layouts.luau` — `railWidthFor`, layout-mode tables (`chromeHeight`, `fadeSize`, `cardCorners`).
- `HapticEngine.luau` — vibration wrappers guarded by service availability.
- `moveable.luau`, `lockable.luau` — drag/lock mixins.
- `log.luau` — warn/error/log with Astra prefix.
- `locale.luau` — translation table + `SetTranslator` support.
- `filesystem.luau`, `filesystemManager.luau` — RobloxFS abstraction (isFolder/WriteFile wrappers, secure-mode aware).
- `assetResolver.luau`, `network.luau`, `services.luau` — platform layer (HTTP fetch with retries, service singletons).
- `windowSizing.luau` — responsive size computation.
- `enums.luau`, `ordering.luau`, `odometer.luau`, `fontManager.luau`, `functions.luau` (legacy shim), `path.luau` — small helpers.

---

## Naming conventions after minification

| Pattern | Meaning |
|---|---|
| `a1`–`aN` (file-scope) | top-level requires, in require order |
| `a1`–`aN` (in-function) | per-function locals, in declaration order |
| `self`, method names | untouched (public/private API surface) |
| Roblox property string keys | untouched |
| Icon-name strings, config flags | untouched (data) |

When touching a minified file, re-run `python3 tools/minify/minify.py <file>`
and `luau-compile` afterward, then `node scripts/generate_bundle.js`.
