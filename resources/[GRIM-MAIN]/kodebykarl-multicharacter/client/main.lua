local ESX = exports["es_extended"]:getSharedObject()
local playerId = PlayerId()
local hidingPlayers = false
local cam = nil
local previewPed = nil
local previewToken = 0
local isNuiOpen = false
local nuiReady = false
local pendingIsNew = false
local scenePrepared = false

local MODEL_MALE = `mp_m_freemode_01`
local MODEL_FEMALE = `mp_f_freemode_01`

function ClearScriptCam()
    if cam then
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(cam, false)
        cam = nil
    end
end

local function PrefetchFreemodeModels()
    RequestModel(MODEL_MALE)
    RequestModel(MODEL_FEMALE)
end

local function EnsureSceneReady(x, y, z)
    SetFocusPosAndVel(x, y, z, 0.0, 0.0, 0.0)
    RequestCollisionAtCoord(x, y, z)
    if scenePrepared then return end

    NewLoadSceneStartSphere(x, y, z, 80.0, 0)
    local deadline = GetGameTimer() + 4000
    while IsNewLoadSceneActive() and not IsNewLoadSceneLoaded() and GetGameTimer() < deadline do
        RequestCollisionAtCoord(x, y, z)
        Wait(0)
    end
    if IsNewLoadSceneActive() then
        NewLoadSceneStop()
    end

    deadline = GetGameTimer() + 2000
    local ped = PlayerPedId()
    while GetGameTimer() < deadline do
        RequestCollisionAtCoord(x, y, z)
        if ped ~= 0 and HasCollisionLoadedAroundEntity(ped) then
            break
        end
        Wait(0)
    end
    scenePrepared = true
end

local function SetupDeathscreenCam(ped)
    if not ped or ped == 0 or not DoesEntityExist(ped) then return end

    local camCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 4.4, 0.35)
    local lookAt = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, 0.05)

    if not cam then
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    end
    SetCamCoord(cam, camCoords.x, camCoords.y, camCoords.z)
    PointCamAtCoord(cam, lookAt.x, lookAt.y, lookAt.z)
    SetCamFov(cam, 46.0)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 500, true, true)
end

local function SetupInitialDeathscreenCam()
    ClearScriptCam()

    local spawn = Config.Multicharacter.DefaultSpawn
    local heading = spawn.w or 205.5
    local rad = math.rad(heading)
    local dist = 4.4
    local spawnZ = (spawn.z or 31.2) + 0.98

    local camX = spawn.x - math.sin(rad) * dist
    local camY = spawn.y + math.cos(rad) * dist
    local camZ = spawnZ + 0.35

    cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(cam, camX, camY, camZ)
    PointCamAtCoord(cam, spawn.x, spawn.y, spawnZ + 0.05)
    SetCamFov(cam, 46.0)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, true)
end

function DestroyPreviewPed()
    previewToken = previewToken + 1
    if previewPed and DoesEntityExist(previewPed) then
        DeleteEntity(previewPed)
        previewPed = nil
    end
end

local function isFemaleSkin(skinData)
    if type(skinData) ~= "table" then return false end
    local sex = skinData.sex or skinData.rawSex
    if sex == 1 or sex == "f" or sex == "F" or sex == "female" or sex == "Female" then
        return true
    end
    if sex == 0 or sex == "m" or sex == "M" or sex == "male" or sex == "Male" then
        return false
    end
    local model = skinData.model
    if model then
        local hash = type(model) == "number" and model or joaat(model)
        return hash == MODEL_FEMALE
    end
    return false
end

-- Character select only uses freemode male/female — never custom peds.
local function resolvePreviewModel(skinData)
    return isFemaleSkin(skinData) and MODEL_FEMALE or MODEL_MALE
end

local function requestModelFast(model)
    if HasModelLoaded(model) then
        return true
    end
    RequestModel(model)
    local deadline = GetGameTimer() + 3000
    while not HasModelLoaded(model) and GetGameTimer() < deadline do
        Wait(0)
    end
    return HasModelLoaded(model)
end

local function applyPreviewAppearance(ped, skinData)
    if not ped or ped == 0 or not DoesEntityExist(ped) or type(skinData) ~= "table" then
        return
    end

    -- Illenium native format
    if skinData.components or skinData.headBlend or skinData.hair then
        pcall(function()
            exports["illenium-appearance"]:setPedAppearance(ped, skinData)
        end)
        return
    end

    -- Fallback: loadSkin2 expects ped + appearance table
    pcall(function()
        TriggerEvent("skinchanger:loadSkin2", ped, skinData)
    end)
end

local function forcePedStanding(ped)
    if not ped or ped == 0 or not DoesEntityExist(ped) then return end

    local maxH = GetEntityMaxHealth(ped)
    if not maxH or maxH < 100 then
        maxH = 200
        SetEntityMaxHealth(ped, maxH)
    end

    if IsPedDeadOrDying(ped, true) or IsEntityDead(ped) or GetEntityHealth(ped) <= 100 then
        pcall(ResurrectPed, ped)
        pcall(ReviveInjuredPed, ped)
        SetEntityHealth(ped, maxH)
    end

    SetPedCanRagdoll(ped, false)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetPedRagdollOnCollision(ped, false)
    ResetPedRagdollTimer(ped)
    SetPedConfigFlag(ped, 166, false)
    ClearPedBloodDamage(ped)
    ClearPedTasksImmediately(ped)
    SetEntityRotation(ped, 0.0, 0.0, GetEntityHeading(ped), 2, true)
end

local function startPreviewHold(token)
    CreateThread(function()
        local dict, clip = "amb@world_human_stand_guard@male@base", "base"
        RequestAnimDict(dict)
        while previewToken == token and previewPed and DoesEntityExist(previewPed) do
            forcePedStanding(previewPed)
            if HasAnimDictLoaded(dict) and not IsEntityPlayingAnim(previewPed, dict, clip, 3) then
                TaskPlayAnim(previewPed, dict, clip, 8.0, 8.0, -1, 1, 0.0, false, false, false)
            end
            FreezeEntityPosition(previewPed, true)
            Wait(400)
        end
    end)
end

function SpawnCharacterPreview(skinData, spawnVector)
    local spawnCoords = spawnVector or Config.Multicharacter.DefaultSpawn
    local spawnX = spawnCoords.x
    local spawnY = spawnCoords.y
    local floorZ = spawnCoords.z or 31.2
    local heading = spawnCoords.w or 205.5
    local model = resolvePreviewModel(skinData)

    -- True ground elevation matching deathscreen:
    -- In GTA V, ped root coordinate sits ~0.98m above the bottom of the feet.
    local foundGround, gZ = GetGroundZFor_3dCoord(spawnX, spawnY, floorZ + 2.5, false)
    if not foundGround then
        foundGround, gZ = GetGroundZFor_3dCoord(spawnX, spawnY, floorZ + 15.0, false)
    end
    local spawnZ
    if foundGround and math.abs(gZ - floorZ) < 0.6 then
        spawnZ = gZ + 0.98
    else
        spawnZ = floorZ + 0.98
    end

    previewToken = previewToken + 1
    local token = previewToken

    CreateThread(function()
        -- Same freemode ped: just re-skin (no scene wait, no recreate)
        if previewPed and DoesEntityExist(previewPed) and GetEntityModel(previewPed) == model then
            SetPedDefaultComponentVariation(previewPed)
            applyPreviewAppearance(previewPed, skinData)
            forcePedStanding(previewPed)
            startPreviewHold(token)
            SetupDeathscreenCam(previewPed)
            return
        end

        if previewPed and DoesEntityExist(previewPed) then
            DeleteEntity(previewPed)
            previewPed = nil
        end

        PrefetchFreemodeModels()
        if not requestModelFast(model) then
            model = MODEL_MALE
            if not requestModelFast(model) then
                return
            end
        end
        if token ~= previewToken then return end

        previewPed = CreatePed(0, model, spawnX, spawnY, spawnZ, heading, false, false)

        if token ~= previewToken then
            if previewPed and DoesEntityExist(previewPed) then
                DeleteEntity(previewPed)
                previewPed = nil
            end
            return
        end

        if not previewPed or previewPed == 0 or not DoesEntityExist(previewPed) then
            return
        end

        SetEntityAsMissionEntity(previewPed, true, true)
        SetEntityVisible(previewPed, true, false)
        ResetEntityAlpha(previewPed)
        SetEntityInvincible(previewPed, true)
        SetEntityCoordsNoOffset(previewPed, spawnX, spawnY, spawnZ, false, false, false)
        SetEntityHeading(previewPed, heading)
        SetEntityCollision(previewPed, false, false)
        FreezeEntityPosition(previewPed, true)
        SetBlockingOfNonTemporaryEvents(previewPed, true)
        SetPedAoBlobRendering(previewPed, true)
        SetPedDefaultComponentVariation(previewPed)
        ClearPedBloodDamage(previewPed)
        SetEntityHealth(previewPed, 200)

        forcePedStanding(previewPed)
        applyPreviewAppearance(previewPed, skinData)
        startPreviewHold(token)

        if token == previewToken then
            SetupDeathscreenCam(previewPed)
        end
    end)
end

local function startHidingLoop()
    if hidingPlayers then return end
    hidingPlayers = true

    CreateThread(function()
        local ped
        while hidingPlayers do
            ped = PlayerPedId()
            SetEntityVisible(ped, false, false)
            SetPlayerInvincible(playerId, true)
            HideHudAndRadarThisFrame()
            DisableAllControlActions(0)
            Wait(0)
        end

        SetEntityVisible(PlayerPedId(), true, false)
        SetPlayerInvincible(playerId, false)
        FreezeEntityPosition(PlayerPedId(), false)
    end)
end

local function WaitForNuiReady()
    local timeout = GetGameTimer() + 15000
    while not nuiReady and GetGameTimer() < timeout do
        Wait(50)
    end
end

local isMultivipOpen = false

local function OpenMulticharacterNui(characters, slots)
    WaitForNuiReady()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openMulticharacter",
        characters = characters or {},
        maxSlots = slots or Config.Multicharacter.DefaultSlots or 1
    })
    DoScreenFadeIn(500)
end

function OpenMultivip(data)
    isMultivipOpen = true
    WaitForNuiReady()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openMultivip",
        data = data or { players = {} },
    })
end

function CloseMultivip()
    isMultivipOpen = false
    SendNUIMessage({ action = "closeMultivip" })
    if not isNuiOpen then
        SetNuiFocus(false, false)
    end
end

function RefreshCharacters()
    ESX.TriggerServerCallback('esx_multicharacter:SetupCharacters', function(characters, slots)
        OpenMulticharacterNui(characters, slots)
    end)
end

function SetupCharacters()
    if isNuiOpen then return end
    isNuiOpen = true
    pendingIsNew = false

    ESX.DisableSpawnManager()
    DoScreenFadeOut(0)
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()

    local spawn = Config.Multicharacter.DefaultSpawn
    local ped = PlayerPedId()
    SetEntityCoordsNoOffset(ped, spawn.x, spawn.y, spawn.z, false, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityVisible(ped, false, false)

    startHidingLoop()
    PrefetchFreemodeModels()
    scenePrepared = false
    EnsureSceneReady(spawn.x, spawn.y, spawn.z)
    SetupInitialDeathscreenCam()
    DestroyPreviewPed()

    ESX.TriggerServerCallback('esx_multicharacter:SetupCharacters', function(characters, slots)
        OpenMulticharacterNui(characters, slots)
    end)
end

function SetPendingNewCharacter(isNew)
    pendingIsNew = isNew == true
end

RegisterNUICallback("nuiReady", function(_, cb)
    nuiReady = true
    cb({ ok = true })
end)

RegisterNetEvent('esx_multicharacter:SetupUI', function(characters, slots)
    OpenMulticharacterNui(characters, slots)
end)

RegisterNetEvent('esx_multicharacter:SetupCharacters', function()
    isNuiOpen = false
    SetupCharacters()
end)

function CloseMulticharacter()
    isNuiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "closeMulticharacter" })
    ClearScriptCam()
    DestroyPreviewPed()
    ClearFocus()
end

local function FinishPlayerSpawn(playerData, isNew, skin)
    hidingPlayers = false

    local spawn = playerData and playerData.coords or nil
    if not spawn or not spawn.x then
        spawn = {
            x = Config.Multicharacter.DefaultSpawn.x,
            y = Config.Multicharacter.DefaultSpawn.y,
            z = Config.Multicharacter.DefaultSpawn.z,
            heading = Config.Multicharacter.DefaultSpawn.w or 0.0,
        }
    end
    spawn.heading = spawn.heading or spawn.w or 0.0

    local ped = PlayerPedId()
    SetEntityVisible(ped, true, false)
    SetEntityCollision(ped, true, true)
    FreezeEntityPosition(ped, true)
    SetEntityCoordsNoOffset(ped, spawn.x, spawn.y, spawn.z, false, false, true)
    SetEntityHeading(ped, spawn.heading)

    if isNew then
        SetPedDefaultComponentVariation(ped)
        Wait(200)
        if GetResourceState('illenium-appearance') == 'started' then
            TriggerEvent('esx_skin:resetFirstSpawn')
            local function onCreationFinished()
                TriggerEvent('cfx-keydi-welcome:show')
                SetTimeout(1800, function()
                    TriggerEvent('pma-voice:client:creationFinished')
                end)
            end
            TriggerEvent('esx_skin:openSaveableMenu', onCreationFinished, onCreationFinished)
        else
            TriggerEvent('cfx-keydi-welcome:show')
        end
    elseif skin then
        if GetResourceState('illenium-appearance') == 'started' then
            pcall(function() exports['illenium-appearance']:setPedAppearance(ped, skin) end)
        else
            TriggerEvent('skinchanger:loadSkin', skin)
        end
    end

    Wait(400)
    FreezeEntityPosition(PlayerPedId(), false)
    TriggerServerEvent('esx:onPlayerSpawn')
    TriggerEvent('esx:onPlayerSpawn')
    TriggerEvent('playerSpawned', spawn)
    TriggerEvent('esx:restoreLoadout')
    TriggerEvent('esx:loadingScreenOff')
    DoScreenFadeIn(800)
end

RegisterNetEvent('esx:playerLoaded', function(playerData, isNew, skin)
    local spawnNew = isNew == true or pendingIsNew
    pendingIsNew = false
    CloseMulticharacter()
    DoScreenFadeOut(0)

    local sex = playerData and playerData.sex or 'm'
    local model = (sex == 'f' or sex == 1) and MODEL_FEMALE or MODEL_MALE

    requestModelFast(model)

    if HasModelLoaded(model) then
        SetPlayerModel(PlayerId(), model)
        SetModelAsNoLongerNeeded(model)
    end

    FinishPlayerSpawn(playerData, spawnNew, skin)
end)

RegisterNetEvent('esx_multicharacter:slotsUpdated', function()
    if isNuiOpen then
        RefreshCharacters()
    end
end)

RegisterNetEvent('esx:onPlayerLogout', function()
    isNuiOpen = false
    hidingPlayers = false
    pendingIsNew = false
    DoScreenFadeOut(0)
    Wait(500)
    SetupCharacters()
end)

CreateThread(function()
    while not ESX.PlayerLoaded do
        if NetworkIsPlayerActive(playerId) then
            ESX.DisableSpawnManager()
            DoScreenFadeOut(0)
            Wait(500)
            SetupCharacters()
            break
        end
        Wait(100)
    end
end)

RegisterCommand('relog', function()
    TriggerServerEvent('esx_multicharacter:relog')
end, false)

RegisterCommand(Config.Multicharacter.VipCommand or 'Multivip', function()
    ESX.TriggerServerCallback('esx_multicharacter:openMultivip', function(data)
        if not data then
            ESX.ShowNotification("Developer and Owner only.", "error")
            return
        end
        OpenMultivip(data)
    end)
end, false)

CreateThread(function()
    local command = Config.Multicharacter.VipCommand or 'Multivip'
    TriggerEvent('chat:addSuggestion', '/' .. command, 'Grant character slots 2 and 3 (Developer / Owner)')
end)

exports('SetupCharacters', SetupCharacters)
exports('SetPendingNewCharacter', SetPendingNewCharacter)
