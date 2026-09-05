local a1 = {}
a1.__index = a1
a1.__type = "Input"

local a2 = script.Parent.Parent.utilities

local a3 = require(a2.Parent.core.state)
local a4 = require(script.Parent.Parent.functions)
local a5 = require(a2.moveable)
local a6 = require(a2.lockable)
local a7 = require(a2.locale)
local a8 = require(a2.constants)
local a9 = require(a2.HapticEngine)

local a10 = a8.pillResizeInfo
local a11 = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local function a12(a13)
    local a, b = a13:match("^([%d%.%-]+)%^([%d%.%-]+)$")
    if a and b then
        local na, nb = tonumber(a), tonumber(b)
        if na and nb then
            return na ^ nb
        end
    end
    return tonumber(a13)
end

function a1.new(tab, a14)
    a14 = if typeof(a14) == "table" then a14 else {}

    local self = setmetatable({
        tab = assert(tab, "Missing argument #1 (Tab expected)"),
        window = tab.window,
        name = a14.name or a14.Name or "Input",
        icon = tab.window:ResolveIcon(a14.icon or a14.Icon),
        description = a14.description or a14.Description,
        forgetState = a14.forgetState or a14.ForgetState or tab.forgetState,
        placeholder = a14.placeholder or a14.Placeholder or "",
        numeric = a14.numeric or a14.Numeric or false,         clearOnFocus = a14.clearOnFocus or a14.ClearOnFocus or false,

        callback = a14.callback or a14.Callback or function() end,
    }, a1)

    self.value =
        tostring(a14.value or a14.Value or a14.currentValue or a14.CurrentValue or "")

    self.flag = a14.flag
        or a14.Flag
        or (not self.forgetState and a4.deriveFlagFromName(self.name) or nil)
    self.window:_registerControl(self)

    self.main = self.window:Create("Frame", {
        Size = UDim2.new(1, -20, 0, 41),
        BorderSizePixel = 0,
        Name = self.name,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),

        BackgroundTransparency = 1,
        Parent = self.tab.tabPage,
    }, { BackgroundTransparency = "ElementTransparency" })

    self.stroke = self.window:StyleElementBody(self.main)
    self.hoverOverlay = self.window:CreateHoverOverlay(self.main)

        self.container = self.window:Create("Frame", {
        Size = UDim2.new(0, 170, 0, 16),
        Position = UDim2.new(0, 20, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 5,

        Parent = self.main,
    })

    self.window:Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,

        Parent = self.container,
    })

    if self.icon then
        self.iconLabel = self.window:Create("ImageLabel", {
            Image = self.icon,
            Size = UDim2.fromOffset(16, 16),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            ZIndex = 5,

            ImageTransparency = 1,
            Parent = self.container,
        }, { ImageColor3 = "ContentColor" })
    end

    self.title = self.window:Create("TextLabel", {
        Text = a7.t(self.name),
        Size = UDim2.fromOffset(150, 16),
        AutomaticSize = Enum.AutomaticSize.X,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1,
        ZIndex = 5,

        TextTransparency = 1,
        Parent = self.container,
    }, { TextColor3 = "ContentColor", FontFace = "Font" })

        self.box = self.window:Create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -7, 0, 20),
        Size = UDim2.fromOffset(85, 30),
        BorderSizePixel = 0,

        BackgroundTransparency = 1,
        Parent = self.main,
    }, { BackgroundColor3 = "FieldBackground" })

    self.window:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = self.box,
    })

    self.boxStroke = self.window:Create("UIStroke", {
        Transparency = 1,
        Parent = self.box,
    }, { Color = "SurfaceStroke" })

        self.glow = self.window:CreateGlow(self.box, "FieldGlow", 20, 1)
    self._glowIdle = 1
    self.input = self.window:Create("TextBox", {
        Text = self.value,
        PlaceholderText = a7.t(self.placeholder),
        Size = UDim2.new(1, -15, 0, 15),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ClearTextOnFocus = self.clearOnFocus,

        TextTransparency = 1,
        Parent = self.box,
    }, { TextColor3 = "ContentColor", FontFace = "Font", PlaceholderColor3 = "PlaceholderColor" })

        self.window:ConnectFor(self, self.input:GetPropertyChangedSignal("Text"), function()
        if self.numeric then
            local a15 = (self.input.Text:gsub("[^%d%.%-eE%^]", ""))
            if a15 ~= self.input.Text then
                self.input.Text = a15
                return             end
        end
        self:_sizeBox(true)
    end)

        self.window:ConnectFor(self, self.input.Focused, function()
        a3.tweenService:Create(self.input, a11, { TextTransparency = 0 }):Play()
    end)

        self.window:ConnectFor(self, self.input.FocusLost, function()
        a3.tweenService:Create(self.input, a11, { TextTransparency = 0.6 }):Play()
                        if self.clearOnFocus and self.input.Text == "" and self.value ~= "" then
            self.input.Text = self.value
            return
        end
        if self.input.Text == self.value then
            return         end
        self:_commit(self.input.Text)
    end)

    self.window:_wireElementHover(self)

    if self.description then
        self.descriptor = require(script.Parent.descriptor).new(self.tab, { description = self.description })
    end

    self:_sizeBox(false)
    return self
end

function a1:_sizeBox(a16)
    local a17 = self.input.Text ~= "" and self.input.Text or self.placeholder
    local a18 = math.clamp(a4.textWidth(self.window.theme.Font, 15, a17) + 30, 70, 220)
    if a16 then
        a3.tweenService:Create(self.box, a10, { Size = UDim2.fromOffset(a18, 30) }):Play()
    else
        self.box.Size = UDim2.fromOffset(a18, 30)
    end
end

function a1:_commit(a19, a20)
    a19 = tostring(a19)
    if self.numeric then
        local n = a12(a19)
        if not n or n ~= n or n == math.huge or n == -math.huge then
                        if self.input.Text ~= self.value then
                self.input.Text = self.value
            end
            return
        end
        a19 = tostring(n)
    end

    local a21 = a19 ~= self.value
    self.value = a19
    if self.input.Text ~= a19 then
        self.input.Text = a19
    end

    if not a20 then
        self.window:_runGuarded(self, self.callback, a19)
        self.window:_persist(self)
                        if a21 and not self.window._loading then
            a9.click()
            self.window:_flashResult(self, true)
        end
    end
end

function a1:Set(a22, a23)
    self:_commit(a22, a23)
end

function a1:_setShown(a24, a25)
    local w = self.window
    if a24 then
        w:_revealCommon(self, a25)
        w:_reveal(self.box, { BackgroundTransparency = w.theme.FieldTransparency }, a25)
        w:_reveal(self.boxStroke, { Transparency = 0.85 }, a25)
        w:_reveal(self.input, { TextTransparency = 0.6 }, a25)
    else
        w:_hideCommon(self, a25)
        w:_reveal(self.box, { BackgroundTransparency = 1 }, a25)
        w:_reveal(self.boxStroke, { Transparency = 1 }, a25)
        w:_reveal(self.input, { TextTransparency = 1 }, a25)
    end
end

function a1:_refreshTheme()
    a3.tweenService
        :Create(
            self.box,
            TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            { BackgroundTransparency = self.window.theme.FieldTransparency }
        )
        :Play()
end

a5(a1)
a6(a1)

return a1
