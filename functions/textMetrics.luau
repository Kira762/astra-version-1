local a1 = require(script.Parent.Parent.core.state)
local a2 = a1.textService

local a3 = {}

local a4: { [string]: number } = {}
local a5 = 0
local a6 = 1024
local a7: { [string]: number } = {}
local a8 = 0
local a9 = 1024

local function a10(a11: string, a12: Font, a13: number, a14: number): GetTextBoundsParams
	local a15 = Instance.new("GetTextBoundsParams")
	a15.Text = a11
	a15.Font = a12
	a15.Size = a13
	a15.Width = a14
	return a15
end

local function a16(a17: GetTextBoundsParams): unknown
    local ok, a18 = pcall(function()
        return a2:GetTextBoundsAsync(a17)
    end)
    return if ok then a18 else nil
end

local function a19(a20: unknown, a21: "X" | "Y"): number?
    if typeof(a20) == "Vector2" then
        return if a21 == "X" then a20.X else a20.Y
    end
    if type(a20) == "table" and type((a20 :: any)[a21]) == "number" then
        return (a20 :: any)[a21]
    end
    return nil
end

function a3.textWidth(a22: Font, a23: number, a24: any): number
    a24 = tostring(a24)
    local a25 = tostring(a22.Family)
        .. "|"
        .. tostring(a22.Weight)
        .. "|"
        .. tostring(a22.Style)
        .. "|"
        .. tostring(a23)
        .. "|"
        .. a24
    local a26 = a4[a25]
    if a26 then
        return a26
    end

    local a27 = a19(a16(a10(a24, a22, a23, math.huge)), "X")
    if not a27 then
        local a28 = utf8.len(a24) or #a24
        return math.ceil(a23 * 0.55 * a28)
    end

    local a29 = math.ceil(a27)
    if a5 >= a6 then
        a4 = {}
        a5 = 0
    end
    a4[a25] = a29
    a5 += 1
    return a29
end

function a3.textHeight(a30: Font, a31: number, a32: any, a33: number): number
    a32 = tostring(a32)
    local a34 = tostring(a30.Family)
        .. "|"
        .. tostring(a30.Weight)
        .. "|"
        .. tostring(a30.Style)
        .. "|"
        .. tostring(a31)
        .. "|"
        .. tostring(a33)
        .. "|"
        .. a32
    local a35 = a7[a34]
    if a35 then
        return a35
    end

    local a36 = a19(a16(a10(a32, a30, a31, a33)), "Y")
    if not a36 then
        return a31
    end

    local a37 = math.ceil(a36)
    if a8 >= a9 then
        a7 = {}
        a8 = 0
    end
    a7[a34] = a37
    a8 += 1
    return a37
end

return a3
