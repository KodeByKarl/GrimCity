local airdrops = {}
local tryCount = 0
local cooldown = math.random(Config.Settings.Cooldown.min, Config.Settings.Cooldown.max)
local nextDropAt = 0
local activeLabel = nil

local function eventName()
    return Config.ScoreboardEventName or 'Airdrop'
end

local function locationLabel(index, coords)
    local labels = Config.LocationLabels or {}
    if labels[index] and labels[index] ~= '' then
        return labels[index]
    end
    if coords then
        return ('Drop Zone (%.0f, %.0f)'):format(coords.x, coords.y)
    end
    return ('Drop Zone #%s'):format(tostring(index or '?'))
end

local function syncScoreboard(status, location, endsAt)
    if GetResourceState('kodebykarl-ui') ~= 'started' then return end
    pcall(function()
        exports['kodebykarl-ui']:SetWorldEvent(eventName(), {
            status = status or 'INACTIVE',
            location = location or '—',
            endsAt = tonumber(endsAt) or 0,
        })
    end)
end

local function setInactiveScoreboard()
    activeLabel = nil
    local ends = nextDropAt
    if Config.Settings.Manual then
        ends = 0
    elseif ends <= 0 then
        ends = os.time() + (cooldown * 60)
        nextDropAt = ends
    end
    syncScoreboard('INACTIVE', '—', ends)
end

local function setActiveScoreboard(label)
    activeLabel = label or 'Airdrop'
    syncScoreboard('ACTIVE', activeLabel, 0)
end

local function canRunCommand(src)
    if src == 0 then return true end
    local ace = Config.Settings.AcePermission or 'command.airdrop'
    if IsPlayerAceAllowed(src, ace) then return true end
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return false end
    local group = xPlayer.getGroup and xPlayer.getGroup() or 'user'
    return group == 'owner' or group == 'developer' or group == 'admin' or group == 'superadmin'
end

local function notify(src, msg, nType)
    if src == 0 then
        print(('[kodebykarl-airdropv2] %s'):format(msg))
        return
    end
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'AIRDROP',
        description = msg,
        type = nType or 'inform',
    })
end

RegisterNetEvent('esx:playerLoaded', function(playerId)
    TriggerClientEvent('kodebykarl-airdropv2:syncAirdrops', playerId, airdrops)
end)

local function RestartCooldown()
    cooldown = math.random(Config.Settings.Cooldown.min, Config.Settings.Cooldown.max)
    nextDropAt = os.time() + (cooldown * 60)
end

local function GetAirdrop(id)
    for _, v in pairs(airdrops) do
        if v.id == id then return v end
    end
    return nil
end

local function GetAirdropIndex(id)
    for k, v in pairs(airdrops) do
        if v.id == id then return k end
    end
    return nil
end

local function RemoveAirdrop(id)
    for k, v in pairs(airdrops) do
        if v.id == id then
            airdrops[k] = nil
            break
        end
    end
end

local function IsLocationTaken(location)
    for _, v in pairs(airdrops) do
        if v.coords == location then
            return true
        end
    end
    return false
end

local function SelectLoottable(lootTable)
    if lootTable ~= nil then
        return Config.LootTables[lootTable].Items
    end

    local randomLootTable = Config.LootTables[math.random(1, #Config.LootTables)]
    local chance = math.random(1, 100)
    while randomLootTable.Chance < chance do
        Wait(10)
        randomLootTable = Config.LootTables[math.random(1, #Config.LootTables)]
        chance = math.random(1, 100)
    end
    return randomLootTable.Items
end

local function RewardPlayer(source, items)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    for _, v in pairs(items) do
        if v.type == 'account' then
            xPlayer.addAccountMoney(v.name, v.count, 'Airdrop')
        else
            if GetResourceState('ox_inventory') == 'started' then
                exports.ox_inventory:AddItem(source, v.name, v.count)
            else
                xPlayer.addInventoryItem(v.name, v.count)
            end
        end
    end
end

local function SpawnAirdrop(lootTable, customCoords, locationIndex)
    local idx = locationIndex or math.random(1, #Config.Locations)
    local randomLocation = Config.Locations[idx]
    local isLocationTaken = IsLocationTaken(randomLocation)

    if tryCount > 10 or not isLocationTaken or customCoords then
        tryCount = 0

        local airdropId = math.random(10000, 99999)
        local airdropItems = SelectLoottable(lootTable)
        local coords = randomLocation
        local label = locationLabel(idx, randomLocation)

        if customCoords then
            coords = customCoords
            label = locationLabel(locationIndex, customCoords)
        elseif coords.z < 150.0 then
            coords = vector3(randomLocation.x, randomLocation.y, 200.0)
        end

        if Config.Settings.DeletePrevious then
            TriggerClientEvent('kodebykarl-airdropv2:removeAllObjects', -1)
            airdrops = {}
        end

        airdrops[#airdrops + 1] = {
            id = airdropId,
            items = airdropItems,
            coords = coords,
            label = label,
            locationIndex = idx,
            landed = false,
        }

        setActiveScoreboard(label)
        TriggerClientEvent('kodebykarl-airdropv2:syncAirdrops', -1, airdrops)
        TriggerClientEvent('kodebykarl-airdropv2:news', -1, label)
        return true
    end

    if isLocationTaken then
        tryCount = tryCount + 1
        return SpawnAirdrop(lootTable)
    end
    return false
end

RegisterNetEvent('kodebykarl-airdropv2:pickupAirdrop', function(id)
    local src = source
    local airdrop = GetAirdrop(id)
    if not airdrop then return end

    RewardPlayer(src, airdrop.items)
    RemoveAirdrop(id)
    TriggerClientEvent('kodebykarl-airdropv2:removeObject', -1, id)
    TriggerClientEvent('kodebykarl-airdropv2:syncAirdrops', -1, airdrops)

    local anyLeft = false
    for _ in pairs(airdrops) do
        anyLeft = true
        break
    end
    if not anyLeft then
        if not Config.Settings.Manual then
            RestartCooldown()
        else
            nextDropAt = 0
        end
        setInactiveScoreboard()
    end

    TriggerClientEvent('ox_lib:notify', -1, {
        title = 'AIRDROP',
        description = 'Airdrop has been looted!',
        type = 'success',
    })
end)

RegisterNetEvent('kodebykarl-airdropv2:airdropLanded', function(id)
    local airdropIndex = GetAirdropIndex(id)
    if not airdropIndex or not airdrops[airdropIndex] then return end
    airdrops[airdropIndex].landed = true
end)

local function StartAirdropLoop()
    RestartCooldown()
    setInactiveScoreboard()
    while true do
        while cooldown > 0 do
            Wait(60000)
            cooldown = cooldown - 1
            nextDropAt = os.time() + (cooldown * 60)
            if not activeLabel then
                setInactiveScoreboard()
            end
        end

        RestartCooldown()

        local players = ESX.GetPlayers and ESX.GetPlayers() or GetPlayers()
        if Config.Settings.SpawnOffline or (not Config.Settings.SpawnOffline and #players > 0) then
            SpawnAirdrop(math.random(1, #Config.LootTables))
        end

        Wait(10)
    end
end

RegisterCommand(Config.Settings.Command or 'spawn_airdrop', function(source)
    if not canRunCommand(source) then
        notify(source, 'No permission.', 'error')
        return
    end
    local idx = math.random(1, #Config.Locations)
    SpawnAirdrop(math.random(1, #Config.LootTables), Config.Locations[idx], idx)
    notify(source, 'Airdrop spawned.', 'success')
end, false)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    setInactiveScoreboard()
    if not Config.Settings.Manual then
        CreateThread(StartAirdropLoop)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    syncScoreboard('INACTIVE', '—', 0)
end)

exports('SpawnAirdrop', function(lootTable, coords, locationIndex)
    return SpawnAirdrop(lootTable, coords, locationIndex)
end)

exports('IsAirdropActive', function()
    for _ in pairs(airdrops) do
        return true
    end
    return false
end)
