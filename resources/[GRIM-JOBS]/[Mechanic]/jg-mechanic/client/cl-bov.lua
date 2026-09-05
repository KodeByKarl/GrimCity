-- Client-side handler for Turbo Blow-Off Valve (BOV) & Compressor Flutter Sounds

local currentVehicle = nil
local currentBovType = nil
local hasTurbo = false
local prevRpm = 0.0
local lastBovTime = 0
local isElectric = false

local BOV_SOUND_CONFIGS = {
  [1] = "hks",     -- HKS SSQV (High Whistle)
  [2] = "greddy",  -- GReddy Type-RS (Deep Rush)
  [3] = "tial",    -- TIAL Compressor Flutter (Stututu)
  [4] = "wrc"      -- WRC Rally Anti-Lag Valve
}

-- Play 3D spatial BOV audio
local function playBovSoundEffect(vehicle, bovType)
  if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return end
  local coords = GetEntityCoords(vehicle)

  if bovType == "tial" then
    -- Aggressive Stututu multi-pulse flutter
    CreateThread(function()
      for i = 1, 4 do
        if not DoesEntityExist(vehicle) then break end
        PlaySoundFromCoord(-1, "CAR_TURBO_RELEASE", coords.x, coords.y, coords.z, "DLC_EXEC_CAR_TURBO_SOUNDS", 0, 20, 0)
        Wait(65)
      end
    end)
  elseif bovType == "wrc" then
    -- Rally chirp + whistle
    PlaySoundFromCoord(-1, "CAR_TURBO_RELEASE", coords.x, coords.y, coords.z, "DLC_EXEC_CAR_TURBO_SOUNDS", 0, 25, 0)
    PlaySoundFromCoord(-1, "NAV_LEFT_RIGHT", coords.x, coords.y, coords.z, "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 10, 0)
  elseif bovType == "greddy" then
    -- Deep whoosh
    PlaySoundFromCoord(-1, "CAR_TURBO_RELEASE", coords.x, coords.y, coords.z, "DLC_EXEC_CAR_TURBO_SOUNDS", 0, 25, 0)
  else
    -- HKS High whistle
    PlaySoundFromCoord(-1, "CAR_TURBO_RELEASE", coords.x, coords.y, coords.z, "DLC_EXEC_CAR_TURBO_SOUNDS", 0, 20, 0)
  end
end

-- Sync handler from server for nearby clients
RegisterNetEvent("jg-mechanic:client:sync-bov", function(senderSrc, netId, coords, bovType)
  if senderSrc == GetPlayerServerId(PlayerId()) then return end

  local myCoords = GetEntityCoords(cache.ped or PlayerPedId())
  if #(myCoords - coords) > 65.0 then return end

  local vehicle = NetToVeh(netId)
  if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return end

  playBovSoundEffect(vehicle, bovType)
end)

-- Update active vehicle turbo & BOV configuration
local function updateVehicleBovState(vehicle)
  if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
    currentVehicle = nil
    currentBovType = nil
    hasTurbo = false
    isElectric = false
    return
  end

  currentVehicle = vehicle
  local modelName = GetEntityArchetypeName(vehicle)
  isElectric = isVehicleElectric and isVehicleElectric(modelName) or false

  local state = Entity(vehicle).state
  local tuningConfig = state and state.tuningConfig

  hasTurbo = IsToggleModOn(vehicle, 18) or (tuningConfig and tuningConfig.turbocharging == 1)

  if tuningConfig and tuningConfig.bov then
    local bovIndex = tonumber(tuningConfig.bov) or 1
    currentBovType = BOV_SOUND_CONFIGS[bovIndex] or "hks"
  else
    currentBovType = nil
  end
end

-- Listen for vehicle entry/exit
lib.onCache("vehicle", function(vehicle)
  updateVehicleBovState(vehicle)
end)

-- Listen for tuning statebag changes live
AddStateBagChangeHandler("tuningConfig", "", function(bagName, key, value)
  if currentVehicle and currentVehicle ~= 0 then
    local vehFromBag = GetEntityFromStateBagName(bagName)
    if vehFromBag == currentVehicle then
      hasTurbo = IsToggleModOn(currentVehicle, 18) or (value and value.turbocharging == 1)
      if value and value.bov then
        local bovIndex = tonumber(value.bov) or 1
        currentBovType = BOV_SOUND_CONFIGS[bovIndex] or "hks"
      else
        currentBovType = nil
      end
    end
  end
end)

-- Main BOV discharge monitoring loop
CreateThread(function()
  while true do
    local sleep = 1000

    if currentVehicle and currentVehicle ~= 0 and DoesEntityExist(currentVehicle) and not isElectric and currentBovType then
      local ped = cache.ped or PlayerPedId()
      if GetPedInVehicleSeat(currentVehicle, -1) == ped and IsVehicleEngineOn(currentVehicle) then
        sleep = 0
        local now = GetGameTimer()
        local rpm = GetVehicleCurrentRpm(currentVehicle)
        local isAccelerating = IsControlPressed(0, 71) -- [W]

        -- Trigger BOV on lift-off from high boost / high RPM
        if prevRpm > 0.58 and rpm < (prevRpm - 0.05) and not isAccelerating and (now - lastBovTime) > 750 then
          lastBovTime = now
          playBovSoundEffect(currentVehicle, currentBovType)

          local netId = NetworkGetNetworkIdFromEntity(currentVehicle)
          if netId and netId ~= 0 then
            TriggerServerEvent("jg-mechanic:server:trigger-bov", netId, currentBovType)
          end
        end

        prevRpm = rpm
      end
    end

    Wait(sleep)
  end
end)
