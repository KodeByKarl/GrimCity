local ESX = exports['es_extended']:getSharedObject()
local Webhook = require 'server.webhook'

-- Anti-Farm Tracker: [killerId_victimId] = timestamp
local KillHistory = {}

-- Helper: Get Gang/Job Label
local function getPlayerGangLabel(xPlayer)
    if not xPlayer then return 'Unemployed' end
    local gang = nil
    if xPlayer.getGang then
        gang = xPlayer.getGang()
    elseif xPlayer.gang then
        gang = xPlayer.gang
    end

    if type(gang) == 'table' then
        return gang.label or gang.name or 'Unemployed'
    elseif type(gang) == 'string' then
        return gang:gsub('^%l', string.upper)
    end

    return 'Unemployed'
end

-- Helper: Check if server vector coords is inside any TrapHouse zone
local function getActiveTrapZone(coords)
    if not coords then return nil end
    for _, zone in ipairs(Config.TrapZones) do
        local dist = #(coords - zone.coords)
        if dist <= zone.radius then
            return zone
        end
    end
    return nil
end

-- Helper: Generate Weighted Items to Give
local function generateKillRewards()
    local rewardsToGive = {}
    local maxItems = math.random(Config.RewardsPerKill.min or 1, Config.RewardsPerKill.max or 2)
    local attempts = 0

    while #rewardsToGive < maxItems and attempts < 15 do
        attempts += 1
        for _, entry in ipairs(Config.RewardPool) do
            local roll = math.random(1, 100)
            if roll <= entry.chance then
                local amount = math.random(entry.min, entry.max)
                if amount > 0 then
                    rewardsToGive[#rewardsToGive + 1] = {
                        item = entry.item,
                        label = entry.label or entry.item,
                        amount = amount
                    }
                    if #rewardsToGive >= maxItems then break end
                end
            end
        end
    end

    -- Fallback default reward if roll yields empty
    if #rewardsToGive == 0 then
        rewardsToGive[1] = { item = 'black_money', label = 'Dirty Money', amount = 1500 }
    end

    return rewardsToGive
end

-- Primary Secured Kill Handler (Triggered 100% Server-Side)
local function handleTrapHouseKill(victimSrc, killerSrc, deathData)
    if not victimSrc or not killerSrc or victimSrc == killerSrc then return end

    local xVictim = ESX.GetPlayerFromId(victimSrc)
    local xKiller = ESX.GetPlayerFromId(killerSrc)
    if not xVictim or not xKiller then return end

    -- Verify Killer Ped & Coords on Server
    local killerPed = GetPlayerPed(killerSrc)
    if not DoesEntityExist(killerPed) then return end
    local killerCoords = GetEntityCoords(killerPed)

    -- Check if Killer is inside a TrapHouse RedZone
    local zone = getActiveTrapZone(killerCoords)
    if not zone then return end

    -- Anti-Farm Cooldown Check (Prevents repeated farming between 2 players)
    local killKey = ('%d_%d'):format(killerSrc, victimSrc)
    local lastKill = KillHistory[killKey] or 0
    local curTime = os.time()

    if (curTime - lastKill) < (Config.AntiFarmCooldown or 180) then
        TriggerClientEvent('ox_lib:notify', killerSrc, {
            title = 'TRAPHOUSE ANTI-FARM',
            description = 'Anti-Farm cooldown active for this target.',
            type = 'error'
        })
        return
    end

    -- Record Kill Timestamp
    KillHistory[killKey] = curTime

    -- Generate & Distribute Rewards via ox_inventory
    local itemsToGive = generateKillRewards()
    local rewardsSummary = {}

    for _, reward in ipairs(itemsToGive) do
        exports.ox_inventory:AddItem(killerSrc, reward.item, reward.amount)
        rewardsSummary[#rewardsSummary + 1] = ('x%d %s'):format(reward.amount, reward.label)
    end

    local summaryStr = table.concat(rewardsSummary, ', ')

    -- Notify Killer
    TriggerClientEvent('ox_lib:notify', killerSrc, {
        title = ('TRAPHOUSE KILL: %s'):format(zone.label),
        description = ('Eliminated %s! Claimed: %s'):format(xVictim.name, summaryStr),
        type = 'success',
        duration = 7000
    })

    -- Discord Webhook Log
    local killerGang = getPlayerGangLabel(xKiller)
    local victimGang = getPlayerGangLabel(xVictim)
    local logMsg = ('**Killer:** %s (ID: %d | Gang: %s)\n**Victim:** %s (ID: %d | Gang: %s)\n**TrapZone:** %s\n**Rewards Granted:** %s'):format(
        xKiller.name, killerSrc, killerGang, xVictim.name, victimSrc, victimGang, zone.label, summaryStr
    )
    Webhook.SendLog('TRAPHOUSE REDZONE KILL', 65280, logMsg)
end

-- ESX Death Listener
RegisterNetEvent('esx:onPlayerDeath', function(data)
    local victim = source
    if not data or not data.killerServerId then return end
    handleTrapHouseKill(victim, data.killerServerId, data)
end)

-- Native baseevents Death Listener (Fallback)
RegisterNetEvent('baseevents:onPlayerKilled', function(killerId, data)
    local victim = source
    handleTrapHouseKill(victim, killerId, data)
end)

-- Periodically clean up old kill history entries
CreateThread(function()
    while true do
        Wait(300000) -- Every 5 minutes
        local curTime = os.time()
        for key, time in pairs(KillHistory) do
            if (curTime - time) > 600 then
                KillHistory[key] = nil
            end
        end
    end
end)
