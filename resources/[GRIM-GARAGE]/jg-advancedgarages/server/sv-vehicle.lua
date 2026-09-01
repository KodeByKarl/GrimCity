-- Vehicle Management Server Script - Deobfuscated

-- Function to check if a vehicle needs servicing (integrates with jg-mechanic)
function doesVehicleNeedServicing(vehicleData)
    if not vehicleData then
        return false
    end
    
    -- Check if jg-mechanic resource is running
    local mechanicResourceState = GetResourceState("jg-mechanic")
    if mechanicResourceState ~= "started" then
        return false
    end
    
    -- Initialize mechanic config if not already done
    if not Globals.MechanicConfig then
        local configLoaded = pcall(function()
            Globals.MechanicConfig = exports["jg-mechanic"]:config()
        end)
        
        if not configLoaded then
            print("^3[WARNING] You are running jg-mechanic, but you need to be using v1.0.10 or newer to use it with Advanced Garages v3. Some functionality may not work as expected.")
        end
    end
    
    -- Check if vehicle servicing is enabled
    if not Globals.MechanicConfig or not Globals.MechanicConfig.EnableVehicleServicing then
        return false
    end
    
    -- Check if servicing data exists and is valid
    local servicingData = vehicleData.servicingData
    if not servicingData or type(servicingData) ~= "table" then
        return false
    end
    
    -- Check if any component is below the service threshold
    for componentName, componentValue in pairs(servicingData) do
        if componentValue <= Globals.MechanicConfig.ServiceRequiredThreshold then
            return true
        end
    end
    
    return false
end

-- Function to check if a vehicle model is blacklisted from player transfers
function isVehicleTransferBlacklisted(vehicleModel)
    if not Config.PlayerTransferBlacklist then
        return false
    end
    
    local vehicleHash = convertModelToHash(vehicleModel)
    
    for _, blacklistedModel in pairs(Config.PlayerTransferBlacklist) do
        local blacklistedHash = joaat(blacklistedModel)
        if vehicleHash == blacklistedHash then
            return true
        end
    end
    
    return false
end

-- Function to check if a vehicle is currently spawned in the world
function isVehicleSpawned(vehiclePlate)
    if not vehiclePlate or vehiclePlate == "" then
        return false
    end
    
    -- Check with AdvancedParking if available
    local advancedParkingState = GetResourceState("AdvancedParking")
    if advancedParkingState == "started" then
        local vehiclePosition = exports.AdvancedParking:GetVehiclePosition(vehiclePlate)
        if vehiclePosition then
            return true
        end
    end
    
    -- Check in our outside vehicles tracking
    local vehicleNetworkId = Globals.OutsideVehicles[vehiclePlate]
    if not vehicleNetworkId then
        return false
    end
    
    local vehicleEntity = NetworkGetEntityFromNetworkId(vehicleNetworkId)
    if DoesEntityExist(vehicleEntity) then
        local engineHealth = GetVehicleEngineHealth(vehicleEntity)
        if engineHealth > -3999 then
            return true
        end
    end
    
    return false
end

-- Function to delete an outside vehicle by plate
function deleteOutsideVehicle(vehiclePlate)
    local vehicleNetworkId = Globals.OutsideVehicles[vehiclePlate]
    if not vehicleNetworkId then
        return
    end
    
    local vehicleEntity = NetworkGetEntityFromNetworkId(vehicleNetworkId)
    if DoesEntityExist(vehicleEntity) then
        -- Safety check 1: Never delete if an online player is inside the vehicle
        for _, playerId in ipairs(GetPlayers()) do
            local ped = GetPlayerPed(playerId)
            if ped ~= 0 and DoesEntityExist(ped) and GetVehiclePedIsIn(ped, false) == vehicleEntity then
                return
            end
        end

        -- Safety check 2: Never delete if vehicle is currently in a mechanic customization menu or servicing
        local state = Entity(vehicleEntity).state
        if state and (state.inMechanicMenu or state.isMechanicServicing or state.isUndergoingUpgrade) then
            return
        end
    end

    deleteVehicle(vehicleEntity, vehicleNetworkId, vehiclePlate)
end

-- Export the delete function
exports("deleteOutsideVehicle", deleteOutsideVehicle)

-- Function to register a vehicle as being outside (spawned in world)
function registerVehicleOutside(vehiclePlate, vehicleNetworkId)
    Globals.OutsideVehicles[vehiclePlate] = vehicleNetworkId
end

-- Export the register function
exports("registerVehicleOutside", registerVehicleOutside)

-- Function to update a vehicle's license plate
function updateVehiclePlate(playerId, oldPlate, newPlate)
    -- Verify player is in a vehicle
    local playerPed = GetPlayerPed(playerId)
    local currentVehicle = GetVehiclePedIsIn(playerPed, false)
    
    if not currentVehicle then
        Framework.Server.Notify(playerId, Locale.notInsideVehicleError, "error")
        return false
    end
    
    -- Get current vehicle plate and verify it matches
    local currentPlate = Framework.Server.GetPlate(currentVehicle)
    if currentPlate ~= oldPlate then
        debugPrint("Framework.Server.GetPlate does not match with original plate", "warning", 
                  Framework.Server.GetPlate(currentVehicle), oldPlate)
        return false
    end
    
    -- Check if new plate already exists
    local plateExistsQuery = Framework.Queries.GetVehiclePlateOnly:format(Framework.VehiclesTable)
    local plateExists = MySQL.scalar.await(plateExistsQuery, {newPlate})
    
    if plateExists then
        Framework.Server.Notify(playerId, Locale.vehiclePlateExistsError, "error")
        return false
    end
    
    -- Get current vehicle data
    local vehicleData = getVehicleData(playerId, false, oldPlate)
    if not vehicleData then
        print("^1Error: could not get vehicle data before plate change")
        return false
    end
    
    -- Get and update vehicle properties
    local vehicleProps = vehicleData[Framework.VehProps]
    if vehicleProps then
        vehicleProps = json.decode(vehicleData[Framework.VehProps])
    end
    
    if not vehicleProps then
        print("^1Error: could not get props before plate change")
        return false
    end
    
    -- Update plate in properties
    vehicleProps.plate = newPlate
    
    -- Update database with new plate and properties
    local updateQuery = Framework.Queries.UpdateVehiclePlate:format(Framework.VehiclesTable, Framework.VehProps)
    MySQL.update.await(updateQuery, {
        newPlate,
        json.encode(vehicleProps),
        oldPlate
    })
    
    -- Notify jg-mechanic of plate change if available
    local mechanicResourceState = GetResourceState("jg-mechanic")
    if mechanicResourceState == "started" then
        local mechanicNotified = pcall(function()
            exports["jg-mechanic"]:vehiclePlateUpdated(oldPlate, newPlate)
        end)
        
        if not mechanicNotified then
            print("^1[WARNING] Update jg-mechanic to v1.0.11 or newer as it needs to update internal data to the updated plate!")
        end
    end
    
    -- Notify player of success
    local successMessage = string.gsub(Locale.vehiclePlateUpdateSuccess, "%%{value}", newPlate)
    Framework.Server.Notify(playerId, successMessage, "success")
    
    return true
end

-- Function to delete a vehicle from database and world
function deleteVehicleFromDB(playerId)
    -- Verify player is in a vehicle
    local playerPed = GetPlayerPed(playerId)
    local currentVehicle = GetVehiclePedIsIn(playerPed, false)
    
    if not currentVehicle then
        Framework.Server.Notify(playerId, Locale.notInsideVehicleError, "error")
        return
    end
    
    -- Get vehicle plate
    local vehiclePlate = Framework.Server.GetPlate(currentVehicle)
    if not vehiclePlate then
        return
    end
    
    -- Verify player owns the vehicle
    local vehicleData = getVehicleData(playerId, false, vehiclePlate)
    if not vehicleData then
        Framework.Server.Notify(playerId, Locale.vehicleNotOwnedByPlayerError, "error")
        return
    end
    
    -- Delete from database
    local deleteQuery = Framework.Queries.DeleteVehicle:format(Framework.VehiclesTable)
    MySQL.query.await(deleteQuery, {vehiclePlate})
    
    -- Delete physical vehicle
    deleteVehicle(currentVehicle)
    
    -- Notify success
    local successMessage = string.gsub(Locale.vehicleDeletedSuccess, "%%{value}", vehiclePlate)
    Framework.Server.Notify(playerId, successMessage, "success")
end

-- Function to return a vehicle to garage (from outside world)
function returnVehicleToGarage(playerId, vehiclePlate)
    vehiclePlate = vehiclePlate:upper()
    
    -- Verify player owns the vehicle
    if vehiclePlate then
        local vehicleData = getVehicleData(playerId, false, vehiclePlate)
        if not vehicleData then
            Framework.Server.Notify(playerId, Locale.vehicleNotOwnedByPlayerError, "error")
            return false
        end
    end
    
    -- Check if vehicle is spawned outside
    local vehicleNetworkId = Globals.OutsideVehicles[vehiclePlate]
    if not vehicleNetworkId then
        Framework.Server.Notify(playerId, Locale.vehicleParkedSuccess, "error")
        return true
    end
    
    -- Delete the spawned vehicle
    local vehicleEntity = NetworkGetEntityFromNetworkId(vehicleNetworkId)
    deleteVehicle(vehicleEntity)
    
    -- Remove from outside vehicles tracking
    Globals.OutsideVehicles[vehiclePlate] = nil
    
    -- Update database to mark as in garage
    local setInGarageQuery = Framework.Queries.SetInGarage:format(Framework.VehiclesTable)
    MySQL.update.await(setInGarageQuery, {vehiclePlate})
    
    -- Notify success
    Framework.Server.Notify(playerId, Locale.vehicleImpoundReturnedToOwnerSuccess, "success")
end

-- Register network events for vehicle tracking
RegisterNetEvent("jg-advancedgarages:server:register-vehicle-outside", registerVehicleOutside)
RegisterNetEvent("jg-advancedgarages:server:RegisterVehicleOutside", registerVehicleOutside)

-- Register callback for plate updates (admin only)
lib.callback.register("jg-advancedgarages:server:vehicle-update-plate", function(playerId, oldPlate, newPlate)
    local isAdmin = Framework.Server.IsAdmin(playerId)
    if not isAdmin then
        debugPrint("Framework.Server.IsAdmin", "warning", "Returned false")
        return false
    end
    
    return updateVehiclePlate(playerId, oldPlate, newPlate)
end)

-- Command to change vehicle plate (admin only)
lib.addCommand(Config.ChangeVehiclePlate or "vplate", false, function(playerId)
    local isAdmin = Framework.Server.IsAdmin(playerId)
    if not isAdmin then
        return Framework.Server.Notify(playerId, "INSUFFICIENT_PERMISSIONS", "error")
    end
    
    TriggerClientEvent("jg-advancedgarages:client:show-vplate-form", playerId)
end)

-- Command to delete vehicle from database (admin only)
lib.addCommand(Config.DeleteVehicleFromDB or "dvdb", {
    help = Locale.cmdDeleteVeh
}, function(playerId)
    local isAdmin = Framework.Server.IsAdmin(playerId)
    if not isAdmin then
        return Framework.Server.Notify(playerId, "INSUFFICIENT_PERMISSIONS", "error")
    end
    
    deleteVehicleFromDB(playerId)
end)

-- Command to return vehicle to garage (admin only)
lib.addCommand(Config.ReturnVehicleToGarage or "vreturn", {
    help = "Return vehicle back to garage (admin only)",
    params = {}
}, function(playerId, args)
    local isAdmin = Framework.Server.IsAdmin(playerId)
    if not isAdmin then
        return Framework.Server.Notify(playerId, "INSUFFICIENT_PERMISSIONS", "error")
    end
    
    local vehiclePlate = table.concat(args, " ")
    returnVehicleToGarage(playerId, vehiclePlate)
end)

-- Handle Qbox vehicle persistence integration
if Config.Framework == "Qbox" then
    local vehiclePersistenceEnabled = GetConvar("qbx:enableVehiclePersistence", "false")
    if vehiclePersistenceEnabled == "true" then
        -- Track vehicle network ID changes for persistence
        AddStateBagChangeHandler("vehicleid", "", function(bagName, key, value)
            if not value or value == 0 then
                return
            end
            
            local vehicleEntity = GetEntityFromStateBagName(bagName)
            if vehicleEntity == 0 then
                return
            end
            
            local vehiclePlate = Framework.Server.GetPlate(vehicleEntity)
            if not vehiclePlate then
                return
            end
            
            -- Update our tracking if this vehicle is registered as outside
            if not Globals.OutsideVehicles[vehiclePlate] then
                return
            end
            
            local newNetworkId = NetworkGetNetworkIdFromEntity(vehicleEntity)
            Globals.OutsideVehicles[vehiclePlate] = newNetworkId
            
            lib.print.info("[Qbox Persistence Tracker] vehicle", value, "updated to netId", newNetworkId)
        end)
    end
end