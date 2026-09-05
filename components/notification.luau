local a1 = {}
a1.__index = a1
a1.__type = "Notification"

local a2 = script.Parent.Parent.utilities

local a3 = require(a2.Parent.core.state)
local a4 = require(script.Parent.Parent.functions)
local a5 = require(a2.constants)
local a6 = require(a2.HapticEngine)

local a7 = TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
local a8 = TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out) local a9 = TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out) local a10 = TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
local a11 = TweenInfo.new(0.9, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

local a12 = UDim2.new(0.5, 360, 0.5, 0)
local a13 = UDim2.new(0.5, 0, 0.5, 0)

local a14 = 6

local a15 = 8

local function a16(a17)
    return math.clamp(#a17 * 0.06 + 3, 3, 9)
end

function a1.new(window, a18)
    a18 = if typeof(a18) == "table" then a18 else {}

    local self = setmetatable({
        window = assert(window, "Missing argument #1 (Window expected)"),
        title = a18.title or a18.Title or "Notification",
        content = a18.content or a18.Content or "",
        icon = window:ResolveIcon(a18.icon or a18.Icon),
        _hovered = false,
        _dismissed = false,
    }, a1)

    self.duration = a18.duration or a18.Duration or a16(self.content)

    local a19 = self.icon ~= nil and self.icon ~= 0 and self.icon ~= ""

            self.main = self.window:Create("Frame", {
        Name = "Notification",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        BorderSizePixel = 0,
        ZIndex = a5.zIndex.notification,

        Parent = self.window.notifications,
    })

            self.window:Create("UIPadding", {
        PaddingTop = UDim.new(0, a15),

        Parent = self.main,
    })

            self.body = self.window:Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(1, 0, 1, 0),
        Position = a12,         AnchorPoint = Vector2.new(0.5, 0.5),
        Active = true,         BorderSizePixel = 0,
        ZIndex = a5.zIndex.notification,

                BackgroundTransparency = 1,
        Parent = self.main,
    })

    self.window:Create("UIGradient", {
        Rotation = 270,
        Offset = Vector2.new(0, -0.1),

        Parent = self.body,
    }, { Color = { "WindowColor", a4.toColorSequence } })

    self.window:Create("UICorner", {
        Parent = self.body,
    }, { CornerRadius = "CornerRoundness" })

    self.stroke = self.window:Create("UIStroke", {
        Transparency = 1,
        Parent = self.body,
    }, { Color = "SurfaceStroke" })

    self.shadow = self.window:CreateGlow(self.body, "ShadowColor", 20, 1)
        self.window:Create("UIPadding", {
        PaddingLeft = UDim.new(0, 20),
        PaddingRight = UDim.new(0, 20),

        Parent = self.body,
    })

    self.window:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 14),

        Parent = self.body,
    })

    if a19 then
        self.iconLabel = self.window:Create("ImageLabel", {
            Image = self.icon,
            Size = UDim2.fromOffset(24, 24),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            LayoutOrder = 1,
            ZIndex = a5.zIndex.notification,

                        ImageTransparency = 1,
            Parent = self.body,
        }, { ImageColor3 = "ContentColor" })
    end

        self.container = self.window:Create("Frame", {
        Size = UDim2.fromOffset(a19 and 222 or 260, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = 2,
        ZIndex = a5.zIndex.notification,

        Parent = self.body,
    })

    self.window:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),

        Parent = self.container,
    })

    self.titleLabel = self.window:Create("TextLabel", {
        Text = self.title,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        TextSize = 16,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1,
        ZIndex = a5.zIndex.notification,

                TextTransparency = 1,
        Parent = self.container,
    }, { TextColor3 = "ContentColor", FontFace = "TitleFont" })

    if self.content ~= "" then
        self.descriptionLabel = self.window:Create("TextLabel", {
            Text = self.content,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            TextSize = 15,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            LayoutOrder = 2,
            ZIndex = a5.zIndex.notification,

                        TextTransparency = 1,
            Parent = self.container,
        }, { TextColor3 = "ContentColor", FontFace = "Font" })
    end

        self.window._notificationCount = (self.window._notificationCount or 0) + 1
    self.main.LayoutOrder = self.window._notificationCount

            local a20 = self.window._liveNotifications
    if not a20 then
        a20 = {}
        self.window._liveNotifications = a20
    end
    table.insert(a20, self)
    while #a20 > a14 do
        local a21 = table.remove(a20, 1)
        if a21 and a21 ~= self then
            task.spawn(a21._dismiss, a21)
        end
    end

            self._connections = {
        self.window:Connect(self.body.MouseEnter, function()
            self._hovered = true
        end),
        self.window:Connect(self.body.MouseLeave, function()
            self._hovered = false
        end),
        self.window:Connect(self.body.InputBegan, function(a22)
            if
                a22.UserInputType == Enum.UserInputType.MouseButton1
                or a22.UserInputType == Enum.UserInputType.Touch
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
    local a23 = self.iconLabel and 222 or 260

    local a24 = a4.textHeight(self.window.theme.TitleFont, 16, self.title, a23)
    if self.descriptionLabel then
        a24 = a24 + 4 + a4.textHeight(self.window.theme.Font, 15, self.content, a23)
    end

    return math.max(a24, self.iconLabel and 24 or 0) + 28
end

function a1:_show()
                local a25 = self:_measure() + a15
    if self._dismissed or not self.main.Parent then
        return     end

    a6.notify()

        a3.tweenService:Create(self.main, a7, { Size = UDim2.new(1, 0, 0, a25) }):Play()
    a3.tweenService:Create(self.body, a10, { Position = a13 }):Play()
    a3.tweenService:Create(self.body, a8, { BackgroundTransparency = 0 }):Play()
    a3.tweenService:Create(self.titleLabel, a9, { TextTransparency = 0 }):Play()
    a3.tweenService:Create(self.stroke, a8, { Transparency = 0.95 }):Play()
    a3.tweenService:Create(self.shadow, a9, { Transparency = 0.6 }):Play()

    task.wait(0.05)
    if self._dismissed or not self.main.Parent then
        return     end
    if self.iconLabel then
        a3.tweenService:Create(self.iconLabel, a9, { ImageTransparency = 0 }):Play()
    end

    task.wait(0.05)
    if self._dismissed or not self.main.Parent then
        return
    end
    if self.descriptionLabel then
        a3.tweenService:Create(self.descriptionLabel, a9, { TextTransparency = 0.35 }):Play()
    end

        local a26 = 0
    while a26 < self.duration and not self._dismissed and self.main.Parent do
        local dt = task.wait()
        if not self._hovered then
            a26 += dt
        end
    end

    self:_dismiss()
end

function a1:_dismiss()
    if self._dismissed then
        return
    end
    self._dismissed = true

    local a27 = self.window._liveNotifications
    local a28 = a27 and table.find(a27, self)
    if a27 and a28 then
        table.remove(a27, a28)
    end

    if not self.main.Parent then
        return
    end

        a3.tweenService:Create(self.body, a8, { BackgroundTransparency = 1 }):Play()
    a3.tweenService:Create(self.stroke, a8, { Transparency = 1 }):Play()
    a3.tweenService:Create(self.shadow, a9, { Transparency = 1 }):Play()
    a3.tweenService:Create(self.titleLabel, a9, { TextTransparency = 1 }):Play()
    if self.descriptionLabel then
        a3.tweenService:Create(self.descriptionLabel, a9, { TextTransparency = 1 }):Play()
    end
    if self.iconLabel then
        a3.tweenService:Create(self.iconLabel, a9, { ImageTransparency = 1 }):Play()
    end

        a3.tweenService:Create(self.body, a11, { Size = UDim2.new(1, -90, 1, 0) }):Play()
    local a29 = a3.tweenService:Create(self.main, a11, { Size = UDim2.new(1, 0, 0, 0) })
    local a30
    a30 = a29.Completed:Connect(function(a31)
        if a30 then
            a30:Disconnect()
            a30 = nil
        end
        if a31 ~= Enum.PlaybackState.Completed or not self._dismissed or not self.main.Parent then
            return
        end

        for _, a32 in self._connections do
            self.window:Disconnect(a32)
        end
        self.window:DestroySubtree(self.main)
    end)
    a29:Play()
end

return a1
