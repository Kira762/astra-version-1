
local a1 = {}

a1.ids = {
    close = 83277910885129,
    minimise = 108115485663409,
    maximise = 88738500661569,
    settings = 129180860773723,
    search = 100604009889706,
    chevron = 88479147175134,
    check = 125626312718314,
    dot = 91452555903853,
    colorpicker = 91452555903853,
    config = 125823673784681,
}

a1.roles = {
    close = "close",
    minimise = "minimise",
    maximise = "maximise",
    settings = "settings",
    search = "search",
    chevron = "chevron",
    check = "check",
    dot = "dot",
    colorpicker = "colorpicker",
    config = "config",
}

function a1.manifest()
    local a2: { [number]: { roles: { string } } } = {}
    for a3, id in a1.ids do
        local a4 = a2[id]
        if not a4 then
            a4 = { roles = {} }
            a2[id] = a4
        end
        table.insert(a4.roles, a1.roles[a3] or a3)
    end
    return a2
end

function a1.roleForId(id: number): string
    local a5 = a1.manifest()[id]
    if not a5 or #a5.roles == 0 then
        return "window icon"
    end
    return table.concat(a5.roles, "/")
end

function a1.roleList(): { string }
    local a6 = {}
    for a7 in a1.ids do
        table.insert(a6, a1.roles[a7] or a7)
    end
    table.sort(a6)
    return a6
end

return a1
