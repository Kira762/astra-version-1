local a1 = {}
a1.__index = a1
a1.__type = "Tab"

local a2 = script.Parent.Parent.utilities

local a3 = require(a2.Parent.core.state)
local a4 = require(a2.ordering)
local a5 = require(a2.HapticEngine)
local a6 = require(script.Parent.Parent.components.search)
local a7 = require(script.Parent.Parent.components.tabSelector)

local function a8(window, a9)
    for _, element in a9 do
        if element.__type == "Group" then
            a8(window, element.elements)
        else
            window:_unregisterControl(element)
        end

                if element.connections then
            for _, a10 in element.connections do
                window:Disconnect(a10)
            end
            element.connections = nil
        end

                if element._dragConnection then
            element._dragConnection:Disconnect()
            element._dragConnection = nil
        end
                        if window._recordingKeybind == element then
            window._recordingKeybind = nil
        end
        if element._outsideClickConn then
            window:Disconnect(element._outsideClickConn)
            element._outsideClickConn = nil
        end
    end
end

local a11 = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local a12 = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local function a13(a14)
    if a14.mode == "sidebar" then
        return UDim2.new(1, -35, 1, 0)
    end
    return UDim2.new(1, -20, 1, 0)
end

local function a15(a16)
    if a16.mode == "sidebar" then
        return UDim2.new(0, 35, 0, 0)
    end
    return UDim2.new(0, 0, 0, 0)
end

function a1.new(window, a17)
    a17 = if typeof(a17) == "table" then a17 else {}

    local self = setmetatable({
        window = assert(window, "Missing argument #1 (Window expected)"),
        name = a17.name or a17.Name,
        icon = window:ResolveIcon(a17.icon or a17.Icon),
        neglectSelector = a17.neglectSelector or a17.NeglectSelector or false,
        customOrder = a17.customOrder or a17.CustomOrder or 0,
                forgetState = a17.forgetState or a17.ForgetState or false,

        elements = {},
        connections = {},     }, a1)

        assert(self.name or self.icon, "A tab needs a name or an icon.")

        if not self.neglectSelector then
        a7.build(self, self.window.layout)
    end

        self.tabPage = self.window:Create("ScrollingFrame", {
        Name = self.name,
        Size = a13(self.window.layout),
        Position = a15(self.window.layout),
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.Y,

        LayoutOrder = self.customOrder or 0,

        Parent = self.window.elements,
    })

    self.tabPageLayout = self.window:Create("UIListLayout", {
        Padding = UDim.new(0, 7),
        FillDirection = Enum.FillDirection.Vertical,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,

        Parent = self.tabPage,
    })

    self.window:Create("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 33),

        Parent = self.tabPage,
    })

    self:_bindSelector()

    return self
end

function a1:_bindSelector()
    if self.neglectSelector or not self.topbarItemInteract then
        return
    end
    table.insert(self.connections, self.window:Connect(self.topbarItemInteract.MouseButton1Click, function()
        a5.click()
        self:Select()
    end))
    table.insert(self.connections, self.window:Connect(self.topbarItemInteract.MouseEnter, function()
        if not self.window:_interactive() then
            return
        end
        if self.window.selectedTab ~= self then
            self:_applyVisual("hover", a12)
            self:_spinGradients()
        end
    end))
    table.insert(self.connections, self.window:Connect(self.topbarItemInteract.MouseLeave, function()
        if self.window.selectedTab ~= self then
            self:_applyVisual("unselected", a12)
        end
    end))
end

function a1:_rebuildSelector()
    if self.neglectSelector then
        return
    end
    for _, a18 in self.connections do
        self.window:Disconnect(a18)
    end
    table.clear(self.connections)
    if self.topbarItem then
        self.window:DestroySubtree(self.topbarItem)
    end
    a7.build(self, self.window.layout)
    self:_bindSelector()
end

function a1:_applyVisual(a19, a20)
    if self.neglectSelector or not self.topbarItem then
        return
    end

    local a21 = a7.states[self.window.layout.mode][a19]
    if not a21 then
        return
    end

    a7.applyVisual(self, a21, a20)
end

function a1:_spinGradients()
    if self.neglectSelector then
        return
    end

    local a22 = TweenInfo.new(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    for _, a23 in { self.topbarItemGradient, self.topbarItemStrokeGradient } do
        a23.Rotation = 90 - 360         a3.tweenService:Create(a23, a22, { Rotation = 90 }):Play()
    end
end

function a1:Select(a24)
            if self.window._searching then
        a6.close(self.window, { showTabs = true, jumpTo = false })
    end

    self.window.selectedTab = self
    if self.window._applySettingsLayout then
        self.window:_applySettingsLayout(self == self.window.rfSettings)
    end
    self.window:_jumpTo(self.tabPage)

                    local a25 = a24 or not self.window:_interactive()

    if not self.neglectSelector and not a25 then
        self:_applyVisual("selected", a11)
    end

    for _, tab in self.window.tabs do
        if tab ~= self.window.selectedTab then
            tab:Deselect(a25)
        end
    end

    if self ~= self.window.rfSettings and self.window.settingsAction and not a25 then
        a3.tweenService
            :Create(
                self.window.settingsAction.iconLabel,
                TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                { ImageTransparency = 0.6 }
            )
            :Play()
    end
end

function a1:Deselect(a26)
    if not self.neglectSelector and not a26 then
        self:_applyVisual("unselected", a11)
    end
end

function a1:_register(element)
    table.insert(self.elements, element)
    a4(element, #self.elements * 10)
    self.window:_restoreLate(element)

    if not self.window.hidden then
        element:_setShown(true, true)
    end

    return element
end

function a1:CreateButton(a27)
    return self:_register(require(script.Parent.button).new(self, a27))
end

function a1:CreateToggle(a28)
    return self:_register(require(script.Parent.toggle).new(self, a28))
end

function a1:CreateSwitch(a29)
    return self:CreateToggle(a29)
end

function a1:CreateSection(a30)
    return self:_register(require(script.Parent.section).new(self, a30))
end

function a1:CreateText(a31)
    return self:_register(require(script.Parent.text).new(self, a31))
end

function a1:CreateDivider(a32)
    return self:_register(require(script.Parent.divider).new(self, a32))
end

function a1:CreateProgress(a33)
    return self:_register(require(script.Parent.progress).new(self, a33))
end

function a1:CreateConsole(a34)
    return self:_register(require(script.Parent.console).new(self, a34))
end

function a1:CreateStat(a35)
    return self:_register(require(script.Parent.stat).new(self, a35))
end

function a1:CreateSlider(a36)
    return self:_register(require(script.Parent.slider).new(self, a36))
end

function a1:CreateDropdown(a37)
    return self:_register(require(script.Parent.dropdown).new(self, a37))
end

function a1:CreateInput(a38)
    return self:_register(require(script.Parent.input).new(self, a38))
end

function a1:CreateKeybind(a39)
    return self:_register(require(script.Parent.keybind).new(self, a39))
end

function a1:CreateColorPicker(a40)
    return self:_register(require(script.Parent.colorpicker).new(self, a40))
end

function a1:CreateGroup(a41)
    return self:_register(require(script.Parent.group).new(self, a41))
end

function a1:_moveElement(element, a42)
    local a43 = table.find(self.elements, element)
    if not a43 then
        return
    end
    table.remove(self.elements, a43)
    a42 = math.clamp(a42, 1, #self.elements + 1)
    table.insert(self.elements, a42, element)
    for i, el in self.elements do
        a4(el, i * 10)
    end
end

function a1:Remove()
    local window = self.window

            if window._searching then
        a6.close(window, { showTabs = true, jumpTo = window.selectedTab and window.selectedTab.tabPage })
    end

    local a44 = table.find(window.tabs, self)
    if a44 then
        table.remove(window.tabs, a44)
    end

        if window.selectedTab == self then
        window.selectedTab = nil
        for _, tab in ipairs(window.tabs) do
            if not tab.neglectSelector then
                tab:Select()
                break
            end
        end
    end

            a8(window, self.elements)

            for _, a45 in self.connections do
        window:Disconnect(a45)
    end
    self.connections = {}

    if self.topbarItem then
        window:DestroySubtree(self.topbarItem)
    end
    if self.tabPage then
        window:DestroySubtree(self.tabPage)
    end
    self.topbarItem = nil
    self.tabPage = nil
    self.elements = {}
end

return a1
