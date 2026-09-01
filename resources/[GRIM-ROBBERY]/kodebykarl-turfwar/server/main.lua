local ESX = exports['es_extended']:getSharedObject()
local Webhook = require 'server.webhook'

local ActiveTurfs = {}
local CooldownTurfs = {}
local ClaimableTurfs = {}

-- Initialize GlobalState on startup
CreateThread(function()
    Wait(1000)
    for id, data in pairs(Config.TurfWars) do
        GlobalState:set(('turf_state_%s'):format(id), 'IDLE', true)
        GlobalState:set(('turf_timer_%s'):format(id), 0, true)
        GlobalState:set(('turf_cooldown_%s'):format(id), 0, true)
        GlobalState:set(('turf_claimable_%s'):format(id), false, true)
        ClaimableTurfs[id] = false
        ActiveTurfs[id] = nil
        CooldownTurfs[id] = nil
    end
end)

-- Scoreboard & HUD World Event Synchronization
local function updateScoreboardEvents()
    if GetResourceState('cfx-keydi-ui') ~= 'started' then return end

    local activeLabels = {}
    for id, data in pairs(Config.TurfWars) do
        if ActiveTurfs[id] or ClaimableTurfs[id] then
            activeLabels[#activeLabels + 1] = data.label
        end
    end

    if #activeLabels == 0 then
        pcall(function()
            exports['cfx-keydi-ui']:SetWorldEvent('Turf Wars', {
                status = 'INACTIVE',
                location = 'None',
            })
        end)
    else
        table.sort(activeLabels)
        pcall(function()
            exports['cfx-keydi-ui']:SetWorldEvent('Turf Wars', {
                status = 'ACTIVE',
                location = table.concat(activeLabels, ', '),
            })
        end)
    end
end

local function addScoreboardRobbery(id, label, remainingSecs)
    if GetResourceState('cfx-keydi-ui') ~= 'started' then return end
    pcall(function()
        exports['cfx-keydi-ui']:AddActiveRobbery(('turfwar_%s'):format(id), {
            name = label or 'Turf War',
            location = label or 'Turf Zone',
            timer = math.max(remainingSecs or 0, 1),
            sticky = true,
        })
    end)
    updateScoreboardEvents()
end

local function removeScoreboardRobbery(id)
    if GetResourceState('cfx-keydi-ui') ~= 'started' then return end
    pcall(function()
        exports['cfx-keydi-ui']:RemoveActiveRobbery(('turfwar_%s'):format(id))
    end)
    updateScoreboardEvents()
end

-- Helper: Get Player Gang Data
local function getPlayerGang(xPlayer)
    local gang = nil
    if xPlayer.getGang then
        gang = xPlayer.getGang()
    elseif xPlayer.gang then
        gang = xPlayer.gang
    end

    if type(gang) == 'table' then
        return gang.name or 'none', gang.label or 'Unemployed'
    elseif type(gang) == 'string' then
        return gang, gang:gsub('^%l', string.upper)
    end

    return 'none', 'Unemployed'
end

-- Helper: Count online gang members
local function countOnlineGangMembers(gangName)
    if not gangName or gangName == '' or Config.IgnoreGangs[gangName] then return 0 end
    local count = 0
    local players = ESX.GetExtendedPlayers()
    for _, xPlayer in pairs(players) do
        local gName = getPlayerGang(xPlayer)
        if gName == gangName then
            count += 1
        end
    end
    return count
end

-- Helper: Build Simple Police/Job Style Chat Templates
local function SendTurfStartChatTemplate(turfLabel, playerName, gangLabel)
    local curTime = os.date("%H:%M")
    local template = '<div style="background: #0f0f13; border-radius: 4px; border: 1px solid rgba(255, 58, 58, 0.4); padding: 10px; margin-bottom: 8px; font-family: sans-serif; position: relative; box-shadow: inset 0 0 100px rgba(0,0,0,0.8); word-break: break-word; overflow-wrap: anywhere; flex-shrink: 0; min-height: min-content;">'
        .. '  <div style="display: flex; justify-content: space-between; font-size: 11px; color: #ff8080; font-weight: 600; text-transform: uppercase;">'
        .. '    <span>FEED • TURF WAR | INITIATED</span>'
        .. '    <span>' .. curTime .. '</span>'
        .. '  </div>'
        .. '  <div style="color: #ffffff; font-size: 13px; font-weight: 700; text-transform: uppercase; margin-top: 6px; line-height: 1.4; text-shadow: 0 2px 4px rgba(0,0,0,0.85);">'
        .. '    TURF WAR HAS BEEN INITIATED AT ' .. turfLabel .. ' BY ' .. playerName:upper() .. ' (' .. gangLabel:upper() .. ')'
        .. '  </div>'
        .. '</div>'

    TriggerClientEvent('chat:addMessage', -1, { template = template })
end

local function SendTurfClaimChatTemplate(turfLabel, claimerName, gangLabel)
    local curTime = os.date("%H:%M")
    local template = '<div style="background: #0f0f13; border-radius: 4px; border: 1px solid rgba(46, 204, 113, 0.4); padding: 10px; margin-bottom: 8px; font-family: sans-serif; position: relative; box-shadow: inset 0 0 100px rgba(0,0,0,0.8); word-break: break-word; overflow-wrap: anywhere; flex-shrink: 0; min-height: min-content;">'
        .. '  <div style="display: flex; justify-content: space-between; font-size: 11px; color: #2ecc71; font-weight: 600; text-transform: uppercase;">'
        .. '    <span>FEED • TURF WAR | CLAIMED</span>'
        .. '    <span>' .. curTime .. '</span>'
        .. '  </div>'
        .. '  <div style="color: #ffffff; font-size: 13px; font-weight: 700; text-transform: uppercase; margin-top: 6px; line-height: 1.4; text-shadow: 0 2px 4px rgba(0,0,0,0.85);">'
        .. '    TURF WAR AT ' .. turfLabel .. ' HAS BEEN CLAIMED BY ' .. claimerName:upper() .. ' (' .. gangLabel:upper() .. ')'
        .. '  </div>'
        .. '</div>'

    TriggerClientEvent('chat:addMessage', -1, { template = template })
end

-- Server Main Loop: Timer countdowns & Cooldown handling
CreateThread(function()
    while true do
        Wait(1000)

        -- Handle Active Turfs Timer
        for id, remaining in pairs(ActiveTurfs) do
            if remaining > 0 then
                local nextSec = remaining - 1
                ActiveTurfs[id] = nextSec
                GlobalState:set(('turf_timer_%s'):format(id), nextSec, true)

                -- Countdown finished -> Enters CLAIMABLE state at trigger spot!
                if nextSec <= 0 then
                    ActiveTurfs[id] = nil
                    ClaimableTurfs[id] = true
                    GlobalState:set(('turf_state_%s'):format(id), 'CLAIMABLE', true)
                    GlobalState:set(('turf_claimable_%s'):format(id), true, true)

                    local data = Config.TurfWars[id]
                    if data then
                        addScoreboardRobbery(id, data.label, 0)
                    end
                end
            end
        end

        -- Handle Cooldown Timers
        for id, remaining in pairs(CooldownTurfs) do
            if remaining > 0 then
                local nextCd = remaining - 1
                CooldownTurfs[id] = nextCd
                GlobalState:set(('turf_cooldown_%s'):format(id), nextCd, true)

                if nextCd <= 0 then
                    CooldownTurfs[id] = nil
                    GlobalState:set(('turf_state_%s'):format(id), 'IDLE', true)
                    GlobalState:set(('turf_cooldown_%s'):format(id), 0, true)
                end
            end
        end
    end
end)

-- Register Event: Start Turf War Sequence
RegisterNetEvent('kodebykarl-turfwar:server:startTurf', function(turfId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local data = Config.TurfWars[turfId]
    if not data then return end

    -- Distance Anti-Exploit Check
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    if #(coords - data.coords) > 10.0 then
        return TriggerClientEvent('ox_lib:notify', src, { title = 'TURF WAR', description = 'You are too far from the trigger location.', type = 'error' })
    end

    -- State Checks
    if ActiveTurfs[turfId] or ClaimableTurfs[turfId] then
        return TriggerClientEvent('ox_lib:notify', src, { title = 'TURF WAR', description = 'This Turf War is already active or claimable!', type = 'error' })
    end

    if CooldownTurfs[turfId] and CooldownTurfs[turfId] > 0 then
        local secs = CooldownTurfs[turfId]
        local mins = math.floor(secs / 60)
        return TriggerClientEvent('ox_lib:notify', src, { title = 'TURF WAR', description = ('Turf is on cooldown (%dm remaining).'):format(mins), type = 'error' })
    end

    if not Config.AllowMultipleTurfwars and next(ActiveTurfs) then
        return TriggerClientEvent('ox_lib:notify', src, { title = 'TURF WAR', description = 'Another Turf War is currently in progress.', type = 'error' })
    end

    -- Gang / Test Job Validation
    local gangName, gangLabel = getPlayerGang(xPlayer)
    local jobName = (xPlayer.job and xPlayer.job.name) or (xPlayer.getJob and xPlayer.getJob().name) or 'unemployed'
    local isAllowedTestPlayer = Config.AllowAllJobsForTesting or (Config.AllowTestJobs and Config.AllowTestJobs[jobName])

    if not isAllowedTestPlayer and Config.IgnoreGangs[gangName] then
        return TriggerClientEvent('ox_lib:notify', src, { title = 'TURF WAR', description = 'You must belong to an active Gang to initiate a Turf War.', type = 'error' })
    end

    -- Online Members Check
    if not isAllowedTestPlayer and Config.MinGangMembersOnline > 0 then
        local onlineCount = countOnlineGangMembers(gangName)
        if onlineCount < Config.MinGangMembersOnline then
            return TriggerClientEvent('ox_lib:notify', src, { title = 'TURF WAR', description = ('At least %d members of your gang must be online (%d/%d).'):format(Config.MinGangMembersOnline, onlineCount, Config.MinGangMembersOnline), type = 'error' })
        end
    end

    -- Start War Sequence
    ActiveTurfs[turfId] = data.timer
    CooldownTurfs[turfId] = data.cooldown
    ClaimableTurfs[turfId] = false

    GlobalState:set(('turf_state_%s'):format(turfId), 'ACTIVE', true)
    GlobalState:set(('turf_timer_%s'):format(turfId), data.timer, true)
    GlobalState:set(('turf_cooldown_%s'):format(turfId), data.cooldown, true)
    GlobalState:set(('turf_claimable_%s'):format(turfId), false, true)

    addScoreboardRobbery(turfId, data.label, data.timer)

    -- Send Simple Police Announcement Style Chat Template
    SendTurfStartChatTemplate(data.label, xPlayer.name, gangLabel)

    -- Webhook Log
    local logMsg = ('**Initiated By:** %s (ID: %d)\n**Gang:** %s\n**Location:** %s\n**Timer:** %d seconds'):format(
        xPlayer.name, src, gangLabel, data.label, data.timer
    )
    Webhook.SendLog('TURF WAR - INITIATED', 16744192, logMsg)
end)

-- Register Event: Claim Rewards Right Where Triggered
RegisterNetEvent('kodebykarl-turfwar:server:claimTurf', function(turfId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local data = Config.TurfWars[turfId]
    if not data then return end

    -- Verify Turf is Claimable
    if not ClaimableTurfs[turfId] or GlobalState[('turf_claimable_%s'):format(turfId)] ~= true then
        return TriggerClientEvent('ox_lib:notify', src, { title = 'TURF WAR', description = 'Rewards for this Turf War are not claimable.', type = 'error' })
    end

    -- Strict Distance Check (Must be standing right at the trigger coordinates)
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    if #(coords - data.coords) > 6.0 then
        return TriggerClientEvent('ox_lib:notify', src, { title = 'TURF WAR', description = 'You must be right at the trigger spot to claim rewards.', type = 'error' })
    end

    -- Gang / Test Job Check
    local gangName, gangLabel = getPlayerGang(xPlayer)
    local jobName = (xPlayer.job and xPlayer.job.name) or (xPlayer.getJob and xPlayer.getJob().name) or 'unemployed'
    local isAllowedTestPlayer = Config.AllowAllJobsForTesting or (Config.AllowTestJobs and Config.AllowTestJobs[jobName])

    if not isAllowedTestPlayer and Config.IgnoreGangs[gangName] then
        return TriggerClientEvent('ox_lib:notify', src, { title = 'TURF WAR', description = 'Only active gang members can claim Turf War rewards.', type = 'error' })
    end

    -- Lock Claim to prevent duplicate payouts
    ClaimableTurfs[turfId] = false
    GlobalState:set(('turf_claimable_%s'):format(turfId), false, true)
    GlobalState:set(('turf_state_%s'):format(turfId), 'COOLDOWN', true)

    removeScoreboardRobbery(turfId)

    -- Distribute Item Rewards directly via ox_inventory
    local claimedSummary = {}
    for _, reward in ipairs(data.rewards) do
        local count = math.random(reward.min, reward.max)
        if count > 0 then
            exports.ox_inventory:AddItem(src, reward.item, count)
            claimedSummary[#claimedSummary + 1] = ('x%d %s'):format(count, reward.label or reward.item)
        end
    end

    local itemsListStr = table.concat(claimedSummary, ', ')

    -- Send Simple Police Announcement Style Chat Template
    SendTurfClaimChatTemplate(data.label, xPlayer.name, gangLabel)

    TriggerClientEvent('ox_lib:notify', src, {
        title = 'REWARDS CLAIMED',
        description = ('Received: %s'):format(itemsListStr),
        type = 'success',
        duration = 8000
    })

    -- Webhook Log
    local logMsg = ('**Claimed By:** %s (ID: %d)\n**Gang:** %s\n**Location:** %s\n**Items Claimed:** %s'):format(
        xPlayer.name, src, gangLabel, data.label, itemsListStr
    )
    Webhook.SendLog('TURF WAR - REWARDS CLAIMED', 65280, logMsg)
end)
