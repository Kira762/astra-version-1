local a1 = {}
a1.__index = a1
a1.__type = "Drag"

local a2 = script.Parent.Parent.utilities

local a3 = require(a2.Parent.core.state)
local a4 = require(a2.constants)
local a5 = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local a6 = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

function a1.new(window, a7)
    a7 = if typeof(a7) == "table" then a7 else {}

    local self = setmetatable({
        window = assert(window, "Missing argument #1 (Window expected)"),
    }, a1)

        self.drag = self.window:Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(150, 20),
        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0.5, 0, 0.5, self.window.size.Y.Offset / 2 + 15),
        ZIndex = a4.zIndex.drag,

                Visible = false,
        Parent = self.window.screenGui,
    })

    self.dragCosmetic = self.window:Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.3),
        ZIndex = a4.zIndex.drag,

                BackgroundTransparency = 1,         Size = UDim2.fromOffset(0, 4),
        Parent = self.drag,
    })

    self.window:Create("UICorner", {
        CornerRadius = UDim.new(0, 20),

        Parent = self.dragCosmetic,
    })

        self.window:CreateGlow(self.dragCosmetic, Color3.fromRGB(255, 255, 255), 10, 0.5)

    self.dragInteract = self.window:Create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        TextTransparency = 1,
        ZIndex = a4.zIndex.drag,

        Parent = self.drag,
    })

    local a8 = false
    local a9 = nil

                local a10 = Vector2.zero
    local a11 = self.window.screenGui

    if a11 and a11.IgnoreGuiInset then
        a10 = a3.guiService:GetGuiInset()
    end

    local function a12()
        local a13 = a3.userInputService and a3.userInputService:GetMouseLocation()
            or Vector2.new(0, 0)
        local a14 = a9 or Vector2.new(0, 0)
        local a15 = a10 or Vector2.new(0, 0)

        return a13 + a14 + a15
    end

        local function a16()
        local a17 = a12()
        local x, y = a17.X, a17.Y

                if self.window.settings and self.window.settings.keepOnScreen then
            local a18 = self.window.main.AbsoluteSize
            local a19 = self.window.screenGui.AbsoluteSize
            local a20 = 8
            local a21, a22 = a18.X / 2, a18.Y / 2
                        x = math.clamp(x, a21 + a20, math.max(a21 + a20, a19.X - a21 - a20))
            y = math.clamp(y, a22 + a20, math.max(a22 + a20, a19.Y - a22 - a20))
        end

        local a23 = UDim2.fromOffset(x, y)
        local a24 = UDim2.fromOffset(x, y + (self.window.main.Size.Y.Offset / 2 + 15))
        return a23, a24
    end

    self.window:Connect(self.drag.MouseEnter, function()
        if not a8 and not self.window.hidden then
            a3.tweenService
                :Create(
                    self.dragCosmetic,
                    a6,
                    { BackgroundTransparency = 0.5, Size = UDim2.new(0, 120, 0, 4) }
                )
                :Play()
        end
    end)

    self.window:Connect(self.drag.MouseLeave, function()
        if not a8 and not self.window.hidden then
            a3.tweenService
                :Create(
                    self.dragCosmetic,
                    a6,
                    { BackgroundTransparency = 0.7, Size = UDim2.new(0, 100, 0, 4) }
                )
                :Play()
        end
    end)

    local function a25()
        if not a8 then
            return
        end
        a8 = false

        if self._dragConnection then
            self.window:Disconnect(self._dragConnection)
            self._dragConnection = nil
        end

        if not self.window:_interactive() then
            return
        end

        a3.tweenService
            :Create(
                self.dragCosmetic,
                a5,
                { Size = UDim2.new(0, 100, 0, 4), BackgroundTransparency = 0.7 }
            )
            :Play()

                local a26 = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        local a27, a28 = a16()
        a3.tweenService:Create(self.window.main, a26, { Position = a27 }):Play()
        a3.tweenService:Create(self.drag, a26, { Position = a28 }):Play()
    end

    local a29 = 1e-7
    local a30 = 1e-60
    local a31

    self.window:Connect(self.dragInteract.InputBegan, function(a32, a33)
        if a33 then
            return
        end

        local a34 = a32.UserInputType.Name
        if a34 == "MouseButton1" or a34 == "Touch" then
                        if not self.window:_interactive() then
                return
            end

            a8 = true

            if self._dragConnection then
                self.window:Disconnect(self._dragConnection)
                self._dragConnection = nil
            end

                        if a11 and a11.IgnoreGuiInset then
                a10 = a3.guiService:GetGuiInset()
            end

            a9 = self.window.main.AbsolutePosition
                + self.window.main.AbsoluteSize * self.window.main.AnchorPoint
                - a3.userInputService:GetMouseLocation()
            if not self.window.hidden then
                a3.tweenService
                    :Create(
                        self.dragCosmetic,
                        a5,
                        { Size = UDim2.new(0, 110, 0, 4), BackgroundTransparency = 0 }
                    )
                    :Play()
            end

            self._dragConnection = self.window:Connect(a3.runService.RenderStepped, a31)
        end
    end)

    self.window:Connect(a3.userInputService.InputEnded, function(a35)
        local a36 = a35.UserInputType.Name
        if a36 == "MouseButton1" or a36 == "Touch" then
            a25()
        end
    end)

            self.window:Connect(a3.userInputService.WindowFocusReleased, a25)

    a31 = function(dt)
        if not a8 then
            if self._dragConnection then
                self.window:Disconnect(self._dragConnection)
                self._dragConnection = nil
            end
            return
        end

        if self.window.unloaded or not self.window:_interactive() then
            a25()
            return
        end

        local a37, a38 = a16()

        self.window.main.Position = self.window.main.Position:Lerp(a37, 1 - a29 ^ dt)
        self.drag.Position = self.drag.Position:Lerp(a38, 1 - a30 ^ dt)
    end

    return self
end

return a1
