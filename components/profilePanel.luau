local utilities = script.Parent.Parent.utilities
local state = require(utilities.Parent.core.state)
local services = require(utilities.services)
local image = require(script.Parent.Parent.images.image)
local functions = require(script.Parent.Parent.functions)
local locale = require(utilities.locale)
local log = require(utilities.log)
local constants = require(utilities.constants)
local sidebar = require(script.Parent.sidebar)
local network = require(utilities.network)

-- [[The profile panel lives OUTSIDE the window frame, beside it: a companion]]
-- [[card whose height always matches the current window height. The window and]]
-- [[the panel are centred on screen as a single unit, so the window sits half a]]
-- [[panel (width + gap) away from the screen centre, on the opposite side of]]
-- [[the panel.]]
-- [[
--   Visual language: the card is built from the same tokens as the window —
--   the WindowColor plate, a hairline SurfaceStroke, ElementCornerRadius on
--   the inner containers, the brand Font, muted PlaceholderColor labels and
--   brighter ContentColor/TitlingColor values. Nothing here introduces a
--   colour, radius or shadow the rest of Astra does not already use.
--
--   Layout, top to bottom:
--     header   avatar (with its presence dot) on the left; display name,
--              @username and the PREMIUM pill beside it; the settings gear in
--              the top-right corner. The header is pinned — it never scrolls.
--     divider  one hairline rule, inset by the card padding.
--     details  a vertically scrolling column of sections, each a subtle
--              uppercase label above a rounded dark container of compact
--              label/value rows:
--                ACCOUNT       user ID (+ COPY), join date, account age,
--                              friends, followers, key, whitelist
--                CURRENT GAME  thumbnail, game name, place ID
--                SERVER        players, server ID, uptime
--                USER SESSION  time in server
--
--   Every value is bound to a real source (see the DATA section below) and
--   falls back to a neutral "—" when the source is unavailable. Nothing on the
--   card is fabricated, and values the app treats as identifying stay masked
--   until "Reveal profile details" is on.
-- ]]

local profilePanel = {}

profilePanel.width = 260
profilePanel.gap = 12

-- [[Card metrics. Kept in lockstep with the layout code below; the scroll
-- [[region is the only part of the card that grows with content.]]
local avatarSize = 48
local avatarTop = 12
local paddingX = 12
local headerHeight = 74
local dividerHeight = 1
local scrollPaddingTop = 12
local scrollPaddingBottom = 16
local sectionGap = 12
local headingHeight = 13
local headingGap = 7
local headingIconSize = 12
local cardPaddingX = 10
local cardPaddingY = 10
local rowHeight = 18
local rowGap = 6
local rowIconSize = 12
local labelWidth = 92
local actionSize = 16
local actionInset = actionSize + 6
local gearSize = 26
local gearIconSize = 15
local gameThumbnailSize = 40
local tooltipHeight = 32
local scrollBarThickness = 6
local scrollBarTransparency = 0.8
local refreshInterval = 1

-- [[Neutral placeholder for a value the application cannot supply. Never a
-- [[made-up number: "—" reads as "no data" in every locale.]]
local fallbackValue = "—"

-- [[Placeholder shown in place of an identifier while the reveal toggle is
-- [[off: a fixed-width block, so neither the value nor its length leaks. Names
-- [[keep the sidebar mask ("Tes****") instead.]]
local maskedId = "••••••"
local maskedKey = "••••••••"

local nameTransparency = 0
local subtitleTransparency = 0.4
local labelTransparency = 0.45
local headingTransparency = 0.45
local iconTransparency = 0.35
local avatarBgTransparency = 0.95
local idleStrokeTransparency = 0.95
local hoverStrokeTransparency = 0.25
local cardStrokeTransparency = 0.55
local pillHoverTransparency = 0.92
local glowTransparency = 0.6

local settleTween = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local hoverTween = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local fallbackUri = "rbxassetid://0"

profilePanel.settleInfo = settleTween

local buildGeneration = 0

local avatarGenerations = setmetatable({}, { __mode = "k" })
local avatarReady = setmetatable({}, { __mode = "k" })
local gameThumbnailGenerations = setmetatable({}, { __mode = "k" })

local edgeMargin = 8

-- [[Effective card height: derived from the current window height so the]]
-- [[card never exceeds the window. At the default 420px window height the]]
-- [[card is exactly 420px; at other responsive sizes it matches the window.]]
function profilePanel.effectiveHeight(window): number
    if not window or not window.size then
        return 420
    end
    local windowH = window.size.Y.Offset
    if type(windowH) ~= "number" or windowH <= 0 then
        return 420
    end
    return windowH
end

local function currentCardHeight(window): number
    return profilePanel.effectiveHeight(window)
end

local function hasRoom(window): boolean
    local camera = state.workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize
    if not viewport then
        return true
    end
    if viewport.X < window.size.X.Offset + profilePanel.gap + profilePanel.width + edgeMargin * 2 then
        return false
    end
    local cardH = currentCardHeight(window)
    return viewport.Y >= cardH + edgeMargin * 2
end

-- [[The panel is "enabled" when its content should exist at all: the user]]
-- [[toggled it on, the player is known, and the screen has room. Window]]
-- [[visibility (hidden/minimised) layers on top in setShown.]]
function profilePanel.isEnabled(window): boolean
    return window.settings.showProfile
        and state.localPlayer ~= nil
        and hasRoom(window)
end

-- [[How far the window rests off the screen centre so that the]]
-- [[window + gap + panel pair is centred (0 while the panel is off).]]
function profilePanel.shiftFor(window): number
    if not profilePanel.isEnabled(window) then
        return 0
    end
    return (profilePanel.width + profilePanel.gap) / 2
end

-- [[Is the card on screen right now? `isEnabled` answers "should its]]
-- [[content exist" (setting + player + room); this adds the window's own]]
-- [[visibility, which is what the on-screen clamp cares about — a]]
-- [[minimised capsule must not be shoved around by a card that is not]]
-- [[there.]]
function profilePanel.isShown(window): boolean
    local panel = window.profilePanel
    return panel ~= nil and panel.Visible == true
end

-- [[Half-extents of the window + card pair, measured from the window's]]
-- [[centre: how far the pair reaches left, right and up/down. The card]]
-- [[height matches the window height, so vertical half-extent is simply]]
-- [[the window half. Returns the plain window halves while the card is not shown.]]
-- [[`width` / `height` override the window size for callers mid-animation (the drag]]
-- [[path measures the frame, which is smaller while minimised).]]
function profilePanel.pairHalfSize(window, width: number?, height: number?)
    local size = window.size
    local halfW = (width or size.X.Offset) / 2
    local halfH = (height or size.Y.Offset) / 2
    if not profilePanel.isShown(window) then
        return halfW, halfW, halfH
    end
    local extra = profilePanel.width + profilePanel.gap
    local left = (window.settings.profileSide or "right") == "left"
    local cardH = if height then height else currentCardHeight(window)
    local pairHalfH = math.max(halfH, cardH / 2)
    if left then
        return halfW + extra, halfW, pairHalfH
    end
    return halfW, halfW + extra, pairHalfH
end

-- [[The "Reveal profile details" toggle (persisted under the legacy]]
-- [[`showFullUsername` key). Off = every identifying value on the card is]]
-- [[masked; on = display name, username, user ID, place ID, server ID and]]
-- [[license key show in full.]]
function profilePanel.revealEnabled(window): boolean
    return window.settings.showFullUsername == true
end

-- [[The reveal toggle's prerequisite: it unmasks values that live ON the]]
-- [[card, so it is only meaningful while "Show profile" is on. Leaving it]]
-- [[active with the card off would silently unmask identity data the moment]]
-- [[the card came back, so the dependency is enforced rather than implied.]]
function profilePanel.revealAllowed(window): boolean
    return window.settings.showProfile == true
end

-- [[Driver for the "Reveal profile details" toggle. Refuses the on state]]
-- [[while "Show profile" is off: the setting stays off, the card stays]]
-- [[masked, and a notification says what is required first. Returns whether]]
-- [[the requested value was accepted, so the caller can roll its own switch]]
-- [[back to match.]]
function profilePanel.setReveal(window, enabled): boolean
    local want = enabled == true
    if want and not profilePanel.revealAllowed(window) then
        window.settings.showFullUsername = false
        profilePanel.applyIdentity(window)
        profilePanel.applyLive(window)
        window:Notify({
            title = locale.resolve("Show profile is required"),
            content = locale.resolve(
                "Turn on \"Show profile\" first. Profile details can only be revealed while the profile card is visible."
            ),
        })
        return false
    end
    window.settings.showFullUsername = want
    profilePanel.applyIdentity(window)
    profilePanel.applyLive(window)
    return true
end

-- [[Dependency normalisation for settings that arrive from somewhere other]]
-- [[than the toggle: a config saved before the rule existed (or edited by]]
-- [[hand) can carry reveal = on with the card off. Returns true when]]
-- [[something had to be corrected, so callers can resync a switch.]]
function profilePanel.syncReveal(window): boolean
    if window.settings.showFullUsername ~= true or profilePanel.revealAllowed(window) then
        return false
    end
    window.settings.showFullUsername = false
    profilePanel.applyIdentity(window)
    return true
end

-- =========================================================================
-- Formatting helpers
-- =========================================================================

-- [[Write a label's text only when it actually changes: the live refresh runs
-- [[every second, and touching a Text property repaints the tree.]]
local function setText(label, text)
    if label and label.Text ~= text then
        label.Text = text
    end
end

local function groupDigits(value: number): string
    local rounded = math.floor(math.abs(value))
    local text = tostring(rounded)
    local formatted = text:reverse():gsub("%d%d%d", "%1,"):reverse()
    if formatted:sub(1, 1) == "," then
        formatted = formatted:sub(2)
    end
    return if value < 0 then "-" .. formatted else formatted
end

-- [[Compact duration notation: "8s", "47m 12s", "2h 34m", "3d 4h". Used for]]
-- [[server uptime and the current session; a missing/negative source is the
-- [[neutral placeholder, never a zero that would read as real.]]
local function formatDuration(seconds: number?): string
    if type(seconds) ~= "number" or seconds ~= seconds or seconds < 0 then
        return fallbackValue
    end
    local total = math.floor(seconds)
    local days = math.floor(total / 86400)
    local hours = math.floor(total % 86400 / 3600)
    local minutes = math.floor(total % 3600 / 60)
    local secs = total % 60
    if days > 0 then
        return `{days}d {hours}h`
    end
    if hours > 0 then
        return `{hours}h {minutes}m`
    end
    if minutes > 0 then
        return `{minutes}m {secs}s`
    end
    return `{secs}s`
end

local monthNames = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }

-- [[Civil date from a Unix timestamp without relying on os.date, which some
-- [[executor sandboxes strip (Howard Hinnant's days-from-civil algorithm).]]
local function civilDate(daysSinceEpoch: number): (number, number, number)
    local z = daysSinceEpoch + 719468
    local era = math.floor(z / 146097)
    local doe = z - era * 146097
    local yoe = math.floor((doe - math.floor(doe / 1460) + math.floor(doe / 36524) - math.floor(doe / 146096)) / 365)
    local y = yoe + era * 400
    local doy = doe - (365 * yoe + math.floor(yoe / 4) - math.floor(yoe / 100))
    local mp = math.floor((5 * doy + 2) / 153)
    local d = doy - math.floor((153 * mp + 2) / 5) + 1
    local m = mp + (if mp < 10 then 3 else -9)
    y += (if m <= 2 then 1 else 0)
    return y, m, d
end

local function formatDate(unixSeconds: number?): string
    if type(unixSeconds) ~= "number" or unixSeconds <= 0 then
        return fallbackValue
    end
    local ok, y, m, d = pcall(function()
        return civilDate(math.floor(unixSeconds / 86400))
    end)
    if not ok or type(y) ~= "number" then
        return fallbackValue
    end
    local month = monthNames[m]
    if not month then
        return fallbackValue
    end
    return `{d} {month} {y}`
end

-- [[Account age in days -> the card's short readable form.]]
local function formatAccountAge(days: number?): string
    if type(days) ~= "number" or days ~= days or days < 0 then
        return fallbackValue
    end
    local total = math.floor(days)
    if total < 1 then
        return "Today"
    end
    if total < 31 then
        return if total == 1 then "1 day" else `{total} days`
    end
    local years = math.floor(total / 365.25)
    if years < 1 then
        local months = math.floor(total / 30.44)
        return if months <= 1 then "1 month" else `{months} months`
    end
    local remainder = math.floor((total - years * 365.25) / 30.44)
    local yearText = if years == 1 then "1 year" else `{years} years`
    if remainder < 1 then
        return yearText
    end
    return `{yearText} {remainder}mo`
end

local function nowSeconds(): number?
    local ok, value = pcall(function()
        return os.time()
    end)
    if ok and type(value) == "number" then
        return value
    end
    return nil
end

-- =========================================================================
-- Data sources
-- =========================================================================
-- [[Every value on the card comes from one of these, with a neutral fallback]]
-- [[when the source is unavailable.
--
--   display name / username / user ID  Players.LocalPlayer
--   premium pill                       LocalPlayer.MembershipType
--   join date / account age            LocalPlayer.AccountAge (days)
--   friends / followers                Roblox friends endpoints (public,
--                                      same request function as thumbnails)
--   game name                          DataModel.Name
--   place ID                           DataModel.PlaceId
--   game thumbnail                     thumbnails.roblox.com (DataModel.GameId)
--   players                            Players:GetPlayers() / Players.MaxPlayers
--   server ID                          DataModel.JobId
--   server uptime                      Workspace.DistributedGameTime
--   session time                       os.clock() since the client loaded
--   key / whitelist                    supplied by the host through
--                                      Window:SetProfile — no built-in store
-- ]]

local function sessionStartedAt(): number?
    local ok, value = pcall(function()
        return os.clock()
    end)
    if ok and type(value) == "number" then
        return value
    end
    return nil
end

local clientSessionStart = sessionStartedAt()

local function sessionSeconds(): number?
    if clientSessionStart == nil then
        return nil
    end
    local now = sessionStartedAt()
    if now == nil then
        return nil
    end
    return math.max(0, now - clientSessionStart)
end

-- [[Workspace.DistributedGameTime is the time the server has been running.
-- [[Roblox exposes no dedicated uptime API, so this is the server's own clock
-- [[rather than a value we invent.]]
local function serverUptimeSeconds(): number?
    local ok, value = pcall(function()
        return state.workspace.DistributedGameTime
    end)
    if ok and type(value) == "number" and value == value and value >= 0 then
        return value
    end
    return nil
end

local function getJobId(): string?
    local ok, value = pcall(function()
        return (game :: any).JobId
    end)
    if ok and type(value) == "string" and value ~= "" then
        return value
    end
    return nil
end

local function isStudio(): boolean
    local ok, value = pcall(function()
        return state.runService:IsStudio()
    end)
    return ok and value == true
end

local function playerCounts(): (number?, number?)
    local ok, players = pcall(function()
        return services.getService("Players")
    end)
    if not ok or players == nil then
        return nil, nil
    end
    local listOk, list = pcall(function()
        return players:GetPlayers()
    end)
    local maxOk, maxPlayers = pcall(function()
        return players.MaxPlayers
    end)
    local current = if listOk and type(list) == "table" then #list else nil
    local capacity = if maxOk and type(maxPlayers) == "number" and maxPlayers > 0 then maxPlayers else nil
    return current, capacity
end

-- [[MembershipType is the real Roblox source for the premium pill: legacy
-- [[Builders Club tiers count, Free/None do not. When the platform cannot be
-- [[read the pill stays hidden rather than claiming a status.]]
local function isPremium(player): boolean
    if not player then
        return false
    end
    local ok, membership = pcall(function()
        return player.MembershipType
    end)
    if not ok or membership == nil or typeof(membership) ~= "EnumItem" then
        return false
    end
    return membership ~= Enum.MembershipType.None and membership ~= Enum.MembershipType.Free
end

-- =========================================================================
-- Remote data: game thumbnail, friends / followers counts
-- =========================================================================

local resolvedGameIcons: { [number]: string? } = {}
local pendingGameIconRequests: { [number]: { (string?) -> () } } = {}
local resolvedCounts: { [number]: { friends: number?, followers: number? } } = {}
local pendingCountRequests: { [number]: { ({ friends: number?, followers: number? }) -> () } } = {}

local function toValidNumber(value: any): number?
    if type(value) == "number" and value > 0 then
        return value
    end
    if type(value) == "string" then
        local n = tonumber(value)
        if n and n > 0 then
            return n
        end
    end
    return nil
end

-- [[Counts may legitimately be 0, so they need their own coercion (the
-- [[identifier coercion above rejects 0 as "missing").]]
local function toCount(value: any): number?
    if type(value) == "number" and value == value and value >= 0 then
        return math.floor(value)
    end
    if type(value) == "string" then
        local n = tonumber(value)
        if n and n >= 0 then
            return math.floor(n)
        end
    end
    return nil
end

-- [[One shared JSON GET helper over the executor's request function — the
-- [[same `network.getRequestFn()` the rest of Astra uses. Missing request
-- [[function or a failed call hands the callback nil so every caller can fall
-- [[back to the neutral placeholder instead of inventing data.]]
local function requestJson(url: string, callback: (any?) -> ())
    local requestFn = network.getRequestFn()
    if not requestFn then
        callback(nil)
        return
    end
    task.spawn(function()
        local decoded = nil
        local ok, result = pcall(requestFn, {
            Url = url,
            Method = "GET",
        })
        if ok and type(result) == "table" then
            local body = (result :: any).Body
            local success = false
            if type((result :: any).StatusCode) == "number" then
                local code = (result :: any).StatusCode :: number
                success = code >= 200 and code < 300
            elseif type((result :: any).Success) == "boolean" then
                success = (result :: any).Success == true
            else
                success = type(body) == "string" and #body > 0
            end
            if success and type(body) == "string" and #body > 0 then
                local decodeOk, parsed = pcall(function()
                    return state.httpService:JSONDecode(body)
                end)
                if decodeOk then
                    decoded = parsed
                end
            end
        end
        callback(decoded)
    end)
end

local function getUniverseId(): number?
    local ok, result = pcall(function()
        return (game :: any).GameId
    end)
    if ok then
        return toValidNumber(result)
    end
    return nil
end

local function getPlaceId(): number?
    local ok, result = pcall(function()
        return (game :: any).PlaceId
    end)
    if ok then
        return toValidNumber(result)
    end
    return nil
end

local function buildFallbackUrl(placeId: number?): string
    if not placeId then
        return ""
    end
    -- [[Legacy rbxthumb GameIcon fallback: uses PlaceId in this runtime.]]
    return `rbxthumb://type=GameIcon&id={placeId}&w=150&h=150`
end

-- [[Roblox's official thumbnails endpoint expects the *universe* id
-- [[(game.GameId), not the place id. The displayed "Place ID" row still uses
-- [[game.PlaceId; the legacy rbxthumb fallback uses it as well, which is the
-- [[documented convention for that URI.]]
local function fetchOfficialGameIcon(universeId: number, callback: (string?) -> ())
    local cached = resolvedGameIcons[universeId]
    if cached ~= nil then
        callback(if type(cached) == "string" and cached ~= "" then cached else nil)
        return
    end

    local pending = pendingGameIconRequests[universeId]
    if pending then
        table.insert(pending, callback)
        return
    end

    pendingGameIconRequests[universeId] = { callback }

    task.spawn(function()
        local finalImageUrl: string? = nil
        local url = `https://thumbnails.roblox.com/v1/games/icons?universeIds={universeId}&size=512x512&format=Png&isCircular=false`
        requestJson(url, function(parsed)
            if type(parsed) == "table" then
                local data = (parsed :: any).data
                if type(data) == "table" then
                    -- [[Match by targetId; the response order is not guaranteed.]]
                    for _, entry in ipairs(data) do
                        if type(entry) == "table" then
                            local tid = (entry :: any).targetId or (entry :: any).targetID or (entry :: any).id
                            local stateName = (entry :: any).state
                            local matches = tonumber(tid) == universeId
                            if matches and (stateName == "Completed" or stateName == nil) then
                                local img = (entry :: any).imageUrl or (entry :: any).contentUrl or (entry :: any).url
                                if type(img) == "string" and #img > 0 then
                                    finalImageUrl = img
                                    break
                                end
                            end
                        end
                    end
                    -- [[Fallback: first completed entry, still real response data.]]
                    if not finalImageUrl then
                        for _, entry in ipairs(data) do
                            if type(entry) == "table" then
                                local stateName = (entry :: any).state
                                if stateName == "Completed" or stateName == nil then
                                    local img = (entry :: any).imageUrl or (entry :: any).contentUrl
                                    if type(img) == "string" and #img > 0 then
                                        finalImageUrl = img
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end

            if finalImageUrl and #finalImageUrl > 0 then
                resolvedGameIcons[universeId] = finalImageUrl
            end

            local callbacks = pendingGameIconRequests[universeId]
            pendingGameIconRequests[universeId] = nil
            for _, cb in ipairs(callbacks or {}) do
                pcall(cb, finalImageUrl)
            end
        end)
    end)
end

-- [[Friends and followers counts: Roblox's public friends endpoints (no auth
-- [[required). Both requests share one callback so a value only lands on the
-- [[card when the platform actually answered.]]
local function fetchProfileCounts(userId: number, callback: ({ friends: number?, followers: number? }) -> ())
    local cached = resolvedCounts[userId]
    if cached then
        callback(cached)
        return
    end

    local pending = pendingCountRequests[userId]
    if pending then
        table.insert(pending, callback)
        return
    end

    pendingCountRequests[userId] = { callback }

    task.spawn(function()
        local counts: { friends: number?, followers: number? } = {}
        local remaining = 2

        local function finish()
            remaining -= 1
            if remaining > 0 then
                return
            end
            if counts.friends ~= nil or counts.followers ~= nil then
                -- [[Only cache a real answer; a failed pair retries later.]]
                resolvedCounts[userId] = counts
            end
            local callbacks = pendingCountRequests[userId]
            pendingCountRequests[userId] = nil
            for _, cb in ipairs(callbacks or {}) do
                pcall(cb, counts)
            end
        end

        requestJson(`https://friends.roblox.com/v1/users/{userId}/friends/count`, function(parsed)
            if type(parsed) == "table" then
                counts.friends = toCount((parsed :: any).count)
            end
            finish()
        end)
        requestJson(`https://friends.roblox.com/v1/users/{userId}/followers/count`, function(parsed)
            if type(parsed) == "table" then
                counts.followers = toCount((parsed :: any).count)
            end
            finish()
        end)
    end)
end

-- =========================================================================
-- Card writers
-- =========================================================================

local function licenseDaysLeft(data, now: number?): number?
    local whitelist = data.whitelist
    if not whitelist then
        return nil
    end
    if type(whitelist.daysLeft) == "number" then
        return whitelist.daysLeft
    end
    if type(whitelist.expiresAt) == "number" and now then
        return math.ceil((whitelist.expiresAt - now) / 86400)
    end
    return nil
end

-- [[License + whitelist rows. Astra ships no key store of its own, so these
-- [[come from what the host handed to Window:SetProfile; with nothing supplied
-- [[the rows read "—" rather than showing a made-up key.]]
function profilePanel.applyLicense(window)
    local data = window.profileData or {}
    local reveal = profilePanel.revealEnabled(window)

    local key = data.key
    setText(window.profileKeyValue, if type(key) == "string" and key ~= ""
        then (if reveal then key else maskedKey)
        else fallbackValue)

    local days = licenseDaysLeft(data, nowSeconds())
    local status = if data.whitelist and type(data.whitelist.status) == "string" then data.whitelist.status else nil
    -- [[Compact, reference-shaped value: a countdown when one is known, the
    -- [[word "Expired" once it lapses, the host's own word when there is no
    -- [[expiry to count, and the neutral placeholder when there is neither.
    -- [[An unusual status ("Trial") is still spelled out, since dropping it
    -- [[would hide real information.]]
    local whitelistText
    if days == nil then
        whitelistText = status or fallbackValue
    elseif days < 0 then
        whitelistText = "Expired"
    else
        local dayText = if days == 1 then "1 day left" else `{days} days left`
        whitelistText = if status and string.lower(status) ~= "active" then `{status} · {dayText}` else dayText
    end
    setText(window.profileWhitelistValue, whitelistText)
end

-- [[Premium pill placement. The reference keeps the pill on the handle row,
-- [[so it rides just after the subtitle text; it only drops under the headline
-- [[when there is no subtitle, or when the pair would not fit before the
-- [[settings gear. Re-run whenever the headline or subtitle text changes.]]
function profilePanel.layoutPremium(window)
    local badge = window.profilePremium
    local subtitle = window.profileSubtitle
    if not badge or not subtitle then
        return
    end
    local width = badge.Size.X.Offset
    if width <= 0 then
        return
    end
    local nameX = paddingX + avatarSize + 10
    local limit = profilePanel.width - paddingX - gearSize - 8
    local belowY = 49
    local function inlineAfter(instance, y)
        local text = instance.Text
        local measured = if text == "" then 0 else functions.textWidth(window.theme.Font, instance.TextSize, text)
        local x = nameX + measured + 8
        if measured <= instance.Size.X.Offset and x + width <= limit then
            badge.Position = UDim2.fromOffset(x, y)
            return true
        end
        return false
    end
    if subtitle.Visible and subtitle.Text ~= "" then
        if inlineAfter(subtitle, subtitle.Position.Y.Offset - 0.5) then
            return
        end
        badge.Position = UDim2.fromOffset(nameX, belowY)
        return
    end
    if not inlineAfter(window.profileName, 13) then
        badge.Position = UDim2.fromOffset(nameX, belowY)
    end
end

-- [[Write every identity field on the card from the current player and the]]
-- [[reveal toggle: display name, @username, premium pill, user ID (with its]]
-- [[COPY action), place ID, server ID and the license rows. nil-safe on both]]
-- [[the instances and the player, so a missing player leaves placeholders]]
-- [[rather than erroring.]]
function profilePanel.applyIdentity(window)
    local player = state.localPlayer
    local reveal = profilePanel.revealEnabled(window)
    local data = window.profileData or {}

    local username = ""
    local displayName = ""
    if player then
        username = tostring(player.Name or "")
        displayName = tostring(player.DisplayName or "")
        if displayName == "" then
            displayName = username
        end
    end

    local name = window.profileName
    if name then
        setText(
            name,
            if displayName == "" then ""
                elseif reveal then displayName
                else sidebar.maskUsername(displayName)
        )
    end

    local subtitle = window.profileSubtitle
    if subtitle then
        -- [[An explicit Window:SetProfile subtitle wins over the generated
        -- [[@username: it is the developer's own copy, not identity data, so
        -- [[the reveal toggle leaves it untouched.]]
        local custom = if type(data.subtitle) == "string" and data.subtitle ~= "" then data.subtitle else nil
        local text = if custom then locale.resolve(custom) else nil
        if text == nil and username ~= "" then
            text = "@" .. (if reveal then username else sidebar.maskUsername(username))
        end
        setText(subtitle, text or "")
        subtitle.Visible = subtitle.Text ~= ""
    end
    profilePanel.layoutPremium(window)

    local premium = window.profilePremium
    if premium then
        premium.Visible = isPremium(player)
    end

    local userId = window.profileUserIdValue
    if userId then
        local id = if player and player.UserId then tostring(player.UserId) else ""
        setText(userId, if id == "" then fallbackValue elseif reveal then id else maskedId)
    end

    local copy = window.profileCopyUserId
    if copy then
        copy.Visible = reveal and player ~= nil
    end

    local placeId = window.profilePlaceId
    if placeId then
        local id = getPlaceId()
        setText(placeId, if not id then fallbackValue elseif reveal then tostring(id) else maskedId)
    end

    local serverId = window.profileServerIdValue
    if serverId then
        local jobId = getJobId()
        if not jobId then
            -- [[Studio / local test servers have no JobId: say so instead of
            -- [[showing a stale or invented server.]]
            setText(serverId, if isStudio() then "Studio" else fallbackValue)
        else
            setText(serverId, if reveal then jobId else maskedId)
        end
    end

    if window.profileJoinDateValue then
        local accountAge = if player and type(player.AccountAge) == "number" then player.AccountAge else nil
        local now = nowSeconds()
        setText(
            window.profileJoinDateValue,
            if accountAge and now then formatDate(now - accountAge * 86400) else fallbackValue
        )
        setText(window.profileAccountAgeValue, formatAccountAge(accountAge))
    end

    profilePanel.applyLicense(window)
end

-- [[Friends / followers counts arrive asynchronously; this is the sink they
-- [[land in. Guarded by the build generation so a rebuilt or unloaded card
-- [[never receives them.]]
function profilePanel.applyCounts(window, counts)
    if window.unloaded or not counts then
        return
    end
    if counts.friends ~= nil then
        setText(window.profileFriendsValue, groupDigits(counts.friends))
    else
        setText(window.profileFriendsValue, fallbackValue)
    end
    if counts.followers ~= nil then
        setText(window.profileFollowersValue, groupDigits(counts.followers))
    else
        setText(window.profileFollowersValue, fallbackValue)
    end
end

-- [[Live values: player count, server uptime and the current session. Called
-- [[by the refresh loop, by reveal changes and whenever the card comes back.]]
function profilePanel.applyLive(window)
    if window.unloaded or not window.profileDetails then
        return
    end

    local current, capacity = playerCounts()
    setText(
        window.profilePlayersValue,
        if current ~= nil and capacity ~= nil then `{current} / {capacity}` else fallbackValue
    )

    setText(window.profileUptimeValue, formatDuration(serverUptimeSeconds()))
    setText(window.profileSessionValue, formatDuration(sessionSeconds()))

    -- [[A whitelist entry that expires at a timestamp counts down here too.]]
    profilePanel.applyLicense(window)
end

-- =========================================================================
-- Card construction
-- =========================================================================

local function sectionHeight(rowCount: number): number
    if rowCount <= 0 then
        return cardPaddingY * 2
    end
    return cardPaddingY * 2 + rowCount * rowHeight + (rowCount - 1) * rowGap
end

local function addRow(window, card, spec)
    local fade = function(instance, prop, shown)
        table.insert(window.profileFadeTargets, { instance = instance, prop = prop, shown = shown })
    end

    local y = spec.y
    local x = spec.x or cardPaddingX
    local textX = x
    local rowLabelWidth = spec.labelWidth or labelWidth
    if spec.icon then
        local icon = window:Create("ImageLabel", {
            Name = spec.name .. "Icon",
            Image = window:ResolveIcon(spec.icon),
            Position = UDim2.fromOffset(x, y + 3),
            Size = UDim2.fromOffset(rowIconSize, rowIconSize),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ImageTransparency = 1,
            Parent = card,
        }, { ImageColor3 = spec.iconColor or "PlaceholderColor" })
        fade(icon, "ImageTransparency", iconTransparency)
        textX = x + rowIconSize + 5
    end

    local label = window:Create("TextLabel", {
        Name = spec.name .. "Label",
        Text = spec.label,
        Position = UDim2.fromOffset(textX, y),
        Size = UDim2.fromOffset(rowLabelWidth, rowHeight),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextTransparency = 1,
        Parent = card,
    }, { TextColor3 = "PlaceholderColor", FontFace = "Font" })
    fade(label, "TextTransparency", labelTransparency)

    local inset = if spec.action then actionInset else 0
    local value = window:Create("TextLabel", {
        Name = spec.instanceName or (spec.name .. "Value"),
        Text = fallbackValue,
        Position = UDim2.fromOffset(textX + rowLabelWidth, y),
        Size = UDim2.new(1, -(textX + rowLabelWidth + cardPaddingX + inset), 0, rowHeight),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        TextSize = spec.valueSize or 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextTransparency = 1,
        Parent = card,
    }, { TextColor3 = spec.valueColor or "TitlingColor", FontFace = "Font" })
    fade(value, "TextTransparency", nameTransparency)

    if spec.action == "copy" then
        local button = window:Create("TextButton", {
            Name = "CopyUserId",
            Text = "",
            Position = UDim2.new(1, -(cardPaddingX + actionSize), 0, y + (rowHeight - actionSize) / 2),
            Size = UDim2.fromOffset(actionSize, actionSize),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            TextTransparency = 1,
            Visible = false,
            Parent = card,
        })
        local icon = window:Create("ImageLabel", {
            Name = "Icon",
            Image = window:ResolveIcon("copy"),
            Size = UDim2.fromOffset(13, 13),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            BackgroundTransparency = 1,
            ImageTransparency = 1,
            Parent = button,
        }, { ImageColor3 = "ActionColor" })
        fade(icon, "ImageTransparency", 0.15)
        window.profileCopyUserId = button
        window:Connect(button.Activated, function()
            -- [[The action only exists while the ID is revealed: with the
            -- [[detail hidden there is nothing meaningful to copy, and the
            -- [[button is hidden too (applyIdentity).]]
            if not profilePanel.revealEnabled(window) then
                return
            end
            local current = state.localPlayer
            if setclipboard and current then
                setclipboard(tostring(current.UserId))
            end
        end)
    end

    -- [[Hover-help for values that do not fit: the row's full text is shown in
    -- [[a small themed tooltip above (or below) the row.]]
    local tooltipY = (spec.cardY or 0) + y
    window:Connect(value.MouseEnter, function()
        local text = value.Text
        if text == "" or text == fallbackValue then
            return
        end
        local available = value.AbsoluteSize.X
        local measured = functions.textWidth(window.theme.Font, value.TextSize, text)
        if available <= 0 or measured <= available then
            return
        end
        profilePanel.showTooltip(window, text, tooltipY)
    end)
    window:Connect(value.MouseLeave, function()
        profilePanel.hideTooltip(window)
    end)

    return value
end

-- [[Position and reveal the hover tooltip. It lives on the card surface (not
-- [[inside the scroll region) so it is never clipped by the scrolling area;
-- [[`detailsY` is the row's offset from the top of the card's content.]]
function profilePanel.showTooltip(window, text, contentY: number)
    local tip = window.profileTooltip
    if not tip or not window.profileTooltipLabel then
        return
    end
    local details = window.profileDetails
    local scrollY = 0
    if details then
        local ok, canvasPosition = pcall(function()
            return details.CanvasPosition
        end)
        if ok and canvasPosition and typeof(canvasPosition) ~= "number" then
            scrollY = canvasPosition.Y or 0
        end
    end
    local cardH = currentCardHeight(window)
    local y = headerHeight + dividerHeight + (contentY - scrollY) - tooltipHeight - 6
    y = math.clamp(y, 4, math.max(4, cardH - tooltipHeight - 4))
    setText(window.profileTooltipLabel, text)
    tip.Position = UDim2.fromOffset(paddingX + cardPaddingX, y)
    tip.Visible = true
    state.tweenService:Create(tip, hoverTween, { BackgroundTransparency = 0 }):Play()
    state.tweenService:Create(window.profileTooltipLabel, hoverTween, { TextTransparency = 0 }):Play()
end

function profilePanel.hideTooltip(window)
    local tip = window.profileTooltip
    if not tip or not tip.Visible then
        return
    end
    state.tweenService:Create(tip, hoverTween, { BackgroundTransparency = 1 }):Play()
    if window.profileTooltipLabel then
        state.tweenService:Create(window.profileTooltipLabel, hoverTween, { TextTransparency = 1 }):Play()
    end
    task.delay(hoverTween.Time, function()
        if tip.Parent and tip.BackgroundTransparency >= 1 then
            tip.Visible = false
        end
    end)
end

function profilePanel.build(window, onOpenSettings)
    if window.profilePanel then
        window:DestroySubtree(window.profilePanel)
        window.profilePanel = nil
    end

    local player = state.localPlayer
    local cardHeight = currentCardHeight(window)
    profilePanel.height = cardHeight
    window.profileFadeTargets = {}

    window.profilePanel = window:Create("Frame", {
        Name = "ProfilePanel",
        AnchorPoint = Vector2.new(0, 0),
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.fromOffset(profilePanel.width, cardHeight),
        BackgroundTransparency = 1,
        ZIndex = 1,
        Visible = false,

        Parent = window.screenGui,
    })

    -- [[The card surface: a visible themed plate (the gradient supplies]]
    -- [[the colour; transparency stays 0 so the card actually shows).]]
    window.profilePanelSurface = window:Create("Frame", {
        Name = "Surface",
        Size = UDim2.fromScale(1, 1),
        BorderSizePixel = 0,
        BackgroundTransparency = 0,
        Parent = window.profilePanel,
    })

    window:Create("UIGradient", {
        Rotation = 270,
        Offset = Vector2.new(0, -0.1),
        Parent = window.profilePanelSurface,
    }, { Color = { "WindowColor", functions.toColorSequence } })

    window.profilePanelCorner = window:Create("UICorner", {
        Parent = window.profilePanelSurface,
    }, { CornerRadius = "CornerRoundness" })

    window.profilePanelStroke = window:Create("UIStroke", {
        Transparency = 1,
        Parent = window.profilePanelSurface,
    }, { Color = "SurfaceStroke" })

    window.profilePanelGlow = window:CreateGlow(window.profilePanelSurface, "ShadowColor", 20, 1)

    -- [[Everything the card fades in/out as a unit registers here once: the
    -- [[panel show/hide pass then just walks the list.]]
    local function fade(instance, prop, shown)
        table.insert(window.profileFadeTargets, { instance = instance, prop = prop, shown = shown })
    end

    -- ===== header: avatar + presence, name / username / premium, gear =====

    window.profileAvatar = window:Create("ImageLabel", {
        Name = "Avatar",
        Position = UDim2.fromOffset(paddingX, avatarTop),
        Size = UDim2.fromOffset(avatarSize, avatarSize),
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        ImageTransparency = 1,
        Parent = window.profilePanelSurface,
    }, { BackgroundColor3 = "ContentColor" })

    window:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = window.profileAvatar,
    })
    window:Create("UIStroke", {
        Thickness = 1,
        Transparency = 0.4,
        Parent = window.profileAvatar,
    }, { Color = "SurfaceStroke" })

    local onlineDot = window:Create("Frame", {
        Name = "Online",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.fromOffset(paddingX + avatarSize, avatarTop + avatarSize),
        Size = UDim2.fromOffset(12, 12),
        BorderSizePixel = 0,
        Parent = window.profilePanelSurface,
    }, { BackgroundColor3 = "Success" })
    window:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = onlineDot })
    window:Create("UIStroke", {
        Thickness = 2,
        Transparency = 0,
        Parent = onlineDot,
    }, { Color = "Background" })

    local nameX = paddingX + avatarSize + 10
    local nameWidth = profilePanel.width - nameX - gearSize - 14

    -- [[The headline/subtitle are filled by applyIdentity at the end of the
    -- [[build, so the card never flashes an unmasked display name first.]]
    window.profileName = window:Create("TextLabel", {
        Name = "Name",
        Text = "",
        Position = UDim2.fromOffset(nameX, 12),
        Size = UDim2.fromOffset(nameWidth, 18),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = false,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextTransparency = 1,
        Parent = window.profilePanelSurface,
    }, { TextColor3 = "TitlingColor", FontFace = "Font" })

    fade(window.profileName, "TextTransparency", nameTransparency)

    window.profileSubtitle = window:Create("TextLabel", {
        Name = "Subtitle",
        Text = "",
        Position = UDim2.fromOffset(nameX, 31),
        Size = UDim2.fromOffset(nameWidth, 15),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = false,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Visible = false,
        TextTransparency = 1,
        Parent = window.profilePanelSurface,
    }, { TextColor3 = "ContentColor", FontFace = "Font" })

    fade(window.profileSubtitle, "TextTransparency", subtitleTransparency)

    -- [[PREMIUM pill: only shown while the platform reports a paid
    -- [[membership (MembershipType), never as decoration. The pill width is
    -- [[measured from its own label so it stays a fixed, predictable box.]]
    local premiumLabelText = "PREMIUM"
    local premiumTextWidth = functions.textWidth(window.theme.Font, 9, premiumLabelText)
    local premiumPaddingLeft = 6
    local premiumPaddingRight = 7
    local premiumIconSize = 10
    local premiumGap = 4
    local premiumWidth = premiumPaddingLeft + premiumIconSize + premiumGap + premiumTextWidth + premiumPaddingRight
    local premium = window:Create("Frame", {
        Name = "PremiumBadge",
        Position = UDim2.fromOffset(nameX, 49),
        Size = UDim2.fromOffset(premiumWidth, 16),
        BorderSizePixel = 0,
        Visible = false,
        Parent = window.profilePanelSurface,
    }, { BackgroundColor3 = "ElementSurface", BackgroundTransparency = "ElementTransparency" })
    window.profilePremium = premium
    window:Create("UICorner", {
        Parent = premium,
    }, { CornerRadius = "PillCornerRadius" })
    window:Create("UIStroke", {
        Transparency = 0.35,
        Parent = premium,
    }, { Color = "ElementStroke" })
    local premiumIcon = window:Create("ImageLabel", {
        Name = "Crown",
        Image = window:ResolveIcon("crown"),
        Position = UDim2.fromOffset(premiumPaddingLeft, 3),
        Size = UDim2.fromOffset(premiumIconSize, premiumIconSize),
        BackgroundTransparency = 1,
        Parent = premium,
    }, { ImageColor3 = "AccentColor" })
    local premiumLabel = window:Create("TextLabel", {
        Name = "Label",
        Text = premiumLabelText,
        Position = UDim2.fromOffset(premiumPaddingLeft + premiumIconSize + premiumGap, 0),
        Size = UDim2.fromOffset(premiumTextWidth, 16),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTransparency = 1,
        Parent = premium,
    }, { TextColor3 = "AccentColor", FontFace = "Font" })
    fade(premiumIcon, "ImageTransparency", 0)
    fade(premium, "BackgroundTransparency", 0)
    fade(premiumLabel, "TextTransparency", 0)

    -- [[Header hover-help for a truncated display name.]]
    window:Connect(window.profileName.MouseEnter, function()
        local text = window.profileName.Text
        if text == "" then
            return
        end
        local available = window.profileName.AbsoluteSize.X
        if available <= 0 or functions.textWidth(window.theme.Font, window.profileName.TextSize, text) <= available then
            return
        end
        profilePanel.showTooltip(window, text, 12)
    end)
    window:Connect(window.profileName.MouseLeave, function()
        profilePanel.hideTooltip(window)
    end)

    -- [[Divider under the pinned header.]]
    window.profileDivider = window:Create("Frame", {
        Name = "Divider",
        Position = UDim2.fromOffset(paddingX, headerHeight),
        Size = UDim2.new(1, -paddingX * 2, 0, dividerHeight),
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        Parent = window.profilePanelSurface,
    }, { BackgroundColor3 = "ElementStroke" })
    table.insert(window.profileFadeTargets, {
        instance = window.profileDivider,
        prop = "BackgroundTransparency",
        shown = 0.5,
    })

    local function label(parent, name, text, position, size, textSize, color, align, transparency)
        local instance = window:Create("TextLabel", {
            Name = name,
            Text = text,
            Position = position,
            Size = size,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            TextSize = textSize,
            TextXAlignment = align or Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextTransparency = 1,
            Parent = parent,
        }, { TextColor3 = color, FontFace = "Font" })
        fade(instance, "TextTransparency", transparency or nameTransparency)
        return instance
    end

    -- ===== scrollable details =====

    window.profileDetails = window:Create("ScrollingFrame", {
        Name = "Details",
        Position = UDim2.fromOffset(0, headerHeight + dividerHeight),
        Size = UDim2.new(1, 0, 1, -(headerHeight + dividerHeight)),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
        ScrollBarImageTransparency = scrollBarTransparency,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ClipsDescendants = true,
        Parent = window.profilePanelSurface,
    })

    local content = window:Create("Frame", {
        Name = "Content",
        Position = UDim2.fromOffset(0, scrollPaddingTop),
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = window.profileDetails,
    })
    window.profileDetailsContent = content

    -- [[Section heading: a small muted icon + uppercase label, matching the
    -- [[way the rest of the window titles its groups.]]
    local function heading(y: number, title: string, iconName: string): number
        local icon = window:Create("ImageLabel", {
            Name = title .. "Icon",
            Image = window:ResolveIcon(iconName),
            Position = UDim2.fromOffset(paddingX, y + 1),
            Size = UDim2.fromOffset(headingIconSize, headingIconSize),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ImageTransparency = 1,
            Parent = content,
        }, { ImageColor3 = "PlaceholderColor" })
        fade(icon, "ImageTransparency", iconTransparency)

        label(
            content,
            title,
            string.upper(title),
            UDim2.fromOffset(paddingX + headingIconSize + 5, y),
            UDim2.new(1, -(paddingX * 2 + headingIconSize + 5), 0, headingHeight),
            10,
            "PlaceholderColor",
            Enum.TextXAlignment.Left,
            headingTransparency
        )
        return y + headingHeight + headingGap
    end

    -- [[Rounded dark container for a section's rows.]]
    local function card(y: number, name: string, height: number)
        local frame = window:Create("Frame", {
            Name = name,
            Position = UDim2.fromOffset(paddingX, y),
            Size = UDim2.new(1, -paddingX * 2, 0, height),
            BorderSizePixel = 0,
            Parent = content,
        }, { BackgroundColor3 = "CardSurface", BackgroundTransparency = "ElementTransparency" })
        window:Create("UICorner", { Parent = frame }, { CornerRadius = "ElementCornerRadius" })
        window:Create("UIStroke", {
            Transparency = cardStrokeTransparency,
            Parent = frame,
        }, { Color = "ElementStroke" })
        fade(frame, "BackgroundTransparency", 0)
        return frame
    end

    local y = 0

    -- ===== ACCOUNT =====

    local accountRows = {
        { name = "UserId", label = "USER ID", icon = "id-card", action = "copy" },
        { name = "JoinDate", label = "JOIN DATE", icon = "calendar-days" },
        { name = "AccountAge", label = "ACCOUNT AGE", icon = "hourglass" },
        { name = "Friends", label = "FRIENDS", icon = "users-round", instanceName = "Friends" },
        { name = "Followers", label = "FOLLOWERS", icon = "user-round", instanceName = "Followers" },
        { name = "Key", label = "KEY", icon = "key-round", labelWidth = 62, valueSize = 12 },
        { name = "Whitelist", label = "WHITELIST", icon = "shield-check", labelWidth = 62, valueSize = 12 },
    }

    y = heading(y, "ACCOUNT", "user-round")
    local accountCardY = y
    local accountCard = card(y, "AccountCard", sectionHeight(#accountRows))
    for index, row in ipairs(accountRows) do
        local value = addRow(window, accountCard, {
            name = row.name,
            label = row.label,
            icon = row.icon,
            action = row.action,
            instanceName = row.instanceName,
            labelWidth = row.labelWidth,
            valueSize = row.valueSize,
            y = cardPaddingY + (index - 1) * (rowHeight + rowGap),
            cardY = accountCardY,
        })
        if row.name == "UserId" then
            window.profileUserIdValue = value
        elseif row.name == "JoinDate" then
            window.profileJoinDateValue = value
        elseif row.name == "AccountAge" then
            window.profileAccountAgeValue = value
        elseif row.name == "Friends" then
            window.profileFriendsValue = value
        elseif row.name == "Followers" then
            window.profileFollowersValue = value
        elseif row.name == "Key" then
            window.profileKeyValue = value
        elseif row.name == "Whitelist" then
            window.profileWhitelistValue = value
        end
    end
    y = accountCardY + sectionHeight(#accountRows) + sectionGap

    -- ===== CURRENT GAME =====

    y = heading(y, "CURRENT GAME", "gamepad-2")
    local gameCardY = y
    local gameCardHeight = cardPaddingY * 2 + gameThumbnailSize
    local gameCard = card(y, "CurrentGame", gameCardHeight)

    local gameThumbnail = window:Create("ImageLabel", {
        Name = "GameThumbnail",
        Image = "",
        Position = UDim2.fromOffset(cardPaddingX, cardPaddingY),
        Size = UDim2.fromOffset(gameThumbnailSize, gameThumbnailSize),
        BorderSizePixel = 0,
        BackgroundTransparency = 0,
        Parent = gameCard,
    }, { BackgroundColor3 = "ElementSurface" })
    window:Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = gameThumbnail })
    window:Create("UIStroke", {
        Transparency = cardStrokeTransparency,
        Parent = gameThumbnail,
    }, { Color = "ElementStroke" })

    local gameNameX = cardPaddingX + gameThumbnailSize + 10
    local gameName = label(
        gameCard,
        "GameName",
        tostring(game.Name or fallbackValue),
        UDim2.fromOffset(gameNameX, cardPaddingY),
        UDim2.new(1, -(gameNameX + cardPaddingX), 0, 17),
        13,
        "TitlingColor"
    )
    window.profilePlaceId = addRow(window, gameCard, {
        name = "PlaceId",
        label = "Place ID",
        instanceName = "GameBy",
        y = cardPaddingY + 22,
        x = gameNameX,
        labelWidth = 52,
        cardY = gameCardY,
    })

    window:Connect(gameName.MouseEnter, function()
        local text = gameName.Text
        if text == "" or text == fallbackValue then
            return
        end
        local available = gameName.AbsoluteSize.X
        if available <= 0 or functions.textWidth(window.theme.Font, gameName.TextSize, text) <= available then
            return
        end
        profilePanel.showTooltip(window, text, gameCardY + cardPaddingY)
    end)
    window:Connect(gameName.MouseLeave, function()
        profilePanel.hideTooltip(window)
    end)

    y = gameCardY + gameCardHeight + sectionGap

    -- ===== SERVER =====

    local serverRows = {
        { name = "Players", label = "PLAYERS", icon = "users" },
        { name = "ServerId", label = "SERVER ID", icon = "server" },
        { name = "Uptime", label = "SERVER UPTIME", icon = "timer" },
    }

    y = heading(y, "SERVER", "server")
    local serverCardY = y
    local serverCard = card(y, "ServerCard", sectionHeight(#serverRows))
    for index, row in ipairs(serverRows) do
        local value = addRow(window, serverCard, {
            name = row.name,
            label = row.label,
            icon = row.icon,
            y = cardPaddingY + (index - 1) * (rowHeight + rowGap),
            cardY = serverCardY,
        })
        if row.name == "Players" then
            window.profilePlayersValue = value
        elseif row.name == "ServerId" then
            window.profileServerIdValue = value
        elseif row.name == "Uptime" then
            window.profileUptimeValue = value
        end
    end
    y = serverCardY + sectionHeight(#serverRows) + sectionGap

    -- ===== USER SESSION =====

    y = heading(y, "USER SESSION", "clock")
    local sessionCardY = y
    local sessionCard = card(y, "SessionCard", sectionHeight(1))
    window.profileSessionValue = addRow(window, sessionCard, {
        name = "Session",
        label = "TIME IN SERVER",
        icon = "activity",
        y = cardPaddingY,
        cardY = sessionCardY,
    })
    y = sessionCardY + sectionHeight(1) + sectionGap

    content.Size = UDim2.new(1, 0, 0, y)
    window.profileDetails.CanvasSize = UDim2.fromOffset(0, scrollPaddingTop + y + scrollPaddingBottom)

    -- [[Hover tooltip surface. Parented to the card (not the scroll region) so
    -- [[it is never clipped by the scrolling area.]]
    local tooltip = window:Create("Frame", {
        Name = "Tooltip",
        Position = UDim2.fromOffset(paddingX + cardPaddingX, 40),
        Size = UDim2.new(1, -(paddingX * 2 + cardPaddingX * 2), 0, tooltipHeight),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 10,
        Parent = window.profilePanelSurface,
    }, { BackgroundColor3 = "PopupSurface" })
    window.profileTooltip = tooltip
    window:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = tooltip })
    window:Create("UIStroke", {
        Transparency = 0.25,
        Parent = tooltip,
    }, { Color = "ElementStroke" })
    window:Create("UIPadding", {
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        Parent = tooltip,
    })
    window.profileTooltipLabel = window:Create("TextLabel", {
        Name = "Label",
        Text = "",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        TextSize = 11,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextTransparency = 1,
        Parent = tooltip,
    }, { TextColor3 = "ContentColor", FontFace = "Font" })

    -- ===== settings gear, top-right of the header =====

    window.profileGear = window:Create("TextButton", {
        Name = "OpenSettings",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -8, 0, 10),
        Size = UDim2.fromOffset(gearSize, gearSize),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        TextTransparency = 1,
        ZIndex = 3,
        Parent = window.profilePanelSurface,
    })

    window.profileGearPill = window:Create("Frame", {
        Name = "HoverPill",
        Size = UDim2.fromScale(1, 1),
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        ZIndex = 1,
        Parent = window.profileGear,
    }, { BackgroundColor3 = "ElementHover" })

    window:Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = window.profileGearPill,
    })

    window.profileGearIcon = window:Create("ImageLabel", {
        Name = "Icon",
        Image = window:ResolveIcon(constants.icons.settings),
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(gearIconSize, gearIconSize),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        ImageTransparency = 1,
        ZIndex = 2,
        Parent = window.profileGear,
    }, { ImageColor3 = "ActionColor" })

    fade(window.profileGearIcon, "ImageTransparency", 0)

    window:Connect(window.profileGear.MouseEnter, function()
        if not window:_interactive() then
            return
        end
        state.tweenService
            :Create(window.profileGearPill, hoverTween, { BackgroundTransparency = pillHoverTransparency })
            :Play()
        state.tweenService
            :Create(
                window.profilePanelStroke,
                hoverTween,
                { Color = window.theme.ElementStrokeHover, Transparency = hoverStrokeTransparency }
            )
            :Play()
    end)

    window:Connect(window.profileGear.MouseLeave, function()
        state.tweenService
            :Create(window.profileGearPill, hoverTween, { BackgroundTransparency = 1 })
            :Play()
        state.tweenService
            :Create(
                window.profilePanelStroke,
                hoverTween,
                { Color = window.theme.SurfaceStroke, Transparency = idleStrokeTransparency }
            )
            :Play()
    end)

    window:Connect(window.profileGear.Activated, function()
        if not window:_interactive() or not onOpenSettings then
            return
        end
        local ok, err = pcall(onOpenSettings)
        if not ok then
            log.warn("Astra: the profile panel's settings action failed: " .. tostring(err))
        end
    end)

    -- [[The panel is a sibling of the window frame: mirroring the frame's]]
    -- [[position keeps it following drags, restores and resizes without a]]
    -- [[per-frame loop.]]
    window:Connect(window.main:GetPropertyChangedSignal("Position"), function()
        profilePanel.layout(window)
    end)
    window:Connect(window.main:GetPropertyChangedSignal("Size"), function()
        profilePanel.layout(window)
    end)

    -- [[Live values (player count, uptime, session) refresh on a slow tick
    -- [[while the card is on screen; the connection is created once per window
    -- [[so rebuilds cannot stack loops.]]
    if not window.profileRefreshConnection then
        local elapsed = 0
        window.profileRefreshConnection = window:Connect(state.runService.Heartbeat, function(dt: number)
            if window.unloaded then
                return
            end
            elapsed += dt
            if elapsed < refreshInterval then
                return
            end
            elapsed = 0
            if profilePanel.isShown(window) then
                profilePanel.applyLive(window)
            end
        end)
    end

    -- [[Avatar: same generation guard as the rest of the card so a rebuilt or
    -- [[unloaded panel never receives a stale image.]]
    buildGeneration += 1
    local generation = buildGeneration
    window.profileBuildGeneration = generation
    gameThumbnailGenerations[gameThumbnail] = generation

    local function safeAssign(url: string)
        if window.unloaded or gameThumbnailGenerations[gameThumbnail] ~= generation then
            return
        end
        if not gameThumbnail.Parent then
            return
        end
        image.assign(gameThumbnail, "Image", url)
    end

    local universeId = getUniverseId()
    local fallbackUrl = buildFallbackUrl(getPlaceId())
    if universeId then
        local cachedIcon = resolvedGameIcons[universeId]
        if type(cachedIcon) == "string" and cachedIcon ~= "" then
            safeAssign(cachedIcon)
        else
            fetchOfficialGameIcon(universeId, function(officialUrl: string?)
                if officialUrl and officialUrl ~= "" then
                    safeAssign(officialUrl)
                elseif fallbackUrl ~= "" then
                    safeAssign(fallbackUrl)
                end
            end)
        end
    elseif fallbackUrl ~= "" then
        safeAssign(fallbackUrl)
    end

    if player then
        local avatarGeneration = generation
        avatarGenerations[window.profileAvatar] = avatarGeneration

        local function applyAvatar(avatarLabel, uri)
            if avatarGenerations[avatarLabel] ~= avatarGeneration then
                return
            end
            if uri ~= nil and uri ~= "" then
                avatarReady[avatarLabel] = true
                image.assign(avatarLabel, "Image", uri)
                -- [[The avatar may finish loading after the panel already
                -- [[faded in: reveal it now instead of waiting for the
                -- [[next show/hide cycle.]]
                if window.profilePanel and window.profilePanel.Visible then
                    state.tweenService:Create(avatarLabel, settleTween, { ImageTransparency = 0 }):Play()
                end
            else
                avatarReady[avatarLabel] = nil
                image.assign(avatarLabel, "Image", fallbackUri)
            end
        end

        local cachedUri = image.avatar(player.UserId, function(uri)
            if window.unloaded then
                return
            end
            local avatar = window.profileAvatar
            if not avatar then
                return
            end
            applyAvatar(avatar, uri)
        end)

        if cachedUri ~= "" then
            applyAvatar(window.profileAvatar, cachedUri)
        end

        -- [[Public profile counts: fetched once per build and applied through
        -- [[the generation guard. Unavailable counts stay "—".]]
        local userId = tonumber(player.UserId)
        if userId then
            fetchProfileCounts(userId, function(counts)
                if window.unloaded or window.profileBuildGeneration ~= generation then
                    return
                end
                profilePanel.applyCounts(window, counts)
            end)
        end
    end

    profilePanel.applyIdentity(window)
    profilePanel.applyLive(window)
    profilePanel.layout(window)
    return window.profilePanel
end

-- [[Place the card beside the window frame, vertically centred on the]]
-- [[window's centre. The frame's position may carry scale (the centred]]
-- [[resting position) or be pure offset after a drag: the scale passes]]
-- [[through untouched, the offset gets the half-window + gap edge. The]]
-- [[card's height is derived from window.size.Y.Offset so it never exceeds]]
-- [[the window and aligns top/bottom edges with the window at default size.]]
function profilePanel.layout(window)
    local panel = window.profilePanel
    if not panel then
        return
    end

    local main = window.main
    local pos = main.Position
    local width = main.Size.X.Offset
    local left = (window.settings.profileSide or "right") == "left"
    local edge = width / 2 + profilePanel.gap
    local cardH = currentCardHeight(window)
    profilePanel.height = cardH

    panel.AnchorPoint = Vector2.new(if left then 1 else 0, 0)
    panel.Position = UDim2.new(
        pos.X.Scale,
        pos.X.Offset + (if left then -edge else edge),
        pos.Y.Scale,
        pos.Y.Offset - cardH / 2
    )
    panel.Size = UDim2.fromOffset(profilePanel.width, cardH)

    -- [[The details region takes whatever the pinned header leaves. The
    -- [[scrollbar only appears when the sections are taller than that region,
    -- [[and the content narrows by its width so nothing slides underneath.]]
    local details = window.profileDetails
    local content = window.profileDetailsContent
    if not (details and content) then
        return
    end
    local regionHeight = math.max(0, cardH - headerHeight - dividerHeight)
    details.Size = UDim2.new(1, 0, 0, regionHeight)
    local scrollable = content.Size.Y.Offset > math.max(0, regionHeight - scrollPaddingTop - scrollPaddingBottom)
    details.ScrollBarThickness = if scrollable then scrollBarThickness else 0
    content.Size = UDim2.new(1, if scrollable then -scrollBarThickness else 0, 0, content.Size.Y.Offset)
end

function profilePanel.setShown(window, shown, tweenInfo)
    local panel = window.profilePanel
    if not panel then
        return
    end

    -- [[Window visibility wins over the requested state: never fade the]]
    -- [[panel in while the window is hidden or minimised.]]
    shown = shown == true
        and profilePanel.isEnabled(window)
        and not window.hidden
        and not window.minimised

    local avatar = window.profileAvatar
    local stroke = window.profilePanelStroke
    local glow = window.profilePanelGlow

    panel.Visible = shown

    if not (avatar and stroke) then
        return
    end

    if shown then
        -- [[Fresh values the moment the card (re)appears.]]
        profilePanel.applyLive(window)
    end

    local hasImage = avatarReady[avatar] == true
        or (type(avatar.Image) == "string" and avatar.Image ~= "" and avatar.Image ~= fallbackUri)

    local targets: { [Instance]: { [string]: any } } = {
        [avatar] = {
            ImageTransparency = if shown and hasImage then 0 else 1,
            BackgroundTransparency = if shown then avatarBgTransparency else 1,
        },
        [stroke] = { Transparency = if shown then idleStrokeTransparency else 1 },
    }

    if glow then
        targets[glow] = { Transparency = if shown then glowTransparency else 1 }
    end

    for _, entry in ipairs(window.profileFadeTargets or {}) do
        local props = targets[entry.instance]
        if not props then
            props = {}
            targets[entry.instance] = props
        end
        props[entry.prop] = if shown then entry.shown else 1
    end

    for instance, props in targets do
        local needsUpdate = false
        for prop, value in props do
            if instance[prop] ~= value then
                needsUpdate = true
                break
            end
        end
        if not needsUpdate then
            continue
        end
        if tweenInfo then
            state.tweenService:Create(instance, tweenInfo, props):Play()
        else
            for prop, value in props do
                instance[prop] = value
            end
        end
    end
end

function profilePanel.setEnabled(window, enabled)
    window.settings.showProfile = enabled == true

    -- [[The reveal toggle depends on the card, so switching the card off]]
    -- [[switches the reveal off with it: it can never sit active while]]
    -- [[there is nothing on screen to reveal. The caller (the settings UI)]]
    -- [[rolls its own switch back from the return value.]]
    local revealCleared = false
    if not window.settings.showProfile and window.settings.showFullUsername then
        window.settings.showFullUsername = false
        revealCleared = true
    end
    profilePanel.applyIdentity(window)

    profilePanel.setShown(window, window.settings.showProfile, settleTween)
    window:_recenterForProfile(window.settings.showProfile)

    if revealCleared then
        window:Notify({
            title = locale.resolve("Reveal profile details"),
            content = locale.resolve(
                "Turned off with the profile card: it unmasks the values on that card, so it needs \"Show profile\" to be on."
            ),
        })
    end

    -- [[The toggle is only half the story: the card also needs a player and]]
    -- [[room on screen (260px beside the window, window-height tall). A missing]]
    -- [[player resolves itself through the late-player waiter in Window.new,]]
    -- [[but a small viewport would otherwise leave the user looking at an]]
    -- [[active toggle and no card — so say why.]]
    if window.settings.showProfile and state.localPlayer and not hasRoom(window) then
        window:Notify({
            title = locale.resolve("Profile card"),
            content = locale.resolve(
                "This screen has no room for the profile card, so it stays hidden. It needs 260px beside the window and enough height for the window — enlarge the window or rotate the device and it appears."
            ),
        })
    end

    return revealCleared
end

function profilePanel.setSide(window, side)
    window.settings.profileSide = if side == "left" then "left" else "right"
    profilePanel.layout(window)
    window:_recenterForProfile(true)
end

-- [[Window:SetProfile accepts either the legacy subtitle string / nil or a
-- [[table carrying everything the card's host-owned rows show:
-- [[  { subtitle = "…", key = "…", whitelist = { status = "Active", daysLeft = 14 } }
-- [[`whitelist.expiresAt` (unix seconds) is accepted instead of `daysLeft` and
-- [[counted down live. Anything not supplied reads "—".]]
function profilePanel.setProfile(window, props)
    if type(props) ~= "table" then
        -- [[Legacy call shape: a subtitle string (or nil to clear it). The
        -- [[host's key / whitelist rows are left exactly as they were.]]
        return profilePanel.setSubtitle(window, props)
    end

    local data = {}
    if type(props) == "table" then
        local subtitle = props.subtitle or props.Subtitle
        if type(subtitle) == "string" and subtitle ~= "" then
            data.subtitle = subtitle
        end
        local key = props.key or props.Key
        if type(key) == "string" and key ~= "" then
            data.key = key
        end
        local whitelist = props.whitelist or props.Whitelist
        if type(whitelist) == "table" then
            local status = whitelist.status or whitelist.Status
            local daysLeft = whitelist.daysLeft or whitelist.DaysLeft
            local expiresAt = whitelist.expiresAt or whitelist.ExpiresAt
            data.whitelist = {
                status = if type(status) == "string" and status ~= "" then status else nil,
                daysLeft = if type(daysLeft) == "number" then daysLeft else nil,
                expiresAt = if type(expiresAt) == "number" then expiresAt else nil,
            }
        end
    end
    window.profileData = data
    window.profileText = data.subtitle
    profilePanel.applyIdentity(window)
    profilePanel.applyLive(window)
    return data
end

-- [[Legacy setter (string / nil): swaps the subtitle while leaving any key or
-- [[whitelist the host supplied in place.]]
function profilePanel.setSubtitle(window, text)
    if type(text) == "table" then
        return profilePanel.setProfile(window, text)
    end
    local data = window.profileData or {}
    -- [[Copy before mutating: the caller may still hold the table it passed.]]
    data = { subtitle = data.subtitle, key = data.key, whitelist = data.whitelist }
    data.subtitle = if type(text) == "string" and text ~= "" then text else nil
    window.profileData = data
    window.profileText = data.subtitle
    profilePanel.applyIdentity(window)
end

-- [[Kept as an alias: the reveal toggle no longer drives the name alone, so]]
-- [[refreshing the name refreshes the whole identity block.]]
function profilePanel.refreshName(window)
    profilePanel.applyIdentity(window)
end

return profilePanel
