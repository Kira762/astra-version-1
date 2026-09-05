local a1 = require(script.Parent.Parent.core.state)
local a2 = require(script.Parent.log)

local a3 = {}

export type LocaleToken = { [any]: string }
export type Translator = (source: string, localeId: string) -> string?
export type TranslationTables = { [string]: { [string]: string } }

a3.strings = {} :: TranslationTables
a3.current = "en"
a3.translator = nil :: Translator?

local a4 = {}

local function a5(id: string): string
    return string.match(id, "^(%a+)") or id
end

function a3.t(a6: unknown): unknown
    if type(a6) ~= "string" or a6 == "" then
        return a6
    end
    return { [a4] = a6 }
end

function a3.isToken(a7: unknown): boolean
    return type(a7) == "table" and type((a7 :: { [any]: unknown })[a4]) == "string"
end

function a3.sourceOf(a8: LocaleToken): string
    return a8[a4]
end

function a3.resolve(a9: unknown): any
    if type(a9) ~= "string" then
        return a9
    end

    if a3.translator then
        local ok, a10 = pcall(a3.translator, a9, a3.current)
        if ok and type(a10) == "string" and a10 ~= "" then
            return a10
        end
    end

    local a11 = a3.strings[a3.current]
    if a11 and a11[a9] then
        return a11[a9]
    end

    local a12 = a3.strings[a5(a3.current)]
    if a12 and a12[a9] then
        return a12[a9]
    end

    return a9
end

function a3.register(a13: TranslationTables?)
    if type(a13) ~= "table" then
        return
    end
    for id, a14 in a13 do
        if type(id) == "string" and type(a14) == "table" then
            id = string.lower(id)
            local a15 = a3.strings[id]
            if not a15 then
                a15 = {}
                a3.strings[id] = a15
            end
            for a16, a17 in a14 do
                if type(a16) == "string" and type(a17) == "string" then
                    a15[a16] = a17
                else
                    a2.warn(`Astra: skipping a '{id}' translation, entries must be string to string.`)
                end
            end
        end
    end
end

function a3.setActive(a18: string?): string
    a3.current = if type(a18) == "string" and a18 ~= "" then string.lower(a18) else "en"
    return a3.current
end

function a3.detect(): string
    local id = a1.localizationService.RobloxLocaleId
    if type(id) == "string" and id ~= "" then
        return string.lower(id)
    end
    return "en"
end

return a3
