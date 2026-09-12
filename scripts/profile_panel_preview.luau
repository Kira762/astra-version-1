-- ===== profile card preview dump =====
-- [[Walks the real profile card built by the bundle and prints it as JSON so
-- [[an offline renderer can draw it (scripts/render_profile_panel_preview.py).
-- [[Run through scripts/profile_panel_preview.sh; not part of the test suite.
-- [[Content is deliberately fixed to exercise every row: a premium player, a
-- [[host-supplied license/whitelist, a named game and a 50-player server.]]
local state = Astra.Core.state
local player = state.localPlayer
player.Name = "Kira762"
player.DisplayName = "Kira"
player.UserId = 1234567890
game.PlaceId = 2753915549
game.Name = "Blox Fruits"
game.GameId = 123456
game.JobId = "d2f4a1b9-8c3e-4a71-9b2f-5c1e7a8d9f01"

local window = Astra:CreateWindow({ name = "Preview" })
TestPump(0.6)
window:SetProfile({ key = "ASTRA-PREMIUM-LICENSE", whitelist = { status = "Active", daysLeft = 14 } })
state.workspace.DistributedGameTime = 9240
game:GetService("Players").MaxPlayers = 50
TestPump(1.2)

local function num(value)
	return string.format("%.4f", value or 0)
end

local function color(value)
	if not value then
		return "null"
	end
	return string.format("[%s,%s,%s]", num(value.R), num(value.G), num(value.B))
end

local function esc(text)
	return '"' .. tostring(text):gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n") .. '"'
end

local function dump(inst)
	local props = inst.__props or {}
	local parts = {}
	local anchor = props.AnchorPoint
	table.insert(parts, '"name":' .. esc(props.Name or "?"))
	table.insert(parts, '"anchor":[' .. num(anchor and anchor.X) .. "," .. num(anchor and anchor.Y) .. "]")
	local px, py = props.Position and props.Position.X or {}, props.Position and props.Position.Y or {}
	local sx, sy = props.Size and props.Size.X or {}, props.Size and props.Size.Y or {}
	table.insert(parts, '"pos":[' .. num(px.Scale) .. "," .. num(px.Offset) .. "," .. num(py.Scale) .. "," .. num(py.Offset) .. "]")
	table.insert(parts, '"size":[' .. num(sx.Scale) .. "," .. num(sx.Offset) .. "," .. num(sy.Scale) .. "," .. num(sy.Offset) .. "]")
	table.insert(parts, '"z":' .. tostring(props.ZIndex or 1))
	table.insert(parts, '"class":' .. esc(props.ClassName or "?"))
	table.insert(parts, '"visible":' .. tostring(props.Visible ~= false))
	table.insert(parts, '"x":' .. num(inst.AbsolutePosition and inst.AbsolutePosition.X))
	table.insert(parts, '"y":' .. num(inst.AbsolutePosition and inst.AbsolutePosition.Y))
	table.insert(parts, '"w":' .. num(inst.AbsoluteSize and inst.AbsoluteSize.X))
	table.insert(parts, '"h":' .. num(inst.AbsoluteSize and inst.AbsoluteSize.Y))
	table.insert(parts, '"text":' .. esc(props.Text or ""))
	table.insert(parts, '"textSize":' .. tostring(props.TextSize or 0))
	table.insert(parts, '"align":' .. esc(props.TextXAlignment and props.TextXAlignment.Name or "Left"))
	table.insert(parts, '"textTransparency":' .. tostring(props.TextTransparency or 0))
	table.insert(parts, '"backgroundTransparency":' .. tostring(props.BackgroundTransparency or 0))
	table.insert(parts, '"imageTransparency":' .. tostring(props.ImageTransparency or 0))
	table.insert(parts, '"color":' .. color(props.BackgroundColor3))
	table.insert(parts, '"textColor":' .. color(props.TextColor3))

	local corner = "null"
	local stroke = "null"
	local gradient = "null"
	for _, child in inst:GetChildren() do
		local childProps = child.__props or {}
		if childProps.ClassName == "UICorner" and childProps.CornerRadius then
			corner = string.format("[%s,%s]", num(childProps.CornerRadius.Scale), num(childProps.CornerRadius.Offset))
		elseif childProps.ClassName == "UIStroke" then
			local c = childProps.Color
			stroke = ("[%s,%s,%s,%s]"):format(num(c and c.R), num(c and c.G), num(c and c.B), tostring(childProps.Transparency or 0))
		elseif childProps.ClassName == "UIGradient" and childProps.Color then
			local keypoints = childProps.Color.Keypoints
			if keypoints and keypoints[1] and keypoints[#keypoints] then
				local a = keypoints[1].Value
				local b = keypoints[#keypoints].Value
				gradient = ("[%s,%s,%s,%s,%s,%s]"):format(num(a.R), num(a.G), num(a.B), num(b.R), num(b.G), num(b.B))
			end
		end
	end
	table.insert(parts, '"corner":' .. corner)
	table.insert(parts, '"stroke":' .. stroke)
	table.insert(parts, '"gradient":' .. gradient)

	local children = {}
	for _, child in inst:GetChildren() do
		local childProps = child.__props or {}
		if childProps.Size then
			table.insert(children, dump(child))
		end
	end
	table.insert(parts, '"children":[' .. table.concat(children, ",") .. "]")
	return "{" .. table.concat(parts, ",") .. "}"
end

print("MASKED")
print(dump(window.profilePanel))

for _, tab in window._settingsTabs do
	if tab.name == "Appearance" then
		tab:Select()
		TestPump(0.2)
		for _, element in tab.elements do
			if element.name == "Reveal profile details" then
				element:Set(true)
			end
		end
	end
end
TestPump(0.4)
print("REVEALED")
print(dump(window.profilePanel))
