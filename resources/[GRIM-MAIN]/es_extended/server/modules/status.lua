local function clamp(value, minimum, maximum)
    if type(value) ~= 'number' then
        value = tonumber(value) or 0
    end
    return math.min(math.max(value, minimum or 0), maximum or value)
end

local function round(value)
    if ESX and ESX.Math and ESX.Math.Round then
        return ESX.Math.Round(value)
    end
    return math.floor((tonumber(value) or 0) + 0.5)
end

local function statusSecureEnabled()
    return Config.StatusSecure and Config.StatusSecure.enabled
end

local function secureCfg(key, default)
    if Config.StatusSecure and Config.StatusSecure[key] ~= nil then
        return Config.StatusSecure[key]
    end
    return default
end

local function kick(src, msg)
    DropPlayer(src, msg or 'Unauthorized character stat modification')
end

local lastHealth = {}
local lastArmor = {}
local healthHealBudget = {}
local armorHealBudget = {}
local respawnGrace = {}
local punishCooldown = {}

local function defaultStatusValue(stat, value)
    if value ~= nil then
        return tonumber(value) or 0
    end

    if stat == 'stress' then
        return 0
    end

    return 100
end

-- ox_inventory default item status is 0-1000000; ESX status is 0-100.
local function normalizeStatusDelta(amount)
    amount = tonumber(amount) or 0
    if math.abs(amount) > 100 then
        amount = amount * 0.0001
    end
    return amount
end

local function syncPlayerStatus(playerId, xPlayer)
    local status = xPlayer.getMeta('status') or {}
    local hunger = clamp(defaultStatusValue('hunger', status.hunger), 0, 100)
    local thirst = clamp(defaultStatusValue('thirst', status.thirst), 0, 100)
    local stress = clamp(defaultStatusValue('stress', status.stress), 0, 100)

    if status.hunger == nil or status.thirst == nil or status.stress == nil then
        status.hunger = hunger
        status.thirst = thirst
        status.stress = stress
        xPlayer.setMeta('status', status)
    end

    TriggerClientEvent('es_extended:status:updateStatus', playerId, hunger, thirst, stress)
end

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    syncPlayerStatus(playerId, xPlayer)
    -- Grace only: accept metadata health/armor restore. Do NOT grant permanent heal budget
    -- (that was letting menu heal/armor through forever after login).
    respawnGrace[playerId] = GetGameTimer() + secureCfg('loadGraceMs', 8000)
    healthHealBudget[playerId] = 0
    armorHealBudget[playerId] = 0
    SetTimeout(500, function()
        local ped = GetPlayerPed(playerId)
        if ped and ped ~= 0 then
            lastHealth[playerId] = GetEntityHealth(ped)
            lastArmor[playerId] = GetPedArmour(ped)
        end
    end)
end)

local function defaultBudgetTtl()
    return secureCfg('budgetTtlMs', 8000)
end

--- Grant a temporary allowance for legit health/armor increases (items, EMS, admin).
--- ttlMs: after this, the granted amount expires (does not wipe other active grants).
exports('GrantHealthArmorBudget', function(playerId, healthDelta, armorDelta, ttlMs)
    if type(playerId) ~= 'number' then return false end

    local h = tonumber(healthDelta) or 0
    local a = tonumber(armorDelta) or 0
    healthHealBudget[playerId] = (healthHealBudget[playerId] or 0) + h
    armorHealBudget[playerId] = (armorHealBudget[playerId] or 0) + a

    local ttl = ttlMs
    if ttl == nil then
        ttl = defaultBudgetTtl()
    end

    if ttl and ttl > 0 and (h > 0 or a > 0) then
        SetTimeout(ttl, function()
            if h > 0 then
                healthHealBudget[playerId] = math.max(0, (healthHealBudget[playerId] or 0) - h)
            end
            if a > 0 then
                armorHealBudget[playerId] = math.max(0, (armorHealBudget[playerId] or 0) - a)
            end
        end)
    end

    return true
end)

--- Short grace + budget for spawn / revive / hospital check-in (full restore).
exports('MarkRespawn', function(playerId, graceMs)
    if type(playerId) ~= 'number' then return false end
    local grace = graceMs or secureCfg('spawnGraceMs', 5000)
    respawnGrace[playerId] = GetGameTimer() + grace

    local h, a = 300, 100
    healthHealBudget[playerId] = (healthHealBudget[playerId] or 0) + h
    armorHealBudget[playerId] = (armorHealBudget[playerId] or 0) + a
    local ttl = math.max(grace, defaultBudgetTtl())
    SetTimeout(ttl, function()
        healthHealBudget[playerId] = math.max(0, (healthHealBudget[playerId] or 0) - h)
        armorHealBudget[playerId] = math.max(0, (armorHealBudget[playerId] or 0) - a)
    end)

    SetTimeout(math.min(grace, 1500), function()
        local ped = GetPlayerPed(playerId)
        if ped and ped ~= 0 then
            lastHealth[playerId] = GetEntityHealth(ped)
            lastArmor[playerId] = GetPedArmour(ped)
        end
    end)
    return true
end)

RegisterNetEvent('es_extended:status:update', function()
    local src = source
    local xPlayer = ESX.Players[src]
    if not xPlayer then return end

    local status = xPlayer.getMeta('status') or {}
    local hunger = clamp(round((tonumber(status.hunger) or 100) - (Config.Status and Config.Status.hunger_rate or 1)), 0, 100)
    local thirst = clamp(round((tonumber(status.thirst) or 100) - (Config.Status and Config.Status.thirst_rate or 1)), 0, 100)
    local stress = tonumber(status.stress) or 0

    status.hunger = hunger
    status.thirst = thirst
    status.stress = stress
    xPlayer.setMeta('status', status)

    TriggerClientEvent('es_extended:status:updateStatus', src, hunger, thirst, stress)
end)

local function updateStatus(src, stat, amount)
    local xPlayer = ESX.Players[src]
    if not xPlayer then return end

    local status = xPlayer.getMeta('status') or {}
    if stat == 'hunger' then
        status.hunger = clamp(defaultStatusValue('hunger', status.hunger) + amount, 0, 100)
    elseif stat == 'thirst' then
        status.thirst = clamp(defaultStatusValue('thirst', status.thirst) + amount, 0, 100)
    elseif stat == 'stress' then
        status.stress = clamp(defaultStatusValue('stress', status.stress) + amount, 0, 100)
    end

    xPlayer.setMeta('status', status)
    TriggerClientEvent('es_extended:status:updateStatus', src, status.hunger, status.thirst, status.stress)
end

--- Trusted server resources only (never call from a client net event).
local trustedNeedsResources = {
    ox_inventory = true,
    ['cfx-keydi-ambulance'] = true,
}

local function trustedNeedsInvoker()
    return trustedNeedsResources[GetInvokingResource()] == true
end

exports('SecureApplyItemStatus', function(playerId, statusTable)
    if not trustedNeedsInvoker() then return false end
    if type(playerId) ~= 'number' or type(statusTable) ~= 'table' then return false end

    for k, v in pairs(statusTable) do
        if k == 'hunger' or k == 'thirst' or k == 'stress' then
            updateStatus(playerId, k, normalizeStatusDelta(v))
        end
    end
    return true
end)

--- Set hunger/thirst/stress to absolute values (0-100). Trusted server resources only.
exports('SecureSetStatus', function(playerId, statusTable)
    if not trustedNeedsInvoker() then return false end
    if type(playerId) ~= 'number' or type(statusTable) ~= 'table' then return false end

    local xPlayer = ESX.Players[playerId]
    if not xPlayer then return false end

    local status = xPlayer.getMeta('status') or {}
    if statusTable.hunger ~= nil then
        status.hunger = clamp(tonumber(statusTable.hunger) or 0, 0, 100)
    end
    if statusTable.thirst ~= nil then
        status.thirst = clamp(tonumber(statusTable.thirst) or 0, 0, 100)
    end
    if statusTable.stress ~= nil then
        status.stress = clamp(tonumber(statusTable.stress) or 0, 0, 100)
    end

    status.hunger = clamp(defaultStatusValue('hunger', status.hunger), 0, 100)
    status.thirst = clamp(defaultStatusValue('thirst', status.thirst), 0, 100)
    status.stress = clamp(defaultStatusValue('stress', status.stress), 0, 100)

    xPlayer.setMeta('status', status)
    TriggerClientEvent('es_extended:status:updateStatus', playerId, status.hunger, status.thirst, status.stress)
    return true
end)

local stressNet = {}

local function trackStressAbs(src, delta)
    local lim = (Config.StatusSecure and Config.StatusSecure.stressAbsPerMinute) or 48
    local now = GetGameTimer()
    local e = stressNet[src]
    if not e or now - e.t > 60000 then
        stressNet[src] = { t = now, sum = 0 }
        e = stressNet[src]
    end
    e.sum = e.sum + math.abs(delta)
    return e.sum <= lim
end

RegisterNetEvent('ESX:Status:AddHunger', function(v)
    if statusSecureEnabled() then
        return kick(source, 'Unauthorized hunger change (use items / scripts).')
    end
    updateStatus(source, 'hunger', tonumber(v) or 0)
end)

RegisterNetEvent('ESX:Status:RemoveHunger', function(v)
    if statusSecureEnabled() then
        return kick(source, 'Unauthorized hunger change (use items / scripts).')
    end
    updateStatus(source, 'hunger', -(tonumber(v) or 0))
end)

RegisterNetEvent('ESX:Status:AddThirst', function(v)
    if statusSecureEnabled() then
        return kick(source, 'Unauthorized thirst change (use items / scripts).')
    end
    updateStatus(source, 'thirst', tonumber(v) or 0)
end)

RegisterNetEvent('ESX:Status:RemoveThirst', function(v)
    if statusSecureEnabled() then
        return kick(source, 'Unauthorized thirst change (use items / scripts).')
    end
    updateStatus(source, 'thirst', -(tonumber(v) or 0))
end)

RegisterNetEvent('ESX:Status:AddStress', function(v)
    v = tonumber(v) or 0
    if statusSecureEnabled() then
        if v <= 0 or v > 25 then
            return kick(source, 'Unauthorized stress change.')
        end
        if not trackStressAbs(source, v) then
            return kick(source, 'Stress modification rate limit.')
        end
    end
    updateStatus(source, 'stress', v)
end)

RegisterNetEvent('ESX:Status:RemoveStress', function(v)
    v = tonumber(v) or 0
    if statusSecureEnabled() then
        if v <= 0 or v > 100 then
            return kick(source, 'Unauthorized stress change.')
        end
        if not trackStressAbs(source, -v) then
            return kick(source, 'Stress modification rate limit.')
        end
    end
    updateStatus(source, 'stress', -v)
end)

local function collectIdentifiers(src)
    local lines = {}
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        lines[#lines + 1] = GetPlayerIdentifier(src, i)
    end
    return table.concat(lines, '\n')
end

local function discordLogUnauthorized(src, kind, oldValue, newValue, budget)
    local webhook = secureCfg('discordWebhook', '')
    if type(webhook) ~= 'string' or webhook == '' then return end

    local name = GetPlayerName(src) or 'Unknown'
    local payload = {
        username = 'Grim StatusSecure',
        embeds = { {
            title = 'Unauthorized ' .. kind .. ' gain',
            color = 15158332,
            description = ('**Player:** %s [`%s`]\n**Old:** `%s` → **New:** `%s`\n**Budget left:** `%s`\n**Action:** rollback (no ban)')
                :format(name, src, oldValue, newValue, budget or 0),
            fields = {
                { name = 'Identifiers', value = ('```%s```'):format(collectIdentifiers(src)), inline = false },
            },
            footer = { text = 'es_extended StatusSecure' },
        } },
    }

    PerformHttpRequest(webhook, function() end, 'POST', json.encode(payload), {
        ['Content-Type'] = 'application/json',
    })
end

local function rollbackVital(src, kind, value)
    TriggerClientEvent('es_extended:status:secureRollback', src, kind, math.max(0, math.floor(value or 0)))
end

-- Rollback + log only. Do not Electron-ban from es_extended (false positives + ugly "Banned By Resource: es_extended").
local function punishUnauthorized(src, kind, oldValue, newValue, budget)
    local ped = GetPlayerPed(src)
    if ped and ped ~= 0 then
        if kind == 'health' then
            rollbackVital(src, 'health', oldValue)
            lastHealth[src] = oldValue
        else
            rollbackVital(src, 'armor', oldValue)
            lastArmor[src] = oldValue
        end
    end

    punishCooldown[src] = GetGameTimer() + 3000

    print(('[^3StatusSecure^0] Rolled back %s for %s [%s]: %s -> %s (budget=%s)')
        :format(kind, GetPlayerName(src) or '?', src, oldValue, newValue, budget or 0))

    discordLogUnauthorized(src, kind, oldValue, newValue, budget)
end

AddEventHandler('playerDropped', function()
    local src = source
    stressNet[src] = nil
    lastHealth[src] = nil
    lastArmor[src] = nil
    healthHealBudget[src] = nil
    armorHealBudget[src] = nil
    respawnGrace[src] = nil
    punishCooldown[src] = nil
end)

RegisterNetEvent('esx:onPlayerSpawn', function()
    local src = source
    if not ESX.Players[src] then return end
    -- Grace only — no permanent free heal/armor budget
    respawnGrace[src] = GetGameTimer() + secureCfg('spawnGraceMs', 5000)
    SetTimeout(800, function()
        local ped = GetPlayerPed(src)
        if ped and ped ~= 0 then
            lastHealth[src] = GetEntityHealth(ped)
            lastArmor[src] = GetPedArmour(ped)
        end
    end)
end)

CreateThread(function()
    while true do
        local interval = secureCfg('healthCheckInterval', 1000)
        Wait(interval)
        if not statusSecureEnabled() then goto continue end

        local noiseH = secureCfg('healthNoise', 4)
        local noiseA = secureCfg('armorNoise', 2)
        local minH = secureCfg('minHealthFlag', 15)
        local minA = secureCfg('minArmorFlag', 10)
        local now = GetGameTimer()

        for src in pairs(ESX.Players) do
            if punishCooldown[src] and now < punishCooldown[src] then goto nextp end

            local ped = GetPlayerPed(src)
            if not ped or ped == 0 then goto nextp end

            local playerState = Player(src).state
            if playerState and (playerState.dead or playerState.isDead) then
                lastHealth[src] = GetEntityHealth(ped)
                lastArmor[src] = GetPedArmour(ped)
                goto nextp
            end

            local h, a = GetEntityHealth(ped), GetPedArmour(ped)
            -- Ignore invalid / not-yet-synced values
            if type(h) ~= 'number' or h <= 0 then goto nextp end

            local lh, la = lastHealth[src], lastArmor[src]

            if respawnGrace[src] and now < respawnGrace[src] then
                lastHealth[src], lastArmor[src] = h, a
                goto nextp
            end

            if not lh then
                lastHealth[src], lastArmor[src] = h, a
                goto nextp
            end

            local dh, da = h - lh, a - la

            -- Health decreased (damage) — accept
            if dh < -2 then
                lastHealth[src] = h
            elseif dh > noiseH then
                local need = dh - noiseH
                local budget = healthHealBudget[src] or 0
                if need > budget and need >= minH then
                    healthHealBudget[src] = 0
                    punishUnauthorized(src, 'health', lh, h, budget)
                    goto nextp
                elseif need > budget then
                    -- Small unauthorized bump: rollback (still punish if clearly menu-sized)
                    healthHealBudget[src] = 0
                    rollbackVital(src, 'health', lh)
                    lastHealth[src] = lh
                else
                    healthHealBudget[src] = math.max(0, budget - need)
                    lastHealth[src] = h
                end
            else
                lastHealth[src] = h
            end

            -- Armor decreased — accept
            if da < -1 then
                lastArmor[src] = a
            elseif da > noiseA then
                local need = da - noiseA
                local budget = armorHealBudget[src] or 0
                if need > budget and need >= minA then
                    armorHealBudget[src] = 0
                    punishUnauthorized(src, 'armor', la, a, budget)
                    goto nextp
                elseif need > budget then
                    armorHealBudget[src] = 0
                    rollbackVital(src, 'armor', la)
                    lastArmor[src] = la
                else
                    armorHealBudget[src] = math.max(0, budget - need)
                    lastArmor[src] = a
                end
            else
                lastArmor[src] = a
            end

            ::nextp::
        end
        ::continue::
    end
end)
