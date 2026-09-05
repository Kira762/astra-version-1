local a1 = {}
a1.__index = a1
a1.__type = "Button"

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
        name = a10.name or a10.Name or "Button",
        icon = tab.window:ResolveIcon(a10.icon or a10.Icon),
        description = a10.description or a10.Description,
        compact = tab.compact or false,
        callback = a10.callback or a10.Callback or function() end,
    }, a1)

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

function a1:_runCallback()
    self.window:_runGuarded(self, self.callback)
end

function a1:_buildFull()
    self.main = self.window:Create("Frame", {
        Size = UDim2.new(1, -20, 0, 43),
        BorderSizePixel = 0,
        Name = self.name,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),

                BackgroundTransparency = 1,
        Parent = self.tab.tabPage,
    }, { BackgroundTransparency = "ElementTransparency" })

    self.stroke = self.window:StyleElementBody(self.main)
    self.hoverOverlay = self.window:CreateHoverOverlay(self.main)

    self.container = self.window:Create("Frame", {
        BorderSizePixel = 0,

        Parent = self.main,
        Size = UDim2.new(0, 170, 0, 16),
        Position = UDim2.new(0, 20, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
    })

    self.containerLayout = self.window:Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,

        Parent = self.container,
    })

    if self.icon then
        self.iconLabel = self.window:Create("ImageLabel", {
            Image = self.icon,
            Size = UDim2.fromOffset(16, 16),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,

                        ImageTransparency = 1,
            Parent = self.container,
        }, { ImageColor3 = "ContentColor" })
    end

    self.title = self.window:Create("TextLabel", {
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

    self.interact = self.window:Create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        TextTransparency = 1,

        Parent = self.main,
    })

    self.window:_wireElementHover(self)

        self.window:ConnectFor(self, self.interact.MouseButton1Click, function()
        a8.click()
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
                { Size = UDim2.new(1, -26, 0, 43) }
            )
            :Play()

        self:_runCallback()

        task.wait(0.11)

        if self.window.unloaded then
            return
        end

        a3.tweenService
            :Create(
                self.main,
                TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
                { Size = UDim2.new(1, -20, 0, 43) }
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

    self.main, self.stroke, self.interact = window:_buildCompactRow(self.tab, self.name)
    self.hoverOverlay = self.interact

    window:Create("UIPadding", {
        PaddingLeft = UDim.new(0, 16),
        PaddingRight = UDim.new(0, 16),

        Parent = self.interact,
    })

    window:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDim.new(0, 6),

        Parent = self.interact,
    })

    if self.icon then
        self.iconLabel = window:Create("ImageLabel", {
            Image = self.icon,
            Size = UDim2.fromOffset(16, 16),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            LayoutOrder = 0,

            ImageTransparency = 1,
            Parent = self.interact,
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
        Parent = self.interact,
    }, { TextColor3 = "ContentColor", FontFace = "Font" })

        window:Create("UIFlexItem", {
        FlexMode = Enum.UIFlexMode.Shrink,
        Parent = self.title,
    })

    self.window:_wireElementHover(self)

        self.window:ConnectFor(self, self.interact.MouseButton1Click, function()
        a8.click()
        a3.tweenService
            :Create(
                self.stroke,
                a9,
                { Transparency = 1 }
            )
            :Play()

        self:_runCallback()

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

function a1:_setShown(a11, a12)
    if a11 then
        self.window:_revealCommon(self, a12)
    else
        self.window:_hideCommon(self, a12)
    end
end

function a1:_minWidth()
    local w = 32     if self.icon then
        w += 22     end
        w += a4.textWidth(self.window.theme.Font, 16, a7.resolve(self.name))
    return w
end

a5(a1)
a6(a1)

return a1
