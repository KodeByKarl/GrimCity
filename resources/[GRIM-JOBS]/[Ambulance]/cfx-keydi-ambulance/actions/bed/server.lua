local Vars = require 'helpers.vars'
local helpers = require 'helpers.game'
local menu = require 'shared.menu'
local RegisteredBed = {}
local BedCooldown = {}
local cacheBedData = {}
local cacheCheckedPlayers = {}
local cachePlayersDropInBed = {}

local blacklistedStrings = {
    "nigga", "cheat", "exploit", 'tanginamo', 'kupal', 'revshit',
    'amari', 'arrabica', 'rasclatv', 'rasclat', 'kupalino', 'n4gga', 'niga', 'nigger', 'niggabyte',
    'negro', 'niggapoptamous', 'tangina', 'putanginamo', 'putangina', 'gago', 'on top', 'gago ka'
}

CreateThread(function()
    -- Ensure cfx_keydi_bed table exists in database
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `cfx_keydi_bed` (
          `id` int(11) NOT NULL AUTO_INCREMENT,
          `name` varchar(255) DEFAULT NULL,
          `identifier` varchar(255) NOT NULL,
          `time` int(11) NOT NULL DEFAULT 0,
          `reason` varchar(255) DEFAULT NULL,
          `bedIndex` int(11) NOT NULL,
          `hospital` varchar(255) NOT NULL,
          PRIMARY KEY (`id`),
          KEY `identifier` (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    for job, beds in pairs(menu.bed.locations) do
        RegisteredBed[job] = {}
        for i = 1, #beds do
            local coords = beds[i]
            RegisteredBed[job][i] = {
                index = i,
                coords = coords,
                state = false,
            }
        end
    end

    local response = MySQL.query.await('SELECT * FROM `cfx_keydi_bed`', {})
    if response then
        for i = 1, #response do
            local row = response[i]
            if row.time > 0 then
                cachePlayersDropInBed[row.identifier] = {time = row.time, bedIndex = row.bedIndex, hospital = row.hospital}
            end
        end
    end
end)


local function FormatSentry(xPlayer, xTarget, targetId, admitReason, admitTime, bedIndex)
    local playerCoords = xPlayer.getCoords(true)
    local targetCoords = xTarget.getCoords(true)
    local text = {
        ('SENTRY DETECTION FOR ADMIT PLAYER'),
        ('Source Name: %s [%s]'):format(xPlayer.name, xPlayer.source),
        ('Target Name: %s [%s]'):format(xTarget.name, xTarget.source),
        ('targetId Provided: %s'):format(targetId),
        ('Admit Reason: %s'):format(admitReason),
        ('Admit Time: %s'):format(admitTime),
        ('Bed Index: %s'):format(bedIndex),
        ('Source Coords: %s'):format('vec3('..playerCoords.x..', '..playerCoords.y..', '..playerCoords.z..')'),
        ('Target Coords: %s'):format('vec3('..targetCoords.x..', '..targetCoords.y..', '..targetCoords.z..')'),
        ('Distance: %s'):format(#(playerCoords - targetCoords))
    }
    return table.concat(text, ' | ')
end

local function SentryBedList(xPlayer)
    local playerCoords = xPlayer.getCoords(true)
    local text = {
        ('SENTRY DETECTION FOR BED LIST'),
        ('Name: %s [%s]'):format(xPlayer.name, xPlayer.source),
        ('Job: %s [%s]'):format(xPlayer.job.label),
        ('Coords: %s'):format('vec3('..playerCoords.x..', '..playerCoords.y..', '..playerCoords.z..')'),
    }
    return table.concat(text, ' | ')
end

ESX.RegisterServerCallback('cfx-keydi-ambulance:getBeds', function(source, cb)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return cb(false) end
    if not helpers.HasJob(menu.bed.access, xPlayer) then
        lib.logger(xPlayer.source, 'cfx-keydi-sentry', SentryBedList(xPlayer), 'ERROR')
        return cb(false)
    end
    cb(RegisteredBed[xPlayer.job.name])
end)

local function ValidatedAdmit(xPlayer, xTarget, targetId, reason, time, bedIndex)
    if not xTarget or not xPlayer then return false, 'INVALID TARGET OR PLAYER' end
    local playerCoords = xPlayer.getCoords(true)
    local targetCoords = xTarget.getCoords(true)
    if targetId == -1 or type(targetId) ~= 'number' then
        return false, 'INVALID ID'
    end
    if not helpers.HasJob(menu.bed.access, xPlayer) then
        return false, 'INVALID JOB'
    end
    if #(playerCoords - targetCoords) > 5.0 then
        return false, 'INVALID DISTANCE'
    end
    if type(time) ~= 'number' or time > 900 then -- 15 minutes limit???
        return false, 'INVALID TIME'
    end
    if not RegisteredBed[xPlayer.job.name][bedIndex] or RegisteredBed[xPlayer.job.name][bedIndex].state then
        return false, 'INVALID BED INDEX'
    end
    for _, blacklisted in ipairs(blacklistedStrings) do
        if string.find(string.lower(reason), string.lower(blacklisted), 1, true) then
            return false, 'LABEL CONTAINS BLACKLISTED STRING'
        end
    end
    return true
end


RegisterNetEvent('cfx-keydi-ambulance:admitTarget', function(playerId, admitReason, admitTime, bedIndex)
    local src = source
    local targetId = tonumber(playerId)
    if not targetId or targetId == -1 then return end
    local xTarget = ESX.GetPlayerFromId(targetId)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or not xTarget then return end
    local success, reason = ValidatedAdmit(xPlayer, xTarget, targetId, admitReason, admitTime, bedIndex)
    if not success then
        lib.logger(xPlayer.source, 'cfx-keydi-sentry', FormatSentry(xPlayer, xTarget, targetId, admitReason, admitTime, bedIndex), 'ERROR')
        print(("^0[^3cfx-keydi-ambulance^0] [ADMIT]: Validation failed for %s: %s"):format(xPlayer.name, reason or 'No reason provided'))
        if AmbulanceLogs and AmbulanceLogs.Sentry then
            AmbulanceLogs.Sentry({
                system = 'BED ADMIT',
                src = src,
                name = xPlayer and xPlayer.name,
                identifier = xPlayer and xPlayer.identifier,
                targetSrc = targetId,
                targetName = xTarget and xTarget.name,
                targetIdentifier = xTarget and xTarget.identifier,
                reason = reason,
                coords = xPlayer and xPlayer.getCoords(true),
                targetCoords = xTarget and xTarget.getCoords(true),
            })
        end
        return
    end
    if not xTarget then return TriggerClientEvent('esx:Notify', xPlayer.source, 'AMBULANCE', 'Invalid Target', 'error', 5000) end
    local id = MySQL.insert.await('INSERT INTO `cfx_keydi_bed` (name, identifier, time, reason, bedIndex, hospital) VALUES (?, ?, ?, ?, ?, ?)', {xTarget.name, xTarget.identifier, admitTime, admitReason, bedIndex, xPlayer.job.name})
    if id ~= 0 then
        RegisteredBed[xPlayer.job.name][bedIndex].state = true
        cacheBedData[bedIndex] = {identifier = xTarget.identifier, playerId = xTarget.source}
        BedCooldown[xTarget.source] = {time = admitTime, bedIndex = bedIndex, identifier = xTarget.identifier, hospital = xPlayer.job.name}
        TriggerClientEvent('cfx-keydi-ambulance:syncBed', xTarget.source, admitTime, bedIndex, xPlayer.job.name)
        if AmbulanceLogs and AmbulanceLogs.BedAdmit then
            local job = xPlayer.job and (('%s — %s'):format(xPlayer.job.label or xPlayer.job.name, xPlayer.job.grade_label or '')) or nil
            AmbulanceLogs.BedAdmit({
                src = src,
                name = xPlayer.name,
                identifier = xPlayer.identifier,
                job = job,
                targetSrc = targetId,
                targetName = xTarget.name,
                targetIdentifier = xTarget.identifier,
                bedIndex = bedIndex,
                hospital = xPlayer.job.name,
                time = admitTime,
                reason = admitReason,
            })
        end
    else
        TriggerClientEvent('esx:Notify', xPlayer.source, 'AMBULANCE', 'Database error, Contact the server Developer.', 'warning', 10000)
    end
end)

local function FinishedBed(playerId, bedIndex, hospital)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end
    if not RegisteredBed[hospital][bedIndex] or not RegisteredBed[hospital][bedIndex].state then return end
    local affectedRows = MySQL.update.await('DELETE FROM `cfx_keydi_bed` WHERE identifier = ?', {xPlayer.identifier})
    local routingId = GetPlayerRoutingBucket(xPlayer.source)
    if routingId ~= 0 then
        SetPlayerRoutingBucket(xPlayer.source, 0)
    end
    RegisteredBed[hospital][bedIndex].state = false
    cacheBedData[bedIndex] = nil
    BedCooldown[playerId] = nil
    TriggerClientEvent('cfx-keydi-ambulance:removeBedFromTarget', xPlayer.source)
end

local function validateUnbed(xPlayer, index, state)
    if not xPlayer then
        return false, 'INVALID PLAYER'
    end
    if not cacheBedData[index] then
        return false, 'INVALID BED DATA'
    end
    if not RegisteredBed[xPlayer.job.name]?[index] then
        return false, 'BED NOT REGISTERED'
    end
    if not state then
        return false, 'INVALID STATE'
    end
    local targetData = cacheBedData[index]
    local xTarget = ESX.GetPlayerFromId(targetData.playerId)
    if not xTarget then
        return false, 'PLAYER NOT ONLINE'
    end
    if not BedCooldown[xTarget.source] then
        return false, 'INVALID BED COOLDOWN'
    end
    if not helpers.HasJob(menu.unbed.access, xPlayer) then
        return false, 'INVALID JOB'
    end
    TriggerClientEvent('esx:Notify', xPlayer.source, 'AMBULANCE', ('You unbed %s from bed #%s'):format(xTarget.name, index), 'success', 5000)
    return true, '', xTarget
end

local function formatUnbed(xPlayer, xTarget, index, state, reason)
    local playerCoords = xPlayer and xPlayer.getCoords(true) or vec3(0, 0, 0)
    local targetCoords = xTarget and xTarget.getCoords(true) or vec3(0, 0, 0)
    local text = {
        ('SENTRY DETECTION FOR UNBED PLAYER'),
        ('Source Name: %s [%s]'):format(xPlayer and xPlayer.name or 'Unknown', xPlayer and xPlayer.source or 0),
        ('Target Name: %s [%s]'):format(xTarget and xTarget.name or 'Unknown', xTarget and xTarget.source or 0),
        ('Index Provided: %s'):format(index),
        ('State Provided: %s'):format(state),
        ('Detection Reason: %s'):format(reason),
        ('Source Coords: %s'):format('vec3('..playerCoords.x..', '..playerCoords.y..', '..playerCoords.z..')'),
        ('Target Coords: %s'):format('vec3('..targetCoords.x..', '..targetCoords.y..', '..targetCoords.z..')'),
        ('Distance: %s'):format(#(playerCoords - targetCoords))
    }
    return table.concat(text, ' | ')
end

RegisterNetEvent('cfx-keydi-ambulance:unbedTarget', function(index, state)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    local success, reason, xTarget = validateUnbed(xPlayer, index, state)
    if not success then
        lib.logger(xPlayer.source, 'cfx-keydi-sentry', formatUnbed(xPlayer, xTarget, index, state, reason), 'ERROR')
        print(("^0[^3cfx-keydi-ambulance^0] [UNBED]: Validation failed for %s: %s"):format(xPlayer.name, reason or 'No reason provided'))
        if AmbulanceLogs and AmbulanceLogs.Sentry then
            AmbulanceLogs.Sentry({
                system = 'UNBED',
                src = src,
                name = xPlayer and xPlayer.name,
                identifier = xPlayer and xPlayer.identifier,
                targetSrc = xTarget and xTarget.source,
                targetName = xTarget and xTarget.name,
                targetIdentifier = xTarget and xTarget.identifier,
                reason = reason,
                coords = xPlayer and xPlayer.getCoords(true),
                targetCoords = xTarget and xTarget.getCoords(true),
            })
        end
        return
    end
    if AmbulanceLogs and AmbulanceLogs.Unbed then
        local job = xPlayer.job and (('%s — %s'):format(xPlayer.job.label or xPlayer.job.name, xPlayer.job.grade_label or '')) or nil
        AmbulanceLogs.Unbed({
            src = src,
            name = xPlayer.name,
            identifier = xPlayer.identifier,
            job = job,
            targetSrc = xTarget.source,
            targetName = xTarget.name,
            targetIdentifier = xTarget.identifier,
            bedIndex = index,
            hospital = xPlayer.job and xPlayer.job.name,
        })
    end
    FinishedBed(xTarget.source, index, xPlayer.job.name)
end)

CreateThread(function()
    while true do
        Wait(1000)
        if next(BedCooldown) then
            for playerId, bedData in pairs(BedCooldown) do
                if bedData.time > 0 then
                    bedData.time -= 1
                end
                if bedData.time <= 0 then
                    FinishedBed(playerId, bedData.bedIndex, bedData.hospital)
                end
            end
        end
    end
end)

AddEventHandler('esx:playerDropped', function(playerId)
	if BedCooldown[playerId] then
        local xPlayer = BedCooldown[playerId]
        if xPlayer.time > 0 then
            MySQL.update.await('UPDATE `cfx_keydi_bed` SET time = ? WHERE identifier = ?', {xPlayer.time, xPlayer.identifier})
            cachePlayersDropInBed[xPlayer.identifier] = {time = xPlayer.time, bedIndex = xPlayer.bedIndex, hospital = xPlayer.hospital}
        else
            MySQL.update.await('DELETE FROM `cfx_keydi_bed` WHERE identifier = ?', {xPlayer.identifier})
        end
        RegisteredBed[xPlayer.hospital][xPlayer.bedIndex].state = false
        print(('^0[^1cfx-keydi-ambulance^0] [%s]: ^2Saved Bed'):format(xPlayer.identifier))
        cacheBedData[xPlayer.bedIndex] = nil
        BedCooldown[playerId] = nil
    end
    cacheCheckedPlayers[playerId] = nil
end)


RegisterNetEvent('cfx-keydi-ambulance:checkBed', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    if cacheCheckedPlayers[xPlayer.source] then return end
    if cachePlayersDropInBed[xPlayer.identifier] and cachePlayersDropInBed[xPlayer.identifier].time > 0 then
        local data = cachePlayersDropInBed[xPlayer.identifier]
        if RegisteredBed[data.hospital][data.bedIndex] and RegisteredBed[data.hospital][data.bedIndex].state then
            SetPlayerRoutingBucket(xPlayer.source, src)
        end
        BedCooldown[xPlayer.source] = {time = data.time, bedIndex = data.bedIndex, identifier = xPlayer.identifier, hospital = data.hospital}
        cacheBedData[data.bedIndex] = {identifier = xPlayer.identifier, playerId = xPlayer.source}
        TriggerClientEvent('cfx-keydi-ambulance:syncBed', xPlayer.source, data.time, data.bedIndex, data.hospital)
        cachePlayersDropInBed[xPlayer.identifier] = nil
    end
    cacheCheckedPlayers[xPlayer.source] = true
end)