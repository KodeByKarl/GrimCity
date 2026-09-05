local ESX = exports['es_extended']:getSharedObject()
local Webhook = require 'server.webhook'

local Drop = nil
local nextDropAt = 0
local lastLocationId = nil
local dropSeq = 0
local claimLocked = false
local claimCount = 0

local ACTIVE_STATUSES = {
    WARNING = true,
    INCOMING = true,
    LOCKED = true,
    OPEN = true,
}

local function dbg(...)
    if Config.Debug then
        print('[kodebykarl-airdrop]', ...)
    end
end

local function countPlayers()
    return #GetPlayers()
end

local function eventName()
    return Config.ScoreboardEventName or 'Airdrop'
end

local function isDropLive()
    return Drop and ACTIVE_STATUSES[Drop.status] == true
end

local function cloneCoords(coords)
    if not coords then return nil end
    return { x = coords.x + 0.0, y = coords.y + 0.0, z = coords.z + 0.0 }
end

local function scoreboardEndsAt()
    if not Drop then return nextDropAt end
    if Drop.status == 'LOCKED' or Drop.status == 'WARNING' or Drop.status == 'INCOMING' then
        return Drop.unlockAt or Drop.expireAt or 0
    end
    if Drop.status == 'OPEN' then
        return Drop.expireAt or 0
    end
    return nextDropAt
end

local function syncScoreboard()
    if GetResourceState('kodebykarl-ui') ~= 'started' then return end
    pcall(function()
        if isDropLive() then
            exports['kodebykarl-ui']:SetWorldEvent(eventName(), {
                status = 'ACTIVE',
                location = Drop.label or '—',
                endsAt = scoreboardEndsAt(),
            })
        else
            exports['kodebykarl-ui']:SetWorldEvent(eventName(), {
                status = 'INACTIVE',
                location = '—',
                endsAt = nextDropAt or 0,
            })
        end
    end)
end

local function publishState()
    local payload = nil
    if Drop then
        payload = {
            seq = Drop.seq,
            status = Drop.status,
            locationId = Drop.locationId,
            label = Drop.label,
            coords = Drop.coords,
            heading = Drop.heading,
            startedAt = Drop.startedAt,
            incomingAt = Drop.incomingAt,
            landAt = Drop.landAt,
            unlockAt = Drop.unlockAt,
            expireAt = Drop.expireAt,
            nextDropAt = nextDropAt,
            claimedBy = Drop.claimedBy,
            serverNow = os.time(),
        }
    else
        payload = {
            seq = 0,
            status = 'IDLE',
            nextDropAt = nextDropAt,
            serverNow = os.time(),
        }
    end
    GlobalState:set('airdrop_event', payload, true)
    syncScoreboard()
end

local function setNextDrop(secondsFromNow)
    nextDropAt = os.time() + math.max(0, math.floor(secondsFromNow or 0))
    publishState()
end

local function enabledLocationIds()
    local list = {}
    for id, loc in pairs(Config.Locations) do
        if loc and loc.enabled ~= false and loc.coords then
            list[#list + 1] = id
        end
    end
    table.sort(list)
    return list
end

local function pickLocation(requestedId)
    if requestedId and requestedId ~= '' and requestedId ~= 'random' then
        local loc = Config.Locations[requestedId]
        if loc and loc.enabled ~= false then
            return requestedId, loc
        end
        return nil, nil
    end

    local ids = enabledLocationIds()
    if #ids == 0 then return nil, nil end

    if Config.AutoDrop.AvoidLastLocation and lastLocationId and #ids > 1 then
        local filtered = {}
        for i = 1, #ids do
            if ids[i] ~= lastLocationId then
                filtered[#filtered + 1] = ids[i]
            end
        end
        if #filtered > 0 then ids = filtered end
    end

    local id = ids[math.random(1, #ids)]
    return id, Config.Locations[id]
end

local function sendChat(kind, message)
    if not Config.ChatAnnounce then return end
    local color = '#ff8080'
    local border = '#ff3a3a'
    if kind == 'success' then
        color = '#2ecc71'
        border = '#2ecc71'
    elseif kind == 'warning' then
        color = '#ffcc66'
        border = '#ffcc66'
    end

    local template = '<div style="background: linear-gradient(135deg, rgba(28, 14, 18, 0.85) 0%, rgba(15, 10, 14, 0.92) 100%); border-radius: 8px; padding: 8px 12px; margin-bottom: 6px; border-left: 3px solid ' .. border .. '; border-top: 1px solid rgba(255, 58, 58, 0.15); box-shadow: 0 4px 15px rgba(0,0,0,0.5); text-align: left; font-family: \'Outfit\', sans-serif; word-break: break-word; overflow-wrap: anywhere; white-space: pre-wrap; max-width: 100%; box-sizing: border-box; flex-shrink: 0; min-height: min-content; line-height: 1.4;">'
        .. '<b style="color: ' .. color .. '; letter-spacing: 0.3px;">[AIRDROP]</b>'
        .. '<span style="color: rgba(255,255,255,0.4); margin: 0 6px;">•</span>'
        .. '<span style="color: #ffffff; font-weight: 600;">' .. message .. '</span>'
        .. '</div>'

    TriggerClientEvent('chat:addMessage', -1, { template = template })
end

local function announce(kind, title, description)
    if Config.Notify.Enable then
        TriggerClientEvent('kodebykarl-airdrop:client:announce', -1, {
            title = title or 'AIRDROP',
            description = description,
            type = kind or 'inform',
            duration = Config.Notify.Duration or 8000,
        })
    end
end

local function playerAllowedToLoot(src)
    local fn = Config.RequireFunction
    if not fn or fn == false or fn == '' then return true end
    if GetResourceState('kodebykarl-ui') ~= 'started' then return false end
    local ok, allowed = pcall(function()
        return exports['kodebykarl-ui']:PlayerHasFunction(src, fn)
    end)
    return ok and allowed == true
end

local function isAdmin(src)
    if src == 0 then return true end
    local ace = Config.Admin and Config.Admin.AcePermission
    if ace and ace ~= '' and IsPlayerAceAllowed(src, ace) then
        return true
    end
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return false end
    local group = (xPlayer.getGroup and xPlayer.getGroup()) or 'user'
    return Config.Admin.Groups and Config.Admin.Groups[group] == true
end

local function rollPool(pool, count)
    local rewards = {}
    if type(pool) ~= 'table' or #pool == 0 or count <= 0 then return rewards end

    local attempts = 0
    while #rewards < count and attempts < 24 do
        attempts += 1
        for i = 1, #pool do
            local entry = pool[i]
            if entry and entry.item and (math.random(1, 100) <= (entry.chance or 100)) then
                local amount = math.random(entry.min or 1, entry.max or 1)
                if amount > 0 then
                    rewards[#rewards + 1] = {
                        item = entry.item,
                        label = entry.label or entry.item,
                        amount = amount,
                    }
                    if #rewards >= count then break end
                end
            end
        end
    end
    return rewards
end

local function generateRewards(location)
    local rewards = {}

    if Config.GuaranteedRewards then
        for i = 1, #Config.GuaranteedRewards do
            local entry = Config.GuaranteedRewards[i]
            if entry and entry.item then
                local amount = math.random(entry.min or 1, entry.max or 1)
                if amount > 0 then
                    rewards[#rewards + 1] = {
                        item = entry.item,
                        label = entry.label or entry.item,
                        amount = amount,
                    }
                end
            end
        end
    end

    local pool = (location and location.rewards) or Config.RewardPool
    local want = math.random(Config.RewardsPerDrop.min or 3, Config.RewardsPerDrop.max or 5)
    local rolled = rollPool(pool, want)
    for i = 1, #rolled do
        rewards[#rewards + 1] = rolled[i]
    end

    if #rewards == 0 and Config.EmptyFallback then
        rewards[1] = {
            item = Config.EmptyFallback.item,
            label = Config.EmptyFallback.label or Config.EmptyFallback.item,
            amount = Config.EmptyFallback.amount or 1,
        }
    end

    return rewards
end

local function endDrop(reason)
    if not Drop then
        publishState()
        return
    end

    dbg('endDrop', reason, Drop.locationId)
    Drop.status = reason == 'claimed' and 'CLAIMED' or 'IDLE'
    Drop.endedReason = reason
    publishState()

    local cleanup = (Config.CleanupDelaySeconds or 8) * 1000
    local seq = Drop.seq
    SetTimeout(cleanup, function()
        if Drop and Drop.seq == seq then
            Drop = nil
            claimLocked = false
            claimCount = 0
            publishState()
        end
    end)
end

local function startDrop(requestedId, source)
    if isDropLive() then
        if not (source and Config.Admin.ForceCancelsActive) then
            return false, 'An airdrop is already active.'
        end
        Drop = nil
        claimLocked = false
        claimCount = 0
        TriggerClientEvent('kodebykarl-airdrop:client:cleanup', -1)
    end

    local id, loc = pickLocation(requestedId)
    if not id or not loc then
        return false, 'Unknown or disabled airdrop location.'
    end

    local now = os.time()
    local warning = math.max(0, Config.WarningSeconds or 0)
    local flight = math.max(1, Config.FlightSeconds or 28)
    local lock = math.max(0, Config.LockSeconds or 120)
    local open = math.max(15, Config.OpenSeconds or 180)

    dropSeq += 1
    lastLocationId = id
    claimLocked = false
    claimCount = 0

    local warningAt = now
    local incomingAt = now + warning
    local landAt = incomingAt + flight
    local unlockAt = landAt + lock
    local expireAt = unlockAt + open

    Drop = {
        seq = dropSeq,
        status = warning > 0 and 'WARNING' or 'INCOMING',
        locationId = id,
        label = loc.label or id,
        coords = cloneCoords(loc.coords),
        heading = loc.heading or 0.0,
        startedAt = warningAt,
        incomingAt = incomingAt,
        landAt = landAt,
        unlockAt = unlockAt,
        expireAt = expireAt,
        claimedBy = nil,
        location = loc,
    }

    publishState()
    TriggerClientEvent('kodebykarl-airdrop:client:sync', -1, GlobalState.airdrop_event)

    local locLabel = Drop.label:upper()
    if warning > 0 then
        sendChat('warning', ('SUPPLY DROP INCOMING AT %s IN %d SECONDS'):format(locLabel, warning))
        announce('warning', 'AIRDROP INCOMING', ('Drop zone: %s — plane inbound in %ds'):format(Drop.label, warning))
    else
        sendChat('inform', ('SUPPLY PLANE INBOUND TO %s'):format(locLabel))
        announce('inform', 'AIRDROP INBOUND', ('Plane inbound to %s'):format(Drop.label))
    end

    Webhook.SendLog('AIRDROP STARTED', 16744192, ('**Location:** %s (`%s`)\n**Started By:** %s\n**Unlock:** <t:%d:R>\n**Expires:** <t:%d:R>'):format(
        Drop.label, id, source and ('player %d'):format(source) or 'scheduler', unlockAt, expireAt
    ))

    dbg('startDrop', id, Drop.status)
    return true
end

local function tryAutoDrop()
    if not Config.AutoDrop.Enable then return end
    if isDropLive() then return end

    local minPlayers = Config.AutoDrop.MinPlayers or 0
    if minPlayers > 0 and countPlayers() < minPlayers then
        dbg('auto skip: min players', countPlayers(), minPlayers)
        setNextDrop((Config.AutoDrop.RetryMinutes or 5) * 60)
        return
    end

    local ok, err = startDrop('random', nil)
    if not ok then
        dbg('auto start failed', err)
        setNextDrop((Config.AutoDrop.RetryMinutes or 5) * 60)
    end
end

-- State machine
CreateThread(function()
    Wait(1500)
    if Config.AutoDrop.Enable then
        setNextDrop((Config.AutoDrop.StartupDelayMinutes or 5) * 60)
    else
        nextDropAt = 0
        publishState()
    end

    while true do
        Wait(1000)
        local now = os.time()

        if Drop and ACTIVE_STATUSES[Drop.status] then
            if Drop.status == 'WARNING' and now >= (Drop.incomingAt or 0) then
                Drop.status = 'INCOMING'
                sendChat('inform', ('SUPPLY PLANE INBOUND TO %s'):format(Drop.label:upper()))
                announce('inform', 'AIRDROP INBOUND', ('Plane inbound to %s'):format(Drop.label))
                publishState()
                TriggerClientEvent('kodebykarl-airdrop:client:sync', -1, GlobalState.airdrop_event)
            elseif Drop.status == 'INCOMING' and now >= (Drop.landAt or 0) then
                Drop.status = 'LOCKED'
                sendChat('inform', ('CRATE LANDED AT %s — UNLOCKS IN %d SECONDS'):format(Drop.label:upper(), Config.LockSeconds or 0))
                announce('inform', 'CRATE LANDED', ('%s — locked for %ds'):format(Drop.label, Config.LockSeconds or 0))
                publishState()
                TriggerClientEvent('kodebykarl-airdrop:client:sync', -1, GlobalState.airdrop_event)
            elseif Drop.status == 'LOCKED' and now >= (Drop.unlockAt or 0) then
                Drop.status = 'OPEN'
                sendChat('success', ('CRATE AT %s IS UNLOCKED — LOOT IT'):format(Drop.label:upper()))
                announce('success', 'CRATE UNLOCKED', ('The airdrop at %s can be looted'):format(Drop.label))
                publishState()
                TriggerClientEvent('kodebykarl-airdrop:client:sync', -1, GlobalState.airdrop_event)
            elseif Drop.status == 'OPEN' and now >= (Drop.expireAt or 0) then
                sendChat('warning', ('AIRDROP AT %s DESPAWNED UNCLAIMED'):format(Drop.label:upper()))
                announce('error', 'AIRDROP EXPIRED', ('The crate at %s is gone'):format(Drop.label))
                Webhook.SendLog('AIRDROP EXPIRED', 16776960, ('**Location:** %s'):format(Drop.label))
                setNextDrop((Config.AutoDrop.IntervalMinutes or 45) * 60)
                endDrop('expired')
                TriggerClientEvent('kodebykarl-airdrop:client:cleanup', -1)
            else
                syncScoreboard()
            end
        elseif Config.AutoDrop.Enable then
            if nextDropAt > 0 and now >= nextDropAt then
                tryAutoDrop()
            else
                syncScoreboard()
            end
        else
            syncScoreboard()
        end
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == 'kodebykarl-ui' then
        syncScoreboard()
    end
end)

RegisterNetEvent('kodebykarl-airdrop:server:claim', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    if not Drop or Drop.status ~= 'OPEN' then
        return TriggerClientEvent('ox_lib:notify', src, {
            title = 'AIRDROP',
            description = 'This crate is not lootable yet.',
            type = 'error',
        })
    end

    if not playerAllowedToLoot(src) then
        return TriggerClientEvent('ox_lib:notify', src, {
            title = 'AIRDROP',
            description = 'You cannot loot the airdrop in this region.',
            type = 'error',
        })
    end

    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return end
    local coords = GetEntityCoords(ped)
    local dropVec = vec3(Drop.coords.x, Drop.coords.y, Drop.coords.z)
    if #(coords - dropVec) > ((Config.Claim.Distance or 2.8) + 1.5) then
        return TriggerClientEvent('ox_lib:notify', src, {
            title = 'AIRDROP',
            description = 'You are too far from the crate.',
            type = 'error',
        })
    end

    if Config.Claim.OneWinner then
        if claimLocked or Drop.claimedBy then
            return TriggerClientEvent('ox_lib:notify', src, {
                title = 'AIRDROP',
                description = 'Someone already claimed this crate.',
                type = 'error',
            })
        end
        claimLocked = true
    else
        local maxPlayers = Config.Claim.MaxPlayers or 1
        if claimCount >= maxPlayers then
            return TriggerClientEvent('ox_lib:notify', src, {
                title = 'AIRDROP',
                description = 'This crate is empty.',
                type = 'error',
            })
        end
    end

    claimCount += 1
    Drop.claimedBy = xPlayer.getName and xPlayer.getName() or GetPlayerName(src)

    local rewards = generateRewards(Drop.location)
    local summary = {}
    for i = 1, #rewards do
        local r = rewards[i]
        exports.ox_inventory:AddItem(src, r.item, r.amount)
        summary[#summary + 1] = ('x%d %s'):format(r.amount, r.label)
    end
    local summaryStr = table.concat(summary, ', ')

    TriggerClientEvent('ox_lib:notify', src, {
        title = 'AIRDROP LOOTED',
        description = ('Received: %s'):format(summaryStr),
        type = 'success',
        duration = 8000,
    })

    sendChat('success', ('AIRDROP AT %s CLAIMED BY %s'):format(Drop.label:upper(), Drop.claimedBy:upper()))
    announce('success', 'AIRDROP CLAIMED', ('%s looted the crate at %s'):format(Drop.claimedBy, Drop.label))
    Webhook.SendLog('AIRDROP CLAIMED', 65280, ('**Player:** %s (ID: %d)\n**Location:** %s\n**Loot:** %s'):format(
        Drop.claimedBy, src, Drop.label, summaryStr
    ))

    local done = Config.Claim.OneWinner or claimCount >= (Config.Claim.MaxPlayers or 1)
    if done then
        setNextDrop((Config.AutoDrop.IntervalMinutes or 45) * 60)
        endDrop('claimed')
        TriggerClientEvent('kodebykarl-airdrop:client:cleanup', -1)
    else
        publishState()
    end
end)

local function adminStart(src, locationId)
    if not isAdmin(src) then
        if src > 0 then
            TriggerClientEvent('ox_lib:notify', src, { title = 'AIRDROP', description = 'No permission.', type = 'error' })
        end
        return
    end
    local ok, err = startDrop(locationId or 'random', src)
    if not ok then
        local msg = err or 'Failed to start airdrop.'
        if src > 0 then
            TriggerClientEvent('ox_lib:notify', src, { title = 'AIRDROP', description = msg, type = 'error' })
        else
            print('[kodebykarl-airdrop] ' .. msg)
        end
        return
    end
    if src > 0 then
        TriggerClientEvent('ox_lib:notify', src, { title = 'AIRDROP', description = ('Started at %s'):format(Drop.label), type = 'success' })
    end
end

local function adminCancel(src)
    if not isAdmin(src) then
        if src > 0 then
            TriggerClientEvent('ox_lib:notify', src, { title = 'AIRDROP', description = 'No permission.', type = 'error' })
        end
        return
    end
    if not isDropLive() then
        if src > 0 then
            TriggerClientEvent('ox_lib:notify', src, { title = 'AIRDROP', description = 'No active airdrop.', type = 'error' })
        end
        return
    end
    sendChat('warning', 'AIRDROP CANCELLED BY ADMIN')
    Webhook.SendLog('AIRDROP CANCELLED', 16711680, ('**By:** %s'):format(src == 0 and 'console' or ('ID %d'):format(src)))
    setNextDrop((Config.AutoDrop.IntervalMinutes or 45) * 60)
    endDrop('cancelled')
    TriggerClientEvent('kodebykarl-airdrop:client:cleanup', -1)
    if src > 0 then
        TriggerClientEvent('ox_lib:notify', src, { title = 'AIRDROP', description = 'Airdrop cancelled.', type = 'success' })
    end
end

lib.addCommand(Config.Admin.Command or 'airdrop', {
    help = 'Force an airdrop (random / location id / cancel)',
    params = {
        { name = 'target', type = 'string', help = 'random, cancel, or location id', optional = true },
    },
}, function(source, args)
    local target = args.target and tostring(args.target):lower() or 'random'
    if target == 'cancel' or target == 'stop' then
        adminCancel(source)
        return
    end
    adminStart(source, target)
end)

lib.addCommand(Config.Admin.NextCommand or 'airdropnext', {
    help = 'Show next airdrop timer',
}, function(source)
    if not isAdmin(source) then
        if source > 0 then
            TriggerClientEvent('ox_lib:notify', source, { title = 'AIRDROP', description = 'No permission.', type = 'error' })
        end
        return
    end
    local remaining = math.max(0, (nextDropAt or 0) - os.time())
    local mins = math.floor(remaining / 60)
    local secs = remaining % 60
    local live = isDropLive() and Drop.label or 'none'
    local msg = ('Active: %s | Next drop in %d:%02d'):format(live, mins, secs)
    if source > 0 then
        TriggerClientEvent('ox_lib:notify', source, { title = 'AIRDROP', description = msg, type = 'inform' })
    else
        print('[kodebykarl-airdrop] ' .. msg)
    end
end)

exports('GetState', function()
    return Drop and {
        status = Drop.status,
        locationId = Drop.locationId,
        label = Drop.label,
        unlockAt = Drop.unlockAt,
        expireAt = Drop.expireAt,
        nextDropAt = nextDropAt,
    } or { status = 'IDLE', nextDropAt = nextDropAt }
end)

exports('StartDrop', function(locationId)
    return startDrop(locationId or 'random', 0)
end)

exports('CancelDrop', function()
    adminCancel(0)
    return true
end)
