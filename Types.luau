export type Theme = string | { [string]: any }

export type Translator = (source: string, localeId: string) -> string?

export type Translations = { [string]: { [string]: string } }
export type IconPack = "lucide" | "material" | "tabler" | "phosphor" | "heroicons" | "feather"

export type WindowConfiguration = {
    autoSave: boolean?,
    autoLoad: boolean?,
    fileName: string?,
    customFolder: string?,
}

export type WindowProps = {
    name: string?,
    subtitle: string?,
    theme: Theme?,
    icon: (string | number)?,
    showName: string?,
    showIcon: (string | number)?,
    showIconOnly: boolean?,     profile: string?,     configuration: WindowConfiguration?,
    fallbackFont: (Font | Enum.Font)?,     locale: string?,     translations: Translations?,     translator: Translator?, }

export type TabProps = {
    name: string?,
    icon: (string | number)?,
}

-- [[The declarative element shape. Input is the library's only element, so it
-- [[is the only `type` a definition can name.]]
export type CollapsibleElementProps = {
    type: "Input",
    [string]: any,
}

-- [[Input is the only element: its props, its instance type, and the]]
-- [[`Tab:CreateInput` constructor below are the whole element surface.]]
export type InputProps = {
    name: string?,
    icon: (string | number)?,
    flag: string?,
    value: string?,
    placeholder: string?,
    numeric: boolean?,
    clearOnFocus: boolean?,
    forgetState: boolean?,
    callback: ((value: string) -> ())?,
}

export type NotifyProps = {
    title: string?,
    content: string?,
    icon: (string | number)?,
    duration: number?,
}

export type ToastProps = {
    title: string?,
    subtitle: string?,     subtitleAbove: boolean?,     icon: (string | number)?,     avatar: number?,     minWidth: number?,     duration: number?,
    position: "Top" | "Bottom"?,
}

export type PopupBox = {
    title: string?,
    description: string?,
    icon: (string | number)?,
}

export type PopupOption = {
    text: string?,
    style: string?,     callback: (() -> ())?,
}

export type PopupProps = {
    title: string?,
    subtitle: string?,
    icon: (string | number)?,
    content: string?,     boxes: { PopupBox }?,     options: { PopupOption }?,     dismissable: boolean?, }

export type Moveable = {
    MoveTo: (self: any, index: number) -> (),
    MoveToTop: (self: any) -> (),
    MoveToBottom: (self: any) -> (),
    MoveUp: (self: any) -> (),
    MoveDown: (self: any) -> (),
}

export type Lockable = {
    Lock: (self: any, reason: string?) -> (),
    Unlock: (self: any) -> (),
    IsLocked: (self: any) -> boolean,
}

export type Input = Moveable & Lockable & {
    value: string,
    Set: (self: Input, value: string, skipCallback: boolean?) -> (),
    -- [[Retype the empty field's hint; the box re-measures against it.]]
    SetPlaceholder: (self: Input, placeholder: string) -> (),
}

export type Popup = {
    Close: (self: Popup) -> (),
}

export type Tab = {
    Select: (self: Tab, noAnimation: boolean?) -> (),
    Deselect: (self: Tab, noAnimation: boolean?) -> (),
    Remove: (self: Tab) -> (),
    CreateInput: (self: Tab, props: InputProps) -> Input,
}

export type Window = {
    unloaded: boolean,
    ResolveIcon: (self: Window, value: (string | number)?, pack: IconPack?) -> (string | number)?,
    Flags: { [string]: any },
    CreateTab: (self: Window, props: TabProps) -> Tab,
    Notify: (self: Window, props: NotifyProps) -> (),
    Toast: (self: Window, props: ToastProps) -> (),
    Popup: (self: Window, props: PopupProps) -> Popup?,     Show: (self: Window) -> (),
    Hide: (self: Window) -> (),
    ToggleHide: (self: Window) -> (),
    ToggleMinimise: (self: Window) -> (),
    Navigate: (self: Window, tab: string | Tab) -> (),
    ChangeTheme: (self: Window, theme: Theme) -> (),
    SetLocale: (self: Window, localeId: string) -> (),
    SetTranslator: (self: Window, translator: Translator?) -> (),
    RegisterTranslations: (self: Window, translations: Translations) -> (),
    Save: (self: Window, name: string?) -> boolean,
    Load: (self: Window, name: string?) -> boolean,
    ListConfigs: (self: Window) -> { string },
    DeleteConfig: (self: Window, name: string) -> boolean,
    GetPath: (self: Window) -> (string, string),
    Get: (self: Window, flag: string) -> any,
    Set: (self: Window, flag: string, value: any) -> boolean,
    Unload: (self: Window) -> (),
}

export type IconCatalog = {
    Lucide: IconPack,
    Material: IconPack,
    Tabler: IconPack,
    Phosphor: IconPack,
    Heroicons: IconPack,
    Feather: IconPack,
    -- [[`name` may be a bare icon name (searched in every pack, in priority]]
    -- [[order) or a pack-qualified `"pack:name"`; `pack` addresses one pack.]]
    get: (name: string, pack: IconPack?) -> string?,
    getByPack: (pack: IconPack, name: string) -> string?,
    list: (pack: IconPack?) -> { string },
    packs: () -> { string },
    count: (pack: IconPack?) -> number,
    isPack: (pack: string?) -> boolean,
    priority: () -> { string },
    loaded: () -> { string },
    refreshCustom: () -> number,
    resolve: (value: (string | number)?, pack: IconPack?) -> (string | number)?,
}

export type MotionSpec = string | TweenInfo

-- [[The service is a plain table of functions (dot calls, like `Icons`),
-- [[so the fields carry no `self` - `Astra.Motion.tween(frame, props)`.
export type MotionService = {
    enabled: boolean,
    timeScale: number,
    profile: string,
    profiles: { [string]: { timeScale: number?, enabled: boolean? } },
    specNames: { string },
    spec: (spec: MotionSpec?) -> TweenInfo,
    step: (base: number) -> number,
    setTimeScale: (scale: number) -> number,
    getTimeScale: () -> number,
    setEnabled: (enabled: boolean) -> boolean,
    isEnabled: () -> boolean,
    setProfile: (name: string) -> boolean,
    getProfile: () -> string,
    cancel: (instance: Instance?) -> boolean,
    tween: (instance: Instance?, props: { [string]: any }, spec: MotionSpec?, onCompleted: (() -> ())?) -> Tween?,
    set: (instance: Instance?, props: { [string]: any }) -> (),
}

export type Astra = {
    CreateWindow: (self: Astra, props: WindowProps) -> Window,
    Icons: IconCatalog,
    Motion: MotionService,
}

return {}
