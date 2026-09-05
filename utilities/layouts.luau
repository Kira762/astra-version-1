local a1 = {}

local a2 = 64

local a3 = a2 - 1
local a4 = 38
local a5 = 3

export type Mode = "top" | "sidebar"

export type Layout = {
    mode: Mode,

        topbarHeight: number,
    chromeHeight: number,

            pageDirection: Enum.FillDirection,

            fadeSize: UDim2,
    fadeTransparency: NumberSequence,
    fadeCorners: { string }?,

        tabStripTop: number?,
    tabStripHeight: number?,

        railWidth: number?,
    railCollapsedWidth: number?,
    railCollapseBelow: number?,
    rowHeight: number?,
    rowCornerRadius: number?,
    rowSpacing: number?,
    railPadding: number?,
    rowInset: number?,
    rowPadding: number?,
    rowContentSpacing: number?,
    rowIconSize: number?,
    footerHeight: number?,
    avatarSize: number?,
    cardTransparency: number?,
    cardStrokeRotation: number?,
    cardStrokeTransparency: NumberSequence?,
    cardCorners: { string }?,
    forceCollapsed: boolean?,
}

a1.top = {
    mode = "top" :: Mode,

    topbarHeight = a2,
    chromeHeight = a3 + a4 + a5,

    tabStripTop = a3,
    tabStripHeight = a4,

    profileHeight = 48,

    pageDirection = Enum.FillDirection.Horizontal,

            fadeSize = UDim2.new(1, 0, -0.093, 100),
    fadeTransparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.4414, 0),
        NumberSequenceKeypoint.new(0.7007, 0.631),
        NumberSequenceKeypoint.new(1, 1),
    }),
} :: Layout

a1.sidebar = {
    mode = "sidebar" :: Mode,

    topbarHeight = a2,
    chromeHeight = a2,

            railWidth = 219,
            railCollapsedWidth = 64,
    railCollapseBelow = 589,

    rowHeight = 38,
    rowCornerRadius = 14,
    rowSpacing = 4,
        railPadding = 17,
    rowInset = 15,
    rowPadding = 10,
    rowContentSpacing = 6,
    rowIconSize = 20,

    footerHeight = 60,
    avatarSize = 34,

    pageDirection = Enum.FillDirection.Vertical,

    cardTransparency = 0.98,
    cardStrokeRotation = 55,
            cardCorners = { "TopLeftRadius", "BottomRightRadius" },
    cardStrokeTransparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.9),
        NumberSequenceKeypoint.new(0.128, 0.95),
        NumberSequenceKeypoint.new(0.414, 0.985),
        NumberSequenceKeypoint.new(1, 1),
    }),

    fadeSize = UDim2.new(1, 0, 0, 55),
    fadeTransparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.377, 0),
        NumberSequenceKeypoint.new(1, 1),
    }),
        fadeCorners = { "BottomLeftRadius", "BottomRightRadius" },
} :: Layout

local a6 = table.clone(a1.sidebar)
a6.forceCollapsed = true

function a1.get(a7: unknown): Layout?
    if a7 == "sidebar" then
        return a1.sidebar
    elseif a7 == "collapsedSidebar" then
        return a6
    elseif a7 == "top" then
        return a1.top
    end
    return nil
end

function a1.railWidthFor(a8: Layout, a9: number): number
    if a8.mode ~= "sidebar" then
        return 0
    end
    local a10 = a8.railWidth :: number
    if a8.forceCollapsed or a9 < (a8.railCollapseBelow :: number) then
        return a8.railCollapsedWidth :: number
    end
    return a10
end

return a1
