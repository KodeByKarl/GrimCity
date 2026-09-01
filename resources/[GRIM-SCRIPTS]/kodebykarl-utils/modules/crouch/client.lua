local crouched = false
LocalPlayer.state:set('Crouch', false, false)

local function loadAnimSet(anim)
    if not anim or anim == '' then return false end
    RequestAnimSet(anim)
    local timeout = 0
    while not HasAnimSetLoaded(anim) and timeout < 100 do
        Wait(10)
        timeout = timeout + 1
    end
    return HasAnimSetLoaded(anim)
end

local function canCrouch(ped)
    if not DoesEntityExist(ped) or IsEntityDead(ped) then return false end
    if IsPauseMenuActive() then return false end
    if IsPedInAnyVehicle(ped, false) then return false end
    if IsPedFalling(ped) or IsPedJumping(ped) or IsPedRagdoll(ped) then return false end
    return true
end

local function getWalkStyle()
    -- Check rpemotes (uses KVP string "walkstyle")
    if GetResourceState('rpemotes') == 'started' then
        local walk = GetResourceKvpString('walkstyle')
        if walk and walk ~= '' and walk ~= 'default' then
            return walk
        end
    end

    -- Check scully_emotemenu
    if GetResourceState('scully_emotemenu') == 'started' then
        local ok, walk = pcall(function()
            return exports['scully_emotemenu']:getCurrentWalk()
        end)
        if ok and walk and walk ~= '' and walk ~= 'default' then
            return walk
        end
    end

    -- Fallback to kodebykarl-ui if present
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

local function applyWalkOrReset(ped)
    local walk = getWalkStyle()
    ResetPedStrafeClipset(ped)
    ResetPedWeaponMovementClipset(ped)

    if walk and loadAnimSet(walk) then
        SetPedMovementClipset(ped, walk, 0.25)
        RemoveAnimSet(walk)
    else
        ResetPedMovementClipset(ped, 0.25)
    end
end

local function setCrouched(state)
    local ped = PlayerPedId()

    if state then
        if not canCrouch(ped) then return end
        if not loadAnimSet('move_ped_crouched') then return end

        SetPedStealthMovement(ped, false, 0)
        SetPedMovementClipset(ped, 'move_ped_crouched', 0.25)
        SetPedStrafeClipset(ped, 'move_ped_crouched_strafing')
        SetPedWeaponMovementClipset(ped, 'move_ped_crouched')
        crouched = true
        LocalPlayer.state:set('Crouch', true, false)
    else
        SetPedStealthMovement(ped, false, 0)
        applyWalkOrReset(ped)
        crouched = false
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
    setCrouched(not crouched)
end

-- Export function
exports('toggleCrouch', toggleCrouch)
exports('setCrouched', setCrouched)
exports('isCrouched', function() return crouched end)

-- Command
RegisterCommand('crouch', function()
    toggleCrouch()
end, false)

RegisterKeyMapping('crouch', 'Crouch', 'keyboard', 'LCONTROL')

-- Block GTA default stealth duck & detect LCONTROL (Control 36) reliably every frame
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

-- Monitor vehicle entry/exit, ragdoll, falling, jumping
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

-- Vehicle cache handler if ox_lib is available
if lib and lib.onCache then
    lib.onCache('vehicle', function(veh)
        if veh and crouched then
            setCrouched(false)
        end
    end)
end
