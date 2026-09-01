local ESX = exports['es_extended']:getSharedObject()
local RewardProps = {}

-- Helper: Format Seconds into MM:SS Clock
local function formatClock(seconds)
    seconds = tonumber(seconds) or 0
    if seconds <= 0 then return '00:00' end
    local mins = math.floor(seconds / 60)
    local secs = seconds % 60
    return ('%02d:%02d'):format(mins, secs)
end

-- Announce Message Event
RegisterNetEvent('kodebykarl-turfwar:client:announce', function(msg, msgType)
    lib.notify({
        title = 'TURF WAR ANNOUNCEMENT',
        description = msg,
        type = msgType or 'info',
        duration = 8000
    })
end)

-- Main Target Setup & Claim Bag Spawning
CreateThread(function()
    while GetResourceState('ox_target') ~= 'started' do
        Wait(200)
    end

    for id, data in pairs(Config.TurfWars) do
        -- Register Target Zone at Trigger Location
        exports.ox_target:addSphereZone({
            coords = data.coords,
            radius = data.interactDistance or 2.5,
            debug = false,
            options = {
                {
                    name = ('kodebykarl_turfwar_start_%s'):format(id),
                    icon = 'fa-solid fa-flag-checkered',
                    label = ('Initiate %s'):format(data.label),
                    canInteract = function()
                        local state = GlobalState[('turf_state_%s'):format(id)] or 'IDLE'
                        return state == 'IDLE'
                    end,
                    onSelect = function()
                        -- Check allowed weapon if weapon restrictions enabled
                        if data.weapon and data.weapon.enable then
                            local ped = PlayerPedId()
                            local _, currentWeapon = GetCurrentPedWeapon(ped, true)
                            if not data.weapon.list[currentWeapon] then
                                return lib.notify({
                                    title = 'WEAPON RESTRICTED',
                                    description = 'You are not holding an allowed weapon for this Turf War.',
                                    type = 'error'
                                })
                            end
                        end

                        local ok = lib.progressBar({
                            duration = 4000,
                            label = ('Initiating %s...'):format(data.label),
                            useWhileDead = false,
                            canCancel = true,
                            disable = { move = true, car = true, combat = true },
                            anim = { dict = 'missheistdockssetup1clipboard@base', clip = 'base', flag = 49 }
                        })

                        if ok then
                            TriggerServerEvent('kodebykarl-turfwar:server:startTurf', id)
                        end
                    end
                },
                {
                    name = ('kodebykarl_turfwar_claim_%s'):format(id),
                    icon = 'fa-solid fa-box-open',
                    label = ('Claim %s Rewards'):format(data.label),
                    canInteract = function()
                        local claimable = GlobalState[('turf_claimable_%s'):format(id)]
                        return claimable == true
                    end,
                    onSelect = function()
                        local ok = lib.progressBar({
                            duration = data.claimTime or 8000,
                            label = ('Securing %s Rewards...'):format(data.label),
                            useWhileDead = false,
                            canCancel = true,
                            disable = { move = true, car = true, combat = true },
                            anim = { dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', clip = 'machinic_loop_mecheckbox', flag = 49 }
                        })

                        if ok then
                            TriggerServerEvent('kodebykarl-turfwar:server:claimTurf', id)
                        end
                    end
                }
            }
        })
    end
end)

-- Claim Reward Bag Prop & Live TextUI Loop
CreateThread(function()
    local rewardBagModel = Config.RewardBag.model or `prop_cs_heist_bag_02`

    while true do
        Wait(500)
        local ped = PlayerPedId()
        local pCoords = GetEntityCoords(ped)

        for id, data in pairs(Config.TurfWars) do
            local state = GlobalState[('turf_state_%s'):format(id)] or 'IDLE'
            local claimable = GlobalState[('turf_claimable_%s'):format(id)] == true
            local dist = #(pCoords - data.coords)

            -- Handle Claim Reward Bag Prop at Trigger Location
            if claimable then
                if not RewardProps[id] or not DoesEntityExist(RewardProps[id]) then
                    lib.requestModel(rewardBagModel, 5000)
                    if HasModelLoaded(rewardBagModel) then
                        local zOff = Config.RewardBag.zOffset or -0.98
                        local prop = CreateObject(rewardBagModel, data.coords.x, data.coords.y, data.coords.z + zOff, false, false, false)
                        SetEntityHeading(prop, Config.RewardBag.heading or 0.0)
                        FreezeEntityPosition(prop, true)
                        SetEntityInvincible(prop, true)
                        SetModelAsNoLongerNeeded(rewardBagModel)
                        RewardProps[id] = prop
                    end
                end
            else
                if RewardProps[id] and DoesEntityExist(RewardProps[id]) then
                    DeleteObject(RewardProps[id])
                    RewardProps[id] = nil
                end
            end

            -- Live HUD Stopwatch when standing near trigger spot during ACTIVE sequence
            if state == 'ACTIVE' and dist <= 25.0 then
                local remainingSecs = GlobalState[('turf_timer_%s'):format(id)] or 0
                if remainingSecs > 0 then
                    lib.showTextUI(('TURF WAR: %s | Time Remaining: %s'):format(data.label, formatClock(remainingSecs)), {
                        position = 'top-center',
                        icon = 'fa-solid fa-stopwatch',
                        style = { backgroundColor = '#140d11', color = '#ff3a3a', border = '1px solid #ff3a3a' }
                    })
                end
            end
        end
    end
end)

-- Resource Stop Cleanup
AddEventHandler('onResourceStop', function(resName)
    if resName ~= GetCurrentResourceName() then return end
    for id, prop in pairs(RewardProps) do
        if DoesEntityExist(prop) then
            DeleteObject(prop)
        end
    end
end)
