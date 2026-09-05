local a1 = {}

function a1.getService(a2)
    local a3 = game:GetService(a2)
    return if cloneref then cloneref(a3) else a3
end

return a1
