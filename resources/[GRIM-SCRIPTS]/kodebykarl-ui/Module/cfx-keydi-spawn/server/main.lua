ESX = ESX or exports["es_extended"]:getSharedObject()

-- Server side handlers for cfx-keydi-spawn module
RegisterNetEvent("cfx-keydi-spawn:server:requestSpawnMenu", function(isDeathCam)
    local src = source
    TriggerClientEvent("cfx-keydi-spawn:client:open", src, isDeathCam)
end)

-- Command to open spawn selector for player (Admin / Test command)
ESX.RegisterCommand('spawnmenu', 'admin', function(xPlayer, args, showError)
    local target = args.target or xPlayer
    if target then
        TriggerClientEvent("cfx-keydi-spawn:client:open", target.source, false)
    end
end, true, {help = "Open Spawn Selector UI", arguments = {
    {name = 'target', help = 'Player ID (optional)', type = 'player'}
}})
