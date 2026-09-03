local variables = require(script.Parent.utilities.variables)
local image = require(script.Parent.utilities.image)
local locale = require(script.Parent.utilities.locale)
local constants = require(script.Parent.utilities.constants)
local icons = require(script.Parent.utilities.icons)
local types = require(script.Parent.Types)

export type Theme = types.Theme
export type Translator = types.Translator
export type Translations = types.Translations
export type WindowConfiguration = types.WindowConfiguration

export type WindowProps = types.WindowProps
export type TabProps = types.TabProps
export type TagProps = types.TagProps
export type SectionProps = types.SectionProps
export type GroupProps = types.GroupProps
export type ButtonProps = types.ButtonProps
export type ToggleProps = types.ToggleProps
export type SliderProps = types.SliderProps
export type DropdownProps = types.DropdownProps
export type InputProps = types.InputProps
export type KeybindProps = types.KeybindProps
export type ColorPickerProps = types.ColorPickerProps
export type StatProps = types.StatProps
export type ProgressProps = types.ProgressProps
export type ConsoleProps = types.ConsoleProps
export type TextProps = types.TextProps
export type DividerProps = types.DividerProps
export type NotifyProps = types.NotifyProps
export type ToastProps = types.ToastProps
export type PopupBox = types.PopupBox
export type PopupOption = types.PopupOption
export type PopupProps = types.PopupProps

export type Moveable = types.Moveable
export type Lockable = types.Lockable
export type Window = types.Window
export type Tab = types.Tab
export type Group = types.Group
export type Button = types.Button
export type Toggle = types.Toggle
export type Slider = types.Slider
export type Dropdown = types.Dropdown
export type Input = types.Input
export type Keybind = types.Keybind
export type ColorPicker = types.ColorPicker
export type Stat = types.Stat
export type Progress = types.Progress
export type Console = types.Console
export type Section = types.Section
export type TabSection = types.TabSection
export type Text = types.Text
export type Divider = types.Divider
export type Tag = types.Tag
export type Popup = types.Popup
export type Astra = types.Astra

type WindowModule = { new: (types.WindowProps) -> types.Window }

local astra = {} :: Astra
local activeWindow: types.Window? = nil

-- Public icon catalog.
-- Use astra.Icons.get(name, pack) for explicit pack selection.
astra.Icons = icons

function astra:CreateWindow(properties: types.WindowProps): types.Window
    local existing = activeWindow
    if existing then
        local state = existing :: any
        if state.unloaded then
            activeWindow = nil
        elseif state.settings and state.settings.antiWindowDuplicate ~= false then
            return existing
        end
    end

    local made, result = pcall(function()
        return (require(script.Parent.ui.window) :: WindowModule).new(properties)
    end)
    if not made then
        error(result, 0)
    end

    local built = result :: types.Window
    activeWindow = built
    if variables.secureMode then
        task.defer(function()
            image.preload(function(failed, failedRoles)
                if failed <= 0 or built.unloaded then
                    return
                end
                local roleText = if #failedRoles > 0
                    then table.concat(failedRoles, ", ")
                    else "optional window icon"
                built:Notify({
                    title = locale.resolve("Optional icon warning"),
                    content = locale.resolve("Failed to load: ") .. roleText,
                })
            end)
        end)
    end
    if variables.secureMode then
                        task.spawn(function()
            local body = variables.fontManager:loadFont(constants.fontAsset, Enum.FontWeight.Medium)
            local title = variables.fontManager:loadFont(constants.fontAsset, Enum.FontWeight.SemiBold)
                        if
                not built.unloaded
                and body
                and title
                and body ~= variables.fallbackFont
                and title ~= variables.fallbackFont
            then
                built:ChangeTheme({ Font = body, TitleFont = title })
            end
        end)
    end

    if not built.unloaded then
        built:Show()
    end

    return built
end

return astra
