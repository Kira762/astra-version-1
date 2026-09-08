local sidebar = require(script.Parent.Parent.components.sidebar)
local search = require(script.Parent.Parent.components.search)

local Topbar = {}

function Topbar.Build(window, layout)
    window.tabList = window:Create("ScrollingFrame", {
        Name = "Tabs",
        Active = true,
        Size = UDim2.new(1, 0, 0, layout.tabStripHeight),
        Position = UDim2.new(0.5, 0, 0, layout.tabStripTop),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        ScrollBarImageTransparency = 1,
        ScrollingDirection = Enum.ScrollingDirection.X,
        Parent = window.main,
    })
    window.tabListLayout = window:Create("UIListLayout", {
        Padding = UDim.new(0, 7),
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = window.tabList,
    })
    window:Create("UIPadding", {
        PaddingLeft = UDim.new(0, 22),
        PaddingRight = UDim.new(0, 10),
        Parent = window.tabList,
    })
    sidebar.buildProfile(window, layout)
    sidebar.reflowProfile(window)
end

function Topbar.ApplyWidth(window)
    search.railWidth(window, 0)
    window.elements.Size = UDim2.new(1, 0, 1, -window.layout.chromeHeight)
    window.bottomFade.Size = UDim2.new(1, 0, window.layout.fadeSize.Y.Scale, window.layout.fadeSize.Y.Offset)
    sidebar.reflowProfile(window)
end

return Topbar
