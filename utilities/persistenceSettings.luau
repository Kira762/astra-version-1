local a1 = require(script.Parent.Parent.core.state)
local a2 = require(script.Parent.filesystem)
local a3 = require(script.Parent.persistencePaths)
local a4 = require(script.Parent.persistenceWrite)
local a5 = require(script.Parent.enums)

local a6 = {}

type SettingsWindow = {
    settings: {
        toggleKeybind: EnumItem,
        mouseOverride: boolean,
        keepOnScreen: boolean,
        welcomeToast: boolean,
        haptics: boolean,
        showProfile: boolean,
        showFullUsername: boolean,
        antiWindowDuplicate: boolean,
        layoutMode: string,
        activeSubTab: number,
    },
}

type DecodedSettings = {
    toggleKeybind: { [number]: unknown }?,
    mouseOverride: unknown?,
    keepOnScreen: unknown?,
    welcomeToast: unknown?,
        haptics: unknown?,
        showProfile: unknown?,
        showFullUsername: unknown?,    antiWindowDuplicate: unknown?,
    layoutMode: unknown?,
    activeSubTab: unknown?,
}

function a6.getSettingsPath(): (string, string)
    return a3.getSettingsPath()
end

function a6.saveSettings(window: SettingsWindow): boolean
    local a7, a8 = a6.getSettingsPath()

    local a9: { [string]: unknown } = {
        toggleKeybind = {
            tostring(window.settings.toggleKeybind.EnumType),
            window.settings.toggleKeybind.Value,
        } :: { unknown },
        mouseOverride = window.settings.mouseOverride,
        keepOnScreen = window.settings.keepOnScreen,
        welcomeToast = window.settings.welcomeToast,
        haptics = window.settings.haptics,
        showProfile = window.settings.showProfile,
        showFullUsername = window.settings.showFullUsername,
        antiWindowDuplicate = window.settings.antiWindowDuplicate,
        layoutMode = window.settings.layoutMode,
        activeSubTab = window.settings.activeSubTab,
    }

    local ok, a10 = pcall(a1.httpService.JSONEncode, a1.httpService, a9)
    if not ok then
        return false
    end

    local a11 = pcall(a4.write, a7, a8, a10)

    if not a11 then
        return false
    end

    return true
end

local function a12(a13: string): (DecodedSettings?, string?)
    local a14 = false
    pcall(function()
        a14 = a2.isfile(a13)
    end)
    if not a14 then
        return nil, nil
    end

    local a15, a16 = pcall(a2.readfile, a13)
    if not a15 or type(a16) ~= "string" then
        return nil, nil
    end

    local a17, a18 = pcall(a1.httpService.JSONDecode, a1.httpService, a16)
        if not a17 or type(a18) ~= "table" then
        return nil, a16
    end

        return a18 :: DecodedSettings, a16
end

local function a19(): DecodedSettings?
    local a20, a21 = a6.getSettingsPath()
    local a22 = a12(a21)
    if a22 then
        return a22
    end

    local a23, a24 = a12(a4.tempPathFor(a21))
    if a23 and a24 then
        pcall(a4.write, a20, a21, a24)
        return a23
    end

    return nil
end

function a6.loadSettings(window: SettingsWindow): boolean
    local a25 = a19()

    if not a25 then
        return false
    end

    if a25.toggleKeybind then
        pcall(function()
            local a26 = tostring(a25.toggleKeybind[1]):gsub("^Enum%.", "")
            local a27 = (Enum :: any)[a26]
            if a27 then
                local a28 = a5.itemFromValue(a27, a25.toggleKeybind[2])
                if a28 then
                    window.settings.toggleKeybind = a28
                end
            end
        end)
    end

    if type(a25.mouseOverride) == "boolean" then
        window.settings.mouseOverride = a25.mouseOverride
    end

    if type(a25.keepOnScreen) == "boolean" then
        window.settings.keepOnScreen = a25.keepOnScreen
    end

    if type(a25.welcomeToast) == "boolean" then
        window.settings.welcomeToast = a25.welcomeToast
    end

    if type(a25.haptics) == "boolean" then
        window.settings.haptics = a25.haptics
    end

    if type(a25.showProfile) == "boolean" then
        window.settings.showProfile = a25.showProfile
    end
    if type(a25.showFullUsername) == "boolean" then
        window.settings.showFullUsername = a25.showFullUsername
    end
    if type(a25.antiWindowDuplicate) == "boolean" then
        window.settings.antiWindowDuplicate = a25.antiWindowDuplicate
    end
    if a25.layoutMode == "top"
        or a25.layoutMode == "sidebar"
        or a25.layoutMode == "collapsedSidebar"
    then
        window.settings.layoutMode = a25.layoutMode
    end

    if type(a25.activeSubTab) == "number" and a25.activeSubTab >= 1 then
        window.settings.activeSubTab = math.floor(a25.activeSubTab)
    end

    return true
end

return a6
