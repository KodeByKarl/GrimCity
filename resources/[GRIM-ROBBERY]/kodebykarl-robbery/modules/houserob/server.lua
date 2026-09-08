--[[
  House robbery — all rewards / item changes are server-authoritative.
  Clients only request actions; every handler re-validates source, distance, and state.
]]

local HouseRob = {
    inside = {}, -- [src] = houseKey
    lockpickBusy = {}, -- [src] = true
    searchBusy = {}, -- [src] = true
    soundAlertAt = {}, -- [src] = gameTimer
}

local function getHouse(house)
    return house and Config.HouseRob.Houses[house] or nil
end

local function playerCoords(src)
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return nil end
    return GetEntityCoords(ped)
end

local function nearHouseDoor(src, house, maxDist)
    local h = getHouse(house)
    if not h or not h.coords then return false end
    local pos = playerCoords(src)
    if not pos then return false end
    local door = vec3(h.coords.x, h.coords.y, h.coords.z)
    return #(pos - door) <= (maxDist or 3.0)
end

local function isPlayerPolice(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or not xPlayer.job then return false end
    local name = tostring(xPlayer.job.name):lower()
    return name == 'police' or name == 'sheriff'
end

local function setInside(src, house)
    HouseRob.inside[src] = house
end

local function clearInside(src)
    HouseRob.inside[src] = nil
end

local function ResetHouseStateTimer(house)
    CreateThread(function()
        Wait(Config.HouseRob.TimeToCloseDoors * 60000)
        local h = getHouse(house)
        if not h then return end
        h.opened = false
        h.rewardClaimed = false
        local furnitureData = h.furniture
        for i = 1, #furnitureData do
            furnitureData[i].searched = false
            furnitureData[i].isBusy = false
        end
        TriggerClientEvent('cfx-cs-robbery:houserob:client:ResetHouseState', -1, house)
    end)
end

lib.callback.register('cfx-cs-robbery:houserob:server:GetHouseConfig', function(_)
    return Config.HouseRob.Houses
end)

--- Boss/police enter or re-enter an already opened house
RegisterNetEvent('cfx-cs-robbery:houserob:server:enterHouse', function(house)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local h = getHouse(house)
    if not xPlayer or not h then return end
    if not nearHouseDoor(src, house, 3.5) then return end

    -- First open only via finishLockpick; this event is for already-open or police
    if not h.opened and not isPlayerPolice(src) then
        return
    end

    if not h.opened then
        -- Police forcing entry on closed house
        ResetHouseStateTimer(house)
        h.opened = true
        TriggerClientEvent('cfx-cs-robbery:houserob:client:setHouseState', -1, house, true)
        lib.logger(src, 'robbery_houserob', xPlayer.name .. ' [' .. src .. '] police-entered house ' .. house)
    end

    setInside(src, house)
    SetPlayerRoutingBucket(src, h.routingBucket or 0)
    TriggerClientEvent('cfx-cs-robbery:houserob:client:enterHouse', src, house)
end)

--- Lockpick result — server decides break + open (client skillcheck is UX only)
RegisterNetEvent('cfx-cs-robbery:houserob:server:finishLockpick', function(house, success, usingAdvanced)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local h = getHouse(house)
    if not xPlayer or not h then return end
    if HouseRob.lockpickBusy[src] then return end
    if h.opened then return end
    if not nearHouseDoor(src, house, 3.5) then return end
    if isPlayerPolice(src) then return end

    HouseRob.lockpickBusy[src] = true

    local itemName = usingAdvanced and 'advancedlockpick' or 'lockpick'
    local count = ox_inventory:GetItemCount(src, itemName) or 0
    if count < 1 then
        HouseRob.lockpickBusy[src] = nil
        TriggerClientEvent('esx:Notify', src, 'House Robbery', 'You need a lockpick.', 'error', 5000)
        return
    end

    success = success == true

    if not success then
        local breakChance = usingAdvanced and 25 or 50
        if math.random(1, 100) <= breakChance then
            ox_inventory:RemoveItem(src, itemName, 1)
            TriggerClientEvent('esx:Notify', src, 'House Robbery', 'The lockpick bent and broke...', 'error', 5000)
        else
            TriggerClientEvent('esx:Notify', src, 'House Robbery', 'Failed to pick the lock.', 'error', 5000)
        end
        HouseRob.lockpickBusy[src] = nil
        return
    end

    -- Successful first open
    ResetHouseStateTimer(house)
    h.opened = true
    TriggerClientEvent('cfx-cs-robbery:houserob:client:setHouseState', -1, house, true)
    lib.logger(src, 'robbery_houserob', xPlayer.name .. ' [' .. src .. '] started house robbery at ' .. house)

    setInside(src, house)
    SetPlayerRoutingBucket(src, h.routingBucket or 0)
    TriggerClientEvent('esx:Notify', src, 'House Robbery', 'Lock picked successfully!', 'success', 5000)
    TriggerClientEvent('cfx-cs-robbery:houserob:client:enterHouse', src, house)

    HouseRob.lockpickBusy[src] = nil
end)

RegisterNetEvent('cfx-cs-robbery:houserob:server:SetBusyState', function(cabin, house, bool)
    local src = source
    local h = getHouse(house)
    if not h or not h.furniture or not h.furniture[cabin] then return end
    if HouseRob.inside[src] ~= house then return end
    h.furniture[cabin].isBusy = bool and true or false
    TriggerClientEvent('cfx-cs-robbery:houserob:client:SetBusyState', -1, cabin, house, h.furniture[cabin].isBusy)
end)

RegisterNetEvent('cfx-cs-robbery:houserob:server:searchFurniture', function(cabin, house)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local h = getHouse(house)
    if not xPlayer or not h then return end
    if HouseRob.inside[src] ~= house then return end
    if HouseRob.searchBusy[src] then return end
    if not cabin or not h.furniture[cabin] then return end
    if h.furniture[cabin].searched then return end
    if not h.opened then return end

    -- Must be in the house routing bucket
    if GetPlayerRoutingBucket(src) ~= (h.routingBucket or 0) then return end

    HouseRob.searchBusy[src] = true

    -- Mark searched first to prevent double-claim races
    h.furniture[cabin].searched = true
    h.furniture[cabin].isBusy = false
    TriggerClientEvent('cfx-cs-robbery:houserob:client:setCabinState', -1, house, cabin, true)
    TriggerClientEvent('cfx-cs-robbery:houserob:client:SetBusyState', -1, cabin, house, false)

    local rewards = Config.HouseRob.Rewards
    if not rewards then
        HouseRob.searchBusy[src] = nil
        return
    end

    local giveDirty = not h.rewardClaimed
    if giveDirty then
        local dirty = rewards.dirtyMoney
        if dirty and dirty.item and dirty.amount and dirty.amount > 0 then
            ox_inventory:AddItem(src, dirty.item, dirty.amount)
            local dirtyLabel = (ox_items[dirty.item] and ox_items[dirty.item].label) or dirty.item
            lib.logger(src, 'robbery_houserob', xPlayer.name .. ' received ' .. dirty.amount .. 'x ' .. dirtyLabel .. ' from house robbery [' .. house .. ']')
        end
        h.rewardClaimed = true
    end

    local recycling = rewards.recycling
    local recAmount = 0
    if recycling and recycling.item and recycling.min and recycling.max then
        recAmount = math.random(recycling.min, recycling.max)
        ox_inventory:AddItem(src, recycling.item, recAmount)
        local recLabel = (ox_items[recycling.item] and ox_items[recycling.item].label) or recycling.item
        lib.logger(src, 'robbery_houserob', xPlayer.name .. ' received ' .. recAmount .. 'x ' .. recLabel .. ' from house robbery [' .. house .. ']')
    end

    if giveDirty then
        TriggerClientEvent('esx:Notify', src, 'House Robbery', ('Found $%s dirty money and %sx recycling materials.'):format(
            rewards.dirtyMoney and rewards.dirtyMoney.amount or 0,
            recAmount
        ), 'success', 6000)
    else
        TriggerClientEvent('esx:Notify', src, 'House Robbery', ('Found %sx recycling materials.'):format(recAmount), 'success', 5000)
    end

    HouseRob.searchBusy[src] = nil
end)

--- Exit / bucket reset — only 0 or this house's bucket
RegisterNetEvent('cfx-cs-robbery:houserob:setRoutingBucket', function(bucket)
    local src = source
    bucket = tonumber(bucket)
    if bucket == nil then return end

    if bucket == 0 then
        clearInside(src)
        SetPlayerRoutingBucket(src, 0)
        return
    end

    -- Only allow the routing bucket of a house the player is allowed to be in
    local house = HouseRob.inside[src]
    local h = house and getHouse(house) or nil
    if h and tonumber(h.routingBucket) == bucket then
        SetPlayerRoutingBucket(src, bucket)
        return
    end

    -- Reject arbitrary bucket hopping
end)

RegisterNetEvent('cfx-cs-robbery:houserob:server:leaveHouse', function(house)
    local src = source
    if house and HouseRob.inside[src] == house then
        clearInside(src)
    elseif not house then
        clearInside(src)
    end
    SetPlayerRoutingBucket(src, 0)
end)

RegisterNetEvent('cfx-cs-robbery:houserob:server:soundAlert', function(house)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local h = getHouse(house)
    if not xPlayer or not h then return end
    if HouseRob.inside[src] ~= house then return end

    local now = GetGameTimer()
    if HouseRob.soundAlertAt[src] and (now - HouseRob.soundAlertAt[src]) < 30000 then
        return
    end
    HouseRob.soundAlertAt[src] = now

    local chance = Config.HouseRob.ChanceToAlertPolice or 100
    if math.random(1, 100) > chance then return end

    local coords = h.coords
    local soundCfg = Config.HouseRob.SoundDetection or {}
    local jobs = soundCfg.alertJobs or { 'police' }
    local houseKey = type(house) == 'string' and house:lower() or ''
    local y = coords and (coords.y or coords['y'])
    local sheriffMinY = tonumber(soundCfg.sheriffMinY) or 2500.0
    if houseKey:find('paleto', 1, true) or (type(y) == 'number' and y >= sheriffMinY) then
        jobs = soundCfg.sheriffJobs or { 'sheriff' }
    end
    local msg = ('House robbery in progress — neighbors reported loud noise near %.0f, %.0f'):format(coords.x, coords.y)

    if ESX.SendDispatch then
        ESX.SendDispatch(jobs, msg, 12000)
    else
        for i = 1, #jobs do
            local players = ESX.GetExtendedPlayers('job', jobs[i])
            for j = 1, #players do
                TriggerClientEvent('esx:Notify', players[j].source, 'Dispatch', msg, 'police', 12000)
            end
        end
    end

    lib.logger(src, 'robbery_houserob', xPlayer.name .. ' [' .. src .. '] triggered sound alert at house ' .. house)
end)

AddEventHandler('playerDropped', function()
    local src = source
    clearInside(src)
    HouseRob.lockpickBusy[src] = nil
    HouseRob.searchBusy[src] = nil
    HouseRob.soundAlertAt[src] = nil
end)
