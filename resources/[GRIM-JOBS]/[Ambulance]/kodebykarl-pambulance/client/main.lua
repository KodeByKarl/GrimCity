local ESX = exports['es_extended']:getSharedObject()

local function jobName()
    local job = ESX.PlayerData and ESX.PlayerData.job and ESX.PlayerData.job.name
    if not job then
        local pd = ESX.GetPlayerData()
        job = pd and pd.job and pd.job.name
    end
    return job
end

local function jobGrade()
    local job = ESX.PlayerData and ESX.PlayerData.job
    if not job then
        local pd = ESX.GetPlayerData()
        job = pd and pd.job
    end
    return tonumber(job and job.grade) or 0
end

local function isPaletoEms()
    local name = jobName()
    return name == ConfigPambulance.Job or name == ConfigPambulance.OffDutyJob
end

local function isPaletoBoss()
    if not isPaletoEms() then return false end
    local minGrade = (ConfigPambulance.Station.BossMenu and ConfigPambulance.Station.BossMenu.minGrade) or 5
    return jobGrade() >= minGrade
end

local function createStationBlip()
    local blipCfg = ConfigPambulance.Station and ConfigPambulance.Station.Blip
    if not blipCfg or not blipCfg.Coords then return end

    local blip = AddBlipForCoord(blipCfg.Coords.x, blipCfg.Coords.y, blipCfg.Coords.z)
    SetBlipSprite(blip, blipCfg.Sprite or 61)
    SetBlipDisplay(blip, blipCfg.Display or 4)
    SetBlipScale(blip, blipCfg.Scale or 0.8)
    SetBlipColour(blip, blipCfg.Colour or 1)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(blipCfg.Label or ConfigPambulance.Label)
    EndTextCommandSetBlipName(blip)
end

local function openBossMenu()
    if not isPaletoBoss() then
        lib.notify({
            title = ConfigPambulance.Label,
            description = 'Boss access only.',
            type = 'error',
        })
        return
    end

    if GetResourceState('kodebykarl-ui') == 'started' then
        exports['kodebykarl-ui']:OpenIpad()
        return
    end

    lib.notify({
        title = ConfigPambulance.Label,
        description = 'Department boss is managed from the iPad.',
        type = 'inform',
    })
end

local function openWardrobe()
    if not isPaletoEms() then
        lib.notify({
            title = ConfigPambulance.Label,
            description = 'Only Paleto Ambulance personnel can use this wardrobe.',
            type = 'error',
        })
        return
    end

    if GetResourceState('illenium-appearance') == 'started' then
        TriggerEvent('illenium-appearance:client:openOutfitMenu')
    else
        lib.notify({
            title = ConfigPambulance.Label,
            description = 'Wardrobe is unavailable.',
            type = 'error',
        })
    end
end

local function addBox(name, coords, heading, size, option)
    if GetResourceState('ox_target') ~= 'started' then return end
    exports.ox_target:addBoxZone({
        coords = coords,
        size = size or vector3(1.2, 1.2, 2.2),
        rotation = heading or 0.0,
        debug = false,
        options = { option },
    })
end

local function setupBossMenu()
    local cfg = ConfigPambulance.Station and ConfigPambulance.Station.BossMenu
    if not cfg or not cfg.coords then return end

    addBox('pambulance_boss', cfg.coords, cfg.heading, vector3(1.4, 1.4, 2.2), {
        name = 'pambulance_boss',
        icon = cfg.icon or 'fa-solid fa-briefcase',
        label = cfg.label or 'Boss Menu',
        groups = { [ConfigPambulance.Job] = cfg.minGrade or 5, [ConfigPambulance.OffDutyJob] = cfg.minGrade or 5 },
        onSelect = openBossMenu,
        distance = 2.0,
    })
end

local function setupWardrobe()
    local cfg = ConfigPambulance.Station and ConfigPambulance.Station.Wardrobe
    if not cfg or not cfg.coords then return end

    addBox('pambulance_wardrobe', cfg.coords, cfg.heading, cfg.size or vector3(1.2, 2.0, 2.5), {
        name = 'pambulance_wardrobe',
        icon = cfg.icon or 'fa-solid fa-shirt',
        label = cfg.label or 'Wardrobe',
        groups = { [ConfigPambulance.Job] = 0, [ConfigPambulance.OffDutyJob] = 0 },
        onSelect = openWardrobe,
        distance = 2.0,
    })
end

local function setupGarage()
    local cfg = ConfigPambulance.Station and ConfigPambulance.Station.Garage
    if not cfg or not cfg.access then return end
    if GetResourceState('ox_target') ~= 'started' then return end

    local garageId = cfg.garageId or 'Paleto EMS Garage'
    exports.ox_target:addBoxZone({
        coords = cfg.access,
        size = vector3(2.0, 2.0, 2.0),
        rotation = cfg.heading or 0.0,
        debug = false,
        options = {
            {
                name = 'pambulance_garage_access',
                icon = 'fa-solid fa-warehouse',
                label = cfg.label or 'Paleto EMS Garage',
                groups = { [ConfigPambulance.Job] = 0, [ConfigPambulance.OffDutyJob] = 0, ambulance = 0 },
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
                name = 'pambulance_garage_store',
                icon = 'fa-solid fa-parking',
                label = 'Store Ambulance',
                groups = { [ConfigPambulance.Job] = 0, [ConfigPambulance.OffDutyJob] = 0, ambulance = 0 },
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

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
    ESX.PlayerLoaded = true
end)

RegisterNetEvent('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

CreateThread(function()
    while not ESX.IsPlayerLoaded() do Wait(200) end
    ESX.PlayerData = ESX.GetPlayerData()
    createStationBlip()
    setupBossMenu()
    setupWardrobe()
    setupGarage()
end)

exports('GetJobName', function()
    return ConfigPambulance.Job
end)

exports('GetOffDutyJobName', function()
    return ConfigPambulance.OffDutyJob
end)

exports('OpenBossMenu', openBossMenu)
exports('OpenWardrobe', openWardrobe)
