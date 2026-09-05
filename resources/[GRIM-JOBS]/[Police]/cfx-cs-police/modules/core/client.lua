ESX = exports['es_extended']:getSharedObject()
ox_inventory = exports.ox_inventory
ox_target = exports.ox_target
PlayerData = {}
escorting = {}
escorted = {}
isCuffed = nil
cuffProp = nil
isBusy = nil

local Tackle = {
	isTackling	= false,
	isGettingTackled	= false,
	tackleLib	= 'missmic2ig_11',
	tackleAnim	= 'mic_2_ig_11_intro_goon',
	tackleVictimAnim	= 'mic_2_ig_11_intro_p_one',
	lastTackleTime	= 0,
	isRagdoll	= false
}

ESX.SecureNetEvent('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

ESX.SecureNetEvent('esx:setJob', function(job)
	PlayerData.job = job
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName or not ESX.IsPlayerLoaded() then return end
    PlayerData = ESX.GetPlayerData()
end)

AddEventHandler('esx:setPlayerData', function(key, value)
    if GetInvokingResource() ~= 'es_extended' then return end
    PlayerData[key] = value
end)

function HasGroup()
    local job = PlayerData and PlayerData.job
    if (not job or not job.name) and ESX.GetPlayerData then
        job = ESX.GetPlayerData().job
    end
    if not job or not job.name then
        return false
    end
    local name = tostring(job.name):lower()
    if name:sub(1, 3) == 'off' then
        return false
    end
    return type(Config.LawEnforcement[name]) == 'table' or type(Config.LawEnforcement[job.name]) == 'table'
end

--- Resolve a nearby player server id from ox_target data, a raw id, or closest player.
---@param data number|table|nil
---@param maxDistance? number
---@return number|nil
function GetTargetServerId(data, maxDistance)
    maxDistance = maxDistance or 4.0

    if type(data) == 'number' then
        return data
    end

    if type(data) == 'table' then
        if type(data.targetId) == 'number' then
            return data.targetId
        end
        if data.entity and DoesEntityExist(data.entity) and IsPedAPlayer(data.entity) then
            local player = NetworkGetPlayerIndexFromPed(data.entity)
            if player and player ~= -1 then
                return GetPlayerServerId(player)
            end
        end
    end

    local player = lib.getClosestPlayer(GetEntityCoords(cache.ped), maxDistance, false)
    return player and GetPlayerServerId(player) or nil
end

function GetVehicleInDirection()
	local coords = GetEntityCoords(cache.ped)
	local inDirection  = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 5.0, 0.0)
	local rayHandle    = StartExpensiveSynchronousShapeTestLosProbe(coords, inDirection, 10, cache.ped, 0)
	local numRayHandle, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
	if hit == 1 and GetEntityType(entityHit) == 2 then
		local entityCoords = GetEntityCoords(entityHit)
		return entityHit, entityCoords
	end
	return nil
end

CreateThread(function()
	while true do
		Wait(0)
		local letsleep = true
		if Tackle.isRagdoll then
			letsleep = false
			SetPedToRagdoll(cache.ped, 1000, 1000, 0, 0, 0, 0)
		end
		if letsleep then
			Wait(500)
		end
	end
end)

ESX.SecureNetEvent('cfx-cs-police:Tackle:getTackled', function(target)
	Tackle.isGettingTackled = true
	local playerPed = cache.ped
	local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
	RequestAnimDict(Tackle.tackleLib)
	while not HasAnimDictLoaded(Tackle.tackleLib) do
		Wait(10)
	end
	AttachEntityToEntity(cache.ped, targetPed, 11816, 0.25, 0.5, 0.0, 0.5, 0.5, 180.0, false, false, false, false, 2, false)
	TaskPlayAnim(playerPed, Tackle.tackleLib, Tackle.tackleVictimAnim, 8.0, -8.0, 3000, 0, 0, false, false, false)
	Wait(3000)
	DetachEntity(cache.ped, true, false)
	Tackle.isRagdoll = true
	Wait(3000)
	Tackle.isRagdoll = false
	Tackle.isGettingTackled = false
end)

function isTackled()
	return Tackle.isRagdoll
end

exports('isTackled', isTackled)

ESX.SecureNetEvent('cfx-cs-police:Tackle:playTackle', function()
	local playerPed = cache.ped
	RequestAnimDict(Tackle.tackleLib)
	while not HasAnimDictLoaded(Tackle.tackleLib) do
		Wait(10)
	end
	TaskPlayAnim(playerPed, Tackle.tackleLib, Tackle.tackleAnim, 8.0, -8.0, 3000, 0, 0, false, false, false)
	Wait(3000)
	Tackle.isTackling = false
end)

CreateThread(function()
	while true do
		Wait(1)
		local letsleep = true
		if IsControlPressed(0, 21) and IsControlPressed(0, 23) and not Tackle.isTackling and GetGameTimer() - Tackle.lastTackleTime > 10 * 1000 then
			if HasGroup() then
				letsleep = false
				Wait(10)
				local closestPlayer, distance = ESX.Game.GetClosestPlayer()
				if distance ~= -1 and distance <= 3 and not Tackle.isTackling and not Tackle.isGettingTackled and not IsPedInAnyVehicle(cache.ped) and not IsPedInAnyVehicle(GetPlayerPed(closestPlayer)) then
					letsleep = false
					Tackle.isTackling = true
					Tackle.lastTackleTime = GetGameTimer()
					TriggerServerEvent('cfx-cs-police:Tackle:tryTackle', GetPlayerServerId(closestPlayer))
				end
			end
		end
		if letsleep then
			Wait(500)
		end
	end
end)