local configs = require 'shared.config'

local function jobName()
    local data = ESX and ESX.PlayerData
    if not data or not data.job then
        data = ESX and ESX.GetPlayerData and ESX.GetPlayerData() or data
    end
    return data and data.job and data.job.name
end

local function isCityEms()
    local name = jobName()
    return name == 'ambulance' or name == 'offambulance'
end

local function openWardrobe()
    if not isCityEms() then
        ESX.Notify('AMBULANCE', 'Only City EMS personnel can use this wardrobe.', 'error', 3000)
        return
    end

    if GetResourceState('illenium-appearance') == 'started' then
        TriggerEvent('illenium-appearance:client:openOutfitMenu')
        return
    end

    ESX.Notify('AMBULANCE', 'Wardrobe is unavailable.', 'error', 3000)
end

local function setupWardrobe()
    local cfg = configs.Station and configs.Station.Wardrobe
    if not cfg or not cfg.coords then return end
    if GetResourceState('ox_target') ~= 'started' then return end

    exports.ox_target:addBoxZone({
        coords = cfg.coords,
        size = cfg.size or vector3(1.2, 2.0, 2.5),
        rotation = cfg.heading or 0.0,
        debug = false,
        options = {
            {
                name = 'ambulance_wardrobe',
                icon = cfg.icon or 'fa-solid fa-shirt',
                label = cfg.label or 'EMS Wardrobe',
                groups = { ambulance = 0, offambulance = 0 },
                onSelect = openWardrobe,
                distance = 2.0,
            },
        },
    })
end

local function setupGarage()
    local cfg = configs.Station and configs.Station.Garage
    if not cfg or not cfg.access then return end
    if GetResourceState('ox_target') ~= 'started' then return end

    local garageId = cfg.garageId or 'EMS Garage'
    exports.ox_target:addBoxZone({
        coords = cfg.access,
        size = vector3(2.0, 2.0, 2.0),
        rotation = cfg.heading or 0.0,
        debug = false,
        options = {
            {
                name = 'ambulance_garage_access',
                icon = 'fa-solid fa-warehouse',
                label = cfg.label or 'EMS Garage',
                groups = { ambulance = 0, offambulance = 0, pambulance = 0 },
                onSelect = function()
                    if cache.vehicle and GetPedInVehicleSeat(cache.vehicle, -1) == cache.ped then
                        TriggerEvent('jg-advancedgarages:client:store-vehicle', garageId, 'car', false)
                    else
                        TriggerEvent('jg-advancedgarages:client:open-garage', garageId, 'car', false)
                    end
                end,
                distance = 3.5,
            },
            {
                name = 'ambulance_garage_store',
                icon = 'fa-solid fa-parking',
                label = 'Store Ambulance',
                groups = { ambulance = 0, offambulance = 0, pambulance = 0 },
                canInteract = function()
                    return cache.vehicle and GetPedInVehicleSeat(cache.vehicle, -1) == cache.ped
                end,
                onSelect = function()
                    TriggerEvent('jg-advancedgarages:client:store-vehicle', garageId, 'car', false)
                end,
                distance = 12.0,
            },
        },
    })
end

CreateThread(function()
    while ESX == nil do Wait(200) end
    while not ESX.IsPlayerLoaded or not ESX.IsPlayerLoaded() do Wait(200) end
    setupWardrobe()
    setupGarage()
end)
