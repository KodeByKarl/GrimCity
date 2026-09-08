local RESOURCE = GetCurrentResourceName()
local inside = false
local currentHouse = nil
local closestHouse
local inRange
local IsLockpicking = false
local houseObj = {}
local POIOffsets = nil
local usingAdvanced = false
local soundLevel = 0.0
local soundTriggered = false
local soundThreadActive = false
local leaveRobberyHouse, isPlayerPolice, enterRobberyHouse

-- Functions

local function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextOutline()
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

local function resetSoundMeter()
    soundLevel = 0.0
    soundTriggered = false
end

local function isAimingSilent()
    local pid = PlayerId()
    return IsPlayerFreeAiming(pid)
        or IsControlPressed(0, 25) -- INPUT_AIM
        or IsDisabledControlPressed(0, 25)
end

local function drawSoundMeter(level)
    local pct = math.max(0.0, math.min(100.0, level)) / 100.0
    local boxW, boxH = 0.18, 0.034
    local x, y = 0.5, 0.905
    local pad = 0.004

    -- container
    DrawRect(x, y, boxW, boxH, 12, 12, 14, 210)
    DrawRect(x, y - (boxH * 0.5) + 0.0012, boxW, 0.0024, 180, 40, 40, 220)

    -- fill track
    local trackW = boxW - (pad * 2)
    local trackH = 0.012
    local trackY = y + 0.004
    DrawRect(x, trackY, trackW, trackH, 30, 30, 34, 230)

    local fillW = trackW * pct
    if fillW > 0.001 then
        local r, g, b = 70, 200, 90
        if pct >= 0.75 then
            r, g, b = 220, 55, 55
        elseif pct >= 0.45 then
            r, g, b = 230, 170, 40
        end
        DrawRect(x - (trackW * 0.5) + (fillW * 0.5), trackY, fillW, trackH, r, g, b, 245)
    end

    SetTextFont(4)
    SetTextScale(0.28, 0.28)
    SetTextColour(230, 230, 230, 240)
    SetTextCentre(true)
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    local status = isAimingSilent() and 'AIMING · QUIET' or 'SOUND'
    AddTextComponentSubstringPlayerName(('%s  %.0f%%'):format(status, level))
    EndTextCommandDisplayText(x, y - 0.016)
end

local function alertPoliceNoise(house)
    TriggerServerEvent('cfx-cs-robbery:houserob:server:soundAlert', house)
    if GetResourceState('cfx-cs-dispatch') == 'started' then
        pcall(function() exports['cfx-cs-dispatch']:HouseRobbery() end)
    end
end

local function startSoundDetection(house)
    local cfg = Config.HouseRob.SoundDetection
    if not cfg or not cfg.enabled then return end
    if isPlayerPolice() then return end
    if soundThreadActive then return end

    resetSoundMeter()
    soundThreadActive = true
    ESX.Notify('House Robbery', 'Keep quiet — aim while walking to stay silent.', 'info', 6000)

    CreateThread(function()
        local lastTick = GetGameTimer()
        while inside and currentHouse == house and soundThreadActive do
            local now = GetGameTimer()
            local dt = (now - lastTick) / 1000.0
            lastTick = now
            if dt <= 0.0 then dt = 0.001 end
            if dt > 0.25 then dt = 0.25 end

            local ped = cache.ped
            local speed = GetEntitySpeed(ped)
            local moving = speed > (cfg.moveThreshold or 0.45)
            local aiming = isAimingSilent()
            local searching = IsLockpicking

            if searching or not moving or aiming then
                soundLevel = math.max(0.0, soundLevel - (cfg.idleDecay or 5.0) * dt)
            else
                local rate = cfg.walkNoise or 7.5
                if IsPedSprinting(ped) then
                    rate = cfg.sprintNoise or 28.0
                elseif IsPedRunning(ped) then
                    rate = cfg.runNoise or 18.0
                end
                soundLevel = math.min(100.0, soundLevel + rate * dt)
            end

            drawSoundMeter(soundLevel)

            if soundLevel >= 100.0 and not soundTriggered then
                soundTriggered = true
                soundThreadActive = false
                local exitHouse = currentHouse
                ESX.Notify('House Robbery', 'Too loud — neighbors heard you. Getting out!', 'error', 7000)
                alertPoliceNoise(exitHouse)
                if exitHouse then
                    leaveRobberyHouse(exitHouse)
                end
                break
            end

            Wait(0)
        end
        soundThreadActive = false
        resetSoundMeter()
    end)
end

local function leaveRobberyHouse(house)
    soundThreadActive = false
    resetSoundMeter()
    TriggerServerEvent('cfx-cs-robbery:houserob:server:leaveHouse', house)
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

enterRobberyHouse = function(house)
    -- Server sets routing bucket; client only builds interior after enter event
    playDoorSound()
    openHouseAnim()
    Wait(250)
    local coords = { x = Config.HouseRob.Houses[house].coords.x, y = Config.HouseRob.Houses[house].coords.y, z= Config.HouseRob.Houses[house].coords.z - Config.HouseRob.MinZOffset}
    local data = exports[RESOURCE]:CreateHouseRobbery(coords)
    if not data then
        print('[^3kodebykarl-robbery^0]: [House Robbery]: Error Creating House — shell model missing (furnitured_midapart)')
        TriggerServerEvent('cfx-cs-robbery:houserob:server:leaveHouse', house)
        if IsScreenFadedOut() then DoScreenFadeIn(500) end
        ESX.Notify('House Robbery', 'Interior failed to load. Restart kodebykarl-robbery so furnitured_midapart streams.', 'error', 8000)
        return
    end
    houseObj = data[1]
    POIOffsets = data[2]
    print('[^3kodebykarl-robbery^0]: [House Robbery]: Teleporting to vec3('..coords.x + POIOffsets.exit.x..', '..coords.y + POIOffsets.exit.y..', '..coords.z + POIOffsets.exit.z..')')
    SetEntityCoords(cache.ped, coords.x + POIOffsets.exit.x, coords.y + POIOffsets.exit.y, coords.z + POIOffsets.exit.z)
    inside = true
    currentHouse = house
    Wait(500)
    TriggerEvent('cfx-cs-weather:client:DisableSync')
    startSoundDetection(house)
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

--- Emergency unstuck (black screen / failed shell)
local function forceExitHouseRobbery()
    soundThreadActive = false
    resetSoundMeter()
    local house = currentHouse
    inside = false
    currentHouse = nil
    POIOffsets = nil
    TriggerServerEvent('cfx-cs-robbery:houserob:server:leaveHouse', house)
    TriggerEvent('cfx-cs-weather:client:EnableSync')
    if houseObj and next(houseObj) then
        exports[RESOURCE]:DespawnInterior(houseObj, function() end)
    end
    houseObj = {}
    if IsScreenFadedOut() then DoScreenFadeIn(0) end
    local ped = cache.ped
    if house and Config.HouseRob.Houses[house] then
        local c = Config.HouseRob.Houses[house].coords
        SetEntityCoords(ped, c.x, c.y, c.z + 0.5, false, false, false, false)
        SetEntityHeading(ped, c.h or 0.0)
    else
        -- fallback: put player slightly above current coords so they aren't underground
        local pos = GetEntityCoords(ped)
        SetEntityCoords(ped, pos.x, pos.y, pos.z + 50.0, false, false, false, false)
        local found, groundZ = GetGroundZFor_3dCoord(pos.x, pos.y, pos.z + 100.0, false)
        if found then
            SetEntityCoords(ped, pos.x, pos.y, groundZ + 1.0, false, false, false, false)
        end
    end
    ClearPedTasksImmediately(ped)
    FreezeEntityPosition(ped, false)
    ESX.Notify('House Robbery', 'Forced exit from house robbery.', 'info', 5000)
end

RegisterCommand('exithouserob', function()
    forceExitHouseRobbery()
end, false)

RegisterNetEvent('cfx-cs-robbery:houserob:client:forceExit', forceExitHouseRobbery)

local function lockpickFinish(success)
    ClearPedTasks(cache.ped)
    if not closestHouse then return end
    TriggerServerEvent('cfx-cs-robbery:houserob:server:finishLockpick', closestHouse, success == true, usingAdvanced == true)
end

isPlayerPolice = function()
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
                    local isCop = isPlayerPolice()

                    if Config.HouseRob.Houses[k]["opened"] then
                        DrawText3Ds(houseCoords.x, houseCoords.y, houseCoords.z, '~g~[E]~w~ - To Enter')
                        if IsControlJustPressed(0, 38) then
                            if Config.HouseRob.LimitTime and (GetClockHours() < Config.HouseRob.MinimumTime or GetClockHours() > Config.HouseRob.MaximumTime) then
                                ESX.Notify('House Robbery', 'You can\'t do that at this time of day.', 'error', 5000)
                            else
                                TriggerServerEvent('cfx-cs-robbery:houserob:server:enterHouse', k)
                            end
                        end
                    else
                        if isCop then
                            DrawText3Ds(houseCoords.x, houseCoords.y, houseCoords.z, '~b~[E]~w~ - Enter (Police)')
                            if IsControlJustPressed(0, 38) then
                                TriggerServerEvent('cfx-cs-robbery:houserob:server:enterHouse', k)
                            end
                        else
                            DrawText3Ds(houseCoords.x, houseCoords.y, houseCoords.z, '~r~[Locked]~w~ Press ~y~[E]~w~ to Lockpick')
                            if IsControlJustPressed(0, 38) then
                                startLockpicking(k)
                            end
                        end
                    end
                end
            end
        end
        if inside then
            Wait(0)
        elseif not inRange then
            Wait(500)
        else
            Wait(0)
        end
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

        if inside then
            Wait(0)
        else
            Wait(500)
        end
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
