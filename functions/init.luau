
local a1 = require(script.textMetrics)
local a2 = require(script.colors)
local a3 = require(script.flagNames)

local a4 = {}

a4.textWidth = a1.textWidth
a4.textHeight = a1.textHeight
a4.deriveFlagFromName = a3.deriveFlagFromName
a4.contrastColor = a2.contrastColor
a4.toColorSequence = a2.toColorSequence
a4.contrastText = a2.contrastText

return a4
