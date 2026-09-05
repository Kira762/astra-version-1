local a1 = {}

function a1.contrastColor(a2: Color3): Color3
    local a3 = 0.299 * a2.R + 0.587 * a2.G + 0.114 * a2.B
    return if a3 > 0.5 then Color3.fromRGB(0, 0, 0) else Color3.fromRGB(255, 255, 255)
end

function a1.toColorSequence(a4: Color3 | ColorSequence): ColorSequence
    return if typeof(a4) == "ColorSequence" then a4 else ColorSequence.new(a4)
end

function a1.contrastText(a5: Color3): Color3
    local a6 = 0.299 * a5.R + 0.587 * a5.G + 0.114 * a5.B
    return if a6 > 0.6 then Color3.fromRGB(20, 20, 20) else Color3.fromRGB(255, 255, 255)
end

return a1
