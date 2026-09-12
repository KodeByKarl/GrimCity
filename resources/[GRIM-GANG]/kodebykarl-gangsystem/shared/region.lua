--[[
  Gang world features (bases, stashes, blips) — Region 1 only (gangbase).
]]

GangRegion = GangRegion or {}

function GangRegion.Allowed(src)
    if GetResourceState('kodebykarl-ui') ~= 'started' then
        return false
    end

    if IsDuplicityVersion() then
        local ok, allowed = pcall(function()
            return exports['kodebykarl-ui']:PlayerHasFunction(src, 'gangbase')
        end)
        return ok and allowed == true
    end

    local ok, allowed = pcall(function()
        return exports['kodebykarl-ui']:HasFunction('gangbase')
    end)
    return ok and allowed == true
end
