-- Compatibility shim for the old utilities/functions.luau surface.
-- The real modules live in functions/; both paths stay importable.

local functions = {}

local textMetrics = require(script.Parent.Parent.functions.textMetrics)
local colors = require(script.Parent.Parent.functions.colors)
local flags = require(script.Parent.Parent.functions.flagNames)

functions.textWidth = textMetrics.textWidth
functions.textHeight = textMetrics.textHeight
functions.deriveFlagFromName = flags.deriveFlagFromName
functions.contrastColor = colors.contrastColor
functions.toColorSequence = colors.toColorSequence
functions.contrastText = colors.contrastText

return functions
