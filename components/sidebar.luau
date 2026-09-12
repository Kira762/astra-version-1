local utilities = script.Parent.Parent.utilities
local state = require(utilities.Parent.core.state)
local image = require(script.Parent.Parent.images.image)
local locale = require(utilities.locale)
local tabSelector = require(script.Parent.tabSelector)
local search = require(script.Parent.search)

local sidebar = {}

local nameTransparency = 0
local subtitleTransparency = 0.7
local avatarBgTransparency = 0.95

local function maskUsername(name)
    name = tostring(name or "")
    if name == "" then
        return "****"
    end
    return string.sub(name, 1, math.min(3, #name)) .. "****"
end

function sidebar.refreshProfileName(window)
    if not window.profileName or not state.localPlayer then
        return
    end
    local fullName = state.localPlayer.Name
    window.profileName.Text = if window.settings.showFullUsername then fullName else maskUsername(fullName)
end

local settleTween = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
sidebar.settleInfo = settleTween

local buildGeneration = 0

local avatarGenerations = setmetatable({}, { __mode = "k" })

local avatarReady = setmetatable({}, { __mode = "k" })

local fallbackUri = "rbxassetid://0"

local function shouldShowProfile(window)
    -- [[Profile.Visible = Window.Visible AND settings.showProfile: the profile]]
    -- [[also hides while the window is minimised to the pill, where the topbar]]
    -- [[remains technically visible but the window content is not shown.]]
    return window.profile ~= nil
        and window.settings.showProfile
        and not window.hidden
        and not window.minimised
        and state.localPlayer ~= nil
end

function sidebar.buildProfile(window, layout)
    local player = state.localPlayer
    if not player then
        return
    end

    -- [[Re-layout safety: drop any previous profile before building a new one]]
    -- [[so switching layout modes can never orphan the old instance.]]
    if window.profile then
        window:DestroySubtree(window.profile)
        window.profile = nil
        window.profileContainer = nil
        window.profileLayout = nil
        window.profileAvatar = nil
        window.profileName = nil
        window.profileSubtitle = nil
        window.profileLabels = nil
    end

    buildGeneration += 1
    local generation = buildGeneration

    local isSidebar = layout.mode == "sidebar" and not layout.forceCollapsed
    local isCollapsed = layout.forceCollapsed == true
    local isTop = layout.mode == "top"

    if isSidebar then
        window.profile = window:Create("Frame", {
            Name = "Profile",
            AnchorPoint = Vector2.new(0.5, 1),
            Position = UDim2.fromScale(0.5, 1),
            Size = UDim2.new(1, 0, 0, layout.footerHeight),
            BackgroundTransparency = 1,
            Parent = window.sidebar,
        })

        window.profileContainer = window:Create("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, layout.rowInset, 0.5, 0),
            Size = UDim2.new(1, -layout.rowInset, 1, 0),
            BackgroundTransparency = 1,
            Parent = window.profile,
        })

        window.profileLayout = window:Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = window.profileContainer,
        })
    elseif isTop then
        window.profile = window:Create("Frame", {
            Name = "Profile",
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 0, 1, -0),
            Size = UDim2.new(1, 0, 0, layout.profileHeight),
            BackgroundTransparency = 1,
            Parent = window.topbar,
        })

        window.profileContainer = window:Create("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -10, 0.5, 0),
            Size = UDim2.new(0, 0, 1, -4),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Parent = window.profile,
        })

        window.profileLayout = window:Create("UIListLayout", {
            Padding = UDim.new(0, 12),
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = window.profileContainer,
        })
    else
        window.profile = window:Create("Frame", {
            Name = "Profile",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.new(1, -8, 1, -8),
            BackgroundTransparency = 1,
            Parent = window.sidebar,
        })

        window.profileContainer = window.profile
        window.profileLayout = window:Create("UIListLayout", {
            Padding = UDim.new(0, 0),
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = window.profileContainer,
        })
    end

    local avatarSize = layout.avatarSize

    window.profileAvatar = window:Create("ImageLabel", {
        Name = "Avatar",
        Size = UDim2.fromOffset(avatarSize, avatarSize),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        ImageTransparency = 1,
        Parent = window.profileContainer,
    })

    window:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = window.profileAvatar,
    })

    window.profileLabels = window:Create("Frame", {
        Size = UDim2.fromOffset(50, avatarSize),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        LayoutOrder = isCollapsed and 0 or 1,
        Parent = window.profileContainer,
    })

    window:Create("UIListLayout", {
        Padding = UDim.new(0, 2),
        FillDirection = Enum.FillDirection.Vertical,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = window.profileLabels,
    })

    window.profileName = window:Create("TextLabel", {
        Text = if window.settings.showFullUsername then player.Name else maskUsername(player.Name),
        Size = UDim2.fromOffset(50, 16),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 1,
        Parent = window.profileLabels,
    }, { TextColor3 = "TitlingColor", FontFace = "Font" })

    window.profileSubtitle = window:Create("TextLabel", {
        Text = "",
        Size = UDim2.fromOffset(50, 14),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1,
        Visible = false,
        TextTransparency = 1,
        Parent = window.profileLabels,
    }, { TextColor3 = "TitlingColor", FontFace = "Font" })

    avatarGenerations[window.profileAvatar] = generation

    local function applyAvatar(avatarLabel, uri)
        if avatarGenerations[avatarLabel] ~= generation then
            return
        end
        if uri ~= nil and uri ~= "" then
            avatarReady[avatarLabel] = true
            image.assign(avatarLabel, "Image", uri)
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

function sidebar.buildTabRail(window, layout, collapsed)
    window.tabList = window:Create("ScrollingFrame", {
        Name = if collapsed then "CollapsedTabs" else "Tabs",
        Active = true,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        ScrollBarImageTransparency = 1,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ClipsDescendants = true,
        Parent = window.sidebar,
    })
    window:Create("UIPadding", {
        PaddingTop = UDim.new(0, layout.railPadding),
        PaddingBottom = UDim.new(0, layout.railPadding),
        Parent = window.tabList,
    })
    window.tabListLayout = window:Create("UIListLayout", {
        Padding = UDim.new(0, layout.rowSpacing),
        FillDirection = Enum.FillDirection.Vertical,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = window.tabList,
    })
end

function sidebar.applyRailRows(window, width, layout)
    search.railWidth(window, width)
    -- [[The rail is collapsed only when it is at the icon-only width. The]]
    -- [[responsive rail otherwise hugs the widest tab name, which is often]]
    -- [[narrower than the fixed 219px rail the layout used to have.]]
    local isCollapsed = width <= (layout.railCollapsedWidth :: number)
    for _, tab in window.tabs do
        if not tab.neglectSelector then
            tabSelector.setRowCollapsed(tab, isCollapsed, layout)
        end
    end
    tabSelector.relayoutSidebarRows(window, layout, width)
    if window.profileContainer and layout.mode == "sidebar" then
        window.profileContainer.Position = UDim2.new(0, if isCollapsed then 0 else layout.rowInset, 0.5, 0)
        window.profileContainer.Size = UDim2.new(1, if isCollapsed then 0 else -layout.rowInset, 1, 0)
        window.profileLayout.HorizontalAlignment = if isCollapsed
            then Enum.HorizontalAlignment.Center
            else Enum.HorizontalAlignment.Left
        if window.profileLabels then
            window.profileLabels.Visible = not isCollapsed and not layout.forceCollapsed
        end
    end
end

function sidebar.build(window, layout)
    if layout.mode == "sidebar" then
        window.sidebar = window:Create("Frame", {
            Name = "Sidebar",
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(0, layout.railWidth, 1, -layout.chromeHeight),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = window.main,
        })
        sidebar.buildTabRail(window, layout, layout.forceCollapsed == true)
    end
    sidebar.buildProfile(window, layout)
    sidebar.reflowProfile(window)
end

function sidebar.reflowProfile(window)
    local layout = window.layout
    local shouldShow = shouldShowProfile(window)

    if window.profile then
        window.profile.Visible = shouldShow
    end

    if layout.mode == "sidebar" and not layout.forceCollapsed then
        window.tabList.Size = UDim2.new(1, 0, 1, if shouldShow then -layout.footerHeight else 0)
    elseif layout.mode == "top" then
        window.profile.Size = UDim2.new(1, 0, 0, if shouldShow then layout.profileHeight else 0)
        if window.profileContainer then
            window.profileContainer.Visible = shouldShow
        end
    end

    if window.profileLabels and window.profileLabels.Visible ~= (not layout.forceCollapsed) then
        window.profileLabels.Visible = not layout.forceCollapsed
    end

    if window.profileContainer and layout.mode == "sidebar" then
        local sidebarWidth = window.sidebar and window.sidebar.AbsoluteSize.X or layout.railWidth
        local isCollapsed = sidebarWidth < (layout.railWidth :: number)
        window.profileContainer.Position = UDim2.new(0, if isCollapsed then 0 else layout.rowInset, 0.5, 0)
        window.profileContainer.Size = UDim2.new(1, if isCollapsed then 0 else -layout.rowInset, 1, 0)
        window.profileLayout.HorizontalAlignment = if isCollapsed
            then Enum.HorizontalAlignment.Center
            else Enum.HorizontalAlignment.Left
    end
end

function sidebar.applyWidth(window, width)
    local layout = window.layout

    window.sidebar.Size = UDim2.new(0, width, 1, -layout.chromeHeight)
    window.elements.Size = UDim2.new(1, -width, 1, -layout.chromeHeight)
    window.bottomFade.Size = UDim2.new(1, -width, layout.fadeSize.Y.Scale, layout.fadeSize.Y.Offset)
    sidebar.applyRailRows(window, width, layout)
end

function sidebar.setProfileShown(window, shown, tweenInfo)
    if not window.profile then
        return
    end

    -- [[Window visibility wins over the requested state: never fade the]]
    -- [[profile in while the window is hidden or minimised.]]
    if shown and not shouldShowProfile(window) then
        shown = false
    end

    local avatar = window.profileAvatar
    local avatarProps
    if avatar then
        local hasImage = avatarReady[avatar] == true
            or (type(avatar.Image) == "string" and avatar.Image ~= "" and avatar.Image ~= fallbackUri)
        if shown and hasImage then
            avatarProps = {
                ImageTransparency = 0,
                BackgroundTransparency = avatarBgTransparency,
            }
        else
            avatarProps = {
                ImageTransparency = 1,
                BackgroundTransparency = if shown then avatarBgTransparency else 1,
                BackgroundColor3 = window.theme.ContentColor,
            }
        end
    end

    local targets = {
        [avatar] = avatarProps,
        [window.profileName] = { TextTransparency = if shown then nameTransparency else 1 },
        [window.profileSubtitle] = { TextTransparency = if shown then subtitleTransparency else 1 },
    }

    for instance, props in targets do
        if instance and props then
            if tweenInfo then
                state.tweenService:Create(instance, tweenInfo, props):Play()
            else
                for prop, value in props do
                    instance[prop] = value
                end
            end
        end
    end
end

function sidebar.setProfileEnabled(window, enabled)
    if not window.profile then
        window.settings.showProfile = enabled
        return
    end

    window.settings.showProfile = enabled
    sidebar.reflowProfile(window)

    if enabled then
        sidebar.setProfileShown(window, true, settleTween)
    else
        sidebar.setProfileShown(window, false, settleTween)
    end
end

function sidebar.setSubtitle(window, text)
    if not window.profileSubtitle then
        return
    end

    local resolved = if type(text) == "string" and text ~= "" then locale.resolve(text) else nil
    window.profileSubtitle.Text = resolved or ""
    window.profileSubtitle.Visible = resolved ~= nil
end

return sidebar
