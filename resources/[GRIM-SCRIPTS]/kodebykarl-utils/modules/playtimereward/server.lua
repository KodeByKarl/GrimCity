local Config = require 'configs.playtimereward'

if not Config or not Config.Enabled then return end

local claimedCache = {} -- [identifier][rewardId] = true
local claimBusy = {}

local function cacheKey(identifier, rewardId)
    return ('%s:%s'):format(identifier, rewardId)
end

CreateThread(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `cfx-keydi-playtimereward` (
            `id` INT NOT NULL AUTO_INCREMENT,
            `identifier` VARCHAR(60) NOT NULL,
            `reward_id` VARCHAR(32) NOT NULL DEFAULT 'sunrise',
            `plate` VARCHAR(12) NOT NULL,
            `claimed_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            UNIQUE KEY `identifier_reward` (`identifier`, `reward_id`)
        )
    ]])

    -- Older installs only had UNIQUE(identifier). Add reward_id + migrate.
    pcall(function()
        MySQL.query.await('ALTER TABLE `cfx-keydi-playtimereward` ADD COLUMN IF NOT EXISTS `reward_id` VARCHAR(32) NOT NULL DEFAULT \'sunrise\' AFTER `identifier`')
    end)
    pcall(function()
        MySQL.query.await('ALTER TABLE `cfx-keydi-playtimereward` DROP INDEX `identifier`')
    end)
    pcall(function()
        MySQL.query.await('ALTER TABLE `cfx-keydi-playtimereward` ADD UNIQUE KEY `identifier_reward` (`identifier`, `reward_id`)')
    end)
    pcall(function()
        MySQL.update.await('UPDATE `cfx-keydi-playtimereward` SET `reward_id` = ? WHERE `reward_id` IS NULL OR `reward_id` = \'\'', { 'sunrise' })
    end)

    Wait(1000)
    local rows = MySQL.query.await('SELECT `identifier`, `reward_id` FROM `cfx-keydi-playtimereward`', {})
    if rows then
        for i = 1, #rows do
            local rewardId = rows[i].reward_id
            if type(rewardId) ~= 'string' or rewardId == '' then
                rewardId = 'sunrise'
            end
            claimedCache[cacheKey(rows[i].identifier, rewardId)] = true
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

--- ESX cumulative playtime (lastPlaytime metadata + GetPlayerTimeOnline)
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

local function getReward(rewardId)
    local rewards = Config.Rewards
    if type(rewards) ~= 'table' then return nil end
    local reward = rewards[rewardId]
    if type(reward) ~= 'table' then return nil end
    return reward
end

local function claimReward(src, rewardId)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    if claimBusy[src] then return end

    local reward = getReward(rewardId)
    if not reward then
        Notify(src, 'Invalid playtime reward.', 'error')
        return
    end

    local pedCoords = Config.PedCoords
    if pedCoords then
        local playerCoords = xPlayer.getCoords(true)
        if #(playerCoords - pedCoords) > (Config.DistanceCheck or 5.0) then
            Notify(src, 'You are too far from the playtime reward NPC.', 'error')
            return
        end
    end

    local key = cacheKey(xPlayer.identifier, rewardId)
    if reward.OneTime ~= false and claimedCache[key] then
        Notify(src, ('You have already claimed your free %s.'):format(reward.Label or rewardId), 'error')
        return
    end

    local playSeconds = getTotalPlaySeconds(xPlayer)
    local required = tonumber(reward.RequiredSeconds) or 0
    if playSeconds < required then
        local left = required - playSeconds
        Notify(src, ('Need %s total playtime for %s. You have %s (%s left).'):format(
            formatPlayTime(required),
            reward.Label or rewardId,
            formatPlayTime(playSeconds),
            formatPlayTime(left)
        ), 'error')
        return
    end

    claimBusy[src] = true

    local plate = generatePlate()
    local model = reward.VehicleModel or 'neon'
    local garageId = reward.GarageId or 'Legion Square'
    local nick = ('%s-%s'):format(reward.NicknamePrefix or ('REWARD-' .. rewardId:upper()), plate:upper())
    local vehicleJson = json.encode({ model = joaat(model), plate = plate })

    local inserted = false
    local lastErr

    local attempts = {
        {
            [[
                INSERT INTO owned_vehicles
                    (`owner`, `plate`, `vehicle`, `stored`, `in_garage`, `garage_id`, `nickname`, `fuel`, `engine`, `body`)
                VALUES (?, ?, ?, 1, 1, ?, ?, 100, 1000, 1000)
            ]],
            { xPlayer.identifier, plate, vehicleJson, garageId, nick },
        },
        {
            'INSERT INTO owned_vehicles (`owner`, `plate`, `vehicle`, `stored`, `in_garage`, `garage_id`, `nickname`) VALUES (?, ?, ?, 1, 1, ?, ?)',
            { xPlayer.identifier, plate, vehicleJson, garageId, nick },
        },
        {
            'INSERT INTO owned_vehicles (`owner`, `plate`, `vehicle`, `stored`, `nickname`) VALUES (?, ?, ?, 1, ?)',
            { xPlayer.identifier, plate, vehicleJson, nick },
        },
        {
            'INSERT INTO owned_vehicles (`owner`, `plate`, `vehicle`, `stored`) VALUES (?, ?, ?, 1)',
            { xPlayer.identifier, plate, vehicleJson },
        },
    }

    for i = 1, #attempts do
        local ok, err = pcall(function()
            MySQL.insert.await(attempts[i][1], attempts[i][2])
        end)
        if ok then
            inserted = true
            break
        end
        lastErr = err
    end

    if not inserted then
        claimBusy[src] = nil
        print(('[playtimereward] insert failed for %s (%s / %s): %s'):format(
            tostring(xPlayer.identifier),
            tostring(model),
            tostring(plate),
            tostring(lastErr)
        ))
        Notify(src, 'Failed to add vehicle to your garage. Try again.', 'error')
        return
    end

    if reward.OneTime ~= false then
        local id = MySQL.insert.await(
            'INSERT INTO `cfx-keydi-playtimereward` (identifier, reward_id, plate) VALUES (?, ?, ?)',
            { xPlayer.identifier, rewardId, plate }
        )
        if id then
            claimedCache[key] = true
        end
    end

    claimBusy[src] = nil

    pcall(function()
        if GetResourceState('kodebykarl-ui') == 'started' then
            exports['kodebykarl-ui']:GiveKey(src, plate)
        end
    end)

    Notify(src, ('Free %s claimed! Plate %s — pick it up at %s garage.'):format(
        reward.Label or rewardId,
        plate:upper(),
        garageId
    ), 'success')
    print(('[playtimereward] %s [%s] claimed %s (%s) plate %s (%s playtime)'):format(
        xPlayer.name,
        xPlayer.identifier,
        rewardId,
        model,
        plate,
        formatPlayTime(playSeconds)
    ))
end

RegisterNetEvent('cfx-keydi-utils:playtimereward:server:claim', function(rewardId)
    local src = source
    -- Back-compat: old ped/client with no arg claimed sunrise
    if type(rewardId) ~= 'string' or rewardId == '' then
        rewardId = 'sunrise'
    end
    claimReward(src, rewardId:lower())
end)
