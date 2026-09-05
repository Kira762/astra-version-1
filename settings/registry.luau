-- Built-in settings registry (settings/registry.luau).
--
-- Declares every supported built-in Astra setting: its type for validation
-- and its domain (appearance / behavior / performance). These definitions are
-- data, not UI; the window's Settings page renders them and the manager
-- validates writes against this registry.

local registry = {}

export type SettingDefinition = {
    key: string,
    kind: "boolean" | "keybind" | "enum",
    domain: "appearance" | "behavior" | "performance",
    description: string?,
}

registry.definitions = {
    toggleKeybind = {
        key = "toggleKeybind",
        kind = "keybind",
        domain = "behavior",
        description = "Keybind used to show/hide the window.",
    },
    mouseOverride = {
        key = "mouseOverride",
        kind = "boolean",
        domain = "behavior",
        description = "Unlocks the cursor while the window is open.",
    },
    keepOnScreen = {
        key = "keepOnScreen",
        kind = "boolean",
        domain = "appearance",
        description = "Keeps the window clamped inside the viewport.",
    },
    welcomeToast = {
        key = "welcomeToast",
        kind = "boolean",
        domain = "behavior",
        description = "Shows a 'Signed in as' toast on first open of a new account.",
    },
    haptics = {
        key = "haptics",
        kind = "boolean",
        domain = "performance",
        description = "Toggles haptic feedback on supported devices.",
    },
    showProfile = {
        key = "showProfile",
        kind = "boolean",
        domain = "appearance",
        description = "Shows the account profile in the active bar layout.",
    },
    showFullUsername = {
        key = "showFullUsername",
        kind = "boolean",
        domain = "appearance",
        description = "Shows the full Roblox username instead of the masked one.",
    },
    antiWindowDuplicate = {
        key = "antiWindowDuplicate",
        kind = "boolean",
        domain = "behavior",
        description = "Prevents creating another window while one is active.",
    },
    layoutMode = {
        key = "layoutMode",
        kind = "enum",
        domain = "appearance",
        description = "Bar layout mode: top, sidebar, or collapsedSidebar.",
    },
}

function registry.definition(key: string): SettingDefinition?
    return registry.definitions[key]
end

function registry.keys(): { string }
    local keys = {}
    for key in registry.definitions do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

return registry
