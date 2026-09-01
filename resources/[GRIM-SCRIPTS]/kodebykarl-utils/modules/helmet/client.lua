local HitHeadCount = 0

AddEventHandler('entityDamaged', function(victim, culprit, weapon, baseDamage)
    if not culprit or culprit == 0 or not IsPedAPlayer(culprit) then return end
    if cache.ped ~= victim then return end
    if not DoesEntityExist(victim) then return end

    local hit, bone = GetPedLastDamageBone(victim)
    if hit and bone == 31086 then
        HitHeadCount += 1
        if HitHeadCount >= 1 then
            -- Delay clear so deathscreen / hit indicators can read the head bone first
            SetTimeout(50, function()
                if not DoesEntityExist(victim) then return end
                ClearEntityLastDamageEntity(victim)
                ClearPedLastDamageBone(victim)
                pcall(ClearPedProp, victim, 0)
            end)
            HitHeadCount = 0
        end
    end
end)
