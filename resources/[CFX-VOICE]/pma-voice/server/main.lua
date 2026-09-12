voiceData = {}
radioData = {}
callData = {}

-- Free mumble channel pool. Server IDs climb (119, 349, ...) past mumble's
-- usable channel range; mapping sid→channel was leaving players at channel=-1.
local mappedChannels = {}

local function firstFreeChannel()
	local max = math.max(GetConvarInt('sv_maxclients', 48) + 128, 256)
	for i = 1, max do
		if not mappedChannels[i] then
			return i
		end
	end
	return 0
end

function defaultTable(source)
	handleStateBagInitilization(source)
	return {
		radio = 0,
		call = 0,
		lastRadio = 0,
		lastCall = 0
	}
end

function handleStateBagInitilization(source)
	local plyState = Player(source).state
	if not plyState.pmaVoiceInit then
		plyState:set('radio', GetConvarInt('voice_defaultRadioVolume', 30), true)
		plyState:set('phone', GetConvarInt('voice_defaultPhoneVolume', 60), true)
		plyState:set('proximity', {}, true)
		plyState:set('callChannel', 0, true)
		plyState:set('radioChannel', 0, true)
		plyState:set('voiceIntent', 'speech', true)
		plyState:set('pmaVoiceInit', true, false)
	end

	-- Always (re)assign a free mumble channel — required after drop/rejoin.
	local previous = plyState.assignedChannel
	if previous and mappedChannels[previous] == source then
		mappedChannels[previous] = nil
	end

	local assignedChannel = firstFreeChannel()
	plyState:set('assignedChannel', assignedChannel, true)
	if assignedChannel ~= 0 then
		mappedChannels[assignedChannel] = source
		logger.verbose('[channel] Assigned %s to mumble channel %s', source, assignedChannel)
	else
		logger.error('[channel] Failed to find a free mumble channel for %s', source)
	end
end

Citizen.CreateThread(function()
	local plyTbl = GetPlayers()
	for i = 1, #plyTbl do
		local ply = tonumber(plyTbl[i])
		voiceData[ply] = defaultTable(ply)
	end

	Wait(5000)

	local nativeAudio = GetConvar('voice_useNativeAudio', 'false')
	local _3dAudio = GetConvar('voice_use3dAudio', 'false')
	local _2dAudio = GetConvar('voice_use2dAudio', 'false')
	local sendingRangeOnly = GetConvar('voice_useSendingRangeOnly', 'false')
	local gameVersion = GetConvar('gamename', 'fivem')

	if
		nativeAudio == 'false'
		and _3dAudio == 'false'
		and _2dAudio == 'false'
	then
		if gameVersion == 'fivem' then
			SetConvarReplicated('voice_useNativeAudio', 'true')
			if sendingRangeOnly == 'false' then
				SetConvarReplicated('voice_useSendingRangeOnly', 'true')
			end
			logger.info('No convars detected for voice mode, defaulting to \'setr voice_useNativeAudio true\' and \'setr voice_useSendingRangeOnly true\'')
		else
			SetConvarReplicated('voice_use3dAudio', 'true')
			if sendingRangeOnly == 'false' then
				SetConvarReplicated('voice_useSendingRangeOnly', 'true')
			end
			logger.info('No convars detected for voice mode, defaulting to \'setr voice_use3dAudio true\' and \'setr voice_useSendingRangeOnly true\'')
		end
	elseif sendingRangeOnly == 'false' then
		logger.warn('It\'s recommended to have \'voice_useSendingRangeOnly\' set to true you can do that with \'setr voice_useSendingRangeOnly true\', this prevents players who directly join the mumble server from broadcasting to players.')
	end

	if GetConvar('gamename', 'fivem') == 'rdr3' then
		if nativeAudio == 'true' then
			logger.warn("RedM doesn't currently support native audio, automatically switching to 3d audio. This also means that submixes will not work.")
			SetConvarReplicated('voice_useNativeAudio', 'false')
			SetConvarReplicated('voice_use3dAudio', 'true')
		end
	end

	local radioVolume = GetConvarInt("voice_defaultRadioVolume", 30)
	local phoneVolume = GetConvarInt("voice_defaultPhoneVolume", 60)

	if
		radioVolume == 0 or radioVolume == 1 or
		phoneVolume == 0 or phoneVolume == 1
	then
		SetConvarReplicated("voice_defaultRadioVolume", 30)
		SetConvarReplicated("voice_defaultPhoneVolume", 60)
		for i = 1, 5 do
			Wait(5000)
			logger.warn("`voice_defaultRadioVolume` or `voice_defaultPhoneVolume` have their value set as a float, this is going to automatically be fixed but please update your convars.")
		end
	end
end)

AddEventHandler('playerJoining', function()
	if not voiceData[source] then
		voiceData[source] = defaultTable(source)
	end
end)

AddEventHandler("playerDropped", function()
	local source = source
	local mappedChannel = Player(source).state.assignedChannel

	if voiceData[source] then
		local plyData = voiceData[source]

		if plyData.radio ~= 0 then
			removePlayerFromRadio(source, plyData.radio)
		end

		if plyData.call ~= 0 then
			removePlayerFromCall(source, plyData.call)
		end

		voiceData[source] = nil
	end

	if mappedChannel and mappedChannels[mappedChannel] == source then
		mappedChannels[mappedChannel] = nil
		logger.verbose('[channel] Unassigned %s from mumble channel %s', source, mappedChannel)
	end
end)

if GetConvarInt('voice_externalDisallowJoin', 0) == 1 then
	AddEventHandler('playerConnecting', function(_, _, deferral)
		deferral.defer()
		Wait(0)
		deferral.done('This server is not accepting connections.')
	end)
end

function isValidPlayer(source)
	return voiceData[source]
end
exports('isValidPlayer', isValidPlayer)

function getPlayersInRadioChannel(channel)
	local returnChannel = radioData[channel]
	if returnChannel then
		return returnChannel
	end
	return {}
end
exports('getPlayersInRadioChannel', getPlayersInRadioChannel)
exports('GetPlayersInRadioChannel', getPlayersInRadioChannel)

--- Ambulance death mute. Does not disconnect Mumble; only silences the player.
exports('MutePlayer', function(src, muted)
	src = tonumber(src)
	if not src or src <= 0 then return false end
	muted = muted and true or false
	MumbleSetPlayerMuted(src, muted)
	Player(src).state:set('muted', muted, true)
	return true
end)

--- Reassign a free mumble channel + force client rebind. Unmutes unless still marked dead.
local function resetPlayerVoiceChannel(src)
	src = tonumber(src)
	if not src or src <= 0 or not GetPlayerName(src) then
		return false, 'invalid player'
	end

	if not voiceData[src] then
		voiceData[src] = defaultTable(src)
	else
		handleStateBagInitilization(src)
	end

	-- Stuck mute from death/reconnect often blocks talk even after channel bind.
	local isDead = Player(src).state.dead == true
	if not isDead then
		MumbleSetPlayerMuted(src, false)
		Player(src).state:set('muted', false, true)
	end

	local channel = Player(src).state.assignedChannel
	TriggerClientEvent('pma-voice:client:forceRebind', src, channel)
	logger.info('[channel] Reset voice for %s (%s) -> assignedChannel=%s', GetPlayerName(src), src, tostring(channel))
	return true, channel
end

exports('ResetPlayerChannel', resetPlayerVoiceChannel)
exports('resetPlayerChannel', resetPlayerVoiceChannel)

-- Console: resetvoice 119
-- In-game admin: /resetvoice 119  (ace: command.resetvoice)
RegisterCommand('resetvoice', function(source, args)
	local tgt = tonumber(args[1])
	if source ~= 0 then
		if not IsPlayerAceAllowed(source, 'command.resetvoice') and not IsPlayerAceAllowed(source, 'command') then
			return
		end
		if not tgt then
			tgt = source
		end
	elseif not tgt then
		print('^1[pma-voice]^7 Usage: resetvoice <serverId>')
		return
	end

	local ok, channelOrErr = resetPlayerVoiceChannel(tgt)
	if source == 0 then
		if ok then
			print(('[pma-voice] Reset %s -> channel %s'):format(tgt, tostring(channelOrErr)))
		else
			print(('[pma-voice] Failed: %s'):format(tostring(channelOrErr)))
		end
	else
		if ok then
			TriggerClientEvent('chat:addMessage', source, {
				args = { 'VOICE', ('Reset voice for #%s (channel %s)'):format(tgt, tostring(channelOrErr)) }
			})
		else
			TriggerClientEvent('chat:addMessage', source, {
				args = { 'VOICE', ('Failed: %s'):format(tostring(channelOrErr)) }
			})
		end
	end
end, true)

-- Console only: reset every online player after a bad voice session
RegisterCommand('resetvoiceall', function(source)
	if source ~= 0 then return end
	local players = GetPlayers()
	local count = 0
	for i = 1, #players do
		local sid = tonumber(players[i])
		if sid and resetPlayerVoiceChannel(sid) then
			count += 1
		end
	end
	print(('[pma-voice] Reset voice channels for %s players'):format(count))
end, true)
