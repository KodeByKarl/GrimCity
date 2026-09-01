local Config = require 'configs.whitelistedblips'

if not Config or not Config.Enabled then return end

local onDutyPlayers = {}

local function getJobGroup(jobName)
    if not jobName then return nil end
    for groupKey, jobConfig in pairs(Config.Jobs) do
        for _, name in ipairs(jobConfig.jobs) do
            if name == jobName then
                return groupKey, jobConfig
            end
        end
    end
    return nil
end

RegisterNetEvent('cfx-keydi-utils:whitelistedblips:update', function(coords, heading, vehState)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local jobName = xPlayer.job and xPlayer.job.name
    local groupKey, jobConfig = getJobGroup(jobName)
    if not groupKey then
        if onDutyPlayers[src] then
            onDutyPlayers[src] = nil
            TriggerClientEvent('cfx-keydi-utils:whitelistedblips:clear', src)
        end
        return
    end

    if type(coords) ~= 'vector3' and type(coords) ~= 'table' then return end

    local charName = (xPlayer.getName and xPlayer.getName()) or xPlayer.name or GetPlayerName(src) or ('ID %s'):format(src)

    onDutyPlayers[src] = {
        src = src,
        group = groupKey,
        label = jobConfig.label,
        color = jobConfig.color,
        defaultSprite = jobConfig.sprite,
        name = charName,
        coords = vector3(coords.x, coords.y, coords.z),
        heading = tonumber(heading) or 0.0,
        vehState = vehState or 'foot',
        lastUpdate = os.time(),
    }
end)

AddEventHandler('esx:setJob', function(source, job, lastJob)
    local src = source
    local groupKey = getJobGroup(job and job.name)
    if not groupKey then
        if onDutyPlayers[src] then
            onDutyPlayers[src] = nil
            TriggerClientEvent('cfx-keydi-utils:whitelistedblips:clear', src)
        end
    end
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    if onDutyPlayers[src] then
        onDutyPlayers[src] = nil
    end
end)

AddEventHandler('esx:playerDropped', function(source, reason)
    local src = source
    if onDutyPlayers[src] then
        onDutyPlayers[src] = nil
    end
end)

CreateThread(function()
    while true do
        Wait(Config.RefreshInterval or 1500)

        local now = os.time()
        for src, data in pairs(onDutyPlayers) do
            if not GetPlayerPing(src) or (now - data.lastUpdate > 10) then
                onDutyPlayers[src] = nil
            end
        end

        if next(onDutyPlayers) ~= nil then
            for targetSrc, targetData in pairs(onDutyPlayers) do
                local payload = {}
                for src, data in pairs(onDutyPlayers) do
                    if Config.ShareAll or data.group == targetData.group then
                        payload[#payload + 1] = {
                            src = src,
                            group = data.group,
                            label = data.label,
                            color = data.color,
                            defaultSprite = data.defaultSprite,
                            name = data.name,
                            coords = data.coords,
                            heading = data.heading,
                            vehState = data.vehState,
                        }
                    end
                end
                TriggerClientEvent('cfx-keydi-utils:whitelistedblips:sync', targetSrc, payload)
            end
        end
    end
end)
