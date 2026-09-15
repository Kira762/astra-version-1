-- ===== instance budget assertions =====
-- [[Runs the real Astra bundle (loaded as global `Astra` above) against the]]
-- [[mini Roblox environment from sidebar_sizing_stubs.luau.]]
--
-- Instance count is the library's main frame-time lever: Roblox renders and
-- sorts every GUI instance it holds, so a page's element count is a direct
-- proxy for what the menu costs while it is open. Input is the library's only
-- element, so this suite pins one ceiling - the element's - and one budget for
-- a page that holds a single field. A change that quietly re-adds invisible
-- decoration to the card (or to the field box that grows with its text) fails
-- here instead of in game.
--
-- Ceilings are deliberately a few instances above today's numbers: they catch
-- creep, not legitimate layout changes. Raise one only with a before/after
-- count in the changelog.
--
-- Expected behavior under test:
--   * B1 an input stays under its ceiling,
--   * B2 a page holding one input stays under the same budget.

local function expect(cond, message)
	if not cond then
		error("BUDGET FAIL: " .. tostring(message), 0)
	end
end

local window = Astra:CreateWindow({ name = "Budget" })
TestPump(0.6)
window:Show()
TestPump(0.6)
local tab = window:CreateTab({ name = "Budget" })

local function count(inst)
	local n = 1
	for _, child in inst:GetChildren() do
		n += count(child)
	end
	return n
end

-- ===== B1: the element ceiling =====

local ceilings = {
	input = 18,
}

local builders = {
	input = function() return tab:CreateInput({ name = "Input", placeholder = "x" }) end,
}

for name, ceiling in ceilings do
	local ok, element = pcall(builders[name])
	expect(ok, "B1 " .. name .. " builds")
	local used = count(element.main)
	expect(
		used <= ceiling,
		"B1 " .. name .. " stays under its " .. tostring(ceiling) .. " instance ceiling (used " .. tostring(used) .. ")"
	)
end
TestPump(0.3)

-- ===== B2: a one-field page budget =====

local page = window:CreateTab({ name = "Page" })
local before = count(page.tabPage)
page:CreateInput({ name = "Nickname", placeholder = "..." })
TestPump(0.6)

local used = count(page.tabPage) - before
local pageBudget = 18
expect(
	used <= pageBudget,
	"B2 the single-input page stays under its " .. tostring(pageBudget) .. " instance budget (used " .. tostring(used) .. ")"
)

window:Unload()
TestPump(0.1)

print("BUDGET: all assertions passed (page used " .. tostring(used) .. " instances)")
