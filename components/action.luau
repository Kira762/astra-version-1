local a1 = {}
a1.__index = a1
a1.__type = "Action"

local a2 = script.Parent.Parent.utilities

local a3 = require(a2.Parent.core.state)
local a4 = require(a2.log)
local a5 = require(a2.HapticEngine)
local a6 = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

function a1.new(window, a7)
    a7 = if typeof(a7) == "table" then a7 else {}

    local self = setmetatable({
        window = assert(window, "Missing argument #1 (Window expected)"),
        name = a7.name or a7.Name or "Action",
        icon = assert(window:ResolveIcon(a7.icon or a7.Icon), "Missing argument (Icon expected)"),
        callback = assert(a7.callback or a7.Callback, "Missing argument (Function expected)"),
        linkedTab = a7.linkedTab or a7.LinkedTab,
    }, a1)

    self.action = self.window:Create("Frame", {
        Name = self.name,
        BorderSizePixel = 0,

        LayoutOrder = -(a7.order or 0),
        Size = UDim2.fromOffset(24, 24),
        BackgroundTransparency = 1,

        Parent = self.window.actionContainer,
    })

    self.iconLabel = self.window:Create("ImageLabel", {
                Image = self.icon,

        Size = UDim2.fromOffset(20, 20),
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        BackgroundTransparency = 1,

                ImageTransparency = 1,
        Parent = self.action,
    }, { ImageColor3 = "ActionColor" })

    self.interact = self.window:Create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        TextTransparency = 1,

        Parent = self.action,
    })

                local function a8()
        if self.window.unloaded then
            return
        end
        if not self.window:_settled() then
            return         end
        if self.linkedTab and self.window.selectedTab == self.linkedTab then
            return
        end
        if self.isLit and self:isLit() then
            return
        end
        a3.tweenService
            :Create(
                self.iconLabel,
                a6,
                { ImageTransparency = 0.6 }
            )
            :Play()
    end

    self.window:Connect(self.interact.MouseButton1Click, function()
        a5.click()
        task.spawn(function()
            local a9, a10 = pcall(self.callback)
            if not a9 then
                a4.warn(
                    `Astra encountered an error, with the callback for a {self.__type} component named '{self.name}':`
                )
                a4.print(a10)
            end
                                    a8()
        end)
    end)

    self.window:Connect(self.interact.MouseEnter, function()
        if not self.window:_interactive() then
            return         end
        a3.tweenService
            :Create(
                self.iconLabel,
                a6,
                { ImageTransparency = 0.2 }
            )
            :Play()
    end)

    self.window:Connect(self.interact.MouseLeave, a8)

    return self
end

return a1
