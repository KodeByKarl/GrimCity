local buhat = require 'configs.buhat'
local Vars = require 'helpers.vars'

local function resetLocal()
    Vars.isCarrying = false
    buhat.InProgress = false
    buhat.targetSrc = 0
    buhat.type = ''
    ClearPedSecondaryTask(cache.ped)
    DetachEntity(cache.ped, true, false)
end

RegisterCommand("buhat", function()
    if cache.vehicle then return end

    if buhat.InProgress then
        TriggerServerEvent("cfx-keydi-utils:Buhat:Stop")
        resetLocal()
        return
    end

    if Vars.isCarrying then
        return ESX.Notify('BUHAT', 'You are already in a carry.', 'error', 5000)
    end
    if LocalPlayer.state.dead or IsPedDeadOrDying(cache.ped, true) then
        return ESX.Notify('BUHAT', 'You cannot carry while dead.', 'error', 5000)
    end
    if cache.weapon then
        return ESX.Notify('BUHAT', 'You have a gun in your hand.', 'error', 5000)
    end

    local playerId = lib.getClosestPlayer(GetEntityCoords(cache.ped), 2.5, false)
    if not playerId then
        return ESX.Notify('BUHAT', 'No nearby player.', 'error', 5000)
    end

    local targetSrc = GetPlayerServerId(playerId)
    if not targetSrc or targetSrc == -1 then
        return ESX.Notify('BUHAT', 'No nearby player.', 'error', 5000)
    end
    if Player(targetSrc).state.escorted then return end

    Vars.isCarrying = true
    buhat.InProgress = true
    buhat.targetSrc = targetSrc
    buhat.type = "carrying"
    lib.requestAnimDict(buhat.personCarrying.animDict, 10000)
    TriggerServerEvent("cfx-keydi-utils:Buhat:Sync", targetSrc)
end, false)

RegisterNetEvent("cfx-keydi-utils:Buhat:syncTarget", function(targetSrc)
    local targetPed = GetPlayerPed(GetPlayerFromServerId(targetSrc))
    Vars.isCarrying = true
    buhat.InProgress = true
    buhat.targetSrc = targetSrc
    buhat.type = "beingcarried"
    lib.requestAnimDict(buhat.personCarried.animDict, 10000)
    AttachEntityToEntity(cache.ped, targetPed, 0, buhat.personCarried.attachX, buhat.personCarried.attachY, buhat.personCarried.attachZ, 0.5, 0.5, 180, false, false, false, false, 2, false)
end)

RegisterNetEvent("cfx-keydi-utils:Buhat:Stop", function()
    resetLocal()
end)

CreateThread(function()
    while true do
        local sleep = 500
        if buhat.InProgress then
            sleep = 0
            if buhat.type == "carrying" and (LocalPlayer.state.dead or IsPedDeadOrDying(cache.ped, true)) then
                TriggerServerEvent("cfx-keydi-utils:Buhat:Stop")
                resetLocal()
            elseif buhat.type == "carrying" then
                if not IsEntityPlayingAnim(cache.ped, buhat.personCarrying.animDict, buhat.personCarrying.anim, 3) then
                    TaskPlayAnim(cache.ped, buhat.personCarrying.animDict, buhat.personCarrying.anim, 8.0, -8.0, 100000, buhat.personCarrying.flag, 0, false, false, false)
                end
            elseif buhat.type == "beingcarried" then
                if not IsEntityPlayingAnim(cache.ped, buhat.personCarried.animDict, buhat.personCarried.anim, 3) then
                    TaskPlayAnim(cache.ped, buhat.personCarried.animDict, buhat.personCarried.anim, 8.0, -8.0, 100000, buhat.personCarried.flag, 0, false, false, false)
                end
            end
        end
        Wait(sleep)
    end
end)
