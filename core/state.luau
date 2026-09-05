
local a1 = require(script.Parent.Parent.utilities.services)
local a2 = require(script.Parent.Parent.utilities.constants)
local a3 = require(script.Parent.Parent.utilities.log)
local a4 = require(script.Parent.Parent.utilities.filesystemManager)
local a5 = require(script.Parent.Parent.utilities.assetResolver)
local a6 = require(script.Parent.Parent.utilities.fontManager)

type FileSystemManager = fileSystemManager.FileSystemManager
type AssetResolver = assetResolver.AssetResolver
type FontManager = fontManager.FontManager

export type VariablesState = {
    secureMode: boolean,
    coreGui: CoreGui,
    workspace: Workspace,
    runService: RunService,
    userInputService: UserInputService,
    guiService: GuiService,
    localPlayer: Player?,
    tweenService: TweenService,
    httpService: HttpService,
    textService: TextService,
    replicatedStorage: ReplicatedStorage,
    localizationService: LocalizationService,
    guiContainer: Instance,

    fallbackFont: Font,
    fileSystemManager: FileSystemManager,
    assetResolver: AssetResolver,
    fontManager: FontManager,
    setFallbackFont: (font: Enum.Font | Font) -> (),
    brandFont: (weight: Enum.FontWeight?) -> Font,
}

local a7 = {} :: VariablesState

a7.secureMode = (function()
    if typeof(getgenv) ~= "function" then
        return false
    end
    local ok, a8 = pcall(function()
        return getgenv().ASTRA_SECURE
    end)
    return ok and a8 == true
end)()

a7.coreGui = a1.getService("CoreGui") :: CoreGui
a7.workspace = a1.getService("Workspace") :: Workspace
a7.runService = a1.getService("RunService") :: RunService
a7.userInputService = a1.getService("UserInputService") :: UserInputService
a7.guiService = a1.getService("GuiService") :: GuiService
a7.localPlayer = (a1.getService("Players") :: Players).LocalPlayer
a7.tweenService = a1.getService("TweenService") :: TweenService
a7.httpService = a1.getService("HttpService") :: HttpService
a7.textService = a1.getService("TextService") :: TextService
a7.replicatedStorage = a1.getService("ReplicatedStorage") :: ReplicatedStorage
a7.localizationService = a1.getService("LocalizationService") :: LocalizationService

a7.guiContainer = (function(): Instance
    if a7.runService:IsStudio() then
        local a9 = a7.localPlayer
        if a9 then
            return a9.PlayerGui
        end
        return a7.coreGui
    end
    if typeof(gethui) == "function" then
        local ok, a10 = pcall(gethui)
        if ok and a10 then
            return a10
        end
    end
    return a7.coreGui
end)()

a3.setSecureModeSource(function()
    return a7.secureMode
end)

a7.fallbackFont = Font.fromEnum(Enum.Font.BuilderSans)

a7.fileSystemManager = a4.new()
a7.assetResolver =
    a5.new(true, a5.Enum.AssetDownloadUrl.RoProxyDownloadUrl) :: AssetResolver
a7.fontManager = a6.new(
    a7.fileSystemManager:getAssetsFolder("fonts"),
    false,
    true,
    a5.Enum.AssetDownloadUrl.RoProxyDownloadUrl,
    {
        saveToDisk = true,
        skipCache = false,
        fallbackFont = a7.fallbackFont,
    }
) :: FontManager

function a7.setFallbackFont(a11: Enum.Font | Font)
    if typeof(a11) == "EnumItem" then
        a11 = Font.fromEnum(a11)
    end
    if typeof(a11) == "Font" then
        a7.fallbackFont = a11
        a7.fontManager.defaultOptions.fallbackFont = a11
    end
end

function a7.brandFont(a12: Enum.FontWeight?): Font
    if a7.secureMode then
        return Font.new(a7.fallbackFont.Family, a12)
    end
    return Font.new(a2.fontAsset, a12)
end

return a7
