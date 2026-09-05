local a1 = require(script.Parent.Parent.core.state)
local a2 = a1.textService

local a3 = {}
a3.__index = a3

local a4 = 20

local function a5(a6, a7, a8)
    local a9 = Instance.new("GetTextBoundsParams")
    a9.Text = a8
    a9.Font = a6
    a9.Size = a7
    a9.Width = math.huge
    local ok, a10 = pcall(a2.GetTextBoundsAsync, a2, a9)
    return if ok then a10 else Vector2.new(a7 * 0.6, a7)
end

local a11 = {}
local a12 = 0
local a13 = 64
local function a14(a15, a16)
        local a17 = tostring(a15.Family)
        .. "|"
        .. tostring(a15.Weight)
        .. "|"
        .. tostring(a15.Style)
        .. "|"
        .. tostring(a16)
    local a18 = a11[a17]
    if a18 then
        return a18
    end

    local a19, a20 = {}, 0
    for d = 0, 9 do
        local w = math.ceil(a5(a15, a16, tostring(d)).X)
        a19[d] = w
        if w > a20 then
            a20 = w
        end
    end
    a18 = { advance = a19, maxWidth = a20 }
    if a12 >= a13 then
        a11 = {}
        a12 = 0
    end
    a11[a17] = a18
    a12 += 1
    return a18
end

function a3.new(window, a21, a22)
    a22 = a22 or {}
    local self = setmetatable({
        window = window,
        container = a21,
        textSize = a22.textSize or 16,
        transparency = a22.transparency or 1,         duration = a22.duration or 0.55,
        slots = {},         length = 0,     }, a3)

    self.roll = TweenInfo.new(self.duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

            self.zIndex = math.max(a21.ZIndex + 1, 6)

            self.height = math.ceil(self.textSize)

                local a23 = a14(window.theme.Font, self.textSize)
    self.advance = a23.advance
    self.maxWidth = a23.maxWidth

    window:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = a22.alignment or Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0),

        Parent = a21,
    })

    return self
end

function a3:_reel(a24)
    local a25 = self.slots[a24]
    if a25.reel then
        return a25.reel
    end

    local a26 = self.window:Create("Frame", {
        Name = "Reel",
        Size = UDim2.fromOffset(self.maxWidth, self.height),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = self.zIndex,

        Parent = self.container,
    })

    local a27 = self.window:Create("Frame", {
        Size = UDim2.fromOffset(self.maxWidth, self.height),
        AnchorPoint = Vector2.new(0.5, 0),         Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = self.zIndex,

        Parent = a26,
    })

    for i = 0, a4 - 1 do
        self.window:Create("TextLabel", {
            Text = tostring(i % 10),
            Position = UDim2.fromOffset(0, i * self.height),
            Size = UDim2.fromOffset(self.maxWidth, self.height),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            TextSize = self.textSize,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextTransparency = self.transparency,
            ZIndex = self.zIndex,

            Parent = a27,
        }, { TextColor3 = "ContentColor", FontFace = "Font" })
    end

    local a28 = { cell = a26, strip = a27, digit = 0, target = 0, stripTween = nil, sizeTween = nil }
    a25.reel = a28
    return a28
end

function a3:_static(a29)
    local a30 = self.slots[a29]
    if a30.static then
        return a30.static
    end

    local a31 = self.window:Create("TextLabel", {
        Name = "Static",
        Size = UDim2.fromOffset(0, self.height),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        TextSize = self.textSize,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTransparency = self.transparency,
        ZIndex = self.zIndex,

        Parent = self.container,
    }, { TextColor3 = "ContentColor", FontFace = "Font" })

    a30.static = a31
    return a31
end

local function a32(a33)
    if a33.stripTween then
        a33.stripTween:Cancel()
        a33.stripTween = nil
    end
    if a33.sizeTween then
        a33.sizeTween:Cancel()
        a33.sizeTween = nil
    end
end

function a3:_reelSnap(a34, a35)
    a32(a34)
    a34.cell.Size = UDim2.fromOffset(self.advance[a35], self.height)
    a34.strip.Position = UDim2.new(0.5, 0, 0, -a35 * self.height)
    a34.digit = a35
    a34.target = a35
end

function a3:_reelRoll(a36, a37, up)
        if a36.stripTween or a36.sizeTween then
        self:_reelSnap(a36, a36.target)
    end

    local a = a36.digit
    if a == a37 then
        return
    end

    local a38, a39
    if up then
        a38 = a
        a39 = a + (a37 - a) % 10     else
        a38 = a + 10         a39 = a38 - (a - a37) % 10
    end

    a36.strip.Position = UDim2.new(0.5, 0, 0, -a38 * self.height)
    a36.target = a37

        local a40 = a1.tweenService:Create(a36.strip, self.roll, {
        Position = UDim2.new(0.5, 0, 0, -a39 * self.height),
    })
    local a41 = a1.tweenService:Create(a36.cell, self.roll, {
        Size = UDim2.fromOffset(self.advance[a37], self.height),
    })
    a36.stripTween = a40
    a36.sizeTween = a41
    a40.Completed:Connect(function(a42)
        if a42 == Enum.PlaybackState.Completed and a36.stripTween == a40 then
            self:_reelSnap(a36, a37)
        end
    end)
    a40:Play()
    a41:Play()
    a36.digit = a37
end

function a3:_putDigit(a43, a44, up, a45)
    local a46 = self:_reel(a43)
    local a47 = not a46.cell.Visible
    a46.cell.Visible = true
    a46.cell.LayoutOrder = -a43
    if self.slots[a43].static then
        self.slots[a43].static.Visible = false
    end
    if a45 and not a47 then
        self:_reelRoll(a46, a44, up)
    else
        self:_reelSnap(a46, a44)
    end
end

function a3:_putStatic(a48, a49)
    local a50 = self:_static(a48)
    if not a50.Visible then
                a50.TextTransparency = self.transparency
    end
    a50.Text = a49
    a50.Visible = true
    a50.LayoutOrder = -a48
    if self.slots[a48].reel then
        self.slots[a48].reel.cell.Visible = false
    end
end

function a3:_hide(a51)
    local a52 = self.slots[a51]
    if not a52 then
        return
    end
    if a52.reel then
        a52.reel.cell.Visible = false
    end
    if a52.static then
        a52.static.Visible = false
    end
end

function a3:_render(a53, a54, up)
    a53 = tostring(a53)

        if a53 == self._lastText then
        return
    end
    self._lastText = a53

            local a55 = {}
    for _, a56 in utf8.codes(a53) do
        table.insert(a55, utf8.char(a56))
    end

    local n = #a55
    for i = 0, math.max(n, self.length) - 1 do
        self.slots[i] = self.slots[i] or {}
        if i < n then
            local a57 = a55[n - i]             if a57:match("%d") then
                self:_putDigit(i, tonumber(a57), up, a54)
            else
                self:_putStatic(i, a57)
            end
        else
            self:_hide(i)
        end
    end
    self.length = n
end

function a3:to(a58, up)
    self:_render(a58, true, up)
end

function a3:snap(a59)
    self:_render(a59, false, true)
end

function a3:reveal(a60, a61, a62)
    self.transparency = a60
    for _, a63 in self.slots do
        if a63.static and a63.static.Visible then
            self.window:_reveal(a63.static, { TextTransparency = a60 }, a61, a62)
        end
        if a63.reel then
            for _, a64 in a63.reel.strip:GetChildren() do
                if a64:IsA("TextLabel") then
                    self.window:_reveal(a64, { TextTransparency = a60 }, a61, a62)
                end
            end
        end
    end
end

return a3
