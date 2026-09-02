# Astra Runtime Performance Audit

## Scope and baseline

The audit covered all 68 Luau files under `src/`, plus `src/init.luau`, `src/types.luau`, `example.client.luau`, and `version-1.luau`. Baseline syntax compilation passed for all 68 source files, the example, and the bundle. The working tree was clean before optimization.

| Measurement | Baseline |
|---|---:|
| Source Luau files | 68 |
| Source files compiling | 68/68 |
| `task.wait` occurrences across source/example/bundle | 46 |
| `task.spawn` occurrences across source/example/bundle | 34 |
| `task.defer` occurrences across source/example/bundle | 14 |
| `:Connect` occurrences across source/example/bundle | 182 |
| Heartbeat/RenderStepped references in source | 9 |
| TweenService creation calls in source | 135 |

## Ranked confirmed bottlenecks

### P0: lifecycle and runaway work

The window already owns a central connection list and disconnects it during `Unload`, which is a strong foundation. The remaining risk is owner-level connection cleanup and stale asynchronous callbacks in components that create their own drag connections or delayed tasks. Optimization must strengthen ownership checks and avoid work after the window/component is unloaded without changing callback behavior.

### P1: frame and input paths

`Window:_bindTopbarDrag` uses a `RenderStepped` connection, but the callback returns immediately unless dragging is active. This is behaviorally correct, yet it still executes every rendered frame for every live window. The viewport reconciliation uses `Heartbeat` with a two-second interval and is already throttled; it is not a primary hotspot. Dragging and scrolling should avoid repeated property writes and redundant position/layout updates while active.

### P1: animation and tween churn

The source contains 135 TweenService creation sites across the full artifact surface. Hover, reveal, notification, toast, and repeated selection paths construct TweenInfo and tweens frequently. Safe optimization targets are repeated identical target assignments, repeated visual state application, and cancellation of obsolete animation work when a component/window is unloaded. Animation sequencing waits are intentional and should not be blindly removed.

### P1: repeated layout and theme propagation

Absolute-size callbacks and tab/page updates can reapply layout during intermediate animation states. Theme propagation stores per-instance properties, but updates should skip unchanged values before assigning or creating follow-up work. This is especially relevant on mobile where layout recalculation and object property churn are expensive.

### P2: scheduler and initialization work

Several `task.spawn` calls wrap callback execution or animation startup. These are not automatically wrong: callback isolation and non-blocking animation startup are part of behavior. Candidates for removal are only wrappers where direct execution is equivalent and no yielding or error isolation is needed. Image preloading and configuration persistence are intentionally asynchronous.

### P2: allocations and object lookup

Repeated temporary tables, TweenInfo values, and service/property lookups occur in hot UI paths. Shared immutable TweenInfo values and local references can reduce allocation pressure, but caching must not retain destroyed instances or alter theme-dependent behavior.

### P3: micro-optimizations

Small string/table allocations and compact one-off lookups exist but should not be changed until P0/P1 behavior and lifecycle paths are verified. No readability-reducing compression is justified.

## Safe implementation targets

1. Add idempotent connection ownership cleanup for component-level lists while preserving the window-owned cleanup path.
2. Make drag and visual update paths skip redundant writes when the target state is unchanged.
3. Guard delayed animation/callback work with unloaded/destroyed checks already represented by component state.
4. Skip theme/property assignments when the resolved value is unchanged.
5. Reuse stable TweenInfo constants only where duration/easing are identical and no mutable state is involved.
6. Keep intentional waits, callback isolation, preload concurrency, and public APIs unchanged.

## Implemented source optimizations

The following changes were made first in `src/components/window.luau`:

| Area | Change | Runtime rationale |
|---|---|---|
| Theme propagation | Read the current instance property and `continue` when it already equals the resolved theme value. | Prevents redundant property assignments and avoids creating/playing a TweenService tween for unchanged numeric/color properties during repeated theme refreshes. |
| Theme tween setup | Reuse one immutable `themeTweenInfo` value for the fixed 0.5-second Quint/Out theme animation. | Removes repeated TweenInfo allocations in the theme loop without changing duration, easing, or visual behavior. |
| Reveal/hide helper | Compare all requested properties first and return when the target state is already applied. | Avoids duplicate reveal/hide tweens and writes when lifecycle or selection paths request the same visual state repeatedly. |
| Topbar drag | Compute the target position and skip the Position assignment and drag-bar update if it is unchanged. | Keeps the RenderStepped callback behavior intact while reducing per-frame property writes and downstream layout invalidation, particularly on lower-end devices. |

The equivalent logic was then synchronized into `version-1.luau`.

## Post-change validation

The official Luau compiler passed **70/70** checked files: all 68 source modules, `example.client.luau`, and `version-1.luau`. `git diff --check` also passed. The example remains unchanged and therefore preserves the existing public API exercise surface.

Static inspection confirms the optimized paths retain the original event connections, callback order, tween parameters, settings behavior, and public method signatures. No waits, spawns, defers, features, or public API methods were removed. The RenderStepped connection remains window-owned and is disconnected through the existing window lifecycle cleanup.

## Measurement interpretation

No Roblox runtime is available in the sandbox, so frame-time and device-memory measurements cannot be produced here. The measurable source-level reduction is conditional: repeated theme/reveal calls now do zero property/tween work when state is unchanged, and active drag frames with unchanged target coordinates skip two property writes. TweenInfo allocation in `ChangeTheme` is reduced from one per animated property to one per Window module. Roblox Studio MicroProfiler and Lua heap measurements should be collected on a representative mobile device to quantify the remaining runtime delta.

## Remaining issues and tradeoffs

The library still has intentional RenderStepped/Heartbeat callbacks and many animation sites. They were not removed speculatively because they encode drag, viewport, or visual behavior. The no-op comparisons add a small property-read loop to each reveal/theme request; this is expected to be favorable specifically when repeated requests are common, and it preserves correctness when values differ. Further optimization should be guided by Roblox MicroProfiler captures rather than static counts alone.
