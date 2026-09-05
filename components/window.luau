local a1 = script.Parent.Parent.utilities
local a2 = require(script.Parent.Parent.images.image)
local a3 = require(script.Parent.Parent.icons)
local a4 = require(script.Parent.Parent.functions)
local a5 = require(a1.persistence)
local a6 = require(a1.constants)
local a7 = require(a1.locale)
local a8 = require(a1.log)
local a9 = require(a1.HapticEngine)
local a10 = require(a1.windowSizing)
local a11 = require(a1.layouts)
local a12 = require(script.Parent.chrome)
local a13 = require(script.Parent.search)
local a14 = require(script.Parent.sidebar)

local a15 = require(a1.Parent.core.state)

local a16 = require(script.Parent.Parent.themes)

local a17 = {}
a17.__index = a17

local a18 = TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
local a19 = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local a20 = UDim2.fromOffset(185, 50)
local a21 = UDim2.fromOffset(50, 50)
local a22 = UDim2.new(0.5, 0, 0, 20)
local a23 = UDim2.new(0.5, 0, 0, 12)
local a24 = UDim2.new(0.5, 0, 0, a22.Y.Offset + a20.Y.Offset + 12)
local a25 = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local a26 = 320

local a27 = 41

local a28 = 0.55
local a29 = 0.55

local a30 = 0.04
local a31 = 8

local a32 = 2

local function a33(a34): UDim2
    local a35 = a15.workspace.CurrentCamera
    return a10.fit(a35 and a35.ViewportSize, a34)
end

local function a36(window)
    window.tabList = window:Create("ScrollingFrame", {
        Name = "Tabs",
        Active = true,
        Size = UDim2.new(1, 0, 0, window.layout.tabStripHeight),
        Position = UDim2.new(0.5, 0, 0, window.layout.tabStripTop),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        ScrollBarImageTransparency = 1,
        ScrollingDirection = Enum.ScrollingDirection.X,
        Parent = window.main,
    })
    window.tabListLayout = window:Create("UIListLayout", {
        Padding = UDim.new(0, 7),
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = window.tabList,
    })
    window:Create("UIPadding", {
        PaddingLeft = UDim.new(0, 22),
        PaddingRight = UDim.new(0, 10),
        Parent = window.tabList,
    })
end

local a37 = { "TopLeftRadius", "TopRightRadius", "BottomLeftRadius", "BottomRightRadius" }

local a38 = (function()
    return (
        pcall(function()
            local a39 = Instance.new("UICorner")
            a39.TopLeftRadius = UDim.new(0, 1)
            a39:Destroy()
        end)
    )
end)()

local function a40(a41)
    return if a41 then a11.sidebar else a11.top
end

local function a42(a43)
    if a43.mode == "sidebar" and a43.forceCollapsed then
        return "collapsedSidebar"
    end
    return a43.mode
end

local a44 = a16.coerceValue
local a45 = a16.firstColor
local a46 = a16.deriveStrokes
local a47 = a16.resolve

local function a48(window, a49)
    local a50 = window._toastsTop
    if not a50 then
        return
    end

    local a51 = if window._collapsedShown then a24 else a23
    if not a49 or a50.Position == a51 then
        a50.Position = a51
        return
    end

    a15.tweenService:Create(a50, a25, { Position = a51 }):Play()
end

function a17:ResolveIcon(a52, a53)
    return a3.resolve(a52, a53 or self.iconPack)
end

function a17.new(a54)
    a54 = if typeof(a54) == "table" then a54 else {}

                if a54.translations or a54.Translations then
        a7.register(a54.translations or a54.Translations)
    end
    if a54.translator or a54.Translator then
        a7.translator = a54.translator or a54.Translator
    end
    a7.setActive(a54.locale or a54.Locale or a7.detect())

            local a55 = a54.fallbackFont or a54.FallbackFont
    if a55 then
        a15.setFallbackFont(a55)
    end

        local a56 = a40(a54.sidebarLayout or a54.SidebarLayout)
    local a57 = a54.iconPack
    local a58 = a54.IconPack
    if a57 ~= nil and a58 ~= nil then
        error("Astra: choose exactly one icon pack; provide either iconPack or IconPack, not both.", 2)
    end
    local a59 = a57 or a58 or a3.Lucide
    if not a3.isPack(a59) then
        error("Astra: iconPack must be exactly one supported pack: lucide, material, tabler, phosphor, heroicons, or feather.", 2)
    end

    local self = setmetatable({
        name = a54.name or a54.Name or "Astra Window",
        subheading = a54.subtitle or a54.Subtitle,
        layout = a56,
        size = a33(a56.mode),
        instances = {},
        connections = {},

        iconPack = a59,
        icon = a3.resolve(a54.icon or a54.Icon, a59),
        showName = a54.showName or a54.ShowName or "Astra",
        showIcon = a3.resolve(a54.showIcon or a54.ShowIcon, a59),
                showIconOnly = a54.showIconOnly or a54.ShowIconOnly or false,
                profileText = nil,

        themeProperties = {},
        localeProperties = {},
        tabs = {},
        tabSections = {},
        tags = {},
        selectedTab = nil,
        _settingsLayoutActive = false,
        _settingsCardBuilt = false,
        _settingsTabs = {},
        _settingsActiveSubTab = 1,
        theme = a47(a54.theme or a54.Theme),

        controls = {},

        configuration = (function()
            local a60 = a54.configuration or a54.Configuration
            if not a60 then
                return {}
            end
            return {
                autoSave = a60.autoSave or a60.AutoSave,
                autoLoad = a60.autoLoad or a60.AutoLoad,
                fileName = a60.fileName or a60.FileName,
                customFolder = a60.customFolder or a60.CustomFolder,
            }
        end)(),
    }, a17)

            self.Flags = setmetatable({}, {
        __index = function(_, a61)
            local a62 = self.controls[a61]
            return a62 and a62.value
        end,
        __newindex = function(_, a63, a64)
            local a65 = self.controls[a63]
            if not a65 then
                a8.warn("Astra: no flag '" .. tostring(a63) .. "' to set")
                return
            end
            a65:Set(a64)
        end,
        __iter = function()
            local a66
            return function()
                local a67
                a66, a67 = next(self.controls, a66)
                if a66 then
                    return a66, a67.value
                end
                return nil
            end
        end,
    })

            self.settings = {
        toggleKeybind = Enum.KeyCode.K,
        mouseOverride = true,         keepOnScreen = true,         welcomeToast = true,         haptics = true,
        showProfile = true,
        showFullUsername = false,
        antiWindowDuplicate = true,
        layoutMode = a56.mode,
        activeSubTab = 1,
    }
        self._layoutTransitioning = false

        self.screenGui = self:Create("ScreenGui", {
        Name = a15.httpService:GenerateGUID(false),
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        Enabled = true,
        DisplayOrder = a6.displayOrder.window,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,

        Parent = a15.guiContainer,
    })

        self.main = self:Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Name = self.name,
        ZIndex = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.fromOffset((self.size.X.Offset - 50), 0),
        BackgroundTransparency = 1,         Visible = false,
        Parent = self.screenGui,
    })

    self.drag = require(script.Parent.drag).new(self)

    self.windowCorner = self:Create("UICorner", {

        Parent = self.main,
    }, { CornerRadius = "CornerRoundness" })

    self.windowStroke = self:Create("UIStroke", {
                Transparency = 1,
        Parent = self.main,
    }, { Color = "SurfaceStroke" })

    self.windowGradient = self:Create("UIGradient", {
        Rotation = 270,
        Offset = Vector2.new(0, -0.1),

        Parent = self.main,
    }, { Color = { "WindowColor", a4.toColorSequence } })

                self.bottomFade = self:Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.fromScale(1, 1),
        Size = self.layout.fadeSize,
        ZIndex = a6.zIndex.bottomFade,

                BackgroundTransparency = 1,
        Parent = self.main,
    })

    self.bottomFadeCorner = self:_roundCorners(self.bottomFade, self.layout.fadeCorners)

    self.bottomFadeGradient = self:Create("UIGradient", {
        Rotation = 270,
        Offset = Vector2.new(0, 0.2),
        Transparency = self.layout.fadeTransparency,

        Parent = self.bottomFade,
    }, {
                        Color = {
            "WindowColor",
            function(a68)
                return ColorSequence.new(a4.toColorSequence(a68).Keypoints[1].Value)
            end,
        },
    })

        self.topbar = self:Create("Frame", {

        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, self.layout.topbarHeight),
                        Active = true,

        Parent = self.main,
    })

    self.topContainer = self:Create("Frame", {
        Size = UDim2.new(0, 300, 0, 24),
        Position = UDim2.new(0, 25, 0.5, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,

        Parent = self.topbar,
    })

    self.topContainerLayout = self:Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,

        Parent = self.topContainer,
    })

    self.titleContainer = self:Create("Frame", {
        Size = UDim2.fromOffset(50, 24),
        Position = UDim2.new(0, 25, 0.5, 0),
        AutomaticSize = Enum.AutomaticSize.XY,
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        LayoutOrder = 1,

        Parent = self.topContainer,
    })

    self.titleContainerLayout = self:Create("UIListLayout", {
        Padding = UDim.new(0, 3),
        FillDirection = Enum.FillDirection.Vertical,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,

        Parent = self.titleContainer,
    })

    if self.name then
        self.title = self:Create("TextLabel", {
                        Text = a7.t(self.name),
            FontFace = a15.brandFont(Enum.FontWeight.Medium),

            Size = UDim2.fromOffset(50, 20),
            AutomaticSize = Enum.AutomaticSize.X,

            BackgroundTransparency = 1,
            TextSize = 20,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,

                        TextTransparency = 1,
            Parent = self.titleContainer,
        }, { FontFace = "Font", TextColor3 = "TitlingColor" })
    end

    if self.icon then
        self.topbarIcon = self:Create("ImageLabel", {
            Image = self.icon,

            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(32, 32),

                        ImageTransparency = 1,
            Parent = self.topContainer,
        }, { ImageColor3 = "TitlingColor" })
    end

    if self.subheading then
        self.subtitle = self:Create("TextLabel", {
                        Text = a7.t(self.subheading),
            Size = UDim2.fromOffset(50, 12),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,

                        TextTransparency = 1,
            Parent = self.titleContainer,
        }, { TextColor3 = "TitlingColor", FontFace = "Font" })
    end

    self.tagContainer = self:Create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 25, 0.5, 0),
        Size = UDim2.fromOffset(50, 24),
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,
        LayoutOrder = 2,
        Visible = false,

        Parent = self.topContainer,
    })

    self.tagContainerLayout = self:Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,

        Parent = self.tagContainer,
    })

        self.windowShadow = self:CreateGlow(self.main, "ShadowColor", 20, 1)

                self.elements = self:Create("Frame", {
        Size = UDim2.new(1, 0, 1, -self.layout.chromeHeight),
        Position = UDim2.fromScale(1, 1),
        AnchorPoint = Vector2.new(1, 1),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        ClipsDescendants = true,

        Parent = self.main,
    })

    if self.layout.mode == "sidebar" then
        self.elementsCorner = self:_roundCorners(self.elements, self.layout.cardCorners)

        self.elementsStroke = self:Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,

                        Transparency = 1,
            Parent = self.elements,
        }, { Color = "SurfaceStroke" })

                        self:Create("UIGradient", {
            Rotation = self.layout.cardStrokeRotation,
            Transparency = self.layout.cardStrokeTransparency,

            Parent = self.elementsStroke,
        })
    end

    self.elementsLayout = self:Create("UIPageLayout", {
        Padding = UDim.new(0, 0),
        FillDirection = self.layout.pageDirection,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,

                        ScrollWheelInputEnabled = false,
        GamepadInputEnabled = false,
        TouchInputEnabled = false,

        EasingStyle = Enum.EasingStyle.Exponential,
        TweenTime = 0.4,

        Parent = self.elements,
    })

            if self.layout.mode == "sidebar" then
        a14.build(self, self.layout)
        a14.applyWidth(self, a11.railWidthFor(self.layout, self.size.X.Offset))
    else
        a36(self)
        if self.layout.mode == "top" then
            a14.build(self, self.layout)
        elseif self.layout.mode == "collapsedSidebar" then
            a14.build(self, self.layout)
        end
    end

        self.actionContainer = self:Create("Frame", {

        AnchorPoint = Vector2.new(1, 0.5),
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.fromOffset(0, 24),
        Position = UDim2.new(1, -20, 0.5, 0),
        BackgroundTransparency = 1,

        Parent = self.topbar,
    })

    self.actionsListLayout = self:Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        SortOrder = Enum.SortOrder.LayoutOrder,

        Parent = self.actionContainer,
    })

    self.rfSettings = self:CreateTab({
        name = "Astra Settings",
        customOrder = 1000,

        neglectSelector = true,
                        forgetState = true,
    })

    require(script.Parent.action).new(self, {
        name = "Close",
        icon = a6.icons.close,
        order = 1,

        callback = function()
            self:Popup({
                title = "Close window?",
                content = "Are you sure you want to close this window?",
                options = {
                    { text = "Cancel" },
                    {
                        text = "Close",
                        style = "primary",
                        callback = function()
                            self:Close()
                        end,
                    },
                },
            })
        end,
    })

    self.minimiseAction = require(script.Parent.action).new(self, {
        name = "Minimise",
        icon = a6.icons.minimise,
        order = 2,

        callback = function()
            self:ToggleHide()
        end,
    })

    self.settingsAction = require(script.Parent.action).new(self, {
        name = "Settings",
        icon = a6.icons.settings,
        order = 3,
        linkedTab = self.rfSettings,

        callback = function()
            if self.selectedTab == self.rfSettings then
                local a69 = self._previousTab
                self._previousTab = nil
                if a69 and a69.window == self and a69.tabPage then
                    a69:Select()
                    return
                end
                for _, tab in self.tabs do
                    if tab ~= self.rfSettings and tab.window == self and tab.tabPage then
                        tab:Select()
                        return
                    end
                end
                return
            end

            self._previousTab = self.selectedTab
            self.rfSettings:Select()
        end,
    })

    a13.build(self)
        self:_applyRailWidth()

    self.unloaded = false
    self.minimised = false
    self.hidden = true
    self.animating = false
    self._revealing = false
    self.hasShownOnce = false
    self._collapsedShown = false

        self:LoadSettings()
    if self.settings.layoutMode == "collapsedSidebar"
        or (self.settings.layoutMode and self.settings.layoutMode ~= self.layout.mode)
    then
        self:_setLayoutMode(self.settings.layoutMode)
    end
    if self.layout.mode == "sidebar" then
        a14.reflowProfile(self)
        a14.setSubtitle(self, self.profileText)
    end

    task.defer(function()
        if self.unloaded or a15.localPlayer or not self.profile then
            return
        end
        local a70 = os.clock() + 2
        local a71
        a71 = a15.runService.RenderStepped:Connect(function()
            if self.unloaded then
                a71:Disconnect()
                return
            end
            if a15.localPlayer or os.clock() > a70 then
                a71:Disconnect()
                if a15.localPlayer and self.profile then
                    a14.refreshProfileName(self)
                    a14.reflowProfile(self)
                    a14.setProfileShown(self, true, a14.settleInfo)
                end
            end
        end)
        self:Connect(a71)
    end)
    a9.setContainer(self.screenGui)     a9.setEnabled(self.settings.haptics)     a12.buildCollapsedFace(self)
    self:_bindKeybind()
    self:_bindMouseOverride()
    self:_bindTopbarDrag()
    self:_watchViewport()
    self:_buildSettingsUI()

    self:_syncLiveAnimation()

    return self
end

function a17:_syncLiveAnimation()
    if not self.theme.LiveAnimation then
        self._liveAnimating = false         return
    end
    if self._liveAnimating then
        return     end

    self._liveAnimating = true
            self._liveGeneration = (self._liveGeneration or 0) + 1
    local a72 = self._liveGeneration
    task.spawn(function()
        local a73 = true
        local a74 = TweenInfo.new(10, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

        while self._liveGeneration == a72 and self._liveAnimating and not self.unloaded do
            local a75 = a15.tweenService:Create(self.windowGradient, a74, {
                Offset = Vector2.new(if a73 then 0.4 else -0.2, 0),
                Rotation = (if a73 then 220 else 280),
            })

            self._liveTween = a75
            a75:Play()
            a75.Completed:Wait()
            a73 = not a73
        end
        if self._liveGeneration == a72 then
            self._liveAnimating = false
            self._liveTween = nil
        end
    end)
end

function a17:ChangeTheme(a76)
            local a77 = if typeof(a76) == "table" then a76 else a47(a76)
    for a78, a79 in a77 do
        self.theme[a78] = a44(a78, a79)
    end
        if typeof(a76) == "table" then
        a46(self.theme, a77)
    end

    for a80, a81 in self.themeProperties do
        for a82, a83 in a81 do
            local a84 = if typeof(a83) == "table" then a83[2](self.theme[a83[1]]) else self.theme[a83]

            if a80[a82] == a84 then
                continue
            end
            if typeof(a84) == "Color3" or typeof(a84) == "number" then
                a15.tweenService:Create(a80, a19, { [a82] = a84 }):Play()
            else
                a80[a82] = a84
            end
        end
    end

                    if self.hidden then
                        self._themeRefreshPending = true
    else
        self:_refreshElementThemes()
    end

    self:_syncLiveAnimation()
end

function a17:_refreshElementThemes()
    for _, tab in self.tabs do
        for _, element in tab.elements do
            if element._refreshTheme then
                element:_refreshTheme()
            end
        end
    end
end

function a17:CreateTab(a85)
    assert(not self.unloaded, "Cannot create a tab on an unloaded window.")
    local a86 = require(script.Parent.Parent.elements.tab).new(self, a85)

    table.insert(self.tabs, a86)

    if not a86.neglectSelector then
        local a87 = true
        for _, tab in self.tabs do
            if tab ~= a86 and not tab.neglectSelector then
                a87 = false
                break
            end
        end
        if a87 then
            a86:Select(true)
        end

                        if not self.hidden and not self.minimised then
            a86.topbarItem.Visible = true
            a86:_applyVisual(
                if self.selectedTab == a86 then "selected" else "unselected",
                TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            )
        end
    end

    return a86
end

function a17:CreateSection(a88)
    assert(not self.unloaded, "Cannot create a section on an unloaded window.")
    local a89 = require(script.Parent.Parent.elements.tabSection).new(self, a88)
    table.insert(self.tabSections, a89)

            if not a89.inert and not self.hidden and not self.minimised then
        a89:_setVisible(true)
        a89:_setShown(true, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
    end

    return a89
end

function a17:_setTabSectionsShown(a90, a91)
    for _, a92 in self.tabSections do
        a92:_setShown(a90, a91)
    end
end

function a17:_setTabSectionsVisible(a93)
    for _, a94 in self.tabSections do
        a94:_setVisible(a93)
    end
end

function a17:CreateTag(a95)
    assert(not self.unloaded, "Cannot create a tag on an unloaded window.")
    local a96 = require(script.Parent.Parent.elements.tag).new(self, a95)
    table.insert(self.tags, a96)
    return a96
end

function a17:_registerControl(a97)
    if not a97.flag or a97.flag == "" or a97.forgetState then
        return
    end

    local a98 = a97.flag
    if self.controls[a98] then
        local n = 2
        while self.controls[a98 .. n] do
            n += 1
        end
        a98 = a98 .. n
    end

    a97.flag = a98
    self.controls[a98] = a97
    return a98
end

function a17:_restoreLate(element)
    if not self._loadedConfig or not element.flag or element.forgetState then
        return
    end

    local a99 = self._loading
    self._loading = true     a5.applyTo(element, self._loadedConfig[element.flag])
    self._loading = a99
end

function a17:_persist(a100)
            if a100.flag and not a100.forgetState and self.configuration.autoSave and not self._loading then
        task.spawn(self.Save, self)
    end
end

function a17:_unregisterControl(a101)
    if a101.flag and self.controls[a101.flag] == a101 then
        self.controls[a101.flag] = nil
    end
end

function a17:_keybindUsing(a102, a103)
    if typeof(a102) ~= "EnumItem" or a102 == Enum.KeyCode.Unknown then
        return nil
    end
    for _, tab in self.tabs do
        for _, element in tab.elements do
            if element ~= a103 and element.__type == "Keybind" and element.value == a102 then
                return element
            end
        end
    end
    return nil
end

function a17:Notify(a104)
    if self.unloaded then
        return     end
    if not self.notifications then
        self.notifications = self:Create("Frame", {
            Name = "Notifications",
            Size = UDim2.new(0, 300, 0, 800),
            Position = UDim2.new(1, -20, 1, -20),
            AnchorPoint = Vector2.new(1, 1),
            BackgroundTransparency = 1,

            Parent = self.screenGui,
        })

        self:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
                                    Padding = UDim.new(0, 0),

            Parent = self.notifications,
        })
    end

    return require(script.Parent.Parent.components.notification).new(self, a104)
end

function a17:Toast(a105)
    if self.unloaded then
        return
    end

        a105 = if typeof(a105) == "table" then a105 else {}
    local a106 = a105.position or a105.Position or "Top"
    local a107 = typeof(a106) ~= "string" or a106:lower() ~= "bottom"
    a105.position = if a107 then "Top" else "Bottom"
    local a108 = if a107 then "_toastsTop" else "_toastsBottom"
    local a109 = self[a108]

    if not a109 then
        a109 = self:Create("Frame", {
            Name = "Toasts",
            Size = UDim2.new(0, a26, 1, -24),
            Position = if a107 then a23 else UDim2.new(0.5, 0, 1, -12),
            AnchorPoint = if a107 then Vector2.new(0.5, 0) else Vector2.new(0.5, 1),
            BackgroundTransparency = 1,
            ZIndex = a6.zIndex.toast,

            Parent = self.screenGui,
        })

        self:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            VerticalAlignment = if a107 then Enum.VerticalAlignment.Top else Enum.VerticalAlignment.Bottom,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 0),

            Parent = a109,
        })

        self[a108] = a109

                        if a107 then
            a48(self, false)
        end
    end

    return require(script.Parent.Parent.components.toast).new(self, a105, a109)
end

function a17:Popup(a110)
    if self.unloaded then
        return
    end
    return require(script.Parent.Parent.components.popup).new(self, a110)
end

function a17:Close()
    if self.animating or self.unloaded then
        return
    end
    self.animating = true
    self.hidden = true
    self.collapsedInteract.Visible = false
    self._closeTransitionId = (self._closeTransitionId or 0) + 1
    local a111 = self._closeTransitionId
    local a112 = self.main.Size
    local a113 = self.main.Position
    local a114 = UDim2.new(
        a113.X.Scale,
        a113.X.Offset,
        a113.Y.Scale - a112.Y.Scale / 2,
        a113.Y.Offset - a112.Y.Offset / 2
    )
    local a115 = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

    self.main.ClipsDescendants = true
    self.main.AnchorPoint = Vector2.new(0.5, 0)
    self.main.Position = a114
    self.drag.drag.Visible = false
    a15.tweenService:Create(self.windowShadow, a115, { Transparency = 1 }):Play()
    a15.tweenService:Create(self.windowStroke, a115, { Transparency = 1 }):Play()
    local a116 = a15.tweenService:Create(self.main, a115, {
        Size = UDim2.new(a112.X.Scale, a112.X.Offset, 0, 0),
    })
    a116.Completed:Connect(function()
        if not self.unloaded and self._closeTransitionId == a111 then
            self.drag.drag.Visible = false
            self:Unload()
        end
    end)
    a116:Play()
    a15.tweenService:Create(self.windowCorner, a115, { CornerRadius = UDim.new(1, 0) }):Play()
end

function a17:Hide()
            if self.animating or self.hidden then
        return
    end

            if self._searching then
        a13.close(self, { showTabs = false, jumpTo = self.selectedTab and self.selectedTab.tabPage })
    end

            if self._recordingKeybind then
        self._recordingKeybind:_stopRecording()
    end

    self.animating = true
    self._revealing = true
    self.hidden = true
    self.collapsedInteract.Visible = false
                if self.minimised then
        self.minimised = false
        a2.assign(self.minimiseAction.iconLabel, "Image", self:ResolveIcon(a6.icons.minimise))     end

        self._restorePosition = self.main.Position

    local a117, a118 = self:_collapsedRect()

    local a119 = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            local a120 = TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut)
    local a121 = TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut)
    local a122 = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

            self._hideTransitionId = (self._hideTransitionId or 0) + 1
    local a123 = self._hideTransitionId

            a15.tweenService
        :Create(self.drag.dragCosmetic, a119, { Size = UDim2.fromOffset(0, 4), BackgroundTransparency = 1 })
        :Play()
    task.delay(0.18, function()
        if self.unloaded or not self.hidden or self._hideTransitionId ~= a123 then
            return
        end
        self.drag.drag.Visible = false
    end)

            self:_fadeSurfaces(false, a119)

    if self.title then
        a15.tweenService:Create(self.title, a119, { TextTransparency = 1 }):Play()
    end
    if self.subtitle then
        a15.tweenService:Create(self.subtitle, a119, { TextTransparency = 1 }):Play()
    end
    if self.topbarIcon then
        a15.tweenService:Create(self.topbarIcon, a119, { ImageTransparency = 1 }):Play()
    end

    for _, a124 in ipairs(self.actionContainer:GetChildren()) do
        if a124:IsA("Frame") then
            a15.tweenService:Create(a124.ImageLabel, a119, { ImageTransparency = 1 }):Play()
        end
    end

    for _, a125 in self.tags do
        a125:_setShown(false, a119)
    end

    for _, tab in pairs(self.tabs) do
        if not tab.neglectSelector and tab.topbarItem then
            tab:_applyVisual("hidden", a119)
        end
    end
    self:_setTabSectionsShown(false, a119)

    self:_fadeSelectedElementsOut()

            local a126 = a15.tweenService:Create(self.main, a120, { Size = a118, Position = a117 })
    a126.Completed:Connect(function()
                        if self.unloaded or not self.hidden or self._hideTransitionId ~= a123 then
            return
        end

                        self._collapsedShown = true
        a48(self, true)
        self.collapsedInteract.Visible = true
        self.animating = false
        self._revealing = false
    end)
    a126:Play()
    a15.tweenService:Create(self.windowCorner, a121, { CornerRadius = UDim.new(1, 0) }):Play()

            task.delay(0.18, function()
        if self.unloaded or not self.hidden or self._hideTransitionId ~= a123 then
            return
        end
        self.topbar.Visible = false
        self:_setContentVisible(false)

        a12.setCollapsedShown(self, true, a122)
    end)
end

function a17:ToggleHide()
    if self.animating then
        return
    end
    if self.hidden then
        self:Show()
    else
        self:Hide()
    end
end

function a17:ToggleMinimise()
    if self.animating or self.hidden then
        return
    end

        if self._searching then
        a13.close(self, { showTabs = true })
    end

    self.animating = true
    self.drag.drag.Visible = false
    self.collapsedInteract.Visible = false

    local a127 = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    local a128 = TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

    self._hideTransitionId = (self._hideTransitionId or 0) + 1

    if self.minimised then
        self.minimised = false
        self.drag.drag.Visible = false
        a2.assign(self.minimiseAction.iconLabel, "Image", a6.icons.minimise)
        a15.tweenService:Create(self.main, a127, { Size = self.size }):Play()
        self:_fadeSurfaces(true, a128)	a12.setCollapsedShown(self, false, a128)

        a15.tweenService
            :Create(self.drag.drag, a127, {
                Position = UDim2.new(
                    self.main.Position.X.Scale,
                    self.main.Position.X.Offset,
                    self.main.Position.Y.Scale,
                    self.main.Position.Y.Offset + self.size.Y.Offset / 2 + 15
                ),
            })
            :Play()

                        task.delay(0.2, function()
            if self.unloaded or self.minimised or self.hidden then
                return             end
            self:_setContentVisible(true)

            for _, tab in pairs(self.tabs) do
                if not tab.neglectSelector and tab.topbarItem then
                    tab.topbarItem.Visible = true
                    tab:_applyVisual(if self.selectedTab == tab then "selected" else "unselected", a128)
                end
            end
            self:_setTabSectionsVisible(true)
            self:_setTabSectionsShown(true, a128)

            self:_revealElements(0.035, 0.4)
        end)

        task.delay(0.5, function()
            self.animating = false
        end)
    else
        self.minimised = true
        self.drag.drag.Visible = false
        a2.assign(self.minimiseAction.iconLabel, "Image", self:ResolveIcon(a6.icons.maximise))
                        self:_fadeSelectedElementsOut()
        for _, tab in pairs(self.tabs) do
            if not tab.neglectSelector and tab.topbarItem then
                tab:_applyVisual("hidden", a128)
            end
        end
        self:_setTabSectionsShown(false, a128)

        task.delay(0.3, function()
            if self.unloaded or not self.minimised then
                return             end
            self:_setContentVisible(false)
            for _, tab in pairs(self.tabs) do
                if not tab.neglectSelector and tab.topbarItem then
                    tab.topbarItem.Visible = false
                end
            end
            self:_setTabSectionsVisible(false)
        end)

        self:_fadeSurfaces(false, a128)	a12.setCollapsedShown(self, true, a128)
        a15.tweenService
            :Create(self.main, a127, { Size = UDim2.fromOffset(self.size.X.Offset, self.layout.topbarHeight) })
            :Play()

        a15.tweenService
            :Create(self.drag.drag, a127, {
                Position = UDim2.new(
                    self.main.Position.X.Scale,
                    self.main.Position.X.Offset,
                    self.main.Position.Y.Scale,
                    self.main.Position.Y.Offset + self.layout.topbarHeight / 2 + 15
                ),
            })
            :Play()

        task.delay(0.5, function()
            if self.unloaded then
                return
            end
            if self.minimised and not self.hidden then
                self:_syncDragBar()
                self.drag.drag.Visible = true
            end
            self.animating = false
        end)
    end
end

function a17:_syncDragBar()
    local a129 = self.drag and self.drag.drag
    if not a129 then
        return
    end
    local a130 = self.main.Position
    local a131 = if self.minimised then self.layout.topbarHeight / 2 + 15 else self.size.Y.Offset / 2 + 15
    a129.Position = UDim2.new(a130.X.Scale, a130.X.Offset, a130.Y.Scale, a130.Y.Offset + a131)
end

function a17:_clampedPosition(a132: UDim2): UDim2
    if not self.settings or not self.settings.keepOnScreen then
        return a132
    end
            if a132.X.Scale ~= 0 or a132.Y.Scale ~= 0 then
        return a132
    end

    local a133 = self.screenGui.AbsoluteSize
    local a134, a135 = self.size.X.Offset / 2, self.size.Y.Offset / 2
    local a136 = 8
        local x = math.clamp(a132.X.Offset, a134 + a136, math.max(a134 + a136, a133.X - a134 - a136))
    local y = math.clamp(a132.Y.Offset, a135 + a136, math.max(a135 + a136, a133.Y - a135 - a136))
    if x == a132.X.Offset and y == a132.Y.Offset then
        return a132
    end
    return UDim2.fromOffset(x, y)
end

function a17:_clampToScreen()
    self.main.Position = self:_clampedPosition(self.main.Position)
end

function a17:_applyWindowSize()
    if self.unloaded then
        return
    end

    local a137 = a33(self.layout.mode)
    local a138 = a137 ~= self.size
    self.size = a137

            self:_applyRailWidth()

            if self.hidden or self.minimised or self.animating or self._revealing then
        self._pendingResize = self._pendingResize or a138
        return
    end

    if not a138 and not self._pendingResize then
        return
    end
    self._pendingResize = false

    self.main.Size = a137
    self:_clampToScreen()
    self:_syncDragBar()
end

function a17:_applyRailWidth()
    if self.layout.mode ~= "sidebar" then
        return
    end

    local a139 = a11.railWidthFor(self.layout, self.size.X.Offset)
    a14.applyWidth(self, a139)

    if self._settingsLayoutActive or self.selectedTab == self.rfSettings then
        self:_applySettingsLayout(true)
    end
end

function a17:_watchViewport()
    local a140: RBXScriptConnection? = nil
    local a141 = false

    local function a142()
                if a141 then
            return
        end
        a141 = true
        task.defer(function()
            a141 = false
            self:_applyWindowSize()
        end)
    end

    local function a143()
        if a140 then
            self:Disconnect(a140)
            a140 = nil
        end
        local a144 = a15.workspace.CurrentCamera
        if a144 then
            a140 = self:Connect(a144:GetPropertyChangedSignal("ViewportSize"), a142)
        end
        a142()
    end

    self:Connect(a15.workspace:GetPropertyChangedSignal("CurrentCamera"), a143)
    a143()

            local a145 = 0
    self:Connect(a15.runService.Heartbeat, function(a146: number)
        a145 += a146
        if a145 < a32 then
            return
        end
        a145 = 0
        self:_applyWindowSize()
    end)
end

function a17:_bindKeybind()
    self:Connect(a15.userInputService.InputBegan, function(a147, a148)
        if a148 or self._recordingKeybind then
            return         end
        if a147.KeyCode == self.settings.toggleKeybind or a147.UserInputType == self.settings.toggleKeybind then
            self:ToggleHide()
        end
    end)
end

function a17:_bindMouseOverride()
    local a149 = a15.userInputService

    local function a150()
        return self.settings.mouseOverride and not self.hidden and not self.minimised
    end

    local function a151()
        if not a150() then
            return
        end
                        if a149:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            return
        end
        if a149.MouseBehavior ~= Enum.MouseBehavior.Default then
            a149.MouseBehavior = Enum.MouseBehavior.Default
        end
        if not a149.MouseIconEnabled then
            a149.MouseIconEnabled = true
        end
    end

            self:Connect(a149:GetPropertyChangedSignal("MouseBehavior"), a151)
    self:Connect(a149:GetPropertyChangedSignal("MouseIconEnabled"), a151)

            self:Connect(a149.InputEnded, function(a152)
        if a152.UserInputType == Enum.UserInputType.MouseButton2 then
            a151()
        end
    end)

        self._freeMouse = a151
end

function a17:_bindTopbarDrag()
    local a153 = a15.userInputService
    local a154 = false
    local a155 = Vector2.zero
    local a156

            local a157 = Vector2.zero
    if self.screenGui and self.screenGui.IgnoreGuiInset then
        a157 = a15.guiService:GetGuiInset()
    end

    local function a158()
        local a159 = a153:GetMouseLocation() + a155 + a157
        local x, y = a159.X, a159.Y

        if self.settings and self.settings.keepOnScreen then
            local a160 = self.main.AbsoluteSize
            local a161 = self.screenGui.AbsoluteSize
            local a162 = 8
            local a163, a164 = a160.X / 2, a160.Y / 2
            x = math.clamp(x, a163 + a162, math.max(a163 + a162, a161.X - a163 - a162))
            y = math.clamp(y, a164 + a162, math.max(a164 + a162, a161.Y - a164 - a162))
        end

        return UDim2.fromOffset(x, y)
    end

    local function a165()
        a154 = false
        if a156 then
            self:Disconnect(a156)
            a156 = nil
        end
    end

    local function a166()
        if not a154 then
            a165()
            return
        end
        if self.unloaded or not self:_interactive() then
            a165()
            return
        end

        local a167 = a158()
        if self.main.Position == a167 then
            return
        end
        self.main.Position = a167
        if self.drag and self.drag.drag then
            local a168 = self.main.Position
            self.drag.drag.Position = UDim2.new(
                a168.X.Scale,
                a168.X.Offset,
                a168.Y.Scale,
                a168.Y.Offset + (self.main.Size.Y.Offset / 2 + 15)
            )
        end
    end

                local function a169(x, y)
        for _, a170 in { self.tabList, self.actionContainer } do
            local a171, a172 = a170.AbsolutePosition, a170.AbsoluteSize
            if x >= a171.X and x <= a171.X + a172.X and y >= a171.Y and y <= a171.Y + a172.Y then
                return true
            end
        end
        return false
    end

    self:Connect(self.topbar.InputBegan, function(a173, a174)
        if a174 then
            return
        end

        local a175 = a173.UserInputType.Name
        if a175 ~= "MouseButton1" and a175 ~= "Touch" then
            return
        end

        if a169(a173.Position.X, a173.Position.Y) then
            return
        end

                if not self:_interactive() then
            return
        end

        a154 = true
        if a156 then
            self:Disconnect(a156)
            a156 = nil
        end
        a156 = self:Connect(a15.runService.RenderStepped, a166)

        if self.screenGui and self.screenGui.IgnoreGuiInset then
            a157 = a15.guiService:GetGuiInset()
        end

        a155 = self.main.AbsolutePosition + self.main.AbsoluteSize * self.main.AnchorPoint - a153:GetMouseLocation()
    end)

    self:Connect(a153.InputEnded, function(a176)
        local a177 = a176.UserInputType.Name
        if a177 == "MouseButton1" or a177 == "Touch" then
            a165()
        end
    end)

            self:Connect(a153.WindowFocusReleased, function()
        a165()
    end)
end

function a17:_buildSettingsUI()
    self.rfSettings:CreateSection({ name = "General" })

    self.rfSettings:CreateKeybind({
        name = "Toggle Keybind",
        icon = a6.icons.search,
        value = self.settings.toggleKeybind,
        isMenuToggle = true,         onChanged = function(a178)
            self.settings.toggleKeybind = a178
            self:SaveSettings()
        end,
    })

    self.rfSettings:CreateToggle({
        name = "Unlock cursor while open",
        description = "Unlocks the cursor while the menu is open so you can configure in FPS games that lock it.",
        value = self.settings.mouseOverride,
        callback = function(a179)
            self.settings.mouseOverride = a179
            self:SaveSettings()
        end,
    })

    self.rfSettings:CreateToggle({
        name = "Welcome toast",
        description = "Shows a 'Signed in as' toast the first time you open the menu on a new account.",
        value = self.settings.welcomeToast,
        callback = function(a180)
            self.settings.welcomeToast = a180
            self:SaveSettings()
        end,
    })

    self.rfSettings:CreateToggle({
        name = "Haptics",
        description = "A subtle tap as you interact, on devices that support haptics.",
        value = self.settings.haptics,
        callback = function(a181)
            self.settings.haptics = a181
            a9.setEnabled(a181)
            self:SaveSettings()
        end,
    })

    self.rfSettings:CreateToggle({
        name = "Show profile",
        description = "Shows your account profile in the active bar layout.",
        value = self.settings.showProfile,
        callback = function(a182)
            self.settings.showProfile = a182 == true
            a14.reflowProfile(self)
            a14.setProfileShown(self, self.settings.showProfile, a14.settleInfo)
            self:SaveSettings()
        end,
    })

    self.rfSettings:CreateToggle({
        name = "Reveal full username",
        description = "Shows your full Roblox username in the sidebar instead of the masked version.",
        value = self.settings.showFullUsername,
        callback = function(a183)
            self.settings.showFullUsername = a183 == true
            a14.refreshProfileName(self)
            self:SaveSettings()
        end,
    })

    self.rfSettings:CreateToggle({
        name = "Prevent duplicate windows",
        description = "Prevents Astra from creating another window while this window is active.",
        value = self.settings.antiWindowDuplicate,
        callback = function(a184)
            self.settings.antiWindowDuplicate = a184
            self:SaveSettings()
        end,
    })

    self.rfSettings:CreateSection({ name = "Layout" })

    local a185 = {
        top = "Default Topbar",
        sidebar = "Sidebar (Responsive)",
        collapsedSidebar = "Collapsed Sidebar",
    }
    local a186 = self.settings.layoutMode or self.layout.mode
    local a187 = self.rfSettings:CreateDropdown({
        name = "Bar Layout",
        description = "Choose Default Topbar, responsive Sidebar, or an automatic compact Collapsed Sidebar for desktop and mobile.",
        options = { a185.top, a185.sidebar, a185.collapsedSidebar },
        value = a185[a186],
        callback = function(a188)
            local a189
            for a190, a191 in a185 do
                if a188 == a191 then
                    a189 = a190
                    break
                end
            end
            if not a189 then
                return
            end

            local a192 = a42(self.layout)
            if a189 == a192 then
                self:Notify({
                    title = "Bar layout",
                    content = "The " .. a188 .. " layout is already active.",
                })
                if layoutDropdown then
                    layoutDropdown:Set(a185[a192], true)
                end
                return
            end

            if layoutDropdown then
                layoutDropdown:Set(a185[a192], true)
            end
            self:Popup({
                title = "Apply bar layout?",
                content = "Are you sure you want to change the layout to " .. a188 .. "?",
                options = {
                    { text = "Cancel" },
                    {
                        text = "Apply",
                        style = "primary",
                        callback = function()
                            if self:_setLayoutMode(a189) then
                                a186 = a189
                                self.settings.layoutMode = a189
                                self:SaveSettings()
                                self:Notify({
                                    title = "Bar layout changed",
                                    content = "Switched to the " .. a185[a189] .. " layout.",
                                })
                                if layoutDropdown then
                                    layoutDropdown:Set(a185[a189], true)
                                end
                            else
                                a186 = a42(self.layout)
                                if layoutDropdown and a185[a186] then
                                    layoutDropdown:Set(a185[a186], true)
                                end
                                self:Notify({
                                    title = "Bar layout",
                                    content = "The selected bar layout could not be applied right now.",
                                })
                            end
                        end,
                    },
                },
            })
        end,
    })

    self.rfSettings:CreateSection({ name = "Window" })

    self.rfSettings:CreateToggle({
        name = "Keep window on screen",
        description = "Stops the window being dragged off the edge of the screen and lost.",
        value = self.settings.keepOnScreen,
        callback = function(a193)
            self.settings.keepOnScreen = a193
            self:SaveSettings()
        end,
    })

    self.rfSettings:CreateButton({
        name = "Reset Window Position",
        callback = function()
            a15.tweenService
                :Create(self.main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                })
                :Play()
            a15.tweenService
                :Create(self.drag.drag, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0.5, 0, 0.5, self.size.Y.Offset / 2 + 15),
                })
                :Play()
        end,
    })

            if next(self.configuration) ~= nil then
        self.rfSettings:CreateSection({ name = "Configurations" })

        local a194 = self:ListConfigs()[1]
        local a195, a196

        local function a197()
            local a198 = self:ListConfigs()
            a195:Refresh(a198)
            if a194 and not table.find(a198, a194) then
                a194 = a198[1]
            end
            if a194 then
                a195:Set(a194, true)
            end
        end

        a195 = self.rfSettings:CreateDropdown({
            name = "Saved Configurations",
            icon = a6.icons.config,
            options = self:ListConfigs(),
            value = a194,
            placeholder = "No saved configurations",
            callback = function(a199)
                a194 = a199
            end,
        })

        a196 = self.rfSettings:CreateInput({
            name = "Configuration Name",
            description = "Name a new configuration, or leave blank to overwrite the selected one.",
            placeholder = "e.g. PvP Loadout",
            clearOnFocus = false,
        })

        local a200 = self.rfSettings:CreateGroup()

        a200:CreateButton({
            name = "Save",
            icon = a6.icons.config,
            callback = function()
                local a201 = a196.value
                if a201 == "" then
                    a201 = a194
                end
                if not a201 or a201 == "" then
                    self:Toast({ title = a7.resolve("Name your configuration first") })
                    return
                end
                if self:Save(a201) then
                    a196:Set("")
                    a194 = a201
                    a197()
                    self:Toast({
                        title = a7.resolve("Saved configuration"),
                        subtitle = a201,
                        icon = a6.icons.config,
                    })
                else
                    self:Toast({ title = a7.resolve("Couldn't save configuration"), subtitle = a201 })
                end
            end,
        })

        a200:CreateButton({
            name = "Load",
            callback = function()
                if not a194 or a194 == "" then
                    self:Toast({ title = a7.resolve("Pick a configuration to load") })
                    return
                end
                if self:_applyNamedConfig(a194) then
                    self:Toast({ title = a7.resolve("Loaded configuration"), subtitle = a194 })
                else
                    self:Toast({ title = a7.resolve("Couldn't load configuration"), subtitle = a194 })
                end
            end,
        })

        a200:CreateButton({
            name = "Delete",
            callback = function()
                local a202 = a194
                if not a202 or a202 == "" then
                    self:Toast({ title = a7.resolve("Pick a configuration to delete") })
                    return
                end
                if self:DeleteConfig(a202) then
                    a197()
                    self:Toast({ title = a7.resolve("Deleted configuration"), subtitle = a202 })
                else
                    self:Toast({ title = a7.resolve("Couldn't delete configuration"), subtitle = a202 })
                end
            end,
        })
    end
end

function a17:SetProfile(a203)
    self.profileText = a203
    a14.setSubtitle(self, a203)
end

function a17:SaveSettings()
    return a5.saveSettings(self)
end

function a17:LoadSettings()
    return a5.loadSettings(self)
end

function a17:_roundCorners(a204, a205)
    if not a205 or not a38 then
        return self:Create("UICorner", {
            Parent = a204,
        }, { CornerRadius = "CornerRoundness" })
    end

    local a206 = { Parent = a204 }
    local a207 = {}
    for _, a208 in a37 do
        a206[a208] = UDim.new(0, 0)
    end
    for _, a209 in a205 do
        a206[a209] = nil         a207[a209] = "CornerRoundness"
    end

    return self:Create("UICorner", a206, a207)
end

function a17:_setElementLocked(element, a210, a211)
    a210 = a210 == true
                local a212 = element.locked == true
    if a212 == a210 and not (a210 and a211) then
        return
    end
    element.locked = a210

    if not element.lockScrim then
        self:_buildLockScrim(element)
    end

    local a213 = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    if a210 then
        element.lockScrim.Visible = true
    end
    a15.tweenService
        :Create(element.lockScrim, a213, {
            BackgroundTransparency = if a210 then a28 else 1,
        })
        :Play()
    if not a210 then
        task.delay(a213.Time, function()
            if not element.locked and element.lockScrim and element.lockScrim.Parent then
                element.lockScrim.Visible = false             end
        end)
    end

        local a214 = element.descriptor
    if not a214 then
        return
    end

    if a210 then
                        element._descriptionBefore = element._descriptionBefore or a214.titleLabel.Text
        a214.titleLabel.Text = a7.resolve(a211 or "This element is locked.")
    elseif element._descriptionBefore then
        a214.titleLabel.Text = element._descriptionBefore
        element._descriptionBefore = nil
    end

    a15.tweenService
        :Create(a214.titleLabel, a213, {
            TextTransparency = if a210 then a29 else 0.7,
        })
        :Play()
end

function a17:_buildLockScrim(element)
    element.lockScrim = self:Create("TextButton", {
        Name = "ElementLock",
        Active = true,
        AutoButtonColor = false,
        Size = UDim2.fromScale(1, 1),
        BorderSizePixel = 0,
        Text = "",
        TextTransparency = 1,
        ZIndex = a6.zIndex.elementLock,
        Visible = false,

                        BackgroundTransparency = 1,
        Parent = element.main,
    }, { BackgroundColor3 = { "WindowColor", a45 } })

    self:Create("UICorner", {
        Parent = element.lockScrim,
    }, { CornerRadius = "ElementCornerRadius" })
end

function a17:_setLayoutMode(a215)
    if self.unloaded then
        return false
    end
    if self.animating or self.minimised or (self.hidden and self.hasShownOnce) then
        return false
    end
    local a216 = a11.get(a215)
    local a217 = a42(self.layout)
    if not a216 or a215 == a217 then
        return false
    end
    if self._layoutTransitioning then
        return false
    end
    self._layoutTransitioning = true
    self._layoutTransitionId = (self._layoutTransitionId or 0) + 1
    local a218 = self._layoutTransitionId
    local a219 = TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    self:_fadeSurfaces(false, a219)
    self:_fadeSelectedElementsOut()
    for _, tab in self.tabs do
        if not tab.neglectSelector and tab.topbarItem then
            tab:_applyVisual("hidden", a219)
        end
    end
    task.wait(0.12)
    if self.unloaded then
        self._layoutTransitioning = false
        return false
    end
    if self._searching then
        a13.close(self, { showTabs = true, jumpTo = self.selectedTab and self.selectedTab.tabPage })
    end
    local a220 = a42(self.layout)
    self.layout = a216
    self.settings.layoutMode = a215
    if self.sidebar then
        self:DestroySubtree(self.sidebar)
        self.sidebar = nil
    elseif self.tabList then
        self:DestroySubtree(self.tabList)
    end
    if a216.mode == "sidebar" then
        a14.build(self, a216)
        if not self.elementsCorner then
            self.elementsCorner = self:_roundCorners(self.elements, a216.cardCorners)
            self.elementsStroke = self:Create("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Transparency = 1,
                Parent = self.elements,
            }, { Color = "SurfaceStroke" })
            self:Create("UIGradient", {
                Rotation = a216.cardStrokeRotation,
                Transparency = a216.cardStrokeTransparency,
                Parent = self.elementsStroke,
            })
        end
        a14.applyWidth(self, a11.railWidthFor(a216, self.size.X.Offset))
    else
        a36(self)
        a14.build(self, a216)
        if self.elementsCorner then
            self.elementsCorner.CornerRadius = UDim.new(0, 0)
        end
        if self.elementsStroke then
            self.elementsStroke.Transparency = 1
        end
        self.elements.Size = UDim2.new(1, 0, 1, -a216.chromeHeight)
        self.bottomFade.Size = UDim2.new(1, 0, a216.fadeSize.Y.Scale, a216.fadeSize.Y.Offset)
        a13.railWidth(self, 0)
    end
    self.elementsLayout.FillDirection = a216.pageDirection

    for _, tab in self.tabs do
        if not tab.neglectSelector then
            tab:_rebuildSelector()
            tab.topbarItem.Visible = self.elements.Visible and not self.hidden and not self.minimised
            tab:_applyVisual(if self.selectedTab == tab then "selected" else "unselected")
        end
    end
    self:_applySettingsLayout(self.selectedTab == self.rfSettings)
    if self.selectedTab then
        self:_jumpTo(self.selectedTab.tabPage)
        self.selectedTab:_applyVisual("selected")
    end
    self:_fadeSurfaces(true, a219)
    self:_setTabSectionsShown(true, a219)
    task.spawn(function()
        if not self.unloaded and self._layoutTransitionId == a218 then
            self:_revealElements(0.02, 0.5, a218)
        end
    end)
    self._layoutTransitioning = false
    return a220 ~= a215
end
function a17:_buildSettingsCard()
    if self.settingsCard then
        return self.settingsCard
    end

    local a221 = self.layout.mode ~= "sidebar"
    local a222 = self:Create("Frame", {
        Name = "SettingsCard",
        Size = if a221 then UDim2.new(1, -20, 1, -10) else UDim2.new(1, -20, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 1,
        Parent = self.elements,
    }, { BackgroundColor3 = "WindowColor", BackgroundTransparency = "ElementTransparency" })

    local a223 = self:StyleElementBody(a222)

    self.settingsCard = a222
    self.settingsCardStroke = a223
    self._settingsCardBuilt = true

    local a224 = self.rfSettings
    if a224 and a224.tabPage then
        a224.tabPage.Parent = a222
    end

    if self.settingsSubTabBar then
        self.settingsSubTabBar.Parent = a222
    end
    if self.settingsSubTabPages then
        self.settingsSubTabPages.Parent = a222
    end

    return a222
end

function a17:_destroySettingsCard()
    if self.rfSettings and self.rfSettings.tabPage then
        self.rfSettings.tabPage.Parent = self.elements
    end
    if self.settingsCard then
        self:DestroySubtree(self.settingsCard)
        self.settingsCard = nil
        self.settingsCardStroke = nil
    end
    self._settingsCardBuilt = false
end

function a17:_setSettingsSubTabsVisible(a225)
    local a226 = #self._settingsTabs > 0
    if self.settingsSubTabBar then
        self.settingsSubTabBar.Visible = a225 and a226
    end
    if self.settingsSubTabPages then
        self.settingsSubTabPages.Visible = a225 and a226
    end
    if a225 and a226 then
        self:_selectSettingsSubTab(self._settingsActiveSubTab, true)
    end
end

function a17:_selectSettingsSubTab(a227, a228)
    local a229 = self._settingsTabs
    if #a229 == 0 then
        return
    end
    a227 = math.clamp(a227, 1, #a229)
    self._settingsActiveSubTab = a227
    self.settings.activeSubTab = a227

    for i, a230 in a229 do
        local a231 = i == a227
        if a230.page then
            a230.page.Visible = a231
        end
        if a230.button then
            local a232 = if a228 then nil else TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            local a233 = if a231 then 0.25 else 1
            if a232 then
                a15.tweenService:Create(a230.button, a232, { BackgroundTransparency = a233 }):Play()
            else
                a230.button.BackgroundTransparency = a233
            end
            a230.button.TextColor3 = if a231 then self.theme.ContentColor else self.theme.TitlingColor
        end
    end
end

function a17:AddSettingsTab(a234)
    assert(not self.unloaded, "Cannot add a settings tab to an unloaded window.")
    a234 = if typeof(a234) == "table" then a234 else {}

    local a235 = self.rfSettings
    if not a235 then
        return nil
    end

    if not self.settingsSubTabBar then
        self.settingsSubTabBar = self:Create("Frame", {
            Name = "SettingsSubTabBar",
            Size = UDim2.new(1, -20, 0, 30),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = self.settingsCard,
        })

        self:Create("UIListLayout", {
            Padding = UDim.new(0, 6),
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = self.settingsSubTabBar,
        })

        self.settingsSubTabPages = self:Create("Frame", {
            Name = "SettingsSubTabPages",
            Size = UDim2.new(1, -20, 1, -56),
            Position = UDim2.new(0, 10, 0, 46),
            BackgroundTransparency = 1,
            Visible = false,
            ZIndex = 2,
            Parent = self.settingsCard,
        })
    end

    local a236 = a7.resolve(a234.name or a234.Name or "Settings Tab")
    local a237 = self:ResolveIcon(a234.icon or a234.Icon)
    local a238 = #self._settingsTabs + 1

    local a239 = self:Create("TextButton", {
        Name = a236,
        Text = a236,
        TextSize = 13,
        FontFace = a15.brandFont(Enum.FontWeight.Medium),
        AutoButtonColor = false,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = a238,
        Parent = self.settingsSubTabBar,
    }, { TextColor3 = "TitlingColor", BackgroundColor3 = "ContentColor" })

    self:Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = a239,
    })

    self:Create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        Parent = a239,
    })

    local a240 = self:Create("ScrollingFrame", {
        Name = a236,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        ScrollBarImageTransparency = 1,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Visible = false,
        ZIndex = 2,
        Parent = self.settingsSubTabPages,
    })

    self:Create("UIListLayout", {
        Padding = UDim.new(0, 7),
        FillDirection = Enum.FillDirection.Vertical,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = a240,
    })

    self:Create("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        Parent = a240,
    })

    local a241 = {
        name = a236,
        icon = a237,
        page = a240,
        button = a239,
        index = a238,
    }
    table.insert(self._settingsTabs, a241)

    local a242 = setmetatable({
        window = self,
        name = a236,
        elements = {},
        connections = {},
        forgetState = false,
        tabPage = a240,
    }, { __index = a235 })

    self:Connect(a239.MouseButton1Click, function()
        a9.click()
        self:_selectSettingsSubTab(a238)
    end)

    self:_selectSettingsSubTab(a238, true)
    if self._settingsLayoutActive then
        self:_setSettingsSubTabsVisible(true)
    end

    return a242
end

function a17:_applySettingsLayout(a243)
    a243 = a243 == true
    self._settingsLayoutActive = a243
    if self.settingsAction then
        a2.assign(self.settingsAction.iconLabel, "Image", a6.icons.settings)
    end
    if self.layout.mode ~= "sidebar" then
        if self.tabList then
            self.tabList.Visible = not a243 and not self.hidden and not self.minimised and self.elements.Visible
        end
        self.elements.Size = UDim2.new(1, 0, 1, -self.layout.chromeHeight)
        self.bottomFade.Size = UDim2.new(1, 0, self.layout.fadeSize.Y.Scale, self.layout.fadeSize.Y.Offset)
        if a243 then
            self:_buildSettingsCard()
            if self.settingsSubTabBar then
                self:_setSettingsSubTabsVisible(true)
            end
        else
            self:_destroySettingsCard()
        end
        if self.selectedTab and self.selectedTab.tabPage then
            self.selectedTab.tabPage.Size = if a243
                then UDim2.new(1, 0, 1, 0)
                else UDim2.new(1, -20, 1, 0)
            self.selectedTab.tabPage.Position = UDim2.new(0, 0, 0, 0)
        end
        return
    end
    local a244 = a11.railWidthFor(self.layout, self.size.X.Offset)
    local tab = self.selectedTab

    if a243 then
        if self.tabList then
            self.tabList.Visible = false
        end
        self:_buildSettingsCard()
        if self.settingsSubTabBar then
            self:_setSettingsSubTabsVisible(true)
        end
        self.elements.Size = UDim2.new(1, 0, 1, -self.layout.chromeHeight)
        self.bottomFade.Size = UDim2.new(1, 0, self.layout.fadeSize.Y.Scale, self.layout.fadeSize.Y.Offset)
        if tab and tab.tabPage then
            tab.tabPage.Size = UDim2.new(1, 0, 1, 0)
            tab.tabPage.Position = UDim2.new(0, 0, 0, 0)
        end
        return
    end

    self:_destroySettingsCard()

    if self.tabList then
        self.tabList.Visible = not self.hidden and not self.minimised
    end
    if self.sidebar then
        self.sidebar.Visible = not self.hidden and not self.minimised
    end
    self.elements.Size = UDim2.new(1, -a244, 1, -self.layout.chromeHeight)
    self.bottomFade.Size = UDim2.new(1, -a244, self.layout.fadeSize.Y.Scale, self.layout.fadeSize.Y.Offset)
    if tab and tab.tabPage then
        tab.tabPage.Size = UDim2.new(1, -35, 1, 0)
        tab.tabPage.Position = UDim2.new(0, 35, 0, 0)
    end
end

function a17:_setContentVisible(a245)
    self.elements.Visible = a245
    if not a245 then
        self.tabList.Visible = false
        if self.sidebar then
            self.sidebar.Visible = false
        end
        return
    end

    self:_applySettingsLayout(self.selectedTab == self.rfSettings)
end

function a17:_fadeSurfaces(a246, a247)
    local a248 = {
        [self.windowShadow] = { Transparency = if a246 then 0.6 else 1 },
        [self.windowStroke] = { Transparency = if a246 then 0.95 else 1 },
        [self.bottomFade] = { BackgroundTransparency = if a246 then 0 else 1 },
    }

    if self.elementsStroke then
        a248[self.elements] = {
            BackgroundTransparency = if a246 then self.layout.cardTransparency else 1,
        }
        a248[self.elementsStroke] = { Transparency = if a246 then 0 else 1 }
    end

    for a249, a250 in a248 do
        if a247 then
            a15.tweenService:Create(a249, a247, a250):Play()
        else
            for a251, a252 in a250 do
                a249[a251] = a252
            end
        end
    end

    a14.setProfileShown(self, a246, a247)
end

function a17:_fadeSelectedElementsOut()
    if self.selectedTab then
        for _, element in ipairs(self.selectedTab.elements) do
            element:_setShown(false, true)
        end
    end
end

function a17:_revealElements(a253, a254, a255)
    local function a256()
        return not self.unloaded
            and not self.hidden
            and not self.minimised
            and (a255 == nil or self._layoutTransitionId == a255)
    end

    if not a256() then
        return
    end
    for _, tab in pairs(self.tabs) do
        if tab ~= self.selectedTab then
            for _, element in ipairs(tab.elements) do
                if not a256() then
                    return
                end
                element:_setShown(true, false)
            end
        end
    end

    local tab = self.selectedTab
    if not tab then
        return
    end

    local a257 = tab.tabPage
    local a258 = a257.AbsolutePosition.Y
    local a259 = a258 + a257.AbsoluteWindowSize.Y

    local a260 = math.floor(a254 / a253)
    local a261 = 0
    for _, element in ipairs(tab.elements) do
        if not a256() then
            return
        end
        local a262 = element.main.AbsolutePosition.Y
        local a263 = (a262 + element.main.AbsoluteSize.Y) > a258 and a262 < a259
        if a263 then
            element:_setShown(true, true)
            a261 += 1
            if a261 <= a260 then
                task.wait(a253)
                if not a256() then
                    return
                end
            end
        else
            element:_setShown(true, false)         end
    end
end

function a17:Show()
        if self.animating or not self.hidden then
        return
    end
    self.animating = true
    self._revealing = true
    self.drag.drag.Visible = false

                if self.configuration.autoLoad and not self._autoLoaded then
        self._autoLoaded = true
        local ok, a264 = pcall(self.Load, self)
        if not ok then
            a8.warn("Astra: Failed to load configuration - " .. tostring(a264))
        end
    end

    self.hidden = false
    self.minimised = false
    self._collapsedShown = false
    a12.setCollapsedShown(self, false)

        if self._themeRefreshPending then
        self._themeRefreshPending = false
        self:_refreshElementThemes()
    end

    self.collapsedInteract.Visible = false
    if self._freeMouse then
        self._freeMouse()
    end

    if self.hasShownOnce then
        self:_quickRestore()
    else
        self.hasShownOnce = true
        self.main.Visible = true
        if not self.unloaded then
            self:_firstShow()
        end
    end
end

function a17:_quickRestore()
    local a265 = self:_clampedPosition(self._restorePosition or UDim2.new(0.5, 0, 0.5, 0))
    self._restorePosition = a265
    local a266 = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    self.main.ClipsDescendants = true
    self.main.BackgroundTransparency = 0
    self.topbar.Visible = true
    self:_setContentVisible(true)
    self:_setTabSectionsVisible(true)
    self:_setTabSectionsShown(true)
    for _, tab in pairs(self.tabs) do
        if not tab.neglectSelector and tab.topbarItem then
            tab.topbarItem.Visible = true
            tab:_applyVisual(if self.selectedTab == tab then "selected" else "unselected")
        end
        for _, element in ipairs(tab.elements) do
            element:_setShown(true, false)
        end
    end
    self:_fadeSurfaces(true)

    if self.topbarIcon then
        self.topbarIcon.ImageTransparency = 0
    end
    if self.title then
        self.title.TextTransparency = 0
    end
    if self.subtitle then
        self.subtitle.TextTransparency = 0.7
    end
    for _, a267 in ipairs(self.actionContainer:GetChildren()) do
        if a267:IsA("Frame") and a267.ImageLabel then
            a267.ImageLabel.ImageTransparency = 0.6
        end
    end

    local a268 = a15.tweenService:Create(self.main, a266, { Size = self.size, Position = a265 })
    a268.Completed:Connect(function()
        if self.hidden or self.unloaded then
            return
        end
        self.main.ClipsDescendants = false
        self._collapsedShown = false
        self:_syncDragBar()
        self.drag.drag.Visible = false
        self.animating = false
        self._revealing = false
        a48(self, true)
    end)
    a268:Play()
    a15.tweenService:Create(self.windowCorner, a266, { CornerRadius = self.theme.CornerRoundness }):Play()
end
function a17:_firstShow()
    self.drag.drag.Visible = false
    self.main.Visible = true
    self.main.ClipsDescendants = true
    self.main.BackgroundTransparency = 1
    self:_setContentVisible(true)
    self:_setTabSectionsVisible(true)
    self:_setTabSectionsShown(true)
    for _, tab in pairs(self.tabs) do
        if not tab.neglectSelector and tab.topbarItem then
            tab.topbarItem.Visible = true
            tab:_applyVisual(if self.selectedTab == tab then "selected" else "unselected")
        end
        for _, element in ipairs(tab.elements) do
            element:_setShown(true, false)
        end
    end
    local a269 = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    if self.topbarIcon then
        self.topbarIcon.ImageTransparency = 0
    end
    if self.title then
        self.title.TextTransparency = 0
    end
    if self.subtitle then
        self.subtitle.TextTransparency = 0.7
    end
    for _, a270 in ipairs(self.actionContainer:GetChildren()) do
        if a270:IsA("Frame") and a270.ImageLabel then
            a270.ImageLabel.ImageTransparency = 0.6
        end
    end

    local a271 = a15.tweenService:Create(self.main, a269, {
        BackgroundTransparency = 0,
        Size = self.size,
    })
    a271.Completed:Connect(function()
        if self.unloaded then
            return
        end
        self.main.ClipsDescendants = false
        self:_syncDragBar()
        self.drag.drag.Visible = false
        self.animating = false
        self._revealing = false
    end)
    a271:Play()
    a15.tweenService:Create(self.windowCorner, a269, { CornerRadius = self.theme.CornerRoundness }):Play()

    local a272 = a15.localPlayer
    if a272 and self.settings.welcomeToast and a12.isNewUser() then
        self:Toast({
            title = a272.DisplayName,
            subtitle = a7.resolve("Signed in as"),
            subtitleAbove = true,
            avatar = a272.UserId,
            minWidth = 220,
        })
    end
end

function a17:GetPath()
    return a5.getPath(self)
end

function a17:Save(a273)
    if a273 ~= nil and (type(a273) ~= "string" or a273 == "") then
        return false
    end
    return a5.save(self, a273)
end

function a17:Load(a274)
    if a274 ~= nil and (type(a274) ~= "string" or a274 == "") then
        return false
    end
    return a5.load(self, a274)
end

function a17:_applyNamedConfig(a275)
    if not self:Load(a275) then
        return false
    end
            local _, a276 = a5.getPath(self)
    self._loadedConfigPath = a276
    self:Save()
    return true
end

function a17:ListConfigs()
    return a5.list(self)
end

function a17:DeleteConfig(a277)
    return a5.delete(self, a277)
end

function a17:Get(a278)
    local a279 = self.controls[a278]
    return a279 and a279.value
end

function a17:Set(a280, a281)
    local a282 = self.controls[a280]
    if not a282 then
        return false
    end
    a282:Set(a281)
    return true
end

function a17:_jumpTo(a283)
    if a283 then
        self.elementsLayout:JumpTo(a283)
    end
end

function a17:Navigate(tab)
    if tab == nil then
        return
    end

    local a284
    for _, a285 in self.tabs do
                if a285 == tab or a285.name == tab or a285.tabPage == tab then
            a284 = a285
            break
        end
    end

    if not a284 then
        return
    end
    a284:Select()
end

function a17:Create(a286, a287, a288)
    assert(typeof(a286) == "string", "Invalid argument #1 (string expected)")
    local a289 = Instance.new(a286)

            if a288 and self.theme then
        for a290, a291 in a288 do
            a289[a290] = (
                if typeof(a291) == "table" then a291[2](self.theme[a291[1]]) else self.theme[a291]
            )
        end

        self.themeProperties[a289] = a288
    end

    if a287 then
        for a292, a293 in a287 do
            if a7.isToken(a293) then
                self:_bindLocale(a289, a292, a7.sourceOf(a293))
            else
                a2.assign(a289, a292, a293)
            end
        end
    end

    table.insert(self.instances, a289)
    return a289
end

function a17:_bindLocale(a294, a295, a296)
    a294[a295] = a7.resolve(a296)

    local a297 = self.localeProperties[a294]
    if not a297 then
        a297 = {}
        self.localeProperties[a294] = a297
    end
    a297[a295] = a296
end

function a17:SetLocale(a298)
    a7.setActive(a298)
    for a299, a300 in self.localeProperties do
        for a301, a302 in a300 do
            a299[a301] = a7.resolve(a302)
        end
    end
end

function a17:SetTranslator(a303)
    a7.translator = a303
end

function a17:RegisterTranslations(a304)
    a7.register(a304)
    self:SetLocale(a7.current)
end

function a17:CreateGlow(a305, a306, a307, a308)
    local a309 = {
        BlurRadius = UDim.new(0, a307),
        Transparency = a308,
        ZIndex = -1,

        Parent = a305,
    }

    if typeof(a306) == "string" then
        return self:Create("UIShadow", a309, {
            Color = {
                a306,
                function(a310)
                    return if typeof(a310) == "ColorSequence" then a310.Keypoints[1].Value else a310
                end,
            },
        })
    end

    a309.Color = a306
    return self:Create("UIShadow", a309)
end

function a17:_flashResult(element, ok)
    local a311 = element.box
    if not a311 then
        return
    end
    local a312 = element.glow
    local a313 = element.boxStroke
    local a314 = ok and a6.accent.on or self.theme.ErrorColor
    local a315 = ok and a6.accent.onStroke or self.theme.ErrorStrokeColor
    local a316 = TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local a317 = TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

        a15.tweenService:Create(a311, a316, { BackgroundColor3 = a314 }):Play()
    if a313 then
        a15.tweenService:Create(a313, a316, { Color = a315, Transparency = 0.4 }):Play()
    end
    if a312 then
        a15.tweenService:Create(a312, a316, { Color = a315, Transparency = 0.6 }):Play()
    end

        element._flashToken = (element._flashToken or 0) + 1
    local a318 = element._flashToken
    task.delay(0.22, function()
        if element._flashToken ~= a318 then
            return
        end
        a15.tweenService:Create(a311, a317, { BackgroundColor3 = self.theme.FieldBackground }):Play()
        if a313 then
            a15.tweenService
                :Create(a313, a317, { Color = self.theme.SurfaceStroke, Transparency = 0.85 })
                :Play()
        end
        if a312 then
            a15.tweenService
                :Create(a312, a317, { Color = self.theme.FieldGlow, Transparency = element._glowIdle or 1 })
                :Play()
        end
    end)
end

function a17:CreateHoverOverlay(a319)
    local a320 = self:Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        BorderSizePixel = 0,
        ZIndex = 1,

        Parent = a319,
    })

    self:Create("UICorner", {
        Parent = a320,
    }, { CornerRadius = "ElementCornerRadius" })

    return a320
end

function a17:_wireElementHover(element)
    local a321 = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local a322 = self.theme

    self:ConnectFor(element, element.main.MouseEnter, function()
        if not self:_interactive() then
            return         end
        a15.tweenService
            :Create(
                element.stroke,
                a321,
                { Transparency = a322.ElementStrokeHoverTransparency, Color = a322.ElementStrokeHover }
            )
            :Play()
        a15.tweenService:Create(element.title, a321, { TextColor3 = a322.ElementTextHoverColor }):Play()
        if element.hoverOverlay then
            a15.tweenService:Create(element.hoverOverlay, a321, { BackgroundTransparency = 0.97 }):Play()
        end
    end)

    self:ConnectFor(element, element.main.MouseLeave, function()
        a15.tweenService
            :Create(
                element.stroke,
                a321,
                { Transparency = a322.ElementStrokeTransparency, Color = a322.ElementStroke }
            )
            :Play()
        a15.tweenService:Create(element.title, a321, { TextColor3 = a322.ContentColor }):Play()
        if element.hoverOverlay then
            a15.tweenService:Create(element.hoverOverlay, a321, { BackgroundTransparency = 1 }):Play()
        end
    end)
end

function a17:_runGuarded(element, fn, ...)
            if element.locked then
        return
    end

    local a323 = table.pack(...)
    task.spawn(function()
        local ok, a324 = pcall(function()
            return fn(table.unpack(a323, 1, a323.n))
        end)
        if ok or element._errored then
            return
        end
        element._errored = true

        local a325 = element.flashTarget or element.main
        local a326 = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        a15.tweenService:Create(a325, a326, { BackgroundColor3 = self.theme.ErrorColor }):Play()
        a15.tweenService:Create(element.stroke, a326, { Color = self.theme.ErrorStrokeColor }):Play()
                if element.title then
            element.title.Text = a7.resolve("Error, log recorded in console.")
        end

        a8.warn(
            `Astra encountered an error, with the callback for a {element.__type} component named '{element.name}':`
        )
        a8.print(a324)

        task.wait(1)

        if element.title then
            element.title.Text = a7.resolve(element.name)
        end
        a15.tweenService
            :Create(
                a325,
                TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
                { BackgroundColor3 = Color3.fromRGB(255, 255, 255) }
            )
            :Play()
        a15.tweenService
            :Create(
                element.stroke,
                TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                { Color = self.theme.ElementStroke }
            )
            :Play()
        element._errored = false
    end)
end

function a17:StyleElementBody(a327)
    self:Create("UIGradient", {
        Rotation = 270,

        Parent = a327,
    }, { Color = "ElementGradient" })

    self:Create("UICorner", {
        Parent = a327,
    }, { CornerRadius = "ElementCornerRadius" })

    return self:Create("UIStroke", {
        Transparency = 1,

        Parent = a327,
    }, { Color = "ElementStroke", Transparency = "ElementStrokeTransparency" })
end

function a17:_buildCompactRow(a328, a329, a330)
    local a331 = self:Create("Frame", {
        Name = a329,
        Size = UDim2.fromOffset(0, a27),
        AutomaticSize = Enum.AutomaticSize.X,
        ClipsDescendants = true,         BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,

        BackgroundTransparency = 1,
        Parent = a328.tabPage,
    }, { BackgroundTransparency = "ElementTransparency" })

    local a332 = self:StyleElementBody(a331)

        self:Create("UIFlexItem", {
        FlexMode = Enum.UIFlexMode.Fill,
        Parent = a331,
    })

        self:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalFlex = Enum.UIFlexAlignment.Fill,

        Parent = a331,
    })

        local a333 = self:Create("TextButton", {
        Text = "",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,         AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.fromOffset(0, a27),
        BorderSizePixel = 0,
        TextTransparency = 1,
        ZIndex = a330 or 1,

        Parent = a331,
    })

    self:Create("UICorner", {
        Parent = a333,
    }, { CornerRadius = "ElementCornerRadius" })

    return a331, a332, a333
end

function a17:StyleElementPanel(a334)
    self:Create("UIGradient", {
        Rotation = 270,

        Parent = a334,
    }, { Color = "ElementGradient" })

    self:Create("UICorner", {
        Parent = a334,
    }, { CornerRadius = "ElementCornerRadius" })

    local a335 = self:Create("UIStroke", {
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 1,
        Parent = a334,
    })

    self:Create("UIGradient", {
        Rotation = 270,

        Parent = a335,
    }, { Color = "ElementStrokeGradient" })

    return a335
end

function a17:_reveal(a336, a337, a338, a339)
    if not a336 then
        return
    end
    local a340 = false
    for a341, a342 in a337 do
        if a336[a341] ~= a342 then
            a340 = true
            break
        end
    end
    if not a340 then
        return
    end
    if a338 then
        a15.tweenService:Create(a336, a339 or a18, a337):Play()
    else
        for a343, a344 in a337 do
            a336[a343] = a344
        end
    end
end

function a17:_revealCommon(element, a345)
    self:_reveal(element.stroke, { Transparency = self.theme.ElementStrokeTransparency }, a345)
    self:_reveal(element.title, { TextTransparency = 0 }, a345)
    self:_reveal(element.main, { BackgroundTransparency = self.theme.ElementTransparency or 0 }, a345)
    if element.iconLabel then
        self:_reveal(element.iconLabel, { ImageTransparency = 0 }, a345)
    end
    if element.descriptor then
        self:_reveal(element.descriptor.titleLabel, { TextTransparency = 0.7 }, a345)
    end
end

function a17:_hideCommon(element, a346)
    self:_reveal(element.stroke, { Transparency = 1 }, a346)
    self:_reveal(element.title, { TextTransparency = 1 }, a346)
    self:_reveal(element.main, { BackgroundTransparency = 1 }, a346)
    if element.iconLabel then
        self:_reveal(element.iconLabel, { ImageTransparency = 1 }, a346)
    end
    if element.descriptor then
        self:_reveal(element.descriptor.titleLabel, { TextTransparency = 1 }, a346)
    end
end

function a17:_collapsedRect()
    local a347 = if self.showIconOnly then a21 else a20
        if self._collapsedPosition then
        return self._collapsedPosition, a347
    end
    local a348 = UDim2.new(
        a22.X.Scale,
        a22.X.Offset,
        a22.Y.Scale,
        a22.Y.Offset + a347.Y.Offset / 2
    )
    return a348, a347
end

function a17:_interactive()
    return not self.animating and not self.hidden
end

function a17:_settled()
    return not self.hidden and not self._revealing
end

function a17:Connect(a349, a350)
    local a351 = a349:Connect(a350)
    table.insert(self.connections, a351)
    return a351
end

function a17:ConnectFor(a352, a353, a354)
    local a355 = self:Connect(a353, a354)
    a352.connections = a352.connections or {}
    table.insert(a352.connections, a355)
    return a355
end

function a17:Disconnect(a356)
    if not a356 then
        return
    end
    local a357 = table.find(self.connections, a356)
    if a357 then
        table.remove(self.connections, a357)
    end
    a356:Disconnect()
end

function a17:DestroySubtree(a358)
    if not a358 then
        return
    end

    local a359 = { [a358] = true }
    for _, a360 in a358:GetDescendants() do
        a359[a360] = true
    end
    for i = #self.instances, 1, -1 do
        local a361 = self.instances[i]
        if a359[a361] then
            table.remove(self.instances, i)
            self.themeProperties[a361] = nil
            self.localeProperties[a361] = nil
        end
    end

    a358:Destroy()
end

function a17:DisconnectMany(a362, a363)
    if not a363 or #a363 == 0 then
        return
    end

    local a364 = {}
    for _, a365 in a363 do
        a364[a365] = true
        a365:Disconnect()
    end

    local function a366(a367)
        if not a367 then
            return
        end
        local a368 = 0
        for a369 = 1, #a367 do
            local a370 = a367[a369]
            if not a364[a370] then
                a368 += 1
                a367[a368] = a370
            end
        end
        for a371 = #a367, a368 + 1, -1 do
            a367[a371] = nil
        end
    end

    a366(self.connections)
    if a362 and a362 ~= self then
        a366(a362.connections)
    end
end

function a17:DestroySubtrees(a372)
    if not a372 or #a372 == 0 then
        return
    end

    local a373 = {}
    for _, a374 in a372 do
        a373[a374] = true
        for _, a375 in a374:GetDescendants() do
            a373[a375] = true
        end
    end

    local a376 = 0
    for a377 = 1, #self.instances do
        local a378 = self.instances[a377]
        if a373[a378] then
            self.themeProperties[a378] = nil
            self.localeProperties[a378] = nil
        else
            a376 += 1
            self.instances[a376] = a378
        end
    end
    for a379 = #self.instances, a376 + 1, -1 do
        self.instances[a379] = nil
    end

    for _, a380 in a372 do
        a380:Destroy()
    end
end

function a17:Unload()
    self.unloaded = true
            a9.teardown()
    a9.releaseContainer(self.screenGui)
    if self._liveTween then
        self._liveTween:Cancel()         self._liveTween = nil
    end
    for i = #self.connections, 1, -1 do
        self.connections[i]:Disconnect()
    end
    for i = #self.instances, 1, -1 do
        self.instances[i]:Destroy()
    end

                table.clear(self.connections)
    table.clear(self.instances)
    table.clear(self.themeProperties)
    table.clear(self.localeProperties)
    table.clear(self.controls)
    table.clear(self.tabs)
end

return a17
