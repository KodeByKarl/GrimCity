ESX = ESX or exports["es_extended"]:getSharedObject()

local isSpawnOpen = false
local isForced    = false  -- true when timer expired; player must pick a location

local function lockGameMap()
    SetBigmapActive(false, false)
    DisplayRadar(false)
end

local function applySpawnFocus()
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    lockGameMap()
end

local function clearSpawnFocus()
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    lockGameMap()
end

-- Keep the gameplay camera (no aerial spawn cam)
local function DestroySpawnCam()
    RenderScriptCams(false, false, 0, true, true)
end

-- Open Spawn Menu Function
local function OpenSpawnMenu(isDeathCam, respawnTimer, allowEarlySpawn, isBleedout)
    if isSpawnOpen then return end
    -- Lock immediately so a second H cannot start another open
    isSpawnOpen = true
    isForced    = (allowEarlySpawn == false)   -- forced when timer ran out / bleedout

    -- Hide deathscreen first so it cannot steal NUI focus / reopen a script cam
    local uiName = GetCurrentResourceName()
    pcall(function()
        exports[uiName]:HideDeathScreen()
    end)

    applySpawnFocus()
    -- Notify systems (e.g. turfwars leave-zone kill) that spawn/STL UI is open
    TriggerEvent('cfx-keydi-ambulance:isSelecting', true)
    if GetResourceState('cfx-keydi-ambulance') == 'started' then
        pcall(function()
            exports['cfx-keydi-ambulance']:HideEMSUI(true)
        end)
    end

    local playerData = ESX.GetPlayerData()
    local jobName = playerData and playerData.job and playerData.job.name or nil

    -- Filter: public locations + job-restricted (e.g. police only)
    local locations = {}
    for _, loc in ipairs(Config.Spawn.Locations) do
        if not loc.jobs then
            locations[#locations + 1] = loc
        elseif jobName then
            for _, allowed in ipairs(loc.jobs) do
                if allowed == jobName then
                    locations[#locations + 1] = loc
                    break
                end
            end
        end
    end

    local recap = nil
    local ok, result = pcall(function()
        return exports[uiName]:GetLastRecap()
    end)
    if ok and type(result) == "table" then
        recap = result
    end

    SendNUIMessage({
        action = "cfx-keydi-spawn:show",
        data = {
            isDeathCam      = (isDeathCam == nil) and false or isDeathCam,
            respawnTimer    = respawnTimer or Config.Spawn.RespawnTimer or 135,
            allowEarlySpawn = (allowEarlySpawn == nil) and true or (allowEarlySpawn == true),
            isBleedout      = isBleedout == true,
            locations       = locations,
            recap           = recap,
        }
    })

    -- Stay on the gameplay camera (no sky / aerial cam)
    DestroySpawnCam()
    applySpawnFocus()
end

-- Force reopen (timer expired while minimized, or upgrade early menu → forced)
local function ForceOpenSpawnMenu(isDeathCam, respawnTimer, allowEarlySpawn, isBleedout)
    if isSpawnOpen then
        isSpawnOpen = false
        isForced = false
        clearSpawnFocus()
        SendNUIMessage({ action = "cfx-keydi-spawn:hide" })
        DestroySpawnCam()
    end
    OpenSpawnMenu(isDeathCam, respawnTimer, allowEarlySpawn, isBleedout)
end

-- Stay on the current spawn UI but switch to bleedout / forced phase
local function SetSpawnPhase(respawnTimer, allowEarlySpawn, isBleedout)
    if not isSpawnOpen then
        OpenSpawnMenu(true, respawnTimer, allowEarlySpawn, isBleedout)
        return
    end
    isForced = (allowEarlySpawn == false)
    applySpawnFocus()
    SendNUIMessage({
        action = "cfx-keydi-spawn:setPhase",
        data = {
            respawnTimer = math.max(0, tonumber(respawnTimer) or 0),
            allowEarlySpawn = allowEarlySpawn == true,
            isBleedout = isBleedout == true,
        },
    })
end

-- Close Spawn Menu Function (blocked when forced — player must choose)
local function CloseSpawnMenu()
    if not isSpawnOpen then return end
    if isForced then return end   -- cannot close without selecting
    isSpawnOpen = false
    isForced    = false
    clearSpawnFocus()
    SendNUIMessage({ action = "cfx-keydi-spawn:hide" })
    DestroySpawnCam()
    if GetResourceState('cfx-keydi-ambulance') == 'started' then
        pcall(function()
            exports['cfx-keydi-ambulance']:HideEMSUI(false)
        end)
    end
    SetTimeout(5000, function()
        TriggerEvent('cfx-keydi-ambulance:isSelecting', false)
    end)
end

-- Force-close after successful spawn selection (bypasses forced guard)
local function ForceCloseSpawnMenu()
    isSpawnOpen = false
    isForced    = false
    clearSpawnFocus()
    SendNUIMessage({ action = "cfx-keydi-spawn:hide" })
    DestroySpawnCam()
    -- Keep protected briefly while RespawnAtLocation teleports out of turf
    SetTimeout(15000, function()
        TriggerEvent('cfx-keydi-ambulance:isSelecting', false)
    end)
end

local function UpdateSpawnTimer(seconds)
    if not isSpawnOpen then return end
    SendNUIMessage({
        action = "cfx-keydi-spawn:updateTimer",
        data = { respawnTimer = math.max(0, tonumber(seconds) or 0) },
    })
end

local function UpdateSpawnRecap(recap)
    if not isSpawnOpen then return end
    SendNUIMessage({
        action = "cfx-keydi-spawn:updateRecap",
        data = { recap = recap },
    })
end

-- Exports and Commands
exports('OpenSpawnMenu', OpenSpawnMenu)
exports('ForceOpenSpawnMenu', ForceOpenSpawnMenu)
exports('SetSpawnPhase', SetSpawnPhase)
exports('CloseSpawnMenu', CloseSpawnMenu)
exports('ForceCloseSpawnMenu', ForceCloseSpawnMenu)
exports('UpdateSpawnTimer', UpdateSpawnTimer)
exports('UpdateSpawnRecap', UpdateSpawnRecap)
exports('IsSpawnMenuOpen', function()
    return isSpawnOpen
end)

RegisterCommand(Config.Spawn.OpenCommand or "spawnselector", function()
    OpenSpawnMenu(false)
end, false)

-- NUI Callbacks
RegisterNUICallback("cfx-keydi-spawn:close", function(data, cb)
    -- Blocked when forced (timer expired) — player must select a location
    if isForced then
        cb("blocked")
        return
    end
    CloseSpawnMenu()
    cb("ok")
end)

-- Preview no longer moves the camera — stay at death/current spot until Spawn Here
RegisterNUICallback("cfx-keydi-spawn:previewLocation", function(_, cb)
    cb("ok")
end)

RegisterNUICallback("cfx-keydi-spawn:selectSpawn", function(data, cb)
    if not data or not data.coords then
        cb("error")
        return
    end

    -- Block job-restricted spawns if player job does not match
    if data.id then
        for _, loc in ipairs(Config.Spawn.Locations) do
            if loc.id == data.id and loc.jobs then
                local playerData = ESX.GetPlayerData()
                local jobName = playerData and playerData.job and playerData.job.name or nil
                local allowed = false
                if jobName then
                    for _, j in ipairs(loc.jobs) do
                        if j == jobName then
                            allowed = true
                            break
                        end
                    end
                end
                if not allowed then
                    cb("denied")
                    return
                end
                break
            end
        end
    end

    local coords = data.coords
    local isAmbulanceDead = GetResourceState('cfx-keydi-ambulance') == 'started'
        and exports['cfx-keydi-ambulance']:isDead()

    ForceCloseSpawnMenu()

    if isAmbulanceDead then
        exports['cfx-keydi-ambulance']:RespawnAtLocation(coords)
    else
        DoScreenFadeOut(500)
        Wait(600)

        local ped = PlayerPedId()

        FreezeEntityPosition(ped, true)
        SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
        SetEntityHeading(ped, coords.heading or 0.0)

        if IsEntityDead(ped) then
            NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, coords.heading or 0.0, true, false)
            ClearPlayerWantedLevel(PlayerId())
            Wait(300)
            if GetResourceState('illenium-appearance') == 'started' then
                TriggerEvent('illenium-appearance:client:reloadSkin', true)
                Wait(400)
            end
            ped = PlayerPedId()
            SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
            SetEntityHeading(ped, coords.heading or 0.0)
        end

        DestroySpawnCam()

        Wait(500)
        FreezeEntityPosition(ped, false)
        DoScreenFadeIn(800)

        if GetResourceState('pma-voice') == 'started' then
            pcall(function()
                exports['pma-voice']:reinitVoice('spawn-selector')
            end)
        end
    end

    cb("ok")
end)

-- Event Handlers
RegisterNetEvent("cfx-keydi-spawn:client:open", function(isDeathCam, respawnTimer, allowEarlySpawn)
    OpenSpawnMenu(isDeathCam, respawnTimer, allowEarlySpawn)
end)

-- Revive / respawn must always close the map UI (otherwise it stays until /sleep)
local function closeOnAlive()
    if not isSpawnOpen then return end
    isForced = false
    ForceCloseSpawnMenu()
end

AddEventHandler("esx:onPlayerSpawn", closeOnAlive)
AddEventHandler("playerSpawned", closeOnAlive)
RegisterNetEvent("cfx-keydi-ambulance:revive", closeOnAlive)
