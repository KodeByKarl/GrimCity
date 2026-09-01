local ESX = exports["es_extended"]:getSharedObject()
local playerId = PlayerId()
local hidingPlayers = false
local cam = nil
local previewPed = nil
local isNuiOpen = false
local nuiReady = false
local pendingIsNew = false

function ClearScriptCam()
    if cam then
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(cam, false)
        cam = nil
    end
end

local function CreateDeathscreenStyleCam(spawnX, spawnY, spawnZ, pHeading)
    ClearScriptCam()

    local pRad = math.rad(pHeading)
    local camDistance = 3.2
    local camX = spawnX + (math.sin(pRad) * camDistance)
    local camY = spawnY - (math.cos(pRad) * camDistance)
    local camZ = spawnZ + 0.85

    cam = CreateCamWithParams(
        "DEFAULT_SCRIPTED_CAMERA",
        camX, camY, camZ,
        0.0, 0.0, 0.0,
        48.0,
        false, 0
    )

    PointCamAtCoord(cam, spawnX, spawnY, spawnZ + 0.85)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 500, true, true)
end

function DestroyPreviewPed()
    if previewPed and DoesEntityExist(previewPed) then
        DeleteEntity(previewPed)
        previewPed = nil
    end
end

function SpawnCharacterPreview(skinData, spawnVector)
    local spawnCoords = spawnVector or Config.Multicharacter.DefaultSpawn
    local spawnX = spawnCoords.x
    local spawnY = spawnCoords.y
    local spawnZ = spawnCoords.z
    local pHeading = spawnCoords.w or 205.5

    local model = `mp_m_freemode_01`

    if skinData then
        if skinData.model then
            model = type(skinData.model) == 'number' and skinData.model or joaat(skinData.model)
        elseif skinData.sex == 1 or skinData.sex == 'f' or skinData.rawSex == 'f' or skinData.sex == 'Female' then
            model = `mp_f_freemode_01`
        end
    end

    CreateThread(function()
        -- If previewPed already exists and is the same model, just update position and skin INSTANTLY (<5ms)!
        if previewPed and DoesEntityExist(previewPed) and GetEntityModel(previewPed) == model then
            SetEntityCoords(previewPed, spawnX, spawnY, spawnZ, false, false, false, false)
            SetEntityHeading(previewPed, (pHeading + 180.0) % 360.0)

            if skinData then
                if GetResourceState('illenium-appearance') == 'started' then
                    pcall(function() exports['illenium-appearance']:setPedAppearance(previewPed, skinData) end)
                elseif GetResourceState('esx_skin') == 'started' then
                    TriggerEvent('skinchanger:loadSkin', skinData, nil, previewPed)
                end
            end

            CreateDeathscreenStyleCam(spawnX, spawnY, spawnZ, pHeading)
            return
        end

        DestroyPreviewPed()

        RequestModel(model)
        local t = 0
        while not HasModelLoaded(model) and t < 30 do
            Wait(10)
            t = t + 1
        end

        previewPed = CreatePed(4, model, spawnX, spawnY, spawnZ, pHeading, false, false)

        if previewPed and DoesEntityExist(previewPed) then
            SetEntityAsMissionEntity(previewPed, true, true)
            ResurrectPed(previewPed)
            SetEntityHealth(previewPed, 200)
            ClearPedBloodDamage(previewPed)
            ClearPedEnvDirt(previewPed)
            ResetPedVisibleDamage(previewPed)
            ClearPedTasksImmediately(previewPed)

            SetEntityCoords(previewPed, spawnX, spawnY, spawnZ, false, false, false, false)
            SetEntityHeading(previewPed, (pHeading + 180.0) % 360.0)
            SetEntityVisible(previewPed, true, false)
            ResetEntityAlpha(previewPed)
            SetPedAoBlobRendering(previewPed, true)
            SetPedCanRagdoll(previewPed, false)
            SetPedCanRagdollFromPlayerImpact(previewPed, false)
            SetEntityInvincible(previewPed, true)
            FreezeEntityPosition(previewPed, true)
            SetEntityCollision(previewPed, false, false)
            SetBlockingOfNonTemporaryEvents(previewPed, true)

            -- Apply skin instantly
            if skinData then
                if GetResourceState('illenium-appearance') == 'started' then
                    pcall(function() exports['illenium-appearance']:setPedAppearance(previewPed, skinData) end)
                elseif GetResourceState('esx_skin') == 'started' then
                    TriggerEvent('skinchanger:loadSkin', skinData, nil, previewPed)
                end
            end

            -- Clean standing guard pose animation
            local animDict = "amb@world_human_stand_guard@male@base"
            RequestAnimDict(animDict)
            local loadT = 0
            while not HasAnimDictLoaded(animDict) and loadT < 20 do
                Wait(10)
                loadT = loadT + 1
            end
            if HasAnimDictLoaded(animDict) and DoesEntityExist(previewPed) then
                ClearPedTasksImmediately(previewPed)
                TaskPlayAnim(previewPed, animDict, "base", 8.0, 8.0, -1, 1, 0.0, false, false, false)
            end
        end

        CreateDeathscreenStyleCam(spawnX, spawnY, spawnZ, pHeading)
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

    local ped = PlayerPedId()
    SetEntityCoords(ped, Config.Multicharacter.DefaultSpawn.x, Config.Multicharacter.DefaultSpawn.y, Config.Multicharacter.DefaultSpawn.z - 0.9)
    FreezeEntityPosition(ped, true)

    startHidingLoop()
    SpawnCharacterPreview(nil, Config.Multicharacter.DefaultSpawn)

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
    local model = (sex == 'f' or sex == 1) and `mp_f_freemode_01` or `mp_m_freemode_01`

    RequestModel(model)
    local t = 0
    while not HasModelLoaded(model) and t < 60 do
        Wait(10)
        t = t + 1
    end

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
