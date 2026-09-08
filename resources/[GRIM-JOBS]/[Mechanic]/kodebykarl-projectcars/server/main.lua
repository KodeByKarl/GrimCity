local Projects = {}

local function Notify(src, msg, nType)
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Project Cars',
        description = msg,
        type = nType or 'inform',
    })
end

local function NormalizePlate(plate)
    if not plate then return '' end
    return (string.gsub(tostring(plate), '%s+', '')):upper()
end

local function IsAdmin(xPlayer)
    if not xPlayer then return false end
    if xPlayer.admin then return true end
    local group = xPlayer.getGroup and xPlayer.getGroup() or 'user'
    return Config.AdminGroups[group] == true
end

local function CountOwnerProjects(identifier)
    local n = 0
    for _, data in pairs(Projects) do
        if data.owner == identifier then
            n = n + 1
        end
    end
    return n
end

local function InBuildZone(coords)
    if not Config.EnableZoneOnly then return true end
    for i = 1, #Config.BuildZones do
        local zone = Config.BuildZones[i]
        if #(coords - zone.coords) <= (zone.radius or 50.0) then
            return true
        end
    end
    return false
end

local function GeneratePlate()
    if GetResourceState('jg-dealerships-v2') == 'started' then
        local ok, plate = pcall(function()
            return exports['jg-dealerships-v2']:generatePlate(nil, true)
        end)
        if ok and type(plate) == 'string' and plate ~= '' then
            return NormalizePlate(plate)
        end
    end

    for _ = 1, 20 do
        local plate = ('PC%06d'):format(math.random(0, 999999))
        local exists = MySQL.scalar.await('SELECT plate FROM owned_vehicles WHERE plate = ? LIMIT 1', { plate })
        local project = Projects[plate]
        if not exists and not project then
            return plate
        end
    end
    return nil
end

local function Payload(data)
    return {
        plate = data.plate,
        owner = data.owner,
        model = data.model,
        x = data.x,
        y = data.y,
        z = data.z,
        w = data.w,
        status = data.status,
    }
end

local function AllPayloads()
    local list = {}
    for plate, data in pairs(Projects) do
        list[plate] = Payload(data)
    end
    return list
end

local function DefaultStatus()
    return {
        doors = { ['0'] = true, ['1'] = true, ['2'] = true, ['3'] = true },
        hood = true,
        trunk = true,
        wheels = { ['0'] = true, ['1'] = true, ['2'] = true, ['3'] = true },
        brakes = { ['0'] = true, ['1'] = true, ['2'] = true, ['3'] = true },
        engine = true,
        battery = true,
        alternator = true,
        radiator = true,
        sparkplugs = true,
        transmission = true,
    }
end

local function StatusReady(bucket, index)
    if type(bucket) ~= 'table' or index == nil then return false end
    return bucket[tostring(index)] == true
end

local function SanitizeStatus(incoming)
    local status = {
        doors = {},
        hood = false,
        trunk = false,
        wheels = {},
        brakes = {},
        engine = true,
        battery = true,
        alternator = true,
        radiator = true,
        sparkplugs = true,
        transmission = true,
    }

    if type(incoming) ~= 'table' then
        return DefaultStatus()
    end

    if incoming.hood == true then status.hood = true end
    if incoming.trunk == true then status.trunk = true end

    if type(incoming.doors) == 'table' then
        for i = 0, 3 do
            if incoming.doors[tostring(i)] or incoming.doors[i] then
                status.doors[tostring(i)] = true
            end
        end
    else
        status.doors = DefaultStatus().doors
    end

    if type(incoming.wheels) == 'table' then
        for i = 0, 3 do
            if incoming.wheels[tostring(i)] or incoming.wheels[i] then
                status.wheels[tostring(i)] = true
            end
        end
    else
        status.wheels = DefaultStatus().wheels
    end

    if type(incoming.brakes) == 'table' then
        for i = 0, 3 do
            if incoming.brakes[tostring(i)] or incoming.brakes[i] then
                status.brakes[tostring(i)] = true
            end
        end
    else
        status.brakes = DefaultStatus().brakes
    end

    return status
end

local function MergeStatus(status)
    local defaults = DefaultStatus()
    if type(status) ~= 'table' then return defaults end
    for key, value in pairs(defaults) do
        if type(value) ~= 'table' and status[key] == nil then
            status[key] = value
        end
    end
    return status
end

local function IsComplete(status)
    if not status then return false end
    local required = { 'battery', 'alternator', 'radiator', 'engine', 'sparkplugs', 'transmission', 'hood' }
    for i = 1, #required do
        if status[required[i]] then return false end
    end
    for _, missing in pairs(status.doors or {}) do
        if missing then return false end
    end
    for _, missing in pairs(status.wheels or {}) do
        if missing then return false end
    end
    for _, missing in pairs(status.brakes or {}) do
        if missing then return false end
    end
    return true
end

local function SaveProject(data)
    MySQL.update.await([[
        INSERT INTO kodebykarl_projectcars (`plate`, `owner`, `model`, `coord`, `status`)
        VALUES (?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE `coord` = VALUES(`coord`), `status` = VALUES(`status`)
    ]], {
        data.plate,
        data.owner,
        data.model,
        json.encode({ x = data.x, y = data.y, z = data.z, w = data.w }),
        json.encode(data.status),
    })
end

local function DeleteProject(plate)
    Projects[plate] = nil
    MySQL.update.await('DELETE FROM kodebykarl_projectcars WHERE plate = ?', { plate })
    TriggerClientEvent('kodebykarl-projectcars:client:update', -1, plate, nil)
end

local function Broadcast(data)
    TriggerClientEvent('kodebykarl-projectcars:client:update', -1, data.plate, Payload(data))
end

local function HasItem(src, item, count, metadata)
    count = count or 1
    if GetResourceState('ox_inventory') ~= 'started' then return false end
    local n = exports.ox_inventory:GetItemCount(src, item, metadata, metadata ~= nil)
    return n and n >= count
end

local function RemoveItem(src, item, count, metadata)
    count = count or 1
    return exports.ox_inventory:RemoveItem(src, item, count, metadata)
end

local function PartMeta(itemName, model)
    if type(BuildProjectPartMetadata) == 'function' then
        return BuildProjectPartMetadata(itemName, model)
    end
    return { model = tostring(model or Config.DefaultModel):lower() }
end

local function GetShellFromSlot(src, slot, model)
    local invItem = exports.ox_inventory:GetSlot(src, slot)
    if not invItem or invItem.name ~= 'vehicle_shell' then
        -- fallback search
        local items = exports.ox_inventory:Search(src, 'slots', 'vehicle_shell')
        if type(items) == 'table' then
            for _, entry in pairs(items) do
                local metaModel = entry.metadata and entry.metadata.model
                if not model or not metaModel or metaModel == model then
                    return entry
                end
            end
        end
        return nil
    end
    return invItem
end

local function InsertOwnedVehicle(identifier, model, plate, props)
    local garageId = Config.GarageId or 'Legion Square'
    local encoded = json.encode(props)
    local fuel = Config.FinishFuel or 100
    local ok = pcall(function()
        MySQL.insert.await([[
            INSERT INTO owned_vehicles
                (`owner`, `plate`, `vehicle`, `stored`, `in_garage`, `garage_id`, `fuel`, `engine`, `body`, `type`)
            VALUES (?, ?, ?, 1, 1, ?, ?, 1000, 1000, 'car')
        ]], { identifier, plate, encoded, garageId, fuel })
    end)
    if not ok then
        MySQL.insert.await(
            'INSERT INTO owned_vehicles (`owner`, `plate`, `vehicle`, `stored`, `type`) VALUES (?, ?, ?, 1, ?)',
            { identifier, plate, encoded, 'car' }
        )
    end
end

local function FinishProject(src, data)
    local plate = data.plate
    local garageId = Config.GarageId or 'Legion Square'
    local props = {
        model = joaat(data.model),
        plate = plate,
        fuelLevel = Config.FinishFuel or 100,
        engineHealth = 1000.0,
        bodyHealth = 1000.0,
        tankHealth = 1000.0,
        dirtLevel = 0.0,
        windowsBroken = { false, false, false, false, false, false, false, false },
        doorsBroken = { false, false, false, false, false, false },
        tyreBurst = { false, false, false, false, false, false, false },
    }

    InsertOwnedVehicle(data.owner, data.model, plate, props)
    DeleteProject(plate)

    pcall(function()
        exports['kodebykarl-ui']:GiveKey(src, plate)
    end)

    TriggerClientEvent('kodebykarl-projectcars:client:finish', src, {
        plate = plate,
        garage = garageId,
    })
end

local function MissingRequires(status, requires, index, requiresIndex)
    if requires then
        for i = 1, #requires do
            local key = requires[i]
            if status[key] then
                local cfg = Config.Parts[key]
                return ('Install the %s first.'):format(cfg and cfg.label or key)
            end
        end
    end
    if requiresIndex and index ~= nil then
        local bucket = status[requiresIndex .. 's'] or status[requiresIndex]
        if type(bucket) == 'table' and bucket[tostring(index)] then
            local cfg = Config.Parts[requiresIndex]
            return ('Install the %s first.'):format(cfg and cfg.label or requiresIndex)
        end
    end
    return nil
end

CreateThread(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `kodebykarl_projectcars` (
            `plate` varchar(12) NOT NULL,
            `owner` varchar(60) NOT NULL,
            `model` varchar(50) NOT NULL,
            `coord` longtext NOT NULL,
            `status` longtext NOT NULL,
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`plate`),
            KEY `owner` (`owner`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    local rows = MySQL.query.await('SELECT * FROM kodebykarl_projectcars', {}) or {}
    for i = 1, #rows do
        local row = rows[i]
        local coord = json.decode(row.coord or '{}') or {}
        local plate = NormalizePlate(row.plate)
        Projects[plate] = {
            plate = plate,
            owner = row.owner,
            model = row.model,
            x = coord.x or 0.0,
            y = coord.y or 0.0,
            z = coord.z or 0.0,
            w = coord.w or 0.0,
            status = MergeStatus(json.decode(row.status or '{}') or {}),
        }
    end
end)

RegisterNetEvent('kodebykarl-projectcars:server:requestSync', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    TriggerClientEvent('kodebykarl-projectcars:client:sync', src, AllPayloads(), xPlayer and xPlayer.identifier or nil)
end)

lib.callback.register('kodebykarl-projectcars:server:placeShell', function(src, payload)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return { ok = false, reason = 'Not loaded.' } end
    if type(payload) ~= 'table' then return { ok = false, reason = 'Invalid request.' } end

    local model = tostring(payload.model or Config.DefaultModel):lower():gsub('%s+', '')
    if model == '' then return { ok = false, reason = 'Missing vehicle model.' } end

    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return { ok = false, reason = 'Invalid player.' } end
    local pCoords = GetEntityCoords(ped)
    local dest = vector3(payload.x or 0.0, payload.y or 0.0, payload.z or 0.0)
    if #(pCoords - dest) > 12.0 then
        return { ok = false, reason = 'Too far from the shell.' }
    end
    if not InBuildZone(dest) then
        return { ok = false, reason = 'You can only build in a project-car yard.' }
    end

    if CountOwnerProjects(xPlayer.identifier) >= (Config.MaxProjects or 1) then
        return { ok = false, reason = 'You already have a project car out.' }
    end

    local shell = GetShellFromSlot(src, payload.slot, model)
    if not shell then
        return { ok = false, reason = 'You do not have a vehicle shell.' }
    end

    local blueprintItem = Config.BlueprintItem or 'car_blueprint'
    local blueprintNeed = math.floor(tonumber(Config.BlueprintAmount) or 25)
    local blueprintMeta = PartMeta(blueprintItem, model)
    if blueprintNeed > 0 then
        local have = exports.ox_inventory:GetItemCount(src, blueprintItem, { model = model }, true) or 0
        if have < blueprintNeed then
            return {
                ok = false,
                reason = ('Need %sx %s for %s.'):format(
                    blueprintNeed,
                    Config.BlueprintLabel or blueprintItem,
                    GetProjectVehicleLabel(model)
                ),
            }
        end
    end

    local plate = GeneratePlate()
    if not plate then
        return { ok = false, reason = 'Could not generate a plate.' }
    end

    if blueprintNeed > 0 then
        if not exports.ox_inventory:RemoveItem(src, blueprintItem, blueprintNeed, { model = model }) then
            return { ok = false, reason = 'Could not remove blueprints.' }
        end
    end

    if not exports.ox_inventory:RemoveItem(src, 'vehicle_shell', 1, shell.metadata, shell.slot) then
        if blueprintNeed > 0 then
            exports.ox_inventory:AddItem(src, blueprintItem, blueprintNeed, blueprintMeta)
        end
        return { ok = false, reason = 'Could not remove the shell item.' }
    end

    local data = {
        plate = plate,
        owner = xPlayer.identifier,
        model = model,
        x = dest.x,
        y = dest.y,
        z = dest.z,
        w = tonumber(payload.w) or 0.0,
        status = SanitizeStatus(payload.status),
    }

    Projects[plate] = data
    SaveProject(data)
    Broadcast(data)

    return { ok = true, plate = plate }
end)

lib.callback.register('kodebykarl-projectcars:server:installPart', function(src, payload)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return { ok = false, reason = 'Not loaded.' } end
    if type(payload) ~= 'table' then return { ok = false, reason = 'Invalid request.' } end

    local plate = NormalizePlate(payload.plate)
    local data = Projects[plate]
    if not data then return { ok = false, reason = 'No project car here.' } end

    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return { ok = false, reason = 'Invalid player.' } end
    local pCoords = GetEntityCoords(ped)
    if #(pCoords - vector3(data.x, data.y, data.z)) > 8.0 then
        return { ok = false, reason = 'Too far from the project car.' }
    end

    local partType = payload.part
    local cfg = Config.Parts[partType]
    if not cfg then return { ok = false, reason = 'Unknown part.' } end

    local status = data.status
    local index = payload.index

    if partType == 'door' then
        if not StatusReady(status.doors, index) then
            return { ok = false, reason = 'That door is already installed.' }
        end
    elseif partType == 'wheel' then
        if not StatusReady(status.wheels, index) then
            return { ok = false, reason = 'That wheel is already installed.' }
        end
    elseif partType == 'brake' then
        if not StatusReady(status.brakes, index) then
            return { ok = false, reason = 'That brake is already installed.' }
        end
    else
        if not status[partType] then
            return { ok = false, reason = ('%s is already installed.'):format(cfg.label) }
        end
    end

    local need = MissingRequires(status, cfg.requires, index, cfg.requiresIndex)
    if need then
        return { ok = false, reason = need }
    end

    local partMetaFilter = { model = data.model }
    local vehicleLabel = GetProjectVehicleLabel(data.model)
    if not HasItem(src, cfg.item, 1, partMetaFilter) then
        return {
            ok = false,
            reason = ('You need a %s for %s.'):format(cfg.label, vehicleLabel),
        }
    end

    if not RemoveItem(src, cfg.item, 1, partMetaFilter) then
        return { ok = false, reason = 'Could not remove the part.' }
    end

    if partType == 'door' then
        status.doors[tostring(index)] = false
    elseif partType == 'wheel' then
        status.wheels[tostring(index)] = false
    elseif partType == 'brake' then
        status.brakes[tostring(index)] = false
    elseif partType == 'hood' then
        status.hood = false
        status.trunk = false
        if status.doors then
            status.doors['4'] = false
            status.doors['5'] = false
        end
    else
        status[partType] = false
    end

    data.status = status
    SaveProject(data)

    if IsComplete(status) then
        FinishProject(src, data)
        return { ok = true, complete = true }
    end

    Broadcast(data)
    return { ok = true, complete = false }
end)

lib.addCommand(Config.GiveShellCommand, {
    help = 'Give a vehicle shell item',
    params = {
        { name = 'id', type = 'playerId', help = 'Player id' },
        { name = 'model', type = 'string', help = 'Vehicle spawn name (e.g. blista)' },
    },
}, function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)
    if source ~= 0 and not IsAdmin(xPlayer) then
        Notify(source, 'No permission.', 'error')
        return
    end

    local target = tonumber(args.id)
    local model = tostring(args.model or Config.DefaultModel):lower():gsub('%s+', '')
    if not target or not GetPlayerName(target) then
        Notify(source, 'Invalid player.', 'error')
        return
    end

    local added = exports.ox_inventory:AddItem(target, 'vehicle_shell', 1, PartMeta('vehicle_shell', model))

    if added then
        Notify(source, ('Gave %s shell to %s.'):format(GetProjectVehicleLabel(model), GetPlayerName(target)), 'success')
        Notify(target, ('You received a %s shell.'):format(GetProjectVehicleLabel(model)), 'success')
    else
        Notify(source, 'Could not add the item (inventory full?).', 'error')
    end
end)

lib.addCommand(Config.DeleteCommand, {
    help = 'Delete the nearest project car',
}, function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local nearest, nearestDist

    for plate, data in pairs(Projects) do
        local dist = #(coords - vector3(data.x, data.y, data.z))
        if not nearestDist or dist < nearestDist then
            nearest = data
            nearestDist = dist
        end
    end

    if not nearest or nearestDist > 6.0 then
        Notify(source, 'No project car nearby.', 'error')
        return
    end

    if nearest.owner ~= xPlayer.identifier and not IsAdmin(xPlayer) then
        Notify(source, 'This is not your project car.', 'error')
        return
    end

    DeleteProject(nearest.plate)
    Notify(source, ('Deleted project %s.'):format(nearest.plate), 'success')
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    Wait(1000)
    TriggerClientEvent('kodebykarl-projectcars:client:sync', -1, AllPayloads(), nil)
end)

exports('GiveShell', function(src, model)
    src = tonumber(src)
    model = tostring(model or Config.DefaultModel):lower():gsub('%s+', '')
    if not src or not GetPlayerName(src) then return false end
    return exports.ox_inventory:AddItem(src, 'vehicle_shell', 1, PartMeta('vehicle_shell', model))
end)

exports('BuildPartMetadata', function(itemName, model)
    return PartMeta(itemName, model)
end)

exports('GetVehicleLabel', function(model)
    return GetProjectVehicleLabel(model)
end)

exports('GetProjectVehicles', function()
    return Config.Vehicles
end)

exports('IsProjectVehicle', function(model)
    return IsProjectVehicle(model)
end)

exports('PickRandomProjectModel', function()
    return PickRandomProjectModel()
end)

exports('GetLootProjectModels', function()
    return GetLootProjectModels()
end)

exports('GivePart', function(src, itemName, count, model)
    src = tonumber(src)
    count = math.floor(tonumber(count) or 1)
    if not src or count < 1 or not itemName then return false end
    return exports.ox_inventory:AddItem(src, itemName, count, PartMeta(itemName, model))
end)
