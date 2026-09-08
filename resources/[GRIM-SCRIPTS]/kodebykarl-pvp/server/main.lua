local ox_inventory = exports.ox_inventory
local inMatch = {}
local lastReviveAt = {}

ox_inventory:RegisterStash('deathmatch-locker', 'Deathmatch Locker', 10, 100000, true)

local function CountInMatch()
    local n = 0
    for _ in pairs(inMatch) do
        n = n + 1
    end
    return n
end

local function ClearPvpInventory(src)
    ox_inventory:ClearInventory(src, Config.KeepItems)
end

local function Notify(src, msg, nType)
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'PvP',
        description = msg,
        type = nType or 'inform',
        position = 'center-left',
    })
end

local function LeaveMatch(src, notifyClient)
    local data = inMatch[src]
    if not data then return end

    inMatch[src] = nil
    ClearPvpInventory(src)

    local state = Player(src).state
    if state then
        state:set('inPvp', false, true)
        state:set('isInPvp', false, true)
    end

    SetPlayerRoutingBucket(src, data.bucket or 0)
    lastReviveAt[src] = nil

    if notifyClient then
        TriggerClientEvent('kodebykarl-pvp:endMatch', src)
    end
end

RegisterNetEvent('kodebykarl-pvp:requestJoin', function()
    local src = source
    if inMatch[src] then return end

    local maxPlayers = tonumber(Config.MaxPlayers) or 32
    if CountInMatch() >= maxPlayers then
        TriggerClientEvent('kodebykarl-pvp:joinDenied', src, 'Deathmatch is full.')
        return
    end

    inMatch[src] = {
        bucket = GetPlayerRoutingBucket(src),
    }

    local state = Player(src).state
    if state then
        state:set('inPvp', true, true)
        state:set('isInPvp', true, true)
    end

    SetPlayerRoutingBucket(src, Config.Bucket or 50)
    TriggerClientEvent('kodebykarl-pvp:startMatch', src)
end)

RegisterNetEvent('kodebykarl-pvp:requestLeave', function()
    local src = source
    local state = Player(src).state
    if state and (state.dead or state.isReviving) then
        pcall(function()
            exports['kodebykarl-ambulance']:AdminClearDeath(src)
        end)
        TriggerClientEvent('cfx-keydi-ambulance:revive', src)
        TriggerClientEvent('cfx-keydi-ambulance:client:ResetLimbs', src)
        TriggerClientEvent('cfx-keydi-ambulance:client:RemoveBleed', src)
    end
    LeaveMatch(src, true)
end)

RegisterNetEvent('kodebykarl-pvp:requestRevive', function()
    local src = source
    if not inMatch[src] then return end

    local now = GetGameTimer()
    if lastReviveAt[src] and (now - lastReviveAt[src]) < 4000 then
        return
    end
    lastReviveAt[src] = now

    pcall(function()
        exports['kodebykarl-ambulance']:AdminClearDeath(src)
    end)
    TriggerClientEvent('cfx-keydi-ambulance:revive', src)
    TriggerClientEvent('cfx-keydi-ambulance:client:ResetLimbs', src)
    TriggerClientEvent('cfx-keydi-ambulance:client:RemoveBleed', src)
end)

local function GivePvpLoadout(src)
    ClearPvpInventory(src)
    if ox_inventory:CanCarryItem(src, Config.WeaponName, 1) then
        ox_inventory:AddItem(src, Config.WeaponName, 1)
    end
    if ox_inventory:CanCarryItem(src, Config.AmmoName, Config.AmmoAmmount) then
        ox_inventory:AddItem(src, Config.AmmoName, Config.AmmoAmmount)
    end
end

RegisterNetEvent('kodebykarl-pvp:giveLoadout', function()
    local src = source
    if not inMatch[src] then return end
    GivePvpLoadout(src)
end)

RegisterNetEvent('kodebykarl-pvp:AddItem', function(item, quantity, itemLabel)
    local src = source
    if not inMatch[src] then return end

    if item ~= Config.WeaponName and item ~= Config.AmmoName then return end
    if item == Config.WeaponName and quantity > 1 then return end
    if item == Config.AmmoName and quantity > Config.AmmoAmmount then return end

    if ox_inventory:CanCarryItem(src, item, quantity) then
        ox_inventory:AddItem(src, item, quantity)
        Notify(src, ('You received %dx %s'):format(quantity, itemLabel or item), 'success')
    else
        Notify(src, 'Your inventory is full!', 'error')
    end
end)

RegisterNetEvent('kodebykarl-pvp:resetItem', function()
    local src = source
    if not inMatch[src] then return end
    ClearPvpInventory(src)
end)

lib.callback.register('kodebykarl-pvp:status', function(source)
    return {
        ok = true,
        inPvp = inMatch[source] ~= nil,
        players = CountInMatch(),
        maxPlayers = tonumber(Config.MaxPlayers) or 32,
        name = Config.ArenaName or 'Deathmatch Arena',
        tags = Config.ArenaTags or {},
    }
end)

AddEventHandler('playerDropped', function()
    LeaveMatch(source, false)
end)

exports('playingPvPDeathmatch', function(src)
    src = src or source
    return inMatch[src] ~= nil
end)

exports('IsInMatch', function(src)
    return inMatch[src] ~= nil
end)
