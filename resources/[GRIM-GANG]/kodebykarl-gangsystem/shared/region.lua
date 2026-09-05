--[[
  Gang world features (bases, stashes, blips) — Region 3 / 4 only (turfwar).
]]

GangRegion = GangRegion or {}

function GangRegion.Allowed(src)
    if GetResourceState('kodebykarl-ui') ~= 'started' then
        return false
    end

    if IsDuplicityVersion() then
        local ok, allowed = pcall(function()
            return exports['kodebykarl-ui']:PlayerHasFunction(src, 'turfwar')
        end)
        return ok and allowed == true
    end

    local ok, allowed = pcall(function()
        return exports['kodebykarl-ui']:HasFunction('turfwar')
    end)
    return ok and allowed == true
end
