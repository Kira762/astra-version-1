local a1 = script.Parent.Parent.utilities
local a2 = require(a1.Parent.core.state)
local a3 = require(a1.filesystem)
local a4 = require(a1.constants)
local a5 = require(a1.locale)
local a6 = require(a1.HapticEngine)

local a7 = {}

local a8 = 5

function a7.buildCollapsedFace(window)
    local a9 = window.showIconOnly

    window.collapsedIcon = window:Create("ImageLabel", {
        Name = "CollapsedIcon",
        AnchorPoint = if a9 then Vector2.new(0.5, 0.5) else Vector2.new(0, 0.5),
        Position = if a9 then UDim2.fromScale(0.5, 0.5) else UDim2.new(0, 16, 0.5, 0),
        Size = UDim2.fromOffset(24, 24),
        BackgroundTransparency = 1,
                Image = window.showIcon,
        ZIndex = a4.zIndex.restoreContent,

        ImageTransparency = 1,
        Parent = window.main,
    }, { ImageColor3 = "TitlingColor" })

    window:Create("UICorner", {
        Parent = window.collapsedIcon,
    }, { CornerRadius = "PillCornerRadius" })

    local a10 = window:Create("Frame", {
        Name = "CollapsedText",
        Visible = not a9,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 50, 0.5, 0),
        Size = UDim2.new(1, -60, 0, 32),
        BackgroundTransparency = 1,
        ZIndex = a4.zIndex.restoreContent,

        Parent = window.main,
    })

    window:Create("UIListLayout", {
        Padding = UDim.new(0, 1),
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,

        Parent = a10,
    })

    window.collapsedTitle = window:Create("TextLabel", {
        Name = "Title",
        Text = window.showName,
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        FontFace = a2.brandFont(Enum.FontWeight.Medium),
        RichText = true,
        TextSize = 16,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1,
        ZIndex = a4.zIndex.restoreContent,

        TextTransparency = 1,
        Parent = a10,
    }, { TextColor3 = "TitlingColor" })

    window.collapsedSubtitle = window:Create("TextLabel", {
        Name = "Subtitle",
        Text = a5.t("Tap to show"),
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        FontFace = a2.brandFont(Enum.FontWeight.Medium),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 2,
        ZIndex = a4.zIndex.restoreContent,

        TextTransparency = 1,
        Parent = a10,
    }, { TextColor3 = "TitlingColor" })

                    window.collapsedInteract = window:Create("TextButton", {
        Name = "CollapsedInteract",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = "",
        TextTransparency = 1,
        Visible = false,
        ZIndex = a4.zIndex.restoreInteract,

        Parent = window.main,
    })

    a7.bindCollapsedDrag(window)
end

function a7.bindCollapsedDrag(window)
    local a11 = a2.userInputService
    local a12, a13 = false, false
    local a14, a15 = Vector2.zero, Vector2.zero
    local a16

            local function a17()
        if window.screenGui and window.screenGui.IgnoreGuiInset then
            return a2.guiService:GetGuiInset()
        end
        return Vector2.zero
    end

    local function a18()
        a12 = false
        if a16 then
            window:Disconnect(a16)
            a16 = nil
        end
    end

    local function a19()
        if not a12 then
            a18()
            return
        end
        if window.unloaded or not window.hidden or window.animating then
            a18()
            return
        end

        local a20 = a11:GetMouseLocation()
        if not a13 and (a20 - a15).Magnitude < a8 then
            return
        end
        a13 = true

        local a21 = a20 + a14 + a17()
        window.main.Position = UDim2.fromOffset(a21.X, a21.Y)
    end

    window:Connect(window.collapsedInteract.InputBegan, function(a22, a23)
        if a23 or not window.hidden or window.animating then
            return
        end
        local a24 = a22.UserInputType.Name
        if a24 ~= "MouseButton1" and a24 ~= "Touch" then
            return
        end

        a12, a13 = true, false
        if a16 then
            window:Disconnect(a16)
            a16 = nil
        end
        a16 = window:Connect(a2.runService.RenderStepped, a19)
        a15 = a11:GetMouseLocation()
        a14 = window.main.AbsolutePosition + window.main.AbsoluteSize * window.main.AnchorPoint - a15
    end)

    window:Connect(a11.InputEnded, function(a25)
        local a26 = a25.UserInputType.Name
        if a26 ~= "MouseButton1" and a26 ~= "Touch" then
            return
        end
        if not a12 then
            return
        end
        a18()

        if a13 then
            window._collapsedPosition = window.main.Position
            return
        end

        a6.click()
        window:ToggleHide()
    end)

            window:Connect(a11.WindowFocusReleased, function()
        a18()
    end)
end

function a7.isNewUser()
    local a27 = a2.localPlayer
    if not a27 then
        return false
    end

        if typeof(a3.isfile) ~= "function" or typeof(a3.writefile) ~= "function" then
        return true
    end

    local a28 = a2.fileSystemManager:getPath("lastuser.txt")
    local a29 = tostring(a27.UserId)
    local a30 = true

    pcall(function()
        if a3.isfile(a28) then
            a30 = a3.readfile(a28) ~= a29
        end
    end)

    pcall(function()
        a3.writefile(a28, a29)
    end)

    return a30
end

function a7.setCollapsedShown(window, a31, a32)
    local a33 = window._hideTransitionId

    local a34 = {
        [window.collapsedIcon] = { ImageTransparency = if a31 then 0 else 1 },
    }

    if not window.showIconOnly then
        a34[window.collapsedTitle] = { TextTransparency = if a31 then 0 else 1 }
        a34[window.collapsedSubtitle] = { TextTransparency = if a31 then 0.5 else 1 }
    end

    for a35, a36 in a34 do
        if a32 then
            local a37 = a2.tweenService:Create(a35, a32, a36)
            a37.Completed:Connect(function(ok)
                if not ok or window._hideTransitionId ~= a33 then
                    return
                end
                for a38, a39 in a36 do
                    a35[a38] = a39
                end
            end)
            a37:Play()
        else
            for a40, a41 in a36 do
                a35[a40] = a41
            end
        end
    end
end

return a7
