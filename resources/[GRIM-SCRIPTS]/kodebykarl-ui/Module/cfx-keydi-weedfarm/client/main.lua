ESX = ESX or exports["es_extended"]:getSharedObject()

local spawnedPlants = {}
local harvestedPlants = {}
-- Personal cooldown only (does not block other players at the same spot)
local collectCooldowns = {} -- [index] = true while YOU are cooling down
local isHarvesting = false
local isProcessing = false
local isCollecting = false

local function IsBusy()
    return isHarvesting or isProcessing or isCollecting
end

local function CanUseWeedfarm()
    if type(ConfigServerLocations) ~= "table" or not ConfigServerLocations.CanUseFunction then
        return true
    end
    return ConfigServerLocations.CanUseFunction("grind") or ConfigServerLocations.CanUseFunction("weedfarm")
end

-- Helper Function for 3D Text Render
local function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0 + 0.0125, 0.015 + factor, 0.03, 5, 25, 47, 190)
    ClearDrawOrigin()
end

local function RunProgress(duration, label, anim)
    return lib.progressBar({
        duration = duration,
        label = label,
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true,
        },
        anim = anim,
    })
end

local function SendWeedfarmHud(action, payload)
    SendNUIMessage({
        action = action,
        data = payload
    })
end

local function HideWeedfarmHud()
    SendNUIMessage({
        action = "cfx-keydi-weedfarm:hide"
    })
end

-- Spawn Weed Plant Props at locations
local function SpawnPlantProps()
    local modelHash = Config.WeedFarm.PlantModel
    RequestModel(modelHash)
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 100 do
        Wait(50)
        timeout = timeout + 1
    end

    for i, loc in ipairs(Config.WeedFarm.Locations) do
        local existingObj = GetClosestObjectOfType(loc.x, loc.y, loc.z, 1.0, modelHash, false, false, false)
        if existingObj == 0 then
            local obj = CreateObject(modelHash, loc.x, loc.y, loc.z - 1.0, false, false, false)
            SetEntityHeading(obj, math.random(0, 360))
            PlaceObjectOnGroundProperly(obj)
            FreezeEntityPosition(obj, true)
            table.insert(spawnedPlants, obj)
        else
            table.insert(spawnedPlants, existingObj)
        end
    end
end

local function DeletePlantProps()
    for _, obj in ipairs(spawnedPlants) do
        if obj and DoesEntityExist(obj) then
            DeleteEntity(obj)
        end
    end
    spawnedPlants = {}
end

-- Proximity & 3D Text Loop (plants + collect + process)
CreateThread(function()
    Wait(1000)
    if CanUseWeedfarm() then
        SpawnPlantProps()
    end

    while true do
        local sleep = 1000
        if not CanUseWeedfarm() then
            Wait(1500)
        else
        local ped = PlayerPedId()
        local pCoords = GetEntityCoords(ped)

        for i, loc in ipairs(Config.WeedFarm.Locations) do
            local dist = #(pCoords - loc)
            if dist <= 2.5 then
                sleep = 0
                if harvestedPlants[i] then
                    DrawText3D(loc.x, loc.y, loc.z + 0.5, "~r~Plant Regrowing...")
                elseif IsBusy() then
                    DrawText3D(loc.x, loc.y, loc.z + 0.5, "~y~Busy...")
                else
                    DrawText3D(loc.x, loc.y, loc.z + 0.5, "~g~[E]~s~ Harvest Weed")

                    if IsControlJustReleased(0, 38) then
                        harvestedPlants[i] = true
                        TriggerServerEvent("cfx-keydi-weedfarm:server:startHarvest", i)
                        Wait(500)
                    end
                end
            end
        end

        for i, station in ipairs(Config.WeedFarm.CollectStations or {}) do
            local c = station.coords
            local stationPos = vector3(c.x, c.y, c.z)
            local dist = #(pCoords - stationPos)
            local range = station.interactionDistance or 2.0
            if dist <= range then
                sleep = 0
                if collectCooldowns[i] then
                    DrawText3D(c.x, c.y, c.z + 0.35, "~r~Cooling down...")
                elseif IsBusy() then
                    DrawText3D(c.x, c.y, c.z + 0.35, "~y~Busy...")
                else
                    DrawText3D(c.x, c.y, c.z + 0.35, ("~g~[E]~s~ %s"):format(station.label or "Collect"))

                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent("cfx-keydi-weedfarm:server:startCollect", i)
                        Wait(500)
                    end
                end
            end
        end

        for i, station in ipairs(Config.WeedFarm.ProcessStations or {}) do
            local c = station.coords
            local stationPos = vector3(c.x, c.y, c.z)
            local dist = #(pCoords - stationPos)
            local range = station.interactionDistance or 2.0
            if dist <= range then
                sleep = 0
                if IsBusy() then
                    DrawText3D(c.x, c.y, c.z + 0.35, "~y~Processing...")
                else
                    local hint
                    if station.require and station.require.label then
                        hint = ("~g~[E]~s~ %s ~c~(need %s)"):format(station.label or "Process", station.require.label)
                    else
                        hint = ("~g~[E]~s~ %s"):format(station.label or "Process")
                    end
                    DrawText3D(c.x, c.y, c.z + 0.35, hint)

                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent("cfx-keydi-weedfarm:server:startProcess", i)
                        Wait(500)
                    end
                end
            end
        end

        Wait(sleep)
        end
    end
end)

-- Weed plant harvest
RegisterNetEvent("cfx-keydi-weedfarm:client:harvestStarted", function(plantIndex, duration)
    if IsBusy() then return end
    isHarvesting = true
    harvestedPlants[plantIndex] = true

    duration = duration or Config.WeedFarm.HarvestDuration or 4000
    local itemLabel = Config.WeedFarm.ItemLabel or "Weed Bud"

    local invWeight = (GetResourceState("ox_inventory") == "started" and exports.ox_inventory:GetPlayerWeight()) or 0
    local maxWeight = (GetResourceState("ox_inventory") == "started" and exports.ox_inventory:GetPlayerMaxWeight()) or 24000
    local collected = (GetResourceState("ox_inventory") == "started" and tonumber(exports.ox_inventory:Search("count", "weed_bud"))) or 0

    SendWeedfarmHud("cfx-keydi-weedfarm:show", {
        status = "active",
        stage = "harvest",
        label = itemLabel,
        itemWeight = 50,
        collected = collected,
        weight = invWeight,
        maxWeight = maxWeight,
        progress = 0.05,
        zone = "San Chianski Weed Farm",
        rarity = "uncommon",
        untilFull = math.max(0, math.floor((maxWeight - invWeight) / 50)),
        etaSeconds = math.ceil(duration / 1000),
    })

    local success = RunProgress(duration, ("Harvesting %s…"):format(itemLabel), {
        dict = "amb@world_human_gardener_plant@male@base",
        clip = "base",
    })

    HideWeedfarmHud()

    if not success then
        isHarvesting = false
        harvestedPlants[plantIndex] = nil
        TriggerServerEvent("cfx-keydi-weedfarm:server:cancelAction")
        return
    end

    isHarvesting = false
    TriggerServerEvent("cfx-keydi-weedfarm:server:completeHarvest", plantIndex)
end)

-- Collect station
RegisterNetEvent("cfx-keydi-weedfarm:client:collectStarted", function(stationIndex, duration, progressLabel, itemLabel)
    if IsBusy() then return end
    isCollecting = true
    collectCooldowns[stationIndex] = true

    duration = duration or Config.WeedFarm.CollectDuration or 4000
    local success = RunProgress(duration, progressLabel or ("Collecting %s…"):format(itemLabel or "Item"), {
        dict = "amb@prop_human_parking_meter@male@base",
        clip = "base",
    })

    if not success then
        isCollecting = false
        collectCooldowns[stationIndex] = nil
        TriggerServerEvent("cfx-keydi-weedfarm:server:cancelAction")
        return
    end

    isCollecting = false
    TriggerServerEvent("cfx-keydi-weedfarm:server:completeCollect", stationIndex)
end)

RegisterNetEvent("cfx-keydi-weedfarm:client:syncCollectCooldown", function(stationIndex, state)
    if state then
        collectCooldowns[stationIndex] = true
    else
        collectCooldowns[stationIndex] = nil
    end
end)

RegisterNetEvent("cfx-keydi-weedfarm:client:collectDenied", function(reason)
    isCollecting = false
    if reason == "cooldown" then
        ESX.ShowNotification("~r~This spot is cooling down.")
    elseif reason == "busy" then
        ESX.ShowNotification("~r~Already busy.")
    elseif reason == "distance" then
        ESX.ShowNotification("~r~Too far from the collect spot.")
    elseif reason == "wrong_server" then
        ESX.ShowNotification("~r~" .. ((ConfigServerLocations and ConfigServerLocations.WrongServerMessage)
            and ConfigServerLocations.WrongServerMessage("grind")
            or "Weed farm is only available on Server #2 · Grind."))
    else
        ESX.ShowNotification("~r~Cannot collect right now.")
    end
end)

-- Process station progress
RegisterNetEvent("cfx-keydi-weedfarm:client:processStarted", function(stationIndex, duration, progressLabel, itemLabel)
    if IsBusy() then return end
    isProcessing = true

    duration = duration or Config.WeedFarm.ProcessDuration or 5000

    local invWeight = (GetResourceState("ox_inventory") == "started" and exports.ox_inventory:GetPlayerWeight()) or 0
    local maxWeight = (GetResourceState("ox_inventory") == "started" and exports.ox_inventory:GetPlayerMaxWeight()) or 24000
    local isRoll = stationIndex == 2
    local outItem = isRoll and "joint" or "packaged_weed"
    local collected = (GetResourceState("ox_inventory") == "started" and tonumber(exports.ox_inventory:Search("count", outItem))) or 0

    SendWeedfarmHud("cfx-keydi-weedfarm:show", {
        status = "active",
        stage = isRoll and "roll" or "package",
        label = isRoll and "Joint" or "Packaged Weed",
        itemWeight = isRoll and 10 or 100,
        collected = collected,
        weight = invWeight,
        maxWeight = maxWeight,
        progress = 0.05,
        zone = isRoll and "Weed Rolling Bench #2" or "Packaging Bench #1",
        rarity = isRoll and "rare" or "uncommon",
        untilFull = math.max(0, math.floor((maxWeight - invWeight) / (isRoll and 10 or 100))),
        etaSeconds = math.ceil(duration / 1000),
        recipe = isRoll and {
            inputLabel = "Packaged Weed",
            inputAmount = 5,
            requireLabel = "Rolling Paper",
            requireAmount = 1,
            outputLabel = "Joint",
            outputAmount = 5,
        } or {
            inputLabel = "Weed Bud",
            inputAmount = 5,
            requireLabel = "Zip-lock Bag",
            requireAmount = 1,
            outputLabel = "Packaged Weed",
            outputAmount = 5,
        }
    })

    local success = RunProgress(duration, progressLabel or ("Processing %s…"):format(itemLabel or "Item"), {
        dict = "amb@prop_human_parking_meter@male@base",
        clip = "base",
    })

    HideWeedfarmHud()

    if not success then
        isProcessing = false
        TriggerServerEvent("cfx-keydi-weedfarm:server:cancelAction")
        return
    end

    isProcessing = false
    TriggerServerEvent("cfx-keydi-weedfarm:server:completeProcess", stationIndex)
end)

RegisterNetEvent("cfx-keydi-weedfarm:client:processDenied", function(reason)
    isProcessing = false
    if reason == "missing_input" then
        ESX.ShowNotification("~r~Not enough materials to process.")
    elseif reason == "missing_require" then
        ESX.ShowNotification("~r~Missing required item.")
    elseif reason == "busy" then
        ESX.ShowNotification("~r~Already processing.")
    elseif reason == "distance" then
        ESX.ShowNotification("~r~Too far from the process station.")
    elseif reason == "wrong_server" then
        ESX.ShowNotification("~r~" .. ((ConfigServerLocations and ConfigServerLocations.WrongServerMessage)
            and ConfigServerLocations.WrongServerMessage("grind")
            or "Weed farm is only available on Server #2 · Grind."))
    else
        ESX.ShowNotification("~r~Cannot process right now.")
    end
end)

-- Server Sync for Plant Regrow Cooldown
RegisterNetEvent("cfx-keydi-weedfarm:client:syncCooldown", function(plantIndex, state)
    if state then
        harvestedPlants[plantIndex] = true
    else
        harvestedPlants[plantIndex] = nil
    end
end)

-- Clean up on resource stop
AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for _, obj in ipairs(spawnedPlants) do
        if DoesEntityExist(obj) then
            DeleteEntity(obj)
        end
    end
end)

AddEventHandler("cfx-keydi-serverlocations:changed", function(location)
    local enabled = ConfigServerLocations.LocationAllows
        and ConfigServerLocations.LocationAllows(location, "weedfarm")
        or CanUseWeedfarm()
    if enabled then
        SpawnPlantProps()
    else
        DeletePlantProps()
    end
end)
