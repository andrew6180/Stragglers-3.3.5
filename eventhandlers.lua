local OUR_NAME, profiler = ...

local CreateFrame = profilingmonitor(_G.CreateFrame)

function profiler.isFirstAddonLoaded()
    -- Are any other addons loaded?
    for i=1,GetNumAddOns() do
        if IsAddOnLoaded(i) then
            local name = GetAddOnInfo(i)
            if not name=="!Profiler" then
                return false, name
            end
        end
    end
    return true
end

--
-- Load addon and handle events
--

profiler.frame = CreateFrame("Frame", "Profiler", UIParent)
profiler.events = {
    ADDON_LOADED = function(frame, addon_name)
        print("loaded", addon_name)
        if addon_name==OUR_NAME then
            -- We were loaded
            if not profiler.isFirstAddonLoaded() then
                error(OUR_NAME.." was not loaded first, this will likely lead to attributing functions to the wrong addons.")
            end

            -- Start listening for new globals
            local blizzard = profiler.newGlobals()
            profiler.registerNamespace("Blizzard", blizzard)

            -- Claim our own functions
            _G.profiler = profiler
            profiler.registerNamespace(OUR_NAME, profiler.newGlobals())
        else
            -- another addon was loaded - assume new stuff comes from it
            local new = profiler.newGlobals()
            profiler.registerNamespace(addon_name, new)
        end
    end,

    PLAYER_LOGIN = function(frame, ...)
    end,

    PLAYER_ENTERING_WORLD = function(frame, ...)
        profiler.ui.Window:init()
        profiler.freezeStartup()
    end,

}


-- Dispatch events
profiler.frame:SetScript("OnEvent", function(self, event, ...)
    profiler.events[event](self, ...)
end)

-- Register events
for k, v in pairs(profiler.events) do
    profiler.frame:RegisterEvent(k)
end
