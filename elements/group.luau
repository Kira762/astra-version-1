local a1 = {}
a1.__index = a1
a1.__type = "Group"

local a2 = require(script.Parent.Parent.utilities.moveable)
local a3 = require(script.Parent.Parent.utilities.log)
local a4 = require(script.Parent.Parent.utilities.ordering)

local a5 = 8

local a6 = {
    button = true,
    toggle = true,
    stat = true,
    slider = true,
}

function a1.new(tab, a7)
    a7 = if typeof(a7) == "table" then a7 else {}

    local a8 = string.lower(a7.direction or a7.Direction or "row")
    local a9 = a8 == "column" or a8 == "vertical"
    local a10 = not a9
    local a11 = if a10 then Enum.FillDirection.Horizontal else Enum.FillDirection.Vertical

    local self = setmetatable({
        tab = assert(tab, "Missing argument #1 (Tab expected)"),         window = tab.window,
        direction = a11,
        compact = a10,         forgetState = tab.forgetState,         elements = {},
    }, a1)

        local a12 = tab.direction == Enum.FillDirection.Horizontal

    self.main = self.window:Create("Frame", {
        Name = "Group",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
                        Size = if a10 then UDim2.new(1, -20, 0, 0) else UDim2.new(1, 0, 0, 0),

        Parent = self.tab.tabPage,
    })

    if a12 then
                self.main.Size = UDim2.new(0, 0, 0, 0)
        self.window:Create("UIFlexItem", {
            FlexMode = Enum.UIFlexMode.Fill,
            Parent = self.main,
        })
    end

        self.tabPage = self.main

    self.layout = self.window:Create("UIListLayout", {
        FillDirection = a11,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, a5),
        VerticalAlignment = if a10 then Enum.VerticalAlignment.Center else Enum.VerticalAlignment.Top,
        HorizontalAlignment = if a10 then Enum.HorizontalAlignment.Left else Enum.HorizontalAlignment.Center,

        Parent = self.main,
    })

    return self
end

function a1:_add(a13, a14)
    if self.compact and not a6[a13] then
        a3.warn(
            `Astra: a row only holds compact elements (button/toggle/stat/slider), ignoring '{a13}'. Use a column for it.`
        )
        return nil
    end

    local element = require(script.Parent[a13]).new(self, a14)
    table.insert(self.elements, element)
    a4(element, #self.elements * 10)
    self.window:_restoreLate(element)

    if self.compact then
        self:_wrapChild(element)
    end
    self:_reflowRow()
            if not self.window.hidden then
        element:_setShown(true, true)
    end

    return element
end

function a1:_reflowRow()
    if self.direction ~= Enum.FillDirection.Horizontal then
        return
    end

    local a15 = #self.elements > 0
    for _, element in self.elements do
        if element.__type ~= "Group" then
            a15 = false
            break
        end
    end

    self.layout.Padding = if a15 then UDim.new(0, -10) else UDim.new(0, a5)
end

function a1:_wrapChild(element)
    self.layout.Wraps = true
    self.layout.HorizontalFlex = Enum.UIFlexAlignment.Fill

            element._widthManaged = true

    local a16 = if element._minWidth then element:_minWidth() else 0
    if a16 > 0 then
        element.main.AutomaticSize = Enum.AutomaticSize.None
        element.main.Size = UDim2.new(0, a16, element.main.Size.Y.Scale, element.main.Size.Y.Offset)
    end
end

function a1:CreateButton(a17)
    return self:_add("button", a17)
end
function a1:CreateToggle(a18)
    return self:_add("toggle", a18)
end
function a1:CreateSwitch(a19)
    return self:_add("toggle", a19)
end
function a1:CreateStat(a20)
    return self:_add("stat", a20)
end
function a1:CreateSlider(a21)
    return self:_add("slider", a21)
end
function a1:CreateDropdown(a22)
    return self:_add("dropdown", a22)
end
function a1:CreateSection(a23)
    return self:_add("section", a23)
end
function a1:CreateText(a24)
    return self:_add("text", a24)
end
function a1:CreateDivider(a25)
    return self:_add("divider", a25)
end

function a1:_addGroup(a26)
    a26 = if typeof(a26) == "table" then table.clone(a26) else {}

        if self.direction == Enum.FillDirection.Horizontal then
                        self.layout.VerticalAlignment = Enum.VerticalAlignment.Top
                        if self.tab.direction ~= Enum.FillDirection.Horizontal then
            self.main.Size = UDim2.new(1, 0, 0, 0)
        end
    end

    local a27 = a1.new(self, a26)
    table.insert(self.elements, a27)
    a27.main.LayoutOrder = #self.elements * 10
    self:_reflowRow()
    return a27
end

function a1:CreateGroup(a28)
    return self:_addGroup(a28)
end

function a1:_moveElement(element, a29)
    local a30 = table.find(self.elements, element)
    if not a30 then
        return
    end
    table.remove(self.elements, a30)
    a29 = math.clamp(a29, 1, #self.elements + 1)
    table.insert(self.elements, a29, element)
    for i, el in self.elements do
        a4(el, i * 10)
    end
end

function a1:_setShown(a31, a32)
    for _, el in self.elements do
        el:_setShown(a31, a32)
    end
end

function a1:_refreshTheme()
    for _, el in self.elements do
        if el._refreshTheme then
            el:_refreshTheme()
        end
    end
end

a2(a1)

return a1
