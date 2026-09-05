local ESX = exports['es_extended']:getSharedObject()
local isOpen = false
local tabletProp = nil
local opening = false

--- Non-blocking model/anim load — never spins the client when iPad is closed.
local function LoadModel(model, timeoutMs)
    if HasModelLoaded(model) then return true end
    RequestModel(model)
    local deadline = GetGameTimer() + (timeoutMs or 2500)
    while not HasModelLoaded(model) do
        if GetGameTimer() > deadline then return false end
        Wait(50)
    end
    return true
end

local function LoadAnim(dict, timeoutMs)
    if HasAnimDictLoaded(dict) then return true end
    RequestAnimDict(dict)
    local deadline = GetGameTimer() + (timeoutMs or 2500)
    while not HasAnimDictLoaded(dict) do
        if GetGameTimer() > deadline then return false end
        Wait(50)
    end
    return true
end

local function PlayAnimAsync()
    if not ConfigIpad.UseProp then return end
    CreateThread(function()
        if not isOpen then return end
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then return end

        local dict = ConfigIpad.Prop.dict
        if not LoadAnim(dict) then return end
        if not isOpen then return end
        TaskPlayAnim(ped, dict, ConfigIpad.Prop.anim, 2.0, 2.0, -1, 49, 0.0, false, false, false)

        local model = ConfigIpad.Prop.model
        if not LoadModel(model) then return end
        if not isOpen or DoesEntityExist(tabletProp) then return end

        local coords = GetEntityCoords(ped)
        tabletProp = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)
        AttachEntityToEntity(
            tabletProp, ped, GetPedBoneIndex(ped, ConfigIpad.Prop.bone),
            ConfigIpad.Prop.offset.x, ConfigIpad.Prop.offset.y, ConfigIpad.Prop.offset.z,
            ConfigIpad.Prop.rotation.x, ConfigIpad.Prop.rotation.y, ConfigIpad.Prop.rotation.z,
            true, true, false, true, 1, true
        )
    end)
end

local function StopAnim()
    local ped = PlayerPedId()
    if ConfigIpad.UseProp then
        StopAnimTask(ped, ConfigIpad.Prop.dict, ConfigIpad.Prop.anim, 1.5)
    end
    if tabletProp and DoesEntityExist(tabletProp) then
        DeleteEntity(tabletProp)
    end
    tabletProp = nil
end

--- Local-only snapshot — zero server wait.
local function BuildLocalPayload()
    local data = ESX.GetPlayerData() or {}
    local accounts = data.accounts or {}
    local cash, bank = 0, 0
    for i = 1, #accounts do
        local acc = accounts[i]
        if acc.name == 'money' then cash = acc.money or 0 end
        if acc.name == 'bank' then bank = acc.money or 0 end
    end

    local gangLabel = 'None'
    local gang = LocalPlayer and LocalPlayer.state and LocalPlayer.state.gang
    if gang then
        gangLabel = gang.label or gang.name or 'None'
    end

    return {
        firstName = data.firstName or data.firstname or '',
        lastName = data.lastName or data.lastname or '',
        cash = cash,
        bank = bank,
        job = (data.job and (data.job.label or data.job.name)) or 'Unemployed',
        gang = gangLabel,
        canEditEconomy = false,
        canPoliceBoss = false,
        canPoliceMdt = false,
        universityRole = 'visitor',
    }
end

--- Permissions in background — UI already open.
local function RefreshSessionAsync()
    CreateThread(function()
        local session = lib.callback.await('cfx-keydi-ipad:session', false)
        if not isOpen or type(session) ~= 'table' then return end
        SendNUIMessage({
            action = 'cfx-keydi-ipad:session',
            data = session,
        })
    end)
end

local function OpenIpad()
    if isOpen or opening then return end
    opening = true
    isOpen = true

    local payload = BuildLocalPayload()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'cfx-keydi-ipad:open',
        data = payload,
    })

    PlayAnimAsync()
    RefreshSessionAsync()
    opening = false
end

local function CloseIpad()
    if not isOpen then return end
    isOpen = false
    opening = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'cfx-keydi-ipad:close' })
    StopAnim()
end

RegisterCommand(ConfigIpad.OpenCommand, function()
    if isOpen then
        CloseIpad()
    else
        OpenIpad()
    end
end, false)

RegisterKeyMapping(ConfigIpad.OpenCommand, 'Open iPad', 'keyboard', ConfigIpad.OpenKey)

RegisterNUICallback('cfx-keydi-ipad:close', function(_, cb)
    CloseIpad()
    cb({ ok = true })
end)

-- Economy NUI only when Economy app asks — no idle cost
RegisterNUICallback('cfx-keydi-ipad:economy:getJobs', function(_, cb)
    if not isOpen then
        cb({ ok = false, jobs = {} })
        return
    end
    local result = lib.callback.await('cfx-keydi-ipad:economy:getJobs', false)
    cb(result or { ok = false, jobs = {} })
end)

RegisterNUICallback('cfx-keydi-ipad:economy:setSalary', function(data, cb)
    if not isOpen then
        cb({ ok = false })
        return
    end
    local result = lib.callback.await('cfx-keydi-ipad:economy:setSalary', false, data or {})
    cb(result or { ok = false })
end)

local function PvpResourceStarted()
    return GetResourceState('kodebykarl-pvp') == 'started'
end

RegisterNUICallback('cfx-keydi-ipad:pvp:status', function(_, cb)
    if not PvpResourceStarted() then
        cb({ ok = false, inPvp = false, players = 0, maxPlayers = 32, name = 'Deathmatch Arena', tags = {} })
        return
    end
    local result = lib.callback.await('kodebykarl-pvp:status', false)
    cb(result or { ok = false, inPvp = false, players = 0, maxPlayers = 32 })
end)

RegisterNUICallback('cfx-keydi-ipad:pvp:join', function(_, cb)
    CloseIpad()
    cb({ ok = true })
    if not PvpResourceStarted() then return end
    CreateThread(function()
        Wait(200)
        TriggerEvent('kodebykarl-pvp:client:joinFromIpad')
    end)
end)

RegisterNUICallback('cfx-keydi-ipad:pvp:leave', function(_, cb)
    CloseIpad()
    cb({ ok = true })
    if not PvpResourceStarted() then return end
    CreateThread(function()
        Wait(200)
        TriggerEvent('kodebykarl-pvp:client:leaveFromIpad')
    end)
end)

RegisterNUICallback('cfx-keydi-ipad:leaderboard:pvp', function(_, cb)
    if not isOpen then
        cb({ ok = false, rows = {} })
        return
    end
    if not PvpResourceStarted() then
        cb({ ok = false, rows = {}, mine = nil })
        return
    end
    local result = lib.callback.await('kodebykarl-pvp:getLeaderboard', false)
    cb(result or { ok = false, rows = {} })
end)

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        CloseIpad()
    end
end)

exports('OpenIpad', OpenIpad)
exports('CloseIpad', CloseIpad)
exports('IsIpadOpen', function()
    return isOpen
end)
