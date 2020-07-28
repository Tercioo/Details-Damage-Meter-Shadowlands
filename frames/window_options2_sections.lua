if (true) then
    return
end


local Details = _G.Details
local DF = _G.DetailsFramework
local Loc = _G.LibStub("AceLocale-3.0"):GetLocale("Details")
local SharedMedia = _G.LibStub:GetLibrary("LibSharedMedia-3.0")
local LDB = _G.LibStub ("LibDataBroker-1.1", true)
local LDBIcon = LDB and _G.LibStub("LibDBIcon-1.0", true)
local _

local tinsert = _G.tinsert

local startX = 200
local startY = -60

--templates
local options_text_template = DF:GetTemplate ("font", "OPTIONS_FONT_TEMPLATE")
local options_dropdown_template = DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
local options_switch_template = DF:GetTemplate ("switch", "OPTIONS_CHECKBOX_TEMPLATE")
local options_slider_template = DF:GetTemplate ("slider", "OPTIONS_SLIDER_TEMPLATE")
local options_button_template = DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE")

--store the current instance being edited
local currentInstance

function Details.options.UpdateCurrentInstanceOnOptionsPanel(instance)
    currentInstance = instance
    _G.DetailsOptionsWindow.instance = instance

    --get all the frames created and update the options
    for i = 1, _G.DETAILS_OPTIONS_AMOUNT_SECTION do
        Details.options.GetOptionsSection(i):RefreshOptions()
    end
end

function Details.options.GetCurrentInstanceInOptionsPanel()
    return currentInstance
end

local afterUpdate = function()
    _detalhes:SendOptionsModifiedEvent(currentInstance)
end

--section ~1
local buildSection1 = function()

    local sectionFrame = Details.options.GetOptionsSection(1)

    --> abbreviation options
        local icon = [[Interface\COMMON\mini-hourglass]]
        local iconcolor = {1, 1, 1, .5}
        local iconsize = {14, 14}

        local onSelectTimeAbbreviation = function (_, _, abbreviationtype)
            _detalhes.ps_abbreviation = abbreviationtype
            _detalhes:UpdateToKFunctions()
            afterUpdate()
        end

        local abbreviationOptions = {
            {value = 1, label = Loc ["STRING_OPTIONS_PS_ABBREVIATE_NONE"], desc = Loc ["STRING_EXAMPLE"] .. ": 305.500 -> 305500", onclick = onSelectTimeAbbreviation, icon = icon, iconcolor = iconcolor, iconsize = iconsize}, --, desc = ""
            {value = 2, label = Loc ["STRING_OPTIONS_PS_ABBREVIATE_TOK"], desc = Loc ["STRING_EXAMPLE"] .. ": 305.500 -> 305.5K", onclick = onSelectTimeAbbreviation, icon = icon, iconcolor = iconcolor, iconsize = iconsize}, --, desc = ""
            {value = 3, label = Loc ["STRING_OPTIONS_PS_ABBREVIATE_TOK2"], desc = Loc ["STRING_EXAMPLE"] .. ": 305.500 -> 305K", onclick = onSelectTimeAbbreviation, icon = icon, iconcolor = iconcolor, iconsize = iconsize}, --, desc = ""
            {value = 4, label = Loc ["STRING_OPTIONS_PS_ABBREVIATE_TOK0"], desc = Loc ["STRING_EXAMPLE"] .. ": 25.305.500 -> 25M", onclick = onSelectTimeAbbreviation, icon = icon, iconcolor = iconcolor, iconsize = iconsize}, --, desc = ""
            {value = 5, label = Loc ["STRING_OPTIONS_PS_ABBREVIATE_TOKMIN"], desc = Loc ["STRING_EXAMPLE"] .. ": 305.500 -> 305.5k", onclick = onSelectTimeAbbreviation, icon = icon, iconcolor = iconcolor, iconsize = iconsize}, --, desc = ""
            {value = 6, label = Loc ["STRING_OPTIONS_PS_ABBREVIATE_TOK2MIN"], desc = Loc ["STRING_EXAMPLE"] .. ": 305.500 -> 305k", onclick = onSelectTimeAbbreviation, icon = icon, iconcolor = iconcolor, iconsize = iconsize}, --, desc = ""
            {value = 7, label = Loc ["STRING_OPTIONS_PS_ABBREVIATE_TOK0MIN"], desc = Loc ["STRING_EXAMPLE"] .. ": 25.305.500 -> 25m", onclick = onSelectTimeAbbreviation, icon = icon, iconcolor = iconcolor, iconsize = iconsize}, --, desc = ""
            {value = 8, label = Loc ["STRING_OPTIONS_PS_ABBREVIATE_COMMA"], desc = Loc ["STRING_EXAMPLE"] .. ": 25305500 -> 25.305.500", onclick = onSelectTimeAbbreviation, icon = icon, iconcolor = iconcolor, iconsize = iconsize} --, desc = ""
        }
        local buildAbbreviationMenu = function()
            return abbreviationOptions
        end

    --> number system
        local onSelectNumeralSystem = function (_, _, systemNumber)
            _detalhes:SelectNumericalSystem(systemNumber)
        end

        local asian1K, asian10K, asian1B = DF:GetAsianNumberSymbols()
        local asianNumerals = {value = 2, label = Loc ["STRING_NUMERALSYSTEM_MYRIAD_EASTASIA"], desc = "1" .. asian1K .. " = 1.000 \n1" .. asian10K .. " = 10.000 \n10" .. asian10K .. " = 100.000 \n100" .. asian10K .. " = 1.000.000", onclick = onSelectNumeralSystem, icon = icon, iconcolor = iconcolor, iconsize = iconsize}

        --if region is western it'll be using Korean symbols, set a font on the dropdown so it won't show ?????
        local clientRegion = DF:GetClientRegion()
        if (clientRegion == "western" or clientRegion == "russia") then
            asianNumerals.descfont = DF:GetBestFontForLanguage("koKR")
        end

        local numeralSystems = {
            {value = 1, label = Loc ["STRING_NUMERALSYSTEM_ARABIC_WESTERN"], desc = "1K = 1.000 \n10K = 10.000 \n100K = 100.000 \n1M = 1.000.000", onclick = onSelectNumeralSystem, icon = icon, iconcolor = iconcolor, iconsize = iconsize},
            asianNumerals
        }

        local buildNumeralSystemsMenu = function()
            return numeralSystems
        end

    local sectionOptions = {
        {--segments locked
            type = "toggle",
            get = function() return Details.instances_segments_locked end,
            set = function (self, fixedparam, value)
                Details.instances_segments_locked = value
            end,
            name = Loc ["STRING_OPTIONS_LOCKSEGMENTS"],
            desc = Loc ["STRING_OPTIONS_LOCKSEGMENTS_DESC"],
        },
        {--scroll speed
            type = "range",
            get = function() return _detalhes.scroll_speed end,
            set = function (self, fixedparam, value)
                _detalhes.scroll_speed = value
            end,
            min = 1,
            max = 3,
            step = 1,
            name = Loc ["STRING_OPTIONS_WHEEL_SPEED"],
            desc = Loc ["STRING_OPTIONS_WHEEL_SPEED_DESC"],
        },
        {--instances amount
            type = "range",
            get = function() return _detalhes.instances_amount end,
            set = function (self, fixedparam, value)
                _detalhes.instances_amount = value
            end,
            min = 1,
            max = 30,
            step = 1,
            name = Loc ["STRING_OPTIONS_MAXINSTANCES"],
            desc = Loc ["STRING_OPTIONS_MAXINSTANCES_DESC"],
        },
        {--abbreviation type
            type = "select",
            get = function() return _detalhes.ps_abbreviation end,
            values = function()
                return buildAbbreviationMenu()
            end,
            name = Loc ["STRING_OPTIONS_PS_ABBREVIATE"],
            desc = Loc ["STRING_OPTIONS_PS_ABBREVIATE_DESC"],
        },
        {--number system
            type = "select",
            get = function() return _detalhes.numerical_system end,
            values = function()
                return buildNumeralSystemsMenu()
            end,
            name = Loc ["STRING_NUMERALSYSTEM"],
            desc = Loc ["STRING_NUMERALSYSTEM_DESC"],
        },
        {--animate bars
            type = "toggle",
            get = function() return _detalhes.use_row_animations end,
            set = function (self, fixedparam, value)
                _detalhes:SetUseAnimations(value)
                afterUpdate()
            end,
            name = Loc ["STRING_OPTIONS_ANIMATEBARS"],
            desc = Loc ["STRING_OPTIONS_ANIMATEBARS_DESC"],
        },
        {--update speed
            type = "range",
            get = function() return _detalhes.update_speed end,
            set = function (self, fixedparam, value)
                _detalhes:SetWindowUpdateSpeed(value)
                afterUpdate()
            end,
            min = 0.05,
            max = 3,
            step = 0.05,
            usedecimals = true,
            name = Loc ["STRING_OPTIONS_WINDOWSPEED"],
            desc = Loc ["STRING_OPTIONS_WINDOWSPEED_DESC"],
        },

        {type = "blank"},
        {type = "label", get = function() return "Window Control:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
        {--lock instance
            type = "execute",
            func = function(self)
                local instanceLockButton = currentInstance.baseframe.lock_button
                _detalhes.lock_instance_function(instanceLockButton, "leftclick", true, true)
            end,
            icontexture = [[Interface\PetBattles\PetBattle-LockIcon]],
            icontexcoords = {0.0703125, 0.9453125, 0.0546875, 0.9453125},
            name = Loc ["STRING_OPTIONS_WC_LOCK"],
            desc = Loc ["STRING_OPTIONS_WC_LOCK_DESC"],
        },
        {--ungroup instance
            type = "execute",
            func = function(self)
                currentInstance:UngroupInstance()
            end,
            icontexture = [[Interface\AddOns\Details\images\icons]],
            icontexcoords = {160/512, 179/512, 142/512, 162/512},
            name = Loc ["STRING_OPTIONS_WC_UNSNAP"],
            desc = Loc ["STRING_OPTIONS_WC_UNSNAP_DESC"],
        },
        {--close instance
            type = "execute",
            func = function(self)
                currentInstance:CloseInstance()
            end,
            icontexture = [[Interface\Buttons\UI-Panel-MinimizeButton-Up]],
            icontexcoords = {0.143125, 0.8653125, 0.1446875, 0.8653125},
            name = Loc ["STRING_OPTIONS_WC_CLOSE"],
            desc = Loc ["STRING_OPTIONS_WC_CLOSE_DESC"],
        },
        {--create instance
            type = "execute",
            func = function(self)
                _detalhes:CreateInstance()
            end,
            icontexture = [[Interface\Buttons\UI-AttributeButton-Encourage-Up]],
            --icontexcoords = {160/512, 179/512, 142/512, 162/512},
            name = Loc ["STRING_OPTIONS_WC_CREATE"],
            desc = Loc ["STRING_OPTIONS_WC_CREATE_DESC"],
        },

    }

    DF:BuildMenu(sectionFrame, sectionOptions, startX, startY-20, 300 + 60, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template)
end

Details.optionsSection[1] = buildSection1