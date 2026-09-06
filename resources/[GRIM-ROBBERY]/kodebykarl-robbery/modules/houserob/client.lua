local RESOURCE = GetCurrentResourceName()
local inside = false
local currentHouse = nil
local closestHouse
local inRange
local IsLockpicking = false
local houseObj = {}
local POIOffsets = nil
local usingAdvanced = false

-- Functions

local function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    BeginTextCommandDisplayText("STRING")
    SetTextCentre(true)
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(x,y,z, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

local function loadAnimDict(dict)
    RequestAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do Wait(5) end
end

local function openHouseAnim()
    loadAnimDict("anim@heists@keycard@")
    TaskPlayAnim( cache.ped, "anim@heists@keycard@", "exit", 5.0, 1.0, -1, 16, 0, 0, 0, 0 )
    Wait(400)
    ClearPedTasks(cache.ped)
end

local function playDoorSound()
    if GetResourceState('InteractSound') == 'started' then
        pcall(function() exports['InteractSound']:PlayOnSource('houses_door_open', 0.25) end)
    end
end

local function leaveRobberyHouse(house)
    TriggerServerEvent('cfx-cs-robbery:houserob:setRoutingBucket', 0)
    local ped = cache.ped
    playDoorSound()
    openHouseAnim()
    Wait(250)
    DoScreenFadeOut(250)
    Wait(500)
    exports[RESOURCE]:DespawnInterior(houseObj, function()
        local coords = vec3(Config.HouseRob.Houses[house]["coords"]["x"], Config.HouseRob.Houses[house]["coords"]["y"], Config.HouseRob.Houses[house]["coords"]["z"] + 0.3)
        TriggerEvent('cfx-cs-weather:client:EnableSync')
        Wait(250)
        DoScreenFadeIn(250)
        if Player(cache.serverId).state.dead then
            coords = vec3(Config.HouseRob.Houses[house]["coords"]["x"] + math.random(1,5), Config.HouseRob.Houses[house]["coords"]["y"] - math.random(1, 5), Config.HouseRob.Houses[house]["coords"]["z"] + 0.3)
        end
        SetEntityCoords(ped, coords.x, coords.y, coords.z)
        SetEntityHeading(ped, Config.HouseRob.Houses[house]["coords"]["h"])
    end)
    houseObj = {}
    POIOffsets = nil
    inside = false
    currentHouse = nil
end

local function enterRobberyHouse(house)
    TriggerServerEvent('cfx-cs-robbery:houserob:setRoutingBucket', Config.HouseRob.Houses[house]['routingBucket'])
    playDoorSound()
    openHouseAnim()
    Wait(250)
    local coords = { x = Config.HouseRob.Houses[house].coords.x, y = Config.HouseRob.Houses[house].coords.y, z= Config.HouseRob.Houses[house].coords.z - Config.HouseRob.MinZOffset}
    local data = exports[RESOURCE]:CreateHouseRobbery(coords)
    if not data then print('[^3kodebykarl-robbery^0]: [House Robbery]: Error Creating House ', json.encode(data)) return end
    houseObj = data[1]
    POIOffsets = data[2]
    print('[^3kodebykarl-robbery^0]: [House Robbery]: Teleporting to vec3('..coords.x + POIOffsets.exit.x..', '..coords.y + POIOffsets.exit.y..', '..coords.z + POIOffsets.exit.z..')')
    SetEntityCoords(cache.ped, coords.x + POIOffsets.exit.x, coords.y + POIOffsets.exit.y, coords.z + POIOffsets.exit.z)
    inside = true
    currentHouse = house
    Wait(500)
    TriggerEvent('cfx-cs-weather:client:DisableSync')
    CreateThread(function()
        while true do
            Wait(500)
            if Player(cache.serverId).state.dead then
                leaveRobberyHouse(currentHouse)
            end
            if not inside then break end
            if currentHouse == nil then break end
        end
    end)
end

local function lockpickFinish(success)
    ClearPedTasks(cache.ped)
    if success then
        TriggerServerEvent('cfx-cs-robbery:houserob:server:enterHouse', closestHouse)
        ESX.Notify('House Robbery', 'Lock picked successfully!', 'success', 5000)
    else
        if usingAdvanced then
            if math.random(1, 100) <= 25 then
                TriggerServerEvent("cfx-cs-robbery:houserob:server:removeAdvancedLockpick")
                ESX.Notify('House Robbery', 'The lockpick bent and broke...', 'error', 5000)
            else
                ESX.Notify('House Robbery', 'Failed to pick the lock.', 'error', 5000)
            end
        else
            if math.random(1, 100) <= 50 then
                TriggerServerEvent("cfx-cs-robbery:houserob:server:removeLockpick")
                ESX.Notify('House Robbery', 'The lockpick bent and broke...', 'error', 5000)
            else
                ESX.Notify('House Robbery', 'Failed to pick the lock.', 'error', 5000)
            end
        end
    end
end

local function isPlayerPolice()
    local pData = ESX.GetPlayerData()
    if pData and pData.job then
        local jName = tostring(pData.job.name):lower()
        if jName == 'police' or jName == 'sheriff' then
            return true
        end
    end
    return false
end

local function startLockpicking(house, isAdvanced)
    if not house then return end
    if IsLockpicking then return end

    if Config.HouseRob.LimitTime then
        if GetClockHours() < Config.HouseRob.MinimumTime or GetClockHours() > Config.HouseRob.MaximumTime then
            ESX.Notify('House Robbery', 'You can\'t do that at this time of day.', 'error', 5000)
            return
        end
    end

    local canRob = exports['cfx-cs-scoreboard']:CheckLawEnforcementByTable(Config.HouseRob.Houses[house]["requiredLE"])
    if not canRob.enable then
        return ESX.Notify('House Robbery', 'Not enough ' .. (canRob.name or 'police'), 'error', 5000)
    end

    if Config.HouseRob.Houses[house]["opened"] then
        return ESX.Notify('House Robbery', 'The door is already open.', 'info', 5000)
    end

    if isAdvanced == nil then
        local countAdv = ox_inventory:Search('count', 'advancedlockpick') or 0
        local countNorm = ox_inventory:Search('count', 'lockpick') or 0
        if countAdv > 0 then
            isAdvanced = true
        elseif countNorm > 0 then
            isAdvanced = false
        else
            return ESX.Notify('House Robbery', 'You need a lockpick to break into this house.', 'error', 5000)
        end
    end

    usingAdvanced = isAdvanced
    IsLockpicking = true

    if GetResourceState('cfx-cs-dispatch') == 'started' then
        pcall(function() exports['cfx-cs-dispatch']:HouseRobbery() end)
    end

    RequestAnimDict("veh@break_in@0h@p_m_one@")
    while not HasAnimDictLoaded("veh@break_in@0h@p_m_one@") do Wait(10) end
    TaskPlayAnim(cache.ped, "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 3.0, 3.0, -1, 16, 0, false, false, false)

    local success = false
    if usingAdvanced then
        success = lib.skillCheck({'easy', 'easy'}, {'w', 'a', 's', 'd'})
    else
        success = lib.skillCheck({'easy', 'easy', 'medium'}, {'w', 'a', 's', 'd'})
    end

    ClearPedTasks(cache.ped)
    IsLockpicking = false
    lockpickFinish(success)
end

local function searchCabin(cabin)
    local ped = cache.ped
    if math.random(1, 100) <= 85 then
        local pos = GetEntityCoords(cache.ped)
        TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
    end

    loadAnimDict('creatures@rottweiler@tricks@')
    TaskPlayAnim(cache.ped, 'creatures@rottweiler@tricks@', 'petting_franklin', 8.0, 8.0, -1, 17, 0, false, false, false)

    TriggerServerEvent('cfx-cs-robbery:houserob:server:SetBusyState', cabin, currentHouse, true)
    FreezeEntityPosition(ped, true)
    IsLockpicking = true
    local success = lib.skillCheck({'easy', 'easy', {areaSize = 60, speedMultiplier = 1}, 'easy'}, {'q', 'w', 'e'})
    if success then
        ClearPedTasks(cache.ped)
        TriggerServerEvent('cfx-cs-robbery:houserob:server:searchFurniture', cabin, currentHouse)
        Config.HouseRob.Houses[currentHouse]["furniture"][cabin]["searched"] = true
        TriggerServerEvent('cfx-cs-robbery:houserob:server:SetBusyState', cabin, currentHouse, false)
        FreezeEntityPosition(ped, false)
        SetTimeout(500, function()
            IsLockpicking = false
        end)
    else
        ClearPedTasks(cache.ped)
        TriggerServerEvent('cfx-cs-robbery:houserob:server:SetBusyState', cabin, currentHouse, false)
        ESX.Notify('House Robbery', 'Process Canceled.', 'error', 5000)
        FreezeEntityPosition(ped, false)
        SetTimeout(500, function()
            IsLockpicking = false
        end)
    end
end

-- Events

RegisterNetEvent('esx:playerLoaded', function()
    Config.HouseRob.Houses = lib.callback.await('cfx-cs-robbery:houserob:server:GetHouseConfig', false)
end)

RegisterNetEvent('cfx-cs-robbery:houserob:client:ResetHouseState', function(house)
    Config.HouseRob.Houses[house]["opened"] = false
    for _, v in pairs(Config.HouseRob.Houses[house]["furniture"]) do
        v["searched"] = false
    end
    if currentHouse ~= nil then
        leaveRobberyHouse(currentHouse)
    end
end)

RegisterNetEvent('cfx-cs-robbery:houserob:client:enterHouse', function(house)
    enterRobberyHouse(house)
end)

RegisterNetEvent('cfx-cs-robbery:houserob:client:setHouseState', function(house, state)
    Config.HouseRob.Houses[house]["opened"] = state
end)

RegisterNetEvent('cfx-cs-robbery:houserob:client:setCabinState', function(house, cabin, state)
    Config.HouseRob.Houses[house]["furniture"][cabin]["searched"] = state
end)

RegisterNetEvent('cfx-cs-robbery:houserob:client:SetBusyState', function(cabin, house, bool)
    Config.HouseRob.Houses[house]["furniture"][cabin]["isBusy"] = bool
end)

RegisterNetEvent('cfx-cs-robbery:houserob:UseLockpick', function(isAdvanced)
    if closestHouse == nil then
        return ESX.Notify('House Robbery', 'You are not near any house door.', 'error', 5000)
    end
    startLockpicking(closestHouse, isAdvanced)
end)

-- Threads

CreateThread(function()
    Wait(500)
    while true do
        inRange = false
        local PlayerPed = cache.ped
        local PlayerPos = GetEntityCoords(PlayerPed)
        closestHouse = nil
        if not inside then
            for k, _ in pairs(Config.HouseRob.Houses) do
                local houseCoords = vector3(Config.HouseRob.Houses[k]["coords"]["x"], Config.HouseRob.Houses[k]["coords"]["y"], Config.HouseRob.Houses[k]["coords"]["z"])
                local dist = #(PlayerPos - houseCoords)
                if dist <= 2.0 then
                    closestHouse = k
                    inRange = true
                    local canRob = exports['cfx-cs-scoreboard']:CheckLawEnforcementByTable(Config.HouseRob.Houses[k]["requiredLE"])
                    local isCop = isPlayerPolice()

                    if Config.HouseRob.Houses[k]["opened"] then
                        DrawText3Ds(houseCoords.x, houseCoords.y, houseCoords.z, '~g~[E]~w~ - To Enter')
                        if IsControlJustPressed(0, 38) then
                            if Config.HouseRob.LimitTime and (GetClockHours() < Config.HouseRob.MinimumTime or GetClockHours() > Config.HouseRob.MaximumTime) then
                                ESX.Notify('House Robbery', 'You can\'t do that at this time of day.', 'error', 5000)
                            else
                                enterRobberyHouse(k)
                            end
                        end
                    else
                        if isCop then
                            DrawText3Ds(houseCoords.x, houseCoords.y, houseCoords.z, '~b~[E]~w~ - Enter (Police)')
                            if IsControlJustPressed(0, 38) then
                                enterRobberyHouse(k)
                            end
                        else
                            if canRob.enable then
                                DrawText3Ds(houseCoords.x, houseCoords.y, houseCoords.z, '~r~[Locked]~w~ Press ~y~[E]~w~ to Lockpick')
                                if IsControlJustPressed(0, 38) then
                                    startLockpicking(k)
                                end
                            else
                                DrawText3Ds(houseCoords.x, houseCoords.y, houseCoords.z, '~r~[Locked]~w~ Not enough ' .. (canRob.name or 'police'))
                            end
                        end
                    end
                end
            end
        end
        if inside then Wait(500) end
        if not inRange then
            Wait(400)
        end
        Wait(1)
    end
end)

CreateThread(function()
    while true do
        local ped = cache.ped
        local pos = GetEntityCoords(ped)
        if inside then
            if #(pos - vector3(Config.HouseRob.Houses[currentHouse]["coords"]["x"] + POIOffsets.exit.x, Config.HouseRob.Houses[currentHouse]["coords"]["y"] + POIOffsets.exit.y, Config.HouseRob.Houses[currentHouse]["coords"]["z"] - Config.HouseRob.MinZOffset + POIOffsets.exit.z)) < 1.5 then
                DrawText3Ds(Config.HouseRob.Houses[currentHouse]["coords"]["x"] + POIOffsets.exit.x, Config.HouseRob.Houses[currentHouse]["coords"]["y"] + POIOffsets.exit.y, Config.HouseRob.Houses[currentHouse]["coords"]["z"] - Config.HouseRob.MinZOffset + POIOffsets.exit.z, '~g~E~w~ - To leave house')
                if IsControlJustPressed(0, 38) then
                    leaveRobberyHouse(currentHouse)
                end
            end
            if inside then
                for k, _ in pairs(Config.HouseRob.Houses[currentHouse]["furniture"]) do
                    if #(pos - vector3(Config.HouseRob.Houses[currentHouse]["coords"]["x"] + Config.HouseRob.Houses[currentHouse]["furniture"][k]["coords"]["x"], Config.HouseRob.Houses[currentHouse]["coords"]["y"] + Config.HouseRob.Houses[currentHouse]["furniture"][k]["coords"]["y"], Config.HouseRob.Houses[currentHouse]["coords"]["z"] + Config.HouseRob.Houses[currentHouse]["furniture"][k]["coords"]["z"] - Config.HouseRob.MinZOffset)) < 1 then
                        if not Config.HouseRob.Houses[currentHouse]["furniture"][k]["searched"] then
                            if not Config.HouseRob.Houses[currentHouse]["furniture"][k]["isBusy"] then
                                DrawText3Ds(Config.HouseRob.Houses[currentHouse]["coords"]["x"] + Config.HouseRob.Houses[currentHouse]["furniture"][k]["coords"]["x"], Config.HouseRob.Houses[currentHouse]["coords"]["y"] + Config.HouseRob.Houses[currentHouse]["furniture"][k]["coords"]["y"], Config.HouseRob.Houses[currentHouse]["coords"]["z"] + Config.HouseRob.Houses[currentHouse]["furniture"][k]["coords"]["z"] - Config.HouseRob.MinZOffset, 'E '..Config.HouseRob.Houses[currentHouse]["furniture"][k]["text"])
                                if not IsLockpicking then
                                    if IsControlJustReleased(0, 38) then
                                        searchCabin(k)
                                    end
                                end
                            else
                                DrawText3Ds(Config.HouseRob.Houses[currentHouse]["coords"]["x"] + Config.HouseRob.Houses[currentHouse]["furniture"][k]["coords"]["x"], Config.HouseRob.Houses[currentHouse]["coords"]["y"] + Config.HouseRob.Houses[currentHouse]["furniture"][k]["coords"]["y"], Config.HouseRob.Houses[currentHouse]["coords"]["z"] + Config.HouseRob.Houses[currentHouse]["furniture"][k]["coords"]["z"] - Config.HouseRob.MinZOffset, 'Searching...')
                            end
                        else
                            DrawText3Ds(Config.HouseRob.Houses[currentHouse]["coords"]["x"] + Config.HouseRob.Houses[currentHouse]["furniture"][k]["coords"]["x"], Config.HouseRob.Houses[currentHouse]["coords"]["y"] + Config.HouseRob.Houses[currentHouse]["furniture"][k]["coords"]["y"], Config.HouseRob.Houses[currentHouse]["coords"]["z"] + Config.HouseRob.Houses[currentHouse]["furniture"][k]["coords"]["z"] - Config.HouseRob.MinZOffset, 'Empty.')
                        end
                    end
                end
            end
        end

        if not inside then
            Wait(500)
        end
        Wait(3)
    end
end)

-- Util Command (can be commented out - used for setting new spots in the config)

-- RegisterCommand('gethroffset', function()
--     local coords = GetEntityCoords(cache.ped)
--     local houseCoords = vector3(
--         Config.HouseRob.Houses[currentHouse]["coords"]["x"],
--         Config.HouseRob.Houses[currentHouse]["coords"]["y"],
--         Config.HouseRob.Houses[currentHouse]["coords"]["z"] - Config.HouseRob.MinZOffset
--     )
--     if inside then
--         local xdist = coords.x - houseCoords.x
--         local ydist = coords.y - houseCoords.y
--         local zdist = coords.z - houseCoords.z
--         print('X: '..xdist)
--         print('Y: '..ydist)
--         print('Z: '..zdist)
--     end
-- end, false)
