local options = {}
local isSelecting = false
local respawnLocations = {}
local respawn = require 'shared.spawn'
local Vars = require 'helpers.vars'

local function selectRespawn()
    if isSelecting then return false end

    -- STL is always where you died. City EMS job used to force LS hospital
    -- even if you died in Paleto — do not let job / NUI pick override that.
    local zoneId = Vars.DiedInBlaine() and 'paleto_hospital' or 'murrieta'
    if respawnLocations[zoneId] then
        return respawnLocations[zoneId]
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

    local input = lib.inputDialog('Select Respawn Location', {
        { type = 'select', label = 'Respawn Locations', required = true, searchable = true, clearable = true, options = locations }
    }, { allowCancel = false })

    local locationKey = input and input[1] or (locations[1] and locations[1].value)

    isSelecting = false

    SetTimeout(5000, function()
        TriggerEvent('cfx-keydi-ambulance:isSelecting', false)
    end)

    return (locationKey and respawnLocations[locationKey]) or false
end

CreateThread(function()
    for key, data in pairs(respawn.Locations) do
        if not data.hidden then
            options[#options + 1] = { value = key, label = data.label }
        end
        respawnLocations[key] = data.coords
    end

    for key, data in pairs(respawn.Gangs) do
        respawnLocations[key] = data.coords
    end
end)

exports('SelectRespawn', selectRespawn)
