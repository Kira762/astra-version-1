# Changelog

All notable changes to Astra v1. Dates use 2026.

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
