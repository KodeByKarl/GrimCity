local isBadgeUIOpen = false
local currentBadgeHeadshotHandle = nil
local currentBadgeProp = nil

local function ClearBadgeHeadshot()
    if currentBadgeHeadshotHandle and IsPedheadshotValid(currentBadgeHeadshotHandle) then
        UnregisterPedheadshot(currentBadgeHeadshotHandle)
    end
    currentBadgeHeadshotHandle = nil
end

local function ClearBadgeProp()
    if currentBadgeProp and DoesEntityExist(currentBadgeProp) then
        DeleteEntity(currentBadgeProp)
    end
    currentBadgeProp = nil
end

local function GetPlayerPedHeadshotUrl()
    ClearBadgeHeadshot()
    local ped = PlayerPedId()
    if not ped or not DoesEntityExist(ped) then return "" end

    local handle = RegisterPedheadshot(ped)
    local timeout = 2500
    while not IsPedheadshotReady(handle) and timeout > 0 do
        Wait(50)
        timeout = timeout - 50
    end

    if IsPedheadshotValid(handle) and IsPedheadshotReady(handle) then
        currentBadgeHeadshotHandle = handle
        local txd = GetPedheadshotTxdString(handle)
        return ("https://nui-img/%s/%s"):format(txd, txd)
    end

    return ""
end

local function PlayBadgeEmote()
    local ped = PlayerPedId()
    local emote = ConfigBadge.Emote

    RequestAnimDict(emote.dict)
    local timeout = 1000
    while not HasAnimDictLoaded(emote.dict) and timeout > 0 do
        Wait(50)
        timeout = timeout - 50
    end

    TaskPlayAnim(ped, emote.dict, emote.anim, 8.0, -8.0, emote.duration, 49, 0, false, false, false)

    -- Attach badge prop
    local propHash = GetHashKey(emote.prop)
    RequestModel(propHash)
    timeout = 1000
    while not HasModelLoaded(propHash) and timeout > 0 do
        Wait(50)
        timeout = timeout - 50
    end

    ClearBadgeProp()
    local boneIndex = GetPedBoneIndex(ped, emote.bone)
    local coords = GetEntityCoords(ped)
    local prop = CreateObject(propHash, coords.x, coords.y, coords.z + 0.2, true, true, true)
    AttachEntityToEntity(prop, ped, boneIndex, emote.pos.x, emote.pos.y, emote.pos.z, emote.rot.x, emote.rot.y, emote.rot.z, true, true, false, true, 1, true)
    currentBadgeProp = prop

    -- Auto clean prop after emote duration
    CreateThread(function()
        Wait(emote.duration)
        ClearBadgeProp()
        StopAnimTask(ped, emote.dict, emote.anim, 1.0)
    end)
end

local function DisplayBadgeUI(data)
    if not data then return end

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "cfx-keydi-badge:show",
        data = data
    })
    isBadgeUIOpen = true
end

local function CloseBadgeUI()
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "cfx-keydi-badge:hide"
    })
    isBadgeUIOpen = false
    ClearBadgeHeadshot()
    ClearBadgeProp()
end

RegisterNUICallback("cfx-keydi-badge:close", function(data, cb)
    CloseBadgeUI()
    if cb then cb("ok") end
end)

local function TriggerShowBadge()
    ESX.TriggerServerCallback('cfx-keydi-badge:getBadgeData', function(result)
        if not result or not result.success then
            if ESX and ESX.ShowNotification then
                ESX.ShowNotification(result and result.message or "Cannot show badge.", "error")
            end
            return
        end

        -- Play realistic badge holding emote
        PlayBadgeEmote()

        -- Get live 1x1 character ped mugshot
        result.photoUrl = GetPlayerPedHeadshotUrl()

        -- Broadcast to nearby players and display for self
        TriggerServerEvent("cfx-keydi-badge:server:showBadgeToNearby", result)
    end)
end

-- Command /badge
RegisterCommand(ConfigBadge.Command or "badge", function()
    if isBadgeUIOpen then
        CloseBadgeUI()
    else
        TriggerShowBadge()
    end
end, false)

-- Client events
RegisterNetEvent("cfx-keydi-badge:client:displayBadgeUI", function(badgeData)
    DisplayBadgeUI(badgeData)
end)

RegisterNetEvent("cfx-keydi-badge:client:closeBadgeUI", function()
    CloseBadgeUI()
end)

-- Exports
exports("OpenBadgeCard", TriggerShowBadge)
exports("CloseBadgeCard", CloseBadgeUI)
