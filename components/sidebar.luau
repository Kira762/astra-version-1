local a1 = script.Parent.Parent.utilities
local a2 = require(a1.Parent.core.state)
local a3 = require(script.Parent.Parent.images.image)
local a4 = require(a1.locale)
local a5 = require(script.Parent.tabSelector)
local a6 = require(script.Parent.search)

local a7 = {}

local a8 = 0
local a9 = 0.7
local a10 = 0.95

local function a11(a12)
    a12 = tostring(a12 or "")
    if a12 == "" then
        return "****"
    end
    return string.sub(a12, 1, math.min(3, #a12)) .. "****"
end

function a7.refreshProfileName(window)
    if not window.profileName or not a2.localPlayer then
        return
    end
    local a13 = a2.localPlayer.Name
    window.profileName.Text = if window.settings.showFullUsername then a13 else a11(a13)
end

local a14 = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
a7.settleInfo = a14

local a15 = 0

local a16 = setmetatable({}, { __mode = "k" })

local a17 = setmetatable({}, { __mode = "k" })

local a18 = "rbxassetid://0"

local function a19(window)
    return window.profile ~= nil
        and window.settings.showProfile
        and a2.localPlayer ~= nil
end

local function a20(window, a21)
    local a22 = a2.localPlayer
    if not a22 then
        return
    end

    a15 += 1
    local a23 = a15

    local a24 = a21.mode == "sidebar"
    local a25 = a21.mode == "collapsedSidebar"
    local a26 = a21.mode == "top"

    if a24 then
        window.profile = window:Create("Frame", {
            Name = "Profile",
            AnchorPoint = Vector2.new(0.5, 1),
            Position = UDim2.fromScale(0.5, 1),
            Size = UDim2.new(1, 0, 0, a21.footerHeight),
            BackgroundTransparency = 1,
            Parent = window.sidebar,
        })

        window.profileContainer = window:Create("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, a21.rowInset, 0.5, 0),
            Size = UDim2.new(1, -a21.rowInset, 1, 0),
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
    elseif a26 then
        window.profile = window:Create("Frame", {
            Name = "Profile",
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 0, 1, -0),
            Size = UDim2.new(1, 0, 0, a21.profileHeight),
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

    local a27 = a21.avatarSize

    window.profileAvatar = window:Create("ImageLabel", {
        Name = "Avatar",
        Size = UDim2.fromOffset(a27, a27),
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
        Size = UDim2.fromOffset(50, a27),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        LayoutOrder = a25 and 0 or 1,
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
        Text = if window.settings.showFullUsername then a22.Name else a11(a22.Name),
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

    a16[window.profileAvatar] = a23

    local function a28(a29, a30)
        if a16[a29] ~= a23 then
            return
        end
        if a30 ~= nil and a30 ~= "" then
            a17[a29] = true
            a3.assign(a29, "Image", a30)
        else
            a17[a29] = nil
            a3.assign(a29, "Image", a18)
        end
    end

    local a31 = a3.avatar(a22.UserId, function(a32)
        if window.unloaded then
            return
        end
        local a33 = window.profileAvatar
        if not a33 then
            return
        end
        a28(a33, a32)
    end)

    if a31 ~= "" then
        a28(window.profileAvatar, a31)
    end
end

function a7.build(window, a34)
    local a35 = a34.mode == "sidebar"
    local a36 = a34.mode == "collapsedSidebar"

    if a35 or a36 then
        window.sidebar = window:Create("Frame", {
            Name = "Sidebar",
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(0, a34.railWidth, 1, -a34.chromeHeight),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = window.main,
        })

        window.tabList = window:Create("ScrollingFrame", {
            Name = "Tabs",
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
            PaddingTop = UDim.new(0, a34.railPadding),
            PaddingBottom = UDim.new(0, a34.railPadding),
            Parent = window.tabList,
        })

        window.tabListLayout = window:Create("UIListLayout", {
            Padding = UDim.new(0, a34.rowSpacing),
            FillDirection = Enum.FillDirection.Vertical,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = window.tabList,
        })
    end

    a20(window, a34)
    a7.reflowProfile(window)
end

function a7.reflowProfile(window)
    local a37 = window.layout
    local a38 = a19(window)

    if window.profile then
        window.profile.Visible = a38
    end

    if a37.mode == "sidebar" then
        window.tabList.Size = UDim2.new(1, 0, 1, if a38 then -a37.footerHeight else 0)
    elseif a37.mode == "top" then
        window.profile.Size = UDim2.new(1, 0, 0, if a38 then a37.profileHeight else 0)
        if window.profileContainer then
            window.profileContainer.Visible = a38
        end
    end

    if window.profileLabels and window.profileLabels.Visible ~= (a37.mode ~= "collapsedSidebar") then
        window.profileLabels.Visible = a37.mode ~= "collapsedSidebar"
    end

    if window.profileContainer and a37.mode == "sidebar" then
        local a39 = window.sidebar and window.sidebar.AbsoluteSize.X or a37.railWidth
        local a40 = a39 < (a37.railWidth :: number)
        window.profileContainer.Position = UDim2.new(0, if a40 then 0 else a37.rowInset, 0.5, 0)
        window.profileContainer.Size = UDim2.new(1, if a40 then 0 else -a37.rowInset, 1, 0)
        window.profileLayout.HorizontalAlignment = if a40
            then Enum.HorizontalAlignment.Center
            else Enum.HorizontalAlignment.Left
    end
end

function a7.applyWidth(window, a41)
    local a42 = window.layout

    window.sidebar.Size = UDim2.new(0, a41, 1, -a42.chromeHeight)
    window.elements.Size = UDim2.new(1, -a41, 1, -a42.chromeHeight)
    window.bottomFade.Size = UDim2.new(1, -a41, a42.fadeSize.Y.Scale, a42.fadeSize.Y.Offset)
    a6.railWidth(window, a41)

    local a43 = a41 < (a42.railWidth :: number)
    for _, tab in window.tabs do
        if not tab.neglectSelector then
            a5.setRowCollapsed(tab, a43, a42)
        end
    end

    if window.profileContainer and a42.mode == "sidebar" then
        window.profileContainer.Position = UDim2.new(0, if a43 then 0 else a42.rowInset, 0.5, 0)
        window.profileContainer.Size = UDim2.new(1, if a43 then 0 else -a42.rowInset, 1, 0)
        window.profileLayout.HorizontalAlignment = if a43
            then Enum.HorizontalAlignment.Center
            else Enum.HorizontalAlignment.Left
        window.profileLabels.Visible = not a43
    end
end

function a7.setProfileShown(window, a44, a45)
    if not window.profile then
        return
    end

    local a46 = window.profileAvatar
    local a47
    if a46 then
        local a48 = a17[a46] == true
            or (type(a46.Image) == "string" and a46.Image ~= "" and a46.Image ~= a18)
        if a44 and a48 then
            a47 = {
                ImageTransparency = 0,
                BackgroundTransparency = a10,
            }
        else
            a47 = {
                ImageTransparency = 1,
                BackgroundTransparency = if a44 then a10 else 1,
                BackgroundColor3 = window.theme.ContentColor,
            }
        end
    end

    local a49 = {
        [a46] = a47,
        [window.profileName] = { TextTransparency = if a44 then a8 else 1 },
        [window.profileSubtitle] = { TextTransparency = if a44 then a9 else 1 },
    }

    for a50, a51 in a49 do
        if a50 and a51 then
            if a45 then
                a2.tweenService:Create(a50, a45, a51):Play()
            else
                for a52, a53 in a51 do
                    a50[a52] = a53
                end
            end
        end
    end
end

function a7.setProfileEnabled(window, a54)
    if not window.profile then
        window.settings.showProfile = a54
        return
    end

    window.settings.showProfile = a54
    a7.reflowProfile(window)

    if a54 then
        a7.setProfileShown(window, true, a14)
    else
        a7.setProfileShown(window, false, a14)
    end
end

function a7.setSubtitle(window, a55)
    if not window.profileSubtitle then
        return
    end

    local a56 = if type(a55) == "string" and a55 ~= "" then a4.resolve(a55) else nil
    window.profileSubtitle.Text = a56 or ""
    window.profileSubtitle.Visible = a56 ~= nil
end

return a7
