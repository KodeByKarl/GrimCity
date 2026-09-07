local ESX = exports['es_extended']:getSharedObject()

local function isSheriffBoss(xPlayer)
    if not xPlayer or not xPlayer.job then return false end
    if xPlayer.job.name ~= (ConfigSheriff.Job or 'sheriff') then return false end
    local need = ConfigSheriff.CallsignBossGradeName or 'boss'
    return xPlayer.job.grade_name == need
end

lib.addCommand('givescs', {
    help = 'Set sheriff callsign',
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Sheriff Server ID',
        },
        {
            name = 'callsign',
            type = 'string',
            help = 'Sheriff Callsign',
        },
    },
}, function(source, args)
    local src = source
    local xTarget = ESX.GetPlayerFromId(args.target)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xTarget or not xPlayer then return end

    if not isSheriffBoss(xPlayer) then
        TriggerClientEvent('esx:Notify', src, 'SHERIFF', 'Only the Sheriff boss can set callsigns.', 'error', 5000)
        return
    end

    xTarget.setMeta('callsign', args.callsign)
    TriggerClientEvent('esx:Notify', src, 'SHERIFF',
        ('You set %s callsign to %s'):format(xTarget.name, args.callsign), 'success', 5000)
end)

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    if GetResourceState('kodebykarl-police') ~= 'started' then
        print('^1[kodebykarl-sheriff]^7 kodebykarl-police must be started (F6 LEO menu / cuffs).')
    else
        print('^2[kodebykarl-sheriff]^7 BCSO online — scoreboard job `sheriff`, priority bag `rb_prio_sheriff`.')
    end
end)

exports('GetJobName', function()
    return ConfigSheriff.Job or 'sheriff'
end)

exports('GetOffDutyJobName', function()
    return ConfigSheriff.OffDutyJob or 'offsheriff'
end)
