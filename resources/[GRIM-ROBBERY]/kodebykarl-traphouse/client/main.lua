local ESX = exports['es_extended']:getSharedObject()
local isInRedZone = false
local currentZoneLabel = nil
local activeSphere = nil
local activeBlips = {}

-- Helper: Clean up existing blips & sphere zone
local function clearActiveTrapHouseZone()
    if activeSphere then
        activeSphere:remove()
        activeSphere = nil
    end

    for _, blip in ipairs(activeBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    activeBlips = {}

    if isInRedZone then
        isInRedZone = false
        currentZoneLabel = nil
        lib.hideTextUI()
    end
end

-- Helper: Load and activate single active TrapHouse zone
local function updateActiveTrapHouseZone(zoneData)
    clearActiveTrapHouseZone()
    if not zoneData or not zoneData.coords then return end

    -- Create Radius Blip for Active TrapHouse
    local radiusBlip = AddBlipForRadius(zoneData.coords.x, zoneData.coords.y, zoneData.coords.z, zoneData.radius)
    SetBlipColour(radiusBlip, (zoneData.blip and zoneData.blip.color) or 1)
    SetBlipAlpha(radiusBlip, (zoneData.blip and zoneData.blip.alpha) or 110)

    -- Create Marker Skull Blip for Active TrapHouse
    local markerBlip = AddBlipForCoord(zoneData.coords.x, zoneData.coords.y, zoneData.coords.z)
    SetBlipSprite(markerBlip, 310)
    SetBlipColour(markerBlip, 1)
    SetBlipScale(markerBlip, 0.85)
    SetBlipAsShortRange(markerBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(('TRAPHOUSE: %s'):format(zoneData.label))
    EndTextCommandSetBlipName(markerBlip)

    activeBlips[#activeBlips + 1] = radiusBlip
    activeBlips[#activeBlips + 1] = markerBlip

    -- Create Sphere Zone for Active TrapHouse ONLY
    activeSphere = lib.zones.sphere({
        coords = zoneData.coords,
        radius = zoneData.radius,
        debug = false,
        onEnter = function()
            isInRedZone = true
            currentZoneLabel = zoneData.label

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
end

-- Listen to GlobalState change for instant rotation
AddStateBagChangeHandler('traphouse_active_zone', 'global', function(bagName, key, value)
    updateActiveTrapHouseZone(value)
end)

-- Initial Load on Client Start
CreateThread(function()
    while not GlobalState.traphouse_active_zone do
        Wait(500)
    end
    updateActiveTrapHouseZone(GlobalState.traphouse_active_zone)
end)

-- Optional Vehicle Cleanup Thread inside Active TrapHouse Zone
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
    clearActiveTrapHouseZone()
end)
