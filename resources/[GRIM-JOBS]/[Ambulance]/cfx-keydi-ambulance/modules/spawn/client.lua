local options = {}
local isSelecting = false
local respawnLocations = {}
local respawn = require 'shared.spawn'

local function selectRespawn()
    if isSelecting then return false end

    local jobName = ESX.GetPlayerData().job.name

    if respawn.Jobs[jobName] then
        return respawn.Jobs[jobName]
    end

    isSelecting = true
    TriggerEvent('cfx-keydi-ambulance:isSelecting', true)

    CreateThread(function()
        local startTime = GetGameTimer()
        local timeLimit = 60000

        while isSelecting do
            local remainingTime = math.ceil((timeLimit - (GetGameTimer() - startTime)) / 1000)

            if remainingTime <= 0 then
                lib.closeInputDialog()
                break
            end

            lib.notify({
                id = 'spawnSelect',
                description = ('Time remaining to select respawn location: %s seconds'):format(remainingTime),
                type = 'warning',
                duration = 1500,
                showDuration = false
            })

            Wait(1000)
        end
    end)

    local locations = table.clone(options)

    -- local gangName = ESX.GetPlayerData().gang.name
    
    -- if respawn.Gangs[gangName] then
    --     table.insert(locations, 1, {
    --         value = jobName,
    --         label = respawn.Gangs[gangName].label
    --     })
    -- end

    -- local trapId = exports['cfx-cs-traphouse']:GetActiveTrap()
    -- if respawn.TraphouseGarages[trapId] and LocalPlayer.state.isInTrap then
    --     table.insert(locations, 1, {
    --         value = trapId,
    --         label = respawn.TraphouseGarages[trapId].label
    --     })
    -- end

    local input = lib.inputDialog('Select Respawn Location', {
        { type = 'select', label = 'Respawn Locations',  required = true, searchable = true, clearable = true, options = locations }
    }, { allowCancel = false })

    local locationKey = input and input[1] or locations[1].value

    isSelecting = false

    SetTimeout(5000, function()
        TriggerEvent('cfx-keydi-ambulance:isSelecting', false)
    end)

    return respawnLocations[locationKey] or false
end

CreateThread(function()
    for key, data in pairs(respawn.Locations) do
        options[#options+1] = { value = key, label = data.label }
        respawnLocations[key] = data.coords
    end

    for key, data in pairs(respawn.Gangs) do
        respawnLocations[key] = data.coords
    end

    -- for key, data in pairs(respawn.TraphouseGarages) do
    --     respawnLocations[key] = data.coords
    -- end
end)

exports('SelectRespawn', selectRespawn)