local a1 = {}
a1.__index = a1
a1.__type = "TabSection"

local a2 = require(script.Parent.Parent.utilities.locale)
local a3 = require(script.Parent.Parent.utilities.log)

local a4 = 20

local a5 = 6

local a6 = 3

local function a7(window)
    for _, tab in window.tabs do
        if not tab.neglectSelector then
            return true
        end
    end
    return #window.tabSections > 0
end

function a1.new(window, a8)
    a8 = if typeof(a8) == "table" then a8 else {}

    local self = setmetatable({
        window = assert(window, "Missing argument #1 (Window expected)"),
        name = a8.name or a8.Name or "Section",
        icon = window:ResolveIcon(a8.icon or a8.Icon),
    }, a1)

            if window.layout.mode ~= "sidebar" then
        if not window._warnedTabSection then
            window._warnedTabSection = true
            a3.warn("Astra: Window:CreateSection needs the sidebar layout; it does nothing on the top strip.")
        end
        self.inert = true
        return self
    end

        self.main = window:Create("Frame", {
        Name = self.name,
        Size = UDim2.new(1, -a4 * 2, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,

        Visible = false,
        Parent = window.tabList,
    })

    self.padding = window:Create("UIPadding", {
        PaddingTop = UDim.new(0, if a7(window) then a5 else 0),
        PaddingBottom = UDim.new(0, a6),

        Parent = self.main,
    })

    window:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top,

        Parent = self.main,
    })

    if self.icon then
        self.iconLabel = window:Create("ImageLabel", {
            Image = self.icon,
            Size = UDim2.fromOffset(16, 16),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            LayoutOrder = 0,

                        ImageTransparency = 1,
            Parent = self.main,
        }, { ImageColor3 = "ContentColor" })
    end

    self.title = window:Create("TextLabel", {
        Text = a2.t(self.name),

        Size = UDim2.fromOffset(0, 15),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Bottom,
        TextWrapped = true,
        LayoutOrder = 1,

                TextTransparency = 1,
        Parent = self.main,
    }, { TextColor3 = "ContentColor", FontFace = "Font" })

    return self
end

function a1:_setShown(a9, a10)
    if not self.main then
        return     end
    local w = self.window
    w:_reveal(self.title, { TextTransparency = if a9 then 0.6 else 1 }, a10)
    if self.iconLabel then
        w:_reveal(self.iconLabel, { ImageTransparency = if a9 then 0.65 else 1 }, a10)
    end
end

function a1:_setVisible(a11)
    if self.main then
        self.main.Visible = a11
    end
end

function a1:Remove()
    local a12 = table.find(self.window.tabSections, self)
    if a12 then
        table.remove(self.window.tabSections, a12)
    end
    self.window:DestroySubtree(self.main)
    self.main = nil
end

return a1
