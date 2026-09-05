# Astra Modular Architecture

This document is the record of the Phase 1 audit, the migration map used for the
refactor, the dependency rules, and the validation performed. Source modules are
the source of truth; `version-1.luau` is a generated distribution artifact
(Phase 11) and must not be hand-edited.

## Phase 1 audit summary

Audit covered every existing `.luau` file (68 source modules + entrypoint +
example + generated bundle). Findings:

| File | Responsibility | Problem | Action |
|---|---|---|---|
| `library_entrypoint.luau` | public API, exports, window lifecycle, anti-duplicate | mixes core singleton logic with API surface | KEEP (root) + delegate internals to `core/` and `settings/` |
| `Types.luau` | all public types | fine at root | KEEP (root) |
| `example.client.luau` | usage example | fine at root | KEEP (root) |
| `ui/window.luau` (2875 ln) | window class **plus** theme resolution, reveal/hide engine, element styling helpers, lock engine, connection lifecycle | doing many unrelated jobs | SPLIT: window → `components/window.luau`; theme resolution → `themes/init.luau`; reveal/styling/lock/connection helpers stay as Window methods (tightly coupled, single consumer graph) |
| `ui/action, chrome, drag, search, sidebar, tabSelector, descriptor` | window furniture | belong with window | MOVE → `components/` |
| `ui/button … text` (19 files) | elements | fine | MOVE → `elements/` |
| `ui/notification, toast, popup` | window-level overlays | belong with window | MOVE → `components/` |
| `utilities/icons.luau` (10625 ln) | 6 icon packs + resolver | **the entire catalog loads eagerly** at startup via `constants`/`window` requires | SPLIT → `icons/` one module per pack, lazy-loaded and cached (Phase 6) |
| `utilities/image.luau` | image loading/assignment | UI-adjacent service | MOVE → `images/` (Phase 7) |
| `utilities/imageCache.luau` | disk/remote cache | duplicates cache layer concept | MOVE → `cache/imageCache.luau` |
| `utilities/windowIcons.luau` | built-in icon registry | images domain | MOVE → `images/windowIcons.luau` |
| `utilities/persistence*.luau` (5 files) | config + settings persistence | settings domain | settings split → `settings/persistence.luau`; config split stays in `utilities/` (it is window-config, not settings); shared atomic write stays in `utilities/persistenceWrite.luau` |
| `utilities/variables.luau` | runtime singletons (services, fs manager, font manager) | shared state | MERGE into `core/state.luau` |
| `utilities/runtime.luau` | service singletons | shared state | MERGE into `core/state.luau` |
| `utilities/constants.luau` | static constants | fine as constants | MOVE → `utilities/constants.luau` (KEEP, window icon refs come from `images/windowIcons`) |
| `utilities/functions.luau` | re-export shim | thin wrapper | SPLIT → `functions/` real modules; shim retained for API compat (Phase 8) |
| `utilities/colors.luau`, `textMetrics.luau`, `flagNames.luau` | generic helpers | fine | MOVE → `functions/` |
| `utilities/locale.luau`, `log.luau`, `path.luau`, `enums.luau`, `ordering.luau`, `moveable.luau`, `lockable.luau`, `layouts.luau`, `windowSizing.luau`, `HapticEngine.luau`, `odometer.luau` | small focused helpers | fine | KEEP in `utilities/` |
| `utilities/filesystem.luau`, `filesystemManager.luau`, `assetResolver.luau`, `network.luau`, `services.luau` | platform/filesystem layer | fine | KEEP in `utilities/` |
| `themes/*.luau` (6) | theme tables | fine | KEEP + add `themes/init.luau` (resolution engine extracted from window) |
| `version-1.luau` | generated Wax bundle | artifact | REGENERATE with project's generator (Phase 11) |

Dependency direction (Phase 2), enforced and verified:

```
library_entrypoint → core → components → elements → functions/cache/settings/utilities
```

No module outside `core/` requires `core/state` upward; `functions/`, `cache/`,
`images/`, `icons/` never require UI modules. The two-way edges that existed
(window ⇄ tab ⇄ group ⇄ element) are **preserved as-is** because they are the
existing public behavior (elements require their tab/window instances at
runtime, modules resolve peers lazily through `require(script.Parent[name])`).

## Target structure

See repository tree. `core/init.luau` is the small core service entrypoint,
`core/state.luau` holds shared runtime state, `core/registry.luau` the internal
module registry, `core/loader.luau` controlled lazy loading. `settings/` is an
internal configuration system (registry → defaults → manager → persistence)
consumed by the window UI; it is not a UI element itself.

## Phase 6 icon architecture

- `icons/init.luau` — public API surface (`get`, `resolve`, `getByPack`,
  `list`, `packs`, `count`, `isPack`, pack name constants) — API-compatible
  with the old `utilities/icons.luau`.
- `icons/lucide.luau`, `icons/material.luau`, … — one module per pack, each a
  pure data table. Packs are required lazily: the catalog loads on first
  lookup for that pack, then stays cached (module-level require cache).
- No icon data is loaded during Astra startup unless a window actually
  resolves an icon from a pack. Window chrome uses asset IDs from
  `images/windowIcons.luau` and never touches the packs.
- `Icons.lucide` etc. remain accessible through lazy metatables so existing
  direct table access (`Astra.Icons.lucide`) keeps working, but each access
  loads only that pack.

## Phase 10 startup notes

Eager startup graph before refactor: entrypoint + Types + variables(+runtime,
services, filesystemManager, assetResolver, fontManager, constants,
windowIcons) + image(+imageCache) + locale + constants + icons (all 10.6k
lines) + persistenceSettings (+filesystem, paths, write, enums).

After refactor: identical behavior, but `icons/` is out of the eager graph —
icon packs load only on first pack lookup. `themes/init.luau` only requires
`default.luau` eagerly; other themes load on demand by name. Everything else
keeps its original load timing. No waits, safety checks, or features were
removed.

## Validation performed

1. `luau` syntax compile of every module (63/63 pass) — see validation notes.
2. `require()` path audit: every require resolves to an existing file.
3. Cycle check over the module graph.
4. Public API preserved: `library_entrypoint` exports unchanged, element
   classes keep `new/_setShown/_refreshTheme/...` contracts, `astra.Icons`
   surface unchanged, persistence + settings behavior unchanged.
5. Bundle regenerated from source and verified: module set complete, no
   duplicate implementations, standalone loader contract intact.
6. Bundle equivalence audit (`scripts/verify_bundle_equivalence.py` +
   `scripts/triage_bundle_diff.py`): every module body from the pre-refactor
   monolith is accounted for in the regenerated bundle. 58/69 bodies are
   byte-identical after require-path canonicalization; the remaining 11 are
   the documented intentional transformations:
   - entrypoint (old[2]): core/settings service wiring, settings-backed
     antiWindowDuplicate read, `astra.Core`/`astra.Settings` additions
   - chrome (old[15]): hide-transition generation guard (pre-existing fix,
     carried into components/chrome.luau)
   - sidebar (old[30]): profile rebuild generation guard + collapsedSidebar
     handling (pre-existing fix from 6db1e08, carried over)
   - window (old[40]): theme helpers delegate to `themes/init.luau`
   - functions shim (old[51]): comment + real-module requires
   - icons split (old[52]): catalog split into per-pack data modules
   - layout defaults (old[55]): `profileHeight = 48` constant addition
   - log (old[58]): inlined secure-mode source to keep `log` a leaf module
   - runtime/variables merge (old[69], old[72]): superseded by `core/state.luau`
   - vendored wax (old[74]): formatting/line-offset realignment only

## Runtime fix: avatar generation marker

The 6db1e08 sidebar fix stored its per-build generation marker directly on the
avatar ImageLabel (`window.profileAvatar._profileGeneration = ...`). Roblox
instances reject unknown members, so the first bundle that shipped that code
crashed in CreateWindow with "_profileGeneration is not a valid member of
ImageLabel" (the pre-refactor bundle predated that commit, which is why it
never surfaced there). The marker now lives in a weak-keyed side table
(`avatarGenerations`) in components/sidebar.luau; the stale-callback guard
behavior is unchanged. `scripts/check_instance_fields.py` lints this entire
bug class (custom-field writes on values created via `:Create` /
`Instance.new`).

## Rojo/Wax init-folder semantics (late fix)

A folder with an `init.luau` file syncs as a single ModuleScript — the init
file IS the folder's module, and sibling files become its children. Three
consequences were caught and fixed during final verification:

1. Init files (`core`, `settings`, `cache`, `functions`, `images`, `icons`,
   `themes`) required siblings via `script.Parent.<name>`; corrected to
   `script.<name>` (and `themes/init.luau` now uses `local themesFolder = script`).
2. `components/window.luau` held the themes Instance directly instead of
   requiring the module; corrected to `require(script.Parent.Parent.themes)`.
3. The bundle generator (`scripts/generate_bundle.js`) emitted init-folders as
   Folders with a phantom `init` child; it now emits them as ModuleScripts
   whose closure is the init file, with real siblings as children.

A migration typo (`utility.Parent.Parent.core.state`, one `.Parent` too many,
in 21 component/element files) was also corrected to
`utility.Parent.core.state` and both validation scripts
(`scripts/check_requires.py`, `scripts/eager_graph.py`) were upgraded to model
alias chains and init-file `script` anchoring, so this class of bug can no
longer pass the audit.

## Bundle regeneration (final)

`node scripts/generate_bundle.js` rebuilt `version-1.luau` from the modular
tree: 91 module closures + 5 folders (assets, components, elements,
utilities, root) = 96 refIds with no gaps, LineOffsets aligned 1:1 with
closures, zero occurrences of the pre-fix require patterns, and the standalone
loader contract (`return LoadScript(MainModule)`) intact.
