GangVehicles = GangVehicles or {}

local function GeneratePlate()
    local charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    for _ = 1, 20 do
        local plate = 'G'
        for __ = 1, 7 do
            local idx = math.random(1, #charset)
            plate = plate .. charset:sub(idx, idx)
        end
        plate = plate:upper()
        local exists = MySQL.scalar.await('SELECT 1 FROM owned_vehicles WHERE plate = ? LIMIT 1', { plate })
        if not exists then
            return plate
        end
    end
    return ('G%07d'):format(math.random(0, 9999999))
end

function GangVehicles.WipeClaimed(identifier, plate)
    if plate and plate ~= '' then
        MySQL.update.await('DELETE FROM owned_vehicles WHERE plate = ? AND owner = ?', { plate, identifier })
        return
    end
    -- Fallback: delete any vehicle nicknamed GANG-CLAIM for this owner
    MySQL.update.await(
        "DELETE FROM owned_vehicles WHERE owner = ? AND (nickname LIKE 'GANG-CLAIM-%' OR name LIKE 'GANG-CLAIM-%')",
        { identifier }
    )
end

RegisterNetEvent('kodebykarl-gangsystem:server:claimCar', function(gangId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local def = Config.GetGang(gangId)
    if not def then return end

    local gang = GangMembership.GetPlayerGang(src)
    if not gang or gang.name ~= gangId then
        return TriggerClientEvent('ox_lib:notify', src, {
            title = 'GANG CAR',
            description = 'You must be hired into this gang first.',
            type = 'error',
        })
    end

    if gang.claimed_car then
        return TriggerClientEvent('ox_lib:notify', src, {
            title = 'GANG CAR',
            description = 'You already claimed your gang car.',
            type = 'error',
        })
    end

    local playtime = 0
    if xPlayer.getPlayTime then
        playtime = tonumber(xPlayer.getPlayTime()) or 0
    end
    if playtime < (Config.MinPlaytimeSeconds or 7200) then
        local need = Config.MinPlaytimeSeconds or 7200
        local left = math.max(0, need - playtime)
        local hours = math.floor(left / 3600)
        local mins = math.floor((left % 3600) / 60)
        return TriggerClientEvent('ox_lib:notify', src, {
            title = 'GANG CAR',
            description = ('Need 2 hours city playtime. Remaining ~%dh %dm.'):format(hours, mins),
            type = 'error',
        })
    end

    local model = def.claimVehicle or 'sultan'
    local plate = GeneratePlate()
    local props = json.encode({
        model = joaat(model),
        plate = plate,
    })
    local label = ('GANG-CLAIM-%s'):format(plate)

    local ok = pcall(function()
        MySQL.insert.await([[
            INSERT INTO owned_vehicles (`owner`, `plate`, `vehicle`, `stored`, `name`, `nickname`, `garage_id`, `in_garage`, `gang_vehicle`)
            VALUES (?, ?, ?, 1, ?, ?, 'legion', 1, 1)
        ]], { xPlayer.identifier, plate, props, label, label })
    end)

    if not ok then
        MySQL.insert.await(
            'INSERT INTO owned_vehicles (`owner`, `plate`, `vehicle`, `stored`, `name`) VALUES (?, ?, ?, 1, ?)',
            { xPlayer.identifier, plate, props, label }
        )
    end

    GangMembership.MarkClaimed(src, plate)

    TriggerClientEvent('ox_lib:notify', src, {
        title = 'GANG CAR',
        description = ('Claimed %s [%s]. Check your garage. One-time only.'):format(model, plate),
        type = 'success',
    })
end)
