local a1 = {}
a1.__index = a1
a1.__type = "Section"

local a2 = require(script.Parent.Parent.utilities.moveable)
local a3 = require(script.Parent.Parent.utilities.locale)

function a1.new(tab, a4)
    a4 = if typeof(a4) == "table" then a4 else {}

    local self = setmetatable({
        tab = assert(tab, "Missing argument #1 (Tab expected)"),
        window = tab.window,
        name = a4.name or a4.Name or "Section",
        icon = tab.window:ResolveIcon(a4.icon or a4.Icon),
    }, a1)

            local a5 = if #self.tab.elements == 0 then 0 else 13

    self.main = self.window:Create("Frame", {
        Size = UDim2.new(1, -40, 0, 20 + a5),
        BorderSizePixel = 0,
        Name = self.name,
        BackgroundTransparency = 1,
        Parent = self.tab.tabPage,
    })

    if a5 > 0 then
        self.window:Create("UIPadding", {
            PaddingTop = UDim.new(0, a5),
            Parent = self.main,
        })
    end

    self.window:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Parent = self.main,
    })

    if self.icon then
        self.iconLabel = self.window:Create("ImageLabel", {
            Image = self.icon,
            Size = UDim2.fromOffset(16, 16),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,

                        ImageTransparency = 1,
            Parent = self.main,
        }, { ImageColor3 = "ContentColor" })
    end

    self.title = self.window:Create("TextLabel", {
                Text = a3.t(self.name),

        Size = UDim2.fromOffset(0, 16),
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        TextSize = 15,
        AutomaticSize = Enum.AutomaticSize.X,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        LayoutOrder = 1,

                TextTransparency = 1,
        Parent = self.main,
    }, { TextColor3 = "ContentColor", FontFace = "Font" })

    return self
end

function a1:_setShown(a6, a7)
    local w = self.window
    w:_reveal(self.title, { TextTransparency = if a6 then 0.6 else 1 }, a7)
    if self.iconLabel then
        w:_reveal(self.iconLabel, { ImageTransparency = if a6 then 0.65 else 1 }, a7)
    end
end

a2(a1)

return a1
