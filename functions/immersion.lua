
--Immersion enables players that isn't in your group to show on the damage meter window


local Details = _G.Details
local C_Timer = _G.C_Timer
local C_Map = _G.C_Map

local immersionFrame = _G.CreateFrame("frame", "DetailsImmersionFrame", _G.UIParent)
immersionFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
immersionFrame.DevelopmentDebug = true

--check if can enabled the immersion stuff
function immersionFrame.CheckIfCanEnableImmersion()

    local mapID =  C_Map.GetBestMapForUnit("player")
    if (mapID) then
        local mapFileName = C_Map.GetMapInfo(mapID)
        mapFileName = mapFileName and mapFileName.name

        if (mapFileName and mapFileName:find("InvasionPoint")) then
            Details.immersion_enabled = true
            if (immersionFrame.DevelopmentDebug) then
                print("Details!", "CheckIfCanEnableImmersion() > immersion enabled.")
            end
        else
            if (Details.immersion_enabled) then
                if (immersionFrame.DevelopmentDebug) then
                    print("Details!", "CheckIfCanEnableImmersion() > immersion disabled.")
                end
                Details.immersion_enabled = nil
            end
        end
    end
end

--check events
immersionFrame:SetScript("OnEvent", function (_, event, ...)
    if (event == "ZONE_CHANGED_NEW_AREA") then
        C_Timer.After(3, immersionFrame.CheckIfCanEnableImmersion)
    end
end)