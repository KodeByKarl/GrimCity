local ESX = exports["es_extended"]:getSharedObject()
local playerId = PlayerId()
local hidingPlayers = false
local hidingLoopActive = false
local pendingIsNew = false

local MODEL_MALE = `mp_m_freemode_01`
local MODEL_FEMALE = `mp_f_freemode_01`

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

local function revealLocalPed(ped)
    ped = ped or PlayerPedId()
    if not ped or ped == 0 or not DoesEntityExist(ped) then return ped end

    SetLocalPlayerInvisibleLocally(false)
    NetworkSetEntityInvisibleToNetwork(ped, false)
    SetEntityVisible(ped, true, false)
    ResetEntityAlpha(ped)
    SetEntityAlpha(ped, 255, false)
    SetEntityCollision(ped, true, true)
    return ped
end

local function persistLocalPedReveal(durationMs)
    CreateThread(function()
        local untilTime = GetGameTimer() + (durationMs or 2000)
        while GetGameTimer() < untilTime and not hidingPlayers do
            revealLocalPed(PlayerPedId())
            Wait(100)
        end
    end)
end

local function stopHidingLoop()
    hidingPlayers = false
    SetLocalPlayerInvisibleLocally(false)
    SetPlayerInvincible(playerId, false)
    revealLocalPed(PlayerPedId())
end

local function startHidingLoop()
    if hidingLoopActive then
        hidingPlayers = true
        return
    end
    hidingPlayers = true
    hidingLoopActive = true

    CreateThread(function()
        local ped
        while hidingPlayers do
            ped = PlayerPedId()
            SetEntityVisible(ped, false, false)
            SetLocalPlayerInvisibleLocally(true)
            SetPlayerInvincible(playerId, true)
            HideHudAndRadarThisFrame()
            DisableAllControlActions(0)
            Wait(0)
        end

        hidingLoopActive = false
        revealLocalPed(PlayerPedId())
        SetPlayerInvincible(playerId, false)
        FreezeEntityPosition(PlayerPedId(), false)
    end)
end

local function vec4Table(vec, fallbackHeading)
    if not vec then return nil end
    return {
        x = vec.x,
        y = vec.y,
        z = vec.z,
        heading = vec.w or vec.heading or fallbackHeading or 0.0,
    }
end

local function TeleportLocalPed(ped, spawn)
    SetEntityCoordsNoOffset(ped, spawn.x, spawn.y, spawn.z, false, false, true)
    SetEntityHeading(ped, spawn.heading or spawn.w or 0.0)
end

local function ensureLocalPedRendered(ped)
    ped = revealLocalPed(ped)
    if ped and ped ~= 0 and DoesEntityExist(ped) then
        ClearPedTasksImmediately(ped)
    end
    return ped
end

local function fireSpawnEvents(spawn)
    TriggerServerEvent('esx:onPlayerSpawn')
    TriggerEvent('esx:onPlayerSpawn')
    TriggerEvent('playerSpawned', spawn)
    TriggerEvent('esx:restoreLoadout')
    TriggerEvent('esx:loadingScreenOff')
end

local function reapplyLocalAppearance(appearance)
    if GetResourceState('illenium-appearance') ~= 'started' then return PlayerPedId() end

    if not appearance then
        pcall(function()
            appearance = exports['illenium-appearance']:getPedAppearance(PlayerPedId())
        end)
    end

    if appearance and (appearance.model or appearance.components) then
        pcall(function()
            exports['illenium-appearance']:setPlayerAppearance(appearance)
        end)
        Wait(150)
    end

    return ensureLocalPedRendered(PlayerPedId())
end

local function FormatDob(value)
    if type(value) == "string" and value ~= "" then
        local y, m, d = value:match("(%d%d%d%d)%-(%d%d)%-(%d%d)")
        if y then
            return ("%s-%s-%s"):format(y, m, d)
        end
    end
    return "2005-01-01"
end

local function PromptIdentity()
    local cfg = Config.Identity

    while true do
        local input = lib.inputDialog('Create Your Character', {
            { type = 'input', label = 'First Name', required = true, min = 1, max = cfg.MaxNameLength or 50 },
            { type = 'input', label = 'Last Name', required = true, min = 1, max = cfg.MaxNameLength or 50 },
            { type = 'date', label = 'Date of Birth', required = true, default = true, format = 'YYYY-MM-DD' },
            {
                type = 'select',
                label = 'Sex',
                required = true,
                default = 'm',
                options = {
                    { value = 'm', label = 'Male' },
                    { value = 'f', label = 'Female' },
                },
            },
            {
                type = 'number',
                label = 'Height (cm)',
                required = true,
                default = cfg.DefaultHeight or 175,
                min = cfg.MinHeight or 120,
                max = cfg.MaxHeight or 220,
            },
        })

        if not input then
            lib.notify({
                title = 'Character',
                description = 'You must create a character to play.',
                type = 'error',
                position = 'top-center',
            })
        else
            return {
                firstname = tostring(input[1] or ''),
                lastname = tostring(input[2] or ''),
                dateofbirth = FormatDob(input[3]),
                sex = input[4] == 'f' and 'f' or 'm',
                height = tonumber(input[5]) or cfg.DefaultHeight or 175,
            }
        end
        Wait(250)
    end
end

local CreateAndJoin

local function SubmitCreatedCharacter(data)
    pendingIsNew = true
    DoScreenFadeOut(200)
    Wait(250)

    ESX.TriggerServerCallback('esx_identity:createCharacter', function(success, result)
        if success then
            TriggerServerEvent('esx_identity:CharacterChosen', result, true)
            return
        end

        pendingIsNew = false
        if result == 'already_exists' then
            lib.notify({
                title = 'Character',
                description = 'You already have a character. Joining...',
                type = 'inform',
                position = 'top-center',
            })
            ESX.TriggerServerCallback('esx_identity:autoJoin', function() end)
            return
        end

        local description = 'Could not create character. Try again.'
        if result == 'invalid_name' then
            description = ('First and last names must be 1-%s characters.'):format(Config.Identity.MaxNameLength or 50)
        elseif result == 'busy' then
            description = 'Character creation is already in progress.'
        end

        lib.notify({
            title = 'Character Creation',
            description = description,
            type = 'error',
            position = 'top-center',
        })

        CreateThread(function()
            Wait(500)
            CreateAndJoin()
        end)
    end, data)
end

CreateAndJoin = function()
    pendingIsNew = true

    local deadline = GetGameTimer() + 20000
    while GetResourceState('kodebykarl-ui') ~= 'started' and GetGameTimer() < deadline do
        Wait(50)
    end
    Wait(250)

    DoScreenFadeIn(400)
    Wait(450)

    if GetResourceState('kodebykarl-ui') == 'started' then
        local opened = pcall(function()
            exports['kodebykarl-ui']:OpenIdentity()
        end)
        if opened then
            return
        end
        TriggerEvent('esx_identity:showRegisterIdentity')
        return
    end

    -- Fallback if kodebykarl-ui is not running
    local data = PromptIdentity()
    SubmitCreatedCharacter(data)
end

exports('SubmitNewCharacter', function(data)
    if ESX.PlayerLoaded then return false end
    data = type(data) == 'table' and data or {}
    CreateThread(function()
        SubmitCreatedCharacter(data)
    end)
    return true
end)

local function FinishNewCharacterLanding(appearance)
    local dest = vec4Table(Config.Identity.DefaultSpawn, 169.0526)
    local ped = reapplyLocalAppearance(appearance)
    TeleportLocalPed(ped, dest)
    RequestCollisionAtCoord(dest.x, dest.y, dest.z)
    Wait(100)
    ped = ensureLocalPedRendered(PlayerPedId())
    persistLocalPedReveal(2500)
    FreezeEntityPosition(ped, false)
    TriggerServerEvent('esx_identity:saveNewPlayerSpawn')

    fireSpawnEvents(dest)
    DoScreenFadeIn(800)

    SetTimeout(400, function()
        TriggerEvent('cfx-keydi-welcome:show')
    end)
    SetTimeout(1800, function()
        TriggerEvent('pma-voice:client:creationFinished')
    end)
end

local function FinishPlayerSpawn(playerData, isNew, skin)
    TriggerEvent('cfx-keydi-welcome:hide')

    local campus = vec4Table(Config.Identity.DefaultSpawn, 169.0526)
    local creation = vec4Table(Config.Identity.CreationSpawn, 214.4983) or campus
    local spawn = isNew and creation or (playerData and playerData.coords) or campus
    spawn = {
        x = spawn.x,
        y = spawn.y,
        z = spawn.z,
        heading = spawn.heading or spawn.w or 0.0,
    }

    local ped = ensureLocalPedRendered(PlayerPedId())
    FreezeEntityPosition(ped, true)
    TeleportLocalPed(ped, spawn)
    RequestCollisionAtCoord(spawn.x, spawn.y, spawn.z)

    if isNew then
        SetPedDefaultComponentVariation(ped)
        Wait(200)
        ped = ensureLocalPedRendered(PlayerPedId())
        DoScreenFadeIn(400)
        Wait(450)

        if GetResourceState('illenium-appearance') == 'started' then
            TriggerEvent('esx_skin:resetFirstSpawn')
            TriggerEvent('esx_skin:openSaveableMenu', FinishNewCharacterLanding, FinishNewCharacterLanding)
        else
            FinishNewCharacterLanding()
        end
        return
    end

    local appearance = skin
    if (not appearance or type(appearance) ~= 'table' or not (appearance.model or appearance.components or appearance.headBlend))
        and GetResourceState('illenium-appearance') == 'started' then
        local fetched = nil
        pcall(function()
            lib.callback('illenium-appearance:server:getAppearance', false, function(result)
                fetched = result or false
            end)
        end)
        local deadline = GetGameTimer() + 1500
        while fetched == nil and GetGameTimer() < deadline do
            Wait(0)
        end
        if type(fetched) == 'table' then
            appearance = fetched
        end
    end

    if appearance and type(appearance) == 'table' and (appearance.model or appearance.components or appearance.headBlend) then
        if GetResourceState('illenium-appearance') == 'started' then
            if appearance.model then
                pcall(function() exports['illenium-appearance']:setPlayerAppearance(appearance) end)
            else
                pcall(function() exports['illenium-appearance']:setPedAppearance(PlayerPedId(), appearance) end)
            end
            Wait(150)
        else
            TriggerEvent('skinchanger:loadSkin', appearance)
        end
    end

    local spawnedPed = ensureLocalPedRendered(PlayerPedId())
    persistLocalPedReveal(4000)
    FreezeEntityPosition(spawnedPed, false)
    fireSpawnEvents(spawn)
    DoScreenFadeIn(400)

    -- Returning players: open welcome after spawn, not during the black fade.
    SetTimeout(700, function()
        TriggerEvent('cfx-keydi-welcome:show')
    end)
end

local function SetupSession()
    if ESX.PlayerLoaded then return end

    ESX.DisableSpawnManager()
    DoScreenFadeOut(0)
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()

    local spawn = Config.Identity.DefaultSpawn
    local ped = PlayerPedId()
    SetEntityCoordsNoOffset(ped, spawn.x, spawn.y, spawn.z, false, false, false)
    FreezeEntityPosition(ped, true)
    pendingIsNew = false

    ESX.TriggerServerCallback('esx_identity:autoJoin', function(result)
        if result and result.hasCharacter then
            -- Stay faded; FinishPlayerSpawn reveals after skin apply.
            return
        end
        SetEntityVisible(PlayerPedId(), false, false)
        startHidingLoop()
        CreateAndJoin()
    end)
end

RegisterNetEvent('esx:playerLoaded', function(playerData, isNew, skin)
    local spawnNew = isNew == true or pendingIsNew
    pendingIsNew = false
    DoScreenFadeOut(0)
    stopHidingLoop()

    -- Returning players: do not SetPlayerModel here. That swap + default
    -- components leaves the local ped invisible until appearance finishes.
    if spawnNew then
        local sex = playerData and playerData.sex or 'm'
        local model = (sex == 'f' or sex == 1) and MODEL_FEMALE or MODEL_MALE
        if requestModelFast(model) then
            SetPlayerModel(PlayerId(), model)
            SetModelAsNoLongerNeeded(model)
            Wait(150)
            local ped = PlayerPedId()
            SetPedDefaultComponentVariation(ped)
            ensureLocalPedRendered(ped)
        end
    else
        ensureLocalPedRendered(PlayerPedId())
    end

    FinishPlayerSpawn(playerData, spawnNew, skin)
end)

RegisterNetEvent('esx:onPlayerLogout', function()
    pendingIsNew = false
    stopHidingLoop()
    DoScreenFadeOut(0)
    Wait(500)
    SetupSession()
end)

CreateThread(function()
    while not ESX.PlayerLoaded do
        if NetworkIsPlayerActive(playerId) then
            SetupSession()
            break
        end
        Wait(100)
    end
end)

RegisterCommand('relog', function()
    TriggerServerEvent('esx_identity:relog')
end, false)
