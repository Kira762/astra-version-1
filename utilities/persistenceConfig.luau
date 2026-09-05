local a1 = require(script.Parent.Parent.core.state)
local a2 = require(script.Parent.filesystem)
local a3 = require(script.Parent.log)
local a4 = require(script.Parent.path)
local a5 = require(script.Parent.persistencePaths)
local a6 = require(script.Parent.persistenceWrite)

local a7 = {}

type PersistedControl = {
    value: unknown,
    flag: string?,
    _canBeNil: boolean?,
    _serialize: ((PersistedControl) -> unknown)?,
    _deserialize: ((PersistedControl, unknown) -> ())?,
    Set: (PersistedControl, unknown) -> (),
}

type ConfigWindow = {
    controls: { [string]: PersistedControl },
    configuration: {
        fileName: string?,
        customFolder: string?,
    },
    name: string,
    _loading: boolean?,
    _loadedConfig: { [string]: unknown }?,
    _loadedConfigPath: string?,
}

function a7.getPath(window: ConfigWindow, a8: unknown?): (string?, string?)
    return a5.getConfigPath(window, a8)
end

function a7.save(window: ConfigWindow, a9: unknown?): boolean
    local a10, a11 = a7.getPath(window, a9)
    if not a10 or not a11 then
        a3.warn("Astra: configuration name '" .. tostring(a9) .. "' has no usable characters")
        return false
    end

        if typeof(a2.writefile) ~= "function" then
        return false
    end

    local a12: { [string]: unknown } = {}
    for a13, a14 in window.controls do
        local ok, a15 = pcall(function()
            local a16 = a14._serialize
            if a16 then
                return a16(a14)
            end
            return a14.value
        end)
        if ok then
            a12[a13] = a15
        else
            a3.warn("Astra: Failed to serialize flag '" .. tostring(a13) .. "' - " .. tostring(a15))
        end
    end

                local a17 = window._loadedConfig
    if a17 and window._loadedConfigPath == a11 then
        for a18, a19 in a17 do
            if window.controls[a18] == nil then
                a12[a18] = a19
            end
        end
    end

    local a20, a21 = pcall(a1.httpService.JSONEncode, a1.httpService, a12)
    if not a20 then
        a3.warn("Astra: Failed to encode configuration - " .. tostring(a21))
        return false
    end

    local ok, a22 = pcall(function()
        a6.write(a10, a11, a21)
    end)

    if not ok then
        a3.warn("Astra: Failed to save configuration - " .. tostring(a22))
        return false
    end

                if window._loadedConfigPath == nil or window._loadedConfigPath == a11 then
        window._loadedConfig = a12
        window._loadedConfigPath = a11
    end

    return true
end

local function a23(a24: string): ({ [string]: unknown }?, string?)
    if not a2.isfile(a24) then
        return nil, nil
    end

    local a25, a26 = pcall(a2.readfile, a24)
    if not a25 or type(a26) ~= "string" then
        a3.warn("Astra: Failed to read configuration file")
        return nil, nil
    end

    local a27, a28 = pcall(a1.httpService.JSONDecode, a1.httpService, a26)

        if not a27 or type(a28) ~= "table" then
        return nil, a26
    end

    return a28 :: { [string]: unknown }, a26
end

local function a29(a30: string): string
        local a31 = a4.stripExtension(a30, ".rfld")
    local a32 = a31 .. " (Incorrect Format).rfld"
    local a33 = 2
    while a33 <= 100 and a2.isfile(a32) do
        a32 = a31 .. " (Incorrect Format " .. a33 .. ").rfld"
        a33 += 1
    end
    return a32
end

function a7.load(window: ConfigWindow, a34: unknown?): boolean
    local a35, a36 = a7.getPath(window, a34)
    if not a35 or not a36 then
        a3.warn("Astra: configuration name '" .. tostring(a34) .. "' has no usable characters")
        return false
    end

        if typeof(a2.isfile) ~= "function" then
        return false
    end

    local a37, a38 = a23(a36)

            if not a37 and a2.isfile(a36) then
        local a39, a40 = a23(a6.tempPathFor(a36))
        if a39 and a40 then
            a37 = a39
                        pcall(a6.write, a35, a36, a40)
        end
    end

    if not a37 then
        if a38 then
            a3.warn("Astra: Configuration file has an invalid format, backing up and resetting")
            local a41 = a29(a36)
            pcall(function()
                a2.ensureDir(a35)
                a2.writefile(a41, a38)
                a2.delfile(a36)
            end)
        end
        return false
    end

    local a42 = a37 :: { [string]: unknown }
    local a43 = window._loading
    window._loading = true
        local a44, a45 = pcall(function()
        for a46, a47 in window.controls do
            a7.applyTo(a47, a42[a46])
        end
    end)
            window._loading = a43
    if not a44 then
        a3.warn("Astra: Failed to apply configuration - " .. tostring(a45))
    end

                window._loadedConfig = a42
    window._loadedConfigPath = a36

    return true
end

function a7.applyTo(a48: PersistedControl, a49: unknown)
    if a49 == nil and not a48._canBeNil then
        return
    end
    local ok, a50 = pcall(function()
        local a51 = a48._deserialize
        if a51 then
            a51(a48, a49)
        else
            a48:Set(a49)
        end
    end)
    if not ok then
        a3.warn("Astra: Failed to restore flag '" .. tostring(a48.flag) .. "' - " .. tostring(a50))
    end
end

function a7.list(window: ConfigWindow): { string }
    local a52 = a7.getPath(window)

    local a53: { string } = {}
        if not a52 then
        return a53
    end
    local ok, a54 = pcall(a2.listfiles, a52)
    if not ok or type(a54) ~= "table" then
        return a53
    end

    for _, a55 in a54 do
        local a56 = a4.basename(a55)
                        if a56:sub(-5) == ".rfld" then
            local a57 = a4.stripExtension(a56, ".rfld")
            if a57 and a57 ~= "" and not a57:find(" %(Incorrect Format[^%)]*%)$") then
                table.insert(a53, a57)
            end
        end
    end

    table.sort(a53)
    return a53
end

function a7.delete(window: ConfigWindow, a58: unknown): boolean
    if type(a58) ~= "string" or a58 == "" then
        return false
    end

    local _, a59 = a7.getPath(window, a58)
    if not a59 then
        return false
    end
    if typeof(a2.isfile) ~= "function" or not a2.isfile(a59) then
        return false
    end

        pcall(a2.delfile, a6.tempPathFor(a59))

    return (pcall(a2.delfile, a59))
end

return a7
