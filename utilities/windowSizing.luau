local layoutMetrics = require(script.Parent.layouts)

local breakpoints = {}

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

local minTrackedViewport = 200

-- [[Responsive profiles: larger defaults so desktop doesn't look tiny.]]
-- [[Mobile still uses occupancy-based shrink, so phone keeps full-width feel]]
-- [[while desktop gets a premium large window (same perceived weight).]]
local profiles = {
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
		chromeHeight = layoutMetrics.top.chromeHeight,
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
		chromeHeight = layoutMetrics.sidebar.chromeHeight,
	} :: Profile,
}

function breakpoints.profile(mode: layouts.Mode?): Profile
	if mode == "sidebar" then
		return profiles.sidebar
	end
	return profiles.top
end

function breakpoints.pageHeight(totalHeight: number?, modeForHeight: layouts.Mode?): number
	local sizingProfile = breakpoints.profile(modeForHeight)
	local height = if totalHeight and totalHeight > 0 then totalHeight else sizingProfile.minSize.Y
	return math.max(height - sizingProfile.chromeHeight, 0)
end

local function availableHeight(heightProfile: Profile, viewportHeight: number): number
	local available = viewportHeight - heightProfile.marginFloorY
	if heightProfile.topbarClearance then
		available = math.min(available, viewportHeight - heightProfile.topbarClearance * 2)
	end
	if heightProfile.maxOccupancyY then
		available = math.min(available, viewportHeight * heightProfile.maxOccupancyY)
	end
	return available
end

local function shrinkFactor(current: number, upper: number, lower: number): number
	return math.clamp((upper - current) / (upper - lower), 0, 1)
end

local function fitTop(topProfile: Profile, maxWidth: number, requestedHeight: number): UDim2
	local clampedHeight = math.floor(math.min(math.clamp(requestedHeight, topProfile.minSize.Y, topProfile.defaultSize.Y), requestedHeight))
	local blend = shrinkFactor(clampedHeight, topProfile.defaultSize.Y, topProfile.minSize.Y)
	local width = math.max(topProfile.defaultSize.X + (topProfile.widthCompensation :: number) * blend, topProfile.minSize.X)
	return UDim2.fromOffset(math.floor(math.min(width, maxWidth, clampedHeight * topProfile.maxAspectRatio)), clampedHeight)
end

local function fitSidebar(sidebarProfile: Profile, requestedWidth: number, requestedSidebarHeight: number): UDim2
    -- [[The Sidebar keeps its historical 540px minimum for user resizing, while]]
    -- [[its requested base width is 520px. Keep clamp bounds ordered for the]]
    -- [[responsive fit calculation without changing the declared minimum.]]
    local minWidthBound = math.min(sidebarProfile.minSize.X, sidebarProfile.defaultSize.X)
    local sidebarWidth = math.min(math.clamp(requestedWidth, minWidthBound, sidebarProfile.defaultSize.X), requestedWidth)
	local sidebarHeight = math.min(math.clamp(requestedSidebarHeight, sidebarProfile.minSize.Y, sidebarProfile.defaultSize.Y), requestedSidebarHeight)
	sidebarHeight = math.floor(math.min(sidebarHeight, sidebarWidth / (sidebarProfile.minAspectRatio :: number)))
	sidebarWidth = math.floor(math.min(sidebarWidth, sidebarHeight * sidebarProfile.maxAspectRatio))
	return UDim2.fromOffset(sidebarWidth, sidebarHeight)
end

-- [[Tiered occupancy: phone/tablet/desktop share same perceived scale.]]
-- [[Desktop uses lower occupancy so 1920px doesn't give 1766px window (too huge),]]
-- [[but still larger than old 685 cap.]]
local function getTieredOccupancy(viewport: Vector2, modeOrProfile: Profile): (number, number)
	local w = viewport.X
	if w < 700 then
		-- [[phone: near full width, like before]]
		return modeOrProfile.maxOccupancyX, availableHeight(modeOrProfile, viewport.Y)
	elseif w < 1200 then
		-- [[tablet / small laptop]]
		return math.min(modeOrProfile.maxOccupancyX, 0.72), math.min(availableHeight(modeOrProfile, viewport.Y), viewport.Y * 0.82)
	else
		-- [[desktop: keep premium large but not full-screen]]
		return 0.52, math.min(availableHeight(modeOrProfile, viewport.Y), viewport.Y * 0.72)
	end
end

function breakpoints.fit(viewport: Vector2?, modeOrProfile: layouts.Mode?): UDim2
	-- [[Fix: respect mode (old code always used sidebar)]]
	local fitProfile = if modeOrProfile == "top" then profiles.top else profiles.sidebar
	if not viewport or viewport.X < minTrackedViewport or viewport.Y < minTrackedViewport then
		return UDim2.fromOffset(fitProfile.defaultSize.X, fitProfile.defaultSize.Y)
	end
	-- [[tiered target based on screen size]]
	local occX, availY = getTieredOccupancy(viewport, fitProfile)
	local targetWidth = math.min(viewport.X * occX, viewport.X - fitProfile.marginFloorX)
	-- [[clamp to maxSize so desktop doesn't explode on ultrawide]]
	if fitProfile.maxSize then
		targetWidth = math.min(targetWidth, fitProfile.maxSize.X)
		availY = math.min(availY, fitProfile.maxSize.Y)
	end
	local targetHeight = availY
	if fitProfile.minAspectRatio then
		return fitSidebar(fitProfile, targetWidth, targetHeight)
	end
	return fitTop(fitProfile, targetWidth, targetHeight)
end

-- [[UIScale helper: same physical perception mobile vs desktop.]]
function breakpoints.scaleForViewport(scaleViewport: Vector2?): number
	if not scaleViewport or scaleViewport.X < minTrackedViewport then return 1 end
	-- [[390 -> 0.92, 768 -> 0.98, 1280 -> 1.04, 1920 -> 1.12, 2560 -> 1.18 (clamped)]]
	local s = 0.88 + (scaleViewport.X / 2200) * 0.32
	-- [[y also matters on portrait phones: don't let tall narrow screens over-scale]]
	if scaleViewport.Y < 500 then s = math.min(s, 0.95) end
	return math.clamp(s, 0.88, 1.18)
end

return breakpoints
