local a1 = {}
a1.__index = a1
a1.__type = "Tag"

local a2 = script.Parent.Parent.utilities

local a3 = require(a2.Parent.core.state)
local a4 = require(script.Parent.Parent.functions)
local a5 = require(script.Parent.Parent.images.image)

local a6 = Color3.fromRGB(255, 175, 15)
local a7 = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

function a1.new(window, a8)
    a8 = if typeof(a8) == "table" then a8 else {}

    local self = setmetatable({
        window = assert(window, "Missing argument #1 (Window expected)"),
        text = a8.text or a8.Text or a8.title or a8.Title,
        icon = window:ResolveIcon(a8.icon or a8.Icon),
        color = a8.color or a8.Color or a6,
    }, a1)

    assert(self.icon or (self.text and self.text ~= ""), "A Tag requires an icon, text, or both.")

    self.main = self.window:Create("Frame", {
        Name = "Tag",
        Size = UDim2.fromOffset(10, 24),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = self.color,
        BorderSizePixel = 0,
        LayoutOrder = a8.order or a8.Order or 0,

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

    local a9 = a4.contrastColor(self.color)

    self.iconLabel = self.window:Create("ImageLabel", {
        Name = "Icon",
        Image = self.icon or "",
        ImageColor3 = a9,
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
        TextColor3 = a9,
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
        self:_setShown(true, a7)
    end

    return self
end

function a1:_setShown(a10, a11)
    local a12 = if a10 then 0 else 1
    local a13 = if typeof(a11) == "TweenInfo" then a11 elseif a11 then a7 else nil
    if a13 then
        a3.tweenService:Create(self.main, a13, { BackgroundTransparency = a12 }):Play()
        a3.tweenService:Create(self.iconLabel, a13, { ImageTransparency = a12 }):Play()
        a3.tweenService:Create(self.title, a13, { TextTransparency = a12 }):Play()
    else
        self.main.BackgroundTransparency = a12
        self.iconLabel.ImageTransparency = a12
        self.title.TextTransparency = a12
    end
end

function a1:SetColor(a14)
    self.color = a14
    local a15 = a4.contrastColor(a14)
    a3.tweenService:Create(self.main, a7, { BackgroundColor3 = a14 }):Play()
    a3.tweenService:Create(self.iconLabel, a7, { ImageColor3 = a15 }):Play()
    a3.tweenService:Create(self.title, a7, { TextColor3 = a15 }):Play()
end

function a1:SetText(a16)
    self.text = a16
    self.title.Text = a16 or ""
    self.title.Visible = a16 ~= nil and a16 ~= ""
end

function a1:SetIcon(a17)
    self.icon = a17
    a5.assign(self.iconLabel, "Image", a17)
    self.iconLabel.Visible = a17 ~= nil
end

function a1:Set(a18)
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

function a1:Remove()
        self.window:DestroySubtree(self.main)
    local a19 = table.find(self.window.tags, self)
    if a19 then
        table.remove(self.window.tags, a19)
    end
    if #self.window.tags == 0 then
        self.window.tagContainer.Visible = false
    end
end

return a1
