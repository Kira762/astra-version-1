local utilities = script.Parent.Parent.utilities
local state = require(utilities.Parent.core.state)
local image = require(script.Parent.Parent.images.image)
local functions = require(script.Parent.Parent.functions)
local locale = require(utilities.locale)
local log = require(utilities.log)
local constants = require(utilities.constants)
local sidebar = require(script.Parent.sidebar)

local profilePanel = {}

-- [[The profile panel lives OUTSIDE the window frame, beside it: a]]
-- [[companion card with its own content-driven height, vertically]]
-- [[centred against the window. The window and the panel are centred]]
-- [[on screen as a single unit, so the window sits half a panel]]
-- [[(width + gap) away from the screen centre, on the opposite side]]
-- [[of the panel.]]
-- A full profile card, intentionally wide enough for the Roblox-style details
-- layout. Content stacks top-to-bottom in one flow — avatar, name, username,
-- premium badge, account details, current game, settings gear — so nothing
-- ever overlaps no matter how tall the window is. Every colour below is a
-- theme binding (rather than a hard-coded colour), so ChangeTheme refreshes
-- the card along with the rest of the UI.
profilePanel.width = 280
profilePanel.gap = 12

local avatarSize = 72
local paddingX = 16
local topPad = 16
local iconSize = 16
local indent = iconSize + 7 -- value text aligns under the label text, past its icon

-- [[Vertical flow (y offsets from the panel top). Kept as explicit steps so]]
-- [[the stack reads like the design mock, top to bottom.]]
local avatarTop = topPad -- 16..88
local nameTop = avatarTop + avatarSize + 8 -- 96..118
local nameHeight = 22
local subtitleTop = nameTop + nameHeight + 3 -- 121..137
local subtitleHeight = 16
local badgeTop = subtitleTop + subtitleHeight + 6 -- 143..159
local badgeHeight = 16
local rule1Top = badgeTop + badgeHeight + 12 -- 171
local detailsHeadingTop = rule1Top + 12 -- 183..201
local userIdLabelTop = detailsHeadingTop + 26 -- 209..227
local userIdValueTop = userIdLabelTop + 19 -- 228..248
local joinLabelTop = userIdValueTop + 28 -- 256..274
local joinValueTop = joinLabelTop + 19 -- 275..295
local friendsTop = joinValueTop + 28 -- 303..321
local followersTop = friendsTop + 18 -- 321..339
local rule2Top = followersTop + 30 -- 351
local gameHeadingTop = rule2Top + 12 -- 363..381
local gameCardTop = gameHeadingTop + 26 -- 389..445
local gameCardHeight = 56
local gearSize = 32
local gearIconSize = 20
local gearBottomMargin = 12

-- [[The card hugs its content: last row + breathing room + the gear zone.]]
profilePanel.height = gameCardTop + gameCardHeight + 11 + gearSize + gearBottomMargin -- 500

local nameTransparency = 0
local subtitleTransparency = 0.7
local avatarBgTransparency = 0.95
local idleStrokeTransparency = 0.6
local hoverStrokeTransparency = 0.25
local pillHoverTransparency = 0.92

local settleTween = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local hoverTween = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local fallbackUri = "rbxassetid://0"

-- [[Placeholder shown in place of a numeric identifier while the reveal]]
-- [[toggle is off: a fixed-width block, so neither the value nor its]]
-- [[length leaks. Names keep the sidebar mask ("Tes****") instead.]]
local maskedId = "••••••"

profilePanel.settleInfo = settleTween

local buildGeneration = 0

local avatarGenerations = setmetatable({}, { __mode = "k" })

local avatarReady = setmetatable({}, { __mode = "k" })

-- [[The panel needs room on both axes: window + gap + panel must fit]]
-- [[horizontally (the pair is centred, so both edges keep a small]]
-- [[margin), and the card's own height must fit vertically. This is a]]
-- [[space check, not a device check: a portrait phone has no room and]]
-- [[hides the panel, while a landscape phone (and every desktop)]
-- [[usually has room and shows it.]]
local edgeMargin = 8

local function hasRoom(window)
    local camera = state.workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize
    if not viewport then
        return true
    end
    if viewport.X < window.size.X.Offset + profilePanel.gap + profilePanel.width + edgeMargin * 2 then
        return false
    end
    return viewport.Y >= profilePanel.height + edgeMargin * 2
end

-- [[The panel is "enabled" when its content should exist at all: the user]]
-- [[toggled it on, the player is known, and the screen has room. Window]]
-- [[visibility (hidden/minimised) layers on top in setShown.]]
function profilePanel.isEnabled(window)
    return window.settings.showProfile
        and state.localPlayer ~= nil
        and hasRoom(window)
end

-- [[How far the window rests off the screen centre so that the]]
-- [[window + gap + panel pair is centred (0 while the panel is off).]]
function profilePanel.shiftFor(window)
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
function profilePanel.isShown(window)
    local panel = window.profilePanel
    return panel ~= nil and panel.Visible == true
end

-- [[Half-extents of the window + card pair, measured from the window's]]
-- [[centre: how far the pair reaches left, right and up/down. The card]]
-- [[widens one side by its width + gap and, at 500px tall, can out-tall a]]
-- [[short window — so a clamp that only knew the window's own half size let]]
-- [[the card hang off the edge while the window itself stayed "on screen".]]
-- [[Returns the plain window halves while the card is not shown. `width` /]]
-- [[`height` override the window size for callers mid-animation (the drag]]
-- [[path measures the frame, which is smaller while minimised).]]
function profilePanel.pairHalfSize(window, width, height)
    local size = window.size
    local halfW = (width or size.X.Offset) / 2
    local halfH = (height or size.Y.Offset) / 2
    if not profilePanel.isShown(window) then
        return halfW, halfW, halfH
    end
    local extra = profilePanel.width + profilePanel.gap
    local left = (window.settings.profileSide or "right") == "left"
    local pairHalfH = math.max(halfH, profilePanel.height / 2)
    if left then
        return halfW + extra, halfW, pairHalfH
    end
    return halfW, halfW + extra, pairHalfH
end

-- [[The "Reveal profile details" toggle (persisted under the legacy]]
-- [[`showFullUsername` key). Off = every identifying value on the card is]]
-- [[masked; on = display name, username, user ID and place ID show in full.]]
function profilePanel.revealEnabled(window)
    return window.settings.showFullUsername == true
end

-- [[The reveal toggle's prerequisite: it unmasks values that live ON the]]
-- [[card, so it is only meaningful while "Show profile" is on. Leaving it]]
-- [[active with the card off would silently unmask identity data the moment]]
-- [[the card came back, so the dependency is enforced rather than implied.]]
function profilePanel.revealAllowed(window)
    return window.settings.showProfile == true
end

-- [[Driver for the "Reveal profile details" toggle. Refuses the on state]]
-- [[while "Show profile" is off: the setting stays off, the card stays]]
-- [[masked, and a notification says what is required first. Returns whether]]
-- [[the requested value was accepted, so the caller can roll its own switch]]
-- [[back to match.]]
function profilePanel.setReveal(window, enabled)
    local want = enabled == true
    if want and not profilePanel.revealAllowed(window) then
        window.settings.showFullUsername = false
        profilePanel.applyIdentity(window)
        window:Notify({
            title = locale.resolve("Show profile is required"),
            content = locale.resolve(
                "\"Reveal profile details\" unmasks the display name, username, user ID and place ID on the profile card, so it needs that card to be showing. Turn on \"Show profile\" first — until then this stays off."
            ),
        })
        return false
    end
    window.settings.showFullUsername = want
    profilePanel.applyIdentity(window)
    return true
end

-- [[Dependency normalisation for settings that arrive from somewhere other]]
-- [[than the toggle: a config saved before the rule existed (or edited by]]
-- [[hand) can carry reveal = on with the card off. Returns true when]]
-- [[something had to be corrected, so callers can resync a switch.]]
function profilePanel.syncReveal(window)
    if window.settings.showFullUsername ~= true or profilePanel.revealAllowed(window) then
        return false
    end
    window.settings.showFullUsername = false
    profilePanel.applyIdentity(window)
    return true
end

-- [[Write every identity field on the card from the current player and the]]
-- [[reveal toggle: display name (headline), @username (subtitle), user ID]]
-- [[(with its COPY action) and place ID (current-game card). Called at the]]
-- [[end of the build, by the toggle, and whenever the local player turns up]]
-- [[after construction — it is nil-safe on both the instances and the]]
-- [[player, so a missing player leaves placeholders rather than erroring.]]
function profilePanel.applyIdentity(window)
    local player = state.localPlayer
    local reveal = profilePanel.revealEnabled(window)

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
        name.Text = if displayName == "" then ""
            elseif reveal then displayName
            else sidebar.maskUsername(displayName)
    end

    local subtitle = window.profileSubtitle
    if subtitle then
        -- [[An explicit Window:SetProfile text wins over the generated]]
        -- [[@username: it is the developer's own copy, not identity data,]]
        -- [[so the reveal toggle leaves it untouched.]]
        local custom = window.profileText
        local text = if type(custom) == "string" and custom ~= "" then locale.resolve(custom) else nil
        if text == nil and username ~= "" then
            text = "@" .. (if reveal then username else sidebar.maskUsername(username))
        end
        subtitle.Text = text or ""
        subtitle.Visible = subtitle.Text ~= ""
    end

    local userId = window.profileUserIdValue
    if userId then
        local id = if player then tostring(player.UserId or "") else ""
        userId.Text = if id == "" then "-" elseif reveal then id else maskedId
    end

    local copy = window.profileCopyUserId
    if copy then
        copy.Visible = reveal and player ~= nil
    end

    local placeId = window.profilePlaceId
    if placeId then
        local id = tostring(game.PlaceId or "")
        if id == "" or id == "0" then
            placeId.Text = "Place ID: -"
        else
            placeId.Text = "Place ID: " .. (if reveal then id else maskedId)
        end
    end
end

function profilePanel.build(window, onOpenSettings)
    if window.profilePanel then
        window:DestroySubtree(window.profilePanel)
        window.profilePanel = nil
    end

    local player = state.localPlayer

    window.profilePanel = window:Create("Frame", {
        Name = "ProfilePanel",
        AnchorPoint = Vector2.new(0, 0),
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.fromOffset(profilePanel.width, profilePanel.height),
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

    window:CreateGlow(window.profilePanelSurface, "ShadowColor", 20, 1)

    -- ===== header: avatar + presence dot + name + username + badge =====

    window.profileAvatar = window:Create("ImageLabel", {
        Name = "Avatar",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, avatarTop),
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

    local onlineDot = window:Create("Frame", {
        Name = "Online",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, avatarSize / 2 + 12, 0, avatarTop + avatarSize / 2),
        Size = UDim2.fromOffset(12, 12),
        BorderSizePixel = 0,
        Parent = window.profilePanelSurface,
    }, { BackgroundColor3 = "Success" })
    window:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = onlineDot })

    -- [[The headline text is filled by applyIdentity at the end of the]]
    -- [[build, so it never flashes an unmasked display name first.]]
    window.profileName = window:Create("TextLabel", {
        Name = "Name",
        Text = "",
        Size = UDim2.new(1, -paddingX * 2, 0, nameHeight),
        Position = UDim2.new(0, paddingX, 0, nameTop),
        BackgroundTransparency = 1,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = false,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextTransparency = 1,
        Parent = window.profilePanelSurface,
    }, { TextColor3 = "TitlingColor", FontFace = "Font" })

    window.profileSubtitle = window:Create("TextLabel", {
        Name = "Subtitle",
        Text = "",
        Size = UDim2.new(1, -paddingX * 2, 0, subtitleHeight),
        Position = UDim2.new(0, paddingX, 0, subtitleTop),
        BackgroundTransparency = 1,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = false,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Visible = false,
        TextTransparency = 1,
        Parent = window.profilePanelSurface,
    }, { TextColor3 = "TitlingColor", FontFace = "Font" })

    window:Create("TextLabel", {
        Name = "PremiumBadge",
        Text = "PREMIUM",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, badgeTop),
        Size = UDim2.fromOffset(84, badgeHeight),
        BackgroundTransparency = 1,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = window.profilePanelSurface,
    }, { TextColor3 = "AccentColor", FontFace = "Font" })

    -- ===== details stack =====

    local function label(name, text, position, size, textSize, color)
        return window:Create("TextLabel", {
            Name = name,
            Text = text,
            Position = position,
            Size = size,
            BackgroundTransparency = 1,
            TextSize = textSize or 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = window.profilePanelSurface,
        }, { TextColor3 = color or "ContentColor", FontFace = "Font" })
    end

    local function iconLabel(name, iconName, text, y, height, textSize, color)
        window:Create("ImageLabel", {
            Name = name .. "Icon",
            Image = window:ResolveIcon(iconName),
            Position = UDim2.fromOffset(paddingX, y + 1),
            Size = UDim2.fromOffset(iconSize, iconSize),
            BackgroundTransparency = 1,
            ImageTransparency = 0.15,
            Parent = window.profilePanelSurface,
        }, { ImageColor3 = color or "ContentColor" })
        return label(
            name,
            text,
            UDim2.fromOffset(paddingX + indent, y),
            UDim2.new(1, -paddingX * 2 - indent, 0, height),
            textSize,
            color
        )
    end

    local function rule(y)
        window:Create("Frame", {
            Name = "Divider",
            Position = UDim2.new(0, paddingX, 0, y),
            Size = UDim2.new(1, -paddingX * 2, 0, 1),
            BorderSizePixel = 0,
            Parent = window.profilePanelSurface,
        }, { BackgroundColor3 = "ElementStroke" })
    end

    rule(rule1Top)
    iconLabel("DetailsHeading", "info", "ACCOUNT DETAILS", detailsHeadingTop, 18, 11, "ActionColor")

    iconLabel("UserId", "id-card", "User ID", userIdLabelTop, 18, 12)
    window.profileUserIdValue = label(
        "UserIdValue",
        "-",
        UDim2.fromOffset(paddingX + indent, userIdValueTop),
        UDim2.new(1, -paddingX * 2 - indent - 48, 0, 20),
        14,
        "TitlingColor"
    )
    window.profileCopyUserId = window:Create("TextButton", {
        Name = "CopyUserId",
        Text = "COPY",
        Position = UDim2.new(1, -paddingX - 44, 0, userIdValueTop + 1),
        Size = UDim2.fromOffset(44, 18),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        TextSize = 10,
        Parent = window.profilePanelSurface,
    }, { TextColor3 = "ActionColor", FontFace = "Font" })
    window:Connect(window.profileCopyUserId.Activated, function()
        -- [[The action only exists while the ID is revealed: with the]]
        -- [[detail hidden there is nothing meaningful to copy, and the]]
        -- [[button is hidden too (applyIdentity).]]
        if not profilePanel.revealEnabled(window) then
            return
        end
        local current = state.localPlayer
        if setclipboard and current then
            setclipboard(tostring(current.UserId))
        end
    end)

    iconLabel("JoinDate", "calendar-days", "Join date", joinLabelTop, 18, 12)
    label(
        "JoinDateValue",
        if player then ("Account age: " .. tostring(player.AccountAge) .. " days") else "-",
        UDim2.fromOffset(paddingX + indent, joinValueTop),
        UDim2.new(1, -paddingX * 2 - indent, 0, 20),
        14,
        "TitlingColor"
    )

    iconLabel("Friends", "users-round", "Friends  -", friendsTop, 18, 12, "PlaceholderColor")
    label("Followers", "Followers  -", UDim2.fromOffset(paddingX + indent, followersTop), UDim2.new(1, -paddingX * 2 - indent, 0, 18), 12, "PlaceholderColor")

    rule(rule2Top)
    iconLabel("GameHeading", "gamepad-2", "CURRENT GAME", gameHeadingTop, 18, 11, "ActionColor")

    -- ===== current game card =====

    local gameCard = window:Create("Frame", {
        Name = "CurrentGame",
        Position = UDim2.fromOffset(paddingX, gameCardTop),
        Size = UDim2.new(1, -paddingX * 2, 0, gameCardHeight),
        BorderSizePixel = 0,
        Parent = window.profilePanelSurface,
    }, { BackgroundColor3 = "CardSurface" })
    window:Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = gameCard })
    window:Create("UIStroke", {
        Transparency = 0.5,
        Parent = gameCard,
    }, { Color = "ElementStroke" })

    local gameThumbnail = window:Create("ImageLabel", {
        Name = "GameThumbnail",
        Image = "",
        Position = UDim2.fromOffset(8, 8),
        Size = UDim2.fromOffset(40, 40),
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        Parent = gameCard,
    })
    window:Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = gameThumbnail })
    image.assign(gameThumbnail, "Image", `rbxthumb://type=GameIcon&id={game.PlaceId}&w=150&h=150`)

    label("GameName", tostring(game.Name or ""), UDim2.fromOffset(paddingX + 56, gameCardTop + 10), UDim2.new(1, -paddingX * 2 - 64, 0, 18), 13, "TitlingColor")
    window.profilePlaceId = label(
        "GameBy",
        "Place ID: -",
        UDim2.fromOffset(paddingX + 56, gameCardTop + 30),
        UDim2.new(1, -paddingX * 2 - 64, 0, 16),
        10
    )

    -- ===== settings gear, pinned to the card's bottom edge =====

    window.profileGear = window:Create("TextButton", {
        Name = "OpenSettings",
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, -gearBottomMargin),
        Size = UDim2.fromOffset(gearSize, gearSize),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        TextTransparency = 1,
        ZIndex = 2,
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
        CornerRadius = UDim.new(0, 12),
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

    if player then
        buildGeneration += 1
        local generation = buildGeneration
        avatarGenerations[window.profileAvatar] = generation

        local function applyAvatar(avatarLabel, uri)
            if avatarGenerations[avatarLabel] ~= generation then
                return
            end
            if uri ~= nil and uri ~= "" then
                avatarReady[avatarLabel] = true
                image.assign(avatarLabel, "Image", uri)
                -- [[The avatar may finish loading after the panel already]]
                -- [[faded in: reveal it now instead of waiting for the]]
                -- [[next show/hide cycle.]]
                if window.profilePanel.Visible then
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
    end

    profilePanel.applyIdentity(window)
    profilePanel.layout(window)
    return window.profilePanel
end

-- [[Place the card beside the window frame, vertically centred on the]]
-- [[window's centre. The frame's position may carry scale (the centred]]
-- [[resting position) or be pure offset after a drag: the scale passes]]
-- [[through untouched, the offset gets the half-window + gap edge. The]]
-- [[card's height is intrinsic (its stacked content), so the interior]]
-- [[never needs reflow.]]
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

    panel.AnchorPoint = Vector2.new(if left then 1 else 0, 0)
    panel.Position = UDim2.new(
        pos.X.Scale,
        pos.X.Offset + (if left then -edge else edge),
        pos.Y.Scale,
        pos.Y.Offset - profilePanel.height / 2
    )
    panel.Size = UDim2.fromOffset(profilePanel.width, profilePanel.height)
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
    local name = window.profileName
    local subtitle = window.profileSubtitle
    local gearIcon = window.profileGearIcon
    local stroke = window.profilePanelStroke

    panel.Visible = shown

    if not (avatar and name and subtitle and gearIcon and stroke) then
        return
    end

    local hasImage = avatarReady[avatar] == true
        or (type(avatar.Image) == "string" and avatar.Image ~= "" and avatar.Image ~= fallbackUri)

    local targets = {
        [avatar] = {
            ImageTransparency = if shown and hasImage then 0 else 1,
            BackgroundTransparency = if shown then avatarBgTransparency else 1,
        },
        [name] = { TextTransparency = if shown then nameTransparency else 1 },
        [subtitle] = { TextTransparency = if shown then subtitleTransparency else 1 },
        [gearIcon] = { ImageTransparency = if shown then 0 else 1 },
        [stroke] = { Transparency = if shown then idleStrokeTransparency else 1 },
    }

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
    -- [[room on screen (280px beside the window, 500px of height). A missing]]
    -- [[player resolves itself through the late-player waiter in Window.new,]]
    -- [[but a small viewport would otherwise leave the user looking at an]]
    -- [[active toggle and no card — so say why.]]
    if window.settings.showProfile and state.localPlayer and not hasRoom(window) then
        window:Notify({
            title = locale.resolve("Profile card"),
            content = locale.resolve(
                "This screen has no room for the profile card, so it stays hidden. It needs 280px beside the window and 500px of height — enlarge the window or rotate the device and it appears."
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

function profilePanel.setSubtitle(window, text)
    -- [[The custom subtitle (if any) is kept on the window so applyIdentity]]
    -- [[can prefer it over the generated @username on every refresh.]]
    window.profileText = text
    profilePanel.applyIdentity(window)
end

-- [[Kept as an alias: the reveal toggle no longer drives the name alone, so]]
-- [[refreshing the name refreshes the whole identity block.]]
function profilePanel.refreshName(window)
    profilePanel.applyIdentity(window)
end

return profilePanel
