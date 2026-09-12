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

local function CanUseHouseRob(src)
    if isPlayerPolice(src) then
        return true
    end
    if GetResourceState('kodebykarl-ui') ~= 'started' then
        return true
    end
    local ok, allowed = pcall(function()
        local exp = exports['kodebykarl-ui']
        return exp:PlayerHasFunction(src, 'illegal')
            or exp:PlayerHasFunction(src, 'houserob')
            or exp:PlayerHasFunction(src, 'housing')
            or exp:PlayerHasFunction(src, 'main')
    end)
    if not ok then
        return true
    end
    return allowed == true
end

local function NotifyWrongHouseRegion(src)
    local msg = 'House robbery is only available on Region 1. Open Control Center (F5) → Regions.'
    if GetResourceState('kodebykarl-ui') == 'started' then
        local ok, text = pcall(function()
            return exports['kodebykarl-ui']:WrongServerMessage('illegal')
        end)
        if ok and type(text) == 'string' and text ~= '' then
            msg = text
        end
    end
    TriggerClientEvent('esx:Notify', src, 'House Robbery', msg, 'error', 5000)
end

local function setInside(src, house)
    HouseRob.inside[src] = house
end

local function clearInside(src)
    HouseRob.inside[src] = nil
end

exports('IsInsideHouse', function(src)
    src = tonumber(src)
    return src ~= nil and HouseRob.inside[src] ~= nil
end)

local function readableHouseArea(house)
    local key = tostring(house or '')
    local area = key:gsub('%d+$', ''):gsub('_', ' ')
    if area == '' then return 'Unknown area' end
    return area:sub(1, 1):upper() .. area:sub(2)
end

local function sanitizeStreet(label)
    if type(label) ~= 'string' then return nil end
    local s = label:gsub('^%s+', ''):gsub('%s+$', '')
    if s == '' then return nil end
    return s:sub(1, 120)
end

local function houseAlertJobs(house, coords)
    local soundCfg = Config.HouseRob.SoundDetection or {}
    local jobs = soundCfg.alertJobs or { 'police' }
    local houseKey = type(house) == 'string' and house:lower() or ''
    local y = coords and (coords.y or coords['y'])
    local sheriffMinY = tonumber(soundCfg.sheriffMinY) or 2500.0
    if houseKey:find('paleto', 1, true) or (type(y) == 'number' and y >= sheriffMinY) then
        jobs = soundCfg.sheriffJobs or { 'sheriff' }
    end
    return jobs
end

local function resolveProjectModel()
    if GetResourceState('kodebykarl-projectcars') == 'started' then
        local ok, model = pcall(function()
            return exports['kodebykarl-projectcars']:PickRandomProjectModel()
        end)
        if ok and type(model) == 'string' and model ~= '' then
            return model
        end
    end
    return 'ody18'
end

local function buildProjectMetadata(itemName, model)
    model = tostring(model or ''):lower():gsub('%s+', '')
    if model == '' then
        model = resolveProjectModel()
    end
    if GetResourceState('kodebykarl-projectcars') == 'started' then
        local ok, meta = pcall(function()
            return exports['kodebykarl-projectcars']:BuildPartMetadata(itemName, model)
        end)
        if ok and type(meta) == 'table' then
            return meta, model
        end
    end
    return {
        model = model,
        vehicle = model:upper(),
        label = itemName,
        description = ('Fits %s project cars only.'):format(model:upper()),
    }, model
end

local function giveTaggedProjectItem(src, itemName, count, model)
    count = math.floor(tonumber(count) or 1)
    if count < 1 or not itemName then return false, nil, itemName end
    model = model or resolveProjectModel()
    local resolved = itemName
    if GetResourceState('kodebykarl-projectcars') == 'started' then
        local okResolve, uniqueName = pcall(function()
            return exports['kodebykarl-projectcars']:ResolvePartItem(itemName, model)
        end)
        if okResolve and type(uniqueName) == 'string' and uniqueName ~= '' then
            resolved = uniqueName
        end
        local ok, given = pcall(function()
            return exports['kodebykarl-projectcars']:GivePart(src, itemName, count, model)
        end)
        if ok and given then
            return true, model, resolved
        end
    end
    local meta = buildProjectMetadata(resolved, model)
    return ox_inventory:AddItem(src, resolved, count, meta) and true or false, model, resolved
end

local function shuffleCopy(list)
    local copy = {}
    for i = 1, #list do
        copy[i] = list[i]
    end
    for i = #copy, 2, -1 do
        local j = math.random(i)
        copy[i], copy[j] = copy[j], copy[i]
    end
    return copy
end

local function itemLabel(itemName)
    return (ox_items[itemName] and ox_items[itemName].label) or itemName
end

local function alertHouseRobbery(src, house, reason, streetLabel)
    local h = getHouse(house)
    if not h or not h.coords then return end

    local chance = Config.HouseRob.ChanceToAlertPolice or 100
    if math.random(1, 100) > chance then return end

    local now = GetGameTimer()
    local cooldownKey = tostring(src) .. ':' .. tostring(house) .. ':' .. tostring(reason or 'noise')
    if HouseRob.soundAlertAt[cooldownKey] and (now - HouseRob.soundAlertAt[cooldownKey]) < 30000 then
        return
    end
    HouseRob.soundAlertAt[cooldownKey] = now

    local coords = h.coords
    local jobs = houseAlertJobs(house, coords)
    local street = sanitizeStreet(streetLabel)
    local area = readableHouseArea(house)
    local location = street or area
    local msg
    if reason == 'break-in' then
        msg = ('10-90 House burglary in progress at %s'):format(location)
    elseif reason == 'gunfire' then
        msg = ('10-71 Shots fired during a house burglary at %s'):format(location)
    else
        msg = ('10-90 House burglary — neighbors reported noise at %s'):format(location)
    end

    if ESX.SendDispatch then
        ESX.SendDispatch(jobs, msg, 14000)
    end

    for i = 1, #jobs do
        local players = ESX.GetExtendedPlayers('job', jobs[i])
        for j = 1, #players do
            local leoSrc = players[j].source
            if leoSrc ~= src then
                TriggerClientEvent('cfx-cs-robbery:houserob:client:policeAlert', leoSrc, {
                    coords = { x = coords.x, y = coords.y, z = coords.z },
                    label = 'House Robbery — ' .. location,
                    message = msg,
                    sprite = 411,
                    color = 1,
                    scale = 1.1,
                    radius = 55.0,
                    time = 180000,
                    notifyDuration = 14000,
                })
            end
        end
    end
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
    if not CanUseHouseRob(src) then
        return NotifyWrongHouseRegion(src)
    end
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

RegisterNetEvent('cfx-cs-robbery:houserob:server:finishLockpick', function(house, success, usingAdvanced, streetLabel)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local h = getHouse(house)
    if not xPlayer or not h then return end
    if not CanUseHouseRob(src) then
        HouseRob.lockpickBusy[src] = nil
        return NotifyWrongHouseRegion(src)
    end
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

    alertHouseRobbery(src, house, 'break-in', streetLabel)

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

    local foundBits = {}
    local givePackage = not h.rewardClaimed
    if givePackage then
        local dirty = rewards.dirtyMoney
        if dirty and dirty.item and dirty.amount and dirty.amount > 0 then
            ox_inventory:AddItem(src, dirty.item, dirty.amount)
            foundBits[#foundBits + 1] = ('$%s dirty money'):format(dirty.amount)
            lib.logger(src, 'robbery_houserob', xPlayer.name .. ' received ' .. dirty.amount .. 'x ' .. itemLabel(dirty.item) .. ' from house robbery [' .. house .. ']')
        end

        local bp = rewards.blueprints
        if bp and bp.item then
            local bpMin = math.floor(tonumber(bp.min) or 5)
            local bpMax = math.floor(tonumber(bp.max) or 10)
            if bpMax < bpMin then bpMax = bpMin end
            local bpCount = math.random(bpMin, bpMax)
            local bpModel = resolveProjectModel()
            local given = giveTaggedProjectItem(src, bp.item, bpCount, bpModel)
            if given then
                foundBits[#foundBits + 1] = ('%sx %s (%s)'):format(bpCount, itemLabel(bp.item), tostring(bpModel):upper())
                lib.logger(src, 'robbery_houserob', xPlayer.name .. ' received ' .. bpCount .. 'x ' .. itemLabel(bp.item) .. ' [' .. tostring(bpModel) .. '] from house robbery [' .. house .. ']')
            end
        end

        local parts = rewards.projectParts
        local pool = parts and parts.pool
        if type(pool) == 'table' and #pool > 0 then
            local rollsCfg = parts.rolls or {}
            local rollMin = math.max(1, math.floor(tonumber(rollsCfg.min) or 1))
            local rollMax = math.max(rollMin, math.floor(tonumber(rollsCfg.max) or rollMin))
            local rolls = math.min(#pool, math.random(rollMin, rollMax))
            local shuffled = shuffleCopy(pool)
            for i = 1, rolls do
                local entry = shuffled[i]
                if entry and entry.item then
                    local pMin = math.floor(tonumber(entry.min) or 1)
                    local pMax = math.floor(tonumber(entry.max) or pMin)
                    if pMax < pMin then pMax = pMin end
                    local pCount = math.random(pMin, pMax)
                    local partModel = resolveProjectModel()
                    local given, givenModel, givenItem = giveTaggedProjectItem(src, entry.item, pCount, partModel)
                    if given then
                        foundBits[#foundBits + 1] = ('%sx %s'):format(pCount, itemLabel(givenItem or entry.item))
                        lib.logger(src, 'robbery_houserob', xPlayer.name .. ' received ' .. pCount .. 'x ' .. itemLabel(givenItem or entry.item) .. ' [' .. tostring(givenModel or partModel) .. '] from house robbery [' .. house .. ']')
                    end
                end
            end
        end

        local recycling = rewards.recycling
        if recycling and recycling.item and recycling.min and recycling.max then
            local recMin = math.floor(tonumber(recycling.min) or 1)
            local recMax = math.floor(tonumber(recycling.max) or recMin)
            if recMax < recMin then recMax = recMin end
            local recAmount = math.random(recMin, recMax)
            if recAmount > 0 then
                ox_inventory:AddItem(src, recycling.item, recAmount)
                foundBits[#foundBits + 1] = ('%sx recycling materials'):format(recAmount)
                lib.logger(src, 'robbery_houserob', xPlayer.name .. ' received ' .. recAmount .. 'x ' .. itemLabel(recycling.item) .. ' from house robbery [' .. house .. ']')
            end
        end

        h.rewardClaimed = true
    end

    local summary = #foundBits > 0 and table.concat(foundBits, ', ') or 'nothing'
    TriggerClientEvent('esx:Notify', src, 'House Robbery', ('Found %s.'):format(summary), 'success', givePackage and 7000 or 5000)

    HouseRob.searchBusy[src] = nil
end)

--- Exit / bucket reset — only 0 or this house's bucket
RegisterNetEvent('cfx-cs-robbery:houserob:setRoutingBucket', function(bucket)
    local src = source
    bucket = tonumber(bucket)
    if bucket == nil then return end

    if bucket == 0 then
        clearInside(src)
        if GetResourceState('kodebykarl-ui') == 'started' then
            local restored = false
            pcall(function()
                restored = exports['kodebykarl-ui']:RestorePlayerBucket(src, { force = true }) == true
            end)
            if not restored then
                SetPlayerRoutingBucket(src, 0)
            end
        else
            SetPlayerRoutingBucket(src, 0)
        end
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
    if GetResourceState('kodebykarl-ui') == 'started' then
        local restored = false
        pcall(function()
            restored = exports['kodebykarl-ui']:RestorePlayerBucket(src, { force = true }) == true
        end)
        if not restored then
            SetPlayerRoutingBucket(src, 0)
        end
    else
        SetPlayerRoutingBucket(src, 0)
    end
end)

RegisterNetEvent('cfx-cs-robbery:houserob:server:soundAlert', function(house, streetLabel, reason)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local h = getHouse(house)
    if not xPlayer or not h then return end
    if HouseRob.inside[src] ~= house then return end

    local kind = reason == 'gunfire' and 'gunfire' or 'noise'
    alertHouseRobbery(src, house, kind, streetLabel)

    lib.logger(src, 'robbery_houserob', xPlayer.name .. ' [' .. src .. '] triggered sound alert at house ' .. house)
end)

AddEventHandler('playerDropped', function()
    local src = source
    clearInside(src)
    HouseRob.lockpickBusy[src] = nil
    HouseRob.searchBusy[src] = nil
    HouseRob.soundAlertAt[src] = nil
end)
