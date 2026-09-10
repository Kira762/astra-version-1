local services = {}

function services.getService(cache)
    local a3 = game:GetService(cache)
    return if cloneref then cloneref(a3) else a3
end

return services
