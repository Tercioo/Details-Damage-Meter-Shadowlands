if (true) then
    return
end


local Details = _G.Details
local DF = _G.DetailsFramework
local Loc = _G.LibStub("AceLocale-3.0"):GetLocale("Details")
local SharedMedia = _G.LibStub:GetLibrary("LibSharedMedia-3.0")
local LDB = _G.LibStub ("LibDataBroker-1.1", true)
local LDBIcon = LDB and _G.LibStub("LibDBIcon-1.0", true)

--options panel namespace
Details.options = {}

local tinsert = _G.tinsert
local unpack = _G.unpack
local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent
local _
local preset_version = 3
Details.preset_version = preset_version

--templates
local options_text_template = DF:GetTemplate ("font", "OPTIONS_FONT_TEMPLATE")
local options_dropdown_template = DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
local options_switch_template = DF:GetTemplate ("switch", "OPTIONS_CHECKBOX_TEMPLATE")
local options_slider_template = DF:GetTemplate ("slider", "OPTIONS_SLIDER_TEMPLATE")
local options_button_template = DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE")

--options settings
local startX, startY, heightSize = 10, -130, 710
local optionsWidth, optionsHeight = 1100, 650
local mainHeightSize = 800

--build the options window
function Details.options.InitializeOptionsWindow()
	--local DetailsOptionsWindow = DF:NewPanel(UIParent, _, "DetailsOptionsWindow", _, 897, 592)
    local DetailsOptionsWindow = CreateFrame("frame", "DetailsOptionsWindow", UIParent, "BackdropTemplate")
    DetailsOptionsWindow:SetSize(897, 592)
    local f = DetailsOptionsWindow
    DetailsOptionsWindow.Frame = f

	f.__name = "Options"
	f.real_name = "DETAILS_OPTIONS"
    f.__icon = [[Interface\Scenarios\ScenarioIcon-Interact]]
    f.tabContainer = {}
    f:Hide()

    _G.DetailsPluginContainerWindow.EmbedPlugin(f, f, true)

    --total amount of sections
    DETAILS_OPTIONS_AMOUNT_SECTION = 1

    function Details.options.GetOptionsSection(sectionId)
        return f.tabContainer[sectionId]
    end

    function Details.options.SelectOptionsSection(sectionId)
        for i = 1, DETAILS_OPTIONS_AMOUNT_SECTION do
            f.tabContainer[i]:Hide()
        end
        f.tabContainer[sectionId]:Show()
    end

    --create frames for sections
    for i = 1, DETAILS_OPTIONS_AMOUNT_SECTION do
        local tabFrame = CreateFrame("frame", "$parentTab" .. i, f, "BackdropTemplate")
        tabFrame:SetAllPoints()
        tinsert(f.tabContainer, tabFrame)

        local buildOptionSectionFunc = Details.optionsSection[i]
        buildOptionSectionFunc()
    end
end

-- ~options
function Details:OpenOptionsWindow(instance, no_reopen, section)
	if (not instance.GetId or not instance:GetId()) then
		instance, no_reopen, section = unpack(instance)
    end

    if (not no_reopen and not instance:IsEnabled() or not instance:IsStarted()) then
        Details:CreateInstance(instance:GetId())
	end

    GameCooltip:Close()

    local window = _G.DetailsOptionsWindow
    if (not window) then
        Details.options.InitializeOptionsWindow()
        window = _G.DetailsOptionsWindow
    end

    Details.options.UpdateCurrentInstanceOnOptionsPanel(instance)
    if (section) then
        Details.options.SelectOptionsSection(section)
    end

    window:Show()
end