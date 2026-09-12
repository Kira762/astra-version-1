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
-- [[96px-wide companion card that spans the window's full height. The]]
-- [[window and the panel are centred on screen as a single unit, so]]
-- [[the window sits half a panel (width + gap) away from the screen]]
-- [[centre, on the opposite side of the panel.]]
-- A full profile card, intentionally wide enough for the Roblox-style details
-- layout. Every colour below is a theme binding (rather than a hard-coded
-- colour), so ChangeTheme refreshes the card along with the rest of the UI.
profilePanel.width = 280
profilePanel.gap = 12

local avatarSize = 72
local nameGap = 10
local nameHeight = 24
local subGap = 3
local subHeight = 18
local paddingX = 16
local contentMinTop = 18
local gearSize = 32
local gearIconSize = 20
local gearBottomMargin = 12

local contentHeight = avatarSize + nameGap + nameHeight + subGap + subHeight

local nameTransparency = 0
local subtitleTransparency = 0.7
local avatarBgTransparency = 0.95
local idleStrokeTransparency = 0.95
local hoverStrokeTransparency = 0.65
local pillHoverTransparency = 0.92

local settleTween = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local hoverTween = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local fallbackUri = "rbxassetid://0"

profilePanel.settleInfo = settleTween

local buildGeneration = 0

local avatarGenerations = setmetatable({}, { __mode = "k" })

local avatarReady = setmetatable({}, { __mode = "k" })

-- [[The panel needs horizontal room: window + gap + panel must fit on the]]
-- [[screen (the pair is centred, so both edges keep a small margin). This]]
-- [[is a space check, not a device check: a portrait phone has no room and]]
-- [[hides the panel, while a landscape phone (and every desktop) usually]]
-- [[has room and shows it.]]
local edgeMargin = 8

local function hasRoom(window)
    local camera = state.workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize
    if not viewport then
        return true
    end
    return viewport.X >= window.size.X.Offset + profilePanel.gap + profilePanel.width + edgeMargin * 2
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
        Size = UDim2.fromOffset(profilePanel.width, window.size.Y.Offset),
        BackgroundTransparency = 1,
        ZIndex = 1,
        Visible = false,

        Parent = window.screenGui,
    })

    window.profilePanelSurface = window:Create("Frame", {
        Name = "Surface",
        Size = UDim2.fromScale(1, 1),
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
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

    window.profileAvatar = window:Create("ImageLabel", {
        Name = "Avatar",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, contentMinTop),
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
        Name = "Online", AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, avatarSize / 2 - 4, 0, contentMinTop + avatarSize - 4),
        Size = UDim2.fromOffset(14, 14), BorderSizePixel = 0, Parent = window.profilePanelSurface,
    }, { BackgroundColor3 = "Success" })
    window:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = onlineDot })

    window.profileName = window:Create("TextLabel", {
        Name = "Name",
        Text = if player then player.DisplayName else "",
        Size = UDim2.new(1, -paddingX * 2, 0, nameHeight),
        Position = UDim2.new(0, paddingX, 0, contentMinTop + avatarSize + nameGap),
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
        Size = UDim2.new(1, -paddingX * 2, 0, subHeight),
        Position = UDim2.new(0, paddingX, 0, contentMinTop + avatarSize + nameGap + nameHeight + subGap),
        BackgroundTransparency = 1,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = false,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Visible = false,
        TextTransparency = 1,
        Parent = window.profilePanelSurface,
    }, { TextColor3 = "TitlingColor", FontFace = "Font" })

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

    local function iconLabel(name, iconName, text, position, size, textSize, color)
        local iconSize = 16
        window:Create("ImageLabel", {
            Name = name .. "Icon",
            Image = window:ResolveIcon(iconName),
            Position = position,
            Size = UDim2.fromOffset(iconSize, iconSize),
            BackgroundTransparency = 1,
            ImageTransparency = 0.15,
            Parent = window.profilePanelSurface,
        }, { ImageColor3 = color or "ContentColor" })
        return label(
            name,
            text,
            UDim2.new(position.X.Scale, position.X.Offset + iconSize + 7, position.Y.Scale, position.Y.Offset - 1),
            UDim2.new(size.X.Scale, size.X.Offset - iconSize - 7, size.Y.Scale, size.Y.Offset),
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

    rule(150)
    iconLabel("DetailsHeading", "info", "ACCOUNT DETAILS", UDim2.fromOffset(paddingX, 163), UDim2.new(1, -paddingX * 2, 0, 18), 11, "ActionColor")
    iconLabel("UserId", "id-card", "User ID", UDim2.fromOffset(paddingX, 190), UDim2.new(1, -paddingX * 2, 0, 18), 12)
    local userId = label("UserIdValue", if player then tostring(player.UserId) else "-", UDim2.fromOffset(paddingX, 207), UDim2.new(1, -paddingX * 2 - 48, 0, 20), 14, "TitlingColor")
    local copy = window:Create("TextButton", {
        Name = "CopyUserId", Text = "COPY", Position = UDim2.new(1, -paddingX - 44, 0, 208),
        Size = UDim2.fromOffset(44, 18), BackgroundTransparency = 1, BorderSizePixel = 0,
        TextSize = 10, Parent = window.profilePanelSurface,
    }, { TextColor3 = "ActionColor", FontFace = "Font" })
    window:Connect(copy.Activated, function()
        if setclipboard and player then setclipboard(tostring(player.UserId)) end
    end)
    iconLabel("JoinDate", "calendar-days", "Join date", UDim2.fromOffset(paddingX, 238), UDim2.new(1, -paddingX * 2, 0, 18), 12)
    label("JoinDateValue", if player then ("Account age: " .. tostring(player.AccountAge) .. " days") else "-", UDim2.fromOffset(paddingX, 255), UDim2.new(1, -paddingX * 2, 0, 20), 14, "TitlingColor")
    iconLabel("SocialStats", "users-round", "Friends     -        Followers     -", UDim2.fromOffset(paddingX, 286), UDim2.new(1, -paddingX * 2, 0, 20), 12, "PlaceholderColor")
    rule(318)
    iconLabel("GameHeading", "gamepad-2", "CURRENT GAME", UDim2.fromOffset(paddingX, 331), UDim2.new(1, -paddingX * 2, 0, 18), 11, "ActionColor")
    local gameCard = window:Create("Frame", {
        Name = "CurrentGame", Position = UDim2.fromOffset(paddingX, 356), Size = UDim2.new(1, -paddingX * 2, 0, 52),
        BorderSizePixel = 0, Parent = window.profilePanelSurface,
    }, { BackgroundColor3 = "ContentColor" })
    window:Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = gameCard })
    label("GameName", game.Name, UDim2.fromOffset(paddingX + 12, 364), UDim2.new(1, -paddingX * 2 - 24, 0, 18), 13, "TitlingColor")
    label("GameBy", "Place ID: " .. tostring(game.PlaceId), UDim2.fromOffset(paddingX + 12, 384), UDim2.new(1, -paddingX * 2 - 24, 0, 16), 10)

    label("PremiumBadge", "PREMIUM", UDim2.new(0.5, -42, 0, contentMinTop + avatarSize + nameGap + nameHeight + subGap + subHeight + 6), UDim2.fromOffset(84, 18), 10, "AccentColor")

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
    -- [[position and size keeps it following drags, restores and resizes]]
    -- [[without a per-frame loop.]]
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

    profilePanel.layout(window)
    return window.profilePanel
end

-- [[Place the panel beside the window frame. The frame's position may]]
-- [[carry scale (the centred resting position) or be pure offset after]]
-- [[a drag: the scale passes through untouched, the offset gets the]]
-- [[half-window + gap edge, and the panel mirrors the window's height.]]
function profilePanel.layout(window)
    local panel = window.profilePanel
    if not panel then
        return
    end

    local main = window.main
    local pos = main.Position
    local width = main.Size.X.Offset
    local height = main.Size.Y.Offset
    local left = (window.settings.profileSide or "right") == "left"
    local edge = width / 2 + profilePanel.gap

    panel.AnchorPoint = Vector2.new(if left then 1 else 0, 0)
    panel.Position = UDim2.new(pos.X.Scale, pos.X.Offset + (if left then -edge else edge), pos.Y.Scale, pos.Y.Offset - height / 2)
    panel.Size = UDim2.fromOffset(profilePanel.width, height)

    local contentTop = math.max(contentMinTop, (height - contentHeight) / 2)
    window.profileAvatar.Position = UDim2.new(0.5, 0, 0, contentTop)
    window.profileName.Position = UDim2.new(0, paddingX, 0, contentTop + avatarSize + nameGap)
    window.profileSubtitle.Position = UDim2.new(0, paddingX, 0, contentTop + avatarSize + nameGap + nameHeight + subGap)
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
    profilePanel.setShown(window, window.settings.showProfile, settleTween)
    window:_recenterForProfile(window.settings.showProfile)
end

function profilePanel.setSide(window, side)
    window.settings.profileSide = if side == "left" then "left" else "right"
    profilePanel.layout(window)
    window:_recenterForProfile(true)
end

function profilePanel.setSubtitle(window, text)
    local subtitle = window.profileSubtitle
    if not subtitle then
        return
    end

    local resolved = if type(text) == "string" and text ~= "" then locale.resolve(text) else nil
    local username = if state.localPlayer then "@" .. state.localPlayer.Name else ""
    subtitle.Text = resolved or username
    subtitle.Visible = subtitle.Text ~= ""
end

function profilePanel.refreshName(window)
    local name = window.profileName
    if not name or not state.localPlayer then
        return
    end
    local fullName = state.localPlayer.Name
    name.Text = if window.settings.showFullUsername then fullName else sidebar.maskUsername(fullName)
end

return profilePanel
