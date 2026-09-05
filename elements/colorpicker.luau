local a1 = {}
a1.__index = a1
a1.__type = "ColorPicker"

local a2 = script.Parent.Parent.utilities

local a3 = require(a2.Parent.core.state)
local a4 = require(script.Parent.Parent.functions)
local a5 = require(a2.moveable)
local a6 = require(a2.lockable)
local a7 = require(a2.constants)
local a8 = require(a2.locale)
local a9 = require(a2.HapticEngine)

local a10 = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
})

local a11 = 41
local a12 = 52 local a13 = Vector2.new(150, 120)
local a14 = 184 local a15 = 10
local a16 = 214 local a17 = 10
local a18 = 240 local a19 = 62 local a20 = 8
local a21 = 400

local a22 = {
    wide = {
        height = 190,
        previewPos = UDim2.new(1, -20, 0, a12 + 39),
        previewSize = UDim2.new(1, -(a18 + 20), 0, 78),
        hexPos = UDim2.new(0, a18, 0, a12 + 90),
        hexSize = UDim2.new(1, -(a18 + 20 + a19 + a20), 0, 30),
        alphaFieldPos = UDim2.new(1, -(20 + a19), 0, a12 + 90),
        alphaFieldSize = UDim2.new(0, a19, 0, 30),
    },
    narrow = {
        height = 296,
        previewPos = UDim2.new(1, -20, 0, a12 + a13.Y + 40),
        previewSize = UDim2.new(1, -40, 0, 56),
        hexPos = UDim2.new(0, 20, 0, a12 + a13.Y + 78),
        hexSize = UDim2.new(1, -(40 + a19 + a20), 0, 30),
        alphaFieldPos = UDim2.new(1, -(20 + a19), 0, a12 + a13.Y + 78),
        alphaFieldSize = UDim2.new(0, a19, 0, 30),
    },
}

local a23 = UDim2.new(1, -16, 0, a11 / 2)
local a24 = UDim2.fromOffset(40, 22)

local a25 = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
local a26 = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local a27 = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local a28 = TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local a29 = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local function a30(n)
    return math.clamp(n, 0, 1)
end

local function a31(n)
    return math.clamp(math.round(n), 0, 255)
end

local a32 = {
    black = Color3.fromRGB(0, 0, 0),
    white = Color3.fromRGB(255, 255, 255),
    red = Color3.fromRGB(255, 0, 0),
    green = Color3.fromRGB(0, 255, 0),
    blue = Color3.fromRGB(0, 0, 255),
    yellow = Color3.fromRGB(255, 255, 0),
    cyan = Color3.fromRGB(0, 255, 255),
    magenta = Color3.fromRGB(255, 0, 255),
    orange = Color3.fromRGB(255, 165, 0),
    purple = Color3.fromRGB(128, 0, 128),
    pink = Color3.fromRGB(255, 105, 180),
    brown = Color3.fromRGB(139, 69, 19),
    gray = Color3.fromRGB(128, 128, 128),
    grey = Color3.fromRGB(128, 128, 128),
}

local function a33(h, s, l)
    if s <= 0 then
        return Color3.new(l, l, l)
    end
    local function a34(p, q, t)
        t = t % 1
        if t < 1 / 6 then
            return p + (q - p) * 6 * t
        elseif t < 1 / 2 then
            return q
        elseif t < 2 / 3 then
            return p + (q - p) * (2 / 3 - t) * 6
        end
        return p
    end
    local q = if l < 0.5 then l * (1 + s) else l + s - l * s
    local p = 2 * l - q
    return Color3.new(a34(p, q, h + 1 / 3), a34(p, q, h), a34(p, q, h - 1 / 3))
end

local function a35(s)
    local a36 = {}
    for n in s:gmatch("[%d%.]+") do
        table.insert(a36, tonumber(n))
    end
    return a36
end

local function a37(a38)
    if typeof(a38) ~= "string" then
        return nil
    end
    local s = (a38:lower():match("^%s*(.-)%s*$")) or ""
    if s == "" then
        return nil
    end

    if a32[s] then
        return a32[s]
    end

    local a39 = s:match("^(%a+)")
    local a40 = a35(s)

    if (a39 == "hsv" or a39 == "hsb") and #a40 >= 3 then
        local h = (a40[1] % 360) / 360
        local a41 = if a40[2] > 1 then a40[2] / 100 else a40[2]
        local v = if a40[3] > 1 then a40[3] / 100 else a40[3]
        return Color3.fromHSV(h, a30(a41), a30(v))
    end

    if a39 == "hsl" and #a40 >= 3 then
        local h = (a40[1] % 360) / 360
        local a42 = if a40[2] > 1 then a40[2] / 100 else a40[2]
        local l = if a40[3] > 1 then a40[3] / 100 else a40[3]
        return a33(h, a30(a42), a30(l))
    end

    if (a39 == "rgb" or a39 == "rgba") and #a40 >= 3 then
        return Color3.fromRGB(a31(a40[1]), a31(a40[2]), a31(a40[3]))
    end

        local a43 = s:match("^#?(%x%x%x%x%x%x)$") or s:match("^#?(%x%x%x)$") or s:match("^0x(%x%x%x%x%x%x)$")
    if a43 then
        local ok, a44 = pcall(Color3.fromHex, a43)
        if ok then
            return a44
        end
    end

        if #a40 >= 3 and not a39 then
        if a40[1] <= 1 and a40[2] <= 1 and a40[3] <= 1 then
            return Color3.new(a30(a40[1]), a30(a40[2]), a30(a40[3]))
        end
        return Color3.fromRGB(a31(a40[1]), a31(a40[2]), a31(a40[3]))
    end

    return nil
end

local function a45(a46, a47)
    if typeof(a46) == "Color3" then
        return a46
    end
    if typeof(a46) == "string" then
        return a37(a46) or a47
    end
    return a47
end

function a1.new(tab, a48)
    a48 = if typeof(a48) == "table" then a48 else {}

    local self = setmetatable({
        tab = assert(tab, "Missing argument #1 (Tab expected)"),
        window = tab.window,
        name = a48.name or a48.Name or "Color Picker",
        icon = tab.window:ResolveIcon(a48.icon or a48.Icon),
        description = a48.description or a48.Description,
        forgetState = a48.forgetState or a48.ForgetState or tab.forgetState,

        callback = a48.callback or a48.Callback or function() end,

        _isOpen = false,
    }, a1)

    self.value = a45(
        a48.color or a48.Color or a48.value or a48.Value or a48.default,
        Color3.fromRGB(255, 255, 255)
    )

            self.hue, self.sat, self.val = self.value:ToHSV()

        local a = a48.alpha or a48.Alpha
    self.alpha = if type(a) == "number" then a30(a) else 1

    self.flag = a48.flag
        or a48.Flag
        or (not self.forgetState and a4.deriveFlagFromName(self.name) or nil)
    self.window:_registerControl(self)

            self.main = self.window:Create("Frame", {
        Size = UDim2.new(1, -20, 0, a11),
        BorderSizePixel = 0,
        Name = self.name,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Parent = self.tab.tabPage,
    }, { BackgroundTransparency = "ElementTransparency" })

    self.stroke = self.window:StyleElementBody(self.main)
    self.hoverOverlay = self.window:CreateHoverOverlay(self.main)

    self:_buildHeader()
    self:_buildPicker()

    self.window:ConnectFor(self, self.interact.MouseButton1Click, function()
        a9.click()
        if self._isOpen then
            self:_close()
        else
            self:_open()
        end
    end)

        self.window:ConnectFor(self, self.main.MouseEnter, function()
        if self._isOpen or not self.window:_interactive() then
            return
        end
        local a49 = self.window.theme
        a3.tweenService
            :Create(self.stroke, a26, {
                Transparency = a49.ElementStrokeHoverTransparency,
                Color = a49.ElementStrokeHover,
            })
            :Play()
        a3.tweenService:Create(self.title, a26, { TextColor3 = a49.ElementTextHoverColor }):Play()
        a3.tweenService:Create(self.hoverOverlay, a26, { BackgroundTransparency = 0.97 }):Play()
    end)

    self.window:ConnectFor(self, self.main.MouseLeave, function()
        local a50 = self.window.theme
        a3.tweenService
            :Create(
                self.stroke,
                a26,
                { Transparency = a50.ElementStrokeTransparency, Color = a50.ElementStroke }
            )
            :Play()
        a3.tweenService:Create(self.title, a26, { TextColor3 = a50.ContentColor }):Play()
        a3.tweenService:Create(self.hoverOverlay, a26, { BackgroundTransparency = 1 }):Play()
    end)

    if self.description then
        self.descriptor = require(script.Parent.descriptor).new(self.tab, { description = self.description })
    end

        self:_applyPickerVisibility(false, false)
    self:_setControlsVisible(false)
                self.window:ConnectFor(self, self.main:GetPropertyChangedSignal("AbsoluteSize"), function()
                        if self.window.animating or (self.window.hidden and self.window.hasShownOnce) then
            return
        end
        self:_applyLayout()
    end)
    self:_applyLayout()

    self:_render("instant")

    return self
end

function a1:_buildHeader()
    self.container = self.window:Create("Frame", {
        Size = UDim2.new(0, 170, 0, 16),
        Position = UDim2.new(0, 20, 0, a11 / 2),
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
        SortOrder = Enum.SortOrder.LayoutOrder,

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
        Text = a8.t(self.name),
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

            self.preview = self.window:Create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = a23,
        Size = a24,
        BackgroundColor3 = self.value,
        BorderSizePixel = 0,
        ZIndex = 3,

        BackgroundTransparency = 1,
        Parent = self.main,
    })

    self.window:Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = self.preview,
    })

            self.previewShadow = self.window:CreateGlow(self.preview, self.value, 20, 1)

            self.invisibleGroup = self.window:Create("Frame", {
        Size = UDim2.fromScale(1, 1),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 5,

        Parent = self.preview,
    })

    self.window:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,

        Parent = self.invisibleGroup,
    })

    self.invisibleIcon = self.window:Create("ImageLabel", {
        Image = a7.icons.colorpicker,
        Size = UDim2.fromOffset(16, 16),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 5,

        ImageTransparency = 1,
        Parent = self.invisibleGroup,
    }, { ImageColor3 = "ContentColor" })

    self.invisibleText = self.window:Create("TextLabel", {
        Text = a8.t("Invisible"),
        Size = UDim2.fromOffset(0, 16),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        TextSize = 15,
        LayoutOrder = 1,
        ZIndex = 5,

        TextTransparency = 1,
        Parent = self.invisibleGroup,
    }, { TextColor3 = "ContentColor", FontFace = "Font" })

        self.interact = self.window:Create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, a11),
        Position = UDim2.fromScale(0, 0),
        BorderSizePixel = 0,
        Text = "",
        TextTransparency = 1,
        AutoButtonColor = false,
        ZIndex = 10,

        Parent = self.main,
    })
end

function a1:_buildMap()
    self.map = self.window:Create("Frame", {
        Position = UDim2.fromOffset(20, a12),
        Size = UDim2.fromOffset(a13.X, a13.Y),
        BackgroundColor3 = Color3.fromHSV(self.hue, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 2,

        BackgroundTransparency = 1,
        Parent = self.main,
    })

    self.window:Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = self.map })

    self.mapStroke = self.window:Create("UIStroke", {
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 1,
        Parent = self.map,
    })

        self.satOverlay = self.window:Create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 3,

        BackgroundTransparency = 1,
        Parent = self.map,
    })
    self.window:Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = self.satOverlay })
    self.window:Create("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1),
        }),
        Parent = self.satOverlay,
    })

        self.valOverlay = self.window:Create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        ZIndex = 4,

        BackgroundTransparency = 1,
        Parent = self.map,
    })
    self.window:Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = self.valOverlay })
    self.window:Create("UIGradient", {
        Rotation = 90,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0),
        }),
        Parent = self.valOverlay,
    })
end

function a1:_buildPicker()
    self:_buildMap()

    self.satCursor = self.window:Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(12, 12),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 6,

        BackgroundTransparency = 1,
        Parent = self.map,
    })

    self.window:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = self.satCursor,
    })

    self.satCursorStroke = self.window:Create("UIStroke", {
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 2,
        Transparency = 1,
        Parent = self.satCursor,
    })

    self.mapInteract = self.window:Create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = "",
        TextTransparency = 1,
        AutoButtonColor = false,
        ZIndex = 7,

        Parent = self.map,
    })

        self.hueBar = self.window:Create("Frame", {
        Position = UDim2.fromOffset(a14, a12),
        Size = UDim2.fromOffset(a15, a13.Y),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 2,

        BackgroundTransparency = 1,
        Parent = self.main,
    })

    self.window:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = self.hueBar,
    })

    self.window:Create("UIGradient", {
        Color = a10,
        Rotation = 90,

        Parent = self.hueBar,
    })

    self.hueHandle = self.window:Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.fromOffset(a15 + 8, 8),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 4,

        BackgroundTransparency = 1,
        Parent = self.hueBar,
    })

    self.window:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = self.hueHandle,
    })

    self.hueHandleStroke = self.window:Create("UIStroke", {
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 2,
        Transparency = 1,
        Parent = self.hueHandle,
    })

    self.hueInteract = self.window:Create("TextButton", {
        BackgroundTransparency = 1,
                Size = UDim2.new(1, 16, 1, 8),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Text = "",
        TextTransparency = 1,
        AutoButtonColor = false,
        ZIndex = 6,

        Parent = self.hueBar,
    })

                self.alphaBar = self.window:Create("Frame", {
        Position = UDim2.fromOffset(a16, a12),
        Size = UDim2.fromOffset(a17, a13.Y),
        BackgroundColor3 = self.value,
        BorderSizePixel = 0,
        ZIndex = 2,

        BackgroundTransparency = 1,
        Parent = self.main,
    })

    self.window:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = self.alphaBar,
    })

    self.alphaGradient = self.window:Create("UIGradient", {
        Rotation = 90,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1),
        }),
        Parent = self.alphaBar,
    })

    self.alphaHandle = self.window:Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.fromOffset(a17 + 8, 8),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 4,

        BackgroundTransparency = 1,
        Parent = self.alphaBar,
    })

    self.window:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = self.alphaHandle,
    })

    self.alphaHandleStroke = self.window:Create("UIStroke", {
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 2,
        Transparency = 1,
        Parent = self.alphaHandle,
    })

    self.alphaInteract = self.window:Create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 16, 1, 8),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Text = "",
        TextTransparency = 1,
        AutoButtonColor = false,
        ZIndex = 6,

        Parent = self.alphaBar,
    })

        self.hexBox = self.window:Create("Frame", {
        Position = UDim2.new(0, a18, 0, a12 + 90),
        Size = UDim2.new(1, -(a18 + 20), 0, 30),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 2,

        BackgroundTransparency = 1,
        Parent = self.main,
    })

    self.window:Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = self.hexBox,
    })

    self.hexBoxStroke = self.window:Create("UIStroke", {
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 1,
        Parent = self.hexBox,
    })

    self.hexInput = self.window:Create("TextBox", {
        Text = "#" .. self.value:ToHex():upper(),
        PlaceholderText = a8.t("Smart Input"),
        Size = UDim2.new(1, -14, 1, 0),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Center,
        ClearTextOnFocus = false,
        ZIndex = 3,

        TextTransparency = 1,
        Parent = self.hexBox,
    }, { TextColor3 = "ContentColor", FontFace = "Font", PlaceholderColor3 = "PlaceholderColor" })

        self.alphaBox = self.window:Create("Frame", {
        Position = UDim2.new(0, a18, 0, a12 + 90),
        Size = UDim2.fromOffset(a19, 30),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 2,

        BackgroundTransparency = 1,
        Parent = self.main,
    })

    self.window:Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = self.alphaBox,
    })

    self.alphaBoxStroke = self.window:Create("UIStroke", {
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 1,
        Parent = self.alphaBox,
    })

    self.alphaInput = self.window:Create("TextBox", {
        Text = tostring(math.round(self.alpha * 100)) .. "%",
        PlaceholderText = "100%",
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Center,
        ClearTextOnFocus = false,
        ZIndex = 3,

        TextTransparency = 1,
        Parent = self.alphaBox,
    }, { TextColor3 = "ContentColor", FontFace = "Font", PlaceholderColor3 = "PlaceholderColor" })

    self.window:ConnectFor(self, self.mapInteract.InputBegan, function(a51)
        if
            a51.UserInputType == Enum.UserInputType.MouseButton1
            or a51.UserInputType == Enum.UserInputType.Touch
        then
            self:_beginDrag("sat", a51.UserInputType == Enum.UserInputType.MouseButton1)
        end
    end)

    self.window:ConnectFor(self, self.hueInteract.InputBegan, function(a52)
        if
            a52.UserInputType == Enum.UserInputType.MouseButton1
            or a52.UserInputType == Enum.UserInputType.Touch
        then
            self:_beginDrag("hue", a52.UserInputType == Enum.UserInputType.MouseButton1)
        end
    end)

    self.window:ConnectFor(self, self.alphaInteract.InputBegan, function(a53)
        if
            a53.UserInputType == Enum.UserInputType.MouseButton1
            or a53.UserInputType == Enum.UserInputType.Touch
        then
            self:_beginDrag("alpha", a53.UserInputType == Enum.UserInputType.MouseButton1)
        end
    end)

    self.window:ConnectFor(self, a3.userInputService.InputEnded, function(a54)
        if
            (a54.UserInputType == Enum.UserInputType.MouseButton1 or a54.UserInputType == Enum.UserInputType.Touch)
            and self._drag
        then
            self:_endDrag()
        end
    end)

            self.window:ConnectFor(self, self.hexInput.FocusLost, function()
        local a55 = a37(self.hexInput.Text)
        if a55 then
            self:Set(a55)
        else
            self.hexInput.Text = "#" .. self.value:ToHex():upper()
        end
    end)

        self.window:ConnectFor(self, self.alphaInput.FocusLost, function()
        local n = tonumber((self.alphaInput.Text:gsub("[^%d%.]", "")))
        if n then
            self:SetAlpha(a30(n / 100))
        else
            self.alphaInput.Text = tostring(math.round(self.alpha * 100)) .. "%"
        end
    end)
end

function a1:_beginDrag(a56, a57)
            if not self._isOpen then
        return
    end
    self._drag = a56
    self._dragIsMouse = a57
    self:_setHeld(a56)
    self:_pump()

    if self._dragConnection then
        self._dragConnection:Disconnect()
        self._dragConnection = nil
    end

    self._dragConnection = a3.runService.RenderStepped:Connect(function()
        local a58 = self._dragIsMouse
            and not a3.userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
        if self.window.unloaded or not self._drag or a58 then
            if a58 then
                self:_endDrag()
                return
            end
            if self._dragConnection then
                self._dragConnection:Disconnect()
                self._dragConnection = nil
            end
            return
        end
        self:_pump()
    end)
end

function a1:_endDrag()
    self._drag = nil
    self:_setHeld(nil)
    if self._dragConnection then
        self._dragConnection:Disconnect()
        self._dragConnection = nil
    end

    self.window:_persist(self)
end

function a1:_setHeld(a59)
    local a60 = if a59 == "sat" then UDim2.fromOffset(16, 16) else UDim2.fromOffset(12, 12)
    local a61 = if a59 == "hue" then UDim2.fromOffset(a15 + 12, 10) else UDim2.fromOffset(a15 + 8, 8)
    local a62 = if a59 == "alpha"
        then UDim2.fromOffset(a17 + 12, 10)
        else UDim2.fromOffset(a17 + 8, 8)
    a3.tweenService:Create(self.satCursor, a29, { Size = a60 }):Play()
    a3.tweenService:Create(self.hueHandle, a29, { Size = a61 }):Play()
    a3.tweenService:Create(self.alphaHandle, a29, { Size = a62 }):Play()
end

function a1:_mouseLocation()
    local a63 = a3.userInputService:GetMouseLocation()
    local a64 = self.window.screenGui
    if a64 and a64.IgnoreGuiInset then
        return a63 - a3.guiService:GetGuiInset()
    end
    return a63
end

function a1:_pump()
        local a65, a66, a67, a68 = self.hue, self.sat, self.val, self.alpha

    if self._drag == "sat" then
        local a69 = self.map.AbsoluteSize
        if a69.X <= 0 or a69.Y <= 0 then
            return
        end
        local a70 = self:_mouseLocation()
        self.sat = a30((a70.X - self.map.AbsolutePosition.X) / a69.X)
        self.val = 1 - a30((a70.Y - self.map.AbsolutePosition.Y) / a69.Y)
    elseif self._drag == "hue" then
        local a71 = self.hueBar.AbsoluteSize.Y
        if a71 <= 0 then
            return
        end
        local a72 = self:_mouseLocation()
        self.hue = a30((a72.Y - self.hueBar.AbsolutePosition.Y) / a71)
    elseif self._drag == "alpha" then
        local a73 = self.alphaBar.AbsoluteSize.Y
        if a73 <= 0 then
            return
        end
        local a74 = self:_mouseLocation()
                self.alpha = 1 - a30((a74.Y - self.alphaBar.AbsolutePosition.Y) / a73)
    else
        return
    end

                if self.hue == a65 and self.sat == a66 and self.val == a67 and self.alpha == a68 then
        return
    end

    self.value = Color3.fromHSV(self.hue, self.sat, self.val)
    self:_render("drag")
    self:_fireCallback()
end

function a1:_render(a75)
    local a76 = Color3.fromHSV(self.hue, 1, 1)
    local a77 = UDim2.new(self.sat, 0, 1 - self.val, 0)
    local a78 = UDim2.new(0.5, 0, self.hue, 0)
    local a79 = UDim2.new(0.5, 0, 1 - self.alpha, 0)
    local a80 = 1 - self.alpha     local a81 = 1 - 0.4 * self.alpha
    if a75 == "instant" then
        self.map.BackgroundColor3 = a76
        self.satCursor.Position, self.satCursor.BackgroundColor3 = a77, self.value
        self.hueHandle.Position, self.hueHandle.BackgroundColor3 = a78, a76
        self.alphaBar.BackgroundColor3 = self.value
        self.alphaHandle.Position, self.alphaHandle.BackgroundColor3 = a79, self.value
        self.preview.BackgroundColor3 = self.value
        self.previewShadow.Color = self.value
        if not self.window.hidden then
            self.preview.BackgroundTransparency = a80
            self.previewShadow.Transparency = a81
        end
    else
        local a82 = if a75 == "drag" then a28 else a27
        a3.tweenService:Create(self.map, a82, { BackgroundColor3 = a76 }):Play()
        a3.tweenService
            :Create(self.satCursor, a82, { Position = a77, BackgroundColor3 = self.value })
            :Play()
        a3.tweenService:Create(self.hueHandle, a82, { Position = a78, BackgroundColor3 = a76 }):Play()
        a3.tweenService
            :Create(self.alphaHandle, a82, { Position = a79, BackgroundColor3 = self.value })
            :Play()
                a3.tweenService:Create(self.alphaBar, a27, { BackgroundColor3 = self.value }):Play()
        local a83 = { BackgroundColor3 = self.value }
        local a84 = { Color = self.value }
        if not self.window.hidden then
            a83.BackgroundTransparency = a80
            a84.Transparency = a81
        end
        a3.tweenService:Create(self.preview, a27, a83):Play()
        a3.tweenService:Create(self.previewShadow, a27, a84):Play()
    end

        if not self.hexInput:IsFocused() then
        self.hexInput.Text = "#" .. self.value:ToHex():upper()
    end
    if not self.alphaInput:IsFocused() then
        self.alphaInput.Text = tostring(math.round(self.alpha * 100)) .. "%"
    end

    self:_renderInvisible(a75 ~= "instant")
end

function a1:_renderInvisible(a85)
    local a86 = 0
    if self._isOpen and not self.window.hidden then
        a86 = a30((0.12 - self.alpha) / 0.12)
    end
    local t = 1 - a86
    if a85 then
        a3.tweenService:Create(self.invisibleIcon, a26, { ImageTransparency = t }):Play()
        a3.tweenService:Create(self.invisibleText, a26, { TextTransparency = t }):Play()
    else
        self.invisibleIcon.ImageTransparency = t
        self.invisibleText.TextTransparency = t
    end
end

function a1:_renderTooltip(a87)
    self._renderTooltipState = a87
end

function a1:_fireCallback()
    self.window:_runGuarded(self, self.callback, self.value, self.alpha)
end

function a1:_open()
    if self._isOpen then
        return
    end
    self._isOpen = true
    self:_setControlsVisible(true)
    if self._outsideClickConn then
        self.window:Disconnect(self._outsideClickConn)
    end
    self._outsideClickConn = self.window:Connect(a3.userInputService.InputBegan, function(a88)
        if
            a88.UserInputType ~= Enum.UserInputType.MouseButton1
            and a88.UserInputType ~= Enum.UserInputType.Touch
        then
            return
        end
        local a89 = a88.Position
        local a90 = self.main.AbsolutePosition
        local a91 = self.main.AbsoluteSize
        if
            a89.X < a90.X
            or a89.X > a90.X + a91.X
            or a89.Y < a90.Y
            or a89.Y > a90.Y + a91.Y
        then
            self:_close()
        end
    end)

    a3.tweenService:Create(self.main, a25, { Size = UDim2.new(1, -20, 0, self._openHeight) }):Play()
        a3.tweenService
        :Create(self.preview, a25, { Position = self._previewOpenPos, Size = self._previewOpenSize })
        :Play()
    self:_applyPickerVisibility(true, true)
    self:_renderInvisible(true)
end

function a1:_close()
    if not self._isOpen then
        return
    end
    self._isOpen = false

    if self._outsideClickConn then
        self.window:Disconnect(self._outsideClickConn)
        self._outsideClickConn = nil
    end

        if self._drag then
        self:_endDrag()
    end
    if self.hexInput:IsFocused() then
        self.hexInput:ReleaseFocus()
    end
    if self.alphaInput:IsFocused() then
        self.alphaInput:ReleaseFocus()
    end

    self:_applyPickerVisibility(false, true)
    self:_renderInvisible(true)
    a3.tweenService
        :Create(self.preview, a25, { Position = a23, Size = a24 })
        :Play()
    a3.tweenService:Create(self.main, a25, { Size = UDim2.new(1, -20, 0, a11) }):Play()

            task.delay(a26.Time, function()
        if not self._isOpen and not self.window.unloaded then
            self:_setControlsVisible(false)
        end
    end)
end

function a1:_applyPickerVisibility(a92, a93)
    local a94 = {
        [self.map] = { BackgroundTransparency = if a92 then 0 else 1 },
        [self.satOverlay] = { BackgroundTransparency = if a92 then 0 else 1 },
        [self.valOverlay] = { BackgroundTransparency = if a92 then 0 else 1 },
        [self.mapStroke] = { Transparency = if a92 then 0.9 else 1 },
        [self.satCursor] = { BackgroundTransparency = if a92 then 0 else 1 },
        [self.satCursorStroke] = { Transparency = if a92 then 0 else 1 },
        [self.hueBar] = { BackgroundTransparency = if a92 then 0 else 1 },
        [self.hueHandle] = { BackgroundTransparency = if a92 then 0 else 1 },
        [self.hueHandleStroke] = { Transparency = if a92 then 0 else 1 },
        [self.alphaBar] = { BackgroundTransparency = if a92 then 0 else 1 },
        [self.alphaHandle] = { BackgroundTransparency = if a92 then 0 else 1 },
        [self.alphaHandleStroke] = { Transparency = if a92 then 0 else 1 },
        [self.hexBox] = { BackgroundTransparency = if a92 then 0.9 else 1 },
        [self.hexBoxStroke] = { Transparency = if a92 then 0.85 else 1 },
        [self.hexInput] = { TextTransparency = if a92 then 0.4 else 1 },
        [self.alphaBox] = { BackgroundTransparency = if a92 then 0.9 else 1 },
        [self.alphaBoxStroke] = { Transparency = if a92 then 0.85 else 1 },
        [self.alphaInput] = { TextTransparency = if a92 then 0.4 else 1 },
    }

    for a95, a96 in a94 do
        if a93 then
            a3.tweenService:Create(a95, a26, a96):Play()
        else
            for a97, a98 in a96 do
                a95[a97] = a98
            end
        end
    end
end

function a1:_setControlsVisible(a99)
    for _, a100 in { self.map, self.hueBar, self.alphaBar, self.hexBox, self.alphaBox } do
        a100.Visible = a99
    end
end

function a1:_applyLayout()
    local a101 = self.main.AbsoluteSize.X
    local a102 = if a101 > 0 and a101 < a21 then "narrow" else "wide"
    if a102 == self._layoutMode then
        return
    end
    self._layoutMode = a102

    local l = a22[a102]
    self._openHeight = l.height
    self._previewOpenPos = l.previewPos
    self._previewOpenSize = l.previewSize
    self.hexBox.Position = l.hexPos
    self.hexBox.Size = l.hexSize
    self.alphaBox.Position = l.alphaFieldPos
    self.alphaBox.Size = l.alphaFieldSize

    if self._isOpen then
        a3.tweenService:Create(self.main, a25, { Size = UDim2.new(1, -20, 0, self._openHeight) }):Play()
        a3.tweenService
            :Create(self.preview, a25, { Position = self._previewOpenPos, Size = self._previewOpenSize })
            :Play()
    end
end

function a1:Set(a103, a104)
    self.value = a45(a103, self.value)
    self.hue, self.sat, self.val = self.value:ToHSV()
        self:_render(if self._isOpen then "animate" else "instant")

    if not a104 then
        self:_fireCallback()
        self.window:_persist(self)
    end
end

function a1:SetAlpha(a105, a106)
    self.alpha = a30(if type(a105) == "number" then a105 else self.alpha)
    self:_render(if self._isOpen then "animate" else "instant")

    if not a106 then
        self:_fireCallback()
        self.window:_persist(self)
    end
end

function a1:_serialize()
    return self.value:ToHex() .. string.format("%02x", math.clamp(math.round((self.alpha or 1) * 255), 0, 255))
end

function a1:_deserialize(a107)
    local a108 = tostring(a107)
    local a109 = nil
    if #a108 >= 8 then
        a109 = (tonumber(a108:sub(7, 8), 16) or 255) / 255
        a108 = a108:sub(1, 6)
    end

            local ok, a110 = pcall(Color3.fromHex, a108)
    if not ok then
        return
    end
    if a109 then
        self:SetAlpha(a109, true)
    end
    self:Set(a110)
end

function a1:_setShown(a111, a112)
    local w = self.window
    if a111 then
        w:_revealCommon(self, a112)
                w:_reveal(self.preview, { BackgroundTransparency = 1 - self.alpha }, a112)
        w:_reveal(self.previewShadow, { Transparency = 1 - 0.4 * self.alpha }, a112)
    else
        w:_hideCommon(self, a112)
        w:_reveal(self.preview, { BackgroundTransparency = 1 }, a112)
        w:_reveal(self.previewShadow, { Transparency = 1 }, a112)
                if self._isOpen then
            self:_close()
        end
    end
end

a5(a1)
a6(a1)

return a1
