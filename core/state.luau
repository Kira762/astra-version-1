-- Shared Astra runtime state (core/state.luau).
--
-- Merges the old utilities/runtime.luau (service singletons, secure mode,
-- gui container) and utilities/variables.luau (fallback font, filesystem,
-- asset resolver, font manager singletons) into the single core state module.
-- The API is a superset of both, so existing consumers keep working.

local services = require(script.Parent.Parent.utilities.services)
local constants = require(script.Parent.Parent.utilities.constants)
local log = require(script.Parent.Parent.utilities.log)
local fileSystemManager = require(script.Parent.Parent.utilities.filesystemManager)
local assetResolver = require(script.Parent.Parent.utilities.assetResolver)
local fontManager = require(script.Parent.Parent.utilities.fontManager)

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

local variables = {} :: VariablesState

variables.secureMode = (function()
    if typeof(getgenv) ~= "function" then
        return false
    end
    local ok, val = pcall(function()
        return getgenv().ASTRA_SECURE
    end)
    return ok and val == true
end)()

variables.coreGui = services.getService("CoreGui") :: CoreGui
variables.workspace = services.getService("Workspace") :: Workspace
variables.runService = services.getService("RunService") :: RunService
variables.userInputService = services.getService("UserInputService") :: UserInputService
variables.guiService = services.getService("GuiService") :: GuiService
variables.localPlayer = (services.getService("Players") :: Players).LocalPlayer
variables.tweenService = services.getService("TweenService") :: TweenService
variables.httpService = services.getService("HttpService") :: HttpService
variables.textService = services.getService("TextService") :: TextService
variables.replicatedStorage = services.getService("ReplicatedStorage") :: ReplicatedStorage
variables.localizationService = services.getService("LocalizationService") :: LocalizationService

variables.guiContainer = (function(): Instance
    if variables.runService:IsStudio() then
        local player = variables.localPlayer
        if player then
            return player.PlayerGui
        end
        return variables.coreGui
    end
    if typeof(gethui) == "function" then
        local ok, container = pcall(gethui)
        if ok and container then
            return container
        end
    end
    return variables.coreGui
end)()

log.setSecureModeSource(function()
    return variables.secureMode
end)

variables.fallbackFont = Font.fromEnum(Enum.Font.BuilderSans)

variables.fileSystemManager = fileSystemManager.new()
variables.assetResolver =
    assetResolver.new(true, assetResolver.Enum.AssetDownloadUrl.RoProxyDownloadUrl) :: AssetResolver
variables.fontManager = fontManager.new(
    variables.fileSystemManager:getAssetsFolder("fonts"),
    false,
    true,
    assetResolver.Enum.AssetDownloadUrl.RoProxyDownloadUrl,
    {
        saveToDisk = true,
        skipCache = false,
        fallbackFont = variables.fallbackFont,
    }
) :: FontManager

function variables.setFallbackFont(font: Enum.Font | Font)
    if typeof(font) == "EnumItem" then
        font = Font.fromEnum(font)
    end
    if typeof(font) == "Font" then
        variables.fallbackFont = font
        variables.fontManager.defaultOptions.fallbackFont = font
    end
end

function variables.brandFont(weight: Enum.FontWeight?): Font
    if variables.secureMode then
        return Font.new(variables.fallbackFont.Family, weight)
    end
    return Font.new(constants.fontAsset, weight)
end

return variables
