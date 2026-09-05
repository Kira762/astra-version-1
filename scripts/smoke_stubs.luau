-- Minimal Roblox environment stubs for smoke-testing the Astra bundle
-- under the Luau CLI (`sh scripts/smoke_test_bundle.sh`).
--
-- Scope: ONLY what module-load time touches. Nothing here pretends to build
-- real UI. This file is concatenated before the bundle, so its locals are
-- visible to the bundle code as upvalues (line offsets stay intact).

local function makeProxy(name)
	local proxy
	proxy = setmetatable({}, {
		__index = function(_, key)
			if key == "Name" then
				return name
			end
			return function(...)
				return makeProxy(name .. "." .. tostring(key))
			end
		end,
		__tostring = function()
			return name
		end
	})
	return proxy
end

local servicesByName = {}
local function getService(name)
	if servicesByName[name] == nil then
		servicesByName[name] = makeProxy("ServiceProvider." .. name)
	end
	return servicesByName[name]
end

-- Players.LocalPlayer must be a table-like, not a function
servicesByName["Players"] = setmetatable({}, {
	__index = function(_, key)
		if key == "LocalPlayer" then
			return makeProxy("Player.LocalPlayer")
		end
		return function(...)
			return makeProxy("Players." .. tostring(key))
		end
	end
})

game = setmetatable({}, {
	__index = function(_, key)
		if key == "GetService" then
			return function(_, name)
				return getService(name)
			end
		end
		return makeProxy("game." .. tostring(key))
	end
})

-- RunService:IsStudio() drives the native-filesystem probe; return false so
-- the bundle takes the same "no native FS" path it would in a plain executor.
local runService = setmetatable({}, {
	__index = function(_, key)
		if key == "IsStudio" then
			return function()
				return false
			end
		end
		return function(...)
			return makeProxy("RunService." .. tostring(key))
		end
	end
})
servicesByName["RunService"] = runService

Enum = setmetatable({}, {
	__index = function()
		return setmetatable({}, {
			__index = function()
				return makeProxy("EnumItem")
			end
		})
	end
})

local function fontFrom(family, weight)
	return { Family = family, Weight = weight }
end

Font = {
	fromEnum = function()
		return fontFrom("rbxasset://fonts/families/BuilderSans.json")
	end,
	new = function(family, weight)
		return fontFrom(family, weight)
	end,
}

local function color3(r, g, b)
	return {
		R = r / 255,
		G = g / 255,
		B = b / 255,
		Lerp = function(self, other, alpha)
			return color3(
				(self.R + (other.R - self.R) * alpha) * 255,
				(self.G + (other.G - self.G) * alpha) * 255,
				(self.B + (other.B - self.B) * alpha) * 255
			)
		end,
	}
end

Color3 = {
	fromRGB = function(r, g, b)
		return color3(r, g, b)
	end,
	new = function(r, g, b)
		return color3(r * 255, g * 255, b * 255)
	end,
}

ColorSequenceKeypoint = {
	new = function(time, value)
		return { Time = time, Value = value }
	end,
}

ColorSequence = {
	new = function(keypoints)
		return { Keypoints = keypoints }
	end,
}

TweenInfo = {
	new = function(time, easingStyle, easingDirection, repeatCount, reverses, delayTime)
		return {
			Time = time,
			EasingStyle = easingStyle,
			EasingDirection = easingDirection,
			RepeatCount = repeatCount,
			Reverses = reverses,
			DelayTime = delayTime,
		}
	end,
}

local function udim(scale, offset)
	return { Scale = scale or 0, Offset = offset or 0 }
end

UDim = {
	new = udim,
}

UDim2 = {
	new = function(xs, xo, ys, yo)
		return { X = udim(xs, xo), Y = udim(ys, yo) }
	end,
	fromScale = function(xs, ys)
		return { X = udim(xs, 0), Y = udim(ys, 0) }
	end,
	fromOffset = function(xo, yo)
		return { X = udim(0, xo), Y = udim(0, yo) }
	end,
}

Vector2 = {
	new = function(x, y)
		return { X = x or 0, Y = y or 0 }
	end,
}

NumberSequenceKeypoint = {
	new = function(time, value)
		return { Time = time, Value = value }
	end,
}

NumberSequence = {
	new = function(points)
		return { Keypoints = points }
	end,
}

-- getgenv/writefile/readfile/isfile/isfolder/makefolder/listfiles/delfile/
-- delfolder/cloneref stay nil on purpose: the bundle must tolerate executors
-- without them, and that is exactly the path we want to exercise.
