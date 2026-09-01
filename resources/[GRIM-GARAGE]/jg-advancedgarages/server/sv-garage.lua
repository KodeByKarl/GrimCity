-- FiveM Advanced Garage System - Deobfuscated
-- Server-side garage management functions

local function getPlayerIdentifierForGarage(playerId, garageId, garageLocations)
    local playerIdentifier = Framework.Server.GetPlayerIdentifier(playerId)
    local playerJob = Framework.Server.GetPlayerJob(playerId)
    local playerGang = nil
    
    -- Check if ESX with custom gang integration
    if Config.Framework == "ESX" and Config.GangEnableCustomESXIntegration then
        playerGang = Framework.Server.GetPlayerGang(playerId)
    end
    
    debugPrint("Player Identifier", "debug", playerIdentifier)
    debugPrint("Player Gang", "debug", playerGang)
    debugPrint("Player Job", "debug", playerJob)
    
    -- Get garage locations if not provided
    local availableGarages = garageLocations or getPlayerAvailableGarageLocations(playerId)
    local garageData = availableGarages and availableGarages[garageId]
    
    if not garageData then
        return playerIdentifier
    end
    
    -- Check if this is a job garage with non-personal vehicles
    if playerJob and garageData.garageType == "job" and garageData.vehiclesType ~= "personal" then
        playerIdentifier = playerJob.name
    end
    
    -- Check if this is a gang garage with non-personal vehicles
    if playerGang and garageData.garageType == "gang" and garageData.vehiclesType ~= "personal" then
        playerIdentifier = playerGang.name
    end
    
    return playerIdentifier
end

function getVehicleData(playerId, modelName, plateNumber, garageId, ownerIdentifier)
    local vehicleData = nil
    
    -- If no garage specified, get vehicle without identifier check
    if not garageId then
        vehicleData = MySQL.prepare.await(
            Framework.Queries.GetVehicleNoIdentifier:format(Framework.VehiclesTable),
            {plateNumber}
        ) or false
    else
        local availableGarages = getPlayerAvailableGarageLocations(playerId)
        local garageData = availableGarages and availableGarages[garageId]
        local playerJob = Framework.Server.GetPlayerJob(playerId)
        local playerIdentifier = Framework.Server.GetPlayerIdentifier(playerId)
        
        if garageData and garageData.garageType == "job" and playerJob then
            vehicleData = MySQL.prepare.await(
                ("SELECT * FROM %s WHERE (%s = ? OR %s = ?) AND plate = ?"):format(
                    Framework.VehiclesTable,
                    Framework.PlayerIdentifier,
                    Framework.PlayerIdentifier
                ),
                {playerJob.name, playerIdentifier, plateNumber}
            )
        else
            -- Get owner identifier if not provided
            if not ownerIdentifier then
                ownerIdentifier = getPlayerIdentifierForGarage(playerId, garageId)
            end
            
            vehicleData = MySQL.prepare.await(
                Framework.Queries.GetVehicle:format(Framework.VehiclesTable, Framework.PlayerIdentifier),
                {ownerIdentifier, plateNumber}
            )
        end
    end
    
    if not vehicleData then
        debugPrint("Vehicle data is nil", "warning", plateNumber)
        return false
    end
    
    -- Set default ID if missing
    vehicleData.id = vehicleData.id or 0
    
    -- Get vehicle model and hash
    vehicleData.model = Framework.Server.GetModelColumn(vehicleData)
    vehicleData.hash = convertModelToHash(vehicleData.model)
    
    -- Validate model if specified and config enabled
    if modelName and Config.CheckVehicleModel then
        if vehicleData.model ~= modelName and vehicleData.hash ~= joaat(modelName) then
            debugPrint("Plate has been found, but model does not match the one in the DB", "warning")
            return false
        end
    end
    
    return vehicleData
end

-- Register callback for getting vehicle data
lib.callback.register("jg-advancedgarages:server:get-vehicle", function(playerId, modelName, plateNumber, garageId)
    return getVehicleData(playerId, modelName, plateNumber, garageId)
end)

-- Get all vehicles in a specific garage
lib.callback.register("jg-advancedgarages:server:get-garage-vehicles", function(playerId, garageId)
    local playerIdentifier = Framework.Server.GetPlayerIdentifier(playerId)
    
    if not playerIdentifier then
        debugPrint("Player identifier is nil", "warning")
        return {}
    end
    
    local vehicles = {}
    local playerJob = Framework.Server.GetPlayerJob(playerId)
    local playerGang = nil
    
    -- Get player gang if ESX with custom integration
    if Config.Framework == "ESX" and Config.GangEnableCustomESXIntegration then
        playerGang = Framework.Server.GetPlayerGang(playerId)
    end
    
    debugPrint("Player Identifier", "debug", playerIdentifier)
    debugPrint("Player Gang", "debug", playerGang)
    debugPrint("Player Job", "debug", playerJob)
    
    -- Get available garage locations for player
    local availableGarages = getPlayerAvailableGarageLocations(playerId)
    local garageData = availableGarages and availableGarages[garageId]
    
    -- Set default garage data if not found
    if not garageData then
        garageData = {
            garageType = "personal",
            checkVehicleGarageId = Config.GarageUniqueLocations,
            enableInteriors = Config.PrivGarageEnableInteriors
        }
    end
    
    -- Handle job garages
    if playerJob and garageData.garageType == "job" and garageData.vehiclesType ~= "personal" then
        if garageData.vehiclesType == "owned" then
            -- Get job-owned vehicles (both society-owned and personal-owned job vehicles)
            vehicles = MySQL.rawExecute.await(
                ("SELECT * FROM %s WHERE (%s = ? OR %s = ?) AND job_vehicle = 1 AND job_vehicle_rank <= ?"):format(
                    Framework.VehiclesTable,
                    Framework.PlayerIdentifier,
                    Framework.PlayerIdentifier
                ),
                {playerJob.name, playerIdentifier, playerJob.grade or 0}
            ) or {}
        elseif garageData.vehiclesType == "spawner" and garageData.vehicles then
            -- Add spawner vehicles
            for spawnerIndex, vehicleConfig in ipairs(garageData.vehicles) do
                vehicleConfig.spawnerModel = vehicleConfig.model
                vehicleConfig.spawnerIndex = spawnerIndex
                vehicleConfig.spawner = true
                vehicles[#vehicles + 1] = vehicleConfig
            end
        end
    -- Handle gang garages
    elseif playerGang and garageData.garageType == "gang" and garageData.vehiclesType ~= "personal" then
        if garageData.vehiclesType == "owned" then
            -- Get gang-owned vehicles
            vehicles = MySQL.rawExecute.await(
                Framework.Queries.GetGangVehicles:format(Framework.VehiclesTable, Framework.PlayerIdentifier),
                {playerGang.name, playerGang.grade or 0}
            ) or {}
        elseif garageData.vehiclesType == "spawner" and garageData.vehicles then
            -- Add spawner vehicles
            for spawnerIndex, vehicleConfig in ipairs(garageData.vehicles) do
                vehicleConfig.spawnerModel = vehicleConfig.model
                vehicleConfig.spawnerIndex = spawnerIndex
                vehicleConfig.spawner = true
                vehicles[#vehicles + 1] = vehicleConfig
            end
        end
    -- Handle impound
    elseif garageData.garageType == "impound" then
        if garageData.hasImpoundJob then
            -- Impound job can see all vehicles
            vehicles = MySQL.rawExecute.await(
                Framework.Queries.GetImpoundVehiclesWhitelist:format(Framework.VehiclesTable),
                {garageId}
            ) or {}
        else
            -- Public impound - only player's vehicles
            local jobName = playerJob and playerJob.name or "-"
            local gangName = playerGang and playerGang.name or "-"
            
            vehicles = MySQL.rawExecute.await(
                Framework.Queries.GetImpoundVehiclesPublic:format(
                    Framework.VehiclesTable, 
                    Framework.PlayerIdentifier, 
                    Framework.PlayerIdentifier, 
                    Framework.PlayerIdentifier
                ),
                {garageId, playerIdentifier, jobName, gangName}
            ) or {}
        end
    else
        -- Regular personal garage
        vehicles = MySQL.rawExecute.await(
            Framework.Queries.GetVehicles:format(Framework.VehiclesTable, Framework.PlayerIdentifier),
            {playerIdentifier}
        ) or {}
    end
    
    -- Process vehicles for client
    local processedVehicles = {}
    
    for vehicleIndex, vehicleData in ipairs(vehicles) do
        local model = vehicleData.spawnerModel or Framework.Server.GetModelColumn(vehicleData)
        
        if model then
            -- Decode vehicle properties
            local vehicleProps = false
            if vehicleData[Framework.VehProps] then
                vehicleProps = json.decode(vehicleData[Framework.VehProps] or "{}") or false
            end
            
            -- Check grade requirements
            local hasJobGrade = true
            local hasGangGrade = true
            
            if vehicleData.minJobGrade and playerJob then
                hasJobGrade = (playerJob.grade >= vehicleData.minJobGrade)
            elseif vehicleData.minJobGrade and not playerJob then
                hasJobGrade = false
            end
            
            if vehicleData.minGangGrade and playerGang then
                hasGangGrade = (playerGang.grade >= vehicleData.minGangGrade)
            elseif vehicleData.minGangGrade and not playerGang then
                hasGangGrade = false
            end
            
            if hasJobGrade and hasGangGrade then
                local processedVehicle = {
                    id = vehicleIndex,
                    hash = convertModelToHash(model),
                    model = model,
                    props = vehicleProps,
                    nickname = vehicleData.nickname or false,
                    plate = vehicleData.plate or false,
                    blacklisted = model and isVehicleTransferBlacklisted(model) or false,
                    impound = vehicleData.impound == 1,
                    impoundRetrievable = vehicleData.impound_retrievable == 1,
                    impoundData = vehicleData.impound_data,
                    mileage = vehicleData.mileage,
                    needsServicing = vehicleProps and doesVehicleNeedServicing(vehicleProps) or false,
                    garageId = vehicleData.garage_id,
                    inGarage = (vehicleData.in_garage == 1) or false,
                    isSpawned = not garageData.infiniteSpawns and isVehicleSpawned(vehicleData.plate),
                    fuel = vehicleData.fuel or 100.0,
                    engine = vehicleData.engine or 1000.0,
                    body = vehicleData.body or 1000.0,
                    financed = vehicleData.financed == 1,
                    financeData = (vehicleData.financed == 1) and json.decode(vehicleData.finance_data or "{}") or false,
                    spawnerIndex = vehicleData.spawnerIndex or false
                }
                
                processedVehicles[#processedVehicles + 1] = processedVehicle
            end
        end
    end
    
    return processedVehicles
end)

-- Store vehicle in garage
lib.callback.register("jg-advancedgarages:server:store-vehicle", function(playerId, garageId, networkId, plateNumber, vehicleProps, fuelLevel, bodyHealth, engineHealth, damageData)
    -- Get garage data
    local availableGarages = getPlayerAvailableGarageLocations(playerId)
    local garageData = availableGarages and availableGarages[garageId]
    
    -- Don't persist spawner vehicles, but still despawn them so they can be put away
    if garageData and garageData.vehiclesType == "spawner" then
        lib.callback.await("jg-advancedgarages:client:leave-vehicle", playerId, networkId, garageData.type)
        deleteVehicle(NetworkGetEntityFromNetworkId(networkId), networkId, plateNumber)
        return true
    end
    
    -- Get player identifier
    local playerIdentifier = Framework.Server.GetPlayerIdentifier(playerId)
    
    -- Determine owner based on garage type
    if garageData then
        if garageData.garageType ~= "impound" then
            if garageData.garageType == "job" and garageData.vehiclesType ~= "personal" then
                playerIdentifier = garageData.job
            elseif garageData.garageType == "gang" and garageData.vehiclesType ~= "personal" then
                playerIdentifier = garageData.gang
            end
        else
            return false
        end
    end
    
    -- Remove from outside vehicles tracker
    Globals.OutsideVehicles[plateNumber] = nil
    
    -- Disable Qbox persistence if needed
    if Config.Framework == "Qbox" then
        exports.qbx_core:DisablePersistence(NetworkGetEntityFromNetworkId(networkId))
    end
    
    debugPrint("Storing vehicle", "debug", 
        "Identifier:", playerIdentifier or nil,
        "Plate:", plateNumber or nil,
        "Engine:", engineHealth or nil,
        "Body:", bodyHealth or nil,
        "Fuel:", fuelLevel or nil,
        "Damage:", damageData or {}
    )
    
    local owners = {playerIdentifier}
    local playerJob = Framework.Server.GetPlayerJob(playerId)
    if playerJob and garageData and garageData.garageType == "job" then
        owners[#owners + 1] = playerJob.name
    end

    -- Update vehicle in database
    MySQL.update.await(
        Framework.Queries.StoreVehicle:format(Framework.VehiclesTable, Framework.PlayerIdentifier),
        {
            garageId,
            fuelLevel or 0,
            bodyHealth or 0,
            engineHealth or 0,
            damageData and json.encode(damageData) or nil,
            owners,
            plateNumber
        }
    )
    
    -- Send webhook notification
    sendWebhook(playerId, Webhooks.VehicleTakeOutAndInsert, "Vehicle stored in garage", "success", {
        {key = "Plate", value = plateNumber},
        {key = "Garage", value = garageId}
    })
    
    -- Save vehicle properties if enabled
    if Config.SaveVehiclePropsOnInsert and vehicleProps then
        MySQL.update.await(
            Framework.Queries.UpdateProps:format(Framework.VehiclesTable, Framework.VehProps),
            {json.encode(vehicleProps), plateNumber}
        )
    end
    
    -- Handle client-side vehicle exit
    lib.callback.await("jg-advancedgarages:client:leave-vehicle", playerId, networkId, garageData and garageData.type)
    
    -- Delete the vehicle
    deleteVehicle(NetworkGetEntityFromNetworkId(networkId), networkId, plateNumber)
    
    return true
end)

-- Drive vehicle out of garage
lib.callback.register("jg-advancedgarages:server:drive-vehicle-out", function(playerId, plateNumber, garageId, spawnerIndex, spawnCoords)
    local vehicleModel = nil
    local vehicleData = nil
    local vehicleConfig = nil
    
    -- Get available garages and player identifier
    local availableGarages = getPlayerAvailableGarageLocations(playerId)
    local ownerIdentifier = getPlayerIdentifierForGarage(playerId, garageId, availableGarages)
    local garageData = availableGarages and availableGarages[garageId]
    
    -- Check infinite spawns setting
    local allowInfiniteSpawns = (garageData and garageData.infiniteSpawns) or Config.AllowInfiniteVehicleSpawns
    local vehiclesType = garageData and garageData.vehiclesType
    
    -- Check if vehicle is already spawned (unless infinite spawns or spawner type)
    if not allowInfiniteSpawns and vehiclesType ~= "spawner" and plateNumber then
        if isVehicleSpawned(plateNumber) then
            Framework.Server.Notify(playerId, "Vehicle is already out", "error")
            return false
        end
    end
    
    -- Check distance to garage
    if garageData and garageData.coords then
        local maxDistance = math.max((garageData.distance or 3.0) * 3, 20.0)
        local playerCoords = GetEntityCoords(GetPlayerPed(playerId))
        local garageCoords = garageData.coords.xyz
        local distance = #(playerCoords - garageCoords)
        
        if distance > maxDistance then
            Framework.Server.Notify(playerId, "You are too far away from the garage", "error")
            return false
        end
    end
    
    -- Determine spawn coordinates
    local finalSpawnCoords = spawnCoords
    if garageData and garageData.spawn then
        finalSpawnCoords = findVehicleSpawnCoords(garageData.spawn) or finalSpawnCoords
    end
    
    if not finalSpawnCoords then
        local playerPed = GetPlayerPed(playerId)
        local playerPos = GetEntityCoords(playerPed)
        finalSpawnCoords = vector4(playerPos.x, playerPos.y, playerPos.z, GetEntityHeading(playerPed))
    end
    
    -- Handle spawner vehicles
    if vehiclesType == "spawner" then
        local spawnerVehicles = garageData and garageData.vehicles
        local spawnerVehicle = spawnerVehicles and spawnerVehicles[spawnerIndex]
        
        if not spawnerIndex or not spawnerVehicle then
            return false
        end
        
        vehicleModel = spawnerVehicle.model
        
        -- Handle empty plate
        if plateNumber == "" then
            plateNumber = false
        end
        
        -- Convert plate to uppercase
        if plateNumber then
            plateNumber = string.upper(plateNumber)
        end
        
        -- Set up vehicle properties
        local vehicleProps = {}
        if plateNumber then
            vehicleProps.plate = plateNumber
        end
        
        -- Add max mods if configured
        if spawnerVehicle.maxMods then
            vehicleProps.modEngine = 3
            vehicleProps.modBrakes = 2
            vehicleProps.modTransmission = 2
            vehicleProps.modSuspension = 3
            vehicleProps.modTurbo = true
        end
        
        vehicleConfig = {
            props = vehicleProps,
            fuel = 100.0,
            engine = 1000.0,
            body = 1000.0,
            damage = false,
            livery = spawnerVehicle.livery,
            extras = spawnerVehicle.extras,
            clean = true
        }
    else
        -- Handle regular owned vehicles
        if not plateNumber then
            return Framework.Server.Notify(playerId, "Vehicle plate is nil", "error")
        end
        
        vehicleData = getVehicleData(playerId, false, plateNumber, garageId, ownerIdentifier)
        
        if not vehicleData then
            Framework.Server.Notify(playerId, "Could not get the vehicle's data, see console", "error")
            print("^1[ERROR] Could not get vehicle data - plate does not exist on lookup, it does not belong to you or is corrupted?")
            return false
        end
        
        vehicleModel = vehicleData.model
        
        -- Decode vehicle properties
        local vehicleProps = false
        if vehicleData[Framework.VehProps] then
            vehicleProps = json.decode(vehicleData[Framework.VehProps]) or false
        end
        
        vehicleConfig = {
            props = vehicleProps,
            fuel = vehicleData.fuel or 100.0,
            engine = vehicleData.engine or 1000.0,
            body = vehicleData.body or 1000.0,
            damage = vehicleData.damage and json.decode(vehicleData.damage) or false
        }
    end
    
    -- Verify with client before spawning
    local clientVerification = lib.callback.await("jg-advancedgarages:client:takeout-vehicle-verification", 
        playerId, plateNumber, vehicleData or {}, garageId)
    
    if not clientVerification then
        debugPrint("jg-advancedgarages:client:takeout-vehicle-verification returned false", "debug")
        return false
    end
    
    -- Spawn vehicle if server-side spawning is enabled
    local networkId = nil
    if Config.SpawnVehiclesWithServerSetter then
        local shouldPutInVehicle = not Config.DoNotSpawnInsideVehicle
        
        networkId = spawnVehicleServer(
            playerId,
            vehicleData and vehicleData.id or 0,
            vehicleModel,
            plateNumber,
            finalSpawnCoords,
            shouldPutInVehicle,
            vehicleConfig,
            garageData and garageData.garageType
        )
        
        if not networkId then
            Framework.Server.Notify(playerId, "Could not spawn vehicle with Config.SpawnVehiclesWithServerSetter", "error")
            return false
        end
    end
    
    return true, networkId, vehicleModel, vehicleData, vehicleConfig, finalSpawnCoords
end)

-- Vehicle driven out callback
lib.callback.register("jg-advancedgarages:server:vehicle-driven-out", function(playerId, garageId, networkId, plateNumber, hasReturnCost)
    local ownerIdentifier = getPlayerIdentifierForGarage(playerId, garageId)
    
    -- Handle return cost if applicable
    if hasReturnCost then
        local success = Framework.Server.PlayerRemoveMoney(playerId, Config.GarageVehicleReturnCost, "bank")
        if not success then
            return false
        end
        
        -- Pay into society fund if configured
        if Config.GarageVehicleReturnCostSocietyFund then
            Framework.Server.PayIntoSocietyFund(Config.GarageVehicleReturnCostSocietyFund, Config.GarageVehicleReturnCost)
        end
    end
    
    -- Track outside vehicle
    Globals.OutsideVehicles[plateNumber] = networkId
    
    -- Enable Qbox persistence if needed
    if Config.Framework == "Qbox" then
        exports.qbx_core:EnablePersistence(NetworkGetEntityFromNetworkId(networkId))
    end
    
    -- Update database
    MySQL.update.await(
        Framework.Queries.VehicleDriveOut:format(Framework.VehiclesTable, Framework.PlayerIdentifier),
        {ownerIdentifier, plateNumber}
    )
    
    -- Clean up housing system garage if present
    if GetResourceState("jpr-housingsystem") == "started" then
        MySQL.query.await("DELETE FROM jpr_housingsystem_houses_garages WHERE plate = ?", {plateNumber})
    end
    
    -- Send webhook notification
    sendWebhook(playerId, Webhooks.VehicleTakeOutAndInsert, "Vehicle taken out of garage", "success", {
        {key = "Plate", value = plateNumber},
        {key = "Garage", value = garageId}
    })
    
    return true
end)

-- Transfer vehicle to another player
lib.callback.register("jg-advancedgarages:server:transfer-vehicle-to-player", function(playerId, plateNumber, garageId, targetPlayerId)
    -- Verify transfer with client
    local clientVerification = lib.callback.await("jg-advancedgarages:client:transfer-vehicle-verification", 
        playerId, targetPlayerId, plateNumber)
    
    if not clientVerification then
        return false
    end
    
    -- Get current owner identifier and target player identifier
    local currentOwner = getPlayerIdentifierForGarage(playerId, garageId)
    local targetIdentifier = Framework.Server.GetPlayerIdentifier(targetPlayerId)
    
    if not targetIdentifier then
        Framework.Server.Notify(playerId, Locale.playerNotOnlineError, "error")
        return false
    end
    
    -- Get target player name
    local targetPlayerInfo = Framework.Server.GetPlayerInfo(targetPlayerId)
    local targetPlayerName = targetPlayerInfo and targetPlayerInfo.name
    
    -- Update vehicle ownership in database
    MySQL.update.await(
        Framework.Queries.UpdatePlayerId:format(Framework.VehiclesTable, Framework.PlayerIdentifier, Framework.PlayerIdentifier),
        {targetIdentifier, currentOwner, plateNumber}
    )
    
    -- Clean up housing system garage if present
    if GetResourceState("jpr-housingsystem") == "started" then
        MySQL.query.await("DELETE FROM jpr_housingsystem_houses_garages WHERE plate = ?", {plateNumber})
    end
    
    -- Send webhook notification
    sendWebhook(playerId, Webhooks.VehiclePlayerTransfer, "Vehicle transferred to another player", "warning", {
        {key = "Plate", value = plateNumber},
        {key = "Recipient", value = targetPlayerName}
    })
    
    return true
end)

-- Transfer vehicle to another garage
lib.callback.register("jg-advancedgarages:server:transfer-vehicle-garage", function(playerId, plateNumber, sourceGarageId, targetGarageId, hasTransferCost)
    -- Verify transfer with client
    local clientVerification = lib.callback.await("jg-advancedgarages:client:transfer-garage-verification", 
        playerId, plateNumber, sourceGarageId, targetGarageId, plateNumber)
    
    if not clientVerification then
        return false
    end
    
    -- Get owner identifier
    local ownerIdentifier = getPlayerIdentifierForGarage(playerId, sourceGarageId)
    
    -- Check if target garage is valid
    local availableGarages = getPlayerAvailableGarageLocations(playerId)
    local targetGarageData = availableGarages and availableGarages[targetGarageId]
    
    if not targetGarageData and Config.DisableTransfersToUnregisteredGarages then
        Framework.Server.Notify(playerId, "Transfers to this garage are disabled, please contact an admin", "error")
        return false
    end
    
    -- Handle transfer cost
    if Config.GarageVehicleTransferCost then
        local success = Framework.Server.PlayerRemoveMoney(playerId, Config.GarageVehicleTransferCost, "bank")
        if not success then
            print("^1[ERROR] Could not remove player money. Attempted to remove amount:", Config.GarageVehicleTransferCost)
            return false
        end
    end
    
    -- Update vehicle garage in database
    MySQL.update.await(
        Framework.Queries.UpdateGarageId:format(Framework.VehiclesTable, Framework.PlayerIdentifier),
        {targetGarageId, ownerIdentifier, plateNumber}
    )
    
    -- Send webhook notification
    sendWebhook(playerId, Webhooks.VehicleGarageTransfer, "Vehicle transferred to another garage", "warning", {
        {key = "Plate", value = plateNumber},
        {key = "From Garage", value = sourceGarageId},
        {key = "To Garage", value = targetGarageId}
    })
    
    return true
end)

-- Set vehicle nickname
lib.callback.register("jg-advancedgarages:server:vehicle-set-nickname", function(playerId, plateNumber, nickname, garageId)
    local ownerIdentifier = getPlayerIdentifierForGarage(playerId, garageId)
    
    MySQL.update.await(
        Framework.Queries.UpdateVehicleNickname:format(Framework.VehiclesTable, Framework.PlayerIdentifier),
        {nickname, ownerIdentifier, plateNumber}
    )
    
    return true
end)

-- Export function for external resources
exports("getAllGarages", function()
    local garageList = {}
    local allGarages = getAllGaragesAndImpounds()
    
    for garageName, garageData in pairs(allGarages) do
        garageList[#garageList + 1] = {
            name = garageName,
            label = garageName,
            type = garageData.type,
            takeVehicle = garageData.coords,
            putVehicle = garageData.coords,
            spawnPoint = garageData.spawn,
            showBlip = not garageData.hideBlip,
            blipName = garageName,
            blipNumber = garageData.blip.id,
            blipColor = garageData.blip.color,
            vehicle = garageData.type
        }
    end
    
    return garageList
end)