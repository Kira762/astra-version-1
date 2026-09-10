
local themesFolder = script
local coreState = require(script.Parent.core.state)
local log = require(script.Parent.utilities.log)

local themeTable = {}

local colorSequenceKeys = {
    WindowColor = true,
    ElementGradient = true,
    ElementStrokeGradient = true,
    TabBackground = true,
    TabStroke = true,
    SliderProgress = true,
}

function themeTable.coerceValue(key, value)
    if colorSequenceKeys[key] and typeof(value) == "Color3" then
        return ColorSequence.new(value)
    end
    return value
end

function themeTable.firstColor(key)
    return if typeof(key) == "ColorSequence" then key.Keypoints[1].Value else key
end

local function luminance(color, amount)
    local lum = 0.299 * color.R + 0.587 * color.G + 0.114 * color.B
    local contrast = if lum > 0.5 then Color3.new(0, 0, 0) else Color3.new(1, 1, 1)
    return color:Lerp(contrast, amount)
end

function themeTable.deriveStrokes(theme, overrides)
    if overrides.ElementGradient then
        local baseColor = themeTable.firstColor(theme.ElementGradient)
        if overrides.ElementStroke == nil then
            theme.ElementStroke = luminance(baseColor, 0.28)
        end
        if overrides.ElementStrokeGradient == nil then
            theme.ElementStrokeGradient = ColorSequence.new(luminance(baseColor, 0.4))
        end
        if overrides.ElementStrokeHover == nil then
            theme.ElementStrokeHover = luminance(baseColor, 0.52)
        end
    end
    if overrides.TabBackground and overrides.TabStroke == nil then
        theme.TabStroke = ColorSequence.new(luminance(themeTable.firstColor(theme.TabBackground), 0.4))
    end
end

local function resolveInput(input)
    if typeof(input) == "table" then
        return input
    elseif typeof(input) == "string" then
        local child = themes:FindFirstChild(string.lower(input))
        if child then
            return require(child)
        end
        state.warn("Astra: unknown theme '" .. input .. "', using default")
    elseif input ~= nil then
        state.warn("Astra: invalid theme (expected a built-in name or a theme table), using default")
    end
    return require(themes["default"])
end

function themeTable.resolve(input)
    local base = table.clone(require(themes["default"]))
    local overlay = resolveInput(input)
    for key, value in overlay do
        base[key] = themeTable.coerceValue(key, value)
    end
    if typeof(input) == "table" then
        themeTable.deriveStrokes(base, overlay)
    end

    local customTable = if typeof(input) == "table" then input else nil
    if not (customTable and (customTable.Font or customTable.font)) then
        base.Font = default.brandFont(Enum.FontWeight.Medium)
    end
    if not (customTable and (customTable.TitleFont or customTable.titleFont)) then
        base.TitleFont = default.brandFont(Enum.FontWeight.SemiBold)
    end

    return base
end

return themeTable
