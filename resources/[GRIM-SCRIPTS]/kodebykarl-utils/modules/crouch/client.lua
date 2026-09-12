local crouched = false
local aimCrouch = false
LocalPlayer.state:set('Crouch', false, false)

local function loadAnimSet(anim)
    if not anim or anim == '' then return false end
    RequestAnimSet(anim)
    RequestClipSet(anim)
    local timeout = 0
    while not HasAnimSetLoaded(anim) and not HasClipSetLoaded(anim) and timeout < 100 do
        Wait(10)
        timeout = timeout + 1
    end
    return HasAnimSetLoaded(anim) or HasClipSetLoaded(anim)
end

local function canCrouch(ped)
    if not DoesEntityExist(ped) or IsEntityDead(ped) then return false end
    if IsPauseMenuActive() then return false end
    if IsPedInAnyVehicle(ped, false) then return false end
    if IsPedFalling(ped) or IsPedJumping(ped) or IsPedRagdoll(ped) then return false end
    return true
end

local cachedWalk = nil
local cachedWalkAt = 0

local function getWalkStyle()
    if GetResourceState('rpemotes') == 'started' then
        local walk = GetResourceKvpString('walkstyle')
        if walk and walk ~= '' and walk ~= 'default' then
            return walk
        end
    end

    if GetResourceState('scully_emotemenu') == 'started' then
        local ok, walk = pcall(function()
            return exports['scully_emotemenu']:getCurrentWalk()
        end)
        if ok and walk and walk ~= '' and walk ~= 'default' then
            return walk
        end
    end

    if GetResourceState('kodebykarl-ui') == 'started' then
        local ok, walk = pcall(function()
            return exports['kodebykarl-ui']:getCurrentWalk()
        end)
        if ok and walk and walk ~= '' and walk ~= 'default' then
            return walk
        end
    end

    return nil
end

local function getWalkStyleCached()
    local now = GetGameTimer()
    if (now - cachedWalkAt) < 400 then
        return cachedWalk
    end
    cachedWalkAt = now
    cachedWalk = getWalkStyle()
    return cachedWalk
end

---All Flee walk styles (Flee 1–5 + legacy male flee variants)
local FLEE_CLIPSETS = {
    ['move_f@flee@a'] = true, -- Flee
    ['move_f@flee@c'] = true, -- Flee 2
    ['move_m@flee@a'] = true, -- Flee 3
    ['move_m@flee@b'] = true, -- legacy
    ['move_m@flee@c'] = true, -- legacy
    ['move_f@scared'] = true, -- Flee 4
    ['move_f@hurry@a'] = true, -- Flee 5
}

local function isFleeWalk(name)
    if not name or name == '' or name == 'default' then return false end
    name = name:lower()
    if FLEE_CLIPSETS[name] then return true end
    -- any future / custom flee clipset
    return name:find('flee', 1, true) ~= nil
end

local function isAiming()
    local playerId = PlayerId()
    if IsPlayerFreeAiming(playerId) then return true end
    if IsAimCamActive() then return true end
    if IsControlPressed(0, 25) or IsDisabledControlPressed(0, 25) then return true end -- AIM
    return false
end

local function isTryingToRun(ped)
    if IsPedSprinting(ped) or IsPedRunning(ped) then return true end
    if IsControlPressed(0, 21) or IsDisabledControlPressed(0, 21) then return true end -- sprint
    local speed = GetEntitySpeed(ped)
    if speed > 2.0 then return true end
    return false
end

local function applyWalkOrReset(ped)
    local walk = getWalkStyle()
    ResetPedStrafeClipset(ped)
    ResetPedWeaponMovementClipset(ped)

    if walk and loadAnimSet(walk) then
        SetPedMovementClipset(ped, walk, 0.25)
        return
    end

    ResetPedMovementClipset(ped, 0.25)
end

local function applyCrouchClipsets(ped)
    if not loadAnimSet('move_ped_crouched') then return false end
    SetPedStealthMovement(ped, false, 0)
    SetPedMovementClipset(ped, 'move_ped_crouched', 0.25)
    SetPedStrafeClipset(ped, 'move_ped_crouched_strafing')
    SetPedWeaponMovementClipset(ped, 'move_ped_crouched')
    return true
end

local function ensureFleeWalk(ped)
    local walk = getWalkStyle()
    if not walk or not isFleeWalk(walk) then return end
    if not loadAnimSet(walk) then return end
    if GetPedMovementClipset(ped) ~= joaat(walk) then
        SetPedMovementClipset(ped, walk, 0.25)
        ResetPedStrafeClipset(ped)
        ResetPedWeaponMovementClipset(ped)
    end
end

local function setCrouched(state)
    local ped = PlayerPedId()

    if state then
        if not canCrouch(ped) then return end
        if not applyCrouchClipsets(ped) then return end
        crouched = true
        LocalPlayer.state:set('Crouch', true, false)
    else
        SetPedStealthMovement(ped, false, 0)
        applyWalkOrReset(ped)
        crouched = false
        aimCrouch = false
        LocalPlayer.state:set('Crouch', false, false)
        RemoveAnimSet('move_ped_crouched')
    end
end

local function toggleCrouch()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        if crouched then setCrouched(false) end
        return
    end

    -- Manual crouch cancels aim-crouch tracking
    if crouched then
        aimCrouch = false
        setCrouched(false)
    else
        aimCrouch = false
        setCrouched(true)
    end
end

exports('toggleCrouch', toggleCrouch)
exports('setCrouched', setCrouched)
exports('isCrouched', function() return crouched end)

RegisterCommand('crouch', function()
    toggleCrouch()
end, false)

RegisterKeyMapping('crouch', 'Crouch', 'keyboard', 'LCONTROL')

CreateThread(function()
    while true do
        DisableControlAction(0, 36, true) -- INPUT_DUCK (Left Ctrl)

        if IsDisabledControlJustPressed(0, 36) then
            local ped = PlayerPedId()
            if not IsPauseMenuActive() and not IsPedInAnyVehicle(ped, false) then
                toggleCrouch()
            end
        end

        Wait(0)
    end
end)

-- Combat loop: Flee walk equipped → aim = crouch, run/stand = flee
CreateThread(function()
    while true do
        local walk = getWalkStyleCached()
        if not isFleeWalk(walk) then
            if aimCrouch and crouched then
                setCrouched(false)
            end
            aimCrouch = false
            Wait(250)
        else
            local ped = PlayerPedId()

            if not canCrouch(ped) then
                if crouched then setCrouched(false) end
                Wait(150)
            elseif isAiming() then
                -- Auto Crouch: while Flee is equipped, aiming/shooting forces crouch
                if not crouched then
                    setCrouched(true)
                elseif not GetPedMovementClipset(ped) or GetPedMovementClipset(ped) ~= joaat('move_ped_crouched') then
                    applyCrouchClipsets(ped)
                end
                aimCrouch = true
                Wait(0)
            elseif aimCrouch then
                setCrouched(false)
                ensureFleeWalk(ped)
                Wait(50)
            elseif crouched and isTryingToRun(ped) then
                setCrouched(false)
                ensureFleeWalk(ped)
                Wait(50)
            elseif not crouched then
                ensureFleeWalk(ped)
                Wait(100)
            else
                Wait(100)
            end
        end
    end
end)

CreateThread(function()
    while true do
        local sleep = 250
        if crouched then
            sleep = 50
            local ped = PlayerPedId()
            if not canCrouch(ped) then
                setCrouched(false)
            end
        end
        Wait(sleep)
    end
end)

AddEventHandler('esx:onPlayerDeath', function()
    if crouched then setCrouched(false) end
end)

AddEventHandler('playerSpawned', function()
    if crouched then setCrouched(false) end
end)

if lib and lib.onCache then
    lib.onCache('vehicle', function(veh)
        if veh and crouched then
            setCrouched(false)
        end
    end)
end
