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

local currentZoneIndex = 0

-- Helper: Build Fit-To-Text Rotation Chat Template
local function SendTrapHouseRotationChatTemplate(zoneLabel)
    local template = '<div style="background: linear-gradient(135deg, rgba(28, 14, 18, 0.85) 0%, rgba(15, 10, 14, 0.92) 100%); border-radius: 8px; padding: 8px 12px; margin-bottom: 6px; border-left: 3px solid #ff3a3a; border-top: 1px solid rgba(255, 58, 58, 0.15); box-shadow: 0 4px 15px rgba(0,0,0,0.5); text-align: left; font-family: \'Outfit\', sans-serif; word-break: break-word; overflow-wrap: anywhere; white-space: pre-wrap; max-width: 100%; box-sizing: border-box; flex-shrink: 0; min-height: min-content; line-height: 1.4;">'
        .. '<b style="color: #ff8080; letter-spacing: 0.3px;">[TRAPHOUSE REDZONE]</b>'
        .. '<span style="color: rgba(255,255,255,0.4); margin: 0 6px;">•</span>'
        .. '<span style="color: #ffffff; font-weight: 600;">ACTIVE TRAPHOUSE HAS ROTATED TO ' .. zoneLabel:upper() .. ' FOR THE NEXT ' .. (Config.RotationMinutes or 15) .. ' MINUTES!</span>'
        .. '</div>'

    TriggerClientEvent('chat:addMessage', -1, { template = template })
end

-- Helper: Rotate to Next TrapHouse Location
local function rotateActiveTrapHouse()
    if #Config.TrapZones == 0 then return end

    local nextIndex = currentZoneIndex + 1
    if nextIndex > #Config.TrapZones then
        nextIndex = 1
    end
    currentZoneIndex = nextIndex

    local zone = Config.TrapZones[currentZoneIndex]
    local activeData = {
        id = zone.id,
        label = zone.label,
        coords = zone.coords,
        radius = zone.radius,
        blip = zone.blip,
        expires = os.time() + ((Config.RotationMinutes or 15) * 60)
    }

    GlobalState:set('traphouse_active_zone', activeData, true)
    SendTrapHouseRotationChatTemplate(zone.label)

    Webhook.SendLog('TRAPHOUSE ROTATED', 16744192, ('**Active Zone:** %s\n**Duration:** %d minutes'):format(zone.label, Config.RotationMinutes or 15))
end

-- Helper: Check if server vector coords is inside current ACTIVE TrapHouse zone
local function getActiveTrapZone(coords)
    if not coords then return nil end
    local activeZone = GlobalState.traphouse_active_zone
    if not activeZone then return nil end

    local dist = #(coords - activeZone.coords)
    if dist <= activeZone.radius then
        return activeZone
    end
    return nil
end

-- Server Loop for 15-Minute Rotation
CreateThread(function()
    Wait(2000) -- Initial startup delay
    rotateActiveTrapHouse()

    while true do
        Wait((Config.RotationMinutes or 15) * 60 * 1000)
        rotateActiveTrapHouse()
    end
end)

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
