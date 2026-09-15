-- ===== in-card description assertions: the line never covers the element ====
-- [[Runs the real Astra bundle (loaded as global `Astra` above) against the]]
-- [[mini Roblox environment from sidebar_sizing_stubs.luau.]]
--
-- An element created with a `description` renders it inside its own card: a
-- muted 14px line under the title band (one line: 41 -> 61). The card grows by
-- the measured wrapped-line height and the element's own UI keeps the space it
-- always had, so the line can never cover the title row, the field box or the
-- card's edge — the overlap this suite exists to pin. Input is the library's
-- only element, so every case here is an input.
--
-- Expected behavior under test:
--   * D1 the label is a child of the element's own card and the tab page
--        holds nothing but element cards (no standalone row under the card),
--   * D2 the one-line recipe: a 41px card grows to 61px with a 14px, wrapped
--        label at (20, 37), 17px tall,
--   * D3 the title row and the field box keep centring in the base region
--        (20.5, not 30.5),
--   * D4 a wrapped description grows the card line by line (lines*17 + 3),
--   * D5 no described input's line intersects its own title row or field box,
--        and every line stays inside its card,
--   * D6 the field box still sizes from its own text on a described card (the
--        line and the width recipe are independent),
--   * D7 the line reveals with its element at 0.45 transparency,
--   * D8 locking swaps the line for the lock message, unlocking restores the
--        original description,
--   * D9 and an element without a description keeps its card height and
--        carries no label.

local function expect(cond, message)
	if not cond then
		error("INLINE DESCRIPTION FAIL: " .. tostring(message), 0)
	end
end

local function near(actual, wanted, message)
	expect(
		math.abs(actual - wanted) < 0.01,
		message .. " (got " .. tostring(actual) .. ", want " .. tostring(wanted) .. ")"
	)
end

local function eq(actual, wanted, message)
	if actual ~= wanted then
		error(
			"INLINE DESCRIPTION FAIL: " .. message .. " (got " .. tostring(actual) .. ", want " .. tostring(wanted) .. ")",
			0
		)
	end
end

-- [[Rects in the element card's own coordinates, computed the way the engine
-- [[lays them out: every hop resolves Position against the parent's size and
-- [[subtracts the child's anchor. The stub reports AbsoluteSize (scale chains
-- [[resolved) but places anchored children at their raw offset, so the rects
-- [[are walked here rather than read from AbsolutePosition.]]
local function rectIn(instance, ancestor)
	local x, y = 0, 0
	local width, height = 0, 0
	local node = instance
	while node do
		local parent = node.Parent
		if not parent then
			break
		end
		local size = parent.AbsoluteSize
		local position, nodeSize, anchor = node.Position, node.Size, node.AnchorPoint
		local nodeWidth = nodeSize.X.Scale * size.X + nodeSize.X.Offset
		local nodeHeight = nodeSize.Y.Scale * size.Y + nodeSize.Y.Offset
		if node == instance then
			width, height = nodeWidth, nodeHeight
		end
		x = x + position.X.Scale * size.X + position.X.Offset - anchor.X * nodeWidth
		y = y + position.Y.Scale * size.Y + position.Y.Offset - anchor.Y * nodeHeight
		if parent == ancestor then
			break
		end
		node = parent
	end
	return { x = x, y = y, w = width, h = height }
end

local function rectOf(instance, parentSize)
	local position, size, anchor = instance.Position, instance.Size, instance.AnchorPoint
	local width = size.X.Scale * parentSize.X + size.X.Offset
	local height = size.Y.Scale * parentSize.Y + size.Y.Offset
	return {
		x = position.X.Scale * parentSize.X + position.X.Offset - anchor.X * width,
		y = position.Y.Scale * parentSize.Y + position.Y.Offset - anchor.Y * height,
		w = width,
		h = height,
	}
end

local function overlaps(a, b): boolean
	return not (a.x + a.w <= b.x or b.x + b.w <= a.x or a.y + a.h <= b.y or b.y + b.h <= a.y)
end

local function describe(text): string
	return string.format(
		"%.1f..%.1f x %.1f..%.1f",
		text.y, text.y + text.h, text.x, text.x + text.w
	)
end

-- [[The line must clear the element's own UI: the title row and the field box.
-- [[Frames that only paint the card behind the text (backgrounds, hover
-- [[overlays, click targets) are not content and are deliberately not listed.]]
local function assertClearOfContent(element, line, parts)
	for _, part in parts do
		if part then
			local rect = rectIn(part, element.main)
			expect(
				not overlaps(line, rect),
				element.name .. " description line " .. describe(line) .. " overlaps " .. describe(rect)
			)
		end
	end
end

local window = Astra:CreateWindow({ name = "Inline Description Test" })
TestPump(0.6)
local tab = window:CreateTab({ name = "Controls" })
local more = window:CreateTab({ name = "More" })

local input = tab:CreateInput({ name = "Display name", placeholder = "Enter a name", description = "Shown to friends." })
local short = tab:CreateInput({ name = "Short hint", placeholder = "Name", description = "Narrow field." })
local undescribed = tab:CreateInput({ name = "No description", placeholder = "Nothing to measure" })
local wrapped = more:CreateInput({
	name = "Wrapped",
	placeholder = "Type one letter",
	description = "Type one letter. Extra characters are removed automatically, which makes this line wrap.",
})
TestPump(0.6)

-- ===== D1: inside the card, nothing below it ===============================
expect(input.descriptor == nil, "D1 there is no standalone descriptor row any more")
expect(input.descriptionLabel ~= nil, "D1 the element carries an in-card description label")
expect(
	input.descriptionLabel.Parent == input.main,
	"D1 the label is a child of the element's own card"
)
local cards = {
	[input.main] = true,
	[short.main] = true,
	[undescribed.main] = true,
}
for _, child in tab.tabPage:GetChildren() do
	if child:IsA("Frame") then
		expect(cards[child] == true, "D1 the tab page holds nothing but element cards, found " .. tostring(child.Name))
	end
end

-- ===== D2: the one-line recipe ============================================
near(input.main.Size.Y.Offset, 61, "D2 a one-line description grows the 41px card to 61px")
near(input.descriptionLabel.Position.X.Offset, 20, "D2 the line sits on the card's left inset")
near(input.descriptionLabel.Position.Y.Offset, 37, "D2 the line sits under the 41px title band")
near(input.descriptionLabel.Size.Y.Offset, 17, "D2 one line is 17px tall")
eq(input.descriptionLabel.Text, "Shown to friends.", "D2 the line shows the description")
eq(input.descriptionLabel.TextSize, 14, "D2 the line uses the 14px in-UI description size")
eq(input.descriptionLabel.TextWrapped, true, "D2 the line wraps")

-- ===== D3: the title row and the field box keep the base region ============
local inputTitle = rectOf(input.container, input.main.AbsoluteSize)
near(inputTitle.y + inputTitle.h / 2, 20.5, "D3 the title row centres in the 41px base region, not the grown card")
local inputField = rectOf(input.box, input.main.AbsoluteSize)
near(inputField.y + inputField.h / 2, 20.5, "D3 the field box keeps the base region")

-- ===== D4: wrapped descriptions grow line by line =========================
local wrappedLines = wrapped._descriptionLines
expect(wrappedLines >= 2, "D4 the long description measures as more than one line")
near(wrapped.main.Size.Y.Offset, 41 + wrappedLines * 17 + 3, "D4 the card grows by lines*17 + 3")
near(wrapped.descriptionLabel.Size.Y.Offset, wrappedLines * 17, "D4 the label reserves one height per line")

-- ===== D5: the line never covers the element's own UI =====================
local function lineOf(element)
	return rectIn(element.descriptionLabel, element.main)
end

for _, case in {
	{ element = input, parts = { input.container, input.box } },
	{ element = short, parts = { short.container, short.box } },
	{ element = wrapped, parts = { wrapped.container, wrapped.box } },
} do
	local element = case.element
	local line = lineOf(element)
	local card = { x = 0, y = 0, w = element.main.AbsoluteSize.X, h = element.main.AbsoluteSize.Y }
	expect(
		line.y >= 0 and line.y + line.h <= card.h,
		"D5 " .. element.name .. " line " .. describe(line) .. " stays inside its card " .. describe(card)
	)
	assertClearOfContent(element, line, case.parts)
end

-- ===== D6: the field still sizes from its own text on a described card =====
local function boxWidth(element)
	return element.box.Size.X.Offset
end
near(boxWidth(short), 70, "D6 a short hint sits at the field's floor")
expect(
	boxWidth(input) > boxWidth(short),
	"D6 a longer hint grows the field box on a described card ("
		.. tostring(boxWidth(input)) .. " vs " .. tostring(boxWidth(short)) .. ")"
)
local before = boxWidth(input)
input:Set("a value much wider than the hint it was built with")
TestPump(0.4)
expect(boxWidth(input) > before, "D6 typing wider text widens the field on a described card")
expect(
	rectOf(input.box, input.main.AbsoluteSize).y + rectOf(input.box, input.main.AbsoluteSize).h / 2 < 41,
	"D6 ... and the grown field stays in the base region, above the line"
)

-- ===== D7: the line reveals with its element ==============================
eq(input.descriptionLabel.TextTransparency, 0.45, "D7 the line reveals with its element at 0.45")
window:Show()
TestPump(0.8)
eq(input.descriptionLabel.TextTransparency, 0.45, "D7 the line stays at 0.45 once the window is shown")

-- ===== D8: the lock message rides the same line ===========================
input:Lock("Locked by the host.")
TestPump(0.4)
eq(input.descriptionLabel.Text, "Locked by the host.", "D8 locking swaps the line for the lock message")
input:Unlock()
TestPump(0.4)
eq(input.descriptionLabel.Text, "Shown to friends.", "D8 unlocking restores the description")

-- ===== D9: no description, no line, no growth ============================
eq(undescribed.descriptionLabel, nil, "D9 an undescribed element carries no label")
near(undescribed.main.Size.Y.Offset, 41, "D9 an undescribed element keeps its 41px card")

window:Unload()
TestPump(0.2)

print("INLINE DESCRIPTION: all assertions passed")
