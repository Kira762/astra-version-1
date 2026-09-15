local state = {}
state.__index = state
state.__type = "Input"

local utilities = script.Parent.Parent.utilities

local functions = require(script.Parent.Parent.functions)
local moveable = require(utilities.moveable)
local lockable = require(utilities.lockable)
local locale = require(utilities.locale)
local description = require(script.Parent.description)
local haptic = require(utilities.HapticEngine)

-- [[Field feedback rides the shared motion service: the box follows typing
-- on the hover spec (quick, but never jumpy), focus fades the caret text on
-- the press spec, and theme refreshes cross-fade on the surface spec.]]
local motion = require(utilities.motion)
local boxSpec = "snappy"
local textSpec = "fast"

-- [[The field box is sized from the text it shows, so the recipe lives in one
-- place: measure the typed text (or the placeholder while the field is empty),
-- add the box's own horizontal breathing room, and clamp the result between a
-- floor that keeps an empty field tappable and a ceiling that keeps it from
-- pushing the title off the card. The ceiling is also responsive — see
-- `_maxWidth` — so a narrow page shrinks the widest fields instead of letting
-- them overlap the title.]]
local textSize = 15
local boxPadding = 30
local minWidth = 70
local maxWidth = 220
local boxHeight = 30
-- [[Share of the page a field may take at most. Under the ceiling on a desktop
-- page, and the binding constraint on a phone-sized one.]]
local pageWidthShare = 0.55
-- [[Gap the title row keeps clear of the box's right edge (7px inset + gutter).]]
local titleGap = 35

-- [[Numeric fields accept the calculator-style exponent form ("1.5^-3") while
-- typing, so the filter keeps the caret characters and the commit parses it.]]
local function parseNumeric(raw)
    local base, exponent = raw:match("^([%d%.%-]+)%^([%d%.%-]+)$")
    if base and exponent then
        local numericBase, numericExponent = tonumber(base), tonumber(exponent)
        if numericBase and numericExponent then
            return numericBase ^ numericExponent
        end
    end
    return tonumber(raw)
end

function state.new(tab, inputProps)
    inputProps = if typeof(inputProps) == "table" then inputProps else {}

    local self = setmetatable({
        tab = assert(tab, "Missing argument #1 (Tab expected)"),
        window = tab.window,
        name = inputProps.name or inputProps.Name or "Input",
        icon = tab.window:ResolveIcon(inputProps.icon or inputProps.Icon),
        description = inputProps.description or inputProps.Description,
        forgetState = inputProps.forgetState or inputProps.ForgetState or tab.forgetState,
        placeholder = inputProps.placeholder or inputProps.Placeholder or "",
        numeric = inputProps.numeric or inputProps.Numeric or false,
        clearOnFocus = inputProps.clearOnFocus or inputProps.ClearOnFocus or false,

        callback = inputProps.callback or inputProps.Callback or function() end,
    }, state)

    self.value =
        tostring(inputProps.value or inputProps.Value or inputProps.currentValue or inputProps.CurrentValue or "")

    self.flag = inputProps.flag
        or inputProps.Flag
        or (not self.forgetState and tab.deriveFlagFromName(self.name) or nil)
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

    -- [[The card grows for a description before the title row and the field
    -- [[box are built, so both centre in the base region instead of riding
    -- [[down onto the line.]]
    description.attach(self)

    self.container = self.window:Create("Frame", {
        Size = UDim2.new(1, -115, 0, 16),
        Position = UDim2.new(0, 20, description.center(self, 41)),
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
        Text = locale.t(self.name),
        Size = UDim2.new(1, if self.icon then -21 else 0, 0, 16),
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        LayoutOrder = 1,
        ZIndex = 5,

        TextTransparency = 1,
        Parent = self.container,
    }, { TextColor3 = "ContentColor", FontFace = "Font" })

    self.box = self.window:Create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -7, description.center(self, 41)),
        Size = UDim2.fromOffset(85, boxHeight),
        BorderSizePixel = 0,

        BackgroundTransparency = 1,
        Parent = self.main,
    }, { BackgroundColor3 = "FieldBackground" })

    self.window:Create("UICorner", {
        Parent = self.box,
    }, { CornerRadius = "ElementCornerRadius" })

    self.boxStroke = self.window:Create("UIStroke", {
        Transparency = 1,
        Parent = self.box,
    }, { Color = "SurfaceStroke" })

    self._glowIdle = 1
    self.input = self.window:Create("TextBox", {
        Text = self.value,
        PlaceholderText = locale.t(self.placeholder),
        Size = UDim2.new(1, -15, 0, 15),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        TextSize = textSize,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ClearTextOnFocus = self.clearOnFocus,

        TextTransparency = 1,
        Parent = self.box,
    }, { TextColor3 = "ContentColor", FontFace = "Font", PlaceholderColor3 = "PlaceholderColor" })

    self.window:ConnectFor(self, self.input:GetPropertyChangedSignal("Text"), function()
        if self.numeric then
            local filtered = (self.input.Text:gsub("[^%d%.%-eE%^]", ""))
            if filtered ~= self.input.Text then
                self.input.Text = filtered
                return
            end
        end
        self:_sizeBox(true)
    end)

    -- [[The placeholder on screen is the *resolved* one (Window:Create binds it
    -- [[through the locale table), so this fires both when a host retypes the
    -- [[placeholder with SetPlaceholder and when Window:SetLocale re-types it
    -- [[from the translations. Either way the empty field has to re-measure:
    -- [[a longer word in the new language needs a wider box.]]
    self.window:ConnectFor(self, self.input:GetPropertyChangedSignal("PlaceholderText"), function()
        self:_sizeBox(true)
    end)

    -- [[The width ceiling is a share of the page, so a page that changes width
    -- [[(a layout switch, a window resize, the search page) re-measures the
    -- [[field against its new room.]]
    if self.tab.tabPage then
        self.window:ConnectFor(self, self.tab.tabPage:GetPropertyChangedSignal("AbsoluteSize"), function()
            self:_sizeBox(true)
        end)
    end

    self.window:ConnectFor(self, self.input.Focused, function()
        motion.tween(self.input, { TextTransparency = 0 }, textSpec)
    end)

    self.window:ConnectFor(self, self.input.FocusLost, function()
        motion.tween(self.input, { TextTransparency = 0.6 }, textSpec)
        if self.clearOnFocus and self.input.Text == "" and self.value ~= "" then
            self.input.Text = self.value
            return
        end
        if self.input.Text == self.value then
            return
        end
        self:_commit(self.input.Text)
    end)

    self.window:_wireElementHover(self)

    self:_sizeBox(false)
    return self
end

-- [[The ceiling the field may grow to: its own hard maximum, or the page's
-- [[share when the page is narrower than that (a phone in portrait, the
-- [[collapsed sidebar). Never below the floor, so the clamp below always has
-- [[a valid min <= max even on a page that has not been laid out yet.]]
function state:_maxWidth()
    local page = self.tab and self.tab.tabPage
    local available = page and page.AbsoluteSize and page.AbsoluteSize.X or 0
    if available <= 0 then
        return maxWidth
    end
    return math.max(minWidth, math.min(maxWidth, available * pageWidthShare))
end

-- [[One recipe, every trigger: typing, SetPlaceholder, a locale switch, a theme
-- [[refresh (the font is a theme token, so a new theme can measure differently)
-- [[and a page resize all land here. `animate` grows the box on the hover spec
-- [[for user-driven changes; the first layout pass assigns it outright. Both
-- [[the box and the title row's width are pure functions of the measurement, so
-- [[an unchanged width is a no-op instead of a redundant tween.]]
function state:_sizeBox(animate)
    local input = self.input
    if not input then
        return
    end

    -- [[Empty field: size to the placeholder it shows. Typed field: size to
    -- [[what the user typed. Reads the resolved label, never the raw token.]]
    local measure = if input.Text ~= "" then input.Text else input.PlaceholderText
    local width = math.clamp(
        functions.textWidth(self.window.theme.Font, textSize, measure) + boxPadding,
        minWidth,
        self:_maxWidth()
    )
    if width == self._boxWidth then
        return
    end
    self._boxWidth = width

    self.container.Size = UDim2.new(1, -(width + titleGap), 0, 16)
    if animate then
        motion.tween(self.box, { Size = UDim2.fromOffset(width, boxHeight) }, boxSpec)
    else
        self.box.Size = UDim2.fromOffset(width, boxHeight)
    end
end

function state:_commit(rawValue, skipCallback)
    rawValue = tostring(rawValue)
    if self.numeric then
        local parsed = parseNumeric(rawValue)
        if not parsed or parsed ~= parsed or parsed == math.huge or parsed == -math.huge then
            if self.input.Text ~= self.value then
                self.input.Text = self.value
            end
            return
        end
        rawValue = tostring(parsed)
    end

    local changed = rawValue ~= self.value
    self.value = rawValue
    if self.input.Text ~= rawValue then
        self.input.Text = rawValue
    end

    if not skipCallback then
        self.window:_runGuarded(self, self.callback, rawValue)
        self.window:_persist(self)
        if changed and not self.window._loading then
            haptic.click()
            self.window:_flashResult(self, true)
        end
    end
end

function state:Set(value, skipCallback)
    self:_commit(value, skipCallback)
end

-- [[Retype the empty field's hint at runtime. Goes through the window's locale
-- [[binder, so the new placeholder is translated on the next SetLocale exactly
-- [[like the one the element was built with, and re-measures the box: the
-- [[field's width follows the placeholder while nothing is typed.]]
function state:SetPlaceholder(placeholder)
    placeholder = tostring(placeholder or "")
    self.placeholder = placeholder
    self.window:_bindLocale(self.input, "PlaceholderText", placeholder)
    self:_sizeBox(true)
end

function state:_fieldGlow()
    if not self.glow then
        self.glow = self.window:CreateGlow(self.box, "FieldGlow", 20, 1)
    end
    return self.glow
end

function state:_setShown(shown, animate)
    local window = self.window
    if shown then
        window:_revealCommon(self, animate)
        window:_reveal(self.box, { BackgroundTransparency = window.theme.FieldTransparency }, animate)
        window:_reveal(self.boxStroke, { Transparency = 0.85 }, animate)
        window:_reveal(self.input, { TextTransparency = 0.6 }, animate)
    else
        window:_hideCommon(self, animate)
        window:_reveal(self.box, { BackgroundTransparency = 1 }, animate)
        window:_reveal(self.boxStroke, { Transparency = 1 }, animate)
        window:_reveal(self.input, { TextTransparency = 1 }, animate)
    end
end

function state:_refreshTheme()
    motion.tween(
        self.box,
        { BackgroundTransparency = self.window.theme.FieldTransparency },
        "smooth"
    )
    -- [[The measuring font is a theme token: a theme switch can change how wide
    -- [[the same text measures, so the box re-measures against the new font.]]
    self:_sizeBox(true)
end

moveable(state)
lockable(state)

return state
