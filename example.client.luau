-- [[Astra Input example.]]
-- [[Input is the library's only element. Every demo below is the same element]]
-- [[with a different string in it, because that string is what sizes the field:]]
-- [[while the field is empty the box measures its placeholder, and as soon as]]
-- [[something is typed it measures the typed text instead. Short/medium/long]]
-- [[hints therefore render as short/medium/long boxes, up to a ceiling that]]
-- [[follows the page width (55% of it, never past 220px, never under 70px).]]

local bundleSource = game:HttpGet("https://raw.githubusercontent.com/Kira762/astra-version-1/main/version-1.luau")
local compile = loadstring or load
assert(type(compile) == "function", "[Astra] This executor does not provide loadstring/load.")
local bundleLoader, compileError = compile(bundleSource)
assert(type(bundleLoader) == "function", "[Astra] Bundle compilation failed: " .. tostring(compileError))
local Astra = bundleLoader()

assert(
    type(Astra) == "table" and type(Astra.CreateWindow) == "function",
    "[Astra] Failed to load Astra bundle."
)

local window = Astra:CreateWindow({
    name = "Astra Input Test",
    subtitle = "One element, sized by its own text",
    configuration = {
        fileName = "Astra-Example",
        customFolder = "AstraExamples",
        autoSave = true,
        autoLoad = true,
    },
})

local inputs = window:CreateTab({ name = "Inputs", icon = "text-cursor-input" })

-- ===== 1. Empty fields: the placeholder sets the width =====================

inputs:CreateInput({
    name = "Short placeholder",
    placeholder = "Name",
    description = "A two-word hint measures narrow, so the box sits near its 70px floor.",
})

inputs:CreateInput({
    name = "Medium placeholder",
    placeholder = "Enter your display name",
    description = "A sentence-long hint grows the box to fit it.",
})

inputs:CreateInput({
    name = "Long placeholder",
    placeholder = "Type the full name of the loadout you want to apply to this slot",
    description = "A hint longer than the ceiling stops at it instead of pushing the title off the card.",
})

inputs:CreateInput({
    name = "No placeholder",
    description = "With nothing to measure, the box stays at its floor until something is typed.",
})

-- ===== 2. Typed text takes over from the placeholder =======================

inputs:CreateInput({
    name = "Typed text",
    placeholder = "hi",
    value = "a value much wider than its hint",
    description = "The hint is short but the value is not: a non-empty field measures what is typed.",
    callback = function(value)
        window:Toast({ title = "Typed text", subtitle = tostring(value) })
    end,
})

inputs:CreateInput({
    name = "Numeric",
    placeholder = "0.5",
    numeric = true,
    clearOnFocus = true,
    description = "Digits, minus and the 1.5^-3 exponent form; anything else is filtered as you type.",
})

-- ===== 3. SetPlaceholder re-measures an empty field at runtime =============

local retyped = inputs:CreateInput({
    name = "Retyped hint",
    placeholder = "Short",
    description = "Its box follows whatever the field below commits, through SetPlaceholder.",
})

inputs:CreateInput({
    name = "Hint for the field above",
    placeholder = "Type a new hint",
    description = "Commit text here and the field above retypes its placeholder and re-sizes.",
    callback = function(value)
        retyped:SetPlaceholder(value)
    end,
})

-- ===== 4. Flags, persistence and the ordinary props ========================

inputs:CreateInput({
    name = "Saved nickname",
    icon = "user-round",
    flag = "nickname",
    placeholder = "Nickname",
    description = "Flagged, so it is written to the configuration and restored on load.",
    callback = function(value)
        window:Notify({ title = "Nickname", content = tostring(value) })
    end,
})

local locked = inputs:CreateInput({
    name = "Locked field",
    placeholder = "Read only while locked",
    description = "Lock shows its reason on the description line and refuses commits.",
})
locked:Lock("Demonstrating the lockable mixin")

-- [[Select the only user tab explicitly so the example is deterministic.]]
inputs:Select()
