local function clamp(value, minimum, maximum)
    if type(value) ~= 'number' then
        value = tonumber(value) or 0
    end
    return math.min(math.max(value, minimum or 0), maximum or value)
end

CreateThread(function()
    while true do
        Wait(Config.Status and Config.Status.client_interval or 10000)
        if ESX.PlayerLoaded then
            TriggerServerEvent('es_extended:status:update')
        end
    end
end)

RegisterNetEvent('es_extended:status:updateStatus', function(hunger, thirst, stress)
    hunger = clamp(tonumber(hunger) or 0, 0, 100)
    thirst = clamp(tonumber(thirst) or 0, 0, 100)
    stress = clamp(tonumber(stress) or 0, 0, 100)

    ESX.PlayerData = ESX.PlayerData or {}
    ESX.PlayerData.metadata = ESX.PlayerData.metadata or {}
    ESX.PlayerData.metadata.status = ESX.PlayerData.metadata.status or {}
    ESX.PlayerData.metadata.status.hunger = hunger
    ESX.PlayerData.metadata.status.thirst = thirst
    ESX.PlayerData.metadata.status.stress = stress

    LocalPlayer.state:set('hunger', hunger, false)
    LocalPlayer.state:set('thirst', thirst, false)
    LocalPlayer.state:set('stress', stress, false)
end)

local removeStatus = {
    ['stress'] = 'ESX:Status:RemoveStress',
    ['hunger'] = 'ESX:Status:RemoveHunger',
    ['thirst'] = 'ESX:Status:RemoveThirst'
}

local addStatus = {
    ['stress'] = 'ESX:Status:AddStress',
    ['hunger'] = 'ESX:Status:AddHunger',
    ['thirst'] = 'ESX:Status:AddThirst'
}

AddEventHandler('es_extended:status:Add', function(status, value)
    if status == 'stress' and LocalPlayer.state.DisableStress then return end
    TriggerServerEvent(addStatus[status], value)
end)

AddEventHandler('es_extended:status:Remove', function(status, value)
    TriggerServerEvent(removeStatus[status], -value)
end)

CreateThread(function()
    while true do
        if ESX.PlayerLoaded then
            local metadata = ESX.PlayerData.metadata
            if metadata and metadata.status and (metadata.status.hunger <= 0 or metadata.status.thirst <= 0) and not IsEntityDead(ESX.PlayerData.ped) then
                local currentHealth = GetEntityHealth(ESX.PlayerData.ped)
                local decreaseThreshold = math.random(5, 10)
                SetEntityHealth(ESX.PlayerData.ped, currentHealth - decreaseThreshold)
                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.3)
            end
        end
        Wait(5000)
    end
end)

-- StatusSecure rollback (server cannot call SetEntityHealth / SetPedArmour)
RegisterNetEvent('es_extended:status:secureRollback', function(kind, value)
    local ped = cache and cache.ped or PlayerPedId()
    if not ped or ped == 0 then return end
    value = math.max(0, math.floor(tonumber(value) or 0))
    if kind == 'health' then
        SetEntityHealth(ped, value)
    elseif kind == 'armor' then
        SetPedArmour(ped, value)
    end
end)
