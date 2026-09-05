local a1 = script.Parent.Parent.utilities
local a2 = require(a1.Parent.core.state)
local a3 = require(script.Parent.Parent.functions)
local a4 = require(a1.locale)

local a5 = {}

local function a6(a7: string?): string
    if type(a7) ~= "string" or a7 == "" then
        return "?"
    end
    local a8 = utf8.offset(a7, 2)
    local a9 = if a8 then string.sub(a7, 1, a8 - 1) else a7
    return string.upper(a9)
end

a5.states = {
    top = {
        selected = { background = 0, stroke = 0, content = 0 },
        hover = { background = 0.4, stroke = 0.3, content = 0.3 },
        unselected = { background = 0.8, stroke = 0.65, content = 0.5 },
        hidden = { background = 1, stroke = 1, content = 1 },
    },
            sidebar = {
        selected = { background = 0.4, stroke = 0.5, content = 0, shadow = 0.8 },
        hover = { background = 0.7, stroke = 0.8, content = 0.3, shadow = 1 },
        unselected = { background = 1, stroke = 1, content = 0.5, shadow = 1 },
        hidden = { background = 1, stroke = 1, content = 1, shadow = 1 },
    },
}

local function a10(tab, a11, a12)
    tab.topbarItemGradient = tab.window:Create("UIGradient", {
        Rotation = 90,

        Parent = a11,
    }, { Color = { "TabBackground", a3.toColorSequence } })

    tab.topbarItemStrokeGradient = tab.window:Create("UIGradient", {
        Rotation = 90,

        Parent = a12,
    }, { Color = { "TabStroke", a3.toColorSequence } })
end

local function a13(tab, a14, a15)
            if a15 and not tab.icon then
        tab.topbarItemInitial = tab.window:Create("TextLabel", {
            Text = a6(tab.name),

            Size = UDim2.fromOffset(a14, a14),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            TextSize = a14 - 4,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            Visible = false,

                        TextTransparency = 1,
            Parent = tab.topbarItemContainer,
        }, { TextColor3 = "TabColor", FontFace = "Font" })
    end

    if tab.icon then
        tab.topbarItemIcon = tab.window:Create("ImageLabel", {
                                                Image = tab.icon,

            Size = UDim2.fromOffset(a14, a14),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,

                        ImageTransparency = 1,
            Parent = tab.topbarItemContainer,
        }, { ImageColor3 = "TabColor" })
    end

    if tab.name then
        tab.topbarItemTitle = tab.window:Create("TextLabel", {
                        Text = a4.t(tab.name),
            Size = UDim2.fromOffset(0, 16),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            TextSize = 16,
            AutomaticSize = Enum.AutomaticSize.XY,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            LayoutOrder = 1,

                        TextTransparency = 1,
            Parent = tab.topbarItemContainer,
        }, { TextColor3 = "TabColor", FontFace = "Font" })
    end
end

local function a16(tab)
    tab.topbarItem = tab.window:Create("Frame", {
        Name = tab.name,
        Size = UDim2.fromOffset(0, 34),         AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,

                BackgroundTransparency = 1,         Visible = false,
        LayoutOrder = tab.customOrder or 0,

        Parent = tab.window.tabList,
    })

    tab.topbarItemInteract = tab.window:Create("TextButton", {
        Active = false,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        BorderSizePixel = 0,
        Text = "",
        TextTransparency = 1,

        Parent = tab.topbarItem,
    })

    tab.window:Create("UICorner", {
        Parent = tab.topbarItem,
    }, { CornerRadius = "PillCornerRadius" })

    tab.topbarItemStroke = tab.window:Create("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Color3.fromRGB(255, 255, 255),

                Transparency = 1,
        Parent = tab.topbarItem,
    })

    a10(tab, tab.topbarItem, tab.topbarItemStroke)

    tab.topbarItemContainer = tab.window:Create("Frame", {
        Size = UDim2.fromOffset(0, 34),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,

        Parent = tab.topbarItem,
    })

    tab.window:Create("UIPadding", {
        PaddingLeft = UDim.new(0, 13),
        PaddingRight = UDim.new(0, 14),

        Parent = tab.topbarItemContainer,
    })

    tab.topbarItemLayout = tab.window:Create("UIListLayout", {
        Padding = UDim.new(0, 6),
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,

        Parent = tab.topbarItemContainer,
    })

    a13(tab, 16, false)
end

local function a17(tab, a18)
    tab.topbarItem = tab.window:Create("Frame", {
        Name = tab.name,
        Size = UDim2.new(1, -a18.rowInset * 2, 0, a18.rowHeight),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,

                BackgroundTransparency = 1,         Visible = false,
        LayoutOrder = tab.customOrder or 0,

        Parent = tab.window.tabList,
    })

    tab.topbarItemInteract = tab.window:Create("TextButton", {
        Active = false,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        BorderSizePixel = 0,
        Text = "",
        TextTransparency = 1,

        Parent = tab.topbarItem,
    })

    tab.window:Create("UICorner", {
        CornerRadius = UDim.new(0, a18.rowCornerRadius),

        Parent = tab.topbarItem,
    })

    tab.topbarItemStroke = tab.window:Create("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Color3.fromRGB(255, 255, 255),

                Transparency = 1,
        Parent = tab.topbarItem,
    })

    a10(tab, tab.topbarItem, tab.topbarItemStroke)

                tab.topbarItemShadow = tab.window:Create("UIShadow", {
        BlurRadius = UDim.new(0, 20),
        Color = Color3.fromRGB(255, 255, 255),
        Offset = UDim2.new(0, 0, 0, -15),
        Spread = UDim2.new(0, 10, 0, -30),
        ZIndex = -1,

                Transparency = 1,
        Parent = tab.topbarItem,
    })

    tab.topbarItemContainer = tab.window:Create("Frame", {
        Size = UDim2.new(1, -a18.rowPadding, 0, 24),
        Position = UDim2.new(0, a18.rowPadding, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,

        Parent = tab.topbarItem,
    })

    tab.topbarItemLayout = tab.window:Create("UIListLayout", {
        Padding = UDim.new(0, a18.rowContentSpacing),
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,

        Parent = tab.topbarItemContainer,
    })

    a13(tab, a18.rowIconSize, true)
end

function a5.build(tab, a19)
    if a19.mode == "sidebar" then
        a17(tab, a19)
    else
        a16(tab)
    end
end

function a5.setRowCollapsed(tab, a20, a21)
    if a21.mode ~= "sidebar" or not tab.topbarItem then
        return
    end

    if tab.topbarItemTitle then
        tab.topbarItemTitle.Visible = not a20
    end
        if tab.topbarItemInitial then
        tab.topbarItemInitial.Visible = a20
    end
    local a22 = if a20 then 0 else a21.rowPadding
    tab.topbarItemContainer.Size = UDim2.new(1, -a22, 0, 24)
    tab.topbarItemContainer.Position = UDim2.new(0, a22, 0.5, 0)
    tab.topbarItemLayout.HorizontalAlignment = if a20
        then Enum.HorizontalAlignment.Center
        else Enum.HorizontalAlignment.Left
end

function a5.applyVisual(tab, a23, a24)
    local a25 = {
        [tab.topbarItem] = { BackgroundTransparency = a23.background },
        [tab.topbarItemStroke] = { Transparency = a23.stroke },
    }

    if tab.topbarItemIcon then
        a25[tab.topbarItemIcon] = { ImageTransparency = a23.content }
    end
    if tab.topbarItemTitle then
        a25[tab.topbarItemTitle] = { TextTransparency = a23.content }
    end
    if tab.topbarItemInitial then
        a25[tab.topbarItemInitial] = { TextTransparency = a23.content }
    end
    if tab.topbarItemShadow and a23.shadow then
        a25[tab.topbarItemShadow] = { Transparency = a23.shadow }
    end

    for a26, a27 in a25 do
        if a24 then
            a2.tweenService:Create(a26, a24, a27):Play()
        else
            for a28, a29 in a27 do
                a26[a28] = a29
            end
        end
    end
end

return a5
