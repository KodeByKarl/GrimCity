local FG_RESOURCE_CANDIDATES = { 'grimbot', 'fiveguard', 'fg', 'FiveGuard' }

local function fgResource()
    local named = GetConvar('fiveguard_resource', '')
    if named ~= '' and GetResourceState(named) == 'started' then
        return named
    end
    for i = 1, #FG_RESOURCE_CANDIDATES do
        local name = FG_RESOURCE_CANDIDATES[i]
        if GetResourceState(name) == 'started' then
            return name
        end
    end
    return nil
end

-- FiveGuard Anti Steal Outfit false-bans saved-outfit / wardrobe swaps.
-- Client.BypassStealOutfit is a Client-category temp permission; grant it before clothes apply.
function BypassStealOutfit(holdMs)
    holdMs = tonumber(holdMs) or 15000
    local resource = fgResource()
    if resource then
        pcall(function()
            exports[resource]:SetTempPermission('Client', 'BypassStealOutfit', true, false)
        end)
    end
    TriggerServerEvent('illenium-appearance:server:bypassStealOutfit', holdMs)
end
