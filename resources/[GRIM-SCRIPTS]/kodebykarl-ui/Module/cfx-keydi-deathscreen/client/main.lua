local ESX = exports["es_extended"]:getSharedObject()

local isOpen = false
local previewCam = nil
local previewPed = nil
local engagement = nil
local lastKillerServerId = nil
local vitals = { health = 200, armor = 0, lastAliveHealth = 200, lastAliveArmor = 0 }

-- Per-ped lag buffer so dealt damage matches real HP/armor loss (same technique as indicator)
local targetVitals = {} -- [ped] = { health, armor, lastAliveHealth, lastAliveArmor, serverId, time }


local WEAPON_LABELS = {
    [`WEAPON_UNARMED`] = "Fists",
    [`WEAPON_KNIFE`] = "Knife",
    [`WEAPON_NIGHTSTICK`] = "Nightstick",
    [`WEAPON_HAMMER`] = "Hammer",
    [`WEAPON_BAT`] = "Bat",
    [`WEAPON_CROWBAR`] = "Crowbar",
    [`WEAPON_GOLFCLUB`] = "Golf Club",
    [`WEAPON_BOTTLE`] = "Bottle",
    [`WEAPON_DAGGER`] = "Dagger",
    [`WEAPON_HATCHET`] = "Hatchet",
    [`WEAPON_MACHETE`] = "Machete",
    [`WEAPON_SWITCHBLADE`] = "Switchblade",
    [`WEAPON_BATTLEAXE`] = "Battle Axe",
    [`WEAPON_POOLCUE`] = "Pool Cue",
    [`WEAPON_WRENCH`] = "Wrench",
    [`WEAPON_PISTOL`] = "Pistol",
    [`WEAPON_PISTOL_MK2`] = "Pistol Mk II",
    [`WEAPON_COMBATPISTOL`] = "Combat Pistol",
    [`WEAPON_APPISTOL`] = "AP Pistol",
    [`WEAPON_STUNGUN`] = "Stun Gun",
    [`WEAPON_PISTOL50`] = "Pistol .50",
    [`WEAPON_SNSPISTOL`] = "SNS Pistol",
    [`WEAPON_SNSPISTOL_MK2`] = "SNS Pistol Mk II",
    [`WEAPON_HEAVYPISTOL`] = "Heavy Pistol",
    [`WEAPON_VINTAGEPISTOL`] = "Vintage Pistol",
    [`WEAPON_FLAREGUN`] = "Flare Gun",
    [`WEAPON_MARKSMANPISTOL`] = "Marksman Pistol",
    [`WEAPON_REVOLVER`] = "Revolver",
    [`WEAPON_REVOLVER_MK2`] = "Revolver Mk II",
    [`WEAPON_DOUBLEACTION`] = "Double Action",
    [`WEAPON_RAYPISTOL`] = "Up-n-Atomizer",
    [`WEAPON_CERAMICPISTOL`] = "Ceramic Pistol",
    [`WEAPON_NAVYREVOLVER`] = "Navy Revolver",
    [`WEAPON_GADGETPISTOL`] = "Perico Pistol",
    [`WEAPON_MICROSMG`] = "Micro SMG",
    [`WEAPON_SMG`] = "SMG",
    [`WEAPON_SMG_MK2`] = "SMG Mk II",
    [`WEAPON_ASSAULTSMG`] = "Assault SMG",
    [`WEAPON_COMBATPDW`] = "Combat PDW",
    [`WEAPON_MACHINEPISTOL`] = "Machine Pistol",
    [`WEAPON_MINISMG`] = "Mini SMG",
    [`WEAPON_RAYCARBINE`] = "Unholy Hellbringer",
    [`WEAPON_PUMPSHOTGUN`] = "Pump Shotgun",
    [`WEAPON_PUMPSHOTGUN_MK2`] = "Pump Shotgun Mk II",
    [`WEAPON_SAWNOFFSHOTGUN`] = "Sawed-Off Shotgun",
    [`WEAPON_ASSAULTSHOTGUN`] = "Assault Shotgun",
    [`WEAPON_BULLPUPSHOTGUN`] = "Bullpup Shotgun",
    [`WEAPON_MUSKET`] = "Musket",
    [`WEAPON_HEAVYSHOTGUN`] = "Heavy Shotgun",
    [`WEAPON_DBSHOTGUN`] = "Double Barrel Shotgun",
    [`WEAPON_AUTOSHOTGUN`] = "Auto Shotgun",
    [`WEAPON_COMBATSHOTGUN`] = "Combat Shotgun",
    [`WEAPON_ASSAULTRIFLE`] = "Assault Rifle",
    [`WEAPON_ASSAULTRIFLE_MK2`] = "Assault Rifle Mk II",
    [`WEAPON_CARBINERIFLE`] = "Carbine Rifle",
    [`WEAPON_CARBINERIFLE_MK2`] = "Carbine Rifle Mk II",
    [`WEAPON_ADVANCEDRIFLE`] = "Advanced Rifle",
    [`WEAPON_SPECIALCARBINE`] = "Special Carbine",
    [`WEAPON_SPECIALCARBINE_MK2`] = "Special Carbine Mk II",
    [`WEAPON_BULLPUPRIFLE`] = "Bullpup Rifle",
    [`WEAPON_BULLPUPRIFLE_MK2`] = "Bullpup Rifle Mk II",
    [`WEAPON_COMPACTRIFLE`] = "Compact Rifle",
    [`WEAPON_MILITARYRIFLE`] = "Military Rifle",
    [`WEAPON_HEAVYRIFLE`] = "Heavy Rifle",
    [`WEAPON_TACTICALRIFLE`] = "Tactical Rifle",
    [`WEAPON_MG`] = "MG",
    [`WEAPON_COMBATMG`] = "Combat MG",
    [`WEAPON_COMBATMG_MK2`] = "Combat MG Mk II",
    [`WEAPON_GUSENBERG`] = "Gusenberg",
    [`WEAPON_SNIPERRIFLE`] = "Sniper Rifle",
    [`WEAPON_HEAVYSNIPER`] = "Heavy Sniper",
    [`WEAPON_HEAVYSNIPER_MK2`] = "Heavy Sniper Mk II",
    [`WEAPON_MARKSMANRIFLE`] = "Marksman Rifle",
    [`WEAPON_MARKSMANRIFLE_MK2`] = "Marksman Rifle Mk II",
    [`WEAPON_PRECISIONRIFLE`] = "Precision Rifle",
    [`WEAPON_RPG`] = "RPG",
    [`WEAPON_GRENADELAUNCHER`] = "Grenade Launcher",
    [`WEAPON_MINIGUN`] = "Minigun",
    [`WEAPON_FIREWORK`] = "Firework",
    [`WEAPON_RAILGUN`] = "Railgun",
    [`WEAPON_HOMINGLAUNCHER`] = "Homing Launcher",
    [`WEAPON_COMPACTLAUNCHER`] = "Compact Launcher",
    [`WEAPON_RAYMINIGUN`] = "Widowmaker",
    [`WEAPON_GRENADE`] = "Grenade",
    [`WEAPON_STICKYBOMB`] = "Sticky Bomb",
    [`WEAPON_PROXMINE`] = "Proximity Mine",
    [`WEAPON_PIPEBOMB`] = "Pipe Bomb",
    [`WEAPON_SMOKEGRENADE`] = "Smoke Grenade",
    [`WEAPON_MOLOTOV`] = "Molotov",
    [`WEAPON_FIREEXTINGUISHER`] = "Fire Extinguisher",
    [`WEAPON_PETROLCAN`] = "Jerry Can",
    [`WEAPON_FLARE`] = "Flare",
    [`WEAPON_BALL`] = "Ball",
    [`WEAPON_SNOWBALL`] = "Snowball",
    [`WEAPON_FALL`] = "Fall",
    [`WEAPON_DROWNING`] = "Drowning",
    [`WEAPON_DROWNING_IN_VEHICLE`] = "Drowning",
    [`WEAPON_BLEEDING`] = "Bleeding",
    [`WEAPON_ELECTRIC_FENCE`] = "Electric Fence",
    [`WEAPON_EXPLOSION`] = "Explosion",
    [`WEAPON_RAMMED_BY_CAR`] = "Vehicle",
    [`WEAPON_RUN_OVER_BY_CAR`] = "Vehicle",
    [`WEAPON_FIRE`] = "Fire",
    [`WEAPON_ANIMAL`] = "Animal",
}

local function DebugLog(msg)
    if ConfigDeathScreen.Debug then
        print(("[cfx-keydi-deathscreen] %s"):format(msg))
    end
end

local function WeaponLabel(hash)
    hash = tonumber(hash) or 0
    if hash == 0 then return "Unknown" end
    if WEAPON_LABELS[hash] then return WEAPON_LABELS[hash] end

    -- Prefer GTA display name (covers custom / addon guns)
    local ok, labelKey = pcall(function()
        return GetWeaponNameFromHash and GetWeaponNameFromHash(hash) or nil
    end)
    if ok and labelKey and labelKey ~= "" and labelKey ~= "NULL" and labelKey ~= "CARBINERIFLE" then
        local text = GetLabelText(labelKey)
        if text and text ~= "NULL" and text ~= "" then
            return text
        end
        return labelKey
    end

    local ok2, display = pcall(function()
        if GetDisplayNameFromWeaponHash then
            return GetDisplayNameFromWeaponHash(hash)
        end
        return nil
    end)
    if ok2 and display and display ~= "" and display ~= "NULL" then
        local text = GetLabelText(display)
        if text and text ~= "NULL" and text ~= "" then
            return text
        end
        return display
    end

    return ("Weapon 0x%X"):format(hash & 0xFFFFFFFF)
end

local function ResolveWeaponHash(eventWeapon, pedFallback)
    local hash = tonumber(eventWeapon) or 0
    if hash ~= 0 and hash ~= `WEAPON_UNARMED` then
        return hash
    end
    if pedFallback and pedFallback ~= 0 then
        local cause = GetPedCauseOfDeath(pedFallback)
        if cause and cause ~= 0 then return cause end
        local selected = GetSelectedPedWeapon(pedFallback)
        if selected and selected ~= 0 then return selected end
    end
    return hash ~= 0 and hash or `WEAPON_UNARMED`
end

local function ComputeDamageDelta(prevHealth, prevArmor, curHealth, curArmor, lastAliveHealth, lastAliveArmor, fatal)
    local healthDmg = 0
    local armorDmg = 0

    if prevArmor and curArmor and prevArmor > curArmor then
        armorDmg = prevArmor - curArmor
    end
    if prevHealth and curHealth and prevHealth > curHealth then
        healthDmg = prevHealth - curHealth
    end

    -- One-shot / fatal: event often arrives after HP already collapsed
    if fatal or (curHealth and curHealth <= 100) then
        local baseH = lastAliveHealth or prevHealth or 200
        if baseH > curHealth then
            healthDmg = math.max(healthDmg, baseH - curHealth)
        end
        local baseA = lastAliveArmor or prevArmor or 0
        if baseA > (curArmor or 0) then
            armorDmg = math.max(armorDmg, baseA - (curArmor or 0))
        end
    end

    return math.max(0, healthDmg), math.max(0, armorDmg), math.max(0, healthDmg + armorDmg)
end

local function NewEngagement()
    return {
        startedAt = GetGameTimer(),
        hits = DeathScreenBones.EmptyHits(),
        damageReceived = 0,
        damageDealt = 0,
        damageByAttacker = {}, -- [serverId] = damage received from them
        dealtToTarget = {}, -- [serverId] = accurate damage we dealt them
        weaponsByAttacker = {}, -- [serverId] = weaponHash that hurt us most recently
        weaponsDealtTo = {}, -- [serverId] = weapon we used on them
        lastAttacker = nil,
        lastWeapon = 0,
        fatalWeapon = 0,
        distance = 0,
    }
end

local function EnsureEngagement()
    local now = GetGameTimer()
    if not engagement or (now - (engagement.startedAt or 0)) > (ConfigDeathScreen.EngagementTimeout or 45000) then
        engagement = NewEngagement()
    end
    return engagement
end

local function AddDealtDamage(serverId, total, weaponHash)
    if total <= 0 then return end
    local eng = EnsureEngagement()
    eng.damageDealt = (eng.damageDealt or 0) + total
    if serverId and serverId > 0 then
        eng.dealtToTarget = eng.dealtToTarget or {}
        eng.dealtToTarget[serverId] = (eng.dealtToTarget[serverId] or 0) + total
        if weaponHash and weaponHash ~= 0 then
            eng.weaponsDealtTo = eng.weaponsDealtTo or {}
            eng.weaponsDealtTo[serverId] = weaponHash
        end
    end
    DebugLog(("dealt +%s to %s weapon=%s totalDealt=%s"):format(
        tostring(total), tostring(serverId), tostring(weaponHash), tostring(eng.damageDealt)
    ))
end

local function TrackTargetPed(ped, serverId)
    if not ped or ped == 0 or not DoesEntityExist(ped) then return end
    local h = GetEntityHealth(ped)
    local a = GetPedArmour(ped)
    local row = targetVitals[ped]
    if not row then
        targetVitals[ped] = {
            health = h,
            armor = a,
            prevHealth = h,
            prevArmor = a,
            lastAliveHealth = h > 100 and h or 200,
            lastAliveArmor = a,
            serverId = serverId,
            time = GetGameTimer(),
        }
        return
    end
    -- Lag buffer: prev* = last frame, health/armor = current frame before overwrite
    row.prevHealth = row.health
    row.prevArmor = row.armor
    row.health = h
    row.armor = a
    if h > 100 then
        row.lastAliveHealth = h
    end
    row.lastAliveArmor = a
    if serverId then row.serverId = serverId end
    row.time = GetGameTimer()
end

local function HealthPct(ped)
    local h = GetEntityHealth(ped)
    local maxH = GetEntityMaxHealth(ped)
    if maxH > 100 then
        return math.max(0, math.min(100, math.floor(((h - 100) / (maxH - 100)) * 100)))
    end
    return math.max(0, math.min(100, math.floor((h / math.max(1, maxH)) * 100)))
end

local function CleanupPreview()
    if previewCam then
        RenderScriptCams(false, true, 400, true, true)
        DestroyCam(previewCam, false)
        previewCam = nil
    end
    if previewPed and DoesEntityExist(previewPed) then
        DeleteEntity(previewPed)
        previewPed = nil
    end
end

local function StartKillerPreview(killerServerId, isSuicide)
    CleanupPreview()
    if not (ConfigDeathScreen.Preview and ConfigDeathScreen.Preview.enabled) then
        return
    end

    local myPed = PlayerPedId()
    local coords = GetEntityCoords(myPed)
    local heading = GetEntityHeading(myPed)

    local sourcePed = myPed
    if not isSuicide and killerServerId and killerServerId > 0 then
        local player = GetPlayerFromServerId(killerServerId)
        if player ~= -1 then
            local kp = GetPlayerPed(player)
            if kp and kp ~= 0 and DoesEntityExist(kp) then
                sourcePed = kp
            end
        end
    end

    previewPed = ClonePed(sourcePed, false, false, true)
    if not previewPed or previewPed == 0 then
        DebugLog("clone failed")
        return
    end

    SetEntityCollision(previewPed, false, false)
    FreezeEntityPosition(previewPed, true)
    SetEntityInvincible(previewPed, true)
    SetBlockingOfNonTemporaryEvents(previewPed, true)
    ClearPedTasksImmediately(previewPed)
    SetPedCanRagdoll(previewPed, false)
    SetEntityVisible(previewPed, true, false)
    SetPedFleeAttributes(previewPed, 0, false)

    local rad = math.rad(heading)
    local stand = vector3(
        coords.x - math.sin(rad) * 0.15,
        coords.y + math.cos(rad) * 0.15,
        coords.z + (ConfigDeathScreen.Preview.cloneOffsetZ or 0.0)
    )
    SetEntityCoordsNoOffset(previewPed, stand.x, stand.y, stand.z, false, false, false)
    SetEntityHeading(previewPed, heading)
    TaskStandStill(previewPed, -1)

    local dist = ConfigDeathScreen.Preview.camDistance or 2.35
    local camH = ConfigDeathScreen.Preview.camHeight or 0.42
    local camCoords = vector3(
        stand.x - math.sin(rad) * dist,
        stand.y + math.cos(rad) * dist,
        stand.z + camH
    )

    previewCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(previewCam, camCoords.x, camCoords.y, camCoords.z)
    PointCamAtEntity(previewCam, previewPed, 0.0, 0.0, 0.35, true)
    SetCamFov(previewCam, ConfigDeathScreen.Preview.fov or 38.0)
    SetCamActive(previewCam, true)
    RenderScriptCams(true, true, 500, true, true)

    -- Soften local corpse so center focuses on killer clone
    SetEntityAlpha(myPed, 80, false)
end

local function CloseDeathScreen()
    if not isOpen then return end
    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "deathscreen:hide" })
    CleanupPreview()
    local ped = PlayerPedId()
    ResetEntityAlpha(ped)
end

local function OpenDeathScreen(payload)
    if isOpen then
        CloseDeathScreen()
        Wait(50)
    end
    isOpen = true
    SetNuiFocus(ConfigDeathScreen.FocusMouse ~= false, ConfigDeathScreen.FocusMouse ~= false)
    SendNUIMessage({
        action = "deathscreen:show",
        data = payload,
    })
end

local function BuildLocalCombat(isSuicide, killerServerId, weaponHash, distance)
    local eng = engagement or NewEngagement()
    local hits = eng.hits or DeathScreenBones.EmptyHits()

    -- Prefer damage dealt specifically to the killer (accurate exchange)
    local dealt = tonumber(eng.damageDealt) or 0
    if killerServerId and eng.dealtToTarget and eng.dealtToTarget[killerServerId] then
        dealt = eng.dealtToTarget[killerServerId]
    end

    local received = tonumber(eng.damageReceived) or 0
    if killerServerId and eng.damageByAttacker and eng.damageByAttacker[killerServerId] then
        -- Use attacker-specific total when available (more accurate than whole engagement)
        received = eng.damageByAttacker[killerServerId]
    end
    if received <= 0 and not isSuicide then
        -- Minimum fatal package if event missed mid-frame
        received = math.max(1, (vitals.lastAliveHealth or 200) - 100 + (vitals.lastAliveArmor or 0))
    end

    local fatalHash = ResolveWeaponHash(
        weaponHash or eng.fatalWeapon or eng.lastWeapon,
        PlayerPedId()
    )
    if eng.fatalWeapon and eng.fatalWeapon ~= 0 then
        fatalHash = eng.fatalWeapon
    end

    local total = dealt + received
    local outPct = total > 0 and math.floor((dealt / total) * 100 + 0.5) or 0
    local inPct = math.max(0, 100 - outPct)

    return {
        fatalWeapon = WeaponLabel(fatalHash),
        killStreak = 0,
        distance = math.floor((tonumber(distance) or 0) + 0.5),
        damageDealt = math.floor(dealt + 0.5),
        damageReceived = math.floor(received + 0.5),
        damageOutPct = outPct,
        damageInPct = inPct,
        bodyHits = {
            head = hits.head or 0,
            neck = hits.neck or 0,
            torso = hits.torso or 0,
            arms = hits.arms or 0,
            legs = hits.legs or 0,
        },
        totalHits = DeathScreenBones.TotalHits(hits),
        isSuicide = isSuicide == true,
    }
end

local function RequestAndShow(killerServerId, isSuicide, weaponHash, distance)
    lastKillerServerId = killerServerId
    local combat = BuildLocalCombat(isSuicide, killerServerId, weaponHash, distance)

    lib.callback("cfx-keydi-deathscreen:getRecap", false, function(result)
        result = result or {}
        local killer = result.killer or {
            name = isSuicide and GetPlayerName(PlayerId()) or "Unknown",
            id = isSuicide and GetPlayerServerId(PlayerId()) or (killerServerId or 0),
            ping = 0,
            playTime = "—",
            rank = isSuicide and "Suicide" or "—",
            kills = 0,
            kd = "0.00",
            health = 100,
            armor = 0,
            badges = {},
        }
        if isSuicide then
            killer.rank = "Suicide"
        end
        if result.killStreak then
            combat.killStreak = result.killStreak
        end

        StartKillerPreview(killerServerId, isSuicide)

        OpenDeathScreen({
            killer = killer,
            combat = combat,
            recentEliminations = result.recentEliminations or {},
            brand = "GRIM CITY",
            subtitle = "DEATH RECAP",
        })
    end, {
        killerServerId = killerServerId,
        isSuicide = isSuicide,
        weaponHash = weaponHash,
        distance = distance,
        combat = combat,
    })
end

-- Own vitals lag buffer + nearby player target vitals (for accurate Damage Dealt)
CreateThread(function()
    local prevH, prevA
    while true do
        local ped = PlayerPedId()
        if ped and ped ~= 0 then
            local h = GetEntityHealth(ped)
            local a = GetPedArmour(ped)
            vitals.health = prevH or h
            vitals.armor = prevA or a
            prevH, prevA = h, a
            if h > 100 then
                vitals.lastAliveHealth = h
            end
            vitals.lastAliveArmor = a
        end

        -- Track active players within combat range for HP/armor deltas
        local myCoords = GetEntityCoords(ped)
        for _, player in ipairs(GetActivePlayers()) do
            local otherPed = GetPlayerPed(player)
            if otherPed and otherPed ~= 0 and otherPed ~= ped then
                if #(myCoords - GetEntityCoords(otherPed)) < 120.0 then
                    TrackTargetPed(otherPed, GetPlayerServerId(player))
                end
            end
        end

        Wait(0)
    end
end)

-- Cleanup stale target vitals
CreateThread(function()
    while true do
        Wait(5000)
        local now = GetGameTimer()
        for ped, row in pairs(targetVitals) do
            if not DoesEntityExist(ped) or (now - (row.time or 0)) > 15000 then
                targetVitals[ped] = nil
            end
        end
    end
end)

-- Victim-authoritative damage (same numbers the hit indicator shows) — most accurate for PvP Dealt
RegisterNetEvent("cfx-keydi-indicator:client:onHit", function(victimServerId, hit, victimDied, _)
    victimServerId = tonumber(victimServerId)
    if not victimServerId or not hit then return end

    local health = tonumber(hit.health) or 0
    local armor = tonumber(hit.armor) or 0
    local total = health + armor
    if total <= 0 and not victimDied then return end

    local eng = EnsureEngagement()
    local weapon = GetSelectedPedWeapon(PlayerPedId())
    if eng._pendingDealt and eng._pendingDealt[victimServerId] then
        local pending = eng._pendingDealt[victimServerId]
        if pending.weapon and pending.weapon ~= 0 then
            weapon = pending.weapon
        end
        -- Consume this hit from the pending fallback pool so timeout won't double-count
        if total > 0 then
            pending.total = math.max(0, (pending.total or 0) - total)
        end
        if (pending.total or 0) <= 0 then
            eng._pendingDealt[victimServerId] = nil
        end
    end

    if total <= 0 and victimDied then
        -- One-shot with empty hit payload — use whatever pending remains
        if eng._pendingDealt and eng._pendingDealt[victimServerId] then
            total = eng._pendingDealt[victimServerId].total or 0
            eng._pendingDealt[victimServerId] = nil
        end
    end

    if total > 0 then
        AddDealtDamage(victimServerId, total, weapon)
    end

    if victimDied then
        TriggerServerEvent("cfx-keydi-deathscreen:registerKill", victimServerId)
    end
end)

AddEventHandler("gameEventTriggered", function(eventName, data)
    if eventName ~= "CEventNetworkEntityDamage" then return end

    local victim = data[1]
    local attacker = data[2]
    -- Weapon hash slot varies by game build — try common indices
    local weaponHash = data[7] or data[5] or data[4] or 0
    local isFatal = data[6] == 1

    local playerPed = PlayerPedId()

    ------------------------------------------------------------------
    -- WE dealt damage → accurate HP/armor delta from target vitals
    ------------------------------------------------------------------
    if victim ~= playerPed and attacker == playerPed and IsEntityAPed(victim) then
        local curH = GetEntityHealth(victim)
        local curA = GetPedArmour(victim)
        local fatalVictim = isFatal or IsEntityDead(victim) or IsPedFatallyInjured(victim) or curH <= 100

        local cached = targetVitals[victim]
        if not cached then
            TrackTargetPed(victim, IsPedAPlayer(victim) and GetPlayerServerId(NetworkGetPlayerIndexFromPed(victim)) or nil)
            cached = targetVitals[victim]
        end

        local prevH = cached and (cached.prevHealth or cached.health) or curH
        local prevA = cached and (cached.prevArmor or cached.armor) or curA
        local lastH = cached and cached.lastAliveHealth or prevH
        local lastA = cached and cached.lastAliveArmor or prevA

        local _, _, total = ComputeDamageDelta(prevH, prevA, curH, curA, lastH, lastA, fatalVictim)

        local sid = nil
        local isPlayerVictim = IsPedAPlayer(victim)
        if isPlayerVictim then
            local idx = NetworkGetPlayerIndexFromPed(victim)
            if idx and NetworkIsPlayerActive(idx) then
                sid = GetPlayerServerId(idx)
            end
        end

        weaponHash = ResolveWeaponHash(weaponHash, playerPed)

        if isPlayerVictim and sid then
            -- PvP: prefer victim-reported indicator numbers (same as hitmarkers).
            -- Accumulate pending fallback if indicator packets are delayed/lost.
            local eng = EnsureEngagement()
            eng._pendingDealt = eng._pendingDealt or {}
            local pending = eng._pendingDealt[sid]
            if not pending then
                pending = { total = 0, weapon = weaponHash, at = GetGameTimer(), fatal = false, gen = 0 }
                eng._pendingDealt[sid] = pending
            end
            pending.total = (pending.total or 0) + math.max(0, total)
            pending.weapon = weaponHash
            pending.at = GetGameTimer()
            pending.fatal = pending.fatal or fatalVictim
            pending.gen = (pending.gen or 0) + 1
            local gen = pending.gen
            if fatalVictim then
                TriggerServerEvent("cfx-keydi-deathscreen:registerKill", sid)
            end
            CreateThread(function()
                local captureSid = sid
                local captureLastH, captureLastA = lastH, lastA
                local captureGen = gen
                Wait(220)
                if not engagement or not engagement._pendingDealt then return end
                local left = engagement._pendingDealt[captureSid]
                -- Only the latest debounce flush commits (avoids multi-timer double count)
                if not left or left.gen ~= captureGen then return end
                local amt = left.total or 0
                if amt <= 0 and left.fatal then
                    amt = math.max(1, (captureLastH - 100) + (captureLastA or 0))
                end
                engagement._pendingDealt[captureSid] = nil
                if amt > 0 then
                    AddDealtDamage(captureSid, amt, left.weapon)
                end
            end)
        else
            -- NPCs / non-players: local HP/armor delta is authoritative
            if total > 0 then
                AddDealtDamage(nil, total, weaponHash)
            elseif fatalVictim then
                AddDealtDamage(nil, math.max(1, (lastH - 100) + (lastA or 0)), weaponHash)
            end
        end

        -- Refresh cache to post-hit values so next shot diffs correctly
        if cached then
            cached.prevHealth = curH
            cached.prevArmor = curA
            cached.health = curH
            cached.armor = curA
            cached.time = GetGameTimer()
        else
            TrackTargetPed(victim, sid)
        end
        return
    end

    if victim ~= playerPed then return end

    ------------------------------------------------------------------
    -- WE took damage → accurate received + bones + fatal weapon
    ------------------------------------------------------------------
    local eng = EnsureEngagement()
    local curH = GetEntityHealth(playerPed)
    local curA = GetPedArmour(playerPed)
    local fatal = isFatal or IsPedFatallyInjured(playerPed) or IsEntityDead(playerPed) or curH <= 100

    local healthDmg, armorDmg, dmg = ComputeDamageDelta(
        vitals.health,
        vitals.armor,
        curH,
        curA,
        vitals.lastAliveHealth,
        vitals.lastAliveArmor,
        fatal
    )
    eng.damageReceived = (eng.damageReceived or 0) + dmg
    vitals.health, vitals.armor = curH, curA

    if dmg > 0 or fatal then
        local found, bone = GetPedLastDamageBone(playerPed)
        if found and bone then
            local zone = DeathScreenBones.ZoneFromBone(bone)
            eng.hits[zone] = (eng.hits[zone] or 0) + 1
            DebugLog(("recv bone=%s zone=%s hp=%s ar=%s"):format(tostring(bone), zone, tostring(healthDmg), tostring(armorDmg)))
        elseif dmg > 0 then
            eng.hits.torso = (eng.hits.torso or 0) + 1
        end
    end

    weaponHash = ResolveWeaponHash(weaponHash, attacker ~= 0 and attacker or playerPed)
    if weaponHash and weaponHash ~= 0 then
        eng.lastWeapon = weaponHash
        if fatal then
            eng.fatalWeapon = weaponHash
        end
    end

    local attackerServerId = nil
    local isSuicide = false
    local distance = 0.0

    if attacker and attacker ~= 0 and attacker == playerPed then
        isSuicide = true
        attackerServerId = GetPlayerServerId(PlayerId())
    elseif attacker and attacker ~= 0 and IsEntityAPed(attacker) and IsPedAPlayer(attacker) then
        local idx = NetworkGetPlayerIndexFromPed(attacker)
        if idx and NetworkIsPlayerActive(idx) then
            attackerServerId = GetPlayerServerId(idx)
            eng.lastAttacker = attackerServerId
            eng.damageByAttacker = eng.damageByAttacker or {}
            eng.damageByAttacker[attackerServerId] = (eng.damageByAttacker[attackerServerId] or 0) + dmg
            eng.weaponsByAttacker = eng.weaponsByAttacker or {}
            eng.weaponsByAttacker[attackerServerId] = weaponHash
            -- Prefer killer's selected weapon if event hash is empty
            if (not weaponHash or weaponHash == 0 or weaponHash == `WEAPON_UNARMED`) then
                local held = GetSelectedPedWeapon(attacker)
                if held and held ~= 0 then
                    eng.weaponsByAttacker[attackerServerId] = held
                    if fatal then eng.fatalWeapon = held end
                end
            end
            distance = #(GetEntityCoords(playerPed) - GetEntityCoords(attacker))
            eng.distance = distance
        end
    elseif eng.lastAttacker then
        attackerServerId = eng.lastAttacker
        distance = eng.distance or 0.0
        if eng.weaponsByAttacker and eng.weaponsByAttacker[attackerServerId] then
            weaponHash = eng.weaponsByAttacker[attackerServerId]
            if fatal then eng.fatalWeapon = weaponHash end
        end
    else
        isSuicide = true
        attackerServerId = GetPlayerServerId(PlayerId())
    end

    if fatal and ConfigDeathScreen.AutoOpenOnDeath and not isOpen then
        CreateThread(function()
            Wait(175)
            if isOpen then return end
            local me = PlayerPedId()
            if not IsEntityDead(me) and GetEntityHealth(me) > 100 then return end

            local cause = GetPedCauseOfDeath(me)
            if cause and cause ~= 0 then
                weaponHash = cause
                if engagement then engagement.fatalWeapon = cause end
            elseif engagement and engagement.fatalWeapon and engagement.fatalWeapon ~= 0 then
                weaponHash = engagement.fatalWeapon
            elseif engagement and engagement.lastWeapon and engagement.lastWeapon ~= 0 then
                weaponHash = engagement.lastWeapon
            end

            RequestAndShow(attackerServerId, isSuicide, weaponHash, distance)
            engagement = nil
        end)
    end
end)

AddEventHandler("esx:onPlayerSpawn", function()
    if ConfigDeathScreen.CloseOnRespawn then
        CloseDeathScreen()
    end
end)

AddEventHandler("playerSpawned", function()
    if ConfigDeathScreen.CloseOnRespawn then
        CloseDeathScreen()
    end
end)

RegisterNetEvent("hospital:client:Revive", function()
    CloseDeathScreen()
end)

RegisterNetEvent("esx_ambulancejob:revive", function()
    CloseDeathScreen()
end)

RegisterNUICallback("cfx-keydi-deathscreen:close", function(_, cb)
    CloseDeathScreen()
    cb({ ok = true })
end)

RegisterCommand(ConfigDeathScreen.Command or "deathscreen", function()
    engagement = NewEngagement()
    engagement.hits.head = 1
    engagement.hits.torso = 2
    engagement.damageReceived = 120
    engagement.damageDealt = 35
    RequestAndShow(GetPlayerServerId(PlayerId()), true, `WEAPON_PISTOL`, 0.0)
end, false)

exports("OpenDeathScreen", function(data)
    if data then
        OpenDeathScreen(data)
    else
        ExecuteCommand(ConfigDeathScreen.Command or "deathscreen")
    end
end)

exports("CloseDeathScreen", CloseDeathScreen)
