ESX = exports['es_extended']:getSharedObject()
local Vars = require 'helpers.vars'
local helpers = require 'helpers.game'
local configs = require 'shared.config'
local client = require 'helpers.client'
local nui = require 'shared.nui'
local DeathCam = require 'helpers.deathcam'

-- Spawn timer UI waits for the death recap (ConfigDeathScreen.DisplayDuration)
local SPAWN_BAR_DELAY_MS = 10000
local isChecked = false
local onDeath

local newTimer = nil

function ResetDeathTimer()
  newTimer = nil
  print('[cfx-keydi-ambulance]: Resetting Spawn Timer')
end

exports('ResetDeathTimer', ResetDeathTimer)

function OverrideDeathTimer(newTime)
  newTimer = math.max(0, ESX.Math.Round(newTime / 1000))
  local sMinute, sSecond = helpers.SecondsToClock(newTimer)
  print('[cfx-keydi-ambulance]: Setting Spawn Timer to '..sMinute..':'..sSecond)
end

exports('OverrideDeathTimer', OverrideDeathTimer)

local function restoreDeathOnLoad()
    CreateThread(function()
        local timeout = GetGameTimer() + 15000
        while GetGameTimer() < timeout do
            local ped = PlayerPedId()
            if ped and ped ~= 0 and DoesEntityExist(ped) then
                break
            end
            Wait(100)
        end

        if Vars.isReviving then return end

        Vars.CaptureDeathZone(PlayerPedId())

        TriggerServerEvent('cfx-keydi-ambulance:setPlayerDeathStatus', true, 'restore')

        local ped = PlayerPedId()
        if ped and ped ~= 0 then
            SetEntityInvincible(ped, false)
            SetPlayerInvincible(PlayerId(), false)
            SetEntityHealth(ped, 0)
        end

        Wait(400)
        if Vars.isReviving then return end

        -- Spawn/appearance can stand them back up; force the death state + lie-down pose
        if not Vars.isDead then
            onDeath({ restored = true })
        else
            client.StartDeathPose()
        end

        -- Rebind mumble after reconnect, then deafen (dead players cannot hear).
        if GetResourceState('pma-voice') == 'started' then
            Wait(600)
            pcall(function()
                exports['pma-voice']:startJoinHandshake('death-restore')
            end)
        end
        client.SetDeathHearing(false)
    end)
end

AddEventHandler('ESX:Client:PlayerLoaded', function()
    local resource = GetInvokingResource()
    if resource == nil or resource ~= 'es_extended' then return end
    if isChecked then return end
    isChecked = true
    ESX.TriggerServerCallback('cfx-keydi-ambulance:checkDeathStatus', function(isDead)
       if isDead then
            restoreDeathOnLoad()
        else
            TriggerServerEvent('cfx-keydi-ambulance:checkBed')
            -- Alive on load: clear any stuck mute from previous death session
            TriggerServerEvent('cfx-keydi-ambulance:ensureVoiceUnmute')
            if GetResourceState('pma-voice') == 'started' then
                pcall(function()
                    exports['pma-voice']:startJoinHandshake('alive-load')
                end)
            end
        end
    end)
end)

-- Real ESX load event (ESX:Client:PlayerLoaded is never fired by this server's es_extended)
RegisterNetEvent('esx:playerLoaded', function()
    if isChecked then return end
    isChecked = true
    ESX.TriggerServerCallback('cfx-keydi-ambulance:checkDeathStatus', function(isDead)
        if isDead then
            restoreDeathOnLoad()
        else
            TriggerServerEvent('cfx-keydi-ambulance:checkBed')
            TriggerServerEvent('cfx-keydi-ambulance:ensureVoiceUnmute')
            if GetResourceState('pma-voice') == 'started' then
                pcall(function()
                    exports['pma-voice']:startJoinHandshake('alive-load')
                end)
            end
        end
    end)
end)

RegisterNetEvent('esx:onPlayerLogout', function()
    client.StopDeathPose()
    isChecked = false
    Vars.isDead = false
end)

CreateThread(function()
    while true do
        local sleep = 500
        if Vars.isDead then
            sleep = 0
            DisableAllControlActions(0)
            EnableControlAction(0, 47, true)  -- G / 911 dispatch
            EnableControlAction(0, 245, true) -- F10 / screenshot
            -- Do not enable H (74): GTA can treat it as pause/map.
            -- Spawn selector still reads IsDisabledControlJustReleased(0, 74).
        end
        Wait(sleep)
    end
end)

function GetDeathTimer()
    local bankData = ESX.GetAccount('bank')
    local default = Vars.diedInRedZone
        and ESX.Math.Round((configs.General.RedZoneRespawnTimer or 60000) / 1000)
        or ESX.Math.Round((configs.General.RespawnTimer or 300000) / 1000)
    local bankNegative = ESX.Math.Round((configs.General.RespawnWithNegativeBank or 300000) / 1000)
    if newTimer ~= nil then
        return newTimer
    end
    return (bankData and bankData?.money <= -1 and bankNegative or default)
end

local function isDead()
    return Vars.isDead
end

exports('isDead', isDead)

local HideNUI = false
local displayed = false
local deathUiMode = 'full' -- 'full' | 'short'
local selectedRespawnId = nil
local spawnCfg = require 'shared.spawn'

local function diedInBlaine()
    return Vars.DiedInBlaine()
end

local function buildRespawnLocationsPayload()
    local list = {}
    local defaultFine = configs.General.RespawnFine or 1000
    local blaine = diedInBlaine()
    for id, data in pairs(spawnCfg.Locations or {}) do
        if not data.hidden then
            local zone = data.zone
            local include = true
            if zone == 'city' then
                include = not blaine
            elseif zone == 'blaine' then
                include = blaine
            end
            if include then
                list[#list + 1] = {
                    id = id,
                    label = data.label or id,
                    area = data.area or '',
                    cost = tonumber(data.cost) or defaultFine,
                }
            end
        end
    end
    table.sort(list, function(a, b)
        return a.label < b.label
    end)
    return list
end

local function setDeathUiFocus(mode)
    deathUiMode = mode
    -- Never use SetNuiFocusKeepInput(true) — it hard-crashes some FiveM builds.
    if mode == 'full' then
        SetNuiFocus(true, true)
    else
        SetNuiFocus(false, false)
    end
    SetNuiFocusKeepInput(false)
end

local function HideEMSUI(bool)
    if bool then
        DeathCam.Stop()
        SendNUIMessage({ type = 'HideUI' })
        client.blurOut()
        deathUiMode = 'full'
        selectedRespawnId = nil
        displayed = false
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
    else
        client.blurIn()
        displayed = false
        selectedRespawnId = nil
    end
    HideNUI = bool
end

exports('HideEMSUI', HideEMSUI)

local function pushSpawnTimer(_seconds)
end

local function isSpawnMenuOpen()
    return deathUiMode == 'full'
end

local function openSpawnSelector(_isDeathCam, _respawnTimer, _allowEarlySpawn, _isBleedout)
    setDeathUiFocus('full')
    SendNUIMessage({ type = 'updateDeathScreen', update = 'mode', mode = 'full' })
    return true
end

local function pushDeathBar(currentTimer, inBleedout)
    if HideNUI then return end
    if not displayed then
        local total = GetDeathTimer()
        SendNUIMessage({
            type = 'ShowUI',
            time = currentTimer,
            totalTime = total,
            locations = buildRespawnLocationsPayload(),
            mode = 'full',
        })
        displayed = true
        if not selectedRespawnId then
            local locs = buildRespawnLocationsPayload()
            selectedRespawnId = locs[1] and locs[1].id or nil
        end
        CreateThread(function()
            Wait(50)
            if Vars.isDead and displayed and not HideNUI then
                setDeathUiFocus('full')
            end
        end)
    end
    SendNUIMessage({
        type = 'updateDeathScreen',
        update = 'text',
        bleedout = inBleedout == true,
    })
    SendNUIMessage({
        type = 'updateDeathScreen',
        update = 'time',
        time = currentTimer,
    })
end

local function DeathTimer()
    -- Shared timer upvalue — both threads read/write this same variable
    local currentTimer = GetDeathTimer()
    local bleedoutSecs = ESX.Math.Round((configs.General.BleedoutTimer or 0) / 1000)
    local spawnOpened  = false
    local lastHPress   = 0
    local inBleedout   = false
    local spawnBarReady = false
    displayed = false
    selectedRespawnId = nil
    Vars.stlUnlocked = false
    deathUiMode = 'full'
    DeathCam.Stop()

    -- ── Thread 1: death recap first, then spawn bar + bleedout ──────────────
    CreateThread(function()
        local showAt = GetGameTimer() + SPAWN_BAR_DELAY_MS

        local function revealBar()
            if spawnBarReady or not Vars.isDead then return end
            spawnBarReady = true
            pushDeathBar(currentTimer, inBleedout)
        end

        -- Countdown starts immediately; bar waits for the death recap
        while currentTimer > 0 and Vars.isDead do
            if GetGameTimer() >= showAt then
                revealBar()
            end
            Wait(1000)
            if not Vars.isDead then
                client.HideNUI()
                return
            end

            currentTimer = currentTimer - 1
            Vars.stlUnlocked = false
            if spawnBarReady then
                pushDeathBar(currentTimer, false)
            end

            if isSpawnMenuOpen() then
                spawnOpened = true
                pushSpawnTimer(currentTimer)
            end
        end

        if not Vars.isDead then
            client.HideNUI()
            return
        end

        -- STL wait over — bleedout countdown. Confirm unlocks so players can respawn.
        inBleedout = true
        currentTimer = math.max(0, bleedoutSecs)
        Vars.stlUnlocked = true
        if GetGameTimer() >= showAt then
            revealBar()
        else
            while GetGameTimer() < showAt and Vars.isDead do
                Wait(100)
            end
            if Vars.isDead then
                revealBar()
            end
        end
        if not Vars.isDead then
            client.HideNUI()
            return
        end

        pushDeathBar(currentTimer, true)
        spawnOpened = openSpawnSelector(true, currentTimer, false, true) or spawnOpened

        if currentTimer <= 0 then
            pushSpawnTimer(0)
            return
        end

        while currentTimer > 0 and Vars.isDead do
            Wait(1000)
            if not Vars.isDead then
                client.HideNUI()
                return
            end

            currentTimer = currentTimer - 1
            Vars.stlUnlocked = true
            pushDeathBar(currentTimer, true)

            -- Keep user's Full/Short choice — do not force Full back open every tick
            if isSpawnMenuOpen() then
                spawnOpened = true
                pushSpawnTimer(currentTimer)
            end
        end

        if Vars.isDead and currentTimer <= 0 then
            pushSpawnTimer(0)
            client.RemoveRPDeath()
        end
    end)

    -- ── Thread 2: Poll [G] freecam / [H] spawn while down ───────────────────
    CreateThread(function()
        while Vars.isDead do
            -- Soften when Full panel has focus (no need for per-frame poll)
            if deathUiMode == 'full' then
                Wait(200)
            else
                Wait(0)
            end

            if not Vars.isDead then break end

            -- [G] = death freecam (only after spawn timer UI is up, short mode)
            if spawnBarReady and deathUiMode ~= 'full' and IsControlJustReleased(0, 47) then
                DeathCam.Toggle()
            end

            -- [H] key (74) = reopen Full Medical Panel from short bar
            local pressedH = IsDisabledControlJustReleased(0, 74) or IsControlJustReleased(0, 74)
            if pressedH and spawnBarReady and deathUiMode ~= 'full' then
                local now = GetGameTimer()
                if now - (lastHPress or 0) >= 1200 then
                    lastHPress = now
                    openSpawnSelector(true, math.max(0, currentTimer), false, inBleedout)
                end
            end
        end

        DeathCam.Stop()
    end)
end


local function AutoStuck(ped)
    Vars.deathToken = (Vars.deathToken or 0) + 1
    local token = Vars.deathToken
    CreateThread(function()
        Wait(2000)
        -- Cancelled if revived / new death happened
        if token ~= Vars.deathToken or Vars.isReviving or not Vars.isDead then return end
        ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local x, y, z = client.SafeReviveCoords(coords.x, coords.y, coords.z, ped)
        SetEntityCoordsNoOffset(ped, x, y, z, false, false, false)
        client.StartDeathPose()
    end)
end

onDeath = function(data)
    -- Ignore death events fired while / during revive (esx death-monitor race)
    if Vars.isReviving then return end

    local inPvp = LocalPlayer.state.inPvp or LocalPlayer.state.isInPvp

    if Vars.isDead then
        client.StartDeathPose()
        return
    end

    local ped = cache.ped
    -- Capture damage bone before other scripts clear it. GTA reports facial bones on headshots, not only SKEL_Head.
    local hit, bone = GetPedLastDamageBone(ped)
    if (not hit or not bone or bone == 0) and Vars.lastHitBone and (GetGameTimer() - (Vars.lastHitBoneAt or 0)) < 1500 then
        bone = Vars.lastHitBone
    end
    bone = tonumber(bone) or 0
    if bone ~= 0 then
        if Config.ToBoneId then
            bone = Config.ToBoneId(bone)
        end
        Vars.lastHitBone = bone
        Vars.lastHitBoneAt = GetGameTimer()
    end

    if not inPvp then
        AutoStuck(ped)
    end
    Vars.isDead = true
    local _, deathCoords = Vars.CaptureDeathZone(PlayerPedId())
    local zoneDesc = Vars.diedInRedZone and 'RedZone (1 Min Respawn • $15,000 Fine)' or (
        Vars.deathInSandy
            and ('Paleto / Sandy  (5 Min Respawn • $15,000 Fine | Y %.0f)'):format(deathCoords.y)
            or ('City  (5 Min Respawn • $15,000 Fine | Y %.0f)'):format(deathCoords.y)
    )
    lib.notify({
        title = 'STL Zone',
        description = zoneDesc,
        type = Vars.diedInRedZone and 'error' or (Vars.deathInSandy and 'success' or 'inform'),
        duration = 8000,
    })
    client.StartDeathPose()
    client.SetDeathHearing(false)
    TriggerServerEvent('cfx-keydi-ambulance:setPlayerDeathStatus', true)
    if GetResourceState('ox_inventory') == 'started' then
        exports.ox_inventory:closeInventory()
    end
    LocalPlayer.state:set('invBusy', true, true)
    if GetResourceState('cfx-keydi-radio') == 'started' then
        exports['cfx-keydi-radio']:leaveRadio()
    elseif GetResourceState('ac_radio') == 'started' then
        exports['ac_radio']:leaveRadio()
    end
    if GetResourceState('rryban_priority') == 'started' then
        local isVisible = exports['rryban_priority']:GetUIState()
        if isVisible then
           exports['rryban_priority']:HideUI(false)
        end
    end
    if GetResourceState('ox_target') == 'started' then
        pcall(function()
            exports.ox_target:disableTargeting(true)
        end)
    end
    if GetResourceState('jg-hud') == 'started' then
        pcall(function()
            exports['jg-hud']:toggleHud(false)
        end)
    end
    Vars.Status.multiplier = 2.0
    Vars.Status.blood = 100
    Vars.Status.health = GetEntityHealth(ped)
    Vars.Status.area = 'LEGS/ARMS'
    Vars.Status.bleeding = 1
    local part = Config.Bones and Config.Bones[bone]
    if part == 'HEAD' or part == 'NECK' or (Config.IsHeadArea and Config.IsHeadArea(bone)) then
        Vars.Status.multiplier = 0.0
        Vars.Status.bleeding = 5
        Vars.Status.area = "HEAD"
    elseif Vars.Status.bone[bone] or part == 'SPINE' or part == 'UPPER_BODY' or part == 'LOWER_BODY' then
        Vars.Status.multiplier = 1.0
        Vars.Status.bleeding = 2
        Vars.Status.area = 'BODY'
    end
    Vars.Status.pulse = ((Vars.Status.health / 4 + 20) * Vars.Status.multiplier) + math.random(0, 4)

    -- Arena PvP: stay dead for the deathscreen recap, skip ambulance spawn timer UI
    if inPvp then
        return
    end

    client.blurIn()
    DeathTimer()
end

AddEventHandler('esx:onPlayerDeath', function(data)
    onDeath(data)
end)

AddEventHandler('esx:onPlayerSpawn', function()
    -- Reconnect/appearance can fire spawn while the player is still marked dead
    if Vars.isDead and not Vars.isReviving then
        client.StartDeathPose()
        return
    end
    client.StopDeathPose()
    Vars.isDead = false
    LocalPlayer.state:set('invBusy', false, true)
    client.HideNUI()
    -- Unmute if alive; pma-voice also reinits channel on this event
    TriggerServerEvent('cfx-keydi-ambulance:ensureVoiceUnmute')
end)

RegisterNetEvent('cfx-keydi-ambulance:spawnProtect', function(duration)
    if source ~= 65535 then return end
    client.StartSpawnProtection(duration)
end)

RegisterNetEvent('cfx-keydi-ambulance:revive', function()
    if source ~= 65535 then return end
    if Vars.isReviving then return end

    -- Lock out death re-entry immediately (before any Wait)
    client.StopDeathPose()
    Vars.isReviving = true
    Vars.isDead = false
    Vars.deathInSandy = false
    Vars.deathCoords = nil
    Vars.deathToken = (Vars.deathToken or 0) + 1
    LocalPlayer.state:set('isReviving', true, false)
    LocalPlayer.state:set('dead', false, true)
    LocalPlayer.state:set('invBusy', false, true)
    if ESX and ESX.SetPlayerData then
        ESX.SetPlayerData('dead', false)
    end
    ClampGameplayCamPitch(-90.0, 90.0)
    RenderScriptCams(false, false, 0, true, true)
    client.HideNUI()
    TriggerServerEvent('cfx-keydi-ambulance:setPlayerDeathStatus', false)

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    SetEntityVisible(ped, true, false)
    ResetEntityAlpha(ped)
    FreezeEntityPosition(ped, true)
    SetEntityCollision(ped, false, false)
    SetPedCanRagdoll(ped, false)
    ClearPedTasksImmediately(ped)

    DoScreenFadeOut(400)
    local fadeTimeout = GetGameTimer() + 3000
    while not IsScreenFadedOut() and GetGameTimer() < fadeTimeout do
        Wait(0)
    end

    -- Watchdog: if RespawnPed / appearance hangs, never leave players on a black screen.
    CreateThread(function()
        local deadline = GetGameTimer() + 8000
        while GetGameTimer() < deadline do
            if not IsScreenFadedOut() and not IsScreenFadingOut() then
                return
            end
            Wait(100)
        end
        if IsScreenFadedOut() or IsScreenFadingOut() then
            DoScreenFadeIn(0)
        end
        FreezeEntityPosition(PlayerPedId(), false)
        SetEntityCollision(PlayerPedId(), true, true)
        Vars.isReviving = false
        LocalPlayer.state:set('isReviving', false, false)
    end)

    local ok, err = pcall(client.RespawnPed, ped, { x = coords.x, y = coords.y, z = coords.z }, heading)
    if not ok then
        print(('[cfx-keydi-ambulance] RespawnPed failed during revive: %s'):format(tostring(err)))
        FreezeEntityPosition(PlayerPedId(), false)
        SetEntityCollision(PlayerPedId(), true, true)
        Vars.isReviving = false
        LocalPlayer.state:set('isReviving', false, false)
    end

    DoScreenFadeIn(400)
end)

-- AddEventHandler('cfx-keydi-ambulance:purge', function()
--     if not GlobalState.IsPurging then return end
--     local ped = cache.ped
--     local coords = GetEntityCoords(ped)
--     TriggerServerEvent('cfx-keydi-ambulance:setPlayerDeathStatus', false)
--     client.HideNUI()
--     DoScreenFadeOut(800)
--     while not IsScreenFadedOut() do Wait(50) end
--     local formattedCoords = {x = ESX.Math.Round(coords.x, 1), y = ESX.Math.Round(coords.y, 1), z = ESX.Math.Round(coords.z, 1)}
--     client.RespawnPed(ped, formattedCoords, 0.0)
--     Vars.isDead = false
--     DoScreenFadeIn(800)
-- end)

CreateThread(function()
    local blips = configs.Blips or {}
    for i = 1, #blips do
        local data = blips[i]
        local blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
        SetBlipSprite(blip, data.sprite or 61)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, data.scale or 0.8)
        SetBlipColour(blip, data.colour or 1)
        SetBlipAsShortRange(blip, data.shortRange ~= false)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(data.label or 'Hospital')
        EndTextCommandSetBlipName(blip)
    end
end)

CreateThread(function()
    local function getJobCount(jobName)
        return GlobalState[('%s:count'):format(jobName)] or 0
    end

    for i = 1, #configs.CheckIn do
        local checkIn = configs.CheckIn[i]

        exports.ox_target:addSphereZone({
            coords = checkIn.coords,
            radius = checkIn.distance.interact,
            debug = false,

            options = {
                {
                    label = ('Check In - %s'):format(ESX.Math.GroupDigits(checkIn.price)),
                    icon = 'fa-solid fa-hospital',

                    canInteract = function()
                        -- Only allow if medic count is BELOW required
                        return getJobCount(checkIn.job) < checkIn.onDuty
                    end,

                    onSelect = function()
                        -- Re-check server state (safety)
                        if getJobCount(checkIn.job) >= checkIn.onDuty then
                            ESX.Notify(
                                'AMBULANCE',
                                'There are plenty of medics in the city! Distress for help!',
                                'error',
                                5000
                            )
                            return
                        end

                        local progress = lib.progressBar({
                            duration = 1000,
                            label = 'Please Wait . . .',
                            useWhileDead = true,
                            canCancel = false,
                            disable = {
                                car = true,
                            },
                            anim = {
                                scenario = 'WORLD_HUMAN_CLIPBOARD'
                            }
                        })

                        if not progress then
                            ESX.Notify('AMBULANCE', 'Failed to check in.', 'error', 5000)
                            return
                        end

                        ESX.TriggerServerCallback(
                            'cfx-keydi-ambulance:checkIn',
                            function(success)
                                if success then
                                    ESX.Notify(
                                        'AMBULANCE',
                                        'You have been successfully treated by the hospital staff',
                                        'success',
                                        5000
                                    )
                                else
                                    ESX.Notify(
                                        'AMBULANCE',
                                        'You should have money in your bank account.',
                                        'error',
                                        5000
                                    )
                                end
                            end,
                            i
                        )
                    end
                }
            }
        })
    end
end)


local function setTDM(bool)
    TriggerServerEvent('cfx-keydi-ambulance:setPlayerDeathStatus', bool)
    Vars.isDead = bool
end

exports('setTDM', setTDM)

local function isEmsDummyUi()
    return LocalPlayer.state.emsUiDummy == true
end

RegisterNUICallback('ems:setDeathUiMode', function(data, cb)
    local mode = data and data.mode
    if mode == 'full' or mode == 'short' then
        if isEmsDummyUi() then
            TriggerEvent('cfx-keydi-ambulance:dummy:setMode', mode)
            SendNUIMessage({ type = 'updateDeathScreen', update = 'mode', mode = mode })
        else
            setDeathUiFocus(mode)
            SendNUIMessage({ type = 'updateDeathScreen', update = 'mode', mode = mode })
        end
    end
    cb({ ok = true })
end)

RegisterNUICallback('ems:selectRespawn', function(data, cb)
    if not isEmsDummyUi() and not Vars.stlUnlocked then
        cb({ ok = false })
        return
    end
    if type(data) == 'table' and type(data.id) == 'string' then
        selectedRespawnId = data.id
        if isEmsDummyUi() then
            TriggerEvent('cfx-keydi-ambulance:dummy:select', data.id)
        end
    end
    cb({ ok = true })
end)

RegisterNUICallback('ems:sendDistress', function(_, cb)
    if isEmsDummyUi() then
        TriggerEvent('cfx-keydi-ambulance:dummy:distress')
        cb({ ok = true })
        return
    end
    if not Vars.isDead then
        cb({ ok = false })
        return
    end
    TriggerServerEvent('cfx-keydi-ambulance:request911')
    Vars.IsDispatched = true
    SendNUIMessage({ type = 'updateDeathScreen', update = 'dispatch', dispatched = true })
    cb({ ok = true })
end)

RegisterNUICallback('ems:confirmRespawn', function(data, cb)
    if isEmsDummyUi() then
        local id = type(data) == 'table' and data.id or selectedRespawnId
        cb({ ok = true })
        TriggerEvent('cfx-keydi-ambulance:dummy:confirm', id)
        return
    end
    if not Vars.isDead then
        cb({ ok = false })
        return
    end
    if not Vars.stlUnlocked then
        ESX.Notify('AMBULANCE', 'Respawn is not ready yet.', 'error', 3000)
        cb({ ok = false })
        return
    end
    if type(data) == 'table' and type(data.id) == 'string' then
        selectedRespawnId = data.id
    end
    cb({ ok = true })
    CreateThread(function()
        client.RemoveRPDeath()
    end)
end)

exports('GetSelectedRespawnId', function()
    return selectedRespawnId
end)

local stuckCooldownUntil = 0

RegisterCommand('stuck', function()
    local now = GetGameTimer()
    if now < stuckCooldownUntil then return end
    if not Vars.isDead then return end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local x, y, z = client.SafeReviveCoords(coords.x, coords.y, coords.z, ped)
    SetEntityCoordsNoOffset(ped, x, y, z, false, false, false)
    FreezeEntityPosition(ped, false)
    SetEntityCollision(ped, true, true)
    client.StartDeathPose()
    stuckCooldownUntil = now + 30000
end)

-- 911 dispatch blip for on-duty EMS
local active911Blips = {}

RegisterNetEvent('cfx-keydi-ambulance:911Dispatch', function(data)
    if type(data) ~= 'table' or not data.coords then return end

    local dispatchCfg = configs.General.Dispatch911 or {}
    local coords = data.coords
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, dispatchCfg.blipSprite or 153)
    SetBlipColour(blip, dispatchCfg.blipColor or 1)
    SetBlipScale(blip, dispatchCfg.blipScale or 1.1)
    SetBlipAsShortRange(blip, false)
    SetBlipFlashes(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(('911: %s [%s]'):format(data.callerName or 'Unknown', data.callerId or '?'))
    EndTextCommandSetBlipName(blip)
    SetBlipRoute(blip, true)
    SetBlipRouteColour(blip, dispatchCfg.blipColor or 1)

    active911Blips[#active911Blips + 1] = blip

    ESX.Notify(
        '911 DISPATCH',
        ('Downed civilian: %s [%s] — marked on your map.'):format(data.callerName or 'Unknown', data.callerId or '?'),
        'error',
        10000
    )

    SetTimeout(dispatchCfg.blipDuration or 300000, function()
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end)
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    for i = 1, #active911Blips do
        if DoesBlipExist(active911Blips[i]) then
            RemoveBlip(active911Blips[i])
        end
    end
end)
