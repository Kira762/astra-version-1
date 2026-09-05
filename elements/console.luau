local a1 = {}
a1.__index = a1
a1.__type = "Console"

local a2 = script.Parent.Parent.utilities

local a3 = require(a2.moveable)
local a4 = require(a2.locale)

local a5 = 120
local a6 = 48
local a7 = 24 local a8 = 17
local a9 = 12 local a10 = 12
local a11 = 1.25
local a12 = 200

local a13 = Font.fromEnum(Enum.Font.Code)

function a1.new(tab, a14)
    a14 = if typeof(a14) == "table" then a14 else {}

    local self = setmetatable({
        tab = assert(tab, "Missing argument #1 (Tab expected)"),
        window = tab.window,
        name = a14.name or a14.Name,
        description = a14.description or a14.Description,

        height = math.max(tonumber(a14.height or a14.Height) or a5, a6),
                follow = a14.follow or a14.Follow or false,
        maxLines = math.max(tonumber(a14.maxLines or a14.MaxLines) or a12, 1),

        lines = {},
                                lineLabels = {},
        head = 1,         nextOrder = 1,
        textDirty = true,
    }, a1)

    self:_build()
    self:_setLines(a14.text or a14.Text or "")

    if self.description then
        self.descriptor = require(script.Parent.descriptor).new(self.tab, { description = self.description })
    end

    return self
end

function a1:Get(): string
    if self.textDirty then
        self.text = table.concat(self.lines, "\n")
        self.textDirty = false
    end
    return self.text
end

function a1:_setLines(a15)
    a15 = if type(a15) == "string" then a15 else tostring(a15)

    table.clear(self.lines)
    if a15 ~= "" then
        for a16 in string.gmatch(a15 .. "\n", "([^\n]*)\n") do
            table.insert(self.lines, a16)
        end
    end
    self:_trim()
    self:_flush()
end

function a1:_trim()
    local a17 = #self.lines - self.maxLines
    if a17 <= 0 then
        return
    end
    table.move(self.lines, a17 + 1, #self.lines, 1)
    for a18 = #self.lines, #self.lines - a17 + 1, -1 do
        self.lines[a18] = nil
    end
end

function a1:_makeLabel()
    return self.window:Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        FontFace = a13,
        TextSize = a10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        LineHeight = a11,
        RichText = false,
                TextTransparency = self._textTransparency or 1,

        Parent = self.scroll,
    }, { TextColor3 = "ContentColor" })
end

local function a19(a20: string): string
    return if a20 == "" then " " else a20
end

function a1:_flush()
    self.textDirty = true

    for a21, a22 in self.lines do
        local a23 = self.lineLabels[a21]
        if not a23 then
            a23 = self:_makeLabel()
            self.lineLabels[a21] = a23
        end
        a23.LayoutOrder = a21
        a23.Text = a19(a22)
        a23.Visible = true
    end

    for a24 = #self.lines + 1, #self.lineLabels do
        self.lineLabels[a24].Visible = false
    end

    self.head = 1
    self.nextOrder = #self.lines + 1
    self:_follow()
end

function a1:_pushLine(a25: string)
    self.textDirty = true

    if #self.lines < self.maxLines then
        table.insert(self.lines, a25)
        local a26 = #self.lines
        local a27 = self.lineLabels[a26]
        if not a27 then
            a27 = self:_makeLabel()
            self.lineLabels[a26] = a27
        end
        a27.LayoutOrder = self.nextOrder
        a27.Text = a19(a25)
        a27.Visible = true
        self.nextOrder += 1
        return
    end

            table.move(self.lines, 2, #self.lines, 1)
    self.lines[#self.lines] = a25

    local a28 = self.lineLabels[self.head]
    a28.LayoutOrder = self.nextOrder
    a28.Text = a19(a25)
    a28.Visible = true

    self.nextOrder += 1
    self.head = (self.head % #self.lineLabels) + 1
end

function a1:_build()
    local a29 = if self.name then a7 else 0

    self.main = self.window:Create("Frame", {
        Size = UDim2.new(1, -20, 0, self.height + a29 + a8 * 2),
        BorderSizePixel = 0,
        Name = self.name or "Console",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),

                BackgroundTransparency = 1,
        Parent = self.tab.tabPage,
    }, { BackgroundTransparency = "ElementTransparency" })

    self.stroke = self.window:StyleElementBody(self.main)

    if self.name then
        self.container = self.window:Create("Frame", {
            Size = UDim2.new(1, -a8 * 2, 0, 16),
            Position = UDim2.new(0, a8, 0, a8),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,

            Parent = self.main,
        })

        self.title = self.window:Create("TextLabel", {
            Text = a4.t(self.name),

            Size = UDim2.fromScale(1, 1),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,

                        TextTransparency = 1,
            Parent = self.container,
        }, { TextColor3 = "ContentColor", FontFace = "Font" })
    end

            self.panel = self.window:Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, -a8),
        Size = UDim2.new(1, -a8 * 2, 0, self.height),
        BorderSizePixel = 0,
        ClipsDescendants = true,

        BackgroundTransparency = 1,
        Parent = self.main,
    }, { BackgroundColor3 = "StatBackground" })

    self.window:Create("UICorner", {
        Parent = self.panel,
    }, { CornerRadius = "ElementCornerRadius" })

    self.panelStroke = self.window:Create("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,

                Transparency = 1,
        Parent = self.panel,
    }, { Color = "SurfaceStroke" })

    self.scroll = self.window:Create("ScrollingFrame", {
        Size = UDim2.new(1, -a9 * 2, 1, -a9 * 2),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.Y,

        Parent = self.panel,
    })

        self.scrollLayout = self.window:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,

        Parent = self.scroll,
    })

    self:_watchCanvas()
end

function a1:_pin()
    local a30 = self.scroll
    if not a30 or not a30.Parent then
        return
    end
    a30.CanvasPosition = Vector2.new(0, a30.AbsoluteCanvasSize.Y)
end

function a1:_follow()
    if not self.follow then
        return
    end
    self:_pin()
    task.defer(function()
        self:_pin()
    end)
end

function a1:_watchCanvas()
    self.window:ConnectFor(self, self.scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        if self.follow then
            self:_pin()
        end
    end)
end

function a1:Set(a31)
    self:_setLines(a31)
end

function a1:Append(a32)
    a32 = if type(a32) == "string" then a32 else tostring(a32)
    for a33 in string.gmatch(a32 .. "\n", "([^\n]*)\n") do
        self:_pushLine(a33)
    end
    self:_follow()
end

function a1:Clear()
    table.clear(self.lines)
    self:_flush()
end

function a1:Copy(): boolean
    local a34 = (getgenv and getgenv().setclipboard) or setclipboard
    if typeof(a34) ~= "function" then
        return false
    end
    return (pcall(a34, self:Get()))
end

function a1:SetHeight(a35)
    self.height = math.max(tonumber(a35) or a5, a6)
    local a36 = if self.name then a7 else 0
    self.panel.Size = UDim2.new(1, -a8 * 2, 0, self.height)
    self.main.Size = UDim2.new(1, -20, 0, self.height + a36 + a8 * 2)
end

function a1:_setShown(a37, a38)
    local w = self.window

        w:_reveal(self.main, { BackgroundTransparency = if a37 then w.theme.ElementTransparency or 0 else 1 }, a38)
    w:_reveal(self.stroke, { Transparency = if a37 then w.theme.ElementStrokeTransparency else 1 }, a38)
    w:_reveal(self.panel, { BackgroundTransparency = if a37 then 0 else 1 }, a38)
    w:_reveal(self.panelStroke, { Transparency = if a37 then 0.9 else 1 }, a38)

    self._textTransparency = if a37 then 0.15 else 1
    for _, a39 in self.lineLabels do
        w:_reveal(a39, { TextTransparency = self._textTransparency }, a38)
    end

    if self.title then
        w:_reveal(self.title, { TextTransparency = if a37 then 0 else 1 }, a38)
    end
    if self.descriptor then
        w:_reveal(self.descriptor.titleLabel, { TextTransparency = if a37 then 0.7 else 1 }, a38)
    end
end

function a1:Remove()
    if self.descriptor then
        self.descriptor:Remove()
    end
    self.main:Destroy()
end

a3(a1)

return a1
