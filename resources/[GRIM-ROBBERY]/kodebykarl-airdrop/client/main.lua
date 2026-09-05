local planeEnt, crateEnt, chuteEnt
local smokeFx
local smokeTried = false
local blips = {}
local targetOn = false
local currentSeq = 0
local nearText = nil
local claiming = false
local crateLanded = false
local syncedUnix = 0
local syncedAtMs = 0
local oxTarget

local function formatClock(seconds)
    seconds = math.max(0, math.floor(tonumber(seconds) or 0))
    return ('%02d:%02d'):format(math.floor(seconds / 60), seconds % 60)
end

-- FiveM client has no `os` library. Sync unix time from the server payload.
local function now()
    if syncedUnix > 0 then
        return syncedUnix + math.floor((GetGameTimer() - syncedAtMs) / 1000)
    end
    local cloud = GetCloudTimeAsInt()
    if type(cloud) == 'number' and cloud > 1000000000 then
        return cloud
    end
    return 0
end

local function state()
    return GlobalState.airdrop_event
end

local function vecFrom(coords)
    if not coords then return nil end
    if coords.x then return vec3(coords.x + 0.0, coords.y + 0.0, coords.z + 0.0) end
    return vec3(coords[1] or 0.0, coords[2] or 0.0, coords[3] or 0.0)
end

local function lootAllowed()
    local fn = Config.RequireFunction
    if not fn or fn == false or fn == '' then return true end
    if not Config.GateLootOnly then
        if GetResourceState('kodebykarl-ui') ~= 'started' then return false end
        local ok, allowed = pcall(function()
            return exports['kodebykarl-ui']:HasFunction(fn)
        end)
        return ok and allowed == true
    end
    return true
end

local function lootAllowedClaim()
    local fn = Config.RequireFunction
    if not fn or fn == false or fn == '' then return true end
    if GetResourceState('kodebykarl-ui') ~= 'started' then return false end
    local ok, allowed = pcall(function()
        return exports['kodebykarl-ui']:HasFunction(fn)
    end)
    return ok and allowed == true
end

local function deleteEnt(ent)
    if ent and DoesEntityExist(ent) then
        SetEntityAsMissionEntity(ent, true, true)
        DeleteEntity(ent)
    end
end

local function clearBlips()
    for _, blip in pairs(blips) do
        if blip and DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    blips = {}
end

local function clearSmoke()
    if smokeFx then
        StopParticleFxLooped(smokeFx, false)
        smokeFx = nil
    end
    smokeTried = false
end

local function removeTarget()
    if targetOn and oxTarget and crateEnt and DoesEntityExist(crateEnt) then
        pcall(function()
            oxTarget:removeLocalEntity(crateEnt)
        end)
    end
    targetOn = false
end

local function cleanupVisuals()
    removeTarget()
    clearSmoke()
    clearBlips()
    deleteEnt(chuteEnt)
    deleteEnt(crateEnt)
    deleteEnt(planeEnt)
    chuteEnt, crateEnt, planeEnt = nil, nil, nil
    crateLanded = false
    if nearText then
        lib.hideTextUI()
        nearText = nil
    end
end

local function removeBlipKey(key)
    local blip = blips[key]
    if blip and DoesBlipExist(blip) then
        SetBlipRoute(blip, false)
        RemoveBlip(blip)
    end
    blips[key] = nil
end

local function styleBlip(blip, cfg, name)
    if not blip or not DoesBlipExist(blip) or not cfg then return end
    SetBlipSprite(blip, cfg.Sprite or 1)
    SetBlipColour(blip, cfg.Color or 1)
    SetBlipScale(blip, cfg.Scale or 1.0)
    SetBlipAsShortRange(blip, cfg.ShortRange == true)
    SetBlipDisplay(blip, cfg.Display or 4)
    SetBlipPriority(blip, cfg.Priority or 10)
    SetBlipFlashes(blip, cfg.Flash == true)
    if cfg.HighDetail then
        SetBlipHighDetail(blip, true)
    end
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(name or cfg.Label or 'Airdrop')
    EndTextCommandSetBlipName(blip)
    SetBlipRoute(blip, false)
end

local function ensureCoordBlip(key, coords, cfg, name)
    if not cfg or cfg.Enable == false or not coords then return end
    local blip = blips[key]
    if blip and DoesBlipExist(blip) then
        SetBlipCoords(blip, coords.x, coords.y, coords.z)
        return blip
    end
    blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    styleBlip(blip, cfg, name)
    blips[key] = blip
    return blip
end

local function ensureRadiusBlip(coords)
    local cfg = Config.Blips.Radius
    if not cfg or cfg.Enable == false or not coords then return end
    if blips.radius and DoesBlipExist(blips.radius) then return end
    local blip = AddBlipForRadius(coords.x, coords.y, coords.z, cfg.Scale or 120.0)
    SetBlipColour(blip, cfg.Color or 1)
    SetBlipAlpha(blip, cfg.Alpha or 140)
    blips.radius = blip
end

local function approachDir(heading)
    local rad = math.rad(heading or 0.0)
    return vec3(-math.sin(rad), math.cos(rad), 0.0)
end

local function lerpPlaneCoords(st)
    local coords = vecFrom(st and st.coords)
    if not coords then return nil end
    local dir = approachDir(st.heading)
    local alt = Config.Plane.Altitude or 180.0
    local approach = Config.Plane.ApproachDistance or 900.0
    local despawn = Config.Plane.DespawnDistance or 700.0
    local startPos = coords - (dir * approach) + vec3(0.0, 0.0, alt)
    local dropPos = coords + vec3(0.0, 0.0, alt)
    local endPos = coords + (dir * despawn) + vec3(0.0, 0.0, alt)

    local incomingAt = st.incomingAt or st.startedAt or now()
    local landAt = st.landAt or (incomingAt + (Config.FlightSeconds or 28))
    local flight = math.max(1, landAt - incomingAt)
    local t = (now() - incomingAt) / flight

    if t <= 1.0 then
        t = math.max(0.0, math.min(1.0, t))
        return startPos + (dropPos - startPos) * t
    end
    local p = math.min(1.0, (t - 1.0) / 0.35)
    return dropPos + (endPos - dropPos) * p
end

local function ensurePlaneBlip(st)
    local cfg = Config.Blips.Plane
    if not cfg or cfg.Enable == false then
        removeBlipKey('plane')
        return
    end
    if not st or st.status ~= 'INCOMING' then
        removeBlipKey('plane')
        return
    end

    if planeEnt and DoesEntityExist(planeEnt) then
        local existing = blips.plane
        local attached = false
        if existing and DoesBlipExist(existing) then
            local ok, idx = pcall(GetBlipInfoIdEntityIndex, existing)
            attached = ok and idx == planeEnt
        end
        if not attached then
            removeBlipKey('plane')
            local blip = AddBlipForEntity(planeEnt)
            styleBlip(blip, cfg, cfg.Label or 'Airdrop Plane')
            blips.plane = blip
        end
        return
    end

    local pos = lerpPlaneCoords(st)
    if pos then
        ensureCoordBlip('plane', pos, cfg, cfg.Label or 'Airdrop Plane')
    end
end

local function ensureWorldBlips(st)
    local coords = vecFrom(st and st.coords)
    if not coords then return end

    local dropCfg = Config.Blips.Drop or Config.Blips.Crate
    local dropName = st.label and ('Airdrop: %s'):format(st.label) or (dropCfg and dropCfg.Label) or 'Airdrop'
    ensureCoordBlip('drop', coords, dropCfg, dropName)
    ensureRadiusBlip(coords)
    ensurePlaneBlip(st)
end

local function requestModel(hash)
    if not IsModelValid(hash) then return false end
    if HasModelLoaded(hash) then return true end
    return lib.requestModel(hash, 8000) and HasModelLoaded(hash)
end

local function groundZ(coords)
    local found, z = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + 80.0, false)
    if found then return z end
    return coords.z
end

local function spawnCrateAt(coords, heading, withChute)
    if crateEnt and DoesEntityExist(crateEnt) then return crateEnt end
    local model = Config.Crate.Model
    if not requestModel(model) then return nil end

    crateEnt = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)
    SetEntityHeading(crateEnt, heading or 0.0)
    FreezeEntityPosition(crateEnt, Config.Crate.FreezeOnLand ~= false)
    SetEntityInvincible(crateEnt, true)
    SetEntityCollision(crateEnt, true, true)
    SetModelAsNoLongerNeeded(model)

    if withChute then
        local chuteModel = Config.Crate.ParachuteModel
        if requestModel(chuteModel) then
            chuteEnt = CreateObject(chuteModel, coords.x, coords.y, coords.z + 1.6, false, false, false)
            AttachEntityToEntity(chuteEnt, crateEnt, 0, 0.0, 0.0, 1.55, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
            SetModelAsNoLongerNeeded(chuteModel)
        end
    end

    return crateEnt
end

local function requestPtfx(dict, timeout)
    if type(dict) ~= 'string' or dict == '' then return false end
    if HasNamedPtfxAssetLoaded(dict) then return true end
    RequestNamedPtfxAsset(dict)
    local deadline = GetGameTimer() + (timeout or 5000)
    while not HasNamedPtfxAssetLoaded(dict) do
        if GetGameTimer() >= deadline then
            return false
        end
        Wait(10)
    end
    return true
end

local function startSmoke()
    local smoke = Config.Crate.Smoke
    if not smoke or smoke.Enable == false then return end
    if not crateEnt or not DoesEntityExist(crateEnt) then return end
    if smokeFx or smokeTried then return end
    smokeTried = true

    local candidates = {
        { Dict = smoke.Dict, Name = smoke.Name },
        { Dict = 'scr_oddjobtraffickingair', Name = 'scr_crate_drop_flare' },
        { Dict = 'scr_oddjobtraffickingair', Name = 'scr_crate_drop_smoke' },
        { Dict = 'core', Name = 'ent_amb_smoke_foundry' },
    }

    local seen = {}
    CreateThread(function()
        local off = smoke.Offset or vec3(0.0, 0.0, 0.35)
        for i = 1, #candidates do
            local fx = candidates[i]
            local key = ('%s:%s'):format(fx.Dict or '', fx.Name or '')
            if not seen[key] and fx.Dict and fx.Name then
                seen[key] = true
                if requestPtfx(fx.Dict, 5000) and crateEnt and DoesEntityExist(crateEnt) then
                    UseParticleFxAssetNextCall(fx.Dict)
                    local handle = StartParticleFxLoopedOnEntity(
                        fx.Name,
                        crateEnt,
                        off.x, off.y, off.z,
                        0.0, 0.0, 0.0,
                        smoke.Scale or 1.0,
                        false, false, false
                    )
                    if handle and handle ~= 0 then
                        smokeFx = handle
                        return
                    end
                end
            end
        end
    end)
end

local function dropChute()
    if chuteEnt and DoesEntityExist(chuteEnt) then
        DetachEntity(chuteEnt, true, true)
        deleteEnt(chuteEnt)
        chuteEnt = nil
    end
    if crateEnt and DoesEntityExist(crateEnt) and Config.Crate.FreezeOnLand ~= false then
        FreezeEntityPosition(crateEnt, true)
    end
    crateLanded = true
    startSmoke()
end

local function tryClaim()
    if claiming then return end
    local st = state()
    if not st or st.status ~= 'OPEN' then
        lib.notify({ title = 'AIRDROP', description = 'Crate is still locked.', type = 'error' })
        return
    end
    if not lootAllowedClaim() then
        lib.notify({ title = 'AIRDROP', description = 'You cannot loot the airdrop in this region.', type = 'error' })
        return
    end

    claiming = true
    local ok = lib.progressBar({
        duration = Config.Claim.ProgressMs or 8000,
        label = 'Cracking airdrop crate...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = Config.Claim.CancelOnMove ~= false,
            car = true,
            combat = true,
        },
        anim = { dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', clip = 'machinic_loop_mecheckbox', flag = 49 },
    })
    claiming = false
    if ok then
        TriggerServerEvent('kodebykarl-airdrop:server:claim')
    end
end

local function addCrateTarget()
    if targetOn or not crateEnt or not DoesEntityExist(crateEnt) then return end
    if not Config.Claim.UseOxTarget then return end
    if GetResourceState('ox_target') ~= 'started' then return end
    oxTarget = oxTarget or exports.ox_target

    oxTarget:addLocalEntity(crateEnt, {
        {
            name = 'kodebykarl_airdrop_loot',
            icon = 'fa-solid fa-parachute-box',
            label = 'Loot Airdrop',
            distance = Config.Claim.Distance or 2.8,
            canInteract = function()
                local st = state()
                return st and st.status == 'OPEN' and lootAllowedClaim() and not claiming
            end,
            onSelect = tryClaim,
        },
        {
            name = 'kodebykarl_airdrop_locked',
            icon = 'fa-solid fa-lock',
            label = 'Crate Locked',
            distance = Config.Claim.Distance or 2.8,
            canInteract = function()
                local st = state()
                return st and (st.status == 'LOCKED' or st.status == 'INCOMING')
            end,
            onSelect = function()
                local st = state()
                local rem = st and math.max(0, (st.unlockAt or 0) - now()) or 0
                lib.notify({
                    title = 'AIRDROP',
                    description = ('Unlocks in %s'):format(formatClock(rem)),
                    type = 'inform',
                })
            end,
        },
    })
    targetOn = true
end

local function flyPlane(st)
    if not Config.Plane.Enable then return end
    if planeEnt and DoesEntityExist(planeEnt) then return end

    local coords = vecFrom(st.coords)
    if not coords then return end
    local heading = st.heading or 0.0
    local dir = approachDir(heading)
    local alt = Config.Plane.Altitude or 180.0
    local approach = Config.Plane.ApproachDistance or 900.0
    local despawn = Config.Plane.DespawnDistance or 700.0
    local startPos = coords - (dir * approach) + vec3(0.0, 0.0, alt)
    local dropPos = coords + vec3(0.0, 0.0, alt)
    local endPos = coords + (dir * despawn) + vec3(0.0, 0.0, alt)

    local model = Config.Plane.Model
    if not requestModel(model) then return end

    planeEnt = CreateVehicle(model, startPos.x, startPos.y, startPos.z, heading, false, false)
    SetEntityInvincible(planeEnt, true)
    SetEntityCollision(planeEnt, false, false)
    SetVehicleEngineOn(planeEnt, true, true, false)
    SetVehicleRadioEnabled(planeEnt, false)
    ControlLandingGear(planeEnt, 3)
    SetVehicleDoorsLocked(planeEnt, 2)
    SetModelAsNoLongerNeeded(model)
    ensurePlaneBlip(st)

    local seq = st.seq
    local flightMs = math.max(1000, (Config.FlightSeconds or 28) * 1000)
    local started = GetGameTimer()

    CreateThread(function()
        while planeEnt and DoesEntityExist(planeEnt) do
            local stNow = state()
            if not stNow or stNow.seq ~= seq or stNow.status == 'IDLE' or stNow.status == 'CLAIMED' then
                break
            end

            local t = (GetGameTimer() - started) / flightMs
            if t >= 1.35 then break end

            local pos
            if t <= 1.0 then
                local a = startPos
                local b = dropPos
                local p = t
                pos = a + (b - a) * p
            else
                local p = math.min(1.0, (t - 1.0) / 0.35)
                pos = dropPos + (endPos - dropPos) * p
            end

            SetEntityCoordsNoOffset(planeEnt, pos.x, pos.y, pos.z, false, false, false)
            SetEntityHeading(planeEnt, heading)
            Wait(0)
        end

        deleteEnt(planeEnt)
        planeEnt = nil
        removeBlipKey('plane')
    end)
end

local function runCrateFall(st)
    if crateEnt and DoesEntityExist(crateEnt) then
        if crateLanded then
            addCrateTarget()
            startSmoke()
        end
        return
    end

    local coords = vecFrom(st.coords)
    if not coords then return end
    local gz = groundZ(coords)
    local land = vec3(coords.x, coords.y, gz)
    local start = vec3(coords.x, coords.y, gz + (Config.Crate.StartHeight or 160.0))
    local untilLand = (st.landAt or now()) - now()
    local alreadyLanded = untilLand <= 0

    spawnCrateAt(alreadyLanded and land or start, st.heading, not alreadyLanded)
    if not crateEnt then return end
    ensureWorldBlips(st)

    if alreadyLanded then
        dropChute()
        addCrateTarget()
        return
    end

    local seq = st.seq
    local duration = math.max(500, untilLand * 1000)
    local t0 = GetGameTimer()
    FreezeEntityPosition(crateEnt, false)

    CreateThread(function()
        while crateEnt and DoesEntityExist(crateEnt) do
            local stNow = state()
            if not stNow or stNow.seq ~= seq then break end
            local p = math.min(1.0, (GetGameTimer() - t0) / duration)
            local pos = start + (land - start) * p
            SetEntityCoordsNoOffset(crateEnt, pos.x, pos.y, pos.z, false, false, false)
            if p >= 1.0 then
                SetEntityCoordsNoOffset(crateEnt, land.x, land.y, land.z, false, false, false)
                dropChute()
                addCrateTarget()
                break
            end
            Wait(0)
        end
    end)
end

local function applyState(st)
    if st and st.serverNow then
        syncedUnix = st.serverNow
        syncedAtMs = GetGameTimer()
    end

    if not st or st.status == 'IDLE' or st.status == 'CLAIMED' then
        if currentSeq ~= 0 then
            cleanupVisuals()
            currentSeq = 0
        end
        return
    end

    if not lootAllowed() and not Config.GateLootOnly then
        cleanupVisuals()
        return
    end

    if st.seq ~= currentSeq then
        cleanupVisuals()
        currentSeq = st.seq
    end

    ensureWorldBlips(st)

    if st.status == 'INCOMING' then
        flyPlane(st)
        local untilLand = (st.landAt or 0) - now()
        if untilLand <= (Config.FallSeconds or 16) then
            runCrateFall(st)
        end
    elseif st.status == 'LOCKED' or st.status == 'OPEN' then
        runCrateFall(st)
        addCrateTarget()
        startSmoke()
    end
end

RegisterNetEvent('kodebykarl-airdrop:client:announce', function(data)
    if type(data) ~= 'table' then return end
    lib.notify({
        title = data.title or 'AIRDROP',
        description = data.description or '',
        type = data.type or 'inform',
        duration = data.duration or 8000,
    })
end)

RegisterNetEvent('kodebykarl-airdrop:client:sync', function(payload)
    applyState(payload or state())
end)

RegisterNetEvent('kodebykarl-airdrop:client:cleanup', function()
    currentSeq = 0
    cleanupVisuals()
end)

AddStateBagChangeHandler('airdrop_event', 'global', function(_, _, value)
    applyState(value)
end)

CreateThread(function()
    Wait(800)
    applyState(state())
    while true do
        Wait(1000)
        applyState(state())
    end
end)

-- Nearby lock timer + E fallback
CreateThread(function()
    while true do
        local sleep = 700
        local st = state()
        local ped = PlayerPedId()

        if st and vecFrom(st.coords) and (st.status == 'LOCKED' or st.status == 'OPEN' or st.status == 'INCOMING') then
            local coords = vecFrom(st.coords)
            local dist = #(GetEntityCoords(ped) - coords)
            if dist < 12.0 then
                sleep = 0
                local key = nil
                local label = nil
                if st.status == 'OPEN' then
                    key = 'open'
                    label = Config.Claim.AllowKeyFallback and '[E] Loot Airdrop' or 'Airdrop unlocked'
                elseif st.status == 'LOCKED' then
                    key = 'lock'
                    label = ('CRATE LOCKED • %s'):format(formatClock((st.unlockAt or 0) - now()))
                else
                    key = 'fall'
                    label = 'Airdrop incoming'
                end

                if nearText ~= key then
                    nearText = key
                    lib.showTextUI(label, {
                        position = 'top-center',
                        icon = 'fa-solid fa-parachute-box',
                        style = {
                            borderRadius = '6px',
                            backgroundColor = 'rgba(13, 13, 18, 0.9)',
                            color = st.status == 'OPEN' and '#2ecc71' or '#ff4d4d',
                            border = '1px solid rgba(255, 58, 58, 0.4)',
                            padding = '6px 12px',
                            fontSize = '12px',
                            fontWeight = '600',
                        }
                    })
                elseif key == 'lock' then
                    lib.showTextUI(label, {
                        position = 'top-center',
                        icon = 'fa-solid fa-lock',
                        style = {
                            borderRadius = '6px',
                            backgroundColor = 'rgba(13, 13, 18, 0.9)',
                            color = '#ff4d4d',
                            border = '1px solid rgba(255, 58, 58, 0.4)',
                            padding = '6px 12px',
                            fontSize = '12px',
                            fontWeight = '600',
                        }
                    })
                end

                if st.status == 'OPEN' and Config.Claim.AllowKeyFallback and dist <= (Config.Claim.Distance or 2.8) then
                    if IsControlJustPressed(0, 38) then
                        tryClaim()
                    end
                end
            elseif nearText then
                lib.hideTextUI()
                nearText = nil
            end
        elseif nearText then
            lib.hideTextUI()
            nearText = nil
        end

        Wait(sleep)
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    cleanupVisuals()
end)
