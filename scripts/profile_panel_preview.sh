#!/bin/sh
# Offline visual preview of the profile card: builds the real card from the
# bundle under the mini Roblox stubs, dumps it as JSON, then (when Pillow is
# available) renders assets/profile-panel-preview.png and
# assets/profile-panel-preview-revealed.png so the card can be reviewed
# without launching Roblox.
#
#   sh scripts/profile_panel_preview.sh
#
# Regenerate the bundle first if the source changed: node scripts/generate_bundle.js
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUNDLE="$ROOT/version-1.luau"

if [ ! -f "$BUNDLE" ]; then
	echo "bundle missing: $BUNDLE" >&2
	exit 1
fi

LUAU_BIN="$(command -v luau || true)"
if [ -z "$LUAU_BIN" ]; then
	for candidate in /tmp/luau /usr/local/bin/luau; do
		if [ -x "$candidate" ]; then
			LUAU_BIN="$candidate"
			break
		fi
	done
fi
if [ -z "$LUAU_BIN" ]; then
	echo "luau CLI not found (looked in PATH, /tmp, /usr/local/bin)" >&2
	exit 2
fi

TMPDIR_LOCAL="${TMPDIR:-/tmp}"
OUT="$TMPDIR_LOCAL/astra_profile_preview_$$.luau"
DUMP="$TMPDIR_LOCAL/astra_profile_preview_$$.json"
trap 'rm -f "$OUT"' EXIT

{
	cat "$ROOT/scripts/sidebar_sizing_stubs.luau"
	echo ""
	echo "Astra = (function()"
	echo ""
	cat "$BUNDLE"
	echo ""
	echo "end)()"
	echo ""
	cat "$ROOT/scripts/profile_panel_preview.luau"
} > "$OUT"

if ! "$LUAU_BIN" "$OUT" > "$DUMP"; then
	echo "PREVIEW DUMP FAILED" >&2
	exit 1
fi

echo "dump written to $DUMP"

if ! command -v python3 > /dev/null; then
	echo "python3 not found; skipping the render" >&2
	exit 0
fi

python3 "$ROOT/scripts/render_profile_panel_preview.py" "$DUMP" "$ROOT/assets" || {
	echo "PREVIEW RENDER FAILED (is Pillow installed? pip install pillow)" >&2
	exit 1
}
