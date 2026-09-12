local bindLock = false
local creationPending = false
isInitialized = false

function refreshPlayerServerId()
	local sid = GetPlayerServerId(PlayerId())
	if sid and sid > 0 then
		playerServerId = sid
	end
	return playerServerId
end

local function getAssignedChannel()
	local channel = LocalPlayer.state and LocalPlayer.state.assignedChannel
	channel = tonumber(channel)
	if channel and channel > 0 then
		return channel
	end
	return nil
end

local function waitForAssignedChannel(timeoutMs)
	local existing = getAssignedChannel()
	if existing then
		return existing
	end
	local deadline = GetGameTimer() + (timeoutMs or 3000)
	while GetGameTimer() < deadline do
		local channel = getAssignedChannel()
		if channel then
			return channel
		end
		Wait(50)
	end
	return getAssignedChannel()
end

local function currentChannel()
	local sid = refreshPlayerServerId()
	if not sid or sid <= 0 then
		return -1
	end
	return MumbleGetVoiceChannelFromServerId(sid)
end

local function isIdentityOpen()
	if GetResourceState('cfx-keydi-ui') ~= 'started' then
		return false
	end
	local ok, open = pcall(function()
		return exports['cfx-keydi-ui']:IsIdentityOpen()
	end)
	return ok and open == true
end

local function isCreationBlocked()
	return creationPending or isIdentityOpen()
end

local function isVoiceReady()
	local assigned = getAssignedChannel()
	if not assigned then return false end
	return currentChannel() == assigned
end

--- Upstream handleInitialState: set channel and wait until it sticks.
--- Never call NetworkSetVoiceActive here — that cancels an in-flight Mumble connect.
function handleInitialState()
	refreshPlayerServerId()
	local assigned = waitForAssignedChannel(3000)
	if not assigned then
		logger.warn('No assignedChannel yet sid=%s', tostring(playerServerId))
		return false
	end

	local voiceModeData = Cfg.voiceModes[mode]
	MumbleSetTalkerProximity(voiceModeData[1] + 0.0)
	MumbleClearVoiceTarget(voiceTarget)
	MumbleSetVoiceTarget(voiceTarget)
	pcall(MumbleCreateChannel, assigned)
	MumbleSetVoiceChannel(assigned)

	local deadline = GetGameTimer() + 8000
	while tonumber(MumbleGetVoiceChannelFromServerId(playerServerId)) ~= assigned do
		if GetGameTimer() > deadline then
			logger.warn('Channel bind timed out sid=%s assigned=%s channel=%s',
				tostring(playerServerId), tostring(assigned), tostring(currentChannel()))
			return false
		end
		MumbleSetVoiceChannel(assigned)
		Wait(100)
	end

	isInitialized = true
	MumbleAddVoiceTargetChannel(voiceTarget, assigned)
	addNearbyPlayers()
	return true
end

local function bindChannel(reason)
	if isCreationBlocked() then
		return false
	end
	if isVoiceReady() then
		return true
	end
	if bindLock then
		return false
	end

	bindLock = true
	local ok, result = pcall(handleInitialState)
	bindLock = false

	if not ok then
		isInitialized = false
		logger.warn('Channel bind error: %s', tostring(result))
		return false
	end
	if not result then
		isInitialized = false
		return false
	end

	logger.log('Finished connection logic (channel %s)', tostring(getAssignedChannel()))
	return true
end

--- Bind only. FiveM connects Mumble by itself. Do not poke NetworkSetVoiceActive.
function reinitVoice(reason, opts)
	opts = opts or {}
	CreateThread(function()
		if (tonumber(opts.delay) or 0) > 0 then
			Wait(tonumber(opts.delay))
		end
		if opts.waitForCreation then
			local waitUntil = GetGameTimer() + (tonumber(opts.creationTimeout) or 180000)
			while isCreationBlocked() and GetGameTimer() < waitUntil do
				Wait(500)
			end
		end
		if isCreationBlocked() or isVoiceReady() then return end
		bindChannel(reason or 'reinit')
	end)
end

local function startJoinHandshake(reason)
	if isCreationBlocked() then return end
	reinitVoice(reason or 'join', { delay = 0 })
end

exports('reinitVoice', function(reason)
	reinitVoice(type(reason) == 'string' and reason or 'export', {
		delay = 0,
		waitForCreation = isCreationBlocked(),
	})
end)

exports('setCreationPending', function(pending)
	creationPending = pending and true or false
end)

exports('startJoinHandshake', function(reason)
	startJoinHandshake(type(reason) == 'string' and reason or 'export')
end)

AddEventHandler('mumbleConnected', function(address, isReconnecting)
	logger.info('Connected to mumble server with address of %s, is this a reconnect %s',
		GetConvarInt('voice_hideEndpoints', 1) == 1 and 'HIDDEN' or address, isReconnecting)

	logger.log('Connecting to mumble, setting targets.')
	local voiceModeData = Cfg.voiceModes[mode]
	LocalPlayer.state:set('proximity', {
		index = mode,
		distance = voiceModeData[1],
		mode = voiceModeData[2],
	}, true)

	handleInitialState()
	if isInitialized then
		logger.log('Finished connection logic (channel %s)', tostring(getAssignedChannel()))
	end
end)

AddEventHandler('mumbleDisconnected', function(address)
	isInitialized = false
	logger.info('Disconnected from mumble server with address of %s',
		GetConvarInt('voice_hideEndpoints', 1) == 1 and 'HIDDEN' or address)
end)

AddEventHandler('pma-voice:settingsCallback', function(cb)
	cb(Cfg)
end)

AddEventHandler('esx:onPlayerSpawn', function()
	startJoinHandshake('esx:onPlayerSpawn')
end)

RegisterNetEvent('esx:playerLoaded', function(_, isNew)
	if isNew then
		creationPending = true
		return
	end
	startJoinHandshake('esx:playerLoaded')
end)

RegisterNetEvent('esx_identity:showRegisterIdentity', function()
	creationPending = true
end)

RegisterNetEvent('pma-voice:client:joinHandshake')
AddEventHandler('pma-voice:client:joinHandshake', function()
	startJoinHandshake('server')
end)

RegisterNetEvent('pma-voice:client:creationFinished')
AddEventHandler('pma-voice:client:creationFinished', function()
	creationPending = false
	startJoinHandshake('creation-finished')
end)

RegisterCommand('voicefix', function()
	creationPending = false
	bindChannel('command')
end, false)

RegisterNetEvent('pma-voice:client:forceRebind')
AddEventHandler('pma-voice:client:forceRebind', function(assignedChannel)
	creationPending = false
	isInitialized = false
	if assignedChannel and tonumber(assignedChannel) and tonumber(assignedChannel) > 0 then
		LocalPlayer.state:set('assignedChannel', tonumber(assignedChannel), false)
	end
	bindChannel('force-rebind')
end)

CreateThread(function()
	local sid = 0
	while sid <= 0 do
		sid = GetPlayerServerId(PlayerId())
		Wait(200)
	end
	AddStateBagChangeHandler('assignedChannel', ('player:%s'):format(sid), function(_, _, value)
		local channel = tonumber(value)
		if not channel or channel <= 0 or isCreationBlocked() then return end
		CreateThread(function()
			Wait(200)
			if isVoiceReady() then return end
			bindChannel('assignedChannel-changed')
		end)
	end)
end)
