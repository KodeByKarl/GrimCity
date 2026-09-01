local ESX = exports['es_extended']:getSharedObject()
local isInRedZone = false
local currentZoneLabel = nil
local activeSpheres = {}
local ZoneBlips = {}

-- Create Radius Map Blips
CreateThread(function()
    for _, zone in ipairs(Config.TrapZones) do
        if zone.blip and zone.blip.enable then
            local radiusBlip = AddBlipForRadius(zone.coords.x, zone.coords.y, zone.coords.z, zone.radius)
            SetBlipColour(radiusBlip, zone.blip.color or 1)
            SetBlipAlpha(radiusBlip, zone.blip.alpha or 110)

            local markerBlip = AddBlipForCoord(zone.coords.x, zone.coords.y, zone.coords.z)
            SetBlipSprite(markerBlip, 310)
            SetBlipColour(markerBlip, 1)
            SetBlipScale(markerBlip, 0.85)
            SetBlipAsShortRange(markerBlip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(('TRAPHOUSE: %s'):format(zone.label))
            EndTextCommandSetBlipName(markerBlip)

            ZoneBlips[#ZoneBlips + 1] = radiusBlip
            ZoneBlips[#ZoneBlips + 1] = markerBlip
        end
    end
end)

-- Initialize ox_lib Zones efficiently
CreateThread(function()
    for _, zone in ipairs(Config.TrapZones) do
        local sphere = lib.zones.sphere({
            coords = zone.coords,
            radius = zone.radius,
            debug = false,
            onEnter = function()
                isInRedZone = true
                currentZoneLabel = zone.label

                DisplayRadar(true)
                DisplayHud(true)

                lib.showTextUI('TRAPHOUSE REDZONE • KILL ON SIGHT', {
                    position = 'top-center',
                    icon = 'fa-solid fa-skull',
                    style = {
                        borderRadius = '6px',
                        backgroundColor = 'rgba(13, 13, 18, 0.9)',
                        color = '#ff4d4d',
                        border = '1px solid rgba(255, 58, 58, 0.4)',
                        padding = '6px 12px',
                        fontSize = '12px',
                        fontWeight = '600',
                        letterSpacing = '0.5px'
                    }
                })
            end,
            onExit = function()
                isInRedZone = false
                currentZoneLabel = nil
                lib.hideTextUI()
            end
        })

        activeSpheres[#activeSpheres + 1] = sphere
    end
end)

-- Optional Vehicle Cleanup Thread inside TrapHouse Zone
CreateThread(function()
    if not Config.DeleteVehiclesInZone then return end

    local lastVehicle = nil

    while true do
        Wait(1000)
        local ped = PlayerPedId()

        if isInRedZone then
            if IsPedInAnyVehicle(ped, false) then
                lastVehicle = GetVehiclePedIsIn(ped, false)
            else
                if lastVehicle and DoesEntityExist(lastVehicle) then
                    local vCoords = GetEntityCoords(lastVehicle)
                    local driver = GetPedInVehicleSeat(lastVehicle, -1)

                    if driver == 0 or not IsPedAPlayer(driver) then
                        if #(GetEntityCoords(ped) - vCoords) > 5.0 then
                            SetEntityAsMissionEntity(lastVehicle, true, true)
                            DeleteVehicle(lastVehicle)
                            lastVehicle = nil
                        end
                    end
                end
            end
        else
            lastVehicle = nil
        end
    end
end)

-- Global Export for compatibility with other resources
function InRedZoneField()
    return isInRedZone
end

exports('InRedZoneField', InRedZoneField)

-- Cleanup on Resource Stop
AddEventHandler('onResourceStop', function(resName)
    if resName ~= GetCurrentResourceName() then return end
    lib.hideTextUI()
    for _, sphere in ipairs(activeSpheres) do
        sphere:remove()
    end
end)
