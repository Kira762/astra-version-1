local a1 = {}
a1.__index = a1
a1.__type = "Toast"

local a2 = script.Parent.Parent.utilities
local a3 = require(a2.Parent.core.state)
local a4 = require(script.Parent.Parent.functions)
local a5 = require(a2.constants)
local a6 = require(script.Parent.Parent.images.image)
local a7 = require(a2.HapticEngine)

local a8 = TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out) local a9 = TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out) local a10 = TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out) local a11 = TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out) local a12 = TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
local a13 = 24 local a14 = 32 local a15 = 18 local a16 = 18 local a17 = 10
local a18 = 28
local a19 = 12 local a20 = 8 local a21, a22 = 140, 320

local a23 = 6

local a24 = UDim2.new(0.5, 0, 0.5, -180)
local a25 = UDim2.new(0.5, 0, 0.5, 180)
local a26 = UDim2.new(0.5, 0, 0.5, 0)

local function a27(a28)
    return math.clamp(#a28 * 0.06 + 3, 3, 9)
end

local function a29(a30)
    if type(a30) == "number" then
        return "rbxassetid://" .. tostring(a30)
    end
    return a30
end

function a1.new(window, a31, a32)
    a31 = if typeof(a31) == "table" then a31 else {}

    local self = setmetatable({
        window = assert(window, "Missing argument #1 (Window expected)"),
        title = a31.title or a31.Title or "",
        subtitle = a31.subtitle or a31.Subtitle,
        icon = window:ResolveIcon(a31.icon or a31.Icon),
                        avatar = a31.avatar or a31.Avatar,
                        minWidth = a31.minWidth or a31.MinWidth,
                        subtitleAbove = a31.subtitleAbove or a31.SubtitleAbove or false,
        position = a31.position or "Top",
        _hovered = false,
        _dismissed = false,
    }, a1)

    self.duration = a31.duration or a31.Duration or a27(self.title .. (self.subtitle or ""))

            local a33 = self.avatar ~= nil and self.avatar ~= 0
    local a34 = a33 or (self.icon ~= nil and self.icon ~= 0 and self.icon ~= "")
            self._iconImage = if a33
        then a6.avatar(self.avatar, function(a35)
                        if self.iconLabel and not self._dismissed and self.main.Parent then
                a6.assign(self.iconLabel, "Image", a35)
            end
        end)
        elseif a34 then a29(self.icon)
        else nil
    self._iconSize = if a33 then a14 else a13
    self._leftPad = if a33 then a17 else a15
    self._rightPad = if a33 then a18 else a16
    self._minWidth = math.clamp(self.minWidth or 0, a21, a22)
    local a36 = self.subtitle ~= nil and self.subtitle ~= ""

            self.main = self.window:Create("Frame", {
        Name = "Toast",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 0),
        BorderSizePixel = 0,
        ZIndex = a5.zIndex.toast,

        Parent = a32 or self.window.toasts,
    })

        self.window:Create("UIPadding", {
        PaddingTop = UDim.new(0, a20),

        Parent = self.main,
    })

        self.body = self.window:Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(1, 0, 1, 0),
        Position = if self.position == "Bottom" then a25 else a24,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Active = true,         BorderSizePixel = 0,
        ZIndex = a5.zIndex.toast,

        BackgroundTransparency = 1,
        Parent = self.main,
    })

    self.window:Create("UIGradient", {
        Rotation = 270,
        Offset = Vector2.new(0, -0.1),

        Parent = self.body,
    }, { Color = { "WindowColor", a4.toColorSequence } })

    self.window:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),

        Parent = self.body,
    })

    self.stroke = self.window:Create("UIStroke", {
        Transparency = 1,
        Parent = self.body,
    }, { Color = "SurfaceStroke" })

    self.shadow = self.window:CreateGlow(self.body, "ShadowColor", 20, 1)
    self.window:Create("UIPadding", {
        PaddingLeft = UDim.new(0, self._leftPad),
        PaddingRight = UDim.new(0, self._rightPad),

        Parent = self.body,
    })

    self.window:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, a19),

        Parent = self.body,
    })

    if a34 then
                        self.iconLabel = self.window:Create("ImageLabel", {
            Image = self._iconImage,
            Size = UDim2.fromOffset(self._iconSize, self._iconSize),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            LayoutOrder = 1,
            ZIndex = a5.zIndex.toastContent,

            BackgroundTransparency = 1,             ImageTransparency = 1,
            Parent = self.body,
        }, if a33 then nil else { ImageColor3 = "ContentColor" })

        self.window:Create("UICorner", {
            CornerRadius = UDim.new(1, 0),

            Parent = self.iconLabel,
        })
    end

            self.container = self.window:Create("Frame", {
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.fromOffset(0, a36 and 32 or 16),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = 2,
        ZIndex = a5.zIndex.toastContent,

        Parent = self.body,
    })

    self.window:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 1),

        Parent = self.container,
    })

            self.titleLabel = self.window:Create("TextLabel", {
        Text = self.title,
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.fromOffset(0, 16),
        BackgroundTransparency = 1,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = if self.subtitleAbove then 2 else 1,
        ZIndex = a5.zIndex.toastContent,

        TextTransparency = 1,
        Parent = self.container,
    }, { TextColor3 = "ContentColor", FontFace = "TitleFont" })

    if a36 then
        self.subtitleLabel = self.window:Create("TextLabel", {
            Text = self.subtitle,
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.fromOffset(0, 14),
            BackgroundTransparency = 1,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = if self.subtitleAbove then 1 else 2,
            ZIndex = a5.zIndex.toastContent,

            TextTransparency = 1,
            Parent = self.container,
        }, { TextColor3 = "ContentColor", FontFace = "Font" })
    end

        self.window._toastCount = (self.window._toastCount or 0) + 1
    self.main.LayoutOrder = -self.window._toastCount

            local a37 = self.window._liveToasts
    if not a37 then
        a37 = {}
        self.window._liveToasts = a37
    end
    local a38 = a37[self.main.Parent]
    if not a38 then
        a38 = {}
        a37[self.main.Parent] = a38
    end
    self._live = a38
    table.insert(a38, self)
    while #a38 > a23 do
        local a39 = table.remove(a38, 1)
        if a39 and a39 ~= self then
            task.spawn(a39._dismiss, a39)
        end
    end

    self._connections = {
        self.window:Connect(self.body.MouseEnter, function()
            self._hovered = true
        end),
        self.window:Connect(self.body.MouseLeave, function()
            self._hovered = false
        end),
        self.window:Connect(self.body.InputBegan, function(a40)
            if
                a40.UserInputType == Enum.UserInputType.MouseButton1
                or a40.UserInputType == Enum.UserInputType.Touch
            then
                self:_dismiss()
            end
        end),
    }

    task.spawn(function()
        self:_show()
    end)

    return self
end

function a1:_measure()
    local a41 = a4.textWidth(self.window.theme.TitleFont, 16, self.title)
    local a42 = if self.subtitleLabel
        then a4.textWidth(self.window.theme.Font, 14, self.subtitle)
        else 0
    local a43 = math.max(a41, a42)

    local a44 = if self.iconLabel then self._leftPad + self._iconSize + a19 else self._leftPad
    local a45 = math.clamp(a44 + a43 + self._rightPad, self._minWidth, a22)

            if a44 + a43 + self._rightPad > a22 then
        local a46 = a22 - a44 - self._rightPad
        for _, a47 in { self.titleLabel, self.subtitleLabel } do
            if a47 then
                a47.AutomaticSize = Enum.AutomaticSize.None
                a47.TextTruncate = Enum.TextTruncate.AtEnd
                a47.Size = UDim2.fromOffset(a46, a47.Size.Y.Offset)
            end
        end
    end

    local a48 = if self.subtitleLabel then 16 + 1 + 14 else 16
    local a49 = math.max(a48, if self.iconLabel then self._iconSize else 0) + 18

    return a45, a49
end

function a1:_show()
    if self._dismissed or not self.main.Parent then
        return
    end

    a7.notify()

    local a50, a51 = self:_measure()
    if self._dismissed or not self.main.Parent then
        return     end
    self.main.Size = UDim2.new(0, a50, 0, 0)

        a3.tweenService:Create(self.main, a9, { Size = UDim2.new(0, a50, 0, a51 + a20) }):Play()
    a3.tweenService:Create(self.body, a8, { Position = a26 }):Play()
    a3.tweenService:Create(self.body, a10, { BackgroundTransparency = 0 }):Play()
    a3.tweenService:Create(self.stroke, a10, { Transparency = 0.9 }):Play()
    a3.tweenService:Create(self.shadow, a11, { Transparency = 0.6 }):Play()
    a3.tweenService:Create(self.titleLabel, a11, { TextTransparency = 0 }):Play()

    task.wait(0.05)
    if self._dismissed or not self.main.Parent then
        return     end
    if self.iconLabel then
        a3.tweenService:Create(self.iconLabel, a11, { BackgroundTransparency = 0.95 }):Play()
        a3.tweenService:Create(self.iconLabel, a11, { ImageTransparency = 0 }):Play()
    end

    task.wait(0.05)
    if self._dismissed or not self.main.Parent then
        return
    end
    if self.subtitleLabel then
        a3.tweenService:Create(self.subtitleLabel, a11, { TextTransparency = 0.5 }):Play()
    end

        local a52 = 0
    while a52 < self.duration and not self._dismissed and self.main.Parent do
        local dt = task.wait()
        if not self._hovered then
            a52 += dt
        end
    end

    self:_dismiss()
end

function a1:_dismiss()
    if self._dismissed then
        return
    end
    self._dismissed = true

    local a53 = self._live
    local a54 = a53 and table.find(a53, self)
    if a53 and a54 then
        table.remove(a53, a54)
    end

    if not self.main.Parent then
        return
    end

    a3.tweenService:Create(self.body, a10, { BackgroundTransparency = 1 }):Play()
    a3.tweenService:Create(self.stroke, a10, { Transparency = 1 }):Play()
    a3.tweenService:Create(self.shadow, a11, { Transparency = 1 }):Play()
    a3.tweenService:Create(self.titleLabel, a11, { TextTransparency = 1 }):Play()
    if self.subtitleLabel then
        a3.tweenService:Create(self.subtitleLabel, a11, { TextTransparency = 1 }):Play()
    end
    if self.iconLabel then
        a3.tweenService
            :Create(self.iconLabel, a11, { ImageTransparency = 1, BackgroundTransparency = 1 })
            :Play()
    end

    a3.tweenService:Create(self.body, a12, { Size = UDim2.new(1, -60, 1, 0) }):Play()
    local a55 =
        a3.tweenService:Create(self.main, a12, { Size = UDim2.new(0, self.main.Size.X.Offset, 0, 0) })
    local a56
    a56 = a55.Completed:Connect(function(a57)
        if a56 then
            a56:Disconnect()
            a56 = nil
        end
        if a57 ~= Enum.PlaybackState.Completed or not self._dismissed or not self.main.Parent then
            return
        end

        for _, a58 in self._connections do
            self.window:Disconnect(a58)
        end
        self.window:DestroySubtree(self.main)
    end)
    a55:Play()
end

return a1
