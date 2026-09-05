local a1 = require(script.Parent.layouts)

local a2 = {}

export type Profile = {
                defaultSize: Vector2,
    minSize: Vector2,

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

local a4 = {
    top = {
        defaultSize = Vector2.new(685, 450),
        minSize = Vector2.new(560, 350),

                                                maxOccupancyX = 0.86,
        topbarClearance = 36,
        marginFloorX = 24,
        marginFloorY = 28,

                                        maxAspectRatio = 2.3,
        widthCompensation = 130,

        chromeHeight = a1.top.chromeHeight,
    } :: Profile,
    sidebar = {
        defaultSize = Vector2.new(685, 450),
                        minSize = Vector2.new(560, 350),

                                maxOccupancyX = 0.92,
        maxOccupancyY = 0.8,
        marginFloorX = 24,
        marginFloorY = 28,

        maxAspectRatio = 2.6,
        minAspectRatio = 1.2,

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
    local a29 = math.min(math.clamp(a27, a26.minSize.X, a26.defaultSize.X), a27)
    local a30 = math.min(math.clamp(a28, a26.minSize.Y, a26.defaultSize.Y), a28)

                        a30 = math.floor(math.min(a30, a29 / (a26.minAspectRatio :: number)))
    a29 = math.floor(math.min(a29, a30 * a26.maxAspectRatio))

    return UDim2.fromOffset(a29, a30)
end

function a2.fit(a31: Vector2?, a32: layouts.Mode?): UDim2
    local a33 = a4.sidebar

    if not a31 or a31.X < a3 or a31.Y < a3 then
        return UDim2.fromOffset(a33.defaultSize.X, a33.defaultSize.Y)
    end

    local a34 = math.min(a31.X * a33.maxOccupancyX, a31.X - a33.marginFloorX)
    local a35 = a10(a33, a31.Y)

    if a33.minAspectRatio then
        return a25(a33, a34, a35)
    end
    return a18(a33, a34, a35)
end

return a2
