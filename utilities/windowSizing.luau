local a1 = require(script.Parent.layouts)

local a2 = {}

export type Profile = {
	defaultSize: Vector2,
	minSize: Vector2,
	maxSize: Vector2?,
	maxOccupancyX: number,
	maxOccupancyY: number?,
	marginFloorX: number,
	marginFloorY: number,
	topbarClearance: number?,
	maxAspectRatio: number,
	minAspectRatio: number?,
	widthCompensation: number?,
	chromeHeight: number,
}

local a3 = 200

-- Responsive profiles: larger defaults so desktop doesn't look tiny.
-- Mobile still uses occupancy-based shrink, so phone keeps full-width feel
-- while desktop gets a premium large window (same perceived weight).
local a4 = {
	top = {
		defaultSize = Vector2.new(720, 600),
		minSize = Vector2.new(500, 330),
		maxSize = Vector2.new(860, 580),
		maxOccupancyX = 0.88,
		topbarClearance = 36,
		marginFloorX = 20,
		marginFloorY = 20,
		maxAspectRatio = 2.3,
		widthCompensation = 100,
		chromeHeight = a1.top.chromeHeight,
	} :: Profile,
	sidebar = {
		defaultSize = Vector2.new(720, 600),
		minSize = Vector2.new(540, 360),
		maxSize = Vector2.new(880, 600),
		maxOccupancyX = 0.92,
		maxOccupancyY = 0.84,
		marginFloorX = 20,
		marginFloorY = 20,
		maxAspectRatio = 2.6,
		minAspectRatio = 1.18,
		chromeHeight = a1.sidebar.chromeHeight,
	} :: Profile,
}

function a2.profile(a5: layouts.Mode?): Profile
	if a5 == "sidebar" then
		return a4.sidebar
	end
	return a4.top
end

function a2.pageHeight(a6: number?, a7: layouts.Mode?): number
	local a8 = a2.profile(a7)
	local a9 = if a6 and a6 > 0 then a6 else a8.minSize.Y
	return math.max(a9 - a8.chromeHeight, 0)
end

local function a10(a11: Profile, a12: number): number
	local a13 = a12 - a11.marginFloorY
	if a11.topbarClearance then
		a13 = math.min(a13, a12 - a11.topbarClearance * 2)
	end
	if a11.maxOccupancyY then
		a13 = math.min(a13, a12 * a11.maxOccupancyY)
	end
	return a13
end

local function a14(a15: number, a16: number, a17: number): number
	return math.clamp((a16 - a15) / (a16 - a17), 0, 1)
end

local function a18(a19: Profile, a20: number, a21: number): UDim2
	local a22 = math.floor(math.min(math.clamp(a21, a19.minSize.Y, a19.defaultSize.Y), a21))
	local a23 = a14(a22, a19.defaultSize.Y, a19.minSize.Y)
	local a24 = math.max(a19.defaultSize.X + (a19.widthCompensation :: number) * a23, a19.minSize.X)
	return UDim2.fromOffset(math.floor(math.min(a24, a20, a22 * a19.maxAspectRatio)), a22)
end

local function a25(a26: Profile, a27: number, a28: number): UDim2
    -- The Sidebar keeps its historical 540px minimum for user resizing, while
    -- its requested base width is 520px. Keep clamp bounds ordered for the
    -- responsive fit calculation without changing the declared minimum.
    local a29Min = math.min(a26.minSize.X, a26.defaultSize.X)
    local a29 = math.min(math.clamp(a27, a29Min, a26.defaultSize.X), a27)
	local a30 = math.min(math.clamp(a28, a26.minSize.Y, a26.defaultSize.Y), a28)
	a30 = math.floor(math.min(a30, a29 / (a26.minAspectRatio :: number)))
	a29 = math.floor(math.min(a29, a30 * a26.maxAspectRatio))
	return UDim2.fromOffset(a29, a30)
end

-- Tiered occupancy: phone/tablet/desktop share same perceived scale.
-- Desktop uses lower occupancy so 1920px doesn't give 1766px window (too huge),
-- but still larger than old 685 cap.
local function getTieredOccupancy(a31: Vector2, a32: Profile): (number, number)
	local w = a31.X
	if w < 700 then
		-- phone: near full width, like before
		return a32.maxOccupancyX, a10(a32, a31.Y)
	elseif w < 1200 then
		-- tablet / small laptop
		return math.min(a32.maxOccupancyX, 0.72), math.min(a10(a32, a31.Y), a31.Y * 0.82)
	else
		-- desktop: keep premium large but not full-screen
		return 0.52, math.min(a10(a32, a31.Y), a31.Y * 0.72)
	end
end

function a2.fit(a31: Vector2?, a32: layouts.Mode?): UDim2
	-- Fix: respect mode (old code always used sidebar)
	local a33 = if a32 == "top" then a4.top else a4.sidebar
	if not a31 or a31.X < a3 or a31.Y < a3 then
		return UDim2.fromOffset(a33.defaultSize.X, a33.defaultSize.Y)
	end
	-- tiered target based on screen size
	local occX, availY = getTieredOccupancy(a31, a33)
	local a34 = math.min(a31.X * occX, a31.X - a33.marginFloorX)
	-- clamp to maxSize so desktop doesn't explode on ultrawide
	if a33.maxSize then
		a34 = math.min(a34, a33.maxSize.X)
		availY = math.min(availY, a33.maxSize.Y)
	end
	local a35 = availY
	if a33.minAspectRatio then
		return a25(a33, a34, a35)
	end
	return a18(a33, a34, a35)
end

-- UIScale helper: same physical perception mobile vs desktop.
function a2.scaleForViewport(a36: Vector2?): number
	if not a36 or a36.X < a3 then return 1 end
	-- 390 -> 0.92, 768 -> 0.98, 1280 -> 1.04, 1920 -> 1.12, 2560 -> 1.18 (clamped)
	local s = 0.88 + (a36.X / 2200) * 0.32
	-- y also matters on portrait phones: don't let tall narrow screens over-scale
	if a36.Y < 500 then s = math.min(s, 0.95) end
	return math.clamp(s, 0.88, 1.18)
end

return a2
