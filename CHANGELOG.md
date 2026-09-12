# Changelog

All notable changes to Astra v1. Dates use 2026.

## 2026-09-12 — Settings screen: rail order and empty Persistence tab

- **Opening Settings now highlights the first rail row.** The rail rows
  (and the content pages) are ordered by each tab's `customOrder`, but
  the About tab was created with `customOrder = 1000` — lower than
  General's `1001` — so About sorted to the top and the gear action
  (which always opens General) highlighted the **second** row. About now
  uses `1006`, after Persistence, so the rail reads General, Appearance,
  Behavior, Performance, Persistence, About.
- **The Persistence tab is no longer empty.** Its content (Configurations
  section, Saved Configurations dropdown, name input, Save/Load/Delete
  group) was gated behind `next(self.configuration) ~= nil`, which is only
  true when the window is created with a `configuration`
  prop (autoSave/autoLoad/fileName). Windows created without it — including
  the example client — got a blank tab. The content is now built like every
  other settings tab; config save/load already works without the prop
  (paths fall back to the window name), and the dropdown shows its
  "No saved configurations" placeholder when there is nothing saved.
- **Verification:** `scripts/sidebar_tab_sizing_test.sh` now asserts the
  settings rail order (General first, About last), that opening settings
  via the gear path selects General and shows General's page in the
  content area, and that the Persistence tab builds its content for a
  window created without a `configuration` prop. The test fails against
  the pre-change tree. Bundle regenerated (99 modules).

## 2026-09-12 — Responsive sidebar rail follows the longest tab name

- **The responsive sidebar (`Sidebar (Responsive)` bar layout) now sizes its
  rail from the tab names.** The longest visible row in the current rail
  group (tabs or settings tabs, whichever mode the rail shows) determines the
  group's natural width via the existing `functions.textWidth` measurement of
  the row title (icon + spacing + paddings + row insets included). The rail
  itself takes that width, and the rows keep their original full-rail,
  side-aligned size (`scale 1, offset -rowInset*2`) — so every tab in the
  rail is exactly as wide as the longest one, with no floating/centered rows.
- **The window's available space is the cap, not a constant.** Rail width is
  `min(longest natural width, floor(window width / 2))` — no new fixed pixel
  value, and the elements area always keeps at least half of the window.
  The existing `Sidebar.ApplyWidth` already gives the elements area
  `(1, -railWidth, ...)`, so it automatically takes back whatever space the
  rail frees. When a very long name would exceed the cap, the rows hold the
  available width and that title label is constrained to the remaining slot,
  where its existing `TextWrapped` keeps the name readable.
- **Narrow windows are unchanged:** below `railCollapseBelow` the rail still
  collapses to the icon-only width (`railCollapsedWidth`), and the rail is
  considered collapsed only while it is at that icon-only width (a
  content-sized rail below the old fixed 219px still shows titles).
- **The width is re-derived whenever the visible rail group or its inputs
  change:** tab create/remove, layout-mode switch, settings-mode toggle,
  viewport/rail width changes, locale changes (translated titles measure
  differently) and theme changes (title font).
- **Scope:** only the responsive sidebar path (`Window:_railWidth` /
  `Window:_applyContentRailWidth` in `components/window.luau`,
  `tabSelector.railContentWidth` + label wrap in
  `components/tabSelector.luau`, the collapsed check in
  `components/sidebar.luau`, and a re-derive hook in
  `elements/tab.luau`). The topbar layout's per-pill `AutomaticSize.X`
  sizing, the collapsed sidebar's fixed icon-only rail, all tab styles,
  animations, selection and scrolling behavior are untouched.
  `setRowCollapsed` additionally skips rows whose rail was already destroyed
  mid-layout-switch (a destroyed instance must not have properties written
  to it).
- **Verification:** new `scripts/sidebar_tab_sizing_test.sh` (Luau CLI
  harness with a mini Roblox environment, `sidebar_sizing_stubs.luau`)
  exercises the real bundle: identical short names, short/long mixes, one
  very long name (cap + wrapped title + elements keep half the window),
  multiple long names, narrow/wide window (collapse/expand round-trip),
  settings-mode rail, icon-less and `neglectSelector` tabs, locale changes,
  and confirms the topbar and collapsed-sidebar layouts keep their existing
  sizing. The test fails against the pre-change tree (negative control).
  Bundle regenerated (99 modules).

## 2026-09-11 — Window sizing: 600x420 default, fixed mobile profile

- **Default window size is now `600x420`** (was `720x600`) in both bar-layout
  profiles (`top`, `sidebar`) in `utilities/windowSizing.luau`. The responsive
  caps were rebalanced around the new default (`maxSize` 720x480 top /
  760x500 sidebar, `widthCompensation` 100 → 80); the minimum protections are
  unchanged (500x330 top, 540x360 sidebar). No other 720x600 default remains.
- **Desktop/PC stays responsive:** `windowSizing.fit` keeps the existing
  tiered viewport-occupancy fit, so a normal desktop targets exactly 600x420,
  smaller/shorter screens shrink responsively (width compensation kicks in on
  short viewports), and large/ultrawide screens stay capped instead of growing
  into an oversized window. The viewport watcher, `_applyWindowSize`,
  dragging/collapsing and the public API in `components/window.luau` are
  unchanged (comments only).
- **Mobile now uses a fixed size/profile:** touch-only devices (phones —
  `TouchEnabled` with no hardware keyboard) whose short side is below Astra's
  existing 700px phone breakpoint get a per-mode fixed profile instead of live
  occupancy math: `316x318` (top) / `331x280` (sidebar), derived from the
  existing phone-tier fit evaluated once at a 360x390 reference (narrowest
  mainstream phone width × the reference short side `scaleForViewport`
  documents), so the fixed window fits a phone in portrait and landscape
  without clipping. Rotation, the on-screen keyboard and inset changes no
  longer resize the window; tablets, desktops and narrow desktop viewports
  keep the responsive fit.
- **New helper:** `windowSizing.isMobileViewport(viewport)`. `UIScale`
  (`scaleForViewport`) is unchanged and still applied on both paths, so the
  fixed mobile window keeps its per-device perceived scale. Bundle
  regenerated (99 modules).

## 2026-09-11 — New themes (emerald, gold, crimson, onyx) + frost redesign

- **Four new built-in themes:** `emerald` (dark forest, green accent),
  `gold` (dark bronze, gold accent), `crimson` (dark maroon, red accent),
  `onyx` (near-black, monochrome silver accent). Each defines the full
  65-key surface (surfaces, strokes, text, gradients, slider/toggle/field
  styling); omitted keys inherit from the `default` clone in
  `themes/init.luau`.
- **`frost` redesigned (kept, not removed):** was a near-white light theme
  (WindowSurface 250,252,253) — too bright. Rebuilt as a dark "arctic night"
  palette: deep navy surfaces (16,21,28), bright ice-blue accent
  (86,197,235), ice tab-stroke gradient. Same key set, same theme name, so
  persisted `theme = "frost"` picks up the new look automatically.
- Theme registration updated in both places: the settings-UI theme table +
  dropdown options in `components/window.luau` (now 10 entries) and the
  persisted-theme whitelist in `utilities/persistenceSettings.luau`.
- All other themes (`default`, `amethyst`, `cobalt`, `ember`, `rose`)
  unchanged. Bundle regenerated (99 modules).

## 2026-09-11 — Changelog element, settings rebuild, multi-tab example (`d1339ec`)

- **New element — `Tab:CreateChangelog`:** scrollable release history with
  `+` (added) / `-` (removed) / `~` (changed) symbols in green/red/amber,
  entry fade-in, and `Set` / `Refresh` / `Add(entry, prepend?)` / `Clear`.
  Types added: `ChangelogEntry`, `ChangelogChange`, `ChangelogProps`,
  `Changelog`.
- **Built-in settings rebuilt:** the v1.1 settings card +
  `Window:AddSettingsTab` sub-tab API is retired. The window now builds six
  settings tabs (`Window:_buildSettingsUI`): **General** (keybind, cursor,
  welcome toast), **Appearance** (theme + Bar Layout pickers with popup
  confirm, profile, window position), **Behavior** (duplicate-window guard),
  **Performance** (haptics), **Persistence** (saved-config Save/Load/Delete,
  only when `configuration` is passed), **About**. The topbar gear action
  toggles a settings mode that shows only settings tabs; the `activeSubTab`
  registry key is retained and still persisted for compatibility.
- **`layouts/` folder:** per-mode bar-layout builders (`Topbar`, `Sidebar`,
  `SidebarCollapsed`) extracted from the window; `utilities/layouts.luau`
  dispatches (`get` / `implementation` / `railWidthFor`).
- **`CreateWindow` props extended:** `showName`, `showIcon`,
  `showIconOnly` (minimised capsule), `fallbackFont`, `translator`
  (PascalCase aliases accepted); element props gained `description` and
  `icon` across the board; `Progress` gained `steps` / `text` / `format` /
  `showValue` / `indeterminate` props and `Get` / `GetPercentage` /
  `Remove`; `Toast` gained `subtitleAbove` / `avatar` / `minWidth`;
  `Popup` gained `subtitle` / `icon` / `dismissable`; `Console` gained
  `Copy`; `Tag` gained `Set` / `SetColor` / `SetText` / `SetIcon` /
  `Remove`.
- **New window runtime helpers:** `Close()` (animated close → `Unload`,
  wired to the topbar Close action with a confirm popup), `Create`
  (instance factory with theme/locale binding), `Connect` / `ConnectFor` /
  `Disconnect` / `DisconnectMany`, `DestroySubtree` / `DestroySubtrees`,
  `CreateGlow`, `CreateHoverOverlay`, `StyleElementBody` /
  `StyleElementPanel`, `SaveSettings` / `LoadSettings`, `SetProfile`.
- **Entrypoint:** active-window / anti-duplicate guard now also backed by a
  `getgenv()`-backed global store (`__ASTRA_ACTIVE_WINDOW_V1`); in secure
  mode `CreateWindow` preloads window images (failure notification) and
  swaps in the brand fonts.
- **Icon resolution:** pack entries are repo-relative PNG paths under
  `assets/icons/<pack>-pack/`; `icons/init.luau` maps them onto the repo's
  raw-GitHub base URL at resolve time, honours an executor
  `getcustomasset` override, and passes numeric asset ids through.
- **Persistence facade:** new `utilities/persistence.luau` consolidates the
  config + settings persistence surface.
- **Example rewritten:** `example.client.luau` loads the bundle via
  `game:HttpGet` + `loadstring` and builds a 20-tab window (Home, Controls,
  Appearance, Information, Changelog, Updates + 15 labelled test tabs)
  exercising tags, every element, groups, and the new Changelog element.
- Bundle regenerated from the modular tree (includes `layouts/` and
  `elements/changelog.luau`).

## 2026-09-06 — Settings card ColorSequence crash fix (`2ecd628`)

Opening the Settings tab crashed the window:
`Unable to assign property BackgroundColor3. Color3 expected, got ColorSequence`.

- **Cause:** `_buildSettingsCard` in `components/window.luau` themed the card
  with `BackgroundColor3 = "WindowColor"` — but `WindowColor` is a
  `ColorSequence` (a gradient), and `BackgroundColor3` only accepts a `Color3`.
- **Fix:** new `CardSurface` theme key (`Color3`) added to all six built-in
  themes (`default`, `amethyst`, `cobalt`, `ember`, `frost`, `rose`), matching
  each theme's element base color. The card now uses
  `BackgroundColor3 = "CardSurface"`. Custom theme tables inherit the key from
  `default` via `themes/init.luau`'s clone.
- Bundle regenerated and `luau-compile` verified on all changed files.

## 2026-09-06 — Luau minification (`7fa2d09`)

All 93 modular `.luau` sources + regenerated bundle minified:

- Stripped all comments and collapsed whitespace.
- Renamed locals safely inside function bodies (AST-driven, public API names,
  Roblox property keys, and icon-name strings untouched).
- Icon packs: data-only, no renames.
- `version-1.luau`: regenerated from minified sources (1,974,324 → 1,912,889
  bytes; the remaining comment lines are the Wax generator's own preamble and
  the required `WAX BUNDLED DATA BELOW` marker).
- Total: 93 files changed, −124 KB. Verified with `luau-compile`,
  `scripts/check_requires.py`, `scripts/check_instance_fields.py`.
- Minification tooling lives in `tools/minify/` (not bundled).

## 2026-09-05 — v1.1 patch set (`e779bed`)

Four bug fixes + one feature, public API unchanged:

- **Fix 1 — profile avatar not rendering:** `setProfileShown` no longer
  early-returns on `profile.Visible` (uses the `shown` argument), skips nil
  targets, and falls back to a themed plate circle when the avatar URI never
  resolves (tracked in the weak-keyed `avatarReady` side table). Empty avatar
  callback assigns a transparent placeholder instead of a broken image.
  Defensive `localPlayer` late-resolution hook in `Window.new` (2s-capped
  RenderStepped poll).
- **Fix 2 — profile layout unification:** top-mode profile is right-anchored
  in the topbar; `profileSubtitle` created in all three layout branches;
  `reflowProfile`/`applyWidth` handle the unified structure.
- **Fix 3 — settings card + rail race:** new `SettingsCard` overlay
  (`Window:_buildSettingsCard`, element-styled via `StyleElementBody`); rail
  visibility restored independently of `elements.Visible` so it can't get
  stuck hidden.
- **Fix 4 — settings sub-tabs:** new public `Window:AddSettingsTab({ name,
  icon })` builds compact sub-tabs inside the settings card; content delegates
  to the normal element registration/persistence pipeline; `activeSubTab` is
  persisted (registry, defaults, appearance validation, JSON persistence).
- **Fix 5 (SettingsManager wiring) intentionally deferred.**

See `ARCHITECTURE.md` for the full pre-v1.1 modular-refactor history.
