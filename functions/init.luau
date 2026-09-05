-- Generic helper entrypoint (functions/init.luau).
--
-- Preserves the old utilities/functions.luau re-export surface
-- (textWidth/textHeight/deriveFlagFromName/contrastColor/toColorSequence/
-- contrastText) over the real modules in functions/. UI-independent: nothing
-- here may require elements, components, or core state.

-- This file IS the `functions` ModuleScript (init.luau semantics).
local textMetrics = require(script.textMetrics)
local colors = require(script.colors)
local flags = require(script.flagNames)

local functions = {}

functions.textWidth = textMetrics.textWidth
functions.textHeight = textMetrics.textHeight
functions.deriveFlagFromName = flags.deriveFlagFromName
functions.contrastColor = colors.contrastColor
functions.toColorSequence = colors.toColorSequence
functions.contrastText = colors.contrastText

return functions
