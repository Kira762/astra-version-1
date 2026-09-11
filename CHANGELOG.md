# Changelog

All notable changes to Astra v1. Dates use 2026.

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
