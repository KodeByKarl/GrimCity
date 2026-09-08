local airdrops = {}
local threadsStarted = false

local function bootThreads()
    if threadsStarted then return end
    threadsStarted = true
    CreateThread(StartScript)
    CreateThread(ShowLocations)
end

RegisterNetEvent('esx:playerLoaded', function()
    bootThreads()
end)

RegisterNetEvent('esx:onPlayerSpawn', function()
    bootThreads()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        bootThreads()
    end
end)

RegisterNetEvent('kodebykarl-airdropv2:syncAirdrops', function(airdropsSv)
    local incoming = airdropsSv or {}
    -- Preserve local entities/blips when the same drop id is re-synced
    local byId = {}
    for _, v in pairs(airdrops) do
        if v and v.id then byId[v.id] = v end
    end

    local merged = {}
    for _, v in pairs(incoming) do
        if v and v.id then
            local prev = byId[v.id]
            if prev then
                v.object = prev.object
                v.mainBlip = prev.mainBlip
                v.alertBlip = prev.alertBlip
                v.spawning = prev.spawning
                if prev.landed then v.landed = true end
            end
            merged[#merged + 1] = v
            byId[v.id] = nil
        end
    end

    -- Clean up drops removed by the server
    for _, orphan in pairs(byId) do
        if orphan.object and DoesEntityExist(orphan.object) then
            DeleteObject(orphan.object)
        end
        if orphan.mainBlip and DoesBlipExist(orphan.mainBlip) then
            RemoveBlip(orphan.mainBlip)
        end
        if orphan.alertBlip and DoesBlipExist(orphan.alertBlip) then
            RemoveBlip(orphan.alertBlip)
        end
    end

    airdrops = merged
end)

RegisterNetEvent('kodebykarl-airdropv2:removeObject', function(id)
    RemoveObject(id)
    lib.hideTextUI()
end)

RegisterNetEvent('kodebykarl-airdropv2:news', function(label)
    local zone = label or 'unknown sector'
    if ESX and ESX.Scaleform and ESX.Scaleform.ShowBreakingNews then
        ESX.Scaleform.ShowBreakingNews(
            'AIRDROP INCOMING',
            ('Supply crate inbound near %s — expect hostile contact.'):format(zone),
            'Grim City Alert',
            10
        )
    else
        lib.notify({
            title = 'AIRDROP',
            description = ('Inbound near %s'):format(zone),
            type = 'warning',
            duration = 8000,
        })
    end
end)

RegisterNetEvent('kodebykarl-airdropv2:removeAllObjects', function()
    for _, v in pairs(airdrops) do
        RemoveObject(v.id)
    end
    airdrops = {}
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    for _, v in pairs(airdrops) do
        if v.object then
            RemoveObject(v.id)
        end
    end
end)

function StartScript()
    while true do
        local wait = 1000

        if next(airdrops) then
            wait = 1
            for k, v in pairs(airdrops) do
                if not v.landed then
                    airdrops[k].coords = airdrops[k].coords - vector3(0.0, 0.0, 0.01 * Config.Settings.FallSpeed)
                end

                if v.object and DoesEntityExist(v.object) then
                    if GetEntityHeightAboveGround(v.object) > 0.2 then
                        SetEntityCoords(v.object, v.coords.x, v.coords.y, v.coords.z, false, false, false, false)
                    elseif not v.landed then
                        airdrops[k].landed = true
                        TriggerServerEvent('kodebykarl-airdropv2:airdropLanded', v.id)
                    end
                end

                if not v.spawning and not v.object then
                    SpawnObject(k, v.coords)
                end

                if not v.mainBlip then
                    v.mainBlip = AddBlip(v.coords)
                end

                if not v.alertBlip then
                    v.alertBlip = AlertBlip(v.coords)
                end
            end
        end

        Wait(wait)
    end
end

local inprogress = false
function ShowLocations()
    while true do
        local wait = 500
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        for _, v in pairs(airdrops) do
            if v.landed then
                local distance = #(coords - vector3(v.coords.x, v.coords.y, v.coords.z))
                if distance <= 3.0 then
                    wait = 2
                    lib.showTextUI('[E] Loot airdrop')
                    if IsControlJustPressed(0, 38) and not inprogress then
                        lib.hideTextUI()
                        inprogress = true
                        local progress = lib.progressBar({
                            duration = Config.Settings.ProgbarTime,
                            label = 'Looting airdrop...',
                            useWhileDead = false,
                            canCancel = true,
                            disable = {
                                move = true,
                                car = true,
                                combat = true,
                            },
                            anim = {
                                dict = 'mini@repair',
                                clip = 'fixing_a_player',
                                flag = 49,
                            },
                        })
                        if progress then
                            TriggerServerEvent('kodebykarl-airdropv2:pickupAirdrop', v.id)
                            RemoveObject(v.id)
                            inprogress = false
                        else
                            ClearPedTasks(ped)
                            lib.notify({ title = 'AIRDROP', description = 'Loot cancelled.', type = 'error' })
                            inprogress = false
                        end
                    end
                end
            end
        end

        Wait(wait)
    end
end

function SpawnObject(id, coords)
    airdrops[id].spawning = true

    local model = joaat(Config.Object)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end

    local obj = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)
    FreezeEntityPosition(obj, true)
    airdrops[id].object = obj

    if Config.Settings.UseFlareParticles then
        RequestNamedPtfxAsset('wpn_flare')
        while not HasNamedPtfxAssetLoaded('wpn_flare') do Wait(10) end
        UseParticleFxAssetNextCall('wpn_flare')
        SetParticleFxNonLoopedColour(1.0, 0.0, 0.0)
        StartParticleFxLoopedOnEntity('proj_heist_flare_trail', obj, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, false, false, false)
    end
end

function AddBlip(coords)
    if not Config.Blip.Enabled then return nil end
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, Config.Blip.Sprite)
    SetBlipColour(blip, Config.Blip.Colour)
    SetBlipScale(blip, Config.Blip.Scale)
    SetBlipDisplay(blip, 4)
    SetBlipAsShortRange(blip, Config.Blip.ShortRange)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Config.Blip.Name or 'Airdrop')
    EndTextCommandSetBlipName(blip)
    return blip
end

function AlertBlip(coords)
    if not Config.Blip.Enabled then return nil end
    local blipCapture = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blipCapture, 161)
    SetBlipScale(blipCapture, 2.0)
    SetBlipColour(blipCapture, 1)
    PulseBlip(blipCapture)
    return blipCapture
end

function RemoveObject(id)
    for k, v in pairs(airdrops) do
        if v.id == id then
            if v.object and DoesEntityExist(v.object) then
                DeleteObject(v.object)
            end
            if v.mainBlip and DoesBlipExist(v.mainBlip) then
                RemoveBlip(v.mainBlip)
            end
            if v.alertBlip and DoesBlipExist(v.alertBlip) then
                RemoveBlip(v.alertBlip)
            end
            airdrops[k] = nil
            break
        end
    end
end
