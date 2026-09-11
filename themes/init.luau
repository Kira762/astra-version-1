-- Astra theme resolution engine.
-- Built-in themes may provide semantic tokens and legacy consumer keys. Custom
-- themes are merged onto the default palette so missing values never crash UI
-- construction or leave a component with an invalid Color3/ColorSequence.
local themesFolder = script
local variables = require(script.Parent.core.state)
local log = require(script.Parent.utilities.log)

local themes = {}

local gradientKeys = {
    WindowColor = true,
    ElementGradient = true,
    ElementStrokeGradient = true,
    TabBackground = true,
    TabStroke = true,
    SliderProgress = true,
}

local semanticAliases = {
    WindowSurface = { "WindowColor" },
    ElementSurface = { "CardSurface" },
    Stroke = { "ElementStroke", "SurfaceStroke" },
    Accent = { "AccentColor", "DropdownHighlight" },
    AccentStrokeSemantic = { "AccentStroke" },
    PrimaryText = { "ContentColor", "TitlingColor" },
    MutedText = { "PlaceholderColor" },
    ElementHover = { "NeutralButtonHover", "SliderBackgroundHover", "ElementStrokeHover" },
    SecondaryElement = { "NeutralButton", "SliderBackground" },
    InputSurface = { "FieldBackground" },
}

function themes.coerceValue(key, value)
    if gradientKeys[key] and typeof(value) == "Color3" then
        return ColorSequence.new(value)
    end
    return value
end

function themes.firstColor(value)
    if typeof(value) == "ColorSequence" then
        return value.Keypoints[1].Value
    end
    return value
end

local function edgeShade(color, amount)
    if typeof(color) ~= "Color3" then
        return nil
    end
    local luminance = 0.299 * color.R + 0.587 * color.G + 0.114 * color.B
    local target = if luminance > 0.5 then Color3.new(0, 0, 0) else Color3.new(1, 1, 1)
    return color:Lerp(target, amount)
end

local function aliasValue(key, value)
    if key == "WindowColor" or key == "ElementGradient" or key == "ElementStrokeGradient" then
        return themes.coerceValue(key, value)
    end
    if typeof(value) == "Color3" then
        return value
    end
    return nil
end

local function applySemanticAliases(resolved, overrides)
    for semantic, legacyKeys in semanticAliases do
        local override = overrides[semantic]
        if override ~= nil then
            local value = aliasValue(legacyKeys[1], override)
            if value ~= nil then
                for _, legacyKey in legacyKeys do
                    if overrides[legacyKey] == nil then
                        resolved[legacyKey] = value
                    end
                end
            end
        end
    end
end

function themes.deriveStrokes(resolved, overrides)
    if overrides.ElementGradient then
        local fill = themes.firstColor(resolved.ElementGradient)
        if overrides.ElementStroke == nil then
            resolved.ElementStroke = edgeShade(fill, 0.28) or resolved.ElementStroke
        end
        if overrides.ElementStrokeGradient == nil then
            local shade = edgeShade(fill, 0.4)
            if shade then
                resolved.ElementStrokeGradient = ColorSequence.new(shade)
            end
        end
        if overrides.ElementStrokeHover == nil then
            resolved.ElementStrokeHover = edgeShade(fill, 0.52) or resolved.ElementStrokeHover
        end
    end
    if overrides.TabBackground and overrides.TabStroke == nil then
        local shade = edgeShade(themes.firstColor(resolved.TabBackground), 0.4)
        if shade then
            resolved.TabStroke = ColorSequence.new(shade)
        end
    end
end

local function themeOverrides(value)
    if typeof(value) == "table" then
        return value
    elseif typeof(value) == "string" then
        local named = themesFolder:FindFirstChild(string.lower(value))
        if named then
            return require(named)
        end
        log.warn("Astra: unknown theme '" .. value .. "', using default")
    elseif value ~= nil then
        log.warn("Astra: invalid theme (expected a built-in name or a theme table), using default")
    end
    return require(themesFolder["default"])
end

function themes.resolve(value)
    local resolved = table.clone(require(themesFolder["default"]))
    local overrides = themeOverrides(value)
    for key, override in overrides do
        resolved[key] = themes.coerceValue(key, override)
    end
    applySemanticAliases(resolved, overrides)
    if typeof(value) == "table" then
        themes.deriveStrokes(resolved, overrides)
    end

    -- Keep font fallback behavior compatible with existing custom themes.
    local userTable = if typeof(value) == "table" then value else nil
    if not (userTable and (userTable.Font or userTable.font)) then
        resolved.Font = variables.brandFont(Enum.FontWeight.Medium)
    end
    if not (userTable and (userTable.TitleFont or userTable.titleFont)) then
        resolved.TitleFont = variables.brandFont(Enum.FontWeight.SemiBold)
    end
    return resolved
end

return themes
