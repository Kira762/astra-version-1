local variables = require(script.Parent.Parent.core.state)
local textService = variables.textService

local textMetrics = {}

local widthCache: { [string]: number } = {}
local widthCacheCount = 0
local widthCacheCap = 1024
local heightCache: { [string]: number } = {}
local heightCacheCount = 0
local heightCacheCap = 1024

-- A fresh params instance per measurement: GetTextBoundsAsync yields, so a
-- shared params object would race with any concurrent textWidth/textHeight
-- call and could measure another call's text.
local function makeParams(text: string, font: Font, size: number, width: number): GetTextBoundsParams
	local params = Instance.new("GetTextBoundsParams")
	params.Text = text
	params.Font = font
	params.Size = size
	params.Width = width
	return params
end

local function getTextBounds(params: GetTextBoundsParams): unknown
    local ok, bounds = pcall(function()
        return textService:GetTextBoundsAsync(params)
    end)
    return if ok then bounds else nil
end

local function boundAxis(bounds: unknown, axis: "X" | "Y"): number?
    if typeof(bounds) == "Vector2" then
        return if axis == "X" then bounds.X else bounds.Y
    end
    if type(bounds) == "table" and type((bounds :: any)[axis]) == "number" then
        return (bounds :: any)[axis]
    end
    return nil
end

function textMetrics.textWidth(font: Font, size: number, text: any): number
    text = tostring(text)
    local key = tostring(font.Family)
        .. "|"
        .. tostring(font.Weight)
        .. "|"
        .. tostring(font.Style)
        .. "|"
        .. tostring(size)
        .. "|"
        .. text
    local cached = widthCache[key]
    if cached then
        return cached
    end

    local measuredWidth = boundAxis(getTextBounds(makeParams(text, font, size, math.huge)), "X")
    if not measuredWidth then
        local length = utf8.len(text) or #text
        return math.ceil(size * 0.55 * length)
    end

    local width = math.ceil(measuredWidth)
    if widthCacheCount >= widthCacheCap then
        widthCache = {}
        widthCacheCount = 0
    end
    widthCache[key] = width
    widthCacheCount += 1
    return width
end

function textMetrics.textHeight(font: Font, size: number, text: any, width: number): number
    text = tostring(text)
    local key = tostring(font.Family)
        .. "|"
        .. tostring(font.Weight)
        .. "|"
        .. tostring(font.Style)
        .. "|"
        .. tostring(size)
        .. "|"
        .. tostring(width)
        .. "|"
        .. text
    local cached = heightCache[key]
    if cached then
        return cached
    end

    local measuredHeight = boundAxis(getTextBounds(makeParams(text, font, size, width)), "Y")
    if not measuredHeight then
        return size
    end

    local height = math.ceil(measuredHeight)
    if heightCacheCount >= heightCacheCap then
        heightCache = {}
        heightCacheCount = 0
    end
    heightCache[key] = height
    heightCacheCount += 1
    return height
end

return textMetrics
