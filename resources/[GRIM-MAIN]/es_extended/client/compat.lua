-- Compatibility layer using ox_lib and standard FiveM natives

ESX.Game.GetClosestEntity = function(entities, isPlayer, coords, modelFilter)
    return lib.getClosestPed(coords or GetEntityCoords(cache.ped))
end

EnumerateEntitiesWithinDistance = function(entities, isPlayer, coords, maxDistance)
    return {}
end

ESX.Game.Teleport = function(entity, coords, cb)
    if DoesEntityExist(entity) then
        RequestCollisionAtCoord(coords.x, coords.y, coords.z)
        SetEntityCoords(entity, coords.x, coords.y, coords.z, false, false, false, false)
        if coords.w or coords.heading then
            SetEntityHeading(entity, coords.w or coords.heading)
        end
        if cb then cb() end
    end
end

ESX.Streaming = {
    RequestModel = function(model, cb)
        return lib.requestModel(model, 5000)
    end,
    RequestStreamedTextureDict = function(textureDict, cb)
        return lib.requestStreamedTextureDict(textureDict, 5000)
    end,
    RequestNamedPtfxAsset = function(assetName, cb)
        return lib.requestNamedPtfxAsset(assetName, 5000)
    end,
    RequestAnimSet = function(animSet, cb)
        return lib.requestAnimSet(animSet, 5000)
    end,
    RequestAnimDict = function(animDict, cb)
        return lib.requestAnimDict(animDict, 5000)
    end,
    RequestWeaponAsset = function(weaponAsset, cb)
        return lib.requestWeaponAsset(weaponAsset, 5000)
    end,
}

ESX.Scaleform = {
    ShowFreemodeMessage = function(title, msg, sec) end,
    ShowBreakingNews = function(title, msg, bottom, sec) end,
    ShowPopupWarning = function(title, msg, bottom, sec) end,
    ShowTrafficMovie = function(sec) end,
    Utils = {
        RequestScaleformMovie = function(movie) end,
        RunMethod = function(movie, method, ...) end,
    },
}

ESX.CreatePointInternal = function(...) if lib and lib.points then return lib.points.new(...) end end
ESX.RemovePointInternal = function(...) end
ESX.HidePointInternal = function(...) end
StartPointsLoop = function(...) end
ESX.Point = {}

ESX.RegisterInteraction = function(...) end
ESX.RemoveInteraction = function(...) end
ESX.GetInteractKey = function(...) return 38 end

ESX.Game.GetPedMugshot = function(ped, transparent) end
ESX.Game.SpawnObject = function(model, coords, cb)
    local obj = CreateObject(joaat(model), coords.x, coords.y, coords.z, true, true, false)
    if cb then cb(obj) end
    return obj
end
ESX.Game.SpawnLocalObject = function(model, coords, cb)
    local obj = CreateObject(joaat(model), coords.x, coords.y, coords.z, false, true, false)
    if cb then cb(obj) end
    return obj
end
ESX.Game.DeleteVehicle = function(vehicle)
    if DoesEntityExist(vehicle) then
        DeleteEntity(vehicle)
    end
end
ESX.Game.DeleteObject = function(object)
    if DoesEntityExist(object) then
        DeleteEntity(object)
    end
end
ESX.Game.SpawnVehicle = function(model, coords, heading, cb)
    local modelHash = type(model) == 'number' and model or joaat(model)
    lib.requestModel(modelHash)
    local veh = CreateVehicle(modelHash, coords.x, coords.y, coords.z, heading or 0.0, true, false)
    if cb then cb(veh) end
    return veh
end
ESX.Game.SpawnLocalVehicle = function(model, coords, heading, cb)
    local modelHash = type(model) == 'number' and model or joaat(model)
    lib.requestModel(modelHash)
    local veh = CreateVehicle(modelHash, coords.x, coords.y, coords.z, heading or 0.0, false, false)
    if cb then cb(veh) end
    return veh
end
ESX.Game.IsVehicleEmpty = function(vehicle)
    return GetVehicleNumberOfPassengers(vehicle) == 0 and IsVehicleSeatFree(vehicle, -1)
end
ESX.Game.GetObjects = function() return GetGamePool('CObject') end
ESX.Game.GetPeds = function() return GetGamePool('CPed') end
ESX.Game.GetVehicles = function() return GetGamePool('CVehicle') end
ESX.Game.GetPlayers = function() return GetActivePlayers() end
ESX.Game.GetClosestObject = function(coords, modelFilter)
    return lib.getClosestObject(coords or GetEntityCoords(cache.ped), 10.0)
end
ESX.Game.GetClosestPed = function(coords, modelFilter)
    return lib.getClosestPed(coords or GetEntityCoords(cache.ped), 10.0)
end
ESX.Game.GetClosestPlayer = function(coords)
    return lib.getClosestPlayer(coords or GetEntityCoords(cache.ped), 10.0)
end
ESX.Game.GetClosestVehicle = function(coords, modelFilter)
    return lib.getClosestVehicle(coords or GetEntityCoords(cache.ped), 10.0)
end
ESX.Game.GetPlayersInArea = function(coords, maxDistance)
    return lib.getNearbyPlayers(coords or GetEntityCoords(cache.ped), maxDistance or 10.0)
end
ESX.Game.GetVehiclesInArea = function(coords, maxDistance)
    return lib.getNearbyVehicles(coords or GetEntityCoords(cache.ped), maxDistance or 10.0)
end
ESX.Game.IsSpawnPointClear = function(coords, radius)
    return #lib.getNearbyVehicles(coords, radius or 5.0) == 0
end
ESX.Game.GetVehicleInDirection = function()
    local ped = cache.ped or PlayerPedId()
    local coords = GetEntityCoords(ped)
    local forwardVector = GetEntityForwardVector(ped)
    local destination = coords + forwardVector * 5.0
    local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(coords.x, coords.y, coords.z, destination.x, destination.y, destination.z, 10, ped, 0)
    local _, hit, _, _, entityHit = GetShapeTestResult(rayHandle)
    if hit == 1 and IsEntityAVehicle(entityHit) then return entityHit end
    return nil
end
ESX.Game.GetVehicleProperties = function(vehicle)
    return lib.getVehicleProperties(vehicle)
end
ESX.Game.SetVehicleProperties = function(vehicle, props)
    return lib.setVehicleProperties(vehicle, props)
end

function ESX.RegisterInput(command_name, label, input_group, key, on_press, on_release)
    if lib and lib.addKeybind then
        return lib.addKeybind({
            name = command_name,
            description = label,
            defaultMapper = input_group,
            defaultKey = key,
            onPressed = on_press,
            onReleased = on_release
        })
    end
end
