ESX = exports['es_extended']:getSharedObject()
local Vars = require 'helpers.vars'
local config = require 'shared.config'
local menu = require 'shared.menu'

-- Ensure users.dead exists (ambulance death persistence)
CreateThread(function()
	MySQL.ready(function()
		pcall(function()
			MySQL.query.await([[
				ALTER TABLE `users`
				ADD COLUMN IF NOT EXISTS `dead` TINYINT(1) NOT NULL DEFAULT 0
			]])
		end)
	end)
end)

--- Sync pma-voice mute with death. Death mute is authoritative; clearing dead MUST unmute.
local function setVoiceMute(src, muted)
	if GetResourceState('pma-voice') ~= 'started' then return end
	pcall(function()
		exports['pma-voice']:MutePlayer(src, muted and true or false)
	end)
end

local function eacTemp(src, enable, modules)
	if type(src) ~= 'number' or src < 1 then return end
	pcall(function()
		for i = 1, #modules do
			if enable then
				exports['ElectronAC']:tempWhitelistPlayer(src, modules[i])
			else
				exports['ElectronAC']:tempUnWhitelistPlayer(src, modules[i])
			end
		end
	end)
end

local DEATH_EAC_MODULES = { 'antiGodmode', 'antiClearTasks', 'antiTeleport', 'antiInvisible' }

local function setDeadState(src, bool, opts)
	if not src or bool == nil then return end
	opts = opts or {}
	Player(src).state:set('dead', bool, true)
	Vars.cacheDeads[src] = bool
	if bool then
		eacTemp(src, true, DEATH_EAC_MODULES)
	else
		-- Revive uses ClearPedTasks / teleport — keep the exception briefly.
		SetTimeout(8000, function()
			if not GetPlayerName(src) then return end
			if not Vars.cacheDeads[src] then
				eacTemp(src, false, DEATH_EAC_MODULES)
			end
		end)
	end
	-- Reconnect death restore: delay mute so Mumble can bind first (channel=-1).
	if opts.delayMute and bool then
		SetTimeout(4000, function()
			if not GetPlayerName(src) then return end
			if Vars.cacheDeads[src] then
				setVoiceMute(src, true)
			end
		end)
		return
	end
	setVoiceMute(src, bool)
end

local function dropDeadPocketItems(src)
	if GetResourceState('ox_inventory') ~= 'started' then return 0 end
	src = tonumber(src)
	if not src then return 0 end

	local keep = config.General and config.General.KeepItemsOnDrop or { 'identification', 'phone' }
	local dropped = 0

	-- Prefer live inventory (works for STL + quit via ox_inventory:beforePlayerDropped)
	local ok, dropId = pcall(function()
		return exports.ox_inventory:CreateDropFromPlayer(src, keep)
	end)

	if ok and dropId then
		dropped = 1
	end

	return dropped
end

local function grantSpawnProtection(src)
	local duration = config.General and config.General.SpawnProtection and config.General.SpawnProtection.duration or 60
	duration = math.max(1, tonumber(duration) or 60)
	Player(src).state:set('spawnProtect', true, true)
	eacTemp(src, true, { 'antiGodmode' })
	pcall(function()
		exports['es_extended']:MarkRespawn(src, (duration * 1000) + 2000)
	end)
	TriggerClientEvent('cfx-keydi-ambulance:spawnProtect', src, duration)
	SetTimeout(duration * 1000, function()
		if not GetPlayerName(src) then return end
		Player(src).state:set('spawnProtect', false, true)
		if not Vars.cacheDeads[src] then
			eacTemp(src, false, { 'antiGodmode' })
		end
	end)
end

--- Used by /revive (es_extended) to clear death cache before client revive
local function AdminClearDeath(src)
	src = tonumber(src)
	if not src then return false end
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then return false end
	pcall(function()
		exports['es_extended']:MarkRespawn(src, 8000)
	end)
	MySQL.update('UPDATE users SET dead = ? WHERE identifier = ?', {0, xPlayer.identifier})
	setDeadState(src, false)
	return true
end

exports('AdminClearDeath', AdminClearDeath)

--- Client calls this after NetworkResurrectLocalPlayer so unmute sticks post-respawn.
RegisterNetEvent('cfx-keydi-ambulance:ensureVoiceUnmute', function()
	local src = source
	if Vars.cacheDeads[src] then return end
	setVoiceMute(src, false)
end)

--- Drop pockets while inventory is still loaded (ox removes it on playerDropped).
AddEventHandler('ox_inventory:beforePlayerDropped', function(src)
	src = tonumber(src)
	if not src then return end
	if not Vars.cacheDeads[src] then return end
	if config.General.DropItemsOnQuit == false then return end
	dropDeadPocketItems(src)
end)

AddEventHandler('esx:playerDropped', function(playerId)
	if Vars.cacheDeads[playerId] then
		-- Fallback if beforePlayerDropped did not run (older ox_inventory)
		if config.General.DropItemsOnQuit ~= false then
			dropDeadPocketItems(playerId)
		end
		Vars.cacheDeads[playerId] = nil
	end
	if Player(playerId).state.spawnProtect then
		Player(playerId).state:set('spawnProtect', false, true)
	end
end)

-- On character load: apply death flag first, mute after Mumble has a chance to bind.
-- Muting during the reconnect handshake is a common cause of channel=-1.
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
	local src = playerId or (xPlayer and xPlayer.source)
	if not src then return end
	CreateThread(function()
		Wait(800)
		local xP = ESX.GetPlayerFromId(src)
		if not xP then return end
		local value = MySQL.scalar.await('SELECT `dead` FROM `users` WHERE `identifier` = ?', { xP.identifier })
		local isDead = value == 1
		Player(src).state:set('dead', isDead, true)
		Vars.cacheDeads[src] = isDead
		TriggerClientEvent('pma-voice:client:joinHandshake', src)
		Wait(3500)
		if not GetPlayerName(src) then return end
		setVoiceMute(src, Vars.cacheDeads[src] and true or false)
	end)
end)

ESX.RegisterServerCallback('cfx-keydi-ambulance:checkDeathStatus', function(source, cb)
	local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then
        return cb(Vars.cacheDeads[src] or false)
    end
    local value = MySQL.scalar.await('SELECT `dead` FROM `users` WHERE `identifier` = ?', {xPlayer.identifier})
    local returnValue = value == 1 and true or false
    cb(returnValue)
end)


ESX.RegisterServerCallback('cfx-keydi-ambulance:removeItems', function(source, cb)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then return cb(false) end
	-- Allow if cached dead OR DB still marked dead (prevents soft-lock on respawn)
	local dbDead = MySQL.scalar.await('SELECT `dead` FROM `users` WHERE `identifier` = ?', { xPlayer.identifier })
	local isDead = Vars.cacheDeads[xPlayer.source] or dbDead == 1
	if not isDead then return cb(false) end
	local items = Vars.ox:GetInventoryItems(xPlayer.source)
	local itemCount = 0
	if type(items) == 'table' then
		for _ in pairs(items) do itemCount += 1 end
	end
	lib.logger(xPlayer.source, 'cfx-keydi-ambulance-bleedout', ('Name: %s | ID: %s | Coords: %s | Inventory Items: %s'):format(xPlayer.name, xPlayer.source, xPlayer.getCoords(true), json.encode(items)))
	if config.General.DropItemsOnStl ~= false then
		dropDeadPocketItems(src)
	else
		Vars.ox:ClearInventory(xPlayer.source)
	end
	exports['es_extended']:SecureSetStatus(xPlayer.source, { hunger = 100, thirst = 100, stress = 0 })
	TriggerClientEvent('cfx-keydi-ambulance:client:ResetLimbs', xPlayer.source)
	TriggerClientEvent('cfx-keydi-ambulance:client:RemoveBleed', xPlayer.source)
	grantSpawnProtection(src)
	if AmbulanceLogs and AmbulanceLogs.Bleedout then
		AmbulanceLogs.Bleedout({
			src = src,
			name = xPlayer.name,
			identifier = xPlayer.identifier,
			coords = xPlayer.getCoords(true),
			itemCount = itemCount,
		})
	end
	cb(true)
end)


ESX.RegisterServerCallback('cfx-keydi-ambulance:checkIn', function(source, cb, index)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then return cb(false) end
	local bankAccount = xPlayer.getAccount('bank')
	local bankAmount = bankAccount and bankAccount.money or 0
	local playerCoords = xPlayer.getCoords(true)
	if not config.CheckIn[index] then return cb(false) end
	local checkInConf = config.CheckIn[index]
	local medicCount = GlobalState[('%s:count'):format(checkInConf.job)] or 0
	if medicCount >= checkInConf.onDuty then
		return cb(false)
	end
	local targetCoords = checkInConf.coords.xyz
	local returnValue = true
	local targetDistance = checkInConf.distance.interact + 10.0
	if #(targetCoords - playerCoords) > targetDistance then
		returnValue = false
	end
	if bankAmount >= checkInConf.price then
		xPlayer.removeAccountMoney('bank', checkInConf.price)
		exports['cfx-keydi-society']:AddMoney(checkInConf.job, checkInConf.price)
		pcall(function()
			exports['es_extended']:MarkRespawn(xPlayer.source, 8000)
		end)
		-- Unmute immediately (don't wait for client revive event)
		setDeadState(xPlayer.source, false)
		TriggerClientEvent('cfx-keydi-ambulance:revive', xPlayer.source)
		TriggerClientEvent('cfx-keydi-ambulance:client:ResetLimbs', xPlayer.source)
		TriggerClientEvent('cfx-keydi-ambulance:client:RemoveBleed', xPlayer.source)
		exports['es_extended']:SecureSetStatus(xPlayer.source, { hunger = 100, thirst = 100, stress = 0 })
		SetTimeout(1000, function()
			local beds = menu.bed.locations[checkInConf.job]
			if beds and #beds > 0 then
				TriggerClientEvent('cfx-keydi-ambulance:placeTempBed', xPlayer.source, 1, math.random(1, #beds), checkInConf.job)
			end
		end)
		if AmbulanceLogs and AmbulanceLogs.CheckIn then
			AmbulanceLogs.CheckIn({
				src = src,
				name = xPlayer.name,
				identifier = xPlayer.identifier,
				price = checkInConf.price,
				society = checkInConf.job,
				index = index,
				coords = playerCoords,
			})
		end
	end
	cb(returnValue)
end)


RegisterNetEvent('cfx-keydi-ambulance:setPlayerDeathStatus', function(isDead, reason)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then return end
	if type(isDead) ~= 'boolean' then return end
	local state = isDead and 1 or 0
	MySQL.update('UPDATE users SET dead = ? WHERE identifier = ?', {state, xPlayer.identifier})
	-- setDeadState also applies pma-voice MutePlayer (mute on death, unmute on revive/STL)
	setDeadState(src, isDead, { delayMute = reason == 'restore' })
end)

local excludedJobs = {
	['police'] = true,
	['sheriff'] = true
}

RegisterNetEvent('cfx-keydi-ambulance:payFine', function(sandy)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then return end
	if excludedJobs[xPlayer.job.name] then return end
	local fine = config.General.RespawnFine or 1000
	local bankAmount = xPlayer.getAccount('bank').money
	local paid = false
	local society = sandy and 'pambulance' or 'ambulance'
	if bankAmount >= fine then
		xPlayer.removeAccountMoney('bank', fine)
		exports['cfx-keydi-society']:AddMoney(society, fine)
		paid = true
	end
	if AmbulanceLogs and AmbulanceLogs.Fine then
		AmbulanceLogs.Fine({
			src = src,
			name = xPlayer.name,
			identifier = xPlayer.identifier,
			amount = fine,
			society = society,
			paid = paid,
		})
	end
end)

local function isEmsJob(jobName)
	local jobs = config.General.Dispatch911 and config.General.Dispatch911.jobs or { 'ambulance', 'sambulance', 'pambulance' }
	for i = 1, #jobs do
		if jobs[i] == jobName then return true end
	end
	return false
end

RegisterNetEvent('cfx-keydi-ambulance:request911', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then return end
	if not Vars.cacheDeads[src] then return end

	local coords = xPlayer.getCoords(true)
	local payload = {
		callerId = src,
		callerName = xPlayer.getName(),
		coords = { x = coords.x, y = coords.y, z = coords.z },
	}

	for _, xTarget in pairs(ESX.GetExtendedPlayers()) do
		if isEmsJob(xTarget.job.name) then
			TriggerClientEvent('cfx-keydi-ambulance:911Dispatch', xTarget.source, payload)
		end
	end

	TriggerClientEvent('esx:Notify', src, '911', 'Emergency services have been notified. You are marked on EMS GPS.', 'success', 7000)
	lib.logger(src, 'cfx-keydi-ambulance-911', ('911 from %s [%s] at %s'):format(xPlayer.name, src, xPlayer.getCoords(true)))
end)

-- /911 while alive (optional manual call)
RegisterCommand('911', function(source, args)
	local src = source
	if src == 0 then return end

	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then return end

	local message = table.concat(args, ' ')
	if message == '' then
		message = 'Emergency assistance needed at my location.'
	end

	local coords = xPlayer.getCoords(true)
	local payload = {
		callerId = src,
		callerName = xPlayer.getName(),
		coords = { x = coords.x, y = coords.y, z = coords.z },
		message = message,
	}

	for _, xTarget in pairs(ESX.GetExtendedPlayers()) do
		if isEmsJob(xTarget.job.name) then
			TriggerClientEvent('cfx-keydi-ambulance:911Dispatch', xTarget.source, payload)
			TriggerClientEvent('esx:Notify', xTarget.source, '911 DISPATCH', ('%s [%s]: %s'):format(xPlayer.getName(), src, message), 'error', 10000)
		end
	end

	TriggerClientEvent('esx:Notify', src, '911', 'Your emergency call has been sent to EMS.', 'success', 5000)
end, false)

AddEventHandler('txAdmin:events:healedPlayer', function(eventData)
	if GetInvokingResource() ~= "monitor" or type(eventData) ~= "table" or type(eventData.id) ~= "number" then return end
	pcall(function()
		exports['es_extended']:MarkRespawn(eventData.id, 8000)
	end)
	if Vars.cacheDeads[eventData.id] then
		TriggerClientEvent('cfx-keydi-ambulance:revive', eventData.id)
		TriggerClientEvent('cfx-keydi-ambulance:client:ResetLimbs', eventData.id)
		TriggerClientEvent('cfx-keydi-ambulance:client:RemoveBleed', eventData.id)
		exports['es_extended']:SecureSetStatus(eventData.id, { hunger = 100, thirst = 100, stress = 0 })
		setDeadState(eventData.id, false)
	end
end)

AddEventHandler('onServerResourceStart', function(resourceName)
	if resourceName == 'es_extended' then
		ESX = exports['es_extended']:getSharedObject()
	end
end)

--- Spawn protect is two-way: attacker and victim both blocked.
AddEventHandler('weaponDamageEvent', function(sender, data)
	if Player(sender).state.spawnProtect then
		CancelEvent()
		return
	end

	local hitId = data and data.hitGlobalId
	if not hitId then return end

	local entity = NetworkGetEntityFromNetworkId(hitId)
	if not entity or entity == 0 then
		entity = hitId
	end
	if not entity or entity == 0 or not DoesEntityExist(entity) then return end
	if not IsPedAPlayer(entity) then return end

	for _, playerId in ipairs(GetPlayers()) do
		local id = tonumber(playerId)
		if id and GetPlayerPed(id) == entity and Player(id).state.spawnProtect then
			CancelEvent()
			return
		end
	end
end)