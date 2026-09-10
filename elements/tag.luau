local state = {}
state.__index = state
state.__type = "Tag"

local constants = script.Parent.Parent.utilities

local Tag = require(constants.Parent.core.state)
local tab = require(script.Parent.Parent.functions)
local props = require(script.Parent.Parent.images.image)

local text = Color3.fromRGB(255, 175, 15)
local title = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

function state.new(window, icon)
    icon = if typeof(icon) == "table" then icon else {}

    local self = setmetatable({
        window = assert(window, "Missing argument #1 (Window expected)"),
        text = icon.text or icon.Text or icon.title or icon.Title,
        icon = window:ResolveIcon(icon.icon or icon.Icon),
        color = icon.color or icon.Color or text,
    }, state)

    assert(self.icon or (self.text and self.text ~= ""), "A Tag requires an icon, text, or both.")

    self.main = self.window:Create("Frame", {
        Name = "Tag",
        Size = UDim2.fromOffset(10, 24),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = self.color,
        BorderSizePixel = 0,
        LayoutOrder = icon.order or icon.Order or 0,

                BackgroundTransparency = 1,
        Parent = self.window.tagContainer,
    })

    self.window:Create("UICorner", {
        CornerRadius = UDim.new(0, 8),

        Parent = self.main,
    })

    self.window:Create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),

        Parent = self.main,
    })

    self.window:Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,

        Parent = self.main,
    })

    local color = tab.contrastColor(self.color)

    self.iconLabel = self.window:Create("ImageLabel", {
        Name = "Icon",
        Image = self.icon or "",
        ImageColor3 = color,
        Size = UDim2.fromOffset(16, 16),
        BackgroundTransparency = 1,
        Visible = self.icon ~= nil,
        ZIndex = 5,

                ImageTransparency = 1,
        Parent = self.main,
    })

    self.title = self.window:Create("TextLabel", {
        Name = "Title",
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.fromOffset(10, 15),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = self.text or "",
        TextColor3 = color,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        RichText = true,
        Visible = self.text ~= nil and self.text ~= "",
        LayoutOrder = 1,
        ZIndex = 5,

                TextTransparency = 1,
        Parent = self.main,
    }, { FontFace = "Font" })

    self.window.tagContainer.Visible = true

        if not self.window.hidden then
        self:_setShown(true, title)
    end

    return self
end

function state:_setShown(order, element)
    local frame = if order then 0 else 1
    local a13 = if typeof(element) == "TweenInfo" then element elseif element then title else nil
    if a13 then
        Tag.tweenService:Create(self.main, a13, { BackgroundTransparency = frame }):Play()
        Tag.tweenService:Create(self.iconLabel, a13, { ImageTransparency = frame }):Play()
        Tag.tweenService:Create(self.title, a13, { TextTransparency = frame }):Play()
    else
        self.main.BackgroundTransparency = frame
        self.iconLabel.ImageTransparency = frame
        self.title.TextTransparency = frame
    end
end

function state:SetColor(a14)
    self.color = a14
    local a15 = tab.contrastColor(a14)
    Tag.tweenService:Create(self.main, title, { BackgroundColor3 = a14 }):Play()
    Tag.tweenService:Create(self.iconLabel, title, { ImageColor3 = a15 }):Play()
    Tag.tweenService:Create(self.title, title, { TextColor3 = a15 }):Play()
end

function state:SetText(a16)
    self.text = a16
    self.title.Text = a16 or ""
    self.title.Visible = a16 ~= nil and a16 ~= ""
end

function state:SetIcon(a17)
    self.icon = a17
    props.assign(self.iconLabel, "Image", a17)
    self.iconLabel.Visible = a17 ~= nil
end

function state:Set(a18)
    if a18.color or a18.Color then
        self:SetColor(a18.color or a18.Color)
    end
    if a18.text or a18.Text or a18.title or a18.Title then
        self:SetText(a18.text or a18.Text or a18.title or a18.Title)
    end
    if a18.icon ~= nil or a18.Icon ~= nil then
        self:SetIcon(a18.icon or a18.Icon)
    end
end

function state:Remove()
        self.window:DestroySubtree(self.main)
    local a19 = table.find(self.window.tags, self)
    if a19 then
        table.remove(self.window.tags, a19)
    end
    if #self.window.tags == 0 then
        self.window.tagContainer.Visible = false
    end
end

return state
