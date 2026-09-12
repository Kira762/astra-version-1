-- ===== profile details card assertions (redesigned panel) =====
-- [[Runs the real Astra bundle (loaded as global `Astra` above) against the]]
-- [[mini Roblox environment from sidebar_sizing_stubs.luau.]]
--
-- Expected behavior under test:
--   * E1 the card is built from the window's own visual language: the themed
--        plate/stroke/corner tokens, one uppercase section label per section
--        (ACCOUNT, CURRENT GAME, SERVER, USER SESSION) and a rounded dark
--        container per section holding compact label/value rows,
--   * E2 the header is pinned: avatar, name, subtitle, premium pill and gear
--        sit outside the scrolling details region, which scrolls vertically
--        only, keeps bottom padding on its canvas and shows its scrollbar only
--        when the sections are taller than the window allows,
--   * E3 the SERVER and USER SESSION values come from the live environment
--        (Players:GetPlayers()/MaxPlayers, Workspace.DistributedGameTime,
--        DataModel.JobId, the client's own clock) and fall back to "—" when a
--        source is unavailable - never to an invented number,
--   * E4 the license/whitelist rows are host-owned (Window:SetProfile) and
--        read "—" until the host supplies real data,
--   * E5 long values truncate with an ellipsis and reveal the full text in the
--        themed hover tooltip; short values do not raise a tooltip,
--   * E6 a missing local player leaves neutral placeholders instead of
--        identity data or fabricated values,
--   * E7 the premium pill is real data (MembershipType), rides the handle row
--        next to the subtitle and disappears for a free account.

local function expect(cond, message)
	if not cond then
		error("DETAILS FAIL: " .. tostring(message), 0)
	end
end

local function eq(actual, wanted, message)
	if actual ~= wanted then
		error(
			"DETAILS FAIL: " .. message .. " (got " .. tostring(actual) .. ", want " .. tostring(wanted) .. ")",
			0
		)
	end
end

local DASH = "—"

local state = Astra.Core.state
local theme = nil

local function findChild(instance, name)
	for _, child in instance:GetChildren() do
		if child.__props and child.__props.Name == name then
			return child
		end
		local found = findChild(child, name)
		if found then
			return found
		end
	end
	return nil
end

local function isDescendantOf(instance, ancestor)
	local cursor = instance.Parent
	while cursor do
		if cursor == ancestor then
			return true
		end
		cursor = cursor.Parent
	end
	return false
end

local player = state.localPlayer
expect(player ~= nil, "E0 the stub environment has a local player")
player.Name = "TestUser"
player.DisplayName = "Test User"
player.UserId = 42
game.PlaceId = 2753915549
game.Name = "Test Place"
game.GameId = 123456
game.JobId = "astra-details-server"

local window = Astra:CreateWindow({ name = "Profile Details Test" })
TestPump(0.6)
theme = window.theme
expect(theme ~= nil, "E0 the window exposes its resolved theme")

local panel = window.profilePanel
expect(panel ~= nil, "E1 the profile card exists")

-- ===== E1: the card reuses the window's design tokens =====

local surface = findChild(panel, "Surface")
expect(surface ~= nil, "E1 the card surface exists")
-- [[The panel's UICorner is a child of the surface frame.]]
local surfaceCornerInstance = nil
for _, child in surface:GetChildren() do
	if child.ClassName == "UICorner" then
		surfaceCornerInstance = child
	end
end
expect(surfaceCornerInstance ~= nil, "E1 the surface carries its UICorner")
eq(tostring(surfaceCornerInstance.CornerRadius.Offset), tostring(theme.CornerRoundness.Offset), "E1 the card reuses the window's corner radius")

local accountCard = findChild(panel, "AccountCard")
expect(accountCard ~= nil, "E1 the account container exists")
eq(tostring(accountCard.BackgroundColor3.R), tostring(theme.CardSurface.R), "E1 the containers use the themed card surface")
local cardCorner = nil
local cardStroke = nil
for _, child in accountCard:GetChildren() do
	if child.ClassName == "UICorner" then
		cardCorner = child
	elseif child.ClassName == "UIStroke" then
		cardStroke = child
	end
end
expect(cardCorner ~= nil and cardStroke ~= nil, "E1 the containers carry a corner and a hairline stroke")
eq(tostring(cardCorner.CornerRadius.Offset), tostring(theme.ElementCornerRadius.Offset), "E1 containers use the element corner radius")
eq(tostring(cardStroke.Color.R), tostring(theme.ElementStroke.R), "E1 containers use the themed element stroke")

for _, sectionLabel in { "ACCOUNT", "CURRENT GAME", "SERVER", "USER SESSION" } do
	expect(findChild(panel, sectionLabel) ~= nil, "E1 the " .. sectionLabel .. " section label exists")
end
for _, container in { "AccountCard", "CurrentGame", "ServerCard", "SessionCard" } do
	expect(findChild(panel, container) ~= nil, "E1 the " .. container .. " container exists")
end

-- [[Rows are compact label/value pairs: the label is muted, the value uses the
-- [[bright titling colour, and both truncate rather than overflow.]]
local userIdLabel = findChild(panel, "UserIdLabel")
local userIdValue = window.profileUserIdValue
expect(userIdLabel ~= nil and userIdValue ~= nil, "E1 the user ID row exists")
eq(tostring(userIdLabel.TextColor3.R), tostring(theme.PlaceholderColor.R), "E1 row labels use the muted placeholder colour")
eq(tostring(userIdValue.TextColor3.R), tostring(theme.TitlingColor.R), "E1 row values use the titling colour")
eq(userIdValue.TextTruncate, Enum.TextTruncate.AtEnd, "E1 long values truncate with an ellipsis")
eq(userIdLabel.TextXAlignment, Enum.TextXAlignment.Left, "E1 labels are left aligned")
eq(userIdValue.TextXAlignment, Enum.TextXAlignment.Right, "E1 values are right aligned")

-- ===== E2: pinned header + vertical-only scrolling =====

local details = findChild(panel, "Details")
local content = findChild(panel, "Content")
expect(details ~= nil and content ~= nil, "E2 the details scroller exists")
expect(details.ClassName == "ScrollingFrame", "E2 the details region is a ScrollingFrame")
eq(details.ScrollingDirection, Enum.ScrollingDirection.Y, "E2 the details region scrolls vertically only")
expect(isDescendantOf(content, details), "E2 the sections live inside the scroller")

for _, headerPart in { window.profileAvatar, window.profileName, window.profileSubtitle, window.profilePremium, window.profileGear } do
	expect(not isDescendantOf(headerPart, details), "E2 the header stays pinned above the scroller")
end
expect(isDescendantOf(window.profileSessionValue, details), "E2 the session row scrolls with the details")

-- [[The canvas keeps the bottom padding, so the last row is never flush against
-- [[the card edge.]]
expect(details.CanvasSize.Y.Offset > content.Size.Y.Offset, "E2 the canvas reserves padding around the content")
eq(details.CanvasSize.X.Offset, 0, "E2 the canvas never scrolls sideways")
eq(content.Size.X.Scale, 1, "E2 the content spans the scroller")
expect(content.Size.X.Offset <= 0, "E2 the content never exceeds the scroller width")

-- [[At the default window height the sections are taller than the region, so
-- [[the themed scrollbar is present.]]
expect(details.ScrollBarThickness > 0, "E2 the scrollbar appears while the sections overflow")
eq(details.ScrollBarImageColor3.R, 1, "E2 the scrollbar uses the dark theme's thumbnail colour")
expect(details.ClipsDescendants, "E2 the scroller clips its content")

-- [[A window tall enough for everything hides the scrollbar again and hands
-- [[the reserved width back to the content (simulated by resizing the frame,
-- [[which is what a viewport change does).]]
local originalSize = window.main.Size
local tallSize = UDim2.fromOffset(originalSize.X.Offset, 900)
window.size = tallSize
window.main.Size = tallSize
TestPump(0.2)
eq(details.ScrollBarThickness, 0, "E2 a tall enough card shows no scrollbar")
eq(content.Size.X.Offset, 0, "E2 the content reclaims the scrollbar width when nothing scrolls")
window.size = originalSize
window.main.Size = originalSize
TestPump(0.2)
expect(details.ScrollBarThickness > 0, "E2 the scrollbar comes back when the card shrinks again")

-- ===== E3: live server + session values =====

local workspace = state.workspace
local players = game:GetService("Players")
expect(players ~= nil, "E3 the stub exposes the Players service")

workspace.DistributedGameTime = 9240 -- 2h 34m of server uptime
players.MaxPlayers = 50
TestPump(1.2)
eq(window.profilePlayersValue.Text, "1 / 50", "E3 the players row shows current players / max players")
eq(window.profileUptimeValue.Text, "2h 34m", "E3 the uptime row formats the server's own clock")
expect(
	window.profileSessionValue.Text:match("^%d+[smhd]") ~= nil
		or window.profileSessionValue.Text:match("^%d+d %d+h$") ~= nil,
	"E3 the session row shows a real duration (got " .. tostring(window.profileSessionValue.Text) .. ")"
)
eq(window.profileServerIdValue.Text, "••••••", "E3 the server ID is masked while reveal is off")

-- [[A missing source is a neutral placeholder, not a zero.]]
players.MaxPlayers = nil
players.GetPlayers = nil
workspace.DistributedGameTime = nil
TestPump(1.2)
eq(window.profilePlayersValue.Text, DASH, "E3 an unavailable player source reads as the neutral placeholder")
eq(window.profileUptimeValue.Text, DASH, "E3 an unavailable uptime source reads as the neutral placeholder")

players.MaxPlayers = 50
players.GetPlayers = function()
	return { player }
end
workspace.DistributedGameTime = 9240
TestPump(1.2)
eq(window.profilePlayersValue.Text, "1 / 50", "E3 the rows recover as soon as the source answers again")

-- ===== E4: host-owned license rows =====

eq(window.profileKeyValue.Text, DASH, "E4 the key row reads the placeholder until the host supplies one")
eq(window.profileWhitelistValue.Text, DASH, "E4 the whitelist row reads the placeholder until the host supplies one")
window:SetProfile({ key = "ASTRA-KEY-123", whitelist = { status = "Active", daysLeft = 14 } })
TestPump(0.2)
eq(window.profileKeyValue.Text, "••••••••", "E4 the key stays masked while reveal is off")
eq(window.profileWhitelistValue.Text, "14 days left", "E4 the whitelist row shows the host's status and days")
-- [[The legacy string/nil shape only swaps the subtitle: a host toggling
-- [[their own copy must not lose the license rows.]]
window:SetProfile(nil)
TestPump(0.2)
eq(window.profileSubtitle.Text, "@Tes****", "E4 clearing the subtitle restores the masked @username")
eq(window.profileKeyValue.Text, "••••••••", "E4 the legacy shape leaves the host's key row in place")
-- [[The table shape is a full payload: anything omitted is cleared.]]
window:SetProfile({})
TestPump(0.2)
eq(window.profileKeyValue.Text, DASH, "E4 an empty payload clears the key row")
eq(window.profileWhitelistValue.Text, DASH, "E4 an empty payload clears the whitelist row")

-- ===== E7: the premium pill is real, and rides the handle row =====

local premium = window.profilePremium
expect(premium ~= nil, "E7 the premium pill exists")
local player = state.localPlayer
local membership = player.MembershipType
eq(premium.Visible, true, "E7 a paid membership shows the pill")
eq(premium.Position.Y.Offset, window.profileSubtitle.Position.Y.Offset - 0.5,
	"E7 the pill rides the @username row, matching the design")
expect(premium.Position.X.Offset > window.profileSubtitle.Position.X.Offset,
	"E7 the pill sits after the handle text")
expect(premium.Position.X.Offset + premium.Size.X.Offset <= panel.Size.X.Offset - window.profileGear.Size.X.Offset,
	"E7 the pill never runs into the settings gear")
expect(isDescendantOf(premium, window.profilePanelSurface), "E7 the pill lives in the pinned header")

-- [[A free account is not decorated: the pill goes away again.]] 
player.MembershipType = Enum.MembershipType.None
window:SetProfile({ subtitle = "Still here" })
TestPump(0.2)
eq(premium.Visible, false, "E7 a free account shows no premium pill")
player.MembershipType = membership
window:SetProfile({})
TestPump(0.2)
eq(premium.Visible, true, "E7 the pill returns on the next refresh")

-- ===== E5: truncation + hover tooltip =====

local longName = string.rep("Extremely Long Game Title ", 6)
game.Name = longName
local longWindow = Astra:CreateWindow({ name = "Profile Details Test (long values)" })
TestPump(0.6)
local longPanel = longWindow.profilePanel
expect(longPanel ~= nil, "E5 the long-value card exists")
local longGameName = findChild(longPanel, "GameName")
expect(longGameName ~= nil, "E5 the game name exists")
eq(longGameName.Text, longName, "E5 the game name is never truncated in the data, only in the label")
eq(longGameName.TextTruncate, Enum.TextTruncate.AtEnd, "E5 the game name truncates with an ellipsis")
expect(not longWindow.profileTooltip.Visible, "E5 the tooltip starts hidden")

longGameName.MouseEnter:Fire()
TestPump(0.1)
expect(longWindow.profileTooltip.Visible, "E5 hovering a truncated value raises the tooltip")
eq(longWindow.profileTooltip.tipLabel.Text, longName, "E5 the tooltip shows the full value")
longGameName.MouseLeave:Fire()
TestPump(0.4)
expect(not longWindow.profileTooltip.Visible, "E5 the tooltip hides again on mouse leave")

-- [[A short value that fits raises nothing.]]
longWindow.profilePlayersValue.MouseEnter:Fire()
TestPump(0.1)
expect(not longWindow.profileTooltip.Visible, "E5 a value that fits does not raise a tooltip")
longWindow:Unload()
TestPump(0.2)
game.Name = "Test Place"

-- ===== E6: no player, no invented identity =====

local absentPlayer = state.localPlayer
state.localPlayer = nil
local absentWindow = Astra:CreateWindow({ name = "Profile Details Test (no player)" })
TestPump(0.6)
eq(absentWindow.profilePanel.Visible, false, "E6 the card stays hidden while the local player is unknown")
eq(absentWindow.profileName.Text, "", "E6 no display name is invented")
eq(absentWindow.profileUserIdValue.Text, DASH, "E6 no user ID is invented")
eq(absentWindow.profileKeyValue.Text, DASH, "E6 no license key is invented")
state.localPlayer = absentPlayer
TestPump(0.6)
eq(absentWindow.profileUserIdValue.Text, "••••••", "E6 the real identity lands (masked) once the player is known")
absentWindow:Unload()
TestPump(0.2)

print("PROFILE DETAILS: all assertions passed")
