local ESX = exports['es_extended']:getSharedObject()

local cacheFreeCars = {}

local function GeneratePlate()
    if GetResourceState('jg-dealerships') == 'started' then
        local ok, plate = pcall(function()
            return exports['jg-dealerships']:generatePlate()
        end)
        if ok and plate and plate ~= '' then
            return plate
        end
    end
    if GetResourceState('jg-dealerships-v2') == 'started' then
        local ok, plate = pcall(function()
            return exports['jg-dealerships-v2']:generatePlate()
        end)
        if ok and plate and plate ~= '' then
            return plate
        end
    end
    return ('FREE%04d'):format(math.random(0, 9999))
end

local function GetAllowedVehicles()
    return Config.FreeCar and Config.FreeCar.AllowedVehicles or {}
end

local function FindVehicleConfig(model)
    if not model or type(model) ~= 'string' then return nil end
    local vehicles = GetAllowedVehicles()
    for i = 1, #vehicles do
        if vehicles[i].model == model then
            return vehicles[i]
        end
    end
    return nil
end

local function RollWeightedVehicle()
    local vehicles = GetAllowedVehicles()
    if #vehicles == 0 then return nil end

    local total = 0.0
    for i = 1, #vehicles do
        total = total + (tonumber(vehicles[i].chance) or 0)
    end

    if total <= 0 then
        return vehicles[math.random(1, #vehicles)]
    end

    local roll = math.random() * total
    local cumulative = 0.0
    for i = 1, #vehicles do
        cumulative = cumulative + (tonumber(vehicles[i].chance) or 0)
        if roll <= cumulative then
            return vehicles[i]
        end
    end

    return vehicles[#vehicles]
end

--- Insert a vehicle into owned_vehicles already stored in the player's garage.
local function InsertGarageVehicle(identifier, model, label)
    local plate = GeneratePlate()
    local garageId = (Config.FreeCar and Config.FreeCar.GarageId) or 'Legion Square'
    local props = json.encode({
        model = joaat(model),
        plate = plate,
    })
    local displayName = label and ('FREE-%s'):format(label) or ('FREE-%s'):format(plate:upper())

    local ok = pcall(function()
        MySQL.insert.await([[
            INSERT INTO owned_vehicles
                (`owner`, `plate`, `vehicle`, `stored`, `in_garage`, `garage_id`, `fuel`, `engine`, `body`, `name`)
            VALUES
                (?, ?, ?, 1, 1, ?, 100, 1000, 1000, ?)
        ]], {
            identifier,
            plate,
            props,
            garageId,
            displayName,
        })
    end)

    if not ok then
        -- Fallback for DBs missing jg garage columns
        MySQL.insert.await(
            'INSERT INTO owned_vehicles (`owner`, `plate`, `vehicle`, `stored`, `name`) VALUES (?, ?, ?, ?, ?)',
            { identifier, plate, props, true, displayName }
        )
    end

    return plate
end

local function ClaimFreeCar(source, vehicleModel)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false, 'Player not found' end

    if cacheFreeCars[xPlayer.identifier] then
        return false, 'Already claimed'
    end

    local vehCfg = FindVehicleConfig(vehicleModel)
    if not vehCfg then
        return false, 'Vehicle not allowed'
    end

    local bonus = Config.FreeCar and Config.FreeCar.BonusVehicle
    if not bonus or not bonus.model then
        return false, 'Bonus vehicle not configured'
    end

    local claimId = MySQL.insert.await('INSERT INTO `cfx-keydi-freecars` (identifier) VALUES (?)', { xPlayer.identifier })
    if not claimId then
        return false, 'Database error'
    end

    local roulettePlate = InsertGarageVehicle(xPlayer.identifier, vehCfg.model, vehCfg.label)
    local bonusPlate = InsertGarageVehicle(xPlayer.identifier, bonus.model, bonus.label or 'Burrito')

    cacheFreeCars[xPlayer.identifier] = true

    if GetResourceState('ox_inventory') == 'started' then
        pcall(function()
            exports.ox_inventory:RemoveItem(source, 'item_free_car', 1)
        end)
    end

    return true, {
        plate = roulettePlate,
        bonusPlate = bonusPlate,
        bonusModel = bonus.model,
        bonusLabel = bonus.label or 'Burrito',
        model = vehCfg.model,
        label = vehCfg.label,
        rarity = vehCfg.rarity or 'common',
        chance = vehCfg.chance,
    }
end

CreateThread(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `cfx-keydi-freecars` (
            `id` INT NOT NULL AUTO_INCREMENT,
            `identifier` VARCHAR(60) NOT NULL,
            `claimed_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            UNIQUE KEY `identifier` (`identifier`)
        )
    ]])

    Wait(1000)
    local response = MySQL.query.await('SELECT `identifier` FROM `cfx-keydi-freecars`', {})
    if response then
        for i = 1, #response do
            cacheFreeCars[response[i].identifier] = true
        end
    end
end)

lib.callback.register('cfx-keydi-freecar:server:hasClaimed', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    return cacheFreeCars[xPlayer.identifier] == true
end)

lib.callback.register('cfx-keydi-freecar:server:spin', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return { success = false, message = 'Player not found' }
    end

    if cacheFreeCars[xPlayer.identifier] then
        return { success = false, message = 'Already claimed' }
    end

    local winner = RollWeightedVehicle()
    if not winner then
        return { success = false, message = 'No vehicles configured' }
    end

    local success, result = ClaimFreeCar(source, winner.model)
    if not success then
        return { success = false, message = result or 'Unable to claim vehicle.' }
    end

    return {
        success = true,
        model = result.model,
        label = result.label,
        rarity = result.rarity,
        chance = result.chance,
        plate = result.plate,
        bonusPlate = result.bonusPlate,
        bonusModel = result.bonusModel,
        bonusLabel = result.bonusLabel,
    }
end)

RegisterNetEvent('cfx-keydi-freecar:server:claim', function(vehicleModel)
    local src = source
    local success, result = ClaimFreeCar(src, vehicleModel)

    if success then
        TriggerClientEvent('cfx-keydi-freecar:client:claimed', src, result.plate, result)
        TriggerClientEvent(
            'cfx-keydi-freecar:client:notify',
            src,
            Config.FreeCar.NotificationTitle,
            ('Both vehicles are in your garage (%s + %s).'):format(result.label, result.bonusLabel),
            'success'
        )
    else
        TriggerClientEvent('cfx-keydi-freecar:client:notify', src, Config.FreeCar.NotificationTitle, result or 'Unable to claim vehicle.', 'error')
    end
end)

exports('ClaimFreeCar', ClaimFreeCar)
exports('HasClaimedFreeCar', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    return cacheFreeCars[xPlayer.identifier] == true
end)
