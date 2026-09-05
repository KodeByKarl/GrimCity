local currentVehicle = nil
local cachedExhaustBones = {}
local isTwoStepActive = false
local lastTwoStepBurst = 0
local lastPopTime = 0
local prevRpm = 0.0
local isElectric = false
local currentEcuStage = 0

local EXHAUST_BONE_NAMES = {
  "exhaust",
  "exhaust_2",
  "exhaust_3",
  "exhaust_4",
  "exhaust_5",
  "exhaust_6",
  "exhaust_7",
  "exhaust_8",
  "exhaust_9",
  "exhaust_10",
  "exhaust_11",
  "exhaust_12",
  "exhaust_13",
  "exhaust_14",
  "exhaust_15",
  "exhaust_16"
}

-- Ensure PTFX asset is loaded
local function ensurePtfxLoaded()
  if not HasNamedPtfxAssetLoaded("core") then
    RequestNamedPtfxAsset("core")
    local timeout = GetGameTimer() + 2000
    while not HasNamedPtfxAssetLoaded("core") and GetGameTimer() < timeout do
      Wait(10)
    end
  end
end

-- Cache exhaust bones for a vehicle
local function cacheVehicleExhaustBones(vehicle)
  local bones = {}
  if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
    return bones
  end

  for _, boneName in ipairs(EXHAUST_BONE_NAMES) do
    local boneIndex = GetEntityBoneIndexByName(vehicle, boneName)
    if boneIndex and boneIndex ~= -1 then
      bones[#bones + 1] = boneIndex
    end
  end

  return bones
end

-- Trigger visual flame burst & light on exhaust
local function playExhaustFlame(vehicle, bones, scale)
  if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return end
  if #bones == 0 then return end

  ensurePtfxLoaded()
  scale = scale or 1.0

  for _, boneIndex in ipairs(bones) do
    local boneCoords = GetWorldPositionOfEntityBone(vehicle, boneIndex)
    if boneCoords then
      UseParticleFxAssetNextCall("core")
      StartParticleFxNonLoopedAtCoord(
        "veh_backfire",
        boneCoords.x, boneCoords.y, boneCoords.z,
        0.0, 0.0, 0.0,
        scale,
        false, false, false
      )
      DrawLightWithRange(boneCoords.x, boneCoords.y, boneCoords.z, 255, 130, 40, 2.5, 4.0)
    end
  end
end

-- Play backfire pop audio
local function playBackfireSound(vehicle, soundType)
  if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return end
  local coords = GetEntityCoords(vehicle)

  if soundType == "bang" or soundType == "twostep" then
    PlaySoundFromCoord(-1, "NAV_LEFT_RIGHT", coords.x, coords.y, coords.z, "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 15, 0)
    PlaySoundFromEntity(-1, "CAR_TURBO_RELEASE", vehicle, "DLC_EXEC_CAR_TURBO_SOUNDS", 0, 0)
  else
    PlaySoundFromEntity(-1, "CAR_TURBO_RELEASE", vehicle, "DLC_EXEC_CAR_TURBO_SOUNDS", 0, 0)
  end
end

-- Network sync handler for nearby clients
RegisterNetEvent("jg-mechanic:client:sync-backfire", function(senderSrc, netId, coords, scale, soundType)
  if senderSrc == GetPlayerServerId(PlayerId()) then return end

  local myCoords = GetEntityCoords(cache.ped or PlayerPedId())
  if #(myCoords - coords) > 75.0 then return end

  local vehicle = NetToVeh(netId)
  if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return end

  local bones = cacheVehicleExhaustBones(vehicle)
  playExhaustFlame(vehicle, bones, scale)
  playBackfireSound(vehicle, soundType)
end)

-- Main pops & bangs execution
local function triggerPopBurst(vehicle, stage)
  if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return end
  if isElectric then return end

  local numPops = 1
  local scale = 0.8
  local soundType = "pop"

  if stage == 1 then
    numPops = math.random(1, 2)
    scale = 0.6
  elseif stage == 2 then
    numPops = math.random(1, 3)
    scale = 0.9
    soundType = "pop"
  elseif stage >= 3 then
    numPops = math.random(2, 4)
    scale = 1.25
    soundType = "bang"
  end

  local netId = NetworkGetNetworkIdFromEntity(vehicle)
  if netId and netId ~= 0 then
    TriggerServerEvent("jg-mechanic:server:trigger-backfire", netId, scale, soundType)
  end

  CreateThread(function()
    for _ = 1, numPops do
      if not currentVehicle or currentVehicle ~= vehicle then break end
      playExhaustFlame(vehicle, cachedExhaustBones, scale)
      playBackfireSound(vehicle, soundType)
      Wait(math.random(60, 140))
    end
  end)
end

-- Check current vehicle ECU tuning
local function updateVehicleTuningState(vehicle)
  if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
    currentVehicle = nil
    cachedExhaustBones = {}
    currentEcuStage = 0
    isElectric = false
    return
  end

  currentVehicle = vehicle
  cachedExhaustBones = cacheVehicleExhaustBones(vehicle)
  local modelName = GetEntityArchetypeName(vehicle)
  isElectric = isVehicleElectric and isVehicleElectric(modelName) or false

  local state = Entity(vehicle).state
  local tuningConfig = state and state.tuningConfig

  if tuningConfig and tuningConfig.ecu then
    currentEcuStage = tonumber(tuningConfig.ecu) or 0
  else
    currentEcuStage = 0
  end
end

-- Listen for vehicle cache changes
lib.onCache("vehicle", function(vehicle)
  updateVehicleTuningState(vehicle)
end)

-- Statebag listener for tuning updates while inside the car
AddStateBagChangeHandler("tuningConfig", "", function(bagName, key, value)
  if currentVehicle and currentVehicle ~= 0 then
    local vehFromBag = GetEntityFromStateBagName(bagName)
    if vehFromBag == currentVehicle then
      if value and value.ecu then
        currentEcuStage = tonumber(value.ecu) or 0
      else
        currentEcuStage = 0
      end
    end
  end
end)

-- Main Anti-Lag & Pops Thread
CreateThread(function()
  while true do
    local sleep = 1000

    if currentVehicle and currentVehicle ~= 0 and DoesEntityExist(currentVehicle) and not isElectric and currentEcuStage > 0 then
      local ped = cache.ped or PlayerPedId()
      if GetPedInVehicleSeat(currentVehicle, -1) == ped and IsVehicleEngineOn(currentVehicle) then
        sleep = 0
        local now = GetGameTimer()
        local rpm = GetVehicleCurrentRpm(currentVehicle)
        local speed = GetEntitySpeed(currentVehicle) * 3.6 -- km/h
        local isAccelerating = IsControlPressed(0, 71) -- [W] / Gas
        local isHandbraking = IsControlPressed(0, 76) or IsDisabledControlPressed(0, 76) -- [Space] / Handbrake

        -- 1. TWO-STEP LAUNCH CONTROL (Stage 3 ECU / Race Map)
        if currentEcuStage >= 3 and speed < 3.0 and isAccelerating and isHandbraking then
          if not isTwoStepActive then
            isTwoStepActive = true
          end

          -- Bounce RPM between 0.78 and 0.85
          local targetRpm = (math.random(0, 1) == 1) and 0.85 or 0.78
          SetVehicleCurrentRpm(currentVehicle, targetRpm)
          SetVehicleTurboPressure(currentVehicle, 1.0)

          if (now - lastTwoStepBurst) > 90 then
            lastTwoStepBurst = now
            playExhaustFlame(currentVehicle, cachedExhaustBones, 1.3)
            playBackfireSound(currentVehicle, "twostep")

            local netId = NetworkGetNetworkIdFromEntity(currentVehicle)
            if netId and netId ~= 0 then
              TriggerServerEvent("jg-mechanic:server:trigger-backfire", netId, 1.3, "twostep")
            end
          end
        else
          -- If 2-step was just released, apply brief launch torque boost
          if isTwoStepActive then
            isTwoStepActive = false
            CreateThread(function()
              local launchTime = GetGameTimer()
              while (GetGameTimer() - launchTime) < 1200 and currentVehicle and DoesEntityExist(currentVehicle) do
                SetVehicleCheatPowerIncrease(currentVehicle, 1.25)
                Wait(0)
              end
            end)
          end

          -- 2. LIFT-OFF POPS & BANGS (Deceleration from High Redline RPM)
          if prevRpm > 0.84 and rpm < (prevRpm - 0.08) and not isAccelerating and (now - lastPopTime) > 1200 then
            local popChance = 0
            if currentEcuStage == 1 then
              popChance = 20
            elseif currentEcuStage == 2 then
              popChance = 45
            elseif currentEcuStage >= 3 then
              popChance = 70
            end

            if math.random(1, 100) <= popChance then
              lastPopTime = now
              triggerPopBurst(currentVehicle, currentEcuStage)
            end
          end
        end

        prevRpm = rpm
      end
    end

    Wait(sleep)
  end
end)
