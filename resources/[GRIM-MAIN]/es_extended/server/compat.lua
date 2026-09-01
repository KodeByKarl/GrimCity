-- Standalone OneSync compatibility functions for ESX Core

ESX.OneSync = ESX.OneSync or {}

function ESX.OneSync.GetPlayersInArea(coords, maxDistance)
    local players = {}
    local peds = GetActivePlayers()
    for i = 1, #peds do
        local targetPed = GetPlayerPed(peds[i])
        local targetCoords = GetEntityCoords(targetPed)
        if #(coords - targetCoords) <= (maxDistance or 5.0) then
            table.insert(players, { id = peds[i], ped = targetPed, coords = targetCoords })
        end
    end
    return players
end

function ESX.OneSync.GetClosestPlayer(coords, maxDistance)
    local closestPlayer, closestDistance = nil, maxDistance or 1000.0
    local peds = GetActivePlayers()
    for i = 1, #peds do
        local targetPed = GetPlayerPed(peds[i])
        local targetCoords = GetEntityCoords(targetPed)
        local dist = #(coords - targetCoords)
        if dist < closestDistance then
            closestPlayer = peds[i]
            closestDistance = dist
        end
    end
    return closestPlayer, closestDistance
end

function ESX.OneSync.GetPedsInArea(coords, maxDistance)
    return {}
end

function ESX.OneSync.GetObjectsInArea(coords, maxDistance)
    return {}
end

function ESX.OneSync.GetVehiclesInArea(coords, maxDistance)
    return {}
end

function ESX.OneSync.GetClosestPed(coords, maxDistance)
    return nil
end

function ESX.OneSync.GetClosestObject(coords, maxDistance)
    return nil
end

function ESX.OneSync.GetClosestVehicle(coords, maxDistance)
    return nil
end
