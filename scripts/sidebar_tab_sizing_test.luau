-- ===== sidebar tab sizing assertions =====
-- [[Runs the real Astra bundle (loaded as global `Astra` above) against the]]
-- [[mini Roblox environment from sidebar_sizing_stubs.luau. The stub]]
-- [[TextService measures text at 0.6 * size per character, so expected]]
-- [[widths are computed here from that same deterministic formula.]]

local function expect(cond, message)
	if not cond then
		error("SMOKE FAIL: " .. message, 0)
	end
end

local function eq(actual, wanted, message)
	if actual ~= wanted then
		error(
			"SMOKE FAIL: " .. message .. " (got " .. tostring(actual) .. ", want " .. tostring(wanted) .. ")",
			0
		)
	end
end

-- Layout constants (utilities/layouts.luau, mode "sidebar")
local RAIL_EXPANDED = 219
local RAIL_COLLAPSED = 64
local ROW_INSET2 = 30 -- rowInset * 2
local ROW_PADDING2 = 20 -- rowPadding * 2
local ROW_ICON = 20
local ROW_SPACING = 6
local EXPANDED_AVAILABLE = RAIL_EXPANDED - ROW_INSET2

local function textW(text)
	return math.ceil(#text * 16 * 0.6)
end

local function naturalRow(name, hasIcon)
	local width = ROW_PADDING2
	if hasIcon then
		width += ROW_ICON
		if name ~= nil then
			width += ROW_SPACING
		end
	end
	if name ~= nil then
		width += textW(name)
	end
	return width
end

local window = Astra:CreateWindow({ name = "Sidebar Sizing Test" })
print("stage: window created")
TestPump(0.5)
print("stage: initial pump done")

local function groupTabs()
	local out = {}
	for _, tab in window.tabs do
		if
			not tab.neglectSelector
			and tab.topbarItem
			and (tab._isSettingsTab == true) == (window._settingsMode == true)
		then
			table.insert(out, tab)
		end
	end
	return out
end

local function assertEqualRowWidth(width, message)
	local tabs = groupTabs()
	expect(#tabs > 0, message .. " (no rows in the current rail group)")
	for i, tab in tabs do
		local size = tab.topbarItem.Size
		if size.X.Scale ~= 0 then
			error("SMOKE FAIL: " .. message .. " row " .. i .. " is scale-sized, not a fixed natural width", 0)
		end
		if size.X.Offset ~= width then
			error(
				"SMOKE FAIL: " .. message .. " row " .. i .. " width " .. tostring(size.X.Offset) .. ", want " .. tostring(width),
				0
			)
		end
	end
end

local function assertRailWidth(width, message)
	eq(window.sidebar and window.sidebar.Size.X.Offset or nil, width, message)
end

local switched = window:_setLayoutMode("sidebar")
expect(switched == true, "layout switch to the responsive sidebar")
TestPump(1.0)
expect(window.sidebar ~= nil, "responsive sidebar rail exists")
assertRailWidth(RAIL_EXPANDED, "rail starts at the responsive expanded width")

-- T1: several tabs with identical short names.
local t1 = window:CreateTab({ name = "AAA", icon = "house" })
local t2 = window:CreateTab({ name = "AAA", icon = "house" })
local t3 = window:CreateTab({ name = "AAA", icon = "house" })
TestPump(0.2)
local shortWidth = naturalRow("AAA", true)
assertEqualRowWidth(shortWidth, "T1 identical short names -> every row is the natural width")
assertRailWidth(RAIL_EXPANDED, "T1 rail width is untouched by the tab names")

-- T2: a mixture of short and long names; shorter rows expand to the longest.
local medium = window:CreateTab({ name = "AAAAAAAAAAAA", icon = "gauge" }) -- 12 chars
TestPump(0.2)
local mediumWidth = naturalRow("AAAAAAAAAAAA", true)
expect(mediumWidth > shortWidth, "T2 precondition: long name measures wider")
assertEqualRowWidth(mediumWidth, "T2 mixed names -> every row (incl. short ones) matches the longest")

-- T3: one significantly longer name; the rail's available space is the cap.
local long1 = window:CreateTab({ name = "ThisTabNameIsReallyQuiteLong", icon = "sliders-horizontal" })
TestPump(0.2)
local long1Natural = naturalRow("ThisTabNameIsReallyQuiteLong", true)
expect(long1Natural > EXPANDED_AVAILABLE, "T3 precondition: name is wider than the available rail space")
assertEqualRowWidth(EXPANDED_AVAILABLE, "T3 very long name -> rows cap at the available rail width")
assertRailWidth(RAIL_EXPANDED, "T3 rail must NOT be enlarged by a long name")
local long1Title = long1.topbarItemTitle
local cappedSlot = EXPANDED_AVAILABLE - ROW_PADDING2 - ROW_ICON - ROW_SPACING
eq(long1Title.AutomaticSize, Enum.AutomaticSize.Y, "T3 capped title is width-constrained (wraps)")
eq(long1Title.Size.X.Offset, cappedSlot, "T3 capped title holds exactly the available slot")
expect(long1Title.TextWrapped == true, "T3 title keeps its existing TextWrapped style")
eq(t1.topbarItemTitle.AutomaticSize, Enum.AutomaticSize.XY, "T3 uncapped titles keep automatic sizing")
eq(t1.topbarItemTitle.Size.X.Offset, 0, "T3 uncapped titles keep their original size")

-- T4: multiple long names; no tab resizes independently.
local long2 = window:CreateTab({ name = "AnotherExtremelyLongTabName", icon = "palette" })
TestPump(0.2)
assertEqualRowWidth(EXPANDED_AVAILABLE, "T4 several long names -> rows stay equal at the cap")
assertRailWidth(RAIL_EXPANDED, "T4 rail still untouched")

-- T5: removing the long rows re-derives the width from what remains (no latching).
long1:Remove()
long2:Remove()
TestPump(0.2)
assertEqualRowWidth(mediumWidth, "T5 after removing the long rows -> width follows the new longest")
medium:Remove()
TestPump(0.2)
assertEqualRowWidth(shortWidth, "T5 after removing the medium row -> width shrinks again")
assertRailWidth(RAIL_EXPANDED, "T5 rail width never changed")

-- T6: narrow window -> the rail collapses to the icon-only width.
TestViewport.set(500, 700)
TestPump(0.2)
assertRailWidth(RAIL_COLLAPSED, "T6 narrow window -> rail uses the collapsed width")
for i, tab in groupTabs() do
	local size = tab.topbarItem.Size
	if size.X.Scale ~= 1 or size.X.Offset ~= -ROW_INSET2 then
		error("SMOKE FAIL: T6 collapsed rows must track the collapsed rail (row " .. i .. ")", 0)
	end
	expect(tab.topbarItemTitle.Visible == false, "T6 row " .. i .. " hides its title when collapsed")
end

-- T7: wider window again -> rows return to the name-driven width.
TestViewport.set(1920, 1080)
TestPump(0.2)
assertRailWidth(RAIL_EXPANDED, "T7 wide window -> rail back to the expanded width")
assertEqualRowWidth(shortWidth, "T7 expanded again -> name-driven width restored")
for _, tab in groupTabs() do
	expect(tab.topbarItemTitle.Visible == true, "T7 titles visible again when expanded")
end

-- T8: the topbar layout keeps its existing per-pill sizing (untouched path).
switched = window:_setLayoutMode("top")
expect(switched == true, "T8 layout switch back to the topbar")
TestPump(1.0)
for i, tab in groupTabs() do
	local size = tab.topbarItem.Size
	if size.X.Offset ~= 0 or size.Y.Offset ~= 34 then
		error("SMOKE FAIL: T8 topbar row " .. i .. " keeps its original size", 0)
	end
	if tab.topbarItem.AutomaticSize ~= Enum.AutomaticSize.X then
		error("SMOKE FAIL: T8 topbar row " .. i .. " keeps AutomaticSize.X", 0)
	end
end

-- T9: the settings-mode rail group sizes from the settings tab names.
switched = window:_setLayoutMode("sidebar")
expect(switched == true, "T9 layout switch back to the responsive sidebar")
TestPump(1.0)
window.rfSettings:Select()
TestPump(0.2)
local settingsWidth = math.max(
	naturalRow("General", true),
	naturalRow("Appearance", true),
	naturalRow("Behavior", true),
	naturalRow("Performance", true),
	naturalRow("Persistence", true),
	naturalRow("About", true)
)
assertEqualRowWidth(settingsWidth, "T9 settings-mode rail group uses its own longest name")
t1:Select()
TestPump(0.2)
assertEqualRowWidth(shortWidth, "T9 leaving settings restores the normal group width")

-- T10: neglectSelector tabs have no row and must not influence sizing.
local hidden = window:CreateTab({ name = "ShouldNotAffectSizing", neglectSelector = true })
expect(hidden.topbarItem == nil, "T10 neglectSelector tab has no row")
assertEqualRowWidth(shortWidth, "T10 neglectSelector tab does not change row widths")
hidden:Remove()

-- T11: a tab without an icon measures without icon/spacing, and reverts on remove.
local noIcon = window:CreateTab({ name = "NoIconTab" })
TestPump(0.2)
assertEqualRowWidth(naturalRow("NoIconTab", false), "T11 icon-less tab measured without icon and spacing")
eq(noIcon.topbarItemTitle.AutomaticSize, Enum.AutomaticSize.XY, "T11 icon-less title stays automatic")
noIcon:Remove()
TestPump(0.2)
assertEqualRowWidth(shortWidth, "T11 width reverts after the icon-less tab is removed")

-- T12: locale changes re-measure the rows.
window:RegisterTranslations({ ["en"] = { ["AAA"] = "MuchLongerTranslatedName" } })
TestPump(0.2)
local translatedWidth = naturalRow("MuchLongerTranslatedName", true)
if translatedWidth > EXPANDED_AVAILABLE then
	assertEqualRowWidth(EXPANDED_AVAILABLE, "T12 translated long name caps at the available width")
else
	assertEqualRowWidth(translatedWidth, "T12 translated name widens every row")
end
window:RegisterTranslations({ ["en"] = { ["AAA"] = "AAA" } })
TestPump(0.2)
assertEqualRowWidth(shortWidth, "T12 restoring the locale restores the original width")

-- T13: the separate collapsedSidebar layout keeps its icon-only row sizing
-- (name-driven sizing must not leak into it; title visibility there is
-- pre-existing baseline behavior and is intentionally not asserted).
switched = window:_setLayoutMode("collapsedSidebar")
expect(switched == true, "T13 layout switch to the collapsed sidebar")
TestPump(1.0)
assertRailWidth(RAIL_COLLAPSED, "T13 collapsed sidebar uses its fixed compact rail")
for i, tab in groupTabs() do
	local size = tab.topbarItem.Size
	if size.X.Scale ~= 1 or size.X.Offset ~= -ROW_INSET2 then
		error("SMOKE FAIL: T13 collapsed sidebar rows stay icon-only/full-rail (row " .. i .. ")", 0)
	end
end

-- T14: returning to the responsive sidebar restores name-driven sizing.
switched = window:_setLayoutMode("sidebar")
expect(switched == true, "T14 layout switch back to the responsive sidebar")
TestPump(1.0)
assertEqualRowWidth(shortWidth, "T14 responsive sidebar rows are name-sized again")

print("SIDEBAR TAB SIZING: all assertions passed")
