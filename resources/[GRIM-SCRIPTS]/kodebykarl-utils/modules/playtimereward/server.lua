local Config = require 'configs.playtimereward'

if not Config or not Config.Enabled then return end

local claimedCache = {}
local claimBusy = {}

CreateThread(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `cfx-keydi-playtimereward` (
            `id` INT NOT NULL AUTO_INCREMENT,
            `identifier` VARCHAR(60) NOT NULL,
            `plate` VARCHAR(12) NOT NULL,
            `claimed_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            UNIQUE KEY `identifier` (`identifier`)
        )
    ]])

    Wait(1000)
    local rows = MySQL.query.await('SELECT `identifier` FROM `cfx-keydi-playtimereward`', {})
    if rows then
        for i = 1, #rows do
            claimedCache[rows[i].identifier] = true
        end
    end
end)

local function Notify(src, message, msgType)
    TriggerClientEvent('esx:Notify', src, Config.NotifyTitle or 'PLAYTIME REWARD', message, msgType or 'info', 7000)
end

local function formatPlayTime(seconds)
    seconds = math.max(0, math.floor(tonumber(seconds) or 0))
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    if days > 0 then
        return ('%dd %dh %dm'):format(days, hours, minutes)
    end
    if hours > 0 then
        return ('%dh %dm'):format(hours, minutes)
    end
    return ('%dm'):format(math.max(1, minutes))
end

--- ESX cumulative playtime (lastPlaytime metadata + GetPlayerTimeOnline) — same source as /playtime & tx session tracking
local function getTotalPlaySeconds(xPlayer)
    if not xPlayer or not xPlayer.getPlayTime then return 0 end
    return tonumber(xPlayer.getPlayTime()) or 0
end

local function generatePlate()
    if GetResourceState('jg-dealerships-v2') == 'started' then
        local ok, plate = pcall(function()
            return exports['jg-dealerships-v2']:generatePlate(nil, true)
        end)
        if ok and type(plate) == 'string' and plate ~= '' then
            return plate
        end
    end

    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    for _ = 1, 20 do
        local plate = ''
        for i = 1, 8 do
            local idx = math.random(1, #chars)
            plate = plate .. chars:sub(idx, idx)
        end
        local exists = MySQL.scalar.await('SELECT 1 FROM owned_vehicles WHERE plate = ? LIMIT 1', { plate })
        if not exists then
            return plate
        end
    end
    return ('PT%06d'):format(math.random(0, 999999))
end

RegisterNetEvent('cfx-keydi-utils:playtimereward:server:claim', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    if claimBusy[src] then return end

    local pedCoords = Config.PedCoords
    if pedCoords then
        local playerCoords = xPlayer.getCoords(true)
        if #(playerCoords - pedCoords) > (Config.DistanceCheck or 5.0) then
            Notify(src, 'You are too far from the playtime reward NPC.', 'error')
            return
        end
    end

    if Config.OneTime and claimedCache[xPlayer.identifier] then
        Notify(src, 'You have already claimed your free Sunrise.', 'error')
        return
    end

    local playSeconds = getTotalPlaySeconds(xPlayer)
    local required = Config.RequiredSeconds or (6 * 3600)
    if playSeconds < required then
        local left = required - playSeconds
        Notify(src, ('Need %s total playtime. You have %s (%s left).'):format(
            formatPlayTime(required),
            formatPlayTime(playSeconds),
            formatPlayTime(left)
        ), 'error')
        return
    end

    claimBusy[src] = true

    local plate = generatePlate()
    local model = Config.VehicleModel or 'sunrise1'
    local garageId = Config.GarageId or 'Legion Square'
    local nick = ('%s-%s'):format(Config.NicknamePrefix or 'PLAYTIME-SUNRISE', plate:upper())
    local vehicleJson = ('{"model":%s,"plate":"%s"}'):format(joaat(model), plate)

    local inserted = false
    local ok = pcall(function()
        MySQL.insert.await([[
            INSERT INTO owned_vehicles
                (`owner`, `plate`, `vehicle`, `stored`, `in_garage`, `garage_id`, `nickname`, `name`, `fuel`, `engine`, `body`)
            VALUES (?, ?, ?, 1, 1, ?, ?, ?, 100, 1000, 1000)
        ]], {
            xPlayer.identifier,
            plate,
            vehicleJson,
            garageId,
            nick,
            nick,
        })
        inserted = true
    end)

    if not ok or not inserted then
        local ok2 = pcall(function()
            MySQL.insert.await(
                'INSERT INTO owned_vehicles (`owner`, `plate`, `vehicle`, `stored`, `nickname`, `name`) VALUES (?, ?, ?, 1, ?, ?)',
                { xPlayer.identifier, plate, vehicleJson, nick, nick }
            )
            inserted = true
        end)
        if not ok2 or not inserted then
            claimBusy[src] = nil
            Notify(src, 'Failed to add vehicle to your garage. Try again.', 'error')
            return
        end
    end

    if Config.OneTime then
        local id = MySQL.insert.await(
            'INSERT INTO `cfx-keydi-playtimereward` (identifier, plate) VALUES (?, ?)',
            { xPlayer.identifier, plate }
        )
        if id then
            claimedCache[xPlayer.identifier] = true
        end
    end

    claimBusy[src] = nil

    Notify(src, ('Free Sunrise claimed! Plate %s — pick it up at %s garage.'):format(plate:upper(), garageId), 'success')
    print(('[playtimereward] %s [%s] claimed sunrise1 plate %s (%s playtime)'):format(
        xPlayer.name, xPlayer.identifier, plate, formatPlayTime(playSeconds)
    ))
end)
