-- ===== input field assertions: the corner it wears and the width it takes ====
-- [[Runs the real Astra bundle (loaded as global `Astra` above) against the]]
-- [[mini Roblox environment from sidebar_sizing_stubs.luau.]]
--
-- Expected behavior under test:
--   * F1 the input's field box rounds with the theme's ElementCornerRadius —
--        the same token the card it sits in, the profile containers and every
--        other surface read — instead of a capsule (UDim.new(1, 0)) of its own,
--   * F2 that roundness is a theme binding, so a theme switch re-states the
--        field's corner exactly like the card's own corner,
--   * F3 the field and its card therefore always share one corner family,
--   * S1 an empty field sizes its box from the placeholder it shows, and the
--        title row keeps clear of whatever width that gives,
--   * S2 a short hint sits at the 70px floor,
--   * S3 typed text takes over from the placeholder,
--   * S4 clearing the field hands the width back to the placeholder,
--   * S5 SetPlaceholder retypes the hint and re-measures the box,
--   * S6 a hint longer than the ceiling stops at 220px,
--   * S7 a locale switch re-types the hint and re-measures the box,
--   * S8 and the ceiling is responsive: on a narrow page a theme refresh
--        re-measures the field against the page's own share of the width.

local function expect(cond, message)
	if not cond then
		error("INPUT FIELD FAIL: " .. tostring(message), 0)
	end
end

local function eq(actual, wanted, message)
	if actual ~= wanted then
		error(
			"INPUT FIELD FAIL: " .. message .. " (got " .. tostring(actual) .. ", want " .. tostring(wanted) .. ")",
			0
		)
	end
end

local window = Astra:CreateWindow({ name = "Input Field Test" })
TestPump(0.6)
local tab = window:CreateTab({ name = "Controls" })
local input = tab:CreateInput({ name = "Display name", placeholder = "Enter a name" })
TestPump(0.3)

local function cornerOf(frame)
	for _, child in frame:GetChildren() do
		if child.ClassName == "UICorner" then
			return child
		end
	end
	return nil
end

-- ===== F1: the field box wears the element corner radius ===================

local corner = cornerOf(input.box)
expect(corner ~= nil, "F1 the field box carries a corner")
eq(corner.CornerRadius.Scale, 0, "F1 the field corner is a pixel radius, not a capsule scale")
eq(
	tostring(corner.CornerRadius.Offset),
	tostring(window.theme.ElementCornerRadius.Offset),
	"F1 the field wears the element corner radius"
)

-- ===== F2: the corner is a theme binding, not a baked number ===============

window:ChangeTheme("frost")
TestPump(0.3)
eq(
	tostring(corner.CornerRadius.Offset),
	tostring(window.theme.ElementCornerRadius.Offset),
	"F2 a theme switch re-states the field corner"
)
window:ChangeTheme("default")
TestPump(0.3)
eq(
	tostring(corner.CornerRadius.Offset),
	tostring(window.theme.ElementCornerRadius.Offset),
	"F2 ... and switching back restores it"
)

-- ===== F3: field and card share one corner family ==========================

local cardCorner = cornerOf(input.main)
expect(cardCorner ~= nil, "F3 the card carries its own corner")
eq(
	tostring(cardCorner.CornerRadius.Offset),
	tostring(corner.CornerRadius.Offset),
	"F3 field and card round with the same token"
)

-- ===== the width recipe ====================================================
-- [[The harness measures text deterministically (0.6 * point size per
-- [[character), so the expected box width is the element's own recipe computed
-- [[from those same numbers: the measured text plus the box's 30px of padding,
-- [[clamped between the 70px floor and the 220px ceiling.]]
local function expectedWidth(text)
	return math.clamp(math.ceil(#text * 15 * 0.6) + 30, 70, 220)
end

local function boxWidth(element)
	return element.box.Size.X.Offset
end

-- ===== S1: an empty field sizes from its placeholder =======================

eq(boxWidth(input), expectedWidth("Enter a name"), "S1 an empty field takes its placeholder's width")
eq(
	input.container.Size.X.Offset,
	-(expectedWidth("Enter a name") + 35),
	"S1 the title row keeps clear of the box it just sized"
)

-- ===== S2: a short hint sits at the floor ==================================

local tiny = tab:CreateInput({ name = "Tiny", placeholder = "hi" })
TestPump(0.3)
eq(boxWidth(tiny), 70, "S2 a short hint sits at the 70px floor")

-- ===== S3: typed text takes over ===========================================

local typed = "a much longer typed value"
input:Set(typed)
TestPump(0.4)
eq(boxWidth(input), expectedWidth(typed), "S3 a typed field takes the width of what is typed")
expect(
	boxWidth(input) > expectedWidth("Enter a name"),
	"S3 ... which is wider than the placeholder it replaced"
)

-- ===== S4: clearing hands the width back to the placeholder ================

input:Set("")
TestPump(0.4)
eq(boxWidth(input), expectedWidth("Enter a name"), "S4 an emptied field measures its placeholder again")

-- ===== S5: SetPlaceholder re-measures ======================================

local longerHint = "a considerably longer hint than before"
tiny:SetPlaceholder(longerHint)
TestPump(0.4)
eq(tiny.placeholder, longerHint, "S5 SetPlaceholder retypes the element's own hint")
eq(tiny.input.PlaceholderText, longerHint, "S5 ... and the field shows it")
eq(boxWidth(tiny), expectedWidth(longerHint), "S5 ... and the empty field grows to fit it")
tiny:SetPlaceholder("hi")
TestPump(0.4)
eq(boxWidth(tiny), 70, "S5 a shorter hint takes the box back to the floor")

-- ===== S6: the ceiling binds ===============================================

local longHint = string.rep("word ", 30)
local long = tab:CreateInput({ name = "Long", placeholder = longHint })
TestPump(0.3)
expect(#longHint > 40, "S6 the fixture hint is longer than the ceiling can show")
eq(boxWidth(long), 220, "S6 a long hint stops at the 220px ceiling")
long:Set(longHint)
TestPump(0.4)
eq(boxWidth(long), 220, "S6 ... and typing it stays at the ceiling")

-- ===== S7: a locale switch re-types and re-measures ========================

local translated = "Escribe un nombre mucho mas largo"
window:RegisterTranslations({ es = { ["Enter a name"] = translated } })
window:SetLocale("es")
TestPump(0.4)
eq(input.input.PlaceholderText, translated, "S7 the empty field shows the translated hint")
eq(boxWidth(input), expectedWidth(translated), "S7 ... and re-measures for the new language")
window:SetLocale("en")
TestPump(0.4)
eq(input.input.PlaceholderText, "Enter a name", "S7 switching back retypes the hint")
eq(boxWidth(input), expectedWidth("Enter a name"), "S7 ... and the box follows it home")

-- ===== S8: the ceiling is responsive =======================================

eq(boxWidth(long), 220, "S8 the desktop page leaves the field at its own ceiling")
local desktopPage = tab.tabPage.AbsoluteSize.X
TestViewport.set(360, 640)
TestPump(0.6)
local narrowPage = tab.tabPage.AbsoluteSize.X
expect(narrowPage < desktopPage, "S8 the fixture page actually got narrower")
-- [[A theme refresh is one of the re-measure triggers, so it is what picks the
-- [[new page width up here (the harness does not fire AbsoluteSize signals).]]
window:ChangeTheme("default")
TestPump(0.6)
local capped = math.max(70, math.min(220, narrowPage * 0.55))
expect(
	math.abs(boxWidth(long) - capped) < 0.51,
	"S8 a narrow page caps the field at 55% of it (got "
		.. tostring(boxWidth(long)) .. ", want " .. tostring(capped) .. ")"
)
expect(boxWidth(long) < 220, "S8 ... which is below the desktop ceiling")
eq(
	long.container.Size.X.Offset,
	-(boxWidth(long) + 35),
	"S8 the title row keeps clear of the capped box"
)
TestViewport.set(1920, 1080)
TestPump(0.4)
window:ChangeTheme("default")
TestPump(0.6)
eq(boxWidth(long), 220, "S8 widening the page gives the field its ceiling back")

window:Unload()
TestPump(0.2)

print("INPUT FIELD: all assertions passed")
