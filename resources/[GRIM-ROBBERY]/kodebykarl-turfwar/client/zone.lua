local ZoneManager = {}
local TurfBlips = {}
local RadiusBlips = {}
local InsideZones = {}
local DamageThreads = {}

-- Create & Update Map Blips for Turf Locations
function ZoneManager.InitBlips()
    for id, data in pairs(Config.TurfWars) do
        -- Primary Turf Marker Blip
        if data.blip and data.blip.turf and data.blip.turf.enable then
            local b = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
            SetBlipSprite(b, data.blip.turf.id or 310)
            SetBlipDisplay(b, 4)
            SetBlipScale(b, data.blip.turf.scale or 0.8)
            SetBlipColour(b, data.blip.turf.color or 1)
            SetBlipAsShortRange(b, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(data.label)
            EndTextCommandSetBlipName(b)
            TurfBlips[id] = b
        end

        -- Radius Area Blip
        if data.blip and data.blip.radius and data.blip.radius.enable then
            local r = AddBlipForRadius(data.coords.x, data.coords.y, data.coords.z, data.blip.radius.scale or 150.0)
            SetBlipColour(r, data.blip.radius.color or 1)
            SetBlipAlpha(r, data.blip.radius.alpha or 110)
            RadiusBlips[id] = r
        end
    end
end

-- Update Blip Colors based on Turf State
function ZoneManager.UpdateBlipState(id, state)
    local turfBlip = TurfBlips[id]
    local radiusBlip = RadiusBlips[id]

    if not turfBlip and not radiusBlip then return end

    if state == 'ACTIVE' then
        if turfBlip then SetBlipColour(turfBlip, 1) end -- Red
        if radiusBlip then SetBlipColour(radiusBlip, 1); SetBlipAlpha(radiusBlip, 140) end
    elseif state == 'CLAIMABLE' then
        if turfBlip then SetBlipColour(turfBlip, 2) end -- Green
        if radiusBlip then SetBlipColour(radiusBlip, 2); SetBlipAlpha(radiusBlip, 140) end
    elseif state == 'COOLDOWN' then
        if turfBlip then SetBlipColour(turfBlip, 39) end -- Gray/Dark
        if radiusBlip then SetBlipColour(radiusBlip, 39); SetBlipAlpha(radiusBlip, 60) end
    else
        if turfBlip then SetBlipColour(turfBlip, 5) end -- Yellow/Idle
        if radiusBlip then SetBlipColour(radiusBlip, 5); SetBlipAlpha(radiusBlip, 70) end
    end
end

-- Zone Boundary Monitor Thread
CreateThread(function()
    ZoneManager.InitBlips()

    while true do
        Wait(1000)
        local ped = PlayerPedId()
        if DoesEntityExist(ped) and not IsEntityDead(ped) then
            local pCoords = GetEntityCoords(ped)

            for id, data in pairs(Config.TurfWars) do
                local state = GlobalState[('turf_state_%s'):format(id)] or 'IDLE'
                ZoneManager.UpdateBlipState(id, state)

                -- Check boundary while War is ACTIVE
                if state == 'ACTIVE' and data.zone and data.zone.enable then
                    local dist = #(pCoords - data.coords)
                    local maxRadius = data.zone.radius or 150.0

                    if dist <= maxRadius then
                        InsideZones[id] = true
                    else
                        if InsideZones[id] then
                            -- Player crossed outside the boundary line while war active!
                            if not DamageThreads[id] then
                                DamageThreads[id] = true
                                CreateThread(function()
                                    while InsideZones[id] and (GlobalState[('turf_state_%s'):format(id)] == 'ACTIVE') do
                                        local curDist = #(GetEntityCoords(PlayerPedId()) - data.coords)
                                        if curDist > maxRadius then
                                            lib.showTextUI('[!] OUTSIDE TURF BOUNDARY! RETURN IMMEDIATELY!', {
                                                position = 'top-center',
                                                icon = 'fa-solid fa-triangle-exclamation',
                                                style = { backgroundColor = '#b30000', color = '#ffffff' }
                                            })
                                            ApplyDamageToPed(PlayerPedId(), Config.GoBackDrainPerSecond or 10, false)
                                        else
                                            lib.hideTextUI()
                                            break
                                        end
                                        Wait(1000)
                                    end
                                    lib.hideTextUI()
                                    DamageThreads[id] = nil
                                end)
                            end
                        end
                    end
                else
                    InsideZones[id] = false
                end
            end
        end
    end
end)

return ZoneManager
