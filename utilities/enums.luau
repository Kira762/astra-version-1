local a1 = {}

function a1.itemFromValue(a2, a3)
    local ok, a4 = pcall(function()
        return a2:FromValue(a3)
    end)
    if ok and a4 then
        return a4
    end

    local a5, a6 = pcall(function()
        return a2:GetEnumItems()
    end)
    if not a5 then
        return nil
    end

    for _, a7 in a6 do
        if a7.Value == a3 then
            return a7
        end
    end

    return nil
end

return a1
