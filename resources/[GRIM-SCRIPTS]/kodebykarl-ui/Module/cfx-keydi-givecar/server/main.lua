local ESX = exports['es_extended']:getSharedObject()

local function Notify(src, message, msgType)
    if not src or src == 0 then
        print(('[givecar] %s'):format(message))
        return
    end

    TriggerClientEvent('ox_lib:notify', src, {
        title = (Config.GiveCar and Config.GiveCar.NotificationTitle) or 'GIVE CAR',
        description = message,
        type = msgType or 'inform',
    })
end

local function GeneratePlate()
    if GetResourceState('jg-dealerships-v2') == 'started' then
        local ok, plate = pcall(function()
            return exports['jg-dealerships-v2']:generatePlate()
        end)
        if ok and plate and plate ~= '' then
            return tostring(plate):upper()
        end
    end

    if GetResourceState('jg-dealerships') == 'started' then
        local ok, plate = pcall(function()
            return exports['jg-dealerships']:generatePlate()
        end)
        if ok and plate and plate ~= '' then
            return tostring(plate):upper()
        end
    end

    local charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local plate = ''
    for _ = 1, 8 do
        local idx = math.random(1, #charset)
        plate = plate .. charset:sub(idx, idx)
    end
    return plate
end

local function GenerateUniquePlate()
    for _ = 1, 50 do
        local plate = GeneratePlate()
        local exists = MySQL.scalar.await('SELECT 1 FROM owned_vehicles WHERE plate = ? LIMIT 1', { plate })
        if not exists then
            return plate
        end
    end
    return nil
end

local function InsertGarageVehicle(identifier, model, plate)
    local garageId = (Config.GiveCar and Config.GiveCar.GarageId) or 'Legion Square'
    local props = json.encode({
        model = joaat(model),
        plate = plate,
    })

    local ok = pcall(function()
        MySQL.insert.await([[
            INSERT INTO owned_vehicles
                (`owner`, `plate`, `vehicle`, `stored`, `in_garage`, `garage_id`, `fuel`, `engine`, `body`)
            VALUES
                (?, ?, ?, 1, 1, ?, 100, 1000, 1000)
        ]], {
            identifier,
            plate,
            props,
            garageId,
        })
    end)

    if not ok then
        MySQL.insert.await(
            'INSERT INTO owned_vehicles (`owner`, `plate`, `vehicle`, `stored`) VALUES (?, ?, ?, ?)',
            { identifier, plate, props, true }
        )
    end

    return true
end

local function GiveCarToPlayer(adminSrc, targetId, model)
    targetId = tonumber(targetId)
    if not targetId or not model or model == '' then
        return false, 'Usage: /givecar [id] [car]'
    end

    model = tostring(model):lower():gsub('%s+', '')

    local xTarget = ESX.GetPlayerFromId(targetId)
    if not xTarget then
        return false, ('Player %s is not online.'):format(tostring(targetId))
    end

    local plate = GenerateUniquePlate()
    if not plate then
        return false, 'Failed to generate a unique plate. Try again.'
    end

    InsertGarageVehicle(xTarget.identifier, model, plate)

    pcall(function()
        exports['kodebykarl-ui']:GiveKey(targetId, plate)
    end)

    Notify(targetId, ('You received a %s (plate: %s) in your garage.'):format(model, plate), 'success')

    if adminSrc and adminSrc ~= 0 and adminSrc ~= targetId then
        Notify(
            adminSrc,
            ('Gave %s to %s [%s] — plate: %s'):format(model, xTarget.getName(), targetId, plate),
            'success'
        )
    elseif not adminSrc or adminSrc == 0 then
        print(('[givecar] Gave %s to %s [%s] — plate: %s'):format(model, xTarget.getName(), targetId, plate))
    end

    return true, plate
end

local commandName = (Config.GiveCar and Config.GiveCar.Command) or 'givecar'

ESX.RegisterCommand(
    commandName,
    (Config.GiveCar and Config.GiveCar.Groups) or { 'superadmin', 'owner', 'developer' },
    function(xPlayer, args, showError)
        local adminSrc = xPlayer and xPlayer.source or 0
        local target = args.playerId
        local model = args.car

        if type(target) == 'table' and target.source then
            target = target.source
        end

        local ok, result = GiveCarToPlayer(adminSrc, target, model)
        if not ok then
            return showError(result)
        end
    end,
    true,
    {
        help = 'Give a vehicle to a player (stored in garage, random plate)',
        validate = true,
        arguments = {
            { name = 'playerId', help = 'Player server id', type = 'player' },
            { name = 'car', help = 'Vehicle spawn name (e.g. sultan)', type = 'string' },
        },
    }
)

exports('GiveCarToPlayer', function(targetId, model)
    return GiveCarToPlayer(0, targetId, model)
end)
