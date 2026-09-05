local a1 = {}
a1.__index = a1
a1.__type = "Descriptor"

local a2 = require(script.Parent.Parent.utilities.locale)

function a1.new(tab, a3)
    a3 = if typeof(a3) == "table" then a3 else {}

    local self = setmetatable({
        tab = assert(tab, "Missing argument #1 (Tab expected)"),
        window = tab.window,
        description = a3.description or a3.Description or "",
    }, a1)

    self.main = self.window:Create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -30, 0, 0),

        Parent = self.tab.tabPage,
    })

    self.window:Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.main,
    })

    self.titleLabel = self.window:Create("TextLabel", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        RichText = true,
        Size = UDim2.new(1, -90, 0, 0),
        Text = a2.t(self.description),
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,

                TextTransparency = 1,
        Parent = self.main,
    }, { TextColor3 = "ContentColor", FontFace = "Font" })

        self.window:Create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = 1,
        Size = UDim2.fromOffset(0, 15),
        Parent = self.main,
    })

    return self
end

function a1:Remove()
    self.main:Destroy()
end

return a1
