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

local function CreateDeathscreenStyleCam(spawnX, spawnY, spawnZ, pHeading)
    ClearScriptCam()

    local cfg = Config.Multicharacter or {}
    local camPos = cfg.CamCoords
    local lookAt = cfg.CamPoint
    local fov = cfg.CamFov or 48.0

    if camPos then
        cam = CreateCamWithParams(
            "DEFAULT_SCRIPTED_CAMERA",
            camPos.x, camPos.y, camPos.z,
            0.0, 0.0, 0.0,
            fov,
            false, 0
        )
        if lookAt then
            PointCamAtCoord(cam, lookAt.x, lookAt.y, lookAt.z)
        else
            PointCamAtCoord(cam, spawnX, spawnY, spawnZ + 0.85)
        end
    else
        local pRad = math.rad(pHeading)
        local camDistance = 3.2
        local camX = spawnX + (math.sin(pRad) * camDistance)
        local camY = spawnY - (math.cos(pRad) * camDistance)
        local camZ = spawnZ + 0.85

        cam = CreateCamWithParams(
            "DEFAULT_SCRIPTED_CAMERA",
            camX, camY, camZ,
            0.0, 0.0, 0.0,
            fov,
            false, 0
        )
        PointCamAtCoord(cam, spawnX, spawnY, spawnZ + 0.85)
    end

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

local function placePreviewPed(ped, spawnX, spawnY, spawnZ, heading)
    local z = spawnZ
    local found, groundZ = GetGroundZFor_3dCoord(spawnX, spawnY, spawnZ + 2.0, false)
    if found then
        z = groundZ
    end
    SetEntityCoordsNoOffset(ped, spawnX, spawnY, z, false, false, false)
    SetEntityHeading(ped, heading)
end

local function playPreviewIdle(ped)
    local animDict = "amb@world_human_stand_guard@male@base"
    RequestAnimDict(animDict)
    if HasAnimDictLoaded(animDict) then
        TaskPlayAnim(ped, animDict, "base", 8.0, 8.0, -1, 1, 0.0, false, false, false)
        return
    end
    CreateThread(function()
        local deadline = GetGameTimer() + 1500
        while not HasAnimDictLoaded(animDict) and GetGameTimer() < deadline do
            Wait(0)
        end
        if HasAnimDictLoaded(animDict) and previewPed == ped and DoesEntityExist(ped) then
            TaskPlayAnim(ped, animDict, "base", 8.0, 8.0, -1, 1, 0.0, false, false, false)
        end
    end)
end

function SpawnCharacterPreview(skinData, spawnVector)
    local spawnCoords = spawnVector or Config.Multicharacter.DefaultSpawn
    local spawnX = spawnCoords.x
    local spawnY = spawnCoords.y
    local spawnZ = spawnCoords.z
    local pHeading = spawnCoords.w or 205.5
    local faceHeading = (pHeading + 180.0) % 360.0
    local model = resolvePreviewModel(skinData)

    previewToken = previewToken + 1
    local token = previewToken

    CreateThread(function()
        -- Same freemode ped: just re-skin (no scene wait, no recreate)
        if previewPed and DoesEntityExist(previewPed) and GetEntityModel(previewPed) == model then
            applyPreviewAppearance(previewPed, skinData)
            if not cam then
                CreateDeathscreenStyleCam(spawnX, spawnY, spawnZ, pHeading)
            end
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
                CreateDeathscreenStyleCam(spawnX, spawnY, spawnZ, pHeading)
                return
            end
        end
        if token ~= previewToken then return end

        previewPed = CreatePed(4, model, spawnX, spawnY, spawnZ, faceHeading, false, true)

        if token ~= previewToken then
            if previewPed and DoesEntityExist(previewPed) then
                DeleteEntity(previewPed)
                previewPed = nil
            end
            return
        end

        if not previewPed or previewPed == 0 or not DoesEntityExist(previewPed) then
            CreateDeathscreenStyleCam(spawnX, spawnY, spawnZ, pHeading)
            return
        end

        SetEntityAsMissionEntity(previewPed, true, true)
        SetEntityVisible(previewPed, true, false)
        ResetEntityAlpha(previewPed)
        SetEntityInvincible(previewPed, true)
        SetEntityCollision(previewPed, false, false)
        FreezeEntityPosition(previewPed, true)
        SetBlockingOfNonTemporaryEvents(previewPed, true)
        SetPedCanRagdoll(previewPed, false)
        SetPedCanRagdollFromPlayerImpact(previewPed, false)
        SetPedAoBlobRendering(previewPed, true)
        ClearPedTasksImmediately(previewPed)
        ClearPedBloodDamage(previewPed)
        SetEntityHealth(previewPed, 200)

        placePreviewPed(previewPed, spawnX, spawnY, spawnZ, faceHeading)
        applyPreviewAppearance(previewPed, skinData)
        playPreviewIdle(previewPed)

        if token == previewToken then
            CreateDeathscreenStyleCam(spawnX, spawnY, spawnZ, pHeading)
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
    SpawnCharacterPreview(nil, spawn)

    ESX.TriggerServerCallback('esx_multicharacter:SetupCharacters', function(characters, slots)
        if characters and characters[1] and characters[1].skin then
            SpawnCharacterPreview(characters[1].skin, spawn)
        end
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
            TriggerEvent('esx_skin:openSaveableMenu')
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
