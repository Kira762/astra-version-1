local utilities = script.Parent.Parent.utilities
local constants = require(utilities.constants)
local locale = require(utilities.locale)
local haptic = require(utilities.HapticEngine)
local profilePanel = require(script.Parent.profilePanel)

local settingsComponent = {}

local function layoutKey(layout)
    if type(layout) == "table" and layout.mode == "sidebar" and layout.forceCollapsed then
        return "collapsedSidebar"
    end
    return if type(layout) == "table" and layout.mode then layout.mode else "top"
end

-- [[Input is the library's only element, so the built-in settings panel is typed
-- [[rather than clicked: every setting is an Input whose field shows the value
-- [[that is active right now, and committing new text applies it. Three parsing
-- [[helpers cover the shapes a setting takes - a switch, a choice from a fixed
-- [[list, and a key name - and each one answers nil for text it cannot honour,
-- [[which is the caller's cue to put the active value back in the field.
local switchWords = {
    on = true, ["true"] = true, yes = true, y = true, ["1"] = true, enabled = true,
    off = false, ["false"] = false, no = false, n = false, ["0"] = false, disabled = false,
}

local function parseSwitch(text)
    local word = string.lower(tostring(text or "")):gsub("%s+", "")
    local parsed = switchWords[word]
    if parsed == nil then
        return nil
    end
    return parsed
end

local function parseChoice(options, text)
    local wanted = string.lower(tostring(text or "")):gsub("%s+", " ")
    for _, option in options do
        if string.lower(option.label) == wanted or string.lower(option.key) == wanted then
            return option.key
        end
    end
    return nil
end

local function choiceLabel(options, key)
    for _, option in options do
        if option.key == key then
            return option.label
        end
    end
    return ""
end

local function choiceList(options)
    local labels = {}
    for _, option in options do
        table.insert(labels, option.label)
    end
    return table.concat(labels, ", ")
end

local function parseKeyCode(text)
    local name = string.upper(tostring(text or ""):gsub("%s+", ""))
    if name == "" then
        return nil
    end
    -- [[The engine raises on a key name it does not know, so the lookup is
    -- [[guarded: an unknown name is a rejected setting, not a crash.]]
    local ok, item = pcall(function()
        return Enum.KeyCode[name]
    end)
    if ok and typeof(item) == "EnumItem" then
        return item
    end
    return nil
end

function settingsComponent.buildUI(window)
    if window._settingsUIBuilt then
        return
    end
    window._settingsUIBuilt = true
    local appearance = window:CreateTab({ name = "Appearance", icon = "palette", customOrder = 1002, forgetState = true, isSettingsTab = true })
    local persistence = window:CreateTab({ name = "Persistence", icon = "save", customOrder = 1003, forgetState = true, isSettingsTab = true })
    local about = window:CreateTab({ name = "About", icon = "info", customOrder = 1004, forgetState = true, isSettingsTab = true })
    for _, tab in { appearance, persistence, about } do
        tab._isSettingsTab = true
        table.insert(window._settingsTabs, tab)
    end

    -- [[The settings shells are created on first settings access.]]
    -- [[Each tab's elements are created the first time that tab is opened]]
    -- [[(see _buildSettingsContent), so opening the window stays fast. The]]
    -- [[builders run at most once, in the original creation order.]]
    window._settingsContentBuilt = window._settingsContentBuilt or {}

    -- [[A setting that cannot honour what was typed puts the active value back
    -- [[and says why: the field is the panel's only readout, so it must never
    -- [[show something the window is not using.]]
    local function reject(input, message, active)
        input:Set(active, true)
        window:Notify({ title = locale.resolve("Settings"), content = message })
    end

    local function switchSetting(tab, spec)
        local function activeLabel()
            return if spec.get() then "On" else "Off"
        end
        local input
        input = tab:CreateInput({
            name = spec.name,
            icon = spec.icon,
            description = spec.description,
            placeholder = "On / Off",
            value = activeLabel(),
            forgetState = true,
            callback = function(text)
                local parsed = parseSwitch(text)
                if parsed == nil then
                    reject(input, `'${text}' is not a switch value - type On or Off.`, activeLabel())
                    return
                end
                spec.set(parsed)
                input:Set(activeLabel(), true)
            end,
        })
        return input
    end

    local function choiceSetting(tab, spec)
        local function activeLabel()
            local label = choiceLabel(spec.options, spec.get())
            return if label ~= "" then label else choiceLabel(spec.options, spec.options[1] and spec.options[1].key)
        end
        local input
        input = tab:CreateInput({
            name = spec.name,
            icon = spec.icon,
            description = spec.description or `Type one of: {choiceList(spec.options)}.`,
            placeholder = activeLabel(),
            value = activeLabel(),
            forgetState = true,
            callback = function(text)
                local key = parseChoice(spec.options, text)
                if not key then
                    reject(input, `'${text}' is not one of: {choiceList(spec.options)}.`, activeLabel())
                    return
                end
                -- [[The setter owns the field while it works: a choice that
                -- [[confirms through a popup applies from the popup's own
                -- [[callback, later, and retypes the field there.]]
                spec.set(key, input, choiceLabel(spec.options, key))
                input:Set(activeLabel(), true)
            end,
        })
        return input
    end

    local function buildAbout()
        about:CreateInput({
            name = "Rayfield Gen2",
            icon = "info",
            description = "Rayfield Gen2 is a ground-up rebuild of the Rayfield Interface Suite, built entirely in code for a faster, more stable, and more consistent experience.",
            placeholder = "About",
            forgetState = true,
        })
        about:CreateInput({
            name = "Highlights",
            description = "State can persist between sessions, themes can change at runtime, labels can be translated, and the interface is designed for both desktop and mobile.",
            placeholder = "About",
            forgetState = true,
        })
        about:CreateInput({
            name = "Astra",
            icon = "sparkles",
            description = "Astra began from Rayfield Gen2 and was reshaped into a distinct interface library with its own visual language, behavior, and features: a responsive, customizable interface with persistent settings, runtime themes, localization support and animated window transitions.",
            placeholder = "About",
            forgetState = true,
        })
        about:CreateInput({
            name = "Customized by Haijo",
            description = "Originally from Rayfield, Astra is customized, refined, and maintained by Haijo.",
            placeholder = "About",
            forgetState = true,
        })
        about:CreateInput({
            name = "Documentation",
            icon = "link",
            description = "The field holds the documentation address; select it to copy it out.",
            value = "https://docs.sirius.menu/rayfield-gen2",
            placeholder = "docs.sirius.menu",
            forgetState = true,
        })
    end
    about._settingsContentBuilder = buildAbout

    local function buildGeneral()
        local settingsTab = window.rfSettings

        local function keyLabel()
            local keybind = window.settings.toggleKeybind
            return if keybind then tostring(keybind.Name) else ""
        end

        local keybindInput
        keybindInput = settingsTab:CreateInput({
            name = "Toggle Keybind",
            icon = constants.icons.search,
            description = "Type the key that shows or hides the window, e.g. K or F3.",
            placeholder = "Key name",
            value = keyLabel(),
            forgetState = true,
            callback = function(text)
                local keyCode = parseKeyCode(text)
                if not keyCode then
                    reject(keybindInput, `'${text}' is not a key name - try K, F3 or LeftShift.`, keyLabel())
                    return
                end
                window.settings.toggleKeybind = keyCode
                window:SaveSettings()
                keybindInput:Set(keyLabel(), true)
            end,
        })

        switchSetting(settingsTab, {
            name = "Unlock cursor while open",
            description = "Type On to free the cursor while the window is open.",
            get = function() return window.settings.mouseOverride end,
            set = function(value)
                window.settings.mouseOverride = value
                window:SaveSettings()
            end,
        })
        switchSetting(settingsTab, {
            name = "Welcome toast",
            description = "Type On to greet the player when the window opens.",
            get = function() return window.settings.welcomeToast end,
            set = function(value)
                window.settings.welcomeToast = value
                window:SaveSettings()
            end,
        })
        switchSetting(settingsTab, {
            name = "Prevent duplicate windows",
            description = "Type On to close an older window when a new one is created.",
            get = function() return window.settings.antiWindowDuplicate end,
            set = function(value)
                window.settings.antiWindowDuplicate = value
                window:SaveSettings()
            end,
        })
        switchSetting(settingsTab, {
            name = "Keep window on screen",
            description = "Type On to pull the window back when it would leave the viewport.",
            get = function() return window.settings.keepOnScreen end,
            set = function(value)
                window.settings.keepOnScreen = value
                window:SaveSettings()
            end,
        })
        switchSetting(settingsTab, {
            name = "Draggable capsule",
            description = "Type On to drag the minimised bar around the screen.",
            get = function() return window.settings.dragMinimisedBar == true end,
            set = function(value)
                window.settings.dragMinimisedBar = value == true
                window:SaveSettings()
            end,
        })
        switchSetting(settingsTab, {
            name = "Haptics",
            description = "Type On for controller and touch feedback on interaction.",
            get = function() return window.settings.haptics end,
            set = function(value)
                window.settings.haptics = value
                haptic.setEnabled(value)
                window:SaveSettings()
            end,
        })

        choiceSetting(settingsTab, {
            name = "Animation speed",
            icon = "gauge",
            description = "Type Relaxed, Normal, Snappy or Instant.",
            options = {
                { key = "relaxed", label = "Relaxed" },
                { key = "normal", label = "Normal" },
                { key = "snappy", label = "Snappy" },
                { key = "instant", label = "Instant" },
            },
            get = function() return window.settings.motionSpeed end,
            set = function(profile)
                if profile == window.settings.motionSpeed then
                    return
                end
                window.settings.motionSpeed = profile
                window:_applyMotionSetting()
                window:SaveSettings()
            end,
        })

        local resetInput
        resetInput = settingsTab:CreateInput({
            name = "Reset Positions",
            icon = "layout",
            description = "Type window, capsule or both to put it back where it started.",
            placeholder = "window / capsule",
            value = "",
            forgetState = true,
            callback = function(text)
                local target = string.lower(tostring(text or ""):gsub("%s+", ""))
                if target == "window" then
                    window:_recenterForProfile(true)
                elseif target == "capsule" then
                    window:_resetCapsulePosition()
                elseif target == "both" then
                    window:_recenterForProfile(true)
                    window:_resetCapsulePosition()
                else
                    reject(resetInput, `'${text}' is not a position to reset - type window, capsule or both.`, "")
                    return
                end
                resetInput:Set("", true)
            end,
        })
    end
    window.rfSettings._settingsContentBuilder = buildGeneral

    local function buildAppearance()
        local themeOptions = {
            { key = "default", label = "Default" },
            { key = "amethyst", label = "Amethyst" },
            { key = "cobalt", label = "Cobalt" },
            { key = "crimson", label = "Crimson" },
            { key = "ember", label = "Ember" },
            { key = "emerald", label = "Emerald" },
            { key = "frost", label = "Frost" },
            { key = "gold", label = "Gold" },
            { key = "onyx", label = "Onyx" },
            { key = "rose", label = "Rose" },
        }

        choiceSetting(appearance, {
            name = "Theme",
            icon = "palette",
            description = "Type a theme name; the change is confirmed before it is applied.",
            options = themeOptions,
            get = function()
                return if choiceLabel(themeOptions, window.settings.theme) ~= "" then window.settings.theme else "default"
            end,
            set = function(key, input, label)
                if key == window.settings.theme then
                    window:Notify({ title = locale.resolve("Theme"), content = `The {label} theme is already active.` })
                    return
                end
                window:Popup({
                    title = locale.resolve("Apply theme?"),
                    content = `Apply the {label} theme to this window?`,
                    options = {
                        { text = locale.resolve("Cancel") },
                        {
                            text = locale.resolve("Apply"),
                            style = "primary",
                            callback = function()
                                window.settings.theme = key
                                window:ChangeTheme(key)
                                window:SaveSettings()
                                input:Set(label, true)
                                window:Notify({ title = locale.resolve("Theme applied"), subtitle = label })
                            end,
                        },
                    },
                })
            end,
        })

        local layoutOptions = {
            { key = "top", label = "Default Topbar" },
            { key = "sidebar", label = "Sidebar (Responsive)" },
            { key = "collapsedSidebar", label = "Collapsed Sidebar" },
        }

        choiceSetting(appearance, {
            name = "Bar Layout",
            icon = "panel-left",
            description = "Type a layout name; the switch is confirmed before it happens.",
            options = layoutOptions,
            get = function()
                return window.settings.layoutMode or layoutKey(window.layout)
            end,
            set = function(key, input, label)
                if key == layoutKey(window.layout) then
                    window:Notify({ title = locale.resolve("Bar layout"), content = `The {label} layout is already active.` })
                    return
                end
                window:Popup({
                    title = locale.resolve("Apply bar layout?"),
                    content = `Are you sure you want to change the layout to {label}?`,
                    options = {
                        { text = locale.resolve("Cancel") },
                        {
                            text = locale.resolve("Apply"),
                            style = "primary",
                            callback = function()
                                if window:_setLayoutMode(key) then
                                    window.settings.layoutMode = key
                                    window:SaveSettings()
                                    input:Set(label, true)
                                    window:Notify({ title = locale.resolve("Bar layout changed"), content = `Switched to the {label} layout.` })
                                else
                                    input:Set(choiceLabel(layoutOptions, layoutKey(window.layout)), true)
                                    window:Notify({ title = locale.resolve("Bar layout"), content = locale.resolve("The selected bar layout could not be applied right now.") })
                                end
                            end,
                        },
                    },
                })
            end,
        })

        -- [[The two profile settings depend on each other (hiding the card
        -- [[clears its detail reveal), so the reveal field is declared before
        -- [[the card's switch is built and filled in below it.]]
        local revealInput
        switchSetting(appearance, {
            name = "Show profile",
            icon = "user",
            description = "Type On to show the profile card beside the window.",
            get = function() return window.settings.showProfile end,
            set = function(value)
                -- [[Hiding the card clears its detail reveal too, so the]]
                -- [[reveal field has to read Off the moment that happens.]]
                if profilePanel.setEnabled(window, value) and revealInput then
                    revealInput:Set("Off", true)
                end
                window:SaveSettings()
            end,
        })

        choiceSetting(appearance, {
            name = "Profile side",
            description = "Type Right or Left.",
            options = {
                { key = "right", label = "Right" },
                { key = "left", label = "Left" },
            },
            get = function()
                return if (window.settings.profileSide or "right") == "left" then "left" else "right"
            end,
            set = function(side)
                if (window.settings.profileSide or "right") == side then
                    return
                end
                profilePanel.setSide(window, side)
                window:SaveSettings()
            end,
        })

        revealInput = switchSetting(appearance, {
            name = "Reveal profile details",
            description = "Type On to spell out the full username on the profile card.",
            get = function() return window.settings.showFullUsername end,
            set = function(value)
                if not profilePanel.setReveal(window, value) then
                    -- [[The card refused (it is hidden), so the switch stays where
                    -- [[the panel actually is instead of showing a lie.]]
                    revealInput:Set(if window.settings.showFullUsername then "On" else "Off", true)
                end
                window:SaveSettings()
            end,
        })
    end
    appearance._settingsContentBuilder = buildAppearance

    local function buildPersistence()
        switchSetting(persistence, {
            name = "Auto Save Config",
            icon = "save",
            description = "Type On to write the configuration whenever a value changes.",
            get = function() return window.settings.autoSaveConfig end,
            set = function(value)
                window.settings.autoSaveConfig = value
                window.configuration.autoSave = value
                window:SaveSettings()
            end,
        })
        switchSetting(persistence, {
            name = "Auto Load Config",
            description = "Type On to load the saved configuration when the window opens.",
            get = function() return window.settings.autoLoadConfig end,
            set = function(value)
                window.settings.autoLoadConfig = value
                window.configuration.autoLoad = value
                window:SaveSettings()
            end,
        })

        -- [[The list of configurations on disk, retyped after every action that
        -- [[changes it. It is a field like the rest of the panel: the name the
        -- [[action below works on is the one typed beside it.]]
        local function configListValue()
            return table.concat(window:ListConfigs(), ", ")
        end

        local configList = persistence:CreateInput({
            name = "Saved Configurations",
            icon = constants.icons.config,
            description = "Every configuration on disk for this window.",
            placeholder = "No saved configurations",
            value = configListValue(),
            forgetState = true,
        })

        local configName = persistence:CreateInput({
            name = "Configuration Name",
            icon = constants.icons.config,
            description = "The name the action below saves to, loads or deletes.",
            placeholder = "e.g. PvP Loadout",
            clearOnFocus = false,
            forgetState = true,
        })

        local actionInput
        actionInput = persistence:CreateInput({
            name = "Config Action",
            icon = constants.icons.config,
            description = "Type save, load, delete or list and press enter.",
            placeholder = "save / load / delete",
            value = "",
            forgetState = true,
            callback = function(text)
                local action = string.lower(tostring(text or ""):gsub("%s+", ""))
                actionInput:Set("", true)

                if action == "list" then
                    local configs = window:ListConfigs()
                    window:Notify({
                        title = locale.resolve("Saved configurations"),
                        content = if #configs > 0 then table.concat(configs, ", ") else locale.resolve("No saved configurations"),
                    })
                    return
                end

                local name = configName.value
                if name == "" then
                    name = window.configuration.fileName or "Configuration"
                end

                if action == "save" then
                    if window:Save(name) then
                        configName:Set("")
                        configList:Set(configListValue(), true)
                        window:Toast({
                            title = locale.resolve("Saved configuration"),
                            subtitle = name,
                            icon = constants.icons.config,
                        })
                    else
                        window:Toast({ title = locale.resolve("Couldn't save configuration"), subtitle = name })
                    end
                    return
                end

                if action == "load" then
                    if window:_applyNamedConfig(name) then
                        window:Toast({ title = locale.resolve("Loaded configuration"), subtitle = name })
                    else
                        window:Toast({ title = locale.resolve("Couldn't load configuration"), subtitle = name })
                    end
                    return
                end

                if action == "delete" then
                    if window:DeleteConfig(name) then
                        configName:Set("")
                        configList:Set(configListValue(), true)
                        window:Toast({ title = locale.resolve("Deleted configuration"), subtitle = name })
                    else
                        window:Toast({ title = locale.resolve("Couldn't delete configuration"), subtitle = name })
                    end
                    return
                end

                window:Notify({
                    title = locale.resolve("Settings"),
                    content = `'${text}' is not a configuration action - type save, load, delete or list.`,
                })
            end,
        })
    end
    persistence._settingsContentBuilder = buildPersistence
end

function settingsComponent.buildContent(window, tab)
    settingsComponent.buildUI(window)
    -- [[Lazy settings content: a tab's elements are created the first]]
    -- [[time it is opened, keeping window construction fast. The pcall]]
    -- [[keeps one bad element from taking the whole window down.]]
    if window._settingsContentBuilt[tab] or not tab._settingsContentBuilder then
        return
    end
    window._settingsContentBuilt[tab] = true
    local ok, err = pcall(tab._settingsContentBuilder)
    if not ok then
        window:Notify({ title = "Settings", content = "Some settings content failed to load: " .. tostring(err) })
    end
end

function settingsComponent.applySettingsLayout(window, isSettings)
    window._settingsLayoutActive = isSettings == true
    if window.tabList then
        window.tabList.Visible = not window.hidden and not window.minimised
    end
    if window.sidebar then
        window.sidebar.Visible = not window.hidden and not window.minimised
    end
    for _, tab in window.tabs do
        if tab.topbarItem then
            tab.topbarItem.Visible = not window.hidden and not window.minimised
                and (window._settingsMode == (tab._isSettingsTab == true))
        end
    end
    if window.selectedTab and window.selectedTab.tabPage then
        window.selectedTab.tabPage.Size = if window.layout.mode == "sidebar" then UDim2.new(1, -35, 1, 0) else UDim2.new(1, -20, 1, 0)
        window.selectedTab.tabPage.Position = if window.layout.mode == "sidebar" then UDim2.new(0, 35, 0, 0) else UDim2.new(0, 0, 0, 0)
    end
    -- [[The visible rail group changed: re-derive the responsive rail's]]
    -- [[width from the tabs now shown (no-op for the other layouts).]]
    window:_applyContentRailWidth()
end

function settingsComponent.toggleSettingsMode(window)
    if window._settingsMode then
        local previousTab = window._previousTab
        window._previousTab = nil
        if previousTab and previousTab.window == window and previousTab.tabPage and not previousTab._isSettingsTab then
            previousTab:Select()
            return
        end
        for _, tab in window.tabs do
            if not tab._isSettingsTab and tab.window == window and tab.tabPage then
                tab:Select()
                return
            end
        end
        return
    end

    window._previousTab = window.selectedTab
    window.rfSettings:Select()
end

function settingsComponent.setSettingsMode(window, active)
    active = active == true
    if active and window._constructed then
        settingsComponent.buildUI(window)
    end
    window._settingsMode = active
    if active and window._previousTab == nil and window.selectedTab and not window.selectedTab._isSettingsTab then
        window._previousTab = window.selectedTab
    end
    for _, tab in window.tabs do
        if tab.topbarItem then
            tab.topbarItem.Visible = not window.hidden and not window.minimised
                and (active == (tab._isSettingsTab == true))
        end
    end
    settingsComponent.applySettingsLayout(window, active)
end

return settingsComponent
