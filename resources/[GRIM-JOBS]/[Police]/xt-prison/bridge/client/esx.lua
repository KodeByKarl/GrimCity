if GetResourceState('es_extended') ~= 'started' then return end
local ESX = exports['es_extended']:getSharedObject()
local prisonJob = require 'configs.prisonjob'
local prisonModules = require 'modules.client.prison'

local ox_target = exports.ox_target
local busy = false
local createdZones = {}
local playerState = LocalPlayer.state

RegisterNetEvent('esx:playerLoaded', function()
    TriggerEvent('xt-prison:client:onLoad')
end)

RegisterNetEvent('esx:onPlayerLogout', function()
    TriggerEvent('xt-prison:client:onUnload')
end)


local function FixWirings(id)
    local skill = {}
    math.randomseed(GetGameTimer())
    busy = true
    TaskStartScenarioInPlace(cache.ped, "WORLD_HUMAN_WELDING", 0, false)
    local count = math.random(prisonJob.skillCheck.count.min, prisonJob.skillCheck.count.max)
    local keys = prisonJob.skillCheck.keys[math.random(1, #prisonJob.skillCheck.keys)]
    for i = 1, count do
        table.insert(skill, 'easy')
    end
    local success = lib.skillCheck(skill, keys)
    if success then
        local reducedTime = prisonJob.Welding.reduceTime
        TriggerServerEvent('xt-prison:server:update', reducedTime, id)
        ESX.Notify('PRISON', ('Your sentence have been reduced by %s month(s)'):format(reducedTime), 'success', 5000)
        prisonJob.Welding.locations[id].state = false
    end
    lib.hideTextUI()
    busy = false
    ClearPedTasks(cache.ped)
end

local function nearbyFixZone(point)
    if prisonJob.Welding.locations[point.fixIndex].state and playerState.jailTime > 2 and not busy then
        DrawMarker(2, point.coords.x, point.coords.y, point.coords.z + 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 255, 255, 255, 155, false, true, 2, true, nil, nil, false)
        if point.interact < point.currentDistance then
            if point.isTextUI then
                point.isTextUI = false
                lib.hideTextUI()
            end
            return
        end
        if not point.isTextUI then
            point.isTextUI = true
            local prompt = ('[E] Fix')
            lib.showTextUI(prompt, {
                position = 'bottom-center',
                icon = 'fa-solid fa-briefcase',
                style = {
                    backgroundColor = '#2a2a2a',
                    color = '#f0f0f0',
                    padding = '16px 20px',
                    fontSize = '15px',
                    fontWeight = '500',
                    fontFamily = 'Segoe UI, sans-serif',
                    borderRadius = '13px',
                    boxShadow = '8px 8px 15px rgba(0,0,0,0.4), -4px -4px 10px rgba(255,255,255,0.05)',
                    border = '1px solid rgba(255, 255, 255, 0.05)',
                    ['.description'] = {
                        color = '#d0d0d0',
                        fontSize = '13px',
                        marginTop = '6px'
                    }
                }
            })
        end
        if IsControlJustPressed(0, 38) then
            FixWirings(point.fixIndex)
        end
    end
end


local function LoadPrisonJob()
    CreateThread(function()
        for i = 1, #prisonJob.Welding.locations do
            local data = prisonJob.Welding.locations[i]
            createdZones[i] = lib.points.new({
                coords = data.coords,
                distance = data.distance.marker,
                interact = data.distance.interact,
                fixIndex = i,
                nearby = nearbyFixZone
            })
        end
    end)
    CreateThread(function()
        while playerState.inJail do
            if playerState.jailTime > 0 then
                ESX.Notify('PRISON', ('You have %s month(s) left.'):format(playerState.jailTime), 'info', 5000)
            else
                local timeLeft = lib.callback.await('xt-prison:server:checkJailTime', false)
                if timeLeft <= 0 then
                    prisonModules.exitPrison(true)
                end
            end
            Wait(1 * 60000)
        end
    end)
end

exports('LoadPrisonJob', LoadPrisonJob)



local function UnloadPrisonJob()
    for i = 1, #prisonJob.Welding.locations do
        createdZones[i]:remove()
        createdZones[i] = nil
        prisonJob.Welding.locations[i].state = true
    end
end

exports('UnloadPrisonJob', UnloadPrisonJob)