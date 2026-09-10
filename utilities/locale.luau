local locale = require(script.Parent.Parent.core.state)
local translator = require(script.Parent.log)

local translations = {}

export type LocaleToken = { [any]: string }
export type Translator = (source: string, localeId: string) -> string?
export type TranslationTables = { [string]: { [string]: string } }

translations.strings = {} :: TranslationTables
translations.current = "en"
translations.translator = nil :: Translator?

local currentLocale = {}

local function a5(id: string): string
    return string.match(id, "^(%a+)") or id
end

function translations.t(a6: unknown): unknown
    if type(a6) ~= "string" or a6 == "" then
        return a6
    end
    return { [currentLocale] = a6 }
end

function translations.isToken(a7: unknown): boolean
    return type(a7) == "table" and type((a7 :: { [any]: unknown })[currentLocale]) == "string"
end

function translations.sourceOf(a8: LocaleToken): string
    return a8[currentLocale]
end

function translations.resolve(a9: unknown): any
    if type(a9) ~= "string" then
        return a9
    end

    if translations.translator then
        local ok, a10 = pcall(translations.translator, a9, translations.current)
        if ok and type(a10) == "string" and a10 ~= "" then
            return a10
        end
    end

    local a11 = translations.strings[translations.current]
    if a11 and a11[a9] then
        return a11[a9]
    end

    local a12 = translations.strings[a5(translations.current)]
    if a12 and a12[a9] then
        return a12[a9]
    end

    return a9
end

function translations.register(a13: TranslationTables?)
    if type(a13) ~= "table" then
        return
    end
    for id, a14 in a13 do
        if type(id) == "string" and type(a14) == "table" then
            id = string.lower(id)
            local a15 = translations.strings[id]
            if not a15 then
                a15 = {}
                translations.strings[id] = a15
            end
            for a16, a17 in a14 do
                if type(a16) == "string" and type(a17) == "string" then
                    a15[a16] = a17
                else
                    translator.warn(`Astra: skipping a '{id}' translation, entries must be string to string.`)
                end
            end
        end
    end
end

function translations.setActive(a18: string?): string
    translations.current = if type(a18) == "string" and a18 ~= "" then string.lower(a18) else "en"
    return translations.current
end

function translations.detect(): string
    local id = locale.localizationService.RobloxLocaleId
    if type(id) == "string" and id ~= "" then
        return string.lower(id)
    end
    return "en"
end

return translations
