
local a1 = {}

local a2 = require(script.Parent.Parent.functions.textMetrics)
local a3 = require(script.Parent.Parent.functions.colors)
local a4 = require(script.Parent.Parent.functions.flagNames)

a1.textWidth = a2.textWidth
a1.textHeight = a2.textHeight
a1.deriveFlagFromName = a4.deriveFlagFromName
a1.contrastColor = a3.contrastColor
a1.toColorSequence = a3.toColorSequence
a1.contrastText = a3.contrastText

return a1
