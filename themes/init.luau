
local a1 = script
local a2 = require(script.Parent.core.state)
local a3 = require(script.Parent.utilities.log)

local a4 = {}

local a5 = {
    WindowColor = true,
    ElementGradient = true,
    ElementStrokeGradient = true,
    TabBackground = true,
    TabStroke = true,
    SliderProgress = true,
}

function a4.coerceValue(a6, a7)
    if a5[a6] and typeof(a7) == "Color3" then
        return ColorSequence.new(a7)
    end
    return a7
end

function a4.firstColor(a8)
    return if typeof(a8) == "ColorSequence" then a8.Keypoints[1].Value else a8
end

local function a9(a10, a11)
    local a12 = 0.299 * a10.R + 0.587 * a10.G + 0.114 * a10.B
    local a13 = if a12 > 0.5 then Color3.new(0, 0, 0) else Color3.new(1, 1, 1)
    return a10:Lerp(a13, a11)
end

function a4.deriveStrokes(a14, a15)
    if a15.ElementGradient then
        local a16 = a4.firstColor(a14.ElementGradient)
        if a15.ElementStroke == nil then
            a14.ElementStroke = a9(a16, 0.28)
        end
        if a15.ElementStrokeGradient == nil then
            a14.ElementStrokeGradient = ColorSequence.new(a9(a16, 0.4))
        end
        if a15.ElementStrokeHover == nil then
            a14.ElementStrokeHover = a9(a16, 0.52)
        end
    end
    if a15.TabBackground and a15.TabStroke == nil then
        a14.TabStroke = ColorSequence.new(a9(a4.firstColor(a14.TabBackground), 0.4))
    end
end

local function a17(a18)
    if typeof(a18) == "table" then
        return a18
    elseif typeof(a18) == "string" then
        local a19 = a1:FindFirstChild(string.lower(a18))
        if a19 then
            return require(a19)
        end
        a3.warn("Astra: unknown theme '" .. a18 .. "', using default")
    elseif a18 ~= nil then
        a3.warn("Astra: invalid theme (expected a built-in name or a theme table), using default")
    end
    return require(a1["default"])
end

function a4.resolve(a20)
    local a21 = table.clone(require(a1["default"]))
    local a22 = a17(a20)
    for a23, a24 in a22 do
        a21[a23] = a4.coerceValue(a23, a24)
    end
    if typeof(a20) == "table" then
        deriveStrokes(a21, a22)
    end

    local a25 = if typeof(a20) == "table" then a20 else nil
    if not (a25 and (a25.Font or a25.font)) then
        a21.Font = a2.brandFont(Enum.FontWeight.Medium)
    end
    if not (a25 and (a25.TitleFont or a25.titleFont)) then
        a21.TitleFont = a2.brandFont(Enum.FontWeight.SemiBold)
    end

    return a21
end

return a4
