local a1 = {}
a1.__index = a1
a1.__type = "Toggle"

local a2 = script.Parent.Parent.utilities

local a3 = require(a2.Parent.core.state)
local a4 = require(script.Parent.Parent.functions)
local a5 = require(a2.moveable)
local a6 = require(a2.lockable)
local a7 = require(a2.locale)
local a8 = require(a2.HapticEngine)
local a9 = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

function a1.new(tab, a10)
    a10 = if typeof(a10) == "table" then a10 else {}

    local self = setmetatable({
        tab = assert(tab, "Missing argument #1 (Tab expected)"),
        window = tab.window,
        name = a10.name or a10.Name or "Switch",
        icon = tab.window:ResolveIcon(a10.icon or a10.Icon),
        description = a10.description or a10.Description,
        forgetState = a10.forgetState or a10.ForgetState or tab.forgetState,         compact = tab.compact or false,
        flag = a10.flag
            or a10.Flag
            or (
                not (a10.forgetState or a10.ForgetState or tab.forgetState)
                    and a4.deriveFlagFromName(a10.name or a10.Name or "Switch")
                or nil
            ),

        callback = a10.callback or a10.Callback or function() end,

        value = if (a10.value or a10.Value) ~= nil then (a10.value or a10.Value) else false,
    }, a1)

        self.window:_registerControl(self)

    if self.compact then
        self:_buildCompact()
    else
        self:_buildFull()
    end

    if self.description and not self.compact then
        self.descriptor = require(script.Parent.descriptor).new(self.tab, { description = self.description })
    end

    return self
end

function a1:_buildSwitch(a11)
    local window = self.window

    self.functionContainer = window:Create("Frame", {
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(50, 21),

        BackgroundTransparency = 1,
        Parent = a11,
    }, { BackgroundColor3 = "ToggleTrack" })

    window:Create("UICorner", {
        CornerRadius = UDim.new(0, 15),
        Parent = self.functionContainer,
    })

    self.containerStroke = window:Create("UIStroke", {
        Transparency = 1,         Parent = self.functionContainer,
    }, { Color = "SurfaceStroke" })

    self.indicator = window:Create("Frame", {
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(25, 17),
        Position = self.value and UDim2.new(1, -28, 0.5, 0) or UDim2.new(1, -47, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = self.value and self.window.theme.AccentColor or self.window.theme.ToggleKnobOff,

        BackgroundTransparency = 1,
        Parent = self.functionContainer,
    })

    window:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = self.indicator,
    })

    self.indicatorStroke = window:Create("UIStroke", {
        Color = self.value and self.window.theme.AccentStroke or Color3.fromRGB(255, 255, 255),
        Transparency = 1,         Parent = self.indicator,
    })

        self.indicatorGlow = window:CreateGlow(self.indicator, "AccentColor", 20, 1)

        self.overlay = window:Create("Frame", {
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Position = UDim2.fromScale(0, 0),
        AnchorPoint = Vector2.new(0, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),

        BackgroundTransparency = 1,
        Parent = self.functionContainer,
    }, { Visible = "DarkToggleOverlay" })

    window:Create("UICorner", {
        CornerRadius = UDim.new(0, 15),
        Parent = self.overlay,
    })

    self.overlayGradient = window:Create("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 30)),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0.35),
        }),

        Parent = self.overlay,
    })

    return self.functionContainer
end

function a1:_performToggle()
    a8.click()
    self.value = not self.value
    self:_animateIndicator()

    self.window:_runGuarded(self, self.callback, self.value)
    self.window:_persist(self)
end

function a1:_buildFull()
    local window = self.window

    self.main = window:Create("Frame", {
        Size = UDim2.new(1, -20, 0, 41),
        BorderSizePixel = 0,
        Name = self.name,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),

        BackgroundTransparency = 1,

        Parent = self.tab.tabPage,
    }, { BackgroundTransparency = "ElementTransparency" })

    self.stroke = window:StyleElementBody(self.main)
    self.hoverOverlay = window:CreateHoverOverlay(self.main)

    self.container = window:Create("Frame", {
        BorderSizePixel = 0,

        Parent = self.main,
        Size = UDim2.new(0, 170, 0, 16),
        Position = UDim2.new(0, 20, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
    })

    self.containerLayout = window:Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,

        Parent = self.container,
    })

    if self.icon then
        self.iconLabel = window:Create("ImageLabel", {
            Image = self.icon,
            Size = UDim2.fromOffset(16, 16),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,

            ImageTransparency = 1,
            Parent = self.container,
        }, { ImageColor3 = "ContentColor" })
    end

    self.title = window:Create("TextLabel", {
        Text = a7.t(self.name),
        Size = UDim2.fromOffset(250, 16),
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        TextSize = 16,
        AutomaticSize = Enum.AutomaticSize.X,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        LayoutOrder = 1,

        TextTransparency = 1,
        Parent = self.container,
    }, { TextColor3 = "ContentColor", FontFace = "Font" })

    self.interact = window:Create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(1, 0.5),
        AnchorPoint = Vector2.new(1, 0.5),
        TextTransparency = 1,
        ZIndex = 10,

        Parent = self.main,
    })

        self:_buildSwitch(self.main)
    self.functionContainer.Position = UDim2.new(1, -15, 0, 20)
    self.functionContainer.AnchorPoint = Vector2.new(1, 0.5)

    self.window:_wireElementHover(self)

    self.window:ConnectFor(self, self.interact.MouseButton1Click, function()
        a3.tweenService
            :Create(
                self.stroke,
                a9,
                { Transparency = 1 }
            )
            :Play()
        a3.tweenService
            :Create(
                self.main,
                TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
                { Size = UDim2.new(1, -26, 0, 41) }
            )
            :Play()

        self:_performToggle()

        task.wait(0.11)

        if self.window.unloaded then
            return
        end

        a3.tweenService
            :Create(
                self.main,
                TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
                { Size = UDim2.new(1, -20, 0, 41) }
            )
            :Play()
        a3.tweenService
            :Create(
                self.stroke,
                a9,
                { Transparency = self.window.theme.ElementStrokeTransparency }
            )
            :Play()
    end)
end

function a1:_buildCompact()
    local window = self.window

        self.main, self.stroke, self.interact = window:_buildCompactRow(self.tab, self.name, 10)
    self.hoverOverlay = self.interact

    window:Create("UIPadding", {
        PaddingLeft = UDim.new(0, 15),
        PaddingRight = UDim.new(0, 15),

        Parent = self.interact,
    })

        window:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
        Padding = UDim.new(0, 10),

        Parent = self.interact,
    })

    self.container = window:Create("Frame", {
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.fromOffset(0, 16),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = 0,

        Parent = self.interact,
    })

        window:Create("UIFlexItem", {
        FlexMode = Enum.UIFlexMode.Shrink,
        Parent = self.container,
    })

    window:Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,

        Parent = self.container,
    })

    if self.icon then
        self.iconLabel = window:Create("ImageLabel", {
            Image = self.icon,
            Size = UDim2.fromOffset(16, 16),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            LayoutOrder = 0,

            ImageTransparency = 1,
            Parent = self.container,
        }, { ImageColor3 = "ContentColor" })
    end

    self.title = window:Create("TextLabel", {
        Text = a7.t(self.name),
        Size = UDim2.fromOffset(0, 16),
        AutomaticSize = Enum.AutomaticSize.X,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        LayoutOrder = 1,

        TextTransparency = 1,
        Parent = self.container,
    }, { TextColor3 = "ContentColor", FontFace = "Font" })

        window:Create("UIFlexItem", {
        FlexMode = Enum.UIFlexMode.Shrink,
        Parent = self.title,
    })

        self:_buildSwitch(self.interact)
    self.functionContainer.LayoutOrder = 1

    self.window:_wireElementHover(self)

    self.window:ConnectFor(self, self.interact.MouseButton1Click, function()
        a3.tweenService
            :Create(
                self.stroke,
                a9,
                { Transparency = 1 }
            )
            :Play()

        self:_performToggle()

        task.wait(0.11)

        if self.window.unloaded then
            return
        end

        a3.tweenService
            :Create(
                self.stroke,
                a9,
                { Transparency = self.window.theme.ElementStrokeTransparency }
            )
            :Play()
    end)
end

function a1:_animateIndicator()
    local a12 = TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    if self.indicatorGlow then
        a3.tweenService
            :Create(self.indicatorGlow, a12, { Transparency = self.value and self.window.theme.AccentGlow or 1 })
            :Play()
    end
    if self.value then
        a3.tweenService
            :Create(self.indicator, a12, {
                Position = UDim2.new(1, -28, 0.5, 0),
                BackgroundColor3 = self.window.theme.AccentColor,
                BackgroundTransparency = 0,
            })
            :Play()
        a3.tweenService
            :Create(self.indicatorStroke, a12, { Color = self.window.theme.AccentStroke, Transparency = 0 })
            :Play()
    else
        a3.tweenService
            :Create(self.indicator, a12, {
                Position = UDim2.new(1, -47, 0.5, 0),
                BackgroundColor3 = self.window.theme.ToggleKnobOff,
                BackgroundTransparency = self.window.theme.ToggleKnobOffTransparency,
            })
            :Play()
        a3.tweenService
            :Create(self.indicatorStroke, a12, { Color = Color3.fromRGB(255, 255, 255), Transparency = 0.7 })
            :Play()
    end
end

local a13 = TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
local a14 = TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0.35)

function a1:_setShown(a15, a16)
    local w = self.window
    if a15 then
        w:_revealCommon(self, a16)
                w:_reveal(self.indicator, {
            BackgroundColor3 = self.value and w.theme.AccentColor or w.theme.ToggleKnobOff,
            BackgroundTransparency = self.value and 0 or w.theme.ToggleKnobOffTransparency,
        }, a16, a13)
        w:_reveal(self.indicatorStroke, {
            Color = self.value and w.theme.AccentStroke or Color3.fromRGB(255, 255, 255),
            Transparency = self.value and 0 or 0.7,
        }, a16, a13)
        w:_reveal(
            self.indicatorGlow,
            { Transparency = self.value and w.theme.AccentGlow or 1 },
            a16,
            a14
        )
        w:_reveal(self.overlay, { BackgroundTransparency = 0 }, a16, a13)
        w:_reveal(self.containerStroke, { Transparency = 0.85 }, a16, a13)
        w:_reveal(
            self.functionContainer,
            { BackgroundTransparency = w.theme.ToggleTrackTransparency },
            a16,
            a13
        )
    else
        w:_hideCommon(self, a16)
        w:_reveal(self.indicator, { BackgroundTransparency = 1 }, a16, a13)
        w:_reveal(self.indicatorStroke, { Transparency = 1 }, a16, a13)
        w:_reveal(self.indicatorGlow, { Transparency = 1 }, a16, a14)
        w:_reveal(self.overlay, { BackgroundTransparency = 1 }, a16, a13)
        w:_reveal(self.containerStroke, { Transparency = 1 }, a16, a13)
        w:_reveal(self.functionContainer, { BackgroundTransparency = 1 }, a16, a13)
    end
end

function a1:_refreshTheme()
    local t = self.window.theme
    local a17 = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local ts = a3.tweenService
    ts:Create(self.functionContainer, a17, { BackgroundTransparency = t.ToggleTrackTransparency }):Play()
    ts:Create(self.indicator, a17, {
        BackgroundColor3 = self.value and t.AccentColor or t.ToggleKnobOff,
        BackgroundTransparency = self.value and 0 or t.ToggleKnobOffTransparency,
    }):Play()
    ts:Create(self.indicatorStroke, a17, {
        Color = self.value and t.AccentStroke or Color3.fromRGB(255, 255, 255),
    }):Play()
    if self.indicatorGlow then
        ts:Create(self.indicatorGlow, a17, { Transparency = self.value and t.AccentGlow or 1 }):Play()
    end
end

function a1:_minWidth()
    local w = 30 + 10 + 50     if self.icon then
        w += 21     end
        w += a4.textWidth(self.window.theme.Font, 16, a7.resolve(self.name))
    return w
end

a5(a1)
a6(a1)

function a1:Set(a18, a19)
    local a20 = self.value ~= a18
    self.value = a18

    if a20 then
        self:_animateIndicator()
    end

        if not a19 then
        self.window:_runGuarded(self, self.callback, self.value)
        self.window:_persist(self)     end
end

return a1
