local a1 = {}
a1.__index = a1
a1.__type = "Text"

local a2 = require(script.Parent.Parent.utilities.moveable)
local a3 = require(script.Parent.Parent.utilities.locale)

local a4 = 16
local a5 = 14

local a6 = 0.45

function a1.new(tab, a7)
    a7 = if typeof(a7) == "table" then a7 else {}

    local self = setmetatable({
        tab = assert(tab, "Missing argument #1 (Tab expected)"),
        window = tab.window,
        name = tostring(a7.name or a7.Name or ""),
        text = tostring(a7.text or a7.Text or ""),
        icon = tab.window:ResolveIcon(a7.icon or a7.Icon),
    }, a1)

            self.main = self.window:Create("Frame", {
        Size = UDim2.new(1, -20, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BorderSizePixel = 0,
        Name = if self.name ~= "" then self.name else "Text",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),

                BackgroundTransparency = 1,
        Parent = self.tab.tabPage,
    }, { BackgroundTransparency = "ElementTransparency" })

    self.stroke = self.window:StyleElementBody(self.main)

    self.window:Create("UIPadding", {
        PaddingTop = UDim.new(0, 14),
        PaddingBottom = UDim.new(0, 14),
        PaddingLeft = UDim.new(0, 20),
        PaddingRight = UDim.new(0, 20),

        Parent = self.main,
    })

    self.window:Create("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,

        Parent = self.main,
    })

        self.titleRow = self.window:Create("Frame", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        LayoutOrder = 1,

        Parent = self.main,
    })

    self.window:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Top,

        Parent = self.titleRow,
    })

    if self.icon then
        self.iconLabel = self.window:Create("ImageLabel", {
            Image = self.icon,
            Size = UDim2.fromOffset(16, 16),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,

                        ImageTransparency = 1,
            Parent = self.titleRow,
        }, { ImageColor3 = "ContentColor" })
    end

    self.title = self.window:Create("TextLabel", {
        Text = a3.t(self.name),
        Size = UDim2.new(1, if self.icon then -22 else 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        RichText = true,
        TextSize = a4,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1,

                TextTransparency = 1,
        Parent = self.titleRow,
    }, { TextColor3 = "TitlingColor", FontFace = "Font" })

    self.body = self.window:Create("TextLabel", {
        Text = a3.t(self.text),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        RichText = true,
        TextSize = a5,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 2,

                TextTransparency = 1,
        Parent = self.main,
    }, { TextColor3 = "ContentColor", FontFace = "Font" })

    self:_applyPresence()

    return self
end

function a1:_applyPresence()
    self.titleRow.Visible = self.name ~= "" or self.icon ~= nil
    self.body.Visible = self.text ~= ""
end

function a1:Set(a8)
    self.text = tostring(a8)
    self.window:_bindLocale(self.body, "Text", self.text)
    self:_applyPresence()
end

function a1:SetTitle(a9)
    self.name = tostring(a9)
    self.window:_bindLocale(self.title, "Text", self.name)
    self:_applyPresence()
end

function a1:_setShown(a10, a11)
        if a10 then
        self.window:_revealCommon(self, a11)
    else
        self.window:_hideCommon(self, a11)
    end

    self.window:_reveal(self.body, { TextTransparency = if a10 then a6 else 1 }, a11)
end

a2(a1)

return a1
