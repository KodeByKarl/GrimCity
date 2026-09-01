ESX = ESX or exports["es_extended"]:getSharedObject()

local activeChops = {} -- [src] = session
local plateLocks = {} -- [plate] = src
local cooldowns = {} -- [src] = unix

local function Notify(src, msg, nType)
    TriggerClientEvent("ox_lib:notify", src, {
        title = "Chop Shop",
        description = msg,
        type = nType or "inform",
    })
end

local function NormalizePlate(plate)
    if not plate or plate == "" then return "" end
    return (string.gsub(tostring(plate), "%s+", "")):upper()
end

local function IsBlockedPlate(plate)
    local blocked = Config.ChopShop.BlockedPlates
    return blocked and blocked[plate] == true
end

local function InChopZone(coords)
    local radius = (Config.ChopShop.ZoneRadius or 22.0) + 4.0
    for i = 1, #Config.ChopShop.Locations do
        if #(coords - Config.ChopShop.Locations[i].coords) <= radius then
            return true
        end
    end
    return false
end

local function SessionElapsed(session)
    if not session then return false end
    local startAt = tonumber(session.startAt)
    local durationMs = tonumber(session.durationMs)
    if not startAt or not durationMs then return false end
    return (GetGameTimer() - startAt) >= math.max(0, durationMs - 400)
end

local function RollRewards()
    local rewards = {}
    local list = Config.ChopShop.Rewards
    for i = 1, #list do
        local entry = list[i]
        if math.random(100) <= (entry.chance or 100) then
            local minAmt = entry.min or 1
            local maxAmt = entry.max or minAmt
            if maxAmt < minAmt then maxAmt = minAmt end
            rewards[#rewards + 1] = {
                item = entry.item,
                count = math.random(minAmt, maxAmt),
            }
        end
    end
    return rewards
end

local function AddItem(src, item, amount)
    if GetResourceState("ox_inventory") ~= "started" then return false end
    local ok, res = pcall(function()
        return exports.ox_inventory:AddItem(src, item, amount)
    end)
    return ok and res
end

local function LookupOwnedVehicle(plate)
    local ok, row = pcall(function()
        return MySQL.single.await([[
            SELECT owner, plate, job_vehicle
            FROM owned_vehicles
            WHERE UPPER(REPLACE(TRIM(plate), ' ', '')) = ?
            LIMIT 1
        ]], { plate })
    end)
    if ok then return row end

    return MySQL.single.await([[
        SELECT owner, plate
        FROM owned_vehicles
        WHERE UPPER(REPLACE(TRIM(plate), ' ', '')) = ?
        LIMIT 1
    ]], { plate })
end

local function DeleteOwnedVehicle(dbPlate)
    MySQL.update.await("DELETE FROM owned_vehicles WHERE plate = ?", { dbPlate })
end

local function ClearVehicleInventories(plate)
    if GetResourceState("ox_inventory") ~= "started" then return end

    local variants = {
        plate,
        NormalizePlate(plate),
    }

    for i = 1, #variants do
        local p = variants[i]
        if p and p ~= "" then
            pcall(function()
                exports.ox_inventory:RemoveInventory("trunk" .. p)
            end)
            pcall(function()
                exports.ox_inventory:RemoveInventory("glove" .. p)
            end)
        end
    end
end

local function DeleteWorldVehicle(netId)
    netId = tonumber(netId)
    if not netId then return end

    TriggerClientEvent("cfx-keydi-chopshop:client:deleteVehicle", -1, netId)

    local entity = NetworkGetEntityFromNetworkId(netId)
    if entity and entity ~= 0 and DoesEntityExist(entity) then
        if GetResourceState("AdvancedParking") == "started" then
            pcall(function()
                exports.AdvancedParking:DeleteVehicle(entity, false)
            end)
        end
        DeleteEntity(entity)
    end
end

local function ClearSession(src, unlockClient)
    local session = activeChops[src]
    if session and session.plate then
        if plateLocks[session.plate] == src then
            plateLocks[session.plate] = nil
        end
    end
    activeChops[src] = nil
    if unlockClient then
        TriggerClientEvent("cfx-keydi-chopshop:client:unlock", src)
    end
end

local function GetSpeed(entity)
    local vel = GetEntityVelocity(entity)
    if not vel then return 0.0 end
    return math.sqrt((vel.x * vel.x) + (vel.y * vel.y) + (vel.z * vel.z))
end

local function VehicleOccupiedByOther(entity, src)
    local players = GetPlayers()
    for i = 1, #players do
        local id = tonumber(players[i])
        if id and id ~= src then
            local otherPed = GetPlayerPed(id)
            if otherPed and otherPed ~= 0 and GetVehiclePedIsIn(otherPed, false) == entity then
                return true
            end
        end
    end
    return false
end

local function ReadPlate(entity)
    local ok, plate = pcall(GetVehicleNumberPlateText, entity)
    if ok and type(plate) == "string" then
        return NormalizePlate(plate)
    end
    return ""
end

local function ValidateChopVehicle(src, netId, clientPlate, vehicleClass)
    netId = tonumber(netId)
    if not netId then return nil, "denied" end

    local entity = NetworkGetEntityFromNetworkId(netId)
    if not entity or entity == 0 or not DoesEntityExist(entity) then
        return nil, "denied"
    end

    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return nil, "denied" end

    local pCoords = GetEntityCoords(ped)
    local vCoords = GetEntityCoords(entity)
    if not InChopZone(pCoords) or not InChopZone(vCoords) then
        return nil, "zone"
    end

    if #(pCoords - vCoords) > ((Config.ChopShop.InteractionDistance or 3.2) + 4.0) then
        return nil, "zone"
    end

    if GetSpeed(entity) > ((Config.ChopShop.MaxVehicleSpeed or 1.2) + 1.0) then
        return nil, "speed"
    end

    vehicleClass = tonumber(vehicleClass)
    if vehicleClass and not Config.ChopShop.AllowedClasses[vehicleClass] then
        return nil, "class"
    end

    if VehicleOccupiedByOther(entity, src) then
        return nil, "occupied"
    end

    local plate = ReadPlate(entity)
    if plate == "" then
        plate = NormalizePlate(clientPlate)
    end

    local sent = NormalizePlate(clientPlate)
    if plate == "" or (sent ~= "" and sent ~= plate) then
        return nil, "denied"
    end

    if IsBlockedPlate(plate) then
        return nil, "blocked"
    end

    return {
        entity = entity,
        netId = netId,
        plate = plate,
        coords = vCoords,
    }, nil
end

lib.callback.register("cfx-keydi-chopshop:server:request", function(src, netId, clientPlate, vehicleClass)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return { ok = false, reason = "denied" } end

    if activeChops[src] then
        return { ok = false, reason = "busy" }
    end

    local now = os.time()
    if cooldowns[src] and now < cooldowns[src] then
        return { ok = false, reason = "cooldown" }
    end

    local veh, reason = ValidateChopVehicle(src, netId, clientPlate, vehicleClass)
    if not veh then
        return { ok = false, reason = reason or "denied" }
    end

    if plateLocks[veh.plate] then
        return { ok = false, reason = "in_use" }
    end

    -- Must exist in owned_vehicles BEFORE any progress bar.
    local row = LookupOwnedVehicle(veh.plate)
    if not row or not row.owner then
        return { ok = false, reason = "not_owned" }
    end

    if Config.ChopShop.BlockJobVehicles then
        local jobFlag = tonumber(row.job_vehicle) or 0
        if jobFlag == 1 then
            return { ok = false, reason = "job" }
        end
    end

    local duration = Config.ChopShop.ProgressDuration or 12000
    local rewards = RollRewards()

    plateLocks[veh.plate] = src
    activeChops[src] = {
        plate = veh.plate,
        dbPlate = row.plate,
        owner = row.owner,
        netId = veh.netId,
        vehicleClass = tonumber(vehicleClass),
        startAt = GetGameTimer(),
        durationMs = duration,
        rewards = rewards,
        isOwner = row.owner == xPlayer.identifier,
    }

    return {
        ok = true,
        duration = duration,
        isOwner = row.owner == xPlayer.identifier,
    }
end)

RegisterNetEvent("cfx-keydi-chopshop:server:complete", function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local session = activeChops[src]
    if not session then
        KeydiElectron.Flag(src, "Chop shop exploit (no session)", "cfx-keydi-chopshop")
        return
    end

    if not SessionElapsed(session) then
        ClearSession(src, true)
        KeydiElectron.Flag(src, "Chop shop exploit (skipped wait)", "cfx-keydi-chopshop")
        return
    end

    local veh, reason = ValidateChopVehicle(src, session.netId, session.plate, session.vehicleClass)
    if not veh then
        ClearSession(src, true)
        Notify(src, "Chop failed — vehicle left the yard.", "error")
        return
    end

    if veh.plate ~= session.plate then
        ClearSession(src, true)
        KeydiElectron.Flag(src, "Chop shop exploit (plate mismatch)", "cfx-keydi-chopshop")
        return
    end

    -- Re-check DB so a spawn car cannot sneak through after the request.
    local row = LookupOwnedVehicle(session.plate)
    if not row or not row.owner then
        ClearSession(src, true)
        Notify(src, "Spawn / test cars cannot be chopped.", "error")
        return
    end

    local dbPlate = row.plate or session.dbPlate
    DeleteOwnedVehicle(dbPlate)
    ClearVehicleInventories(dbPlate)
    ClearVehicleInventories(session.plate)
    DeleteWorldVehicle(session.netId)

    local given = {}
    local rewards = session.rewards or {}
    for i = 1, #rewards do
        local reward = rewards[i]
        if reward.item and reward.count and reward.count > 0 then
            if AddItem(src, reward.item, reward.count) then
                given[#given + 1] = ("%sx %s"):format(reward.count, reward.item)
            end
        end
    end

    local cooldownMs = Config.ChopShop.Cooldown or 20000
    cooldowns[src] = os.time() + math.floor(cooldownMs / 1000)
    ClearSession(src, false)

    if #given > 0 then
        Notify(src, ("Vehicle chopped. You got: %s"):format(table.concat(given, ", ")), "success")
    else
        Notify(src, "Vehicle chopped. Inventory was full — parts were lost.", "error")
    end

    if not session.isOwner and session.owner then
        local xOwner = ESX.GetPlayerFromIdentifier(session.owner)
        if xOwner then
            Notify(xOwner.source, ("Your vehicle %s was chopped up."):format(session.plate), "error")
        end
    end
end)

RegisterNetEvent("cfx-keydi-chopshop:server:cancel", function()
    local src = source
    if type(src) ~= "number" or src < 1 then return end
    ClearSession(src, false)
end)

AddEventHandler("playerDropped", function()
    ClearSession(source, false)
end)
