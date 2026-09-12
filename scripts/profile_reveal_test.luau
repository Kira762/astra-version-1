-- ===== profile card reveal assertions =====
-- [[Runs the real Astra bundle (loaded as global `Astra` above) against the]]
-- [[mini Roblox environment from sidebar_sizing_stubs.luau.]]
--
-- Expected behavior under test:
--   * P1 with "Reveal profile details" off (the default) the card still
--        shows, and every identifying value on it is masked: the display
--        name (headline), the @username (subtitle), the user ID (with its
--        COPY action hidden) and the place ID (current-game card),
--   * P2 the toggle reveals all four at once,
--   * P3 toggling back off re-masks all four,
--   * P4 an explicit Window:SetProfile subtitle is developer copy, not
--        identity data, so the toggle leaves it alone,
--   * P5 regression: a window built before Players.LocalPlayer exists still
--        shows its card once the player turns up. The identity refresh used
--        to call a nil `sidebar.mask_username`, which threw inside the
--        RenderStepped waiter and left the panel invisible even though
--        "Show profile" was on,
--   * P6 the card also needs room on screen: turning it on in a viewport too
--        small for it keeps it hidden but says why (notification).

local function expect(cond, message)
	if not cond then
		error("PROFILE FAIL: " .. tostring(message), 0)
	end
end

local function eq(actual, wanted, message)
	if actual ~= wanted then
		error(
			"PROFILE FAIL: " .. message .. " (got " .. tostring(actual) .. ", want " .. tostring(wanted) .. ")",
			0
		)
	end
end

local MASKED_ID = "••••••"
local USER_ID = 42
local PLACE_ID = 2753915549

-- [[The stub player/game carry no identity of their own: give them distinct]]
-- [[values so a masked display name can never be confused with the username.]]
local state = Astra.Core.state
local player = state.localPlayer
expect(player ~= nil, "P0 the stub environment has a local player")
player.Name = "TestUser"
player.DisplayName = "Test User"
player.UserId = USER_ID
game.PlaceId = PLACE_ID
game.Name = "Test Place"

local window = Astra:CreateWindow({ name = "Profile Reveal Test" })
TestPump(0.6)

local function findSettingsElement(targetWindow, tabName, elementName)
	for _, tab in targetWindow._settingsTabs do
		if tab.name == tabName then
			tab:Select()
			TestPump(0.15)
			for _, element in tab.elements do
				if element.name == elementName then
					return element
				end
			end
		end
	end
	return nil
end

local function assertMasked(message)
	eq(window.profileName.Text, "Tes****", message .. ": display name masked")
	eq(window.profileSubtitle.Text, "@Tes****", message .. ": username masked")
	eq(window.profileSubtitle.Visible, true, message .. ": username row visible")
	eq(window.profileUserIdValue.Text, MASKED_ID, message .. ": user ID masked")
	eq(window.profileCopyUserId.Visible, false, message .. ": COPY hidden while the user ID is masked")
	eq(window.profilePlaceId.Text, "Place ID: " .. MASKED_ID, message .. ": place ID masked")
end

local function assertRevealed(message)
	eq(window.profileName.Text, "Test User", message .. ": display name revealed")
	eq(window.profileSubtitle.Text, "@TestUser", message .. ": username revealed")
	eq(window.profileUserIdValue.Text, tostring(USER_ID), message .. ": user ID revealed")
	eq(window.profileCopyUserId.Visible, true, message .. ": COPY available once the user ID is revealed")
	eq(window.profilePlaceId.Text, "Place ID: " .. tostring(PLACE_ID), message .. ": place ID revealed")
end

-- P1: the card is on screen by default, with everything masked.
expect(window.profilePanel ~= nil, "P1 the profile panel exists beside the window")
eq(window.profilePanel.Visible, true, "P1 the card shows with 'Show profile' on")
eq(window.settings.showFullUsername, false, "P1 the reveal toggle defaults to off")
assertMasked("P1")

-- P2: the reveal toggle drives all four identity fields at once.
local revealToggle = findSettingsElement(window, "Appearance", "Reveal profile details")
expect(revealToggle ~= nil, "P2 the 'Reveal profile details' toggle exists")
expect(
	findSettingsElement(window, "Appearance", "Reveal full username") == nil,
	"P2 the old 'Reveal full username' toggle is gone"
)
revealToggle:Set(true)
TestPump(0.2)
eq(window.settings.showFullUsername, true, "P2 the toggle writes its setting")
assertRevealed("P2")

-- P3: back off, everything re-masks (nothing latches the revealed values).
revealToggle:Set(false)
TestPump(0.2)
eq(window.settings.showFullUsername, false, "P3 the toggle writes its setting back")
assertMasked("P3")

-- P4: SetProfile copy is the developer's own text, so the toggle skips it.
window:SetProfile("Panel subtitle")
TestPump(0.1)
eq(window.profileSubtitle.Text, "Panel subtitle", "P4 a custom subtitle replaces the @username")
revealToggle:Set(true)
TestPump(0.2)
eq(window.profileSubtitle.Text, "Panel subtitle", "P4 the reveal toggle leaves custom copy alone")
eq(window.profileName.Text, "Test User", "P4 the headline still follows the toggle")
revealToggle:Set(false)
TestPump(0.2)
window:SetProfile(nil)
TestPump(0.1)
eq(window.profileSubtitle.Text, "@Tes****", "P4 clearing the custom subtitle restores the masked @username")

-- P5: regression - the card must appear when the local player turns up after
-- construction (the path that used to throw on the nil mask helper).
window:Unload()
TestPump(0.2)
state.localPlayer = nil
local lateWindow = Astra:CreateWindow({ name = "Profile Reveal Test (late player)" })
TestPump(0.6)
expect(lateWindow.profilePanel ~= nil, "P5 the panel is built even without a local player")
eq(lateWindow.profilePanel.Visible, false, "P5 the card stays hidden while the player is unknown")
eq(lateWindow.profileName.Text, "", "P5 no identity is rendered before the player exists")

state.localPlayer = player
TestPump(0.6)
eq(lateWindow.profilePanel.Visible, true, "P5 the card shows once the local player turns up")
eq(lateWindow.profileName.Text, "Tes****", "P5 the late identity refresh masks the display name")
eq(lateWindow.profileSubtitle.Text, "@Tes****", "P5 the late identity refresh masks the username")
eq(lateWindow.profileUserIdValue.Text, MASKED_ID, "P5 the late identity refresh masks the user ID")
eq(lateWindow.profilePlaceId.Text, "Place ID: " .. MASKED_ID, "P5 the late identity refresh masks the place ID")

local lateReveal = findSettingsElement(lateWindow, "Appearance", "Reveal profile details")
expect(lateReveal ~= nil, "P5 the late window has its own reveal toggle")
lateReveal:Set(true)
TestPump(0.2)
eq(lateWindow.profileName.Text, "Test User", "P5 the late window reveals the display name")
eq(lateWindow.profileSubtitle.Text, "@TestUser", "P5 the late window reveals the username")
eq(lateWindow.profileUserIdValue.Text, tostring(USER_ID), "P5 the late window reveals the user ID")
eq(lateWindow.profilePlaceId.Text, "Place ID: " .. tostring(PLACE_ID), "P5 the late window reveals the place ID")

-- P6: the card also needs room; an active toggle on a cramped viewport says
-- so instead of silently leaving the user without a card.
expect(lateWindow.notifications == nil, "P6 no notification has been raised yet")
TestViewport.set(360, 390)
TestPump(0.4)
local showProfileToggle = findSettingsElement(lateWindow, "Appearance", "Show profile")
expect(showProfileToggle ~= nil, "P6 the 'Show profile' toggle exists")
showProfileToggle:Set(false)
TestPump(0.2)
showProfileToggle:Set(true)
TestPump(0.2)
eq(lateWindow.profilePanel.Visible, false, "P6 a portrait viewport has no room for the card")
expect(
	lateWindow.notifications ~= nil,
	"P6 turning the card on without room explains why it is hidden"
)
TestViewport.set(1920, 1080)
TestPump(0.4)
eq(lateWindow.profilePanel.Visible, true, "P6 the card comes back once the screen has room")

print("PROFILE REVEAL: all assertions passed")
