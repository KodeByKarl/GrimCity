ESX = ESX or exports["es_extended"]:getSharedObject()

-- Live player counts + per-player current location (Server Locations module)
ESX.RegisterServerCallback('cfx-keydi-modules:server:getServersData', function(source, cb)
    if ServerLocations and ServerLocations.GetServersData then
        cb(ServerLocations.GetServersData(source))
        return
    end
    cb({})
end)
