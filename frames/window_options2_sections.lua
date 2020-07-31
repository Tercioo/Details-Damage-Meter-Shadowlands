if (true) then
    --return
end


local Details = _G.Details
local DF = _G.DetailsFramework
local Loc = _G.LibStub("AceLocale-3.0"):GetLocale("Details")
local SharedMedia = _G.LibStub:GetLibrary("LibSharedMedia-3.0")
local LDB = _G.LibStub ("LibDataBroker-1.1", true)
local LDBIcon = LDB and _G.LibStub("LibDBIcon-1.0", true)
local _
local unpack = _G.unpack

local tinsert = _G.tinsert

local startX = 200
local startY = -40
local heightSize = 540
local optionsWidth, optionsHeight = 1100, 650
local mainHeightSize = 800
local presetVersion = 3

--templates
local options_text_template = DF:GetTemplate ("font", "OPTIONS_FONT_TEMPLATE")
local options_dropdown_template = DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
local options_switch_template = DF:GetTemplate ("switch", "OPTIONS_CHECKBOX_TEMPLATE")
local options_slider_template = DF:GetTemplate ("slider", "OPTIONS_SLIDER_TEMPLATE")
local options_button_template = DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE")

local subSectionTitleTextTemplate = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")

local font_select_icon, font_select_texcoord = [[Interface\AddOns\Details\images\icons]], {472/512, 513/512, 186/512, 230/512}
local texture_select_icon, texture_select_texcoord = [[Interface\AddOns\Details\images\icons]], {472/512, 513/512, 186/512, 230/512}

--store the current instance being edited
local currentInstance

function Details.options.SetCurrentInstance(instance)
    currentInstance = instance
end

function Details.options.SetCurrentInstanceAndRefresh(instance)
    currentInstance = instance
    _G.DetailsOptionsWindow.instance = instance

    --get all the frames created and update the options
    for i = 1, _G.DETAILS_OPTIONS_AMOUNT_SECTION do
        local sectionFrame = Details.options.GetOptionsSection(i)
        if (sectionFrame.RefreshOptions) then
            sectionFrame:RefreshOptions()
        end
    end
end

function Details.options.GetCurrentInstanceInOptionsPanel()
    return currentInstance
end

local afterUpdate = function(instance)
    _detalhes:SendOptionsModifiedEvent(instance or currentInstance)
end

local isGroupEditing = function()
    return _detalhes.options_group_edit
end

local editInstanceSetting = function(instance, funcName, ...)
    if (Details[funcName]) then
        if (isGroupEditing()) then
            Details:InstanceGroupCall(instance, funcName, ...)
        else
            instance[funcName](instance, ...)
        end
    else
        local keyName =  funcName
        local value = ...
        if (isGroupEditing()) then
            Details:InstanceGroupEditSetting(instance, keyName, value)
        else
            instance[keyName] = value
        end
    end
end


-- ~01
do
    local buildSection = function(sectionFrame)

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

        --> time measure type
            local onSelectTimeType = function (_, _, timetype)
                _detalhes.time_type = timetype
                _detalhes.time_type_original = timetype
                _detalhes:RefreshMainWindow(-1, true)
                afterUpdate()
            end
            local timetypeOptions = {
                --localize-me
                {value = 1, label = "Activity Time", onclick = onSelectTimeType, icon = "Interface\\Icons\\Achievement_Quests_Completed_Daily_08", iconcolor = {1, .9, .9}, texcoord = {0.078125, 0.921875, 0.078125, 0.921875}},
                {value = 2, label = "Effective Time", onclick = onSelectTimeType, icon = "Interface\\Icons\\Achievement_Quests_Completed_08"},
            }
            local buildTimeTypeMenu = function()
                return timetypeOptions
            end

        --> auto erase
            local onSelectEraseData = function (_, _, eraseType)
                _detalhes.segments_auto_erase = eraseType
                afterUpdate()
            end

            local eraseDataOptions = {
                {value = 1, label = Loc ["STRING_OPTIONS_ED1"], onclick = onSelectEraseData, icon = [[Interface\Addons\Details\Images\reset_button2]]},
                {value = 2, label = Loc ["STRING_OPTIONS_ED2"], onclick = onSelectEraseData, icon = [[Interface\Addons\Details\Images\reset_button2]]},
                {value = 3, label = Loc ["STRING_OPTIONS_ED3"], onclick = onSelectEraseData, icon = [[Interface\Addons\Details\Images\reset_button2]]},
            }
            local buildEraseDataMenu = function()
                return eraseDataOptions
            end

        --> deathlog limit
            local onSelectDeathLogLimit = function(_, _, limitAmount)
                _detalhes:SetDeathLogLimit(limitAmount)
            end
            local DeathLogLimitOptions = {
                {value = 16, label = "16 Records", onclick = onSelectDeathLogLimit, icon = [[Interface\WorldStateFrame\ColumnIcon-GraveyardDefend0]]},
                {value = 32, label = "32 Records", onclick = onSelectDeathLogLimit, icon = [[Interface\WorldStateFrame\ColumnIcon-GraveyardDefend0]]},
                {value = 45, label = "45 Records", onclick = onSelectDeathLogLimit, icon = [[Interface\WorldStateFrame\ColumnIcon-GraveyardDefend0]]},
            }
            local buildDeathLogLimitMenu = function()
                return DeathLogLimitOptions
            end

        local sectionOptions = {
            {type = "label", get = function() return Loc ["STRING_OPTIONS_GENERAL_ANCHOR"] end, text_template = subSectionTitleTextTemplate},
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
            {--click through
                type = "toggle",
                get = function() return currentInstance.clickthrough_window end,
                set = function (self, fixedparam, value)
                    Details:InstanceGroupCall(currentInstance, "UpdateClickThroughSettings", nil, value)
                    afterUpdate()
                end,
                name = "Click Through",
                desc = "Click Through",
            },
            {--click only in combat
                type = "toggle",
                get = function() return currentInstance.clickthrough_incombatonly end,
                set = function (self, fixedparam, value)
                    Details:InstanceGroupCall(currentInstance, "UpdateClickThroughSettings", value)
                    afterUpdate()
                end,
                name = "Click Through Only in Combat",
                desc = "Click Through Only in Combat",
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
            {--time measure
                type = "select",
                get = function() return _detalhes.time_type end,
                values = function()
                    return buildTimeTypeMenu()
                end,
                name = Loc ["STRING_OPTIONS_TIMEMEASURE"],
                desc = Loc ["STRING_OPTIONS_TIMEMEASURE_DESC"],
            },

            {--auto erase settings
                type = "select",
                get = function() return _detalhes.segments_auto_erase end,
                values = function()
                    return buildEraseDataMenu()
                end,
                name = Loc ["STRING_OPTIONS_ED"],
                desc = Loc ["STRING_OPTIONS_ED_DESC"],
            },
            {--pvp frags
                type = "toggle",
                get = function() return _detalhes.only_pvp_frags end,
                set = function (self, fixedparam, value)
                    _detalhes.only_pvp_frags = value
                    afterUpdate()
                end,
                name = Loc ["STRING_OPTIONS_PVPFRAGS"],
                desc = Loc ["STRING_OPTIONS_PVPFRAGS_DESC"],
            },
            {--death log size
                type = "select",
                get = function() return _detalhes.deadlog_events end,
                values = function()
                    return buildDeathLogLimitMenu()
                end,
                name = Loc ["STRING_OPTIONS_DEATHLIMIT"],
                desc = Loc ["STRING_OPTIONS_DEATHLIMIT_DESC"],
            },
            {--pvp frags
                type = "toggle",
                get = function() return _detalhes.damage_taken_everything end,
                set = function (self, fixedparam, value)
                    _detalhes.damage_taken_everything = value
                    afterUpdate()
                end,
                name = Loc ["STRING_OPTIONS_DTAKEN_EVERYTHING"],
                desc = Loc ["STRING_OPTIONS_DTAKEN_EVERYTHING_DESC"],
            },
            {--death log min healing
                type = "range",
                get = function() return _detalhes.deathlog_healingdone_min end,
                set = function (self, fixedparam, value)
                    _detalhes.deathlog_healingdone_min = value
                    afterUpdate()
                end,
                min = 0,
                max = 100000,
                step = 1,
                name = Loc ["STRING_OPTIONS_DEATHLOG_MINHEALING"],
                desc = Loc ["STRING_OPTIONS_DEATHLOG_MINHEALING_DESC"],
            },
            {--always show players even on stardard mode
                type = "toggle",
                get = function() return _detalhes.all_players_are_group end,
                set = function (self, fixedparam, value)
                    _detalhes.all_players_are_group = value
                    afterUpdate()
                end,
                name = Loc ["STRING_OPTIONS_ALWAYSSHOWPLAYERS"],
                desc = Loc ["STRING_OPTIONS_ALWAYSSHOWPLAYERS_DESC"],
            },
            {--battleground remote parser
                type = "toggle",
                get = function() return _detalhes.use_battleground_server_parser end,
                set = function (self, fixedparam, value)
                    _detalhes.use_battleground_server_parser = value
                 end,
                name = Loc ["STRING_OPTIONS_BG_UNIQUE_SEGMENT"],
                desc = Loc ["STRING_OPTIONS_BG_UNIQUE_SEGMENT_DESC"],
            },

            {type = "blank"},
            {type = "label", get = function() return Loc ["STRING_OPTIONS_OVERALL_ANCHOR"] end, text_template = subSectionTitleTextTemplate},

            {--erase overall data on new boss
                type = "toggle",
                get = function() return _detalhes.overall_clear_newboss end,
                set = function (self, fixedparam, value)
                    _detalhes:SetOverallResetOptions(value)
                    afterUpdate()
                end,
                name = Loc ["STRING_OPTIONS_OVERALL_NEWBOSS"],
                desc = Loc ["STRING_OPTIONS_OVERALL_NEWBOSS_DESC"],
            },
            {--erase overall data on mythic plus
                type = "toggle",
                get = function() return _detalhes.overall_clear_newchallenge end,
                set = function (self, fixedparam, value)
                    _detalhes:SetOverallResetOptions(nil, value)
                    afterUpdate()
                end,
                name = Loc ["STRING_OPTIONS_OVERALL_MYTHICPLUS"],
                desc = Loc ["STRING_OPTIONS_OVERALL_MYTHICPLUS_DESC"],
            },
            {--erase overall data on logout
                type = "toggle",
                get = function() return _detalhes.overall_clear_logout end,
                set = function (self, fixedparam, value)
                    _detalhes:SetOverallResetOptions(nil, nil, value)
                    afterUpdate()
                end,
                name = Loc ["STRING_OPTIONS_OVERALL_LOGOFF"],
                desc = Loc ["STRING_OPTIONS_OVERALL_LOGOFF_DESC"],
            },

            {type = "breakline"},
            {type = "label", get = function() return "Window Control:" end, text_template = DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE")},
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
            {--class colors
                type = "execute",
                func = function(self)
                    _detalhes:OpenClassColorsConfig()
                end,
                icontexture = [[Interface\AddOns\Details\images\icons]],
                icontexcoords = {432/512, 464/512, 276/512, 309/512},
                name = Loc ["STRING_OPTIONS_CHANGE_CLASSCOLORS"],
                desc = Loc ["STRING_OPTIONS_CHANGE_CLASSCOLORS_DESC"],
            },
            {--bookmarks
                type = "execute",
                func = function(self)
                    _detalhes:OpenBookmarkConfig()
                end,
                icontexture = [[Interface\LootFrame\toast-star]],
                icontexcoords = {0.1, .64, 0.1, .69},
                name = Loc ["STRING_OPTIONS_WC_BOOKMARK"],
                desc = Loc ["STRING_OPTIONS_WC_BOOKMARK_DESC"],
            },

            {type = "blank"},
            {type = "label", get = function() return Loc ["STRING_OPTIONS_SOCIAL"] end, text_template = subSectionTitleTextTemplate},
            {--nickname
                type = "textentry",
                get = function() return _detalhes:GetNickname(_G.UnitName("player"), _G.UnitName("player"), true) or "" end,
                func = function(self, _, text)
                    local accepted, errortext = _detalhes:SetNickname(text)
                    if (not accepted) then
                        Details:ResetPlayerPersona()
                        Details.options.SetCurrentInstanceAndRefresh(currentInstance)
                    end
                    afterUpdate()
                end,
                name = Loc ["STRING_OPTIONS_NICKNAME"],
                desc = Loc ["STRING_OPTIONS_NICKNAME"],
            },
            {--remove nickname
                type = "execute",
                func = function(self)
                    Details:ResetPlayerPersona()
                    Details.options.SetCurrentInstanceAndRefresh(currentInstance)
                end,
                icontexture = [[Interface\GLUES\LOGIN\Glues-CheckBox-Check]],
                --icontexcoords = {160/512, 179/512, 142/512, 162/512},
                name = "Reset Nickname",
                desc = "Reset Nickname",
            },
        }

        DF:BuildMenu(sectionFrame, sectionOptions, startX, startY-20, heightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template)
    end

    tinsert(Details.optionsSection, buildSection) --optionsSection is declared on boot.lua
end


-- ~02 - skins
do
    local buildSection = function(sectionFrame)

            function Details:OptionPanelOnChangeSkin(skinName)
                self:ChangeSkin(skinName)
                if (self._ElvUIEmbed) then
                    local AS, ASL = unpack(_G.AddOnSkins)
                    AS:Embed_Details()
                end
            end

        --> skin selection
            local onSelectSkin = function (_, _, skinName)
                if (isGroupEditing()) then
                    Details:InstanceGroupCall(currentInstance, "OptionPanelOnChangeSkin", skinName)
                else
                    currentInstance:OptionPanelOnChangeSkin(skinName)
                end
                afterUpdate()
            end

            local buildSkinMenu = function()
                local skinOptions = {}
                for skin_name, skin_table in pairs (_detalhes.skins) do
                    local file = skin_table.file:gsub ([[Interface\AddOns\Details\images\skins\]], "")
                    local desc = "Author: |cFFFFFFFF" .. skin_table.author .. "|r\nVersion: |cFFFFFFFF" .. skin_table.version .. "|r\nSite: |cFFFFFFFF" .. skin_table.site .. "|r\n\nDesc: |cFFFFFFFF" .. skin_table.desc .. "|r\n\nFile: |cFFFFFFFF" .. file .. ".tga|r"
                    skinOptions [#skinOptions+1] = {value = skin_name, label = skin_name, onclick = onSelectSkin, icon = "Interface\\GossipFrame\\TabardGossipIcon", desc = desc}
                end
                return skinOptions
            end

        --> save skin
            local saveAsSkin = function(skinName, dontSave)
                local fileName = skinName or ""

                if (fileName == "") then
                    return
                end
                
                local savedObject = {
                    version = presetVersion,
                    name = skinName,
                }
                
                for key, value in pairs (currentInstance) do
                    if (_detalhes.instance_defaults[key] ~= nil) then
                        if (type (value) == "table") then
                            savedObject[key] = table_deepcopy(value)
                        else
                            savedObject[key] = value
                        end
                    end
                end
                
                if (not dontSave) then
                    _detalhes.savedStyles[#_detalhes.savedStyles+1] = savedObject
                end

                return savedObject
            end

        --> load skin
		local loadSkin = function(instance, skinObject)
            function Details:LoadSkinFromOptionsPanel(skinObject)
                --set skin preset
                local instance = self
                local skin = skinObject.skin
                instance.skin = ""
                instance:ChangeSkin(skin)

                --overwrite all instance parameters with saved ones
                for key, value in pairs (skinObject) do
                    if (key ~= "skin" and not _detalhes.instance_skin_ignored_values[key]) then
                        if (type (value) == "table") then
                            instance[key] = table_deepcopy (value)
                        else
                            instance[key] = value
                        end
                    end
                end

                --apply all changed attributes
                instance:ChangeSkin()
            end

            if (isGroupEditing()) then
                Details:InstanceGroupCall(instance, "LoadSkinFromOptionsPanel", skinObject)
            else
                instance:LoadSkinFromOptionsPanel(skinObject)
            end
        end
        
        --> import skin string
            local importSaved = function()
                --when clicking in the okay button in the import window, it send the text in the first argument
                _detalhes:ShowImportWindow("", function (skinString)
                    if (type (skinString) ~= "string" or string.len(skinString) < 2) then
                        return
                    end

                    skinString = DF:Trim(skinString)

                    local dataTable = Details:DecompressData (skinString, "print")
                    if (dataTable) then
                        --add the new skin
                        _detalhes.savedStyles [#_detalhes.savedStyles+1] = dataTable
                        _detalhes:Msg (Loc ["STRING_OPTIONS_SAVELOAD_IMPORT_OKEY"])
                        Details.options.SetCurrentInstanceAndRefresh(currentInstance)
                        afterUpdate()
                    else
                        Details:Msg (Loc ["STRING_CUSTOM_IMPORT_ERROR"])
                    end
                
                end, "Details! Import Skin (paste string)") --localize-me
            end

        local sectionOptions = {
            {type = "label", get = function() return Loc ["STRING_OPTIONS_SKIN_SELECT_ANCHOR"] end, text_template = subSectionTitleTextTemplate},

            {--skin selection
                type = "select",
                get = function() return currentInstance.skin end,
                values = function()
                    return buildSkinMenu()
                end,
                name = Loc ["STRING_OPTIONS_INSTANCE_SKIN"],
                desc = Loc ["STRING_OPTIONS_INSTANCE_SKIN_DESC"],
            },

            {--custom skin file
                type = "textentry",
                get = function() return currentInstance.skin_custom or "" end,
                func = function(self, _, text)
                    local fileName = text or ""
                    Details:InstanceGroupCall(currentInstance, "SetUserCustomSkinFile", fileName)
                    afterUpdate()
                end,
                name = Loc ["STRING_CUSTOM_SKIN_TEXTURE"],
                desc = Loc ["STRING_CUSTOM_SKIN_TEXTURE_DESC"],
            },

            {--remove custom skin file
                type = "execute",
                func = function(self)
                    Details:InstanceGroupCall(currentInstance, "SetUserCustomSkinFile", "")
                    Details.options.SetCurrentInstanceAndRefresh(currentInstance)
                    afterUpdate()
                end,
                icontexture = [[Interface\GLUES\LOGIN\Glues-CheckBox-Check]],
                --icontexcoords = {160/512, 179/512, 142/512, 162/512},
                name = "Reset Custom Skin",
                desc = "Reset Custom Skin",
            },

            {--save as skin
                type = "textentry",
                get = function() return "" end,
                set = function(self, _, text)
                    saveAsSkin(text)
                    Details.options.SetCurrentInstanceAndRefresh(currentInstance)
                    _detalhes:Msg(Loc ["STRING_OPTIONS_SAVELOAD_SKINCREATED"])
                    afterUpdate()
                end,
                name = Loc ["STRING_OPTIONS_SAVELOAD_SAVE"],
                desc = Loc ["STRING_OPTIONS_SAVELOAD_CREATE_DESC"],
            },

            {--apply to all
                type = "execute",
                func = function(self)
                    local tempPreset = saveAsSkin("temp", true)

                    for instanceId, instance in _detalhes:ListInstances() do
                        if (instance ~= currentInstance) then
                            if (not instance:IsStarted()) then
                                instance:RestoreWindow()
                                loadSkin(instance, tempPreset)
                                instance:Shutdown()
                            else
                                loadSkin(instance, tempPreset)
                                afterUpdate(instance)
                            end
                        end
                    end
                    
                    _detalhes:Msg (Loc ["STRING_OPTIONS_SAVELOAD_APPLYALL"])
                    Details.options.SetCurrentInstanceAndRefresh(currentInstance)
                    afterUpdate()
                end,
                icontexture = [[Interface\Buttons\UI-HomeButton]],
                icontexcoords = {1/16, 14/16, 0, 1},
                name = Loc ["STRING_OPTIONS_SAVELOAD_APPLYTOALL"],
                desc = Loc ["STRING_OPTIONS_SAVELOAD_APPLYALL_DESC"],
            },

            {type = "blank"},
            {type = "label", get = function() return Loc ["STRING_OPTIONS_SKIN_PRESETS_ANCHOR"] end, text_template = subSectionTitleTextTemplate},

            {--apply custom skin
                type = "select",
                get = function()
                    return 0
                end,
                values = function()
                    local loadtable = {}
                    for index, _table in ipairs (_detalhes.savedStyles) do
                        tinsert (loadtable, {value = index, label = _table.name, onclick = function() loadSkin(currentInstance, _table) end,
                        icon = "Interface\\GossipFrame\\TabardGossipIcon", iconcolor = {.7, .7, .5, 1}})
                    end
                    return loadtable
                end,
                name = Loc ["STRING_OPTIONS_SKIN_SELECT"],
                desc = Loc ["STRING_OPTIONS_SKIN_SELECT"],
            },

            {--erase custom skin
                type = "select",
                get = function()
                    return 0
                end,
                values = function()
                    local loadtable = {}
                    for index, _table in ipairs (_detalhes.savedStyles) do
                        tinsert (loadtable, {value = index, label = _table.name, onclick = function(_, _, index)
                            table.remove (_detalhes.savedStyles, index)
                            Details.options.SetCurrentInstanceAndRefresh(currentInstance)
                            afterUpdate()
                            _detalhes:Msg(Loc ["STRING_OPTIONS_SKIN_REMOVED"])
                        end,
                        icon = [[Interface\Glues\LOGIN\Glues-CheckBox-Check]], color = {1, 1, 1}, iconcolor = {1, .9, .9, 0.8}})
                    end
                    return loadtable
                end,
                name = Loc ["STRING_OPTIONS_SAVELOAD_REMOVE"],
                desc = Loc ["STRING_OPTIONS_SAVELOAD_REMOVE"],
            },

            {--export custom skin
                type = "select",
                get = function()
                    return 0
                end,
                values = function()
                    local loadtable = {}
                    for index, _table in ipairs (_detalhes.savedStyles) do
                        tinsert (loadtable, {value = index, label = _table.name, onclick = function(_, _, index)
                            local compressedData = Details:CompressData(_detalhes.savedStyles[index], "print")
                            if (compressedData) then
                                _detalhes:ShowImportWindow(compressedData, nil, "Details! Export Skin")
                            else
                                Details:Msg ("failed to export skin.") --localize-me
                            end
                            Details.options.SetCurrentInstanceAndRefresh(currentInstance)
                            afterUpdate()
                        end,
                        icon = [[Interface\Buttons\UI-GuildButton-MOTD-Up]], color = {1, 1, 1}, iconcolor = {1, .9, .9, 0.8}, texcoord = {1, 0, 0, 1}})
                    end
                    return loadtable
                end,
                name = Loc ["STRING_OPTIONS_SAVELOAD_EXPORT"],
                desc = Loc ["STRING_OPTIONS_SAVELOAD_EXPORT_DESC"],
            },

            {--import custom skin string
                type = "execute",
                func = function(self)
                    importSaved()
                end,
                icontexture = [[Interface\Buttons\UI-GuildButton-MOTD-Up]],
                icontexcoords = {1, 0, 0, 1},
                name = Loc ["STRING_OPTIONS_SAVELOAD_IMPORT"],
                desc = Loc ["STRING_OPTIONS_SAVELOAD_IMPORT_DESC"],
            },

            {type = "breakline"},
            {type = "label", get = function() return Loc ["STRING_OPTIONS_TABEMB_ANCHOR"] end, text_template = subSectionTitleTextTemplate},

            {--chat tab embed enabled
                type = "toggle",
                get = function() return _detalhes.chat_tab_embed.enabled end,
                set = function (self, fixedparam, value)
                    _detalhes.chat_embed:SetTabSettings(nil, value)
                    Details.options.SetCurrentInstanceAndRefresh(currentInstance)
                    afterUpdate()
                end,
                name = Loc ["STRING_ENABLED"],
                desc = Loc ["STRING_OPTIONS_TABEMB_ENABLED_DESC"],
            },

            {--tab name
                type = "textentry",
                get = function() return _detalhes.chat_tab_embed.tab_name or "" end,
                func = function(self, _, text)
                    _detalhes.chat_embed:SetTabSettings(text)
                end,
                name = Loc ["STRING_OPTIONS_TABEMB_TABNAME"],
                desc = Loc ["STRING_OPTIONS_TABEMB_TABNAME_DESC"],
            },

            {--single window
                type = "toggle",
                get = function() return _detalhes.chat_tab_embed.single_window end,
                set = function (self, fixedparam, value)
                    _detalhes.chat_embed:SetTabSettings (nil, nil, value)
                    Details.options.SetCurrentInstanceAndRefresh(currentInstance)
                    afterUpdate()
                end,
                name = Loc ["STRING_OPTIONS_TABEMB_SINGLE"],
                desc = Loc ["STRING_OPTIONS_TABEMB_SINGLE_DESC"],
            },

            {--chat tab width offset
                type = "range",
                get = function() return tonumber (_detalhes.chat_tab_embed.x_offset) end,
                set = function (self, fixedparam, value)
                    _detalhes.chat_tab_embed.x_offset = value
                    if (_detalhes.chat_embed.enabled) then
                        _detalhes.chat_embed:DoEmbed()
                    end
                    afterUpdate()
                end,
                min = -100,
                max = 100,
                step = 1,
                name = "Width Offset", --localize-me
                desc = "Fine tune the size of the window while embeded in the chat.", --localize-me
            },

            {--chat tab height offset
                type = "range",
                get = function() return tonumber (_detalhes.chat_tab_embed.y_offset) end,
                set = function (self, fixedparam, value)
                    _detalhes.chat_tab_embed.y_offset = value
                    if (_detalhes.chat_embed.enabled) then
                        _detalhes.chat_embed:DoEmbed()
                    end
                    afterUpdate()
                end,
                min = -100,
                max = 100,
                step = 1,
                name = "Height Offset", --localize-me
                desc = "Fine tune the size of the window while embeded in the chat.", --localize-me
            },
        }

        DF:BuildMenu(sectionFrame, sectionOptions, startX, startY-20, heightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template)
    end

    tinsert(Details.optionsSection, buildSection)
end


-- ~03
do

    --bar grow direction
    local set_bar_grow_direction = function (_, instance, value)
        editInstanceSetting(currentInstance, "SetBarGrowDirection", value)
        afterUpdate()
    end
    
    local grow_icon_size = {14, 14}
    local orientation_icon_size = {14, 14}
    
    local grow_options = {
        {value = 1, label = Loc ["STRING_TOP_TO_BOTTOM"], iconsize = orientation_icon_size, onclick = set_bar_grow_direction, icon = [[Interface\Calendar\MoreArrow]], texcoord = {0, 1, 0, 0.7}},
        {value = 2, label = Loc ["STRING_BOTTOM_TO_TOP"], iconsize = orientation_icon_size, onclick = set_bar_grow_direction, icon = [[Interface\Calendar\MoreArrow]], texcoord = {0, 1, 0.7, 0}}
    }
    local growMenu = function()
        return grow_options
    end

    --bar orientation
    local set_bar_orientation = function (_, instance, value)
        editInstanceSetting(currentInstance, "SetBarOrientationDirection", value)
        afterUpdate()
    end
    
    local orientation_options = {
        {value = false, label = Loc ["STRING_LEFT_TO_RIGHT"], iconsize = orientation_icon_size, onclick = set_bar_orientation, icon = [[Interface\CHATFRAME\ChatFrameExpandArrow]]},
        {value = true, label = Loc ["STRING_RIGHT_TO_LEFT"], iconsize = orientation_icon_size, onclick = set_bar_orientation, icon = [[Interface\CHATFRAME\ChatFrameExpandArrow]], texcoord = {1, 0, 0, 1}}
    }
    local orientation_menu = function() 
        return orientation_options
    end

    --sort direction
    local set_bar_sorting = function(_, instance, value)
        editInstanceSetting(currentInstance, "bars_sort_direction", value)
        _detalhes:RefreshMainWindow(-1, true)
        afterUpdate()
    end

    local sorting_options = {
        {value = 1, label = Loc ["STRING_DESCENDING"], iconsize ={14, 14}, onclick = set_bar_sorting, icon = [[Interface\Calendar\MoreArrow]], texcoord = {0, 1, 0, 0.7}},
        {value = 2, label = Loc ["STRING_ASCENDING"], iconsize = {14, 14}, onclick = set_bar_sorting, icon = [[Interface\Calendar\MoreArrow]], texcoord = {0, 1, 0.7, 0}}
    }
    local sorting_menu = function()
        return sorting_options
    end

    --select texture
    local texture_icon = [[Interface\TARGETINGFRAME\UI-PhasingIcon]]
    local texture_icon = [[Interface\AddOns\Details\images\icons]]
    local texture_icon_size = {14, 14}
    local texture_texcoord = {469/512, 505/512, 249/512, 284/512}

    local onSelectTexture = function (_, instance, textureName)
        editInstanceSetting(currentInstance, "SetBarSettings", nil, textureName)
        afterUpdate()
    end

    local buildTextureMenu = function()
        local textures = SharedMedia:HashTable("statusbar")
        local texTable = {}
        for name, texturePath in pairs (textures) do 
            texTable[#texTable+1] = {value = name, label = name, iconsize = texture_icon_size, statusbar = texturePath,  onclick = onSelectTexture, icon = texture_icon, texcoord = texture_texcoord}
        end
        table.sort (texTable, function (t1, t2) return t1.label < t2.label end)
        return texTable
    end

    --select background texture
    local onSelectTextureBackground = function (_, instance, textureName)
        editInstanceSetting(currentInstance, "SetBarSettings", nil, nil, nil, nil, textureName)
        afterUpdate()
    end

    local buildTextureMenu2 = function()
        local textures2 = SharedMedia:HashTable ("statusbar")
        local texTable2 = {}
        for name, texturePath in pairs (textures2) do
            texTable2[#texTable2+1] = {value = name, label = name, iconsize = texture_icon_size, statusbar = texturePath,  onclick = onSelectTextureBackground, icon = texture_icon, texcoord = texture_texcoord}
        end
        table.sort (texTable2, function (t1, t2) return t1.label < t2.label end)
        return texTable2
    end

    --select icon file from dropdown
    local OnSelectIconFileSpec = function (_, _, iconpath)
        editInstanceSetting(currentInstance, "SetBarSpecIconSettings", true, iconpath, true)
        afterUpdate()
    end

    local OnSelectIconFile = function (_, _, iconpath)
        editInstanceSetting(currentInstance, "SetBarSettings", nil, nil, nil, nil, nil, nil, nil, nil, iconpath)
        if (currentInstance.row_info.use_spec_icons) then
            editInstanceSetting(currentInstance, "SetBarSpecIconSettings", false)
        end
        afterUpdate()
    end

    local iconsize = {16, 16}
    local icontexture = [[Interface\WorldStateFrame\ICONS-CLASSES]]
    local iconcoords = {0.25, 0.50, 0, 0.25}
    local list = {
        {value = [[]], label = Loc ["STRING_OPTIONS_BAR_ICONFILE1"], onclick = OnSelectIconFile, icon = icontexture, texcoord = iconcoords, iconsize = iconsize, iconcolor = {1, 1, 1, .3}},
        {value = [[Interface\AddOns\Details\images\classes_small]], label = Loc ["STRING_OPTIONS_BAR_ICONFILE2"], onclick = OnSelectIconFile, icon = icontexture, texcoord = iconcoords, iconsize = iconsize},
        {value = [[Interface\AddOns\Details\images\spec_icons_normal]], label = "Specialization", onclick = OnSelectIconFileSpec, icon = [[Interface\AddOns\Details\images\icons]], texcoord = {2/512, 32/512, 480/512, 510/512}, iconsize = iconsize},
        {value = [[Interface\AddOns\Details\images\spec_icons_normal_alpha]], label = "Specialization Alpha", onclick = OnSelectIconFileSpec, icon = [[Interface\AddOns\Details\images\icons]], texcoord = {2/512, 32/512, 480/512, 510/512}, iconsize = iconsize},
        {value = [[Interface\AddOns\Details\images\classes_small_bw]], label = Loc ["STRING_OPTIONS_BAR_ICONFILE3"], onclick = OnSelectIconFile, icon = icontexture, texcoord = iconcoords, iconsize = iconsize},
        {value = [[Interface\AddOns\Details\images\classes_small_alpha]], label = Loc ["STRING_OPTIONS_BAR_ICONFILE4"], onclick = OnSelectIconFile, icon = icontexture, texcoord = iconcoords, iconsize = iconsize},
        {value = [[Interface\AddOns\Details\images\classes_small_alpha_bw]], label = Loc ["STRING_OPTIONS_BAR_ICONFILE6"], onclick = OnSelectIconFile, icon = icontexture, texcoord = iconcoords, iconsize = iconsize},
        {value = [[Interface\AddOns\Details\images\classes]], label = Loc ["STRING_OPTIONS_BAR_ICONFILE5"], onclick = OnSelectIconFile, icon = icontexture, texcoord = iconcoords, iconsize = iconsize},
    }
    local builtIconList = function()
        return list
    end

    local buildSection = function(sectionFrame)
        local sectionOptions = {
            {--line height
                type = "range",
                get = function() return tonumber (currentInstance.row_info.height) end,
                set = function (self, fixedparam, value)
                    editInstanceSetting(currentInstance, "SetBarSettings", value)
                    afterUpdate()
                end,
                min = 10,
                max = 30,
                step = 1,
                name = Loc ["STRING_OPTIONS_BAR_HEIGHT"],
                desc = Loc ["STRING_OPTIONS_BAR_HEIGHT_DESC"],
            },

            {--disable highlight
                type = "toggle",
                get = function() return _detalhes.instances_disable_bar_highlight end,
                set = function (self, fixedparam, value)
                    _detalhes.instances_disable_bar_highlight = value
                    afterUpdate()
                end,
                name = Loc ["STRING_OPTIONS_DISABLE_BARHIGHLIGHT"],
                desc = Loc ["STRING_OPTIONS_DISABLE_BARHIGHLIGHT_DESC"],
            },

            {--padding
                type = "range",
                get = function() return tonumber (currentInstance.row_info.space.between) end,
                set = function (self, fixedparam, value)
                    editInstanceSetting(currentInstance, "SetBarSettings", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, value)
                    afterUpdate()
                end,
                min = -2,
                max = 10,
                step = 1,
                name = Loc ["STRING_OPTIONS_BAR_SPACING"],
                desc = Loc ["STRING_OPTIONS_BAR_SPACING_DESC"],
            },

            {--grow direction
                type = "select",
                get = function() return currentInstance.bars_grow_direction end,
                values = function()
                    return growMenu()
                end,
                name = Loc ["STRING_OPTIONS_BAR_GROW"],
                desc = Loc ["STRING_OPTIONS_BAR_GROW_DESC"],
            },

            {--bar orientation
                type = "select",
                get = function() return currentInstance.bars_inverted and 2 or 1 end,
                values = function()
                    return orientation_menu()
                end,
                name = Loc ["STRING_OPTIONS_BARORIENTATION"],
                desc = Loc ["STRING_OPTIONS_BARORIENTATION_DESC"],
            },

            {--bar sort direction
                type = "select",
                get = function() return currentInstance.bars_sort_direction end,
                values = function()
                    return sorting_menu()
                end,
                name = Loc ["STRING_OPTIONS_BARSORT"],
                desc = Loc ["STRING_OPTIONS_BARSORT_DESC"],
            },

            {type = "blank"},
            {type = "label", get = function() return Loc ["STRING_OPTIONS_TEXT_TEXTUREU_ANCHOR"] end, text_template = subSectionTitleTextTemplate},

            {--select texture
                type = "select",
                get = function() return currentInstance.row_info.texture end,
                values = function()
                    return buildTextureMenu()
                end,
                name = Loc ["STRING_TEXTURE"],
                desc = Loc ["STRING_OPTIONS_BAR_TEXTURE_DESC"],
            },

            {--custom texture
                type = "textentry",
                get = function() return currentInstance.row_info.texture_custom end,
                func = function(self, _, text)
                    editInstanceSetting(currentInstance, "SetBarSettings", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, text)
                    afterUpdate()
                end,
                name = Loc ["STRING_OPTIONS_BARS_CUSTOM_TEXTURE"],
                desc = Loc ["STRING_OPTIONS_BARS_CUSTOM_TEXTURE_DESC"],
            },

            {--remove custom texture
                type = "execute",
                func = function(self)
                    editInstanceSetting(currentInstance, "SetBarSettings", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "")
                    afterUpdate()
                end,
                icontexture = [[Interface\Buttons\UI-GroupLoot-Pass-Down]],
                --icontexcoords = {160/512, 179/512, 142/512, 162/512},
                name = "Remove Custom Texture", --localize-me
                desc = "Remove Custom Texture",
            },

			{--bar color
				type = "color",
                get = function()
                    local r, g, b = unpack(currentInstance.row_info.fixed_texture_color)
                    local alpha = currentInstance.row_info.alpha
                    return {r, g, b, a}
				end,
				set = function (self, r, g, b, a)
                    editInstanceSetting(currentInstance, "SetBarSettings", nil, nil, nil, {r, g, b})
                    editInstanceSetting(currentInstance, "SetBarSettings", nil, nil, nil, nil, nil, nil, nil, a)
                    afterUpdate()
				end,
				name = Loc ["STRING_COLOR"],
				desc = Loc ["STRING_OPTIONS_BAR_COLOR_DESC"],
            },

            {--use class colors
                type = "toggle",
                get = function() return currentInstance.row_info.texture_class_colors end,
                set = function (self, fixedparam, value)
                    editInstanceSetting(currentInstance, "SetBarSettings", nil, nil, value)
                    afterUpdate()
                end,
                name = Loc ["STRING_OPTIONS_BAR_COLORBYCLASS"],
                desc = Loc ["STRING_OPTIONS_BAR_COLORBYCLASS_DESC"],
            },

            {type = "blank"},
            {type = "label", get = function() return Loc ["STRING_OPTIONS_TEXT_TEXTUREL_ANCHOR"] end, text_template = subSectionTitleTextTemplate},

            {--select background texture
                type = "select",
                get = function() return currentInstance.row_info.texture_background end,
                values = function()
                    return buildTextureMenu2()
                end,
                name = Loc ["STRING_TEXTURE"],
                desc = Loc ["STRING_OPTIONS_BAR_BTEXTURE_DESC"],
            },

			{--background color
                type = "color",
                get = function()
                    local r, g, b = unpack(currentInstance.row_info.fixed_texture_background_color)
                    local alpha = currentInstance.row_info.alpha
                    return {r, g, b, a}
                end,
                set = function (self, r, g, b, a)
                    editInstanceSetting(currentInstance, "SetBarSettings", nil, nil, nil, nil, nil, nil, {r, g, b, a})
                    afterUpdate()
                end,
                name = Loc ["STRING_COLOR"],
                desc = Loc ["STRING_OPTIONS_BAR_COLOR_DESC"],
            },

            {--background uses class colors
                type = "toggle",
                get = function() return currentInstance.row_info.texture_background_class_color end,
                set = function (self, fixedparam, value)
                    editInstanceSetting(currentInstance, "SetBarSettings", nil, nil, nil, nil, nil, value)
                    afterUpdate()
                end,
                name = Loc ["STRING_OPTIONS_BAR_COLORBYCLASS"],
                desc = Loc ["STRING_OPTIONS_BAR_COLORBYCLASS_DESC"],
            },

            {type = "blank"},
            {type = "label", get = function() return Loc ["STRING_OPTIONS_TEXT_ROWICONS_ANCHOR"] end, text_template = subSectionTitleTextTemplate},

            {--select icon file
                type = "select",
                get = function(self)
                    local default
                    if (currentInstance.row_info.use_spec_icons) then
                        default = currentInstance.row_info.spec_file
                    else
                        default = currentInstance.row_info.icon_file
                    end
                    return default
                end,
                values = function()
                    return builtIconList()
                end,
                name = Loc ["STRING_TEXTURE"],
                desc = Loc ["STRING_OPTIONS_BAR_ICONFILE_DESC2"],
            },

            {--custom icon path
                type = "textentry",
                get = function()
                    local default
                    if (currentInstance.row_info.use_spec_icons) then
                        default = currentInstance.row_info.spec_file
                    else
                        default = currentInstance.row_info.icon_file
                    end
                    return default
                end,
                func = function(self, _, text)
                    if (text:find ("spec_")) then
                        editInstanceSetting(currentInstance, "SetBarSpecIconSettings", true, text, true)
                    else
                        if (currentInstance.row_info.use_spec_icons) then
                            editInstanceSetting(currentInstance, "SetBarSpecIconSettings", false)
                        end
                        editInstanceSetting(currentInstance, "SetBarSettings", nil, nil, nil, nil, nil, nil, nil, nil, text)
                    end

                    Details.options.SetCurrentInstanceAndRefresh(currentInstance)
                    afterUpdate()
                end,
                name = "Enter the path for a custom icon file",
                desc = "Enter the path for a custom icon file",
            },

            {--bar start at
                type = "toggle",
                get = function() return currentInstance.row_info.start_after_icon end,
                set = function (self, fixedparam, value)
                    editInstanceSetting(currentInstance, "SetBarSettings", nil, nil, nil, nil, nil, nil, nil, nil, nil, value)
                    afterUpdate()
                end,
                name = Loc ["STRING_OPTIONS_BARSTART"],
                desc = Loc ["STRING_OPTIONS_BARSTART_DESC"],
            },

            {type = "breakline"},
            {type = "label", get = function() return Loc ["STRING_OPTIONS_BAR_BACKDROP_ANCHOR"] end, text_template = subSectionTitleTextTemplate},

            {--border enabled
                type = "toggle",
                get = function() return currentInstance.row_info.backdrop.enabled end,
                set = function (self, fixedparam, value)
                    editInstanceSetting(currentInstance, "SetBarBackdropSettings", value)
                    afterUpdate()
                end,
                name = Loc ["STRING_ENABLED"],
                desc = Loc ["STRING_OPTIONS_BAR_BACKDROP_ENABLED_DESC"],
            },

			{--border color
                type = "color",
                get = function()
                    local r, g, b, a = unpack(currentInstance.row_info.backdrop.color)
                    return {r, g, b, a}
                end,
                set = function (self, r, g, b, a)
                    editInstanceSetting(currentInstance, "SetBarBackdropSettings", nil, nil, {r, g, b, a})
                    afterUpdate()
                end,
                name = Loc ["STRING_COLOR"],
                desc = Loc ["STRING_OPTIONS_BAR_BACKDROP_COLOR_DESC"],
            },

            {--border size
                type = "range",
                get = function() return tonumber (currentInstance.row_info.backdrop.size) end,
                set = function (self, fixedparam, value)
                    editInstanceSetting(currentInstance, "SetBarBackdropSettings", nil, value)
                    afterUpdate()
                end,
                min = 0,
                max = 10,
                step = 1,
                usedecimals = true,
                name = Loc ["STRING_OPTIONS_SIZE"],
                desc = Loc ["STRING_OPTIONS_BAR_BACKDROP_SIZE_DESC"],
            },

            {type = "blank"},
            {type = "label", get = function() return "Inline Text (need better name)" end, text_template = subSectionTitleTextTemplate}, --localize-me

            {--inline text enabled
                type = "toggle",
                get = function() return currentInstance.use_multi_fontstrings end,
                set = function (self, fixedparam, value)
                    editInstanceSetting(currentInstance, "use_multi_fontstrings", value)
                    afterUpdate()
                end,
                name = Loc ["STRING_ENABLED"],
                desc = "Vertically align texts in the right side as a vertical line.",
            },

            {--lineText2 (left, usuali is the 'done' amount)
                type = "range",
                get = function() return tonumber (currentInstance.fontstrings_text2_anchor) end,
                set = function (self, fixedparam, value)
                    editInstanceSetting(currentInstance, "fontstrings_text2_anchor", value)
                    editInstanceSetting(currentInstance, "InstanceRefreshRows")
                    afterUpdate()
                end,
                min = 0,
                max = 125,
                step = 1,
                name = "Text 1 Position",
                desc = "Text 1 Position",
            },

            {--lineText3 (in the middle)
                type = "range",
                get = function() return tonumber (currentInstance.fontstrings_text3_anchor) end,
                set = function (self, fixedparam, value)
                    editInstanceSetting(currentInstance, "fontstrings_text3_anchor", value)
                    editInstanceSetting(currentInstance, "InstanceRefreshRows")
                    afterUpdate()
                end,
                min = 0,
                max = 75,
                step = 1,
                name = "Text 2 Position",
                desc = "Text 2 Position",
            },

            {--lineText4 (closest to the right)
                type = "range",
                get = function() return tonumber (currentInstance.fontstrings_text4_anchor) end,
                set = function (self, fixedparam, value)
                    editInstanceSetting(currentInstance, "fontstrings_text4_anchor", value)
                    editInstanceSetting(currentInstance, "InstanceRefreshRows")
                    afterUpdate()
                end,
                min = 0,
                max = 50,
                step = 1,
                name = "Text 3 Position",
                desc = "Text 3 Position",
            },

        }

        DF:BuildMenu(sectionFrame, sectionOptions, startX, startY-20, heightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template)
    end

    tinsert(Details.optionsSection, buildSection)
end


-- ~04
do

    --> text font selection
        local onSelectFont = function (_, instance, fontName)
            editInstanceSetting(currentInstance, "SetBarTextSettings", nil, fontName)
            afterUpdate()
        end

        local buildFontMenu = function()
            local fontObjects = SharedMedia:HashTable("font")
            local fontTable = {}
            for name, fontPath in pairs (fontObjects) do 
                fontTable[#fontTable+1] = {value = name, label = name, icon = font_select_icon, texcoord = font_select_texcoord, onclick = onSelectFont, font = fontPath, descfont = name, desc = Loc ["STRING_MUSIC_DETAILS_ROBERTOCARLOS"]}
            end
            table.sort (fontTable, function (t1, t2) return t1.label < t2.label end)
            return fontTable
        end

	--> percent type
        local onSelectPercent = function (_, instance, percentType)
            editInstanceSetting(currentInstance, "SetBarTextSettings", nil, nil, nil, nil, nil, nil, nil, nil, nil, percentType)
            afterUpdate()
        end
        
        local buildPercentMenu = function()
            local percentTable = {
                {value = 1, label = "Relative to Total", onclick = onSelectPercent, icon = [[Interface\GROUPFRAME\UI-GROUP-MAINTANKICON]]},
                {value = 2, label = "Relative to Top Player", onclick = onSelectPercent, icon = [[Interface\GROUPFRAME\UI-Group-LeaderIcon]]}
            }
            return percentTable
        end

    --> brackets
        local onSelectBracket = function (_, instance, value)
            editInstanceSetting(currentInstance, "SetBarRightTextSettings", nil, nil, nil, value)
            afterUpdate()
		end
		
		local BracketTable = {
			{value = "(", label = "(", onclick = onSelectBracket, icon = ""},
			{value = "{", label = "{", onclick = onSelectBracket, icon = ""},
			{value = "[", label = "[", onclick = onSelectBracket, icon = ""},
			{value = "<", label = "<", onclick = onSelectBracket, icon = ""},
			{value = "NONE", label = "no bracket", onclick = onSelectBracket, icon = [[Interface\Glues\LOGIN\Glues-CheckBox-Check]]},
		}
		local buildBracketMenu = function()
			return BracketTable
        end
    
    --> separators
        local onSelectSeparator = function (_, instance, value)
            editInstanceSetting(currentInstance, "SetBarRightTextSettings", nil, nil, nil, nil, value)
            afterUpdate()
		end
		
		local separatorTable = {
			{value = ",", label = ",", onclick = onSelectSeparator, icon = ""},
			{value = ".", label = ".", onclick = onSelectSeparator, icon = ""},
			{value = ";", label = ";", onclick = onSelectSeparator, icon = ""},
			{value = "-", label = "-", onclick = onSelectSeparator, icon = ""},
			{value = "|", label = "|", onclick = onSelectSeparator, icon = ""},
			{value = "/", label = "/", onclick = onSelectSeparator, icon = ""},
			{value = "\\", label = "\\", onclick = onSelectSeparator, icon = ""},
			{value = "~", label = "~", onclick = onSelectSeparator, icon = ""},
			{value = "NONE", label = "no separator", onclick = onSelectSeparator, icon = [[Interface\Glues\LOGIN\Glues-CheckBox-Check]]},
		}
		local buildSeparatorMenu = function()
			return separatorTable
		end


    local buildSection = function(sectionFrame)
        local sectionOptions = {
            {type = "label", get = function() return Loc ["STRING_OPTIONS_GENERAL_ANCHOR"] end, text_template = subSectionTitleTextTemplate},

			{--text color
                type = "color",
                get = function()
                    local r, g, b = unpack(currentInstance.row_info.fixed_text_color)
                    return {r, g, b, 1}
                end,
                set = function (self, r, g, b, a)
                    editInstanceSetting(currentInstance, "SetBarTextSettings", nil, nil, {r, g, b, 1})
                    afterUpdate()
                end,
                name = Loc ["STRING_OPTIONS_TEXT_FIXEDCOLOR"],
                desc = Loc ["STRING_OPTIONS_TEXT_FIXEDCOLOR_DESC"],
            },
            {--text size
                type = "range",
                get = function() return currentInstance.row_info.font_size end,
                set = function (self, fixedparam, value)
                    editInstanceSetting(currentInstance, "SetBarTextSettings", value)
                    afterUpdate()
                end,
                min = 5,
                max = 32,
                step = 1,
                name = Loc ["STRING_OPTIONS_TEXT_SIZE"],
                desc = Loc ["STRING_OPTIONS_TEXT_SIZE_DESC"],
            },
            {--text font
                type = "select",
                get = function() return currentInstance.row_info.font_face end,
                values = function()
                    return buildFontMenu()
                end,
                name = Loc ["STRING_OPTIONS_TEXT_FONT"],
                desc = Loc ["STRING_OPTIONS_TEXT_FONT_DESC"],
            },
            {--percent type
                type = "select",
                get = function() return currentInstance.row_info.percent_type end,
                values = function()
                    return buildPercentMenu()
                end,
                name = Loc ["STRING_OPTIONS_PERCENT_TYPE"],
                desc = Loc ["STRING_OPTIONS_PERCENT_TYPE_DESC"],
            },
            

            {type = "blank"},
            --left text options
            {type = "label", get = function() return Loc ["STRING_OPTIONS_TEXT_LEFT_ANCHOR"] end, text_template = subSectionTitleTextTemplate},

            {--use class colors
                type = "toggle",
                get = function() return currentInstance.row_info.textL_class_colors end,
                set = function (self, fixedparam, value)
                    editInstanceSetting(currentInstance, "SetBarTextSettings", nil, nil, nil, value)
                    afterUpdate()
                end,
                name = Loc ["STRING_OPTIONS_BAR_COLORBYCLASS"],
                desc = Loc ["STRING_OPTIONS_TEXT_LCLASSCOLOR_DESC"],
            },
            {--outline
                type = "toggle",
                get = function() return currentInstance.row_info.textL_outline end,
                set = function (self, fixedparam, value)
                    editInstanceSetting(currentInstance, "SetBarTextSettings", nil, nil, nil, nil, nil, value)
                    afterUpdate()
                end,
                name = Loc ["STRING_OPTIONS_TEXT_LOUTILINE"],
                desc = Loc ["STRING_OPTIONS_TEXT_LOUTILINE_DESC"],
            },
            {--outline small
                type = "toggle",
                get = function() return currentInstance.row_info.textL_outline_small end,
                set = function (self, fixedparam, value)
                    editInstanceSetting(currentInstance, "SetBarTextSettings", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, value)
                    afterUpdate()
                end,
                name = "Outline", --localize-me
                desc = "Text Outline",
            },
			{--outline small color
                type = "color",
                get = function()
                    local r, g, b = unpack(currentInstance.row_info.textL_outline_small_color)
                    return {r, g, b, a}
                end,
                set = function (self, r, g, b, a)
                    editInstanceSetting(currentInstance, "SetBarTextSettings", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, {r, g, b, a})
                    afterUpdate()
                end,
                name = "Outline Color",
                desc = "Outline Color",
            },
            {--position number
                type = "toggle",
                get = function() return currentInstance.row_info.textL_show_number end,
                set = function (self, fixedparam, value)
                    editInstanceSetting(currentInstance, "SetBarTextSettings", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, value)
                    afterUpdate()
                end,
                name = Loc ["STRING_OPTIONS_TEXT_LPOSITION"],
                desc = Loc ["STRING_OPTIONS_TEXT_LPOSITION_DESC"],
            },
            {--translit text
                type = "toggle",
                get = function() return currentInstance.row_info.textL_translit_text end,
                set = function (self, fixedparam, value)
                    editInstanceSetting(currentInstance, "SetBarTextSettings", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, value)
                    afterUpdate()
                end,
                name = Loc ["STRING_OPTIONS_TEXT_LTRANSLIT"],
                desc = Loc ["STRING_OPTIONS_TEXT_LTRANSLIT_DESC"],
            },

            {type = "blank"},

            {--custom left text
                type = "toggle",
                get = function() return currentInstance.row_info.textL_enable_custom_text end,
                set = function (self, fixedparam, value)
                    editInstanceSetting(currentInstance, "SetBarTextSettings", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, value)
                    afterUpdate()
                end,
                name = Loc ["STRING_OPTIONS_BARLEFTTEXTCUSTOM"],
                desc = Loc ["STRING_OPTIONS_BARLEFTTEXTCUSTOM_DESC"],
            },
            {--open custom text editor
                type = "execute",
                func = function(self)
                    local callback = function(text)
                        text = text:gsub("||", "|")
                        text = DF:Trim(text)
                        editInstanceSetting(currentInstance, "SetBarTextSettings", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, text)
                        afterUpdate()
                    end
                    _G.DetailsWindowOptionsBarTextEditor:Open (currentInstance.row_info.textL_custom_text, callback, _G.DetailsOptionsWindow, _detalhes.instance_defaults.row_info.textL_custom_text)
                end,
                icontexture = [[Interface\GLUES\LOGIN\Glues-CheckBox-Check]],
                --icontexcoords = {160/512, 179/512, 142/512, 162/512},
                name = "Edit Custom Text", --localize-me
                desc = Loc ["STRING_OPTIONS_OPEN_ROWTEXT_EDITOR"],
            },

            {type = "breakline"},
            --right text options
            {type = "label", get = function() return Loc ["STRING_OPTIONS_TEXT_RIGHT_ANCHOR"] end, text_template = subSectionTitleTextTemplate},

            {--use class colors
                type = "toggle",
                get = function() return currentInstance.row_info.textR_class_colors end,
                set = function (self, fixedparam, value)
                    editInstanceSetting(currentInstance, "SetBarTextSettings", nil, nil, nil, nil, value)
                    afterUpdate()
                end,
                name = Loc ["STRING_OPTIONS_BAR_COLORBYCLASS"],
                desc = Loc ["STRING_OPTIONS_TEXT_LCLASSCOLOR_DESC"],
            },
            {--outline
                type = "toggle",
                get = function() return currentInstance.row_info.textR_outline end,
                set = function (self, fixedparam, value)
                    editInstanceSetting(currentInstance, "SetBarTextSettings", nil, nil, nil, nil, nil, nil, value)
                    afterUpdate()
                end,
                name = Loc ["STRING_OPTIONS_TEXT_LOUTILINE"],
                desc = Loc ["STRING_OPTIONS_TEXT_LOUTILINE_DESC"],
            },
            {--outline small
                type = "toggle",
                get = function() return currentInstance.row_info.textR_outline_small end,
                set = function (self, fixedparam, value)
                    editInstanceSetting(currentInstance, "SetBarTextSettings", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, value)
                    afterUpdate()
                end,
                name = "Outline", --localize-me
                desc = "Text Outline",
            },
			{--outline small color
                type = "color",
                get = function()
                    local r, g, b = unpack(currentInstance.row_info.textR_outline_small_color)
                    return {r, g, b, a}
                end,
                set = function (self, r, g, b, a)
                    editInstanceSetting(currentInstance, "SetBarTextSettings", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, {r, g, b, a})
                    afterUpdate()
                end,
                name = "Outline Color",
                desc = "Outline Color",
            },

            {type = "blank"},

            {--show total
                type = "toggle",
                get = function() return currentInstance.row_info.textR_show_data[1] end,
                set = function (self, fixedparam, value)
                    editInstanceSetting(currentInstance, "SetBarRightTextSettings", value)
                    afterUpdate()
                end,
                name = Loc ["STRING_OPTIONS_TEXT_SHOW_TOTAL"],
                desc = Loc ["STRING_OPTIONS_TEXT_SHOW_TOTAL_DESC"],
            },
            {--show per second
                type = "toggle",
                get = function() return currentInstance.row_info.textR_show_data[2] end,
                set = function (self, fixedparam, value)
                    editInstanceSetting(currentInstance, "SetBarRightTextSettings", nil, value)
                    afterUpdate()
                end,
                name = Loc ["STRING_OPTIONS_TEXT_SHOW_PS"],
                desc = Loc ["STRING_OPTIONS_TEXT_SHOW_PS_DESC"],
            },
            {--show percent
                type = "toggle",
                get = function() return currentInstance.row_info.textR_show_data[3] end,
                set = function (self, fixedparam, value)
                    editInstanceSetting(currentInstance, "SetBarRightTextSettings", nil, nil, value)
                    afterUpdate()
                end,
                name = Loc ["STRING_OPTIONS_TEXT_SHOW_PERCENT"],
                desc = Loc ["STRING_OPTIONS_TEXT_SHOW_PERCENT_DESC"],
            },

            {type = "blank"},

            {--separator
                type = "select",
                get = function() return currentInstance.row_info.textR_separator end,
                values = function()
                    return buildSeparatorMenu()
                end,
                name = Loc ["STRING_OPTIONS_TEXT_SHOW_SEPARATOR"],
                desc = Loc ["STRING_OPTIONS_TEXT_SHOW_SEPARATOR_DESC"],
            },
            {--brackets
                type = "select",
                get = function() return currentInstance.row_info.textR_bracket end,
                values = function()
                    return buildBracketMenu()
                end,
                name = Loc ["STRING_OPTIONS_TEXT_SHOW_BRACKET"],
                desc = Loc ["STRING_OPTIONS_TEXT_SHOW_BRACKET_DESC"],
            },

            {type = "blank"},

            {--custom right text
                type = "toggle",
                get = function() return currentInstance.row_info.textR_enable_custom_text end,
                set = function (self, fixedparam, value)
                    editInstanceSetting(currentInstance, "SetBarTextSettings", nil, nil, nil, nil, nil, nil, nil, value)
                    afterUpdate()
                end,
                name = Loc ["STRING_OPTIONS_BARLEFTTEXTCUSTOM"],
                desc = Loc ["STRING_OPTIONS_BARLEFTTEXTCUSTOM_DESC"],
            },
            {--open custom text editor
                type = "execute",
                func = function(self)
                    local callback = function(text)
                        text = text:gsub("||", "|")
                        text = DF:Trim(text)
                        editInstanceSetting(currentInstance, "SetBarTextSettings", nil, nil, nil, nil, nil, nil, nil, nil, text)
                        afterUpdate()
                    end
                    _G.DetailsWindowOptionsBarTextEditor:Open (currentInstance.row_info.textL_custom_text, callback, _G.DetailsOptionsWindow, _detalhes.instance_defaults.row_info.textL_custom_text)
                end,
                icontexture = [[Interface\GLUES\LOGIN\Glues-CheckBox-Check]],
                --icontexcoords = {160/512, 179/512, 142/512, 162/512},
                name = "Edit Custom Text", --localize-me
                desc = Loc ["STRING_OPTIONS_OPEN_ROWTEXT_EDITOR"],
            },
        }

        DF:BuildMenu(sectionFrame, sectionOptions, startX, startY-20, heightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template)
    end

--[[

		

--]]

    tinsert(Details.optionsSection, buildSection)
end