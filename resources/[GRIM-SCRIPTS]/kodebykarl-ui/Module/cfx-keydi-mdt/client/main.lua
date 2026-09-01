local ESX = exports["es_extended"]:getSharedObject()
local isMdtOpen = false
local tabletProp = nil

-- =========================================================================
-- TABLET PROP & ANIMATION
-- =========================================================================

local function PlayTabletAnimation()
    if not ConfigMDT.Tablet.enabled then return end
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then return end

    local dict = ConfigMDT.Tablet.dict
    local anim = ConfigMDT.Tablet.anim
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end

    TaskPlayAnim(playerPed, dict, anim, 2.0, 2.0, -1, 49, 0, false, false, false)

    local model = ConfigMDT.Tablet.model
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end

    if not DoesEntityExist(tabletProp) then
        local coords = GetEntityCoords(playerPed)
        tabletProp = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)
        AttachEntityToEntity(
            tabletProp,
            playerPed,
            GetPedBoneIndex(playerPed, ConfigMDT.Tablet.bone),
            ConfigMDT.Tablet.offset.x,
            ConfigMDT.Tablet.offset.y,
            ConfigMDT.Tablet.offset.z,
            ConfigMDT.Tablet.rotation.x,
            ConfigMDT.Tablet.rotation.y,
            ConfigMDT.Tablet.rotation.z,
            true, true, false, true, 1, true
        )
    end
end

local function StopTabletAnimation()
    local playerPed = PlayerPedId()
    StopAnimTask(playerPed, ConfigMDT.Tablet.dict, ConfigMDT.Tablet.anim, 1.5)
    if DoesEntityExist(tabletProp) then
        DeleteEntity(tabletProp)
        tabletProp = nil
    end
end

-- =========================================================================
-- OPEN & CLOSE MDT
-- =========================================================================

local function OpenMDT()
    local playerData = ESX.GetPlayerData()
    if not playerData or not playerData.job or not ConfigMDT.AllowedJobs[playerData.job.name] then
        ESX.ShowNotification("You do not have access to the Police MDT.", "error")
        return
    end

    if isMdtOpen then return end
    TriggerServerEvent('cfx-keydi-mdt:server:requestMdtData')
end

local function CloseMDT()
    if not isMdtOpen then return end
    isMdtOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "closeMdt" })
    StopTabletAnimation()
end

RegisterCommand(ConfigMDT.OpenCommand, function()
    OpenMDT()
end, false)

RegisterKeyMapping(ConfigMDT.OpenCommand, 'Open Police MDT', 'keyboard', ConfigMDT.OpenKey)

-- =========================================================================
-- SERVER TO CLIENT EVENT RECEIVERS
-- =========================================================================

RegisterNetEvent('cfx-keydi-mdt:client:receiveMdtData', function(payload)
    isMdtOpen = true
    PlayTabletAnimation()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openMdt",
        data = payload
    })
end)

RegisterNetEvent('cfx-keydi-mdt:client:openDenied', function(reason)
    ESX.ShowNotification(reason or "MDT Access Denied", "error")
end)

RegisterNetEvent('cfx-keydi-mdt:client:receiveCitizenSearchResults', function(results)
    SendNUIMessage({
        action = "updateCitizenSearchResults",
        data = results
    })
end)

RegisterNetEvent('cfx-keydi-mdt:client:receiveVehicleSearchResults', function(results)
    SendNUIMessage({
        action = "updateVehicleSearchResults",
        data = results
    })
end)

RegisterNetEvent('cfx-keydi-mdt:client:citizenNotesUpdated', function(data)
    SendNUIMessage({
        action = "updateCitizenNotes",
        data = data
    })
end)

RegisterNetEvent('cfx-keydi-mdt:client:vehicleFlagsUpdated', function(data)
    SendNUIMessage({
        action = "updateVehicleFlags",
        data = data
    })
end)

RegisterNetEvent('cfx-keydi-mdt:client:syncWarrants', function(warrants)
    SendNUIMessage({
        action = "updateMdtWarrants",
        data = warrants
    })
end)

RegisterNetEvent('cfx-keydi-mdt:client:syncBolos', function(bolos)
    SendNUIMessage({
        action = "updateMdtBolos",
        data = bolos
    })
end)

RegisterNetEvent('cfx-keydi-mdt:client:syncIncidents', function(incidents)
    SendNUIMessage({
        action = "updateMdtIncidents",
        data = incidents
    })
end)

RegisterNetEvent('cfx-keydi-mdt:client:syncDispatchCalls', function(calls)
    SendNUIMessage({
        action = "updateMdtDispatchCalls",
        data = calls
    })
end)

RegisterNetEvent('cfx-keydi-mdt:client:syncDutyUnits', function(units)
    SendNUIMessage({
        action = "updateMdtDutyUnits",
        data = units
    })
end)

RegisterNetEvent('cfx-keydi-mdt:client:alertBroadcast', function(alert)
    SendNUIMessage({
        action = "broadcastMdtAlert",
        data = alert
    })
end)

RegisterNetEvent('cfx-keydi-mdt:client:officerProfileUpdated', function(data)
    SendNUIMessage({
        action = "updateMdtOfficerProfile",
        data = data
    })
end)

-- =========================================================================
-- NUI CALLBACKS (React to Lua)
-- =========================================================================

RegisterNUICallback('closeMdt', function(data, cb)
    CloseMDT()
    cb('ok')
end)

RegisterNUICallback('searchCitizen', function(data, cb)
    TriggerServerEvent('cfx-keydi-mdt:server:searchCitizen', data.query)
    cb('ok')
end)

RegisterNUICallback('addCitizenNote', function(data, cb)
    TriggerServerEvent('cfx-keydi-mdt:server:addCitizenNote', data)
    cb('ok')
end)

RegisterNUICallback('searchVehicle', function(data, cb)
    TriggerServerEvent('cfx-keydi-mdt:server:searchVehicle', data.query)
    cb('ok')
end)

RegisterNUICallback('addVehicleFlag', function(data, cb)
    TriggerServerEvent('cfx-keydi-mdt:server:addVehicleFlag', data)
    cb('ok')
end)

RegisterNUICallback('removeVehicleFlag', function(data, cb)
    TriggerServerEvent('cfx-keydi-mdt:server:removeVehicleFlag', data.flagId, data.plate)
    cb('ok')
end)

RegisterNUICallback('createWarrant', function(data, cb)
    TriggerServerEvent('cfx-keydi-mdt:server:createWarrant', data)
    cb('ok')
end)

RegisterNUICallback('deleteWarrant', function(data, cb)
    TriggerServerEvent('cfx-keydi-mdt:server:deleteWarrant', data.warrantId)
    cb('ok')
end)

RegisterNUICallback('createBolo', function(data, cb)
    TriggerServerEvent('cfx-keydi-mdt:server:createBolo', data)
    cb('ok')
end)

RegisterNUICallback('deleteBolo', function(data, cb)
    TriggerServerEvent('cfx-keydi-mdt:server:deleteBolo', data.boloId)
    cb('ok')
end)

RegisterNUICallback('saveIncident', function(data, cb)
    TriggerServerEvent('cfx-keydi-mdt:server:saveIncident', data)
    cb('ok')
end)

RegisterNUICallback('deleteIncident', function(data, cb)
    TriggerServerEvent('cfx-keydi-mdt:server:deleteIncident', data.incidentId)
    cb('ok')
end)

RegisterNUICallback('setDutyStatus', function(data, cb)
    TriggerServerEvent('cfx-keydi-mdt:server:setDutyStatus', data.status)
    cb('ok')
end)

RegisterNUICallback('updateOfficerProfile', function(data, cb)
    TriggerServerEvent('cfx-keydi-mdt:server:updateOfficerProfile', data)
    cb('ok')
end)

RegisterNUICallback('attachUnitToCall', function(data, cb)
    TriggerServerEvent('cfx-keydi-mdt:server:attachUnitToCall', data.callId)
    cb('ok')
end)

RegisterNUICallback('resolveDispatchCall', function(data, cb)
    TriggerServerEvent('cfx-keydi-mdt:server:resolveDispatchCall', data.callId)
    cb('ok')
end)

RegisterNUICallback('setGpsWaypoint', function(data, cb)
    if data and data.coords and data.coords.x and data.coords.y then
        SetNewWaypoint(data.coords.x, data.coords.y)
        ESX.ShowNotification("GPS Waypoint set to call location.", "success")
    end
    cb('ok')
end)

RegisterNUICallback('triggerPanic', function(data, cb)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local streetHash, crossingHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local streetName = GetStreetNameFromHashKey(streetHash)
    if crossingHash ~= 0 then
        streetName = streetName .. " & " .. GetStreetNameFromHashKey(crossingHash)
    end

    TriggerServerEvent('cfx-keydi-mdt:server:triggerPanic', { x = coords.x, y = coords.y, z = coords.z }, streetName)
    ESX.ShowNotification("10-99 EMERGENCY PANIC BEACON BROADCASTED!", "error")
    cb('ok')
end)

-- Exports
exports('OpenMDT', OpenMDT)
exports('CloseMDT', CloseMDT)
