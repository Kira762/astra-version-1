local a1 = {}
a1.__index = a1
a1.__type = "Slider"

local a2 = script.Parent.Parent.utilities

local a3 = require(a2.Parent.core.state)
local a4 = require(script.Parent.Parent.functions)
local a5 = require(a2.odometer)
local a6 = require(a2.moveable)
local a7 = require(a2.lockable)
local a8 = require(a2.locale)
local a9 = require(a2.HapticEngine)

local function a10(a11)
    local a12 = 0
    while a12 < 6 do
        local a13 = a11 * 10 ^ a12
        if math.abs(a13 - math.round(a13)) < 1e-9 then
            break
        end
        a12 += 1
    end
    return a12
end

local function a14(a15, a16, a17)
    local a18 = a15[1] + math.round((a17 - a15[1]) / a16) * a16
    return math.clamp(a18, a15[1], a15[2])
end

local a19 = TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
local a20 = TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
local a21 = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local a22 = 300

local a23 = Vector2.new(35, 20)
local a24 = Vector2.new(41, 22)

local function a25(a26: number): UDim2
    return UDim2.new(a26, 0, 1, 0)
end

local function a27(): UDim2
    return UDim2.new(1, 0, 0.5, 0)
end

local function a28(x: number, a29: number, a30: number): number
    return math.clamp((x - a29) / a30, 0, 1)
end

function a1.new(tab, a31)
    a31 = if typeof(a31) == "table" then a31 else {}

    local self = setmetatable({
        tab = assert(tab, "Missing argument #1 (Tab expected)"),
        window = tab.window,
        name = a31.name or a31.Name or "Slider",
        icon = tab.window:ResolveIcon(a31.icon or a31.Icon),
        description = a31.description or a31.Description,
        forgetState = a31.forgetState or a31.ForgetState or tab.forgetState,

        range = a31.range or a31.Range or { 0, 100 },
        increment = a31.increment or a31.Increment or 1,
        suffix = a31.suffix or a31.Suffix or "",

        callback = a31.callback or a31.Callback or function() end,

        dragging = false,
        minimal = a31.minimal or a31.Minimal or false,
                _handleWidth = a23.X,
    }, a1)

        assert(
        typeof(self.range) == "table" and typeof(self.range[1]) == "number" and typeof(self.range[2]) == "number",
        "A slider range needs two numbers, like { 0, 100 }."
    )

        if self.range[1] > self.range[2] then
        self.range = { self.range[2], self.range[1] }
    end
    if self.increment <= 0 then
        self.increment = 1
    end

    self.value = if (a31.value or a31.Value) ~= nil
        then (a31.value or a31.Value)
        elseif (a31.currentValue or a31.CurrentValue) ~= nil then (
            a31.currentValue or a31.CurrentValue
        )
        else self.range[1]

            self.value = a14(self.range, self.increment, self.value)

    self._decimals = a10(self.increment)

    self.flag = a31.flag
        or a31.Flag
        or (not self.forgetState and a4.deriveFlagFromName(self.name) or nil)
    self.window:_registerControl(self)

    self.main = self.window:Create("Frame", {
        Size = UDim2.new(1, -20, 0, 65),
        BorderSizePixel = 0,
        Name = self.name,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),

        BackgroundTransparency = 1,

        Parent = self.tab.tabPage,
    }, { BackgroundTransparency = "ElementTransparency" })

    self.stroke = self.window:StyleElementBody(self.main)
    self._lastValue = self.value

        if not self.minimal then
        self:_buildLabel()
    end

        self.track = self.window:Create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -15, 0.5, 0),
        Size = UDim2.fromOffset(222, 14),
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        Parent = self.main,
    }, { BackgroundColor3 = "SliderBackground" })

    self.window:Create("UICorner", {
        CornerRadius = UDim.new(0, 13),

        Parent = self.track,
    })

    self.progress = self.window:Create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.fromScale(0, 0.5),
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 2,
        BackgroundTransparency = 1,
        Parent = self.track,
    })

    self.window:Create("UICorner", {
        CornerRadius = UDim.new(0, 13),

        Parent = self.progress,
    })

    self.window:Create("UIGradient", {
        Offset = Vector2.new(0, 0.5),
        Rotation = 2,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.85),
            NumberSequenceKeypoint.new(1, 0),
        }),

        Parent = self.progress,
    }, { Color = { "SliderProgress", a4.toColorSequence } })

        self.progressGlow = self.window:CreateGlow(self.progress, "AccentColor", 20, 1)

        self.handle = self.window:Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = a27(),         Size = UDim2.fromOffset(a23.X, a23.Y),
        BorderSizePixel = 0,
        ZIndex = 50,
        BackgroundTransparency = 1,
        Parent = self.progress,
    }, { BackgroundColor3 = "SliderHandle" })

    self.window:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),

        Parent = self.handle,
    })

        self.handleGlow = self.window:CreateGlow(self.handle, Color3.fromRGB(255, 255, 255), 10, 1)

    self.handleStroke = self.window:Create("UIStroke", {
        Transparency = 1,
        Parent = self.handle,
    }, { Color = "SliderStroke" })

    self.interact = self.window:Create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = "",
        TextTransparency = 1,
        ZIndex = 10,

        Parent = self.track,
    })

        self.window:ConnectFor(self, self.main.MouseEnter, function()
        if not self.window:_interactive() then
            return         end
        a3.tweenService
            :Create(self.track, a19, { BackgroundColor3 = self.window.theme.SliderBackgroundHover })
            :Play()
    end)

    self.window:ConnectFor(self, self.main.MouseLeave, function()
        a3.tweenService
            :Create(self.track, a19, { BackgroundColor3 = self.window.theme.SliderBackground })
            :Play()
    end)

    self.window:ConnectFor(self, self.interact.InputBegan, function(a32)
        if
            a32.UserInputType == Enum.UserInputType.MouseButton1
            or a32.UserInputType == Enum.UserInputType.Touch
        then
            a9.click()             self.dragging = true
            self:_setHeld(true)
            self:_updateFromMouse()

                        if self._dragConnection then
                self._dragConnection:Disconnect()
                self._dragConnection = nil
            end

                                    self._dragConnection = a3.runService.RenderStepped:Connect(function()
                if self.window.unloaded or not self.dragging then
                    if self._dragConnection then
                        self._dragConnection:Disconnect()
                        self._dragConnection = nil
                    end
                    return
                end
                self:_updateFromMouse()
            end)
        end
    end)

    self.window:ConnectFor(self, a3.userInputService.InputEnded, function(a33)
        if
            a33.UserInputType == Enum.UserInputType.MouseButton1
            or a33.UserInputType == Enum.UserInputType.Touch
        then
            self:_endDrag()
        end
    end)

            self.window:ConnectFor(self, a3.userInputService.WindowFocusReleased, function()
        self:_endDrag()
    end)

    if self.description and not self.minimal then
        self.descriptor = require(script.Parent.descriptor).new(self.tab, { description = self.description })
    end

            self.window:ConnectFor(self, self.main:GetPropertyChangedSignal("AbsoluteSize"), function()
                                                if self.window.animating or (self.window.hidden and self.window.hasShownOnce) then
            return
        end
        self:_applyLayout()
    end)
    self:_applyLayout()

    if self.minimal then
                        self.main.Size = UDim2.new(1, -20, 0, 41)
        self.track.AnchorPoint = Vector2.new(0.5, 0.5)
        self.track.Position = UDim2.new(0.5, 0, 0.5, 0)
        self.track.Size = UDim2.new(1, -30, 0, 14)
    end

    self:_renderProgress()

    return self
end

function a1:_buildLabel()
        self.container = self.window:Create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 20, 0.5, 0),
        Size = UDim2.fromOffset(170, 33),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 5,

        Parent = self.main,
    })

    self.containerLayout = self.window:Create("UIListLayout", {
        Padding = UDim.new(0, 2),
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,

        Parent = self.container,
    })

    self.titleContainer = self.window:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 5,

        Parent = self.container,
    })

    self.window:Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,

        Parent = self.titleContainer,
    })

            self.titleFlex = self.window:Create("UIFlexItem", {
        FlexMode = Enum.UIFlexMode.None,
        Parent = self.titleContainer,
    })

    if self.icon then
        self.iconLabel = self.window:Create("ImageLabel", {
            Image = self.icon,
            Size = UDim2.fromOffset(16, 16),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            ZIndex = 5,

                        ImageTransparency = 1,
            Parent = self.titleContainer,
        }, { ImageColor3 = "ContentColor" })
    end

    self.title = self.window:Create("TextLabel", {
        Text = a8.t(self.name),
        Size = UDim2.new(1, 0, 0, 16),
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,         RichText = true,
        LayoutOrder = 1,
        ZIndex = 5,

                TextTransparency = 1,
        Parent = self.titleContainer,
    }, { TextColor3 = "ContentColor", FontFace = "Font" })

        self.window:Create("UIFlexItem", {
        FlexMode = Enum.UIFlexMode.Shrink,
        Parent = self.title,
    })

            self.valueHost = self.window:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 6,
        LayoutOrder = 1,
        Parent = self.container,
    })

    self.valueOdo = a5.new(self.window, self.valueHost, {
        textSize = 15,
        alignment = Enum.HorizontalAlignment.Left,
        transparency = 1,         duration = 0.28,     })
    self.valueOdo:snap(self:_format(self.value))
end

function a1:_setMainHeight(a34)
    if self._widthManaged then
        self.main.Size = UDim2.new(self.main.Size.X.Scale, self.main.Size.X.Offset, 0, a34)
    else
        self.main.Size = UDim2.new(1, -20, 0, a34)
    end
end

function a1:_applyLayout()
    if self.minimal then
        return     end
    local a35 = self.main.AbsoluteSize.X
    local a36 = if a35 > 0 and a35 < a22 then "narrow" else "wide"
    if self._layoutMode == a36 then
        return
    end
    self._layoutMode = a36

    if a36 == "narrow" then
        self:_setMainHeight(70)

        self.container.AnchorPoint = Vector2.new(0, 0)
        self.container.Position = UDim2.new(0, 20, 0, 14)
        self.container.Size = UDim2.new(1, -40, 0, 16)
        self.containerLayout.FillDirection = Enum.FillDirection.Horizontal
        self.titleFlex.FlexMode = Enum.UIFlexMode.Fill         self.valueHost.AutomaticSize = Enum.AutomaticSize.X
        self.valueHost.Size = UDim2.new(0, 0, 0, 16)

        self.track.AnchorPoint = Vector2.new(0.5, 1)
        self.track.Position = UDim2.new(0.5, 0, 1, -14)
        self.track.Size = UDim2.new(1, -30, 0, 14)
    else
        self:_setMainHeight(65)

        self.container.AnchorPoint = Vector2.new(0, 0.5)
        self.container.Position = UDim2.new(0, 20, 0.5, 0)
        self.container.Size = UDim2.new(0, 170, 0, 33)
        self.containerLayout.FillDirection = Enum.FillDirection.Vertical
        self.titleFlex.FlexMode = Enum.UIFlexMode.None
        self.valueHost.AutomaticSize = Enum.AutomaticSize.None
        self.valueHost.Size = UDim2.new(1, 0, 0, 16)

        self.track.AnchorPoint = Vector2.new(1, 0.5)
        self.track.Position = UDim2.new(1, -15, 0.5, 0)
        self.track.Size = UDim2.new(0, 222, 0, 14)
    end
end

function a1:_format(a37)
    local a38 = string.format("%." .. self._decimals .. "f", a37)
    if self.suffix ~= "" then
        return a38 .. " " .. self.suffix
    end
    return a38
end

function a1:_pillTravel()
    return math.max(self.track.AbsoluteSize.X, 0)
end

function a1:_renderProgress(a39)
    local a40 = self.range[2] - self.range[1]
    local a41 = if a40 ~= 0 then math.clamp((self.value - self.range[1]) / a40, 0, 1) else 0

    local a42 = a25(a41)
    if a39 then
        a3.tweenService:Create(self.progress, a39, { Size = a42 }):Play()
    else
        self.progress.Size = a42
    end
end

function a1:_updateFromMouse()
    local a43 = self:_pillTravel()
    if a43 <= 0 then
        return
    end

    local a44 =
        a28(a3.userInputService:GetMouseLocation().X, self.track.AbsolutePosition.X, a43)
    local a45 = a14(self.range, self.increment, self.range[1] + a44 * (self.range[2] - self.range[1]))

    if a45 ~= self.value then
        self.value = a45
        if self.valueOdo then
            self.valueOdo:snap(self:_format(a45))         end
        self._lastValue = a45
        self:_renderProgress(a21)
        self:_fireCallback(a45)
    end
end

function a1:_endDrag()
    if not self.dragging then
        return
    end
    self.dragging = false
    self:_setHeld(false)

    if self._dragConnection then
        self._dragConnection:Disconnect()
        self._dragConnection = nil
    end

    self.window:_persist(self)
end

function a1:_setHeld(a46)
                if not a46 then
        self:_fireCallback(self.value)
    end

    local a47 = if a46 then a24 else a23
    self._handleWidth = a47.X

    a3.tweenService
        :Create(self.handle, a20, {
            Size = UDim2.fromOffset(a47.X, a47.Y),
            BackgroundTransparency = if a46 then 0.7 else 0,
        })
        :Play()
    a3.tweenService:Create(self.handleStroke, a20, { Transparency = if a46 then 0.6 else 1 }):Play()
    self:_renderProgress(a20)
end

function a1:_fireCallback(a48)
    self.window:_runGuarded(self, self.callback, a48, self.dragging == true)
end

function a1:Set(a49, a50)
    a49 = a14(self.range, self.increment, a49)
    self.value = a49
    if self.valueOdo then
        self.valueOdo:to(self:_format(a49), a49 >= (self._lastValue or a49))
    end
    self._lastValue = a49
    self:_renderProgress(a19)

    if not a50 then
        self:_fireCallback(a49)
        self.window:_persist(self)
    end
end

local a51 = TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0.35)

function a1:_setShown(a52, a53)
    local w = self.window
    if a52 then
        w:_revealCommon(self, a53)
        w:_reveal(self.track, { BackgroundTransparency = 0 }, a53)
        w:_reveal(self.progress, { BackgroundTransparency = 0 }, a53)
        w:_reveal(self.handle, { BackgroundTransparency = 0 }, a53)
        if self.valueOdo then
            self.valueOdo:reveal(0.3, a53)
        end
                w:_reveal(self.progressGlow, { Transparency = math.max(0.55, w.theme.AccentGlow) }, a53, a51)
        w:_reveal(self.handleGlow, { Transparency = 0.8 }, a53, a51)
    else
        w:_hideCommon(self, a53)
        w:_reveal(self.track, { BackgroundTransparency = 1 }, a53)
        w:_reveal(self.progress, { BackgroundTransparency = 1 }, a53)
        w:_reveal(self.handle, { BackgroundTransparency = 1 }, a53)
        if self.valueOdo then
            self.valueOdo:reveal(1, a53)
        end
        w:_reveal(self.progressGlow, { Transparency = 1 }, a53, a51)
        w:_reveal(self.handleGlow, { Transparency = 1 }, a53, a51)
    end
end

function a1:_refreshTheme()
    a3.tweenService
        :Create(
            self.progressGlow,
            TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            { Transparency = math.max(0.55, self.window.theme.AccentGlow) }
        )
        :Play()
end

function a1:_minWidth()
    if self.minimal then
        return 100     end
    local w = 40     if self.icon then
        w += 22     end
        w += a4.textWidth(self.window.theme.Font, 16, a8.resolve(self.name))
    w += 12     w += a4.textWidth(self.window.theme.Font, 15, self:_format(self.value))
    return math.max(w, 160)
end

a6(a1)
a7(a1)

return a1
