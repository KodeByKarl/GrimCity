Framework = {}

local function getFramework()
    if Config.Framework ~= 'auto' then return Config.Framework end
    if GetResourceState('es_extended') == 'started' then return 'esx' end
    if GetResourceState('qb-core') == 'started' then return 'qbcore' end
    if GetResourceState('qbx-core') == 'started' then return 'qbx' end
    return 'esx'
end

Framework.Name = getFramework()

function Framework.GetPlayer(source)
    if Framework.Name == 'esx' then
        local ESX = exports['es_extended']:getSharedObject()
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return nil end
        return {
            identifier = xPlayer.identifier,
            name = xPlayer.getName(),
            job = xPlayer.job.name,
            grade = xPlayer.job.grade,
            onDuty = true -- ESX usually doesn't have duty system
        }
    elseif Framework.Name == 'qbcore' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return nil end
        local job = Player.PlayerData.job
        return {
            identifier = Player.PlayerData.citizenid,
            name = (Player.PlayerData.charinfo.firstname or '') .. ' ' .. (Player.PlayerData.charinfo.lastname or ''),
            job = job.name,
            grade = job.grade.level or job.grade,
            onDuty = job.onduty ~= false -- QBCore: true if not explicitly false
        }
    elseif Framework.Name == 'qbx' then
        local Player = exports['qbx-core']:GetPlayer(source)
        if not Player then return nil end
        local job = Player.PlayerData.job
        return {
            identifier = Player.PlayerData.citizenid,
            name = (Player.PlayerData.charinfo.firstname or '') .. ' ' .. (Player.PlayerData.charinfo.lastname or ''),
            job = job.name,
            grade = job.grade.level or job.grade,
            onDuty = job.onduty ~= false -- QBX: true if not explicitly false
        }
    end
    return nil
end

function Framework.AddItem(source, item, count, metadata)
    return Inventory.AddItem(source, item, count, metadata)
end

function Framework.RemoveItem(source, item, count)
    return Inventory.RemoveItem(source, item, count)
end

function Framework.HasJob(source, job)
    local player = Framework.GetPlayer(source)
    return player and player.job == job
end

function Framework.IsDirector(source)
    local player = Framework.GetPlayer(source)
    return player and player.job == 'school' and tonumber(player.grade) == 2 and (player.onDuty == nil or player.onDuty)
end