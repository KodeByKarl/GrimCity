local ESX = exports["es_extended"]:getSharedObject()
local isImpounding = false

local function NormalizePlate(plate)
    if not plate or type(plate) ~= "string" then return nil end
    local trimmed = string.gsub(plate, "^%s*(.-)%s*$", "%1")
    return trimmed ~= "" and trimmed or nil
end

--- Check if coordinates fall within any configured mechanic exclusion zone or car lift
local function IsVehicleInMechanicZone(coords)
    if not ConfigImpound.ProtectMechanicZones or not coords then return false end

    -- 1. Check configured mechanic exclusion zones
    if ConfigImpound.MechanicExclusionZones then
        for _, zone in ipairs(ConfigImpound.MechanicExclusionZones) do
            if zone.coords and #(coords - zone.coords) <= (zone.radius or 35.0) then
                return true, zone.name or "Mechanic Zone"
            end
        end
    end

    -- 2. Check active car lifts from jg-mechanic GlobalState
    if GlobalState.carLiftsData then
        for _, lifts in pairs(GlobalState.carLiftsData) do
            if type(lifts) == "table" then
                for _, lift in ipairs(lifts) do
                    if lift.coords then
                        local liftPos = vector3(lift.coords.x, lift.coords.y, lift.coords.z)
                        if #(coords - liftPos) <= 8.0 then
                            return true, "Car Lift"
                        end
                    end
                end
            end
        end
    end

    return false
end

--- Check if a vehicle is currently undergoing tuning, previewing mods, or in a mechanic session
local function IsVehicleUndergoingUpgrade(vehicle, rawPlate)
    if not vehicle or not DoesEntityExist(vehicle) then return false end

    local state = Entity(vehicle).state
    if state then
        if state.inMechanicMenu then return true end
        if state.isMechanicServicing then return true end
        if state.isUndergoingUpgrade then return true end
        if state.tabletConnectedVehicle then return true end
        if state.dynoRunning then return true end
        if state.unpaidModifications then return true end
    end

    local previewPlate = ConfigImpound.PreviewPlateName or "PREVIEW"
    if rawPlate and string.find(rawPlate:upper(), previewPlate:upper(), 1, true) then
        return true
    end

    return false
end

--- Resolves the true database license plate of a vehicle even if altered by preview/tuning
local function GetRealPlateForVehicle(vehicle, rawPlate)
    if vehicle and DoesEntityExist(vehicle) then
        local state = Entity(vehicle).state
        if state then
            if state.realPlate and type(state.realPlate) == "string" and state.realPlate ~= "" then
                return state.realPlate
            end
            if state.originalPlate and type(state.originalPlate) == "string" and state.originalPlate ~= "" then
                return state.originalPlate
            end
            if type(state.inMechanicMenu) == "table" and state.inMechanicMenu.originalPlate then
                return state.inMechanicMenu.originalPlate
            end
        end
    end

    return rawPlate
end

local function CleanUnoccupiedVehicles()
    local vehicles = GetAllVehicles()
    local cleanedCount = 0
    local protectedCount = 0
    local occupiedPlates = {}
    local platesToStore = {}
    local occupiedVehicles = {}

    -- 1. Scan ALL online players to find all currently occupied vehicles with 100% reliability
    for _, playerId in ipairs(GetPlayers()) do
        local ped = GetPlayerPed(playerId)
        if ped and ped ~= 0 and DoesEntityExist(ped) then
            local veh = GetVehiclePedIsIn(ped, false)
            if veh and veh ~= 0 and DoesEntityExist(veh) then
                occupiedVehicles[veh] = true
                local rawP = GetVehicleNumberPlateText(veh)
                local realP = GetRealPlateForVehicle(veh, rawP)
                
                local normRaw = NormalizePlate(rawP)
                local normReal = NormalizePlate(realP)

                if normRaw then occupiedPlates[normRaw:upper()] = true end
                if rawP then occupiedPlates[rawP:upper()] = true end
                if normReal then occupiedPlates[normReal:upper()] = true end
                if realP then occupiedPlates[realP:upper()] = true end
            end
        end
    end

    -- 2. Scan all vehicles currently spawned in the world
    for _, vehicle in ipairs(vehicles) do
        if DoesEntityExist(vehicle) then
            local isOccupied = occupiedVehicles[vehicle] == true
            local vehCoords = GetEntityCoords(vehicle)
            local rawPlate = GetVehicleNumberPlateText(vehicle)
            local realPlate = GetRealPlateForVehicle(vehicle, rawPlate)
            local plate = NormalizePlate(realPlate)

            -- Double check all seats if not already found occupied via player loop
            if not isOccupied then
                for seat = -1, 6 do
                    local ped = GetPedInVehicleSeat(vehicle, seat)
                    if ped ~= 0 and DoesEntityExist(ped) then
                        isOccupied = true
                        break
                    end
                end
            end

            -- Check if the vehicle is in a mechanic zone or undergoing upgrades
            local inMechZone, zoneName = IsVehicleInMechanicZone(vehCoords)
            local isUpgrading = IsVehicleUndergoingUpgrade(vehicle, rawPlate)

            if isOccupied or inMechZone or isUpgrading then
                -- PROTECT THIS VEHICLE: Do not delete, register all plate forms so Step 3 ignores it
                protectedCount = protectedCount + 1

                if plate then
                    occupiedPlates[plate:upper()] = true
                end
                if realPlate then
                    occupiedPlates[realPlate:upper()] = true
                end
                if rawPlate then
                    occupiedPlates[rawPlate:upper()] = true
                end
                local normRaw = NormalizePlate(rawPlate)
                if normRaw then
                    occupiedPlates[normRaw:upper()] = true
                end

                if ConfigImpound.Debug then
                    print(("[cfx-keydi-impound] Protected vehicle [%s] (Occupied: %s, InMechZone: %s (%s), Upgrading: %s)"):format(
                        realPlate or rawPlate or "Unknown",
                        tostring(isOccupied),
                        tostring(inMechZone),
                        tostring(zoneName),
                        tostring(isUpgrading)
                    ))
                end
            else
                -- Vehicle is unoccupied and not protected: queue for cleanup & garage restore
                if plate then
                    platesToStore[#platesToStore + 1] = {
                        plate = plate,
                        rawPlate = realPlate or rawPlate,
                    }

                    -- Clear from jg-advancedgarages outside tracking
                    pcall(function()
                        if exports["jg-advancedgarages"] and exports["jg-advancedgarages"].deleteOutsideVehicle then
                            exports["jg-advancedgarages"]:deleteOutsideVehicle(plate)
                        end
                    end)
                end

                DeleteEntity(vehicle)
                cleanedCount = cleanedCount + 1
            end
        end
    end

    -- 3. Update database for all deleted unoccupied vehicles (mark as in_garage = 1, stored = 1)
    if ConfigImpound.ReturnToGarage ~= false and #platesToStore > 0 then
        for _, item in ipairs(platesToStore) do
            pcall(function()
                MySQL.update.await(
                    "UPDATE owned_vehicles SET in_garage = 1, stored = 1, impound = 0 WHERE TRIM(plate) = TRIM(?) OR plate = ?",
                    { item.plate, item.rawPlate }
                )
            end)
        end
    end

    -- 4. Sweep database for any orphaned "Left Out" records (in_garage = 0 or stored = 0)
    -- whose entity was already despawned / destroyed and is not currently occupied in the server
    if ConfigImpound.ClearAllOrphanedVehicles ~= false then
        local orphanedRows = MySQL.query.await("SELECT plate FROM owned_vehicles WHERE in_garage = 0 OR stored = 0")
        if orphanedRows and #orphanedRows > 0 then
            local orphanedPlatesToFix = {}
            for _, row in ipairs(orphanedRows) do
                local p = NormalizePlate(row.plate)
                local pUpper = p and p:upper() or ""
                local rawUpper = row.plate and row.plate:upper() or ""

                if p and not occupiedPlates[pUpper] and not occupiedPlates[rawUpper] then
                    orphanedPlatesToFix[#orphanedPlatesToFix + 1] = row.plate

                    pcall(function()
                        if exports["jg-advancedgarages"] and exports["jg-advancedgarages"].deleteOutsideVehicle then
                            exports["jg-advancedgarages"]:deleteOutsideVehicle(p)
                        end
                    end)
                end
            end

            if #orphanedPlatesToFix > 0 then
                for _, fixPlate in ipairs(orphanedPlatesToFix) do
                    local normP = NormalizePlate(fixPlate) or fixPlate
                    pcall(function()
                        MySQL.update.await(
                            "UPDATE owned_vehicles SET in_garage = 1, stored = 1, impound = 0 WHERE TRIM(plate) = TRIM(?) OR plate = ?",
                            { normP, fixPlate }
                        )
                    end)
                end
                print(("[cfx-keydi-impound] Restored %d orphaned left-out vehicles in database to in_garage = 1."):format(#orphanedPlatesToFix))
            end
        end
    end

    -- 5. Ensure default garage_id if null or empty
    pcall(function()
        local defaultGarage = ConfigImpound.DefaultGarage or "Legion Square"
        MySQL.update.await("UPDATE owned_vehicles SET garage_id = ? WHERE garage_id IS NULL OR garage_id = ''", { defaultGarage })
    end)

    print(("[cfx-keydi-impound] Cleaned up %d unoccupied vehicles (%d vehicles protected in use/mechanic) and returned to garage."):format(cleanedCount, protectedCount))
end

-- Automatic Impound Loop
CreateThread(function()
    while true do
        -- Wait for interval
        Wait(ConfigImpound.Interval)
        
        -- Start Warning Countdown
        isImpounding = true
        TriggerClientEvent("cfx-keydi-impound:client:startCountdown", -1, ConfigImpound.WarningDuration)
        
        -- Wait for warning countdown to run down
        Wait(ConfigImpound.WarningDuration * 1000)
        
        -- Run vehicle deletions & database return
        CleanUnoccupiedVehicles()
        isImpounding = false
        TriggerClientEvent("cfx-keydi-impound:client:completed", -1)
    end
end)

-- Admin command to manually invoke mass impound
RegisterCommand("massimpound", function(source, args, rawCommand)
    if source == 0 then
        -- Triggered from server console
        if isImpounding then
            print("[cfx-keydi-impound] Mass impound is already active.")
            return
        end
        isImpounding = true
        TriggerClientEvent("cfx-keydi-impound:client:startCountdown", -1, ConfigImpound.WarningDuration)
        CreateThread(function()
            Wait(ConfigImpound.WarningDuration * 1000)
            CleanUnoccupiedVehicles()
            isImpounding = false
            TriggerClientEvent("cfx-keydi-impound:client:completed", -1)
        end)
        print("[cfx-keydi-impound] Mass impound warning countdown started manually from console.")
    else
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer and (xPlayer.getGroup() == "admin" or xPlayer.getGroup() == "superadmin") then
            if isImpounding then
                xPlayer.showNotification("Mass impound is already active.", "error")
                return
            end
            isImpounding = true
            TriggerClientEvent("cfx-keydi-impound:client:startCountdown", -1, ConfigImpound.WarningDuration)
            CreateThread(function()
                Wait(ConfigImpound.WarningDuration * 1000)
                CleanUnoccupiedVehicles()
                isImpounding = false
                TriggerClientEvent("cfx-keydi-impound:client:completed", -1)
            end)
            xPlayer.showNotification("Mass impound warning countdown started.", "success")
        else
            if xPlayer then
                xPlayer.showNotification("You do not have permission to use this command.", "error")
            end
        end
    end
end, false)

-- Optional: Restore all unspawned left-out cars on resource/server startup
AddEventHandler("onResourceStart", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    if ConfigImpound.RestoreOnStart then
        CreateThread(function()
            Wait(3000)
            pcall(function()
                local defaultGarage = ConfigImpound.DefaultGarage or "Legion Square"
                MySQL.update.await("UPDATE owned_vehicles SET in_garage = 1, stored = 1 WHERE in_garage = 0 OR stored = 0")
                MySQL.update.await("UPDATE owned_vehicles SET garage_id = ? WHERE garage_id IS NULL OR garage_id = ''", { defaultGarage })
            end)
        end)
    end
end)
