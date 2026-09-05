local a1 = script.Parent.Parent.utilities
local a2 = require(a1.Parent.core.state)
local a3 = require(a1.constants)
local a4 = require(a1.locale)
local a5 = require(script.Parent.action)

local a6 = {}

local a7 = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local a8 = 0.6
local a9 = 0.2

local function a10(a11)
    if a11.__type == "Group" then
        local a12 = {}
        local function a13(a14)
            for _, a15 in a14.elements do
                if a15.__type == "Group" then
                    a13(a15)
                elseif a15.name then
                    table.insert(a12, a15.name)
                end
            end
        end
        a13(a11)
        return table.concat(a12, "\n")
    end
    return a11.name or ""
end

local function a16(window)
    local a17 = {}
    for _, tab in window.tabs do
        if tab.neglectSelector then
            continue
        end
        for _, element in tab.elements do
            if element.__type ~= "Section" then
                table.insert(a17, element)
            end
        end
    end
    return a17
end

local function a18(window, a19, a20)
    a2.tweenService
        :Create(window.searchPill, a20, {
            BackgroundTransparency = if a19 then 0.9 else 1,
        })
        :Play()
    a2.tweenService:Create(window.searchStroke, a20, { Transparency = if a19 then 0.85 else 1 }):Play()
    a2.tweenService:Create(window.searchShadow, a20, { Transparency = if a19 then 0.92 else 1 }):Play()
    a2.tweenService:Create(window.searchIcon, a20, { ImageTransparency = if a19 then 0.65 else 1 }):Play()
    a2.tweenService:Create(window.searchInput, a20, { TextTransparency = if a19 then 0.2 else 1 }):Play()
end

local function a21(window, a22, a23)
    if window.layout.mode == "sidebar" then
        return
    end
    for _, tab in window.tabs do
        if not tab.neglectSelector and tab.topbarItem then
            tab:_applyVisual(
                if a22 then (if window.selectedTab == tab then "selected" else "unselected") else "hidden",
                a23
            )
        end
    end
end

local function a24(window, a25)
    a25 = string.lower(a25 or "")
    local a26 = false
    for _, a27 in window._searchUnits do
        local a28 = a25 == "" or string.find(a27.text, a25, 1, true) ~= nil
        a27.unit.main.Visible = a28
        if a27.unit.descriptor then
            a27.unit.descriptor.main.Visible = a28
        end
        a26 = a26 or a28
    end
    window.searchEmpty.Visible = not a26 and a25 ~= ""
end

local function a29(window)
    window._searchUnits = {}
    local a30 = 0
    for _, a31 in a16(window) do
        a30 += 1
        local a32 = a31.main
        table.insert(window._searchUnits, {
            unit = a31,
            text = string.lower(a10(a31)),
            homeParent = a32.Parent,
            homeOrder = a32.LayoutOrder,
            descOrder = a31.descriptor and a31.descriptor.main.LayoutOrder,
        })

        a32.LayoutOrder = a30 * 10
        a32.Parent = window.searchPage
        a32.Visible = true
        if a31.descriptor then
            a31.descriptor.main.LayoutOrder = a30 * 10 + 1
            a31.descriptor.main.Parent = window.searchPage
            a31.descriptor.main.Visible = true
        end
    end
end

local function a33(window)
    for _, a34 in window._searchUnits do
        local a35 = a34.unit
        if a35.main and a35.main.Parent then
            a35.main.LayoutOrder = a34.homeOrder
            a35.main.Parent = a34.homeParent
            a35.main.Visible = true
        end
        if a35.descriptor and a35.descriptor.main and a35.descriptor.main.Parent then
            a35.descriptor.main.LayoutOrder = a34.descOrder
            a35.descriptor.main.Parent = a34.homeParent
            a35.descriptor.main.Visible = true
        end
    end
    window._searchUnits = {}
end

function a6.open(window)
        if window._searching or window.minimised or not window:_interactive() then
        return
    end
    window._searching = true

    a29(window)
    a24(window, "")
    window:_jumpTo(window.searchPage)

        a21(window, false, a7)
    task.delay(a7.Time, function()
        if not window.unloaded and window._searching and window.layout.mode ~= "sidebar" then
            window.tabList.Visible = false
        end
    end)

    window.searchPill.Visible = true
    a18(window, true, a7)
    window.searchInput:CaptureFocus()

    a2.tweenService:Create(window.searchAction.iconLabel, a7, { ImageTransparency = a9 }):Play()
end

function a6.close(window, a36)
    if not window._searching then
        return
    end
    a36 = a36 or {}
    window._searching = false

    window.searchInput.Text = ""
    window.searchInput:ReleaseFocus()
    window.searchEmpty.Visible = false

    a33(window)
    local a37 = if a36.jumpTo == nil then window.selectedTab and window.selectedTab.tabPage else a36.jumpTo
    if a37 then
        window:_jumpTo(a37)
    end

    a18(window, false, a7)
    task.delay(a7.Time, function()
        if not window.unloaded and not window._searching then
            window.searchPill.Visible = false
        end
    end)

    if a36.showTabs then
        if window.layout.mode == "sidebar" and window._applySettingsLayout then
            window:_applySettingsLayout(window.selectedTab == window.rfSettings)
        else
            window.tabList.Visible = true
        end
        a21(window, true, a7)
    end

    a2.tweenService:Create(window.searchAction.iconLabel, a7, { ImageTransparency = a8 }):Play()
end

function a6.toggle(window)
    if window._searching then
        a6.close(window, { showTabs = true })
    else
        a6.open(window)
    end
end

function a6.railWidth(window, a38)
    if window.searchPill then
        window.searchPill.Size = UDim2.new(1, -(a38 + 30), 0, 35)
    end
end

function a6.build(window)
    window._searching = false

        window.searchPage = window:Create("ScrollingFrame", {
        Name = "Search",
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        LayoutOrder = 2000,
        Parent = window.elements,
    })

    window:Create("UIListLayout", {
        Padding = UDim.new(0, 7),
        FillDirection = Enum.FillDirection.Vertical,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,

        Parent = window.searchPage,
    })

            window:Create("UIPadding", {
        PaddingTop = UDim.new(0, if window.layout.mode == "sidebar" then 53 else 10),
        PaddingBottom = UDim.new(0, 33),

        Parent = window.searchPage,
    })

            window.searchEmpty = window:Create("TextLabel", {
        Name = "NoResults",
        Text = a4.t("No results"),
        FontFace = a2.brandFont(Enum.FontWeight.Medium),
        TextSize = 15,
        TextTransparency = 0.6,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.55, 0),
        Size = UDim2.fromOffset(200, 20),
        Visible = false,
        ZIndex = 3,

        Parent = window.main,
    }, { TextColor3 = "ContentColor", FontFace = "Font" })

            local a39 = window.layout.mode == "sidebar"
            local a40 = if a39 then window.layout.chromeHeight + 8 else window.layout.tabStripTop + 1

    window.searchPill = window:Create("Frame", {
        Name = "SearchBar",
        AnchorPoint = Vector2.new(if a39 then 1 else 0.5, 0),
        Position = UDim2.new(if a39 then 1 else 0.5, if a39 then -15 else 0, 0, a40),
        Size = UDim2.new(1, if a39 then -(window.layout.railWidth + 30) else -35, 0, 35),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 10,

        BackgroundTransparency = 1,         Visible = false,

        Parent = window.main,
    })

    window:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = window.searchPill,
    })

    window.searchStroke = window:Create("UIStroke", {
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 1,

        Transparency = 1,
        Parent = window.searchPill,
    })

    window.searchShadow = window:Create("UIShadow", {
        BlurRadius = UDim.new(0, 20),
        Color = Color3.fromRGB(255, 255, 255),
        ZIndex = -1,

        Transparency = 1,
        Parent = window.searchPill,
    })

    window.searchIcon = window:Create("ImageLabel", {
        Image = "rbxassetid://" .. tostring(a3.icons.search),
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 15, 0.5, 1),
        Size = UDim2.fromOffset(16, 16),
        BackgroundTransparency = 1,
        ZIndex = 10,

        ImageTransparency = 1,
        Parent = window.searchPill,
    }, { ImageColor3 = "ContentColor" })

    window.searchInput = window:Create("TextBox", {
        Text = "",
        PlaceholderText = a4.t("Search all pages"),
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 40, 0.5, 0),
        Size = UDim2.new(1, -110, 0, 18),
        BackgroundTransparency = 1,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ClipsDescendants = true,
        ZIndex = 10,

        TextTransparency = 1,
        Parent = window.searchPill,
    }, { TextColor3 = "ContentColor", FontFace = "Font", PlaceholderColor3 = "PlaceholderColor" })

    window:Connect(window.searchInput:GetPropertyChangedSignal("Text"), function()
        if window._searching then
            a24(window, window.searchInput.Text)
        end
    end)

        window.searchAction = a5.new(window, {
        name = "Search",
        icon = a3.icons.search,
        order = 4,

        callback = function()
            a6.toggle(window)
        end,
    })
        window.searchAction.isLit = function()
        return window._searching
    end
end

return a6
