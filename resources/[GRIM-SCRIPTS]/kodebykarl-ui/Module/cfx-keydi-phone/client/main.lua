--[[
    cfx-keydi-phone — companion iPhone NUI shell (not lb-phone)
]]

if ConfigPhone and ConfigPhone.Enabled == false then return end

local ESX = exports['es_extended']:getSharedObject()
local isOpen = false
local phoneProp = nil
local opening = false
local ox_inventory = exports.ox_inventory

local PhonePrefs = {
    messageNotify = true,
    messageSound = true,
    useProp = true,
}

local CallStatus = nil -- 'outgoing' | 'incoming' | 'active' | nil
local ringtone = false
local CALL_ANIM = 'cellphone_call_listen_base'

local function ToBool(v, fallback)
    if v == nil then return fallback end
    if v == true or v == 1 or v == '1' or v == 'true' then return true end
    if v == false or v == 0 or v == '0' or v == 'false' then return false end
    return fallback
end

local function LoadPrefs()
    local raw = GetResourceKvpString('cfx_keydi_phone_prefs')
    if not raw or raw == '' then return end
    local ok, decoded = pcall(json.decode, raw)
    if ok and type(decoded) == 'table' then
        PhonePrefs.messageNotify = ToBool(decoded.messageNotify, PhonePrefs.messageNotify)
        PhonePrefs.messageSound = ToBool(decoded.messageSound, PhonePrefs.messageSound)
        PhonePrefs.useProp = ToBool(decoded.useProp, PhonePrefs.useProp)
    end
end

local function SavePrefs()
    SetResourceKvp('cfx_keydi_phone_prefs', json.encode(PhonePrefs))
end

CreateThread(function()
    LoadPrefs()
end)

local function LocalNumber()
    local data = ESX.GetPlayerData() or {}
    if data.ssn and data.ssn ~= '' then
        return tostring(data.ssn)
    end
    local ident = data.identifier or ''
    if ident == '' then return '—' end
    local hash = 0
    for i = 1, #ident do
        hash = (hash * 31 + string.byte(ident, i)) % 100000000
    end
    return ('555-%04d'):format(hash % 10000)
end

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

local function PlayAnimAsync(kind)
    if not PhonePrefs.useProp or not ConfigPhone.UseProp then return end
    CreateThread(function()
        if not isOpen then return end
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then return end

        local dict = ConfigPhone.Prop.dict
        if not LoadAnim(dict) then return end
        if not isOpen then return end
        local anim = (kind == 'call') and CALL_ANIM or ConfigPhone.Prop.anim
        TaskPlayAnim(ped, dict, anim, 3.0, 3.0, -1, 49, 0.0, false, false, false)

        local model = ConfigPhone.Prop.model
        if not LoadModel(model) then return end
        if not isOpen or DoesEntityExist(phoneProp) then return end

        local coords = GetEntityCoords(ped)
        phoneProp = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)
        AttachEntityToEntity(
            phoneProp, ped, GetPedBoneIndex(ped, ConfigPhone.Prop.bone),
            ConfigPhone.Prop.offset.x, ConfigPhone.Prop.offset.y, ConfigPhone.Prop.offset.z,
            ConfigPhone.Prop.rotation.x, ConfigPhone.Prop.rotation.y, ConfigPhone.Prop.rotation.z,
            true, true, false, true, 1, true
        )
    end)
end

local function StopAnim()
    local ped = PlayerPedId()
    if ConfigPhone.UseProp then
        StopAnimTask(ped, ConfigPhone.Prop.dict, ConfigPhone.Prop.anim, 1.5)
        StopAnimTask(ped, ConfigPhone.Prop.dict, CALL_ANIM, 1.5)
    end
    if phoneProp and DoesEntityExist(phoneProp) then
        DeleteEntity(phoneProp)
    end
    phoneProp = nil
end

local function BuildLocalPayload()
    local data = ESX.GetPlayerData() or {}
    local accounts = data.accounts or {}
    local cash, bank = 0, 0
    for i = 1, #accounts do
        local acc = accounts[i]
        if acc.name == 'money' then cash = acc.money or 0 end
        if acc.name == 'bank' then bank = acc.money or 0 end
    end

    return {
        firstName = data.firstName or data.firstname or '',
        lastName = data.lastName or data.lastname or '',
        cash = cash,
        bank = bank,
        job = (data.job and (data.job.label or data.job.name)) or 'Unemployed',
        number = LocalNumber(),
    }
end

local function OpenPhone()
    if isOpen or opening then return end
    opening = true
    isOpen = true

    local payload = BuildLocalPayload()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'cfx-keydi-phone:open',
        data = payload,
    })

    PlayAnimAsync()
    opening = false
end

local function StopRingtone()
    ringtone = false
end

local function StartRingtone()
    if ringtone then return end
    ringtone = true
    CreateThread(function()
        while ringtone do
            PlaySoundFrontend(-1, 'Remote_Ring', 'Phone_SoundSet_Michael', true)
            Wait(2800)
        end
    end)
end

local function ClearCallLocal()
    CallStatus = nil
    StopRingtone()
end

local function ClosePhone()
    if CallStatus then
        local ev = CallStatus == 'incoming' and 'cfx-keydi-phone:server:call:decline' or 'cfx-keydi-phone:server:call:hangup'
        ClearCallLocal()
        pcall(function()
            lib.callback.await(ev, false)
        end)
    end
    if not isOpen then return end
    isOpen = false
    opening = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'cfx-keydi-phone:close' })
    StopAnim()
end

RegisterCommand(ConfigPhone.OpenCommand, function()
    if isOpen then
        ClosePhone()
    else
        OpenPhone()
    end
end, false)

RegisterKeyMapping(ConfigPhone.OpenCommand, 'Open Phone', 'keyboard', ConfigPhone.OpenKey)

RegisterNUICallback('cfx-keydi-phone:close', function(_, cb)
    ClosePhone()
    cb({ ok = true })
end)

RegisterNUICallback('cfx-keydi-phone:market:catalog', function(_, cb)
    if not isOpen then
        cb({ items = {}, nextUpdateAt = 0 })
        return
    end

    local catalog = { items = {}, nextUpdateAt = 0 }
    local ok, result = pcall(function()
        return lib.callback.await('cfx-keydi-market:server:getCatalog', false)
    end)
    if ok and type(result) == 'table' then
        catalog = result
    end

    for _, row in ipairs(catalog.items or {}) do
        local oxItem = ox_inventory:Items(row.item)
        if oxItem and oxItem.label then
            row.label = oxItem.label
        end
        row.image = ('nui://ox_inventory/web/images/%s.png'):format(row.item)
    end

    cb(catalog)
end)

local function AwaitPhoneCallback(name, payload)
    local ok, result = pcall(function()
        return lib.callback.await(name, false, payload)
    end)
    if ok and type(result) == 'table' then
        return result
    end
    return { ok = false, error = 'Request failed' }
end

RegisterNUICallback('cfx-keydi-phone:contacts:list', function(_, cb)
    if not isOpen then
        cb({ ok = false, contacts = {} })
        return
    end
    cb(AwaitPhoneCallback('cfx-keydi-phone:server:contacts:list'))
end)

RegisterNUICallback('cfx-keydi-phone:contacts:online', function(_, cb)
    if not isOpen then
        cb({ ok = false, players = {} })
        return
    end
    cb(AwaitPhoneCallback('cfx-keydi-phone:server:contacts:online'))
end)

RegisterNUICallback('cfx-keydi-phone:contacts:search', function(data, cb)
    if not isOpen then
        cb({ ok = false, players = {} })
        return
    end
    cb(AwaitPhoneCallback('cfx-keydi-phone:server:contacts:search', data and data.query or ''))
end)

RegisterNUICallback('cfx-keydi-phone:contacts:add', function(data, cb)
    if not isOpen then
        cb({ ok = false, error = 'Phone closed' })
        return
    end
    cb(AwaitPhoneCallback('cfx-keydi-phone:server:contacts:add', data or {}))
end)

RegisterNUICallback('cfx-keydi-phone:contacts:update', function(data, cb)
    if not isOpen then
        cb({ ok = false, error = 'Phone closed' })
        return
    end
    cb(AwaitPhoneCallback('cfx-keydi-phone:server:contacts:update', data or {}))
end)

RegisterNUICallback('cfx-keydi-phone:contacts:remove', function(data, cb)
    if not isOpen then
        cb({ ok = false, error = 'Phone closed' })
        return
    end
    cb(AwaitPhoneCallback('cfx-keydi-phone:server:contacts:remove', data or {}))
end)

RegisterNUICallback('cfx-keydi-phone:messages:conversations', function(_, cb)
    if not isOpen then
        cb({ ok = false, conversations = {}, unreadTotal = 0 })
        return
    end
    cb(AwaitPhoneCallback('cfx-keydi-phone:server:messages:conversations'))
end)

RegisterNUICallback('cfx-keydi-phone:messages:thread', function(data, cb)
    if not isOpen then
        cb({ ok = false, messages = {} })
        return
    end
    cb(AwaitPhoneCallback('cfx-keydi-phone:server:messages:thread', data or {}))
end)

RegisterNUICallback('cfx-keydi-phone:messages:send', function(data, cb)
    if not isOpen then
        cb({ ok = false, error = 'Phone closed' })
        return
    end
    cb(AwaitPhoneCallback('cfx-keydi-phone:server:messages:send', data or {}))
end)

RegisterNUICallback('cfx-keydi-phone:messages:unread', function(_, cb)
    cb(AwaitPhoneCallback('cfx-keydi-phone:server:messages:unread'))
end)

RegisterNUICallback('cfx-keydi-phone:call:start', function(data, cb)
    if not isOpen then
        cb({ ok = false, error = 'Phone closed' })
        return
    end
    if CallStatus then
        cb({ ok = false, error = 'Already in a call' })
        return
    end
    local result = AwaitPhoneCallback('cfx-keydi-phone:server:call:start', data or {})
    if result and result.ok then
        CallStatus = 'outgoing'
        StartRingtone()
        PlayAnimAsync('call')
    end
    cb(result)
end)

RegisterNUICallback('cfx-keydi-phone:call:accept', function(_, cb)
    if CallStatus ~= 'incoming' then
        cb({ ok = false, error = 'No incoming call' })
        return
    end
    local result = AwaitPhoneCallback('cfx-keydi-phone:server:call:accept')
    if result and result.ok then
        CallStatus = 'active'
        StopRingtone()
        if not isOpen then
            OpenPhone()
        end
        PlayAnimAsync('call')
    end
    cb(result)
end)

RegisterNUICallback('cfx-keydi-phone:call:decline', function(_, cb)
    ClearCallLocal()
    cb(AwaitPhoneCallback('cfx-keydi-phone:server:call:decline'))
end)

RegisterNUICallback('cfx-keydi-phone:call:hangup', function(_, cb)
    ClearCallLocal()
    cb(AwaitPhoneCallback('cfx-keydi-phone:server:call:hangup'))
end)

RegisterNetEvent('cfx-keydi-phone:client:callIncoming', function(payload)
    if type(payload) ~= 'table' then return end
    CallStatus = 'incoming'
    StartRingtone()
    if not isOpen then
        OpenPhone()
    end
    SendNUIMessage({
        action = 'cfx-keydi-phone:call:incoming',
        data = payload,
    })
end)

RegisterNetEvent('cfx-keydi-phone:client:callAccepted', function(payload)
    CallStatus = 'active'
    StopRingtone()
    PlayAnimAsync('call')
    SendNUIMessage({
        action = 'cfx-keydi-phone:call:accepted',
        data = type(payload) == 'table' and payload or {},
    })
end)

RegisterNetEvent('cfx-keydi-phone:client:callEnded', function(payload)
    local wasOpen = isOpen
    ClearCallLocal()
    SendNUIMessage({
        action = 'cfx-keydi-phone:call:ended',
        data = type(payload) == 'table' and payload or {},
    })
    if wasOpen then
        PlayAnimAsync()
    end
end)

RegisterNUICallback('cfx-keydi-phone:settings:get', function(_, cb)
    cb({
        ok = true,
        settings = {
            messageNotify = PhonePrefs.messageNotify,
            messageSound = PhonePrefs.messageSound,
            useProp = PhonePrefs.useProp,
        },
    })
end)

RegisterNUICallback('cfx-keydi-phone:settings:set', function(data, cb)
    data = type(data) == 'table' and data or {}

    if data.messageNotify ~= nil then
        PhonePrefs.messageNotify = ToBool(data.messageNotify, PhonePrefs.messageNotify)
    end
    if data.messageSound ~= nil then
        PhonePrefs.messageSound = ToBool(data.messageSound, PhonePrefs.messageSound)
    end
    if data.useProp ~= nil then
        local prev = PhonePrefs.useProp
        PhonePrefs.useProp = ToBool(data.useProp, PhonePrefs.useProp)
        if isOpen and prev ~= PhonePrefs.useProp then
            if PhonePrefs.useProp then
                PlayAnimAsync()
            else
                StopAnim()
            end
        end
    end

    SavePrefs()
    cb({
        ok = true,
        settings = {
            messageNotify = PhonePrefs.messageNotify,
            messageSound = PhonePrefs.messageSound,
            useProp = PhonePrefs.useProp,
        },
    })
end)

RegisterNetEvent('cfx-keydi-phone:client:newMessage', function(payload)
    if type(payload) ~= 'table' then return end

    local from = payload.fromName or 'Someone'
    local preview = tostring(payload.body or '')
    if #preview > 80 then
        preview = preview:sub(1, 77) .. '...'
    end

    if PhonePrefs.messageNotify then
        lib.notify({
            title = 'New Message',
            description = ('%s: %s'):format(from, preview),
            type = 'inform',
            duration = 7000,
            icon = 'message',
        })
    end

    if PhonePrefs.messageSound then
        PlaySoundFrontend(-1, 'Text_Arrive_Tone', 'Phone_SoundSet_Default', true)
    end

    -- Always push NUI so Messages app / badge stay in sync; toast respects notify pref via App
    SendNUIMessage({
        action = 'cfx-keydi-phone:message',
        data = payload,
        showToast = PhonePrefs.messageNotify,
    })
end)

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        ClosePhone()
    end
end)

exports('OpenPhone', OpenPhone)
exports('ClosePhone', ClosePhone)
exports('IsPhoneOpen', function()
    return isOpen
end)
