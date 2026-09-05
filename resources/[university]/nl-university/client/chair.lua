local _origPrint = print
local function debugPrint(...)
    if Config and Config.debug then
        _origPrint(...)
    end
end
local function print(...)
    if Config and Config.debug then
        _origPrint(...)
    end
end

-- Sitting state (per player)
local sitting = false
local tpCoords = nil
local currentZone = nil

-- Define multiple sitting zones with heading 22 for all
local sittingZones = sittingZones or {
    { name = "1", coords = vector4(-1666.6, 185.2, 66.1, 284.66), radius = 0.35, targetId = nil },
    { name = "2", coords = vector4(-1665.6, 183.1, 66.2, 284.66), radius = 0.35, targetId = nil },

    -- New Zones
    { name = "3", coords = vector4(-1664.7, 181.3, 66.25, 284.66), radius = 0.3, targetId = nil },
    { name = "4", coords = vector4(-1666.35, 180.5, 66.15, 284.66), radius = 0.3, targetId = nil },
    { name = "5_1", coords = vector4(-1668.3, 179.6, 66.2, 284.66), radius = 0.25, targetId = nil },
    { name = "5_2", coords = vector4(-1669.15, 181.5, 66.2, 284.66), radius = 0.25, targetId = nil },

    -- Additional new zones provided
    { name = "123", coords = vector4(-1667.3, 182.35, 66.2, 284.66), radius = 0.25, targetId = nil },
    { name = "61234", coords = vector4(-1668.3, 184.5, 66.2, 284.66), radius = 0.3, targetId = nil },
    { name = "5123123", coords = vector4(-1670.1, 183.6, 66.25, 284.66), radius = 0.25, targetId = nil },

    -- Additional zones to be added with heading 284.66
    { name = "0", coords = vector4(-1654.4, 158.9, 66.1, 284.66), radius = 0.3, targetId = nil },
    { name = "0", coords = vector4(-1655.85, 158.15, 66.2, 284.66), radius = 0.3, targetId = nil },
    { name = "0", coords = vector4(-1657.75, 157.25, 66.2, 284.66), radius = 0.3, targetId = nil },
    { name = "0", coords = vector4(-1656.75, 155.35, 66.15, 284.66), radius = 0.25, targetId = nil },
    { name = "0", coords = vector4(-1654.9, 156.2, 66.2, 284.66), radius = 0.3, targetId = nil },
    { name = "0", coords = vector4(-1653.4, 156.9, 66.1, 284.66), radius = 0.3, targetId = nil },
    { name = "0", coords = vector4(-1652.3, 154.7, 66.2, 284.66), radius = 0.25, targetId = nil },
    { name = "0", coords = vector4(-1654.0, 153.95, 66.25, 284.66), radius = 0.3, targetId = nil },
    { name = "0", coords = vector4(-1655.7, 153.1, 66.2, 284.66), radius = 0.3, targetId = nil },

    -- New zones added from the latest list
    { name = "1", coords = vector4(-1644.05, 158.35, 66.15, 115.92), radius = 0.3, targetId = nil },
    { name = "1", coords = vector4(-1642.3, 159.2, 66.2, 115.92), radius = 0.3, targetId = nil },
    { name = "1", coords = vector4(-1640.55, 159.95, 66.2, 115.92), radius = 0.25, targetId = nil },
    { name = "1", coords = vector4(-1641.6, 162.3, 66.1, 115.92), radius = 0.3, targetId = nil },
    { name = "1", coords = vector4(-1643.4, 161.5, 66.1, 115.92), radius = 0.3, targetId = nil },
    { name = "1", coords = vector4(-1645.1, 160.6, 66.2, 115.92), radius = 0.3, targetId = nil },
    { name = "1", coords = vector4(-1646.1, 162.7, 66.2, 115.92), radius = 0.3, targetId = nil },
    { name = "1", coords = vector4(-1644.3, 163.5, 66.2, 115.92), radius = 0.3, targetId = nil },
    { name = "1", coords = vector4(-1642.5, 164.4, 66.25, 115.92), radius = 0.3, targetId = nil },

    -- Newly added zones (converted to vector4 with heading 284.66 for consistency)
    { name = "1", coords = vector4(-1662.05, 182.25, 61.2, 115.3832), radius = 0.35, targetId = nil },
    { name = "2", coords = vector4(-1663.05, 184.3, 61.3, 115.3832), radius = 0.3, targetId = nil },
    { name = "3", coords = vector4(-1663.95, 186.25, 61.3, 115.3832), radius = 0.3, targetId = nil },
    { name = "5", coords = vector4(-1665.7, 185.45, 61.3, 115.3832), radius = 0.3, targetId = nil },
    { name = "12", coords = vector4(-1664.75, 183.45, 61.35, 115.3832), radius = 0.3, targetId = nil },
    { name = "15", coords = vector4(-1663.75, 181.4, 61.3, 115.3832), radius = 0.35, targetId = nil },
    { name = "151", coords = vector4(-1665.35, 180.6, 61.35, 115.3832), radius = 0.3, targetId = nil },
    { name = "1212", coords = vector4(-1666.3, 182.65, 61.3, 115.3832), radius = 0.3, targetId = nil },
    { name = "512", coords = vector4(-1667.3, 184.7, 61.3, 115.3832), radius = 0.3, targetId = nil },
}

-- Function to handle sitting on a chair
---@param coords vector4
---@param zoneName string
local function sitChair(coords, zoneName)
    if sitting then return end

    local ped = PlayerPedId()
    tpCoords = GetEntityCoords(ped)
    local currentScenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER'
    TaskStartScenarioAtPosition(ped, currentScenario, coords.x, coords.y, coords.z, coords.w, 0, true, true)

    sitting = true
    currentZone = zoneName

    -- Thread to handle "Get Up" prompt and state
    CreateThread(function()
        while sitting do
            Wait(0)
            lib.showTextUI('Press E to Get Up', {
                position = Config.textuiPos,
                icon = 'fa-solid fa-arrow-up'
            })
            if IsControlJustPressed(0, Config.sitsGetUpKey) or not IsPedUsingScenario(ped, currentScenario) then
                sitting = false
                currentZone = nil
                lib.hideTextUI()
                ClearPedTasks(ped)
                SetEntityCoords(ped, tpCoords.x, tpCoords.y, tpCoords.z - 0.3, true, false, false, false)
                break
            end
        end
    end)
end

-- Function to create target zones based on the configured system
-- Function to create target zones based on the configured system
local function createTargetZones()
    print("Target System Configured: ", Config.TargetSystem) -- Debug line
    if Config.TargetSystem == "ox_target" and exports and exports.ox_target then
        for _, zone in ipairs(sittingZones or {}) do
            zone.targetId = exports.ox_target:addSphereZone({
                coords = zone.coords,
                radius = zone.radius,
                debug = false,
                options = {
                    {
                        name = 'sit_down_' .. zone.name,
                        label = 'Sit Down',
                        icon = 'fa-solid fa-chair',
                        canInteract = function(entity, distance, coords, name)
                            return not sitting
                        end,
                        onSelect = function(data)
                            sitChair(zone.coords, zone.name)
                        end
                    }
                }
            })
        end
        print("Sitting zones created with ox_target.")
    elseif Config.TargetSystem == "qb-target" and exports and exports['qb-target'] then
        for _, zone in ipairs(sittingZones or {}) do
            pcall(function()
                exports['qb-target']:AddCircleZone(zone.name, vector3(zone.coords.x, zone.coords.y, zone.coords.z), zone.radius, {
                name = zone.name,
                debugPoly = false,
                useZ = true
            }, {
                options = {
                    {
                        type = "client",
                        event = "sitChairEvent",
                        icon = "fa-solid fa-chair",
                        label = "Sit Down",
                        zoneName = zone.name, -- Explicitly pass the zone name
                        canInteract = function(entity, distance, data)
                            return not sitting
                        end
                    }
                },
                distance = 2.0
            })
            -- Store the zone name as targetId for cleanup purposes
            zone.targetId = zone.name
            end)
        end
        print("Sitting zones created with qb-target.")
    else
        print("Target system not found or invalid. Sitting zones will not be created. Configured system: " .. tostring(Config.TargetSystem))
    end
end

-- Register event for qb-target
RegisterNetEvent("sitChairEvent")
AddEventHandler("sitChairEvent", function(data)
    print("sitChairEvent triggered with data: ", json.encode(data)) -- Debug line
    local zoneName = data.zoneName
    if not zoneName then
        print("Error: No zoneName provided in sitChairEvent data.")
        return
    end

    -- Find the zone based on the name to get the coords
    for _, zone in ipairs(sittingZones or {}) do
        if zone.name == zoneName then
            print("Found matching zone: ", zone.name) -- Debug line
            sitChair(zone.coords, zone.name)
            return
        end
    end
    print("Error: No matching zone found for zoneName: ", zoneName)
end)

-- Create target zones on resource start
CreateThread(function()
    createTargetZones()
end)

-- Clean up targets on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if Config.TargetSystem == "ox_target" and exports and exports.ox_target then
            for _, zone in ipairs(sittingZones or {}) do
                if zone.targetId then
                    exports.ox_target:removeZone(zone.targetId)
                end
            end
        elseif Config.TargetSystem == "qb-target" and exports and exports['qb-target'] then
            for _, zone in ipairs(sittingZones or {}) do
                if zone.targetId then
                    exports['qb-target']:RemoveZone(zone.targetId)
                end
            end
        end
        if sitting then
            sitting = false
            currentZone = nil
            lib.hideTextUI()
            ClearPedTasks(PlayerPedId())
        end
    end
end)