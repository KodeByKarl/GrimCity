local ESX = exports["es_extended"]:getSharedObject()
local isVisible = false
local currentSettings = {}
local victimCache = {}

-- Load settings from client key-value store (persistent local storage)
local function LoadSettings()
    local kvp = GetResourceKvpString("cfx-keydi-indicator:settings")
    if kvp then
        currentSettings = json.decode(kvp)
    else
        currentSettings = {
            deadText = ConfigIndicator.DefaultSettings.deadText,
            deadIcon = ConfigIndicator.DefaultSettings.deadIcon,
            fontFamily = ConfigIndicator.DefaultSettings.fontFamily,
            fontSize = ConfigIndicator.DefaultSettings.fontSize,
            duration = ConfigIndicator.DefaultSettings.duration,
            healthColor = ConfigIndicator.DefaultSettings.healthColor,
            armorColor = ConfigIndicator.DefaultSettings.armorColor
        }
    end
end

-- Open/Close Settings Config UI
local function ToggleConfig(state)
    isVisible = state
    SetNuiFocus(state, state)
    SendNUIMessage({
        action = state and "indicator:showConfig" or "indicator:hideConfig",
        settings = currentSettings
    })
end

-- Sync settings update from UI
RegisterNUICallback('indicator:updateSettings', function(data, cb)
    cb('ok')
    currentSettings = data
    SetResourceKvp("cfx-keydi-indicator:settings", json.encode(currentSettings))
end)

-- Close configuration callback
RegisterNUICallback('indicator:closeConfig', function(data, cb)
    cb('ok')
    ToggleConfig(false)
end)

-- Initialize settings on load
CreateThread(function()
    LoadSettings()
end)

-- Global function to allow opening config from other client scripts in the same resource
function OpenIndicatorConfig()
    ToggleConfig(true)
end

-- Keep last-frame vitals so CEventNetworkEntityDamage (often 1+ frames late) still sees pre-hit HP.
-- A 100ms poll was overwriting pInfo after one-shot headshots, so those hits never registered.
local pInfo = {
    health = 0,
    armor = 0,
    lastAliveHealth = 200,
    lastAliveArmor = 0
}

CreateThread(function()
    local prevHealth, prevArmor
    while true do
        local playerPed = PlayerPedId()
        if playerPed and playerPed ~= 0 then
            local h = GetEntityHealth(playerPed)
            local a = GetPedArmour(playerPed)
            pInfo.health = prevHealth or h
            pInfo.armor = prevArmor or a
            prevHealth = h
            prevArmor = a
            if h > 100 then
                pInfo.lastAliveHealth = h
            end
            pInfo.lastAliveArmor = a
        end
        Wait(0)
    end
end)

-- Background Scanner: Keeps track of nearby NPC (non-player) peds health & armor states 
-- so that we can accurately calculate damage differentials on hit.
CreateThread(function()
    while true do
        Wait(500)
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local now = GetGameTimer()

        -- Scan peds in proximity (filtering out players)
        local handle, ped = FindFirstPed()
        local success
        repeat
            if ped and ped ~= playerPed and not IsPedAPlayer(ped) and #(coords - GetEntityCoords(ped)) < 100.0 then
                if not victimCache[ped] then
                    victimCache[ped] = {
                        health = GetEntityHealth(ped),
                        armor = GetPedArmour(ped),
                        time = now
                    }
                end
            end
            success, ped = FindNextPed(handle)
        until not success
        EndFindPed(handle)
    end
end)

-- Cleanup cache entries that haven't been damaged/scanned in 10 seconds
CreateThread(function()
    while true do
        Wait(5000)
        local now = GetGameTimer()
        for id, data in pairs(victimCache) do
            if now - data.time > 10000 then
                victimCache[id] = nil
            end
        end
    end
end)

-- Damage event listener
AddEventHandler('gameEventTriggered', function(eventName, data)
    if eventName == 'CEventNetworkEntityDamage' then
        local victim = data[1]
        local attacker = data[2]
        local isDead = data[6] == 1

        local playerPed = PlayerPedId()

        -- Debug print to check entity type in F8 console
        if ConfigIndicator and ConfigIndicator.Debug and attacker == playerPed then
            print(("[cfx-keydi-indicator] Attacked entity: %s | IsPed: %s | IsVehicle: %s"):format(victim, tostring(IsEntityAPed(victim)), tostring(IsEntityAVehicle(victim))))
        end

        -- CASE A: Local player is the victim, and attacker is another player
        if victim == playerPed and attacker ~= playerPed then
            if IsPedAPlayer(attacker) then
                local attackerPlayer = NetworkGetPlayerIndexFromPed(attacker)
                if NetworkIsPlayerActive(attackerPlayer) then
                    local attackerServerId = GetPlayerServerId(attackerPlayer)
                    
                    local currentHealth = GetEntityHealth(playerPed)
                    local currentArmor = GetPedArmour(playerPed)
                    local fatallyInjured = isDead == true
                        or IsPedFatallyInjured(playerPed)
                        or IsEntityDead(playerPed)
                        or currentHealth <= 100

                    local hit = {
                        health = 0,
                        armor = 0
                    }

                    if pInfo.armor > currentArmor then
                        hit.armor = pInfo.armor - currentArmor
                    end

                    if pInfo.health > currentHealth then
                        hit.health = pInfo.health - currentHealth
                        if hit.health > pInfo.health then
                            hit.health = pInfo.health
                        end
                    elseif fatallyInjured and (pInfo.lastAliveHealth or 0) > currentHealth then
                        hit.health = math.max(hit.health, (pInfo.lastAliveHealth or 0) - currentHealth)
                    end

                    -- Update pInfo immediately to prevent consecutive hits desync
                    pInfo.health = currentHealth
                    pInfo.armor = currentArmor

                    -- Trigger server event to relay the hit info to the attacker
                    if hit.health > 0 or hit.armor > 0 or fatallyInjured then
                        local foundLastDamagedBone, lastDamagedBone = GetPedLastDamageBone(playerPed)
                        local bonehash = foundLastDamagedBone and tonumber(lastDamagedBone) or -1
                        TriggerServerEvent('cfx-keydi-indicator:server:registerHit', attackerServerId, hit, fatallyInjured, bonehash)
                    end
                end
            end
        end

        -- CASE B: Local player is the attacker, and victim is an NPC (non-player ped)
        if attacker == playerPed and victim ~= playerPed then
            if IsEntityAPed(victim) and not IsPedAPlayer(victim) then
                local currentHealth = GetEntityHealth(victim)
                local currentArmor = GetPedArmour(victim)
                
                local cached = victimCache[victim]
                local healthDiff = 0
                local armorDiff = 0

                if cached then
                    healthDiff = cached.health - currentHealth
                    armorDiff = cached.armor - currentArmor
                else
                    -- Fallback baseline if not cached
                    local maxHealth = GetEntityMaxHealth(victim)
                    healthDiff = maxHealth - currentHealth
                end

                -- Update cache with current values
                victimCache[victim] = {
                    health = currentHealth,
                    armor = currentArmor,
                    time = GetGameTimer()
                }

                -- Project entity head/body coordinates to screen coordinates
                local targetCoords = GetPedBoneCoords(victim, 31086, 0.0, 0.0, 0.0) -- Head bone
                if targetCoords.x == 0.0 then
                    targetCoords = GetEntityCoords(victim)
                end

                local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(targetCoords.x, targetCoords.y, targetCoords.z + 0.3)
                
                if onScreen then
                    -- Trigger damage indicators
                    if isDead then
                        SendNUIMessage({
                            action = "indicator:triggerDamage",
                            data = {
                                id = GetGameTimer() .. math.random(100, 999),
                                type = "dead",
                                amount = currentSettings.deadText or "Dead",
                                x = screenX,
                                y = screenY
                            }
                        })
                    else
                        if armorDiff > 0 then
                            SendNUIMessage({
                                action = "indicator:triggerDamage",
                                data = {
                                    id = GetGameTimer() .. math.random(100, 999),
                                    type = "armor",
                                    amount = armorDiff,
                                    x = screenX,
                                    y = screenY
                                }
                            })
                        end

                        if healthDiff > 0 then
                            SendNUIMessage({
                                action = "indicator:triggerDamage",
                                data = {
                                    id = GetGameTimer() .. math.random(100, 999),
                                    type = "health",
                                    amount = healthDiff,
                                    x = screenX,
                                    y = screenY
                                }
                            })
                        end
                    end
                end
            end
        end
    end
end)

-- Receive synced damage indicators from server (for player victims)
-- Receive synced damage indicators from server (for player victims)
local HEAD_BONES = {
    [31085] = true,
    [31086] = true, -- SKEL_Head (ID)
    [12844] = true, -- IK_Head
    [65068] = true, -- FACIAL_facialRoot
    [24532] = true, -- MH_Hair_Scale
    [37193] = true,
    [19336] = true,
    [58331] = true,
    [45750] = true,
    [25260] = true,
    [21550] = true,
    [29868] = true,
    [43536] = true,
    [27474] = true,
    [47419] = true,
    [20178] = true,
    [17188] = true,
    [20623] = true,
    [49979] = true,
    [20279] = true,
    [17719] = true,
    [61839] = true,
    [1356] = true,
    [11174] = true,
    [46240] = true,
    [47495] = true,
    [64654] = true,
    [39317] = true, -- SKEL_Neck_1 ID
    [35731] = true,
    -- Bone INDEX from GetPedBoneIndex — GetPedLastDamageBone often returns these
    -- https://docs.fivem.net/natives/?_0x3F428D08BE5AAE31
    [97] = true,  -- neck
    [98] = true,  -- SKEL_Head
    [99] = true,  -- IK_Head
    [102] = true,
    [103] = true,
    [104] = true,
    [105] = true,
    [106] = true,
    [107] = true,
    [108] = true,
    [109] = true,
    [110] = true,
    [111] = true,
    [112] = true,
    [113] = true,
    [114] = true,
    [115] = true,
    [116] = true,
    [117] = true,
    [118] = true,
    [119] = true,
    [120] = true,
    [121] = true,
    [122] = true,
    [123] = true,
    [124] = true, -- neck alt
    [125] = true,
}

-- GetPedBoneCoords takes a bone ID, not a bone index
local BONE_INDEX_TO_ID = {
    [97] = 39317,
    [98] = 31086,
    [99] = 12844,
    [102] = 65068,
    [103] = 58331,
    [104] = 45750,
    [105] = 25260,
    [106] = 21550,
    [107] = 29868,
    [108] = 43536,
    [109] = 27474,
    [110] = 19336,
    [111] = 1356,
    [112] = 11174,
    [113] = 37193,
    [114] = 20178,
    [115] = 61839,
    [116] = 20279,
    [117] = 17719,
    [118] = 46240,
    [119] = 17188,
    [120] = 20623,
    [121] = 47419,
    [122] = 49979,
    [123] = 47495,
    [124] = 35731,
    [125] = 64654,
}

local function toBoneId(bonehash)
    bonehash = tonumber(bonehash) or -1
    return BONE_INDEX_TO_ID[bonehash] or bonehash
end

local function resolveIndicatorBone(ped, bonehash)
    bonehash = toBoneId(bonehash)
    -- Prefer reported bone; head-family bones always use SKEL_Head for stable screen projection
    if bonehash > 0 and HEAD_BONES[bonehash] then
        return 31086
    end
    if bonehash > 0 then
        return bonehash
    end
    return 31086
end

local function projectHitToScreen(ped, bonehash)
    local bone = resolveIndicatorBone(ped, bonehash)
    local coords = GetPedBoneCoords(ped, bone, 0.0, 0.0, 0.0)
    if not coords or (coords.x == 0.0 and coords.y == 0.0 and coords.z == 0.0) then
        coords = GetEntityCoords(ped)
        -- Nudge up toward upper body so unknown bones still show
        coords = vector3(coords.x, coords.y, coords.z + 0.65)
    elseif HEAD_BONES[bone] or bone == 31086 then
        -- Slightly lower so head markers stay on-screen when ADS / close
        coords = vector3(coords.x, coords.y, coords.z - 0.05)
    end

    local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z)
    if not screenX or not screenY then
        screenX, screenY = 0.5, 0.4
    end
    -- Clamp so off-screen headshots still indicate
    screenX = math.max(0.04, math.min(0.96, screenX))
    screenY = math.max(0.04, math.min(0.96, screenY))
    return true, screenX, screenY
end

RegisterNetEvent('cfx-keydi-indicator:client:onHit', function(victimServerId, hit, victimDied, bonehash)
    local victimPlayer = GetPlayerFromServerId(victimServerId)
    if NetworkIsPlayerActive(victimPlayer) then
        local victimPed = GetPlayerPed(victimPlayer)
        if victimPed and victimPed ~= 0 then
            local onScreen, screenX, screenY = projectHitToScreen(victimPed, bonehash)
            
            if onScreen then
                if victimDied then
                    SendNUIMessage({
                        action = "indicator:triggerDamage",
                        data = {
                            id = GetGameTimer() .. math.random(100, 999),
                            type = "dead",
                            amount = currentSettings.deadText or "Dead",
                            x = screenX,
                            y = screenY
                        }
                    })
                else
                    if hit.armor and hit.armor > 0 then
                        SendNUIMessage({
                            action = "indicator:triggerDamage",
                            data = {
                                id = GetGameTimer() .. math.random(100, 999),
                                type = "armor",
                                amount = hit.armor,
                                x = screenX,
                                y = screenY
                            }
                        })
                    end

                    if hit.health and hit.health > 0 then
                        SendNUIMessage({
                            action = "indicator:triggerDamage",
                            data = {
                                id = GetGameTimer() .. math.random(100, 999),
                                type = "health",
                                amount = hit.health,
                                x = screenX,
                                y = screenY
                            }
                        })
                    end
                end
            end
        end
    end
end)
