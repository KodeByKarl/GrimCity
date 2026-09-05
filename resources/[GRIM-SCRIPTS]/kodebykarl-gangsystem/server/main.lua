local function PatchXPlayer(xPlayer)
    if not xPlayer or xPlayer.__kbkGangPatched then return end
    xPlayer.__kbkGangPatched = true

    local originalGetGang = xPlayer.getGang
    xPlayer.getGang = function(self)
        local src = self.source
        local fromUs = GangMembership.GetPlayerGang(src)
        if fromUs then return fromSys end
        if originalGetGang then
            return originalGetGang(self)
        end
        return self.gang
    end
end

local function OnPlayerLoaded(playerId, xPlayer)
    xPlayer = xPlayer or ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end
    PatchXPlayer(xPlayer)
    GangMembership.LoadPlayer(playerId)
    -- Discord sync attempt (no-op until roles filled)
    GangDiscord.SyncPlayer(playerId)
end

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    GangMembership.EnsureTable()
    Wait(500)
    GangStashes.RegisterAll()
    GangDiscord.StartPollLoop()

    local players = ESX.GetExtendedPlayers and ESX.GetExtendedPlayers() or {}
    for _, xPlayer in pairs(players) do
        PatchXPlayer(xPlayer)
        GangMembership.LoadPlayer(xPlayer.source)
    end
end)

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    CreateThread(function()
        Wait(800)
        OnPlayerLoaded(playerId, xPlayer)
    end)
end)

AddEventHandler('playerDropped', function()
    GangMembership.UnloadPlayer(source)
end)

-- Admin helpers while Discord roles are still ""
lib.addCommand('ganghire', {
    help = 'Hire a player into a gang (admin)',
    params = {
        { name = 'id', type = 'playerId', help = 'Server id' },
        { name = 'gang', type = 'string', help = 'ballas|families|vagos|lostmc|marabunta' },
        { name = 'grade', type = 'number', help = '0-3', optional = true },
    },
    restricted = 'group.admin',
}, function(source, args)
    local ok, msg = GangMembership.Hire(args.id, args.gang, args.grade or 0, 'admin')
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'GANG',
        description = ok and ('Hire ok (%s)'):format(msg) or tostring(msg),
        type = ok and 'success' or 'error',
    })
end)

lib.addCommand('gangfire', {
    help = 'Fire a player from their gang (admin)',
    params = {
        { name = 'id', type = 'playerId', help = 'Server id' },
    },
    restricted = 'group.admin',
}, function(source, args)
    GangMembership.Fire(args.id, 'admin')
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'GANG',
        description = 'Player fired.',
        type = 'inform',
    })
end)

lib.addCommand('gangrefresh', {
    help = 'Force Discord gang sync for a player',
    params = {
        { name = 'id', type = 'playerId', help = 'Server id', optional = true },
    },
    restricted = 'group.admin',
}, function(source, args)
    local target = args.id or source
    GangDiscord.SyncPlayer(target, function(ok, reason)
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'GANG',
            description = ('Sync %s: %s'):format(ok and 'ok' or 'fail', tostring(reason)),
            type = ok and 'success' or 'error',
        })
    end)
end)

lib.addCommand('gangboss', {
    help = 'Set your grade to boss (admin test)',
    restricted = 'group.admin',
}, function(source)
    local gang = GangMembership.GetPlayerGang(source)
    if not gang then
        return TriggerClientEvent('ox_lib:notify', source, {
            title = 'GANG',
            description = 'Not in a gang. /ganghire first.',
            type = 'error',
        })
    end
    GangMembership.Hire(source, gang.name, 3, 'admin_boss')
end)
