local state = {}
state.__index = state
state.__type = "Console"

local constants = script.Parent.Parent.utilities

local Console = require(constants.moveable)
local tab = require(constants.locale)

local props = 120
local name = 48
local text = 24 local height = 17
local follow = 12 local maxLines = 12
local element = 1.25
local frame = 200

local outputBuffer = Font.fromEnum(Enum.Font.Code)

function state.new(tab, maxLines)
    maxLines = if typeof(maxLines) == "table" then maxLines else {}

    local self = setmetatable({
        tab = assert(tab, "Missing argument #1 (Tab expected)"),
        window = tab.window,
        name = maxLines.name or maxLines.Name,
        description = maxLines.description or maxLines.Description,

        height = math.max(tonumber(maxLines.height or maxLines.Height) or props, name),
                follow = maxLines.follow or maxLines.Follow or false,
        maxLines = math.max(tonumber(maxLines.maxLines or maxLines.MaxLines) or frame, 1),

        lines = {},
                                lineLabels = {},
        head = 1,         nextOrder = 1,
        textDirty = true,
    }, state)

    self:_build()
    self:_setLines(maxLines.text or maxLines.Text or "")

    if self.description then
        self.descriptor = require(script.Parent.descriptor).new(self.tab, { description = self.description })
    end

    return self
end

function state:Get(): string
    if self.textDirty then
        self.text = table.concat(self.lines, "\n")
        self.textDirty = false
    end
    return self.text
end

function state:_setLines(a15)
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

function state:_trim()
    local a17 = #self.lines - self.maxLines
    if a17 <= 0 then
        return
    end
    table.move(self.lines, a17 + 1, #self.lines, 1)
    for a18 = #self.lines, #self.lines - a17 + 1, -1 do
        self.lines[a18] = nil
    end
end

function state:_makeLabel()
    return self.window:Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        FontFace = outputBuffer,
        TextSize = maxLines,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        LineHeight = element,
        RichText = false,
                TextTransparency = self._textTransparency or 1,

        Parent = self.scroll,
    }, { TextColor3 = "ContentColor" })
end

local function a19(a20: string): string
    return if a20 == "" then " " else a20
end

function state:_flush()
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

function state:_pushLine(a25: string)
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

function state:_build()
    local a29 = if self.name then text else 0

    self.main = self.window:Create("Frame", {
        Size = UDim2.new(1, -20, 0, self.height + a29 + height * 2),
        BorderSizePixel = 0,
        Name = self.name or "Console",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),

                BackgroundTransparency = 1,
        Parent = self.tab.tabPage,
    }, { BackgroundTransparency = "ElementTransparency" })

    self.stroke = self.window:StyleElementBody(self.main)

    if self.name then
        self.container = self.window:Create("Frame", {
            Size = UDim2.new(1, -height * 2, 0, 16),
            Position = UDim2.new(0, height, 0, height),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,

            Parent = self.main,
        })

        self.title = self.window:Create("TextLabel", {
            Text = tab.t(self.name),

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
        Position = UDim2.new(0.5, 0, 1, -height),
        Size = UDim2.new(1, -height * 2, 0, self.height),
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
        Size = UDim2.new(1, -follow * 2, 1, -follow * 2),
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

function state:_pin()
    local a30 = self.scroll
    if not a30 or not a30.Parent then
        return
    end
    a30.CanvasPosition = Vector2.new(0, a30.AbsoluteCanvasSize.Y)
end

function state:_follow()
    if not self.follow then
        return
    end
    self:_pin()
    task.defer(function()
        self:_pin()
    end)
end

function state:_watchCanvas()
    self.window:ConnectFor(self, self.scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        if self.follow then
            self:_pin()
        end
    end)
end

function state:Set(a31)
    self:_setLines(a31)
end

function state:Append(a32)
    a32 = if type(a32) == "string" then a32 else tostring(a32)
    for a33 in string.gmatch(a32 .. "\n", "([^\n]*)\n") do
        self:_pushLine(a33)
    end
    self:_follow()
end

function state:Clear()
    table.clear(self.lines)
    self:_flush()
end

function state:Copy(): boolean
    local a34 = (getgenv and getgenv().setclipboard) or setclipboard
    if typeof(a34) ~= "function" then
        return false
    end
    return (pcall(a34, self:Get()))
end

function state:SetHeight(a35)
    self.height = math.max(tonumber(a35) or props, name)
    local a36 = if self.name then text else 0
    self.panel.Size = UDim2.new(1, -height * 2, 0, self.height)
    self.main.Size = UDim2.new(1, -20, 0, self.height + a36 + height * 2)
end

function state:_setShown(a37, a38)
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

function state:Remove()
    if self.descriptor then
        self.descriptor:Remove()
    end
    self.main:Destroy()
end

Console(state)

return state
