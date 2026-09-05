local ESX = exports['es_extended']:getSharedObject()
local isOpen = false
local tabletProp = nil

local function PlayAnim()
    if not ConfigIpad.UseProp then return end
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then return end

    local dict = ConfigIpad.Prop.dict
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(10) end
    TaskPlayAnim(ped, dict, ConfigIpad.Prop.anim, 2.0, 2.0, -1, 49, 0.0, false, false, false)

    local model = ConfigIpad.Prop.model
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end

    if not DoesEntityExist(tabletProp) then
        local coords = GetEntityCoords(ped)
        tabletProp = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)
        AttachEntityToEntity(
            tabletProp, ped, GetPedBoneIndex(ped, ConfigIpad.Prop.bone),
            ConfigIpad.Prop.offset.x, ConfigIpad.Prop.offset.y, ConfigIpad.Prop.offset.z,
            ConfigIpad.Prop.rotation.x, ConfigIpad.Prop.rotation.y, ConfigIpad.Prop.rotation.z,
            true, true, false, true, 1, true
        )
    end
end

local function StopAnim()
    local ped = PlayerPedId()
    StopAnimTask(ped, ConfigIpad.Prop.dict, ConfigIpad.Prop.anim, 1.5)
    if DoesEntityExist(tabletProp) then
        DeleteEntity(tabletProp)
        tabletProp = nil
    end
end

local function BuildPayload()
    local data = ESX.GetPlayerData() or {}
    local accounts = data.accounts or {}
    local cash, bank = 0, 0
    for i = 1, #accounts do
        local acc = accounts[i]
        if acc.name == 'money' then cash = acc.money or 0 end
        if acc.name == 'bank' then bank = acc.money or 0 end
    end

    local gangLabel = 'None'
    if LocalPlayer and LocalPlayer.state and LocalPlayer.state.gang then
        gangLabel = LocalPlayer.state.gang.label or LocalPlayer.state.gang.name or 'None'
    end

    return {
        firstName = data.firstName or data.firstname or '',
        lastName = data.lastName or data.lastname or '',
        cash = cash,
        bank = bank,
        job = (data.job and (data.job.label or data.job.name)) or 'Unemployed',
        gang = gangLabel,
    }
end

local function OpenIpad()
    if isOpen then return end
    isOpen = true
    PlayAnim()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'cfx-keydi-ipad:open',
        data = BuildPayload(),
    })
end

local function CloseIpad()
    if not isOpen then return end
    isOpen = false
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
