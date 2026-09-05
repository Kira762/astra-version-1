local a1 = require(script.Parent.core)
local a2 = require(script.Parent.core.state)
local a3 = require(script.Parent.images.image)
local a4 = require(script.Parent.utilities.locale)
local a5 = require(script.Parent.utilities.constants)
local a6 = require(script.Parent.icons)
local a7 = require(script.Parent.settings)
local a8 = require(script.Parent.Types)

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

local a9 = {} :: Astra
local a10: types.Window? = nil
local a11 = "__ASTRA_ACTIVE_WINDOW_V1"

local function a12(): { [string]: any }
    local a13 = _G :: any
    local ok, a14 = pcall(function()
        return (getgenv :: any)()
    end)
    return if ok and type(a14) == "table" then a14 else a13
end

local a15 = a12()

a9.Icons = a6

a9.Core = a1
a9.Settings = a7

function a9:CreateWindow(a16: types.WindowProps): types.Window
    local a17 = a10 or a15[a11]
    a10 = a17
    if a17 then
        local a18 = a17 :: any
        if a18.unloaded then
            a10 = nil
            if a15[a11] == a17 then
                a15[a11] = nil
            end
        else
            local a19 = a7.readPersisted("antiWindowDuplicate", true)
            if a19 and (not a18.settings or a18.settings.antiWindowDuplicate ~= false) then
                a18:Unload()
                a10 = nil
                if a15[a11] == a17 then
                    a15[a11] = nil
                end
            end
        end
    end

    local a20, a21 = pcall(function()
        return (require(script.Parent.components.window) :: WindowModule).new(a16)
    end)
    if not a20 then
        error(a21, 0)
    end

    local a22 = a21 :: types.Window
    a10 = a22
    a15[a11] = a22
    if a2.secureMode then
        task.defer(function()
            a3.preload(function(a23, a24)
                if a23 <= 0 or a22.unloaded then
                    return
                end
                local a25 = if #a24 > 0
                    then table.concat(a24, ", ")
                    else "optional window icon"
                a22:Notify({
                    title = a4.resolve("Optional icon warning"),
                    content = a4.resolve("Failed to load: ") .. a25,
                })
            end)
        end)
    end
    if a2.secureMode then
                        task.spawn(function()
            local a26 = a2.fontManager:loadFont(a5.fontAsset, Enum.FontWeight.Medium)
            local a27 = a2.fontManager:loadFont(a5.fontAsset, Enum.FontWeight.SemiBold)
                        if
                not a22.unloaded
                and a26
                and a27
                and a26 ~= a2.fallbackFont
                and a27 ~= a2.fallbackFont
            then
                a22:ChangeTheme({ Font = a26, TitleFont = a27 })
            end
        end)
    end

    if not a22.unloaded then
        a22:Show()
    end

    return a22
end

return a9
