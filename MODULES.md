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
- Requires — `core` (state/registry/loader), `core.state`, `images.image`, `utilities.locale`, `utilities.constants`, `icons`, `settings`, `Types`.
- Singleton bookkeeping: existing-window guard backed by a module-local `activeWindow` **and** a `getgenv()`-backed global store (key `__ASTRA_ACTIVE_WINDOW_V1`) so the anti-duplicate guard survives across `loadstring`ed instances; the `CreateWindow` dispatcher (pcall around `components.window.new`, re-throws on failure); the export table.
Exported names (typed surface is `Types.luau`'s `Astra`): `CreateWindow`, `Icons`; `Core` and `Settings` are also assigned on the table at runtime. There is no top-level `ChangeTheme`/`SetLocale`/`SetTranslator`/`RegisterTranslations`/`Unload` — those are window methods.
`CreateWindow` side effects: enforces the anti-duplicate guard (persisted `antiWindowDuplicate` setting, per-window opt-out via `settings.antiWindowDuplicate`), in secure mode preloads window images (`Image.preload` → failure `Notify`) and swaps in the brand fonts via `ChangeTheme({ Font, TitleFont })` when they load, then auto-`Show()`s the window one tick later (a `task.defer`, so a script that builds its tabs synchronously can finish first and the window appears once, fully populated; an explicit `Hide()` before that tick cancels it via `_autoShowCancelled`).

### `example.client.luau`
Usage example (not minified). Loads the bundle with `game:HttpGet` + `loadstring`, then builds a 20-tab window: Home, Controls, Appearance, Information, Changelog, Updates, plus 15 labelled test tabs. Demonstrates window tags, every element type, groups, console, and the `CreateChangelog` element (including a runtime `changelog:Add`), and ends with an explicit `home:Select()`.

---

## core/

### `core/init.luau`
- Requires `state`, `registry`, `loader` and exposes them as one table:
  `core.state`, `core.registry`, `core.loader` (the entrypoint and
  `components/*` consume it via `require(...core)`).

### `core/state.luau`
Shared runtime singletons:
- Roblox service fields: `localPlayer`, `coreGui`, `workspace`,
  `runService`, `userInputService`, `guiService`, `tweenService`,
  `httpService`, `textService`, `replicatedStorage`,
  `localizationService`, `guiContainer` (secure-mode aware).
- `secureMode` — platform detection; `fallbackFont` (default
  `Enum.Font.BuilderSans`) + `setFallbackFont(font)`; `brandFont(weight)` —
  font resolver honoring the platform's brand font override.
- Manager singletons: `fileSystemManager`, `assetResolver`, `fontManager`.

### `core/registry.luau`
- `a1..a3` — name→module map, lazy getter, registration list. `registerFactory` lets components override element factories.

### `core/loader.luau`
- `knownModules` — allow-list (`state`, `registry`); `loader.load(name)` requires a known core module exactly once (re-entrant guard + pcall re-throw).
- `loader.service(name, factory)` — registers an element factory override through the registry and returns it.

---

## components/

### `components/window.luau` (the largest module; class `Window`, minified as `a17`)
Constructor/`new` locals:
- `a2..a5` — `core.state`, `functions.colors`, `functions.textMetrics`, `utilities.layouts`.
- `a6..a14` — zIndex/display-order constants, default window props, layout-mode resolution.
- `a15` — `core.state` runtime table (services, localPlayer, tweenService…).
- `a4.toColorSequence` — gradient coercion helper for theme values.

Notable instance fields set in `new`: `screenGui`, `main`, `elements`,
`tabList`, `sidebar`, `settings` (plain table: `toggleKeybind`, `theme`,
`mouseOverride`, `keepOnScreen`, `welcomeToast`, `haptics`,
`dragMinimisedBar`, `showProfile`, `showFullUsername`,
`antiWindowDuplicate`, `layoutMode`, `activeSubTab`), `rfSettings` (the
built-in "General" settings tab), `_settingsTabs` (settings-tab list),
`_settingsMode` / `_previousTab` (settings-mode bookkeeping),
`settingsAction` / `minimiseAction` (topbar actions), `drag`,
`collapsedInteract`, `connections` / `instances` / `themeProperties` /
`localeProperties` / `controls` / `tabs` (lifecycle registries),
`Flags` (metatable view over `controls`).

Method map (names preserved through minification). Settings-related:
- `_buildSettingsUI` — creates the six built-in settings tab shells
  (General via `rfSettings`, plus Appearance, Behavior, Performance,
  Persistence, About; all `isSettingsTab`, `forgetState`). Rail/page order
  follows `customOrder` (General 1001 first, About 1006 last) so opening
  settings highlights the first rail row. Element content is built lazily:
  each tab stores a `_settingsContentBuilder` closure and
  `Window:_buildSettingsContent(tab)` runs it on the tab's first open
  (`Tab:Select`, after construction), so `CreateWindow` stays fast.
  Appearance hosts theme picker + Bar Layout picker (both
  popup-confirmed), the profile toggles (Show profile, Profile side
  Right/Left, Reveal full username) and window toggles, Reset Window
  Position;
  Persistence always hosts saved-config Save/Load/Delete (independent of
  the `configuration` prop — paths fall back to the window name, and the
  dropdown shows its "No saved configurations" placeholder when none
  exist).
- `settingsAction` (topbar gear, `linkedTab = rfSettings`) — toggles
  settings mode via `_toggleSettingsMode` (shared with the profile
  panel's gear): entering shows only settings tabs and remembers the
  previous tab; a second click restores it.
- `_applySettingsLayout(active)` — reflows rail/elements for settings mode.
- `SaveSettings` / `LoadSettings` — per-window settings persistence via
  `utilities.persistence` (settings JSON, includes `activeSubTab` round-trip).
Public surface:
- `Create(className, props, themeBindings?)` — instance factory: theme-bound
  property recording (`themeProperties`), locale-token binding
  (`_bindLocale`), image-guessed property assignment; tracks every instance
  for `Unload`.
- `ChangeTheme`, `CreateTab`/`CreateSection`/`CreateTag`, `Notify`/`Toast`/
  `Popup`, `Show`/`Hide`/`ToggleHide`/`ToggleMinimise`, `Close` (animated
  close → `Unload`), `Save`/`Load`/`ListConfigs`/`DeleteConfig`/`GetPath`,
  `Get`/`Set`, `Navigate`, `SetLocale`/`SetTranslator`/
  `RegisterTranslations`, `ResolveIcon`, `SetProfile`, `Unload`.
- Lifecycle/extension helpers: `Connect`/`ConnectFor`/`Disconnect`/
  `DisconnectMany`, `DestroySubtree`/`DestroySubtrees`, `CreateGlow`,
  `CreateHoverOverlay`, `StyleElementBody`/`StyleElementPanel` (element
  gradient/corner/stroke styling), `_buildCompactRow` (settings-mode tab row).
Internal: `_reveal*`/`_fadeSurfaces`/`_firstShow`/`_quickRestore` (reveal
engine), `_bindTopbarDrag`/`_bindKeybind`/`_bindMouseOverride`,
`_applyWindowSize`/`_applyRailWidth`/`_clampToScreen`/`_watchViewport`,
`_profileCenterPosition`/`_recenterForProfile` (window + profile-panel
recentering), `_setLayoutMode`, `_toggleSettingsMode` (topbar gear + profile
panel gear), `_registerControl`/`_unregisterControl`/`_persist`,
`_runGuarded`, `_setElementLocked`/`_buildLockScrim`, `_updateWindowTitle`.

### `components/sidebar.luau`
Tab-rail reflow (the profile system moved to `components/profilePanel.luau`):
- `maskUsername(name)` — shared masking helper (first 3 chars + `****`), used by the profile panel.
- `buildTabRail` — rail ScrollingFrame + UIPadding + UIListLayout (the layout implementations build their own rails).
- `applyRailRows(window, width, layout)` — rows collapse only at the icon-only width (the responsive rail is often narrower than the old 219px fixed rail); ends with `tabSelector.relayoutSidebarRows`.

### `components/profilePanel.luau`
The profile panel — a 280x500 companion card floating beside the window
frame (a sibling in the same ScreenGui), replacing the in-window profile.
Content stacks top-to-bottom in one flow, matching the design mock: 72px
avatar with presence dot, centred display name / @username subtitle,
PREMIUM badge, an ACCOUNT DETAILS stack (User ID with a COPY action on the
value row, Join date with account age, Friends / Followers rows), a
CURRENT GAME card (dark `CardSurface` plate with the game icon thumbnail,
game name and Place ID), and a bottom-pinned settings gear:
- `build(window, onOpenSettings)` — visible themed surface (WindowColor
  gradient, `CornerRoundness` corners, SurfaceStroke stroke, ShadowColor
  glow); avatar with a generation guard via `images.image.avatar`;
  centred name / subtitle (truncated at end); bottom-pinned settings gear
  sharing `Window:_toggleSettingsMode` (hover pill + stroke hover,
  pcalled). Mirrors `main`'s Position through property-change signals, so
  it follows drags/restores/resizes without a per-frame loop.
- `layout(window)` — places the fixed-size card on the selected side
  (`settings.profileSide`, default `"right"`) flush with the window edge
  (12px gap), vertically centred on the window's centre; the interior is
  static, so it never needs reflow.
- `setShown(window, shown, info)` — effective = requested AND enabled AND
  window visible (not hidden/minimised); fades avatar/name/subtitle/gear/
  stroke; idempotent (skips instances already at target).
- `isEnabled` / `shiftFor` — content-enabled check (`showProfile` on,
  player known, and the screen has horizontal room for window + gap +
  panel plus vertical room for the card's height — a space check, so
  landscape phones count) and the off-centre shift
  `((280 + 12) / 2 = 146px)`, 0 while the panel is off.
- `setEnabled`, `setSide` — settings drivers (both recenter the window).
- `setSubtitle` (from `Window:SetProfile`), `refreshName` (masked vs
  `showFullUsername`).

The window rests off-centre so window + gap + panel are centred as one unit
(`Window:_profileCenterPosition` / `Window:_recenterForProfile`): with the
panel on the right the window sits 52px left of screen centre, and
vice-versa. The panel hides when the screen lacks room for the pair
(portrait phones) and with hide/minimise/close.

### `components/drag.luau`
- `utility` — `core.state` alias. Locals `a1..a8` — drag input state (start pos, delta thresholds, RenderStepped connection).

### `components/action.luau`, `chrome.luau`, `tabSelector.luau`
Small window-furniture classes; top-level `utility` require + constructor locals for created frames/buttons.

`tabSelector.railContentWidth(window, layout)` — natural rail width for the
responsive sidebar: the widest row in the current rail group (tabs or
settings tabs per `_settingsMode`), measured with `functions.textWidth`
(title + icon/spacing/paddings) plus row insets; 0 when the group is empty.
`Window:_railWidth` uses it to size the rail itself
(`min(content, floor(windowWidth / 2))` for the expanded responsive rail;
fixed widths elsewhere), and `tabSelector.relayoutSidebarRows` constrains an
overlong title to the row's remaining slot so its existing `TextWrapped`
wraps it in place. Re-derived from `sidebar.applyRailRows` (rail width
changes), `Window:_applyContentRailWidth` (layout/settings/locale/theme
changes, tab removal), `Tab:Remove`, `Window:SetLocale` and
`Window:ChangeTheme`. No-op for the topbar and collapsed-sidebar layouts.
`applyRailRows` treats the rail as collapsed only at the icon-only width
(`railCollapsedWidth`), so a content-sized rail narrower than the old fixed
219px still shows titles.

### `components/notification.luau`, `toast.luau`, `popup.luau`
Overlay queues: `a1..a4` — container frame, TweenInfo presets, queue table, active-instance guard.

### `components/search.luau`
Fuzzy search overlay: locals for candidate list, scoring weights, debounce connection.

---

## layouts/

One module per bar-layout mode, each with `Build(window, layout)` (creates the
tab strip and rail chrome) and `ApplyWidth(window)` (reflow):

- `Topbar.luau` — mode `top`: horizontal tab strip in the topbar.
- `Sidebar.luau` — mode `sidebar` (responsive): vertical tab rail.
- `SidebarCollapsed.luau` — mode `collapsedSidebar`: compact rail.

`utilities/layouts.luau` holds the per-mode metric tables and dispatches
(`layouts.get(mode)`, `layouts.implementation(mode)`,
`layouts.railWidthFor(layout, viewportWidth)`); `utilities/windowSizing.luau`
uses the same builders for responsive sizing. The window selects the
implementation in `_setLayoutMode`.

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
- `changelog.luau` — release-history element (`__type = "Changelog"`): normalizes `ChangelogEntry`/`ChangelogChange` props, maps symbols (`+`/`-`/`~`, or words like "added"/"removed"/"changed") to green/red/amber, fades entries in, supports `Set`/`Refresh`/`Add(entry, prepend?)`/`Clear`.
- `descriptor.luau`, `divider.luau`, `progress.luau`, `stat.luau`, `tag.luau`, `text.luau`, `button.luau` — simple display/interaction elements.

---

## settings/

- `init.luau` — module wiring: exports the `manager`, `registry`, `defaults`,
  `persistence` modules plus `settings.newManager(overrides)` and
  `settings.readPersisted(key, default)` (used by the entrypoint for the
  anti-duplicate guard).
- `registry.luau` — `definitions`: one `{ key, kind, domain, description }`
  entry per setting. Keys: `toggleKeybind` (keybind/behavior),
  `mouseOverride` (boolean/behavior), `keepOnScreen` (boolean/appearance),
  `welcomeToast` (boolean/behavior), `haptics` (boolean/performance),
  `showProfile` (boolean/appearance), `showFullUsername` (boolean/appearance),
  `antiWindowDuplicate` (boolean/behavior), `layoutMode` (enum/appearance),
  `activeSubTab` (enum/appearance — persisted, retained for compatibility
  with the pre-rebuild sub-tab UI). Lookup: `registry.definition(key)`,
  `registry.keys()`.
- `defaults.luau` — `values`: flat defaults (`toggleKeybind = Enum.KeyCode.K`,
  `layoutMode = "top"`, `activeSubTab = 1`, …); `defaults.clone(overrides)`.
- `manager.luau` — `SettingsManager.new(overrides)` → `{ defaults =
  defaults.clone(overrides), persistence = {} }`; methods `get`, `set`
  (routes through `registry.definition` + the domain validator, returns false
  for unknown keys), `reset`, `onChange(listener)`, `save`, `load`.
- `persistence.luau` — save/load/read of the per-window settings JSON over
  `utilities.persistenceSettings` (round-trips `activeSubTab` and friends).
- `appearance.luau`, `behavior.luau`, `performance.luau` — per-domain
  `validate(key, value) -> (ok, normalized)`. Appearance additionally
  whitelists `layoutMode ∈ { top, sidebar, collapsedSidebar }` and floors
  `activeSubTab` to an integer ≥ 1.

---

## functions/

- `init.luau` — re-export table: `textWidth`, `textHeight`,
  `deriveFlagFromName`, `contrastColor`, `toColorSequence`, `contrastText`.
- `colors.luau` — `toColorSequence` (Color3/ColorSequence pass-through),
  `contrastColor` (black/white by luminance), `contrastText` (dark/white for
  text overlays).
- `textMetrics.luau` — text width/height estimation via `TextService`.
- `flagNames.luau` — control-flag (config key) sanitizer/uniquer.

---

## images/ & cache/

- `init.luau` — folder module: re-exports the image helpers
  (`resolve`, `assign`, `preload`, `avatar`, `rewrites`) alongside
  `windowIcons`.
- `image.luau` — `assign` (guarded property write), `resolve` (value →
  loadable image URL), `avatar(userId, callback)` — returns cached URI or
  `""`, fires callback after fetch; empty final URI → caller uses plate
  fallback; `preload(callback)` — batch preload reporting
  `(failedCount, failedRoles)`; `rewrites`/`onBlock`/`pending` — URL
  rewrites, blocklist hook, in-flight tracking.
- `windowIcons.luau` — asset-id registry for built-in chrome icons (settings,
  close, minimize, profile placeholder, …).
- `cache/imageCache.luau` — disk/memory cache; `pcall(callback, uri or "")` at the end of the retry chain.
- `cache/moduleCache.luau`, `persistenceCache.luau`, `init.luau` — generic memoization layers.

---

## icons/

- `init.luau` — public surface (`get`, `resolve`, `getByPack`, `list`,
  `packs`, `count`, `isPack`) with lazy metatables per pack: a pack's data
  module is required on first lookup, then cached (`packLoaders` /
  `loadedPacks`). Resolution pipeline: pack values are repo-relative PNG
  paths under `assets/icons/<pack>-pack/<first-letter>/`; `resolve` maps them
  onto the repo's raw-GitHub base URL (`assetBase`), honours an executor
  `getcustomasset` override (cached in `customAssetCache`, folder
  `custom_asset`), and passes numeric asset ids through unchanged;
  `namedAssets` covers a few named chrome assets.
- `lucide/feather/material/phosphor/heroicons/tabler.luau` — pure data tables
  `{ [name] = "assets/icons/..." }`. Names are public lookup keys; never
  renamed. Entry counts: lucide 1776, tabler 5130, phosphor 1512,
  heroicons 324, feather 287, material 299.

---

## themes/

- `init.luau` — resolution engine: module table, ColorSequence-key
  whitelist, `coerceValue`, `firstColor`, `deriveStrokes`
  (luminance-based stroke deriver), `resolve` (clones `default`, overlays
  chosen theme, so custom tables inherit missing keys).
- `default.luau` + 9 themes (`amethyst`, `cobalt`, `crimson`, `ember`,
  `emerald`, `frost`, `gold`, `onyx`, `rose`) — theme tables of ~65 keys
  (surfaces, strokes, text colors, gradients, fonts, corner radii,
  slider/toggle/picker styling). Keys a theme omits are inherited from the
  `default` clone. Registered in two places: the settings-UI theme table in
  `components/window.luau` and the persisted-theme whitelist in
  `utilities/persistenceSettings.luau`.
  `CardSurface` (Color3, from the `2ecd628` settings-card fix) is still
  defined in every theme but no longer referenced by the rebuilt settings
  UI — kept for compatibility.

---

## utilities/ (selected)

- `constants.luau` — static constants incl. `icons` map (with `profileAvatarPlaceholder`).
- `persistenceSettings.luau` — settings JSON encode/decode; `activeSubTab` round-trips here.
- `persistenceWrite.luau` — atomic write helper.
- `persistenceConfig.luau`, `persistencePaths.luau` — window-config serialization and key paths.
- `persistence.luau` — facade re-exporting the config + settings persistence
  surface (`getPath`, `save`, `load`, `applyTo`, `list`, `delete`,
  `getSettingsPath`, `saveSettings`, `loadSettings`); required by the window
  and by `settings/persistence`.
- `layouts.luau` — per-mode metric tables (`chromeHeight`, `fadeSize`,
  `cardCorners`, …) and dispatch into the `layouts/` builders
  (`get`, `implementation`, `railWidthFor`).
- `HapticEngine.luau` — vibration wrappers guarded by service availability.
- `moveable.luau`, `lockable.luau` — drag/lock mixins.
- `log.luau` — warn/error/log with Astra prefix.
- `locale.luau` — translation table + `SetTranslator` support.
- `filesystem.luau`, `filesystemManager.luau` — RobloxFS abstraction (isFolder/WriteFile wrappers, secure-mode aware).
- `assetResolver.luau`, `network.luau`, `services.luau` — platform layer (HTTP fetch with retries, service singletons).
- `windowSizing.luau` — responsive size computation (desktop tiers around the
  600x420 default, min/max protected) plus the fixed mobile profile returned
  for touch-only phone-sized viewports (`isMobileViewport`).
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

When touching a minified file, re-minify only that file, then
`luau-compile` it and run `scripts/check_requires.py`,
`scripts/check_instance_fields.py`, and `node scripts/generate_bundle.js`.
(Validate against the full tree with `scripts/smoke_test_bundle.sh`.)
