local a1 = {}
a1.__index = a1
a1.__type = "Popup"

local a2 = script.Parent.Parent.utilities
local a3 = require(a2.Parent.core.state)
local a4 = require(script.Parent.Parent.functions)
local a5 = require(a2.constants)
local a6 = require(a2.locale)
local a7 = require(a2.log)
local a8 = require(a2.HapticEngine)

local a9 = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out) local a10 = TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out) local a11 = TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out) local a12 = TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

local a13 = 400
local a14 = 22
local a15 = 24
local a16 = 22
local a17 = 16 local a18 = a13 - a14 * 2

local a19 = 18
local a20 = 14
local a21 = 15
local a22 = 16
local a23 = 12 local a24 = 300 local a25 = 4
local a26 = a18 - a25 * 2

local a27 = 16
local a28 = 13
local a29 = 20
local a30 = 10
local a31 = 15
local a32 = 14
local a33 = 8
local a34 = 10
local a35 = 40
local a36 = 8
local a37 = UDim.new(1, 0) local a38 = 16

local a39 = 0.5
local a40 = {}

local a41 = nil

local function a42()
    for a43 = #a40, 1, -1 do
        local a44 = a40[a43]
        if a44._closed or not a44.screenGui.Parent then
            table.remove(a40, a43)
        end
    end
end

local function a45(a46)
    a42()
    return a40[#a40] == a46
end

function a1.new(window, a47)
    a47 = if typeof(a47) == "table" then a47 else {}

    local self = setmetatable({
        window = assert(window, "Missing argument #1 (Window expected)"),
        title = a47.title or a47.Title or "Popup",
        subtitle = a47.subtitle or a47.Subtitle,
        content = a47.content or a47.Content,
        icon = window:ResolveIcon(a47.icon or a47.Icon),
        boxes = a47.boxes or a47.Boxes,
        options = a47.options or a47.Options,
                dismissable = if a47.dismissable ~= nil
            then a47.dismissable
            elseif a47.Dismissable ~= nil then a47.Dismissable
            else true,
        _reveal = {},         _connections = {},
        _closed = false,
    }, a1)

        if not self.options or #self.options == 0 then
        self.options = { { text = "Okay" } }
    end

    self:_build()
            a42()
    table.insert(a40, self)
    task.spawn(function()
        self:_show()
    end)

    return self
end

function a1:_fade(a48, a49, to)
    table.insert(self._reveal, { instance = a48, prop = a49, to = to })
    return a48
end

function a1:_build()
    local window = self.window
    local a50 = self.icon ~= nil and self.icon ~= 0 and self.icon ~= ""

        self.screenGui = window:Create("ScreenGui", {
        Name = a3.httpService:GenerateGUID(false),
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        Enabled = true,
        DisplayOrder = a5.displayOrder.popup,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,

        Parent = a3.guiContainer,
    })

                self.backdrop = window:Create("Frame", {
        Name = "Backdrop",
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Active = true,

        BackgroundTransparency = 1,
        Parent = self.screenGui,
    })
    self:_fade(self.backdrop, "BackgroundTransparency", a39)

        self.card = window:Create("Frame", {
        Name = "Card",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 14),         Size = UDim2.fromOffset(a13, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Active = true,         BorderSizePixel = 0,

        BackgroundTransparency = 1,
        Parent = self.screenGui,
    })
    self:_fade(self.card, "BackgroundTransparency", 0)

    window:Create("UIGradient", {
        Rotation = 270,
        Offset = Vector2.new(0, -0.1),

        Parent = self.card,
    }, { Color = { "WindowColor", a4.toColorSequence } })

    window:Create("UICorner", {
        Parent = self.card,
    }, { CornerRadius = "CornerRoundness" })

    self.cardStroke = window:Create("UIStroke", {
        Transparency = 1,
        Parent = self.card,
    }, { Color = "SurfaceStroke" })
    self:_fade(self.cardStroke, "Transparency", 0.95)

    self.cardShadow = window:CreateGlow(self.card, "ShadowColor", 26, 1)     self:_fade(self.cardShadow, "Transparency", 0.55)

    window:Create("UIPadding", {
        PaddingLeft = UDim.new(0, a14),
        PaddingRight = UDim.new(0, a14),
        PaddingTop = UDim.new(0, a15),
        PaddingBottom = UDim.new(0, a16),

        Parent = self.card,
    })

    window:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, a17),

        Parent = self.card,
    })

                local a51 = self:_measureHeader(a50)
    self:_buildHeader(a50, a51)
    local a52 = self:_buildContent()
    self:_buildFooter()

    local a53 = 2 + (a52 > 0 and 1 or 0)     local a54 = a15
        + a51
        + a52
        + a35
        + a16
        + a17 * (a53 - 1)
    self.card.Size = UDim2.fromOffset(a13, a54)
    self.card.AutomaticSize = Enum.AutomaticSize.None

        if self.dismissable then
        table.insert(
            self._connections,
            window:Connect(self.backdrop.InputBegan, function(a55)
                if
                    a55.UserInputType == Enum.UserInputType.MouseButton1
                    or a55.UserInputType == Enum.UserInputType.Touch
                then
                    self:Close()
                end
            end)
        )
        table.insert(
            self._connections,
            window:Connect(a3.userInputService.InputBegan, function(a56, a57)
                if not a57 and a56.KeyCode == Enum.KeyCode.Escape and a45(self) then
                    if a56 == a41 then
                        return
                    end
                    a41 = a56
                    self:Close()
                end
            end)
        )
    end
end

function a1:_buildHeader(a58, a59)
    local window = self.window

    local a60 = window:Create("Frame", {
        Name = "Header",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, a59),
        LayoutOrder = 1,

        Parent = self.card,
    })

    window:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, a23),

        Parent = a60,
    })

    if a58 then
        self:_fade(
            window:Create("ImageLabel", {
                Image = self.icon,
                Size = UDim2.fromOffset(a22, a22),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                LayoutOrder = 1,

                ImageTransparency = 1,
                Parent = a60,
            }, { ImageColor3 = "TitlingColor" }),
            "ImageTransparency",
            0
        )
    end

    local a61 = window:Create("Frame", {
        Name = "Text",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, a58 and -(a22 + a23) or 0, 0, self._columnH),
        LayoutOrder = 2,

        Parent = a60,
    })

    window:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 3),

        Parent = a61,
    })

    self:_fade(
        window:Create("TextLabel", {
            Text = a6.t(self.title),
            Size = UDim2.new(1, 0, 0, self._titleH),
            BackgroundTransparency = 1,
            TextSize = a19,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            LayoutOrder = 1,

            TextTransparency = 1,
            Parent = a61,
        }, { TextColor3 = "TitlingColor", FontFace = "Font" }),
        "TextTransparency",
        0
    )

    if self.subtitle and self.subtitle ~= "" then
        self:_fade(
            window:Create("TextLabel", {
                Text = a6.t(self.subtitle),
                Size = UDim2.new(1, 0, 0, self._subH),
                BackgroundTransparency = 1,
                TextSize = a20,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                LayoutOrder = 2,

                TextTransparency = 1,
                Parent = a61,
            }, { TextColor3 = "TitlingColor", FontFace = "Font" }),
            "TextTransparency",
            0.55
        )
    end
end

function a1:_buildContent()
    if (not self.content or self.content == "") and (not self.boxes or #self.boxes == 0) then
        return 0     end

    local window = self.window
    local a62 = if self.boxes and #self.boxes > 0 then self:_measureBoxes() else self:_measureText()
    local a63 = math.min(a62, a24) + a25 * 2

    local a64 = window:Create("ScrollingFrame", {
        Name = "Content",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, a63),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
        ScrollingDirection = Enum.ScrollingDirection.Y,
        LayoutOrder = 2,

        ScrollBarImageTransparency = 1,
        Parent = self.card,
    })
    self:_fade(a64, "ScrollBarImageTransparency", 0.8)

        window:Create("UIPadding", {
        PaddingLeft = UDim.new(0, a25),
        PaddingRight = UDim.new(0, a25),
        PaddingTop = UDim.new(0, a25),
        PaddingBottom = UDim.new(0, a25),

        Parent = a64,
    })

    if self.boxes and #self.boxes > 0 then
        window:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, a33),

            Parent = a64,
        })
        for a65, a66 in self.boxes do
            self:_buildBox(a64, a66, a65)
        end
    else
        self:_fade(
            window:Create("TextLabel", {
                Text = a6.t(self.content),
                Size = UDim2.new(1, 0, 0, a62),
                BackgroundTransparency = 1,
                TextSize = a21,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextWrapped = true,

                TextTransparency = 1,
                Parent = a64,
            }, { TextColor3 = "ContentColor", FontFace = "Font" }),
            "TextTransparency",
            0.5
        )
    end

    return a63
end

function a1:_buildBox(a67, a68, a69)
    local window = self.window
    a68 = if typeof(a68) == "table" then a68 else { title = tostring(a68) }
    local a70 = a68.icon ~= nil and a68.icon ~= 0 and a68.icon ~= ""
    local a71, a72, a73, a74 = self:_measureBox(a68)

    local a75 = window:Create("Frame", {
        Name = "Box",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Size = UDim2.new(1, -a34, 0, a71),
        LayoutOrder = a69,

        BackgroundTransparency = 1,
        Parent = a67,
    })
    self:_fade(a75, "BackgroundTransparency", 0)

    local a76 = window:StyleElementPanel(a75)
    self:_fade(a76, "Transparency", window.theme.ElementStrokeTransparency)

    window:Create("UIPadding", {
        PaddingLeft = UDim.new(0, a27),
        PaddingRight = UDim.new(0, a27),
        PaddingTop = UDim.new(0, a28),
        PaddingBottom = UDim.new(0, a28),

        Parent = a75,
    })

    window:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, a30),

        Parent = a75,
    })

    if a70 then
        self:_fade(
            window:Create("ImageLabel", {
                Image = a68.icon,
                Size = UDim2.fromOffset(a29, a29),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                LayoutOrder = 1,

                ImageTransparency = 1,
                Parent = a75,
            }, { ImageColor3 = "ContentColor" }),
            "ImageTransparency",
            0
        )
    end

    local a77 = window:Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, a70 and -(a29 + a30) or 0, 0, a74),
        LayoutOrder = 2,

        Parent = a75,
    })

    window:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 3),

        Parent = a77,
    })

    self:_fade(
        window:Create("TextLabel", {
            Text = a6.t(a68.title or a68.Title or ""),
            Size = UDim2.new(1, 0, 0, a72),
            BackgroundTransparency = 1,
            TextSize = a31,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            LayoutOrder = 1,

            TextTransparency = 1,
            Parent = a77,
        }, { TextColor3 = "ContentColor", FontFace = "TitleFont" }),
        "TextTransparency",
        0
    )

    local a78 = a68.description or a68.Description
    if a78 and a78 ~= "" then
        self:_fade(
            window:Create("TextLabel", {
                Text = a6.t(a78),
                Size = UDim2.new(1, 0, 0, a73),
                BackgroundTransparency = 1,
                TextSize = a32,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextWrapped = true,
                LayoutOrder = 2,

                TextTransparency = 1,
                Parent = a77,
            }, { TextColor3 = "ContentColor", FontFace = "Font" }),
            "TextTransparency",
            0.65
        )
    end
end

function a1:_buildFooter()
    local window = self.window

    local a79 = window:Create("Frame", {
        Name = "Footer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, a35),
        LayoutOrder = 3,

        Parent = self.card,
    })

    window:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        HorizontalFlex = Enum.UIFlexAlignment.Fill,         SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, a36),

        Parent = a79,
    })

    for a80, a81 in self.options do
        self:_buildButton(a79, a81, a80)
    end
end

function a1:_buildButton(a82, a83, a84)
    local window = self.window
    a83 = if typeof(a83) == "table" then a83 else { text = tostring(a83) }
    local a85 = a83.style or a83.Style or "neutral"
    local a86 = a83.text or a83.Text or a83.name or a83.Name or "Okay"
    local a87 = a83.callback or a83.Callback

            local a88, a89, a90, a91
    if a85 == "primary" then
        a88, a89, a90, a91 =
            window.theme.AccentColor, window.theme.AccentStroke, window.theme.AccentStroke, 0.1
    elseif a85 == "danger" then
        a88, a89, a90, a91 =
            window.theme.ErrorColor, window.theme.ErrorStrokeColor, window.theme.ErrorStrokeColor, 0
    else
        a88, a89, a90, a91 =
            window.theme.NeutralButton, window.theme.NeutralButtonHover, window.theme.NeutralButtonStroke, 0.85
    end

    local a92 = window:Create("Frame", {
        Name = "Button",
        BackgroundColor3 = a88,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 0, a35),
        LayoutOrder = a84,

        BackgroundTransparency = 1,
        Parent = a82,
    })
    self:_fade(a92, "BackgroundTransparency", 0)

    window:Create("UIFlexItem", { FlexMode = Enum.UIFlexMode.Fill, Parent = a92 })
    window:Create("UICorner", { CornerRadius = a37, Parent = a92 })

    local a93 = window:Create("UIStroke", {
        Color = a90,
        Transparency = 1,
        Parent = a92,
    })
    self:_fade(a93, "Transparency", a91)

    self:_fade(
        window:Create("TextLabel", {
            Text = a6.t(a86),
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            TextSize = a38,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextTruncate = Enum.TextTruncate.AtEnd,

                        TextColor3 = a4.contrastText(a88),
            TextTransparency = 1,
            Parent = a92,
        }, { FontFace = "Font" }),
        "TextTransparency",
        0
    )

    local a94 = window:Create("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        BorderSizePixel = 0,
        ZIndex = 2,

        Parent = a92,
    })

    local a95 = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    table.insert(
        self._connections,
        window:Connect(a94.MouseEnter, function()
            if self._closed then
                return
            end
            a3.tweenService:Create(a92, a95, { BackgroundColor3 = a89 }):Play()
        end)
    )
    table.insert(
        self._connections,
        window:Connect(a94.MouseLeave, function()
            a3.tweenService:Create(a92, a95, { BackgroundColor3 = a88 }):Play()
        end)
    )

    table.insert(
        self._connections,
        window:Connect(a94.MouseButton1Click, function()
            if self._closed then
                return
            end
            a8.click()
                        a3.tweenService:Create(a93, a95, { Transparency = 1 }):Play()
            if a87 then
                task.spawn(function()
                    local ok, a96 = pcall(a87)
                    if not ok then
                        a7.warn("Astra: popup button '" .. a86 .. "' callback errored:")
                        a7.print(a96)
                    end
                end)
            end
            self:Close()
        end)
    )
end

function a1:_measureHeader(a97)
    local a98 = a18 - (if a97 then a22 + a23 else 0)
    self._titleH = a4.textHeight(self.window.theme.Font, a19, a6.resolve(self.title), a98)
    self._subH = if self.subtitle and self.subtitle ~= ""
        then a4.textHeight(self.window.theme.Font, a20, a6.resolve(self.subtitle), a98)
        else 0
    self._columnH = self._titleH + (if self._subH > 0 then 3 + self._subH else 0)
    return math.max(self._columnH, if a97 then a22 else 0)
end

function a1:_measureText()
        return a4.textHeight(self.window.theme.Font, a21, a6.resolve(self.content), a26)
end

function a1:_measureBox(a99)
    a99 = if typeof(a99) == "table" then a99 else { title = tostring(a99) }
    local a100 = a99.icon ~= nil and a99.icon ~= 0 and a99.icon ~= ""
    local a101 = a26 - a34 - a27 * 2 - (if a100 then a29 + a30 else 0)

    local a102 = a4.textHeight(
        self.window.theme.TitleFont,
        a31,
        a6.resolve(a99.title or a99.Title or ""),
        a101
    )
    local a103 = 0
    local a104 = a99.description or a99.Description
    if a104 and a104 ~= "" then
        a103 = a4.textHeight(self.window.theme.Font, a32, a6.resolve(a104), a101)
    end

    local a105 = a102 + (if a103 > 0 then 3 + a103 else 0)
    local a106 = math.max(a105, if a100 then a29 else 0) + a28 * 2
    return a106, a102, a103, a105
end

function a1:_measureBoxes()
    local a107 = 0
    for a108, a109 in self.boxes do
        a107 += (self:_measureBox(a109))
        if a108 < #self.boxes then
            a107 += a33
        end
    end
    return a107
end

function a1:_show()
    if self._closed or not self.screenGui.Parent then
        return
    end

    a8.notify()

    a3.tweenService:Create(self.card, a9, { Position = UDim2.new(0.5, 0, 0.5, 0) }):Play()

    for _, a110 in self._reveal do
        local a111 = if a110.instance == self.backdrop then a12 else a10
        a3.tweenService:Create(a110.instance, a111, { [a110.prop] = a110.to }):Play()
    end
end

function a1:Close()
    if self._closed then
        return
    end
    self._closed = true

    local a112 = table.find(a40, self)
    if a112 then
        table.remove(a40, a112)
    end

    for _, a113 in self._connections do
        self.window:Disconnect(a113)
    end
    self._connections = {}

    if not self.screenGui.Parent then
        return
    end

    if self._closeConnection then
        self._closeConnection:Disconnect()
        self._closeConnection = nil
    end

    local a114 = a3.tweenService:Create(
        self.card,
        a11,
        { Position = UDim2.new(0.5, 0, 0.5, 10) }
    )
    self._closeConnection = a114.Completed:Connect(function(a115)
        local a116 = self._closeConnection
        self._closeConnection = nil
        if a116 then
            a116:Disconnect()
        end
        if a115 == Enum.PlaybackState.Completed and self._closed and self.screenGui.Parent then
            self.window:DestroySubtree(self.screenGui)
        end
    end)
    a114:Play()

    for _, a117 in self._reveal do
        a3.tweenService:Create(a117.instance, a11, { [a117.prop] = 1 }):Play()
    end
end

return a1
