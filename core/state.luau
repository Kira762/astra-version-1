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

local state = {} :: VariablesState

state.secureMode = (function()
	if typeof(getgenv) ~= "function" then
		return false
	end
	local ok, result = pcall(function()
		return getgenv().ASTRA_SECURE
	end)
	return ok and result == true
end)()

state.coreGui = services.getService("CoreGui") :: CoreGui
state.workspace = services.getService("Workspace") :: Workspace
state.runService = services.getService("RunService") :: RunService
state.userInputService = services.getService("UserInputService") :: UserInputService
state.guiService = services.getService("GuiService") :: GuiService
state.localPlayer = (services.getService("Players") :: Players).LocalPlayer
state.tweenService = services.getService("TweenService") :: TweenService
state.httpService = services.getService("HttpService") :: HttpService
state.textService = services.getService("TextService") :: TextService
state.replicatedStorage = services.getService("ReplicatedStorage") :: ReplicatedStorage
state.localizationService = services.getService("LocalizationService") :: LocalizationService

state.guiContainer = (function(): Instance
	if state.runService:IsStudio() then
		local player = state.localPlayer
		if player then
			return player.PlayerGui
		end
		return state.coreGui
	end
	if typeof(gethui) == "function" then
		local ok, hui = pcall(gethui)
		if ok and hui then
			return hui
		end
	end
	return state.coreGui
end)()

log.setSecureModeSource(function()
	return state.secureMode
end)

state.fallbackFont = Font.fromEnum(Enum.Font.BuilderSans)

state.fileSystemManager = fileSystemManager.new()
state.assetResolver =
	assetResolver.new(true, assetResolver.Enum.AssetDownloadUrl.RoProxyDownloadUrl) :: AssetResolver
state.fontManager = fontManager.new(
	state.fileSystemManager:getAssetsFolder("fonts"),
	false,
	true,
	assetResolver.Enum.AssetDownloadUrl.RoProxyDownloadUrl,
	{
		saveToDisk = true,
		skipCache = false,
		fallbackFont = state.fallbackFont,
	}
) :: FontManager

function state.setFallbackFont(font: Enum.Font | Font)
	if typeof(font) == "EnumItem" then
		font = Font.fromEnum(font)
	end
	if typeof(font) == "Font" then
		state.fallbackFont = font
		state.fontManager.defaultOptions.fallbackFont = font
	end
end

function state.brandFont(weight: Enum.FontWeight?): Font
	if state.secureMode then
		return Font.new(state.fallbackFont.Family, weight)
	end
	return Font.new(constants.fontAsset, weight)
end

return state
