
local a1 = {}

export type SettingDefinition = {
    key: string,
    kind: "boolean" | "keybind" | "enum",
    domain: "appearance" | "behavior" | "performance",
    description: string?,
}

a1.definitions = {
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
    activeSubTab = {
        key = "activeSubTab",
        kind = "enum",
        domain = "appearance",
        description = "Index of the currently selected settings sub-tab.",
    },
}

function a1.definition(a2: string): SettingDefinition?
    return a1.definitions[a2]
end

function a1.keys(): { string }
    local a3 = {}
    for a4 in a1.definitions do
        table.insert(a3, a4)
    end
    table.sort(a3)
    return a3
end

return a1
