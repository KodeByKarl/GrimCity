ESX = ESX or exports["es_extended"]:getSharedObject()

ServerLocations = ServerLocations or {}

local playerLocations = {} -- [src] = locationId
local previousPublicId = {} -- [src] = last public realm before a job instance
local lastSwitchAt = {} -- [src] = os.time()

local function DebugLog(msg)
    if ConfigServerLocations.Debug then
        print(("[ServerLocations] %s"):format(msg))
    end
end

local function Notify(src, msg, nType)
    TriggerClientEvent("esx:showNotification", src, msg, nType or "info")
end

local function GetMaxClients()
    local max = tonumber(GetConvarInt("sv_maxclients", 0)) or 0
    if max < 1 then
        max = tonumber(GetConvarInt("sv_maxClients", 0)) or 0
    end
    if max < 1 then
        max = 32
    end
    return max
end

--- Public locations use the whole-server slot cap. Job instances may be smaller, never larger.
local function GetLocationMaxPlayers(loc, kind)
    local serverMax = GetMaxClients()
    if kind ~= "job" then
        return serverMax
    end
    local configured = tonumber(loc and loc.maxPlayers) or serverMax
    if configured < 1 then
        return serverMax
    end
    if configured > serverMax then
        return serverMax
    end
    return configured
end

local function CountPlayersInBucket(bucket)
    local n = 0
    local players = GetPlayers()
    for i = 1, #players do
        local id = tonumber(players[i])
        if id and GetPlayerRoutingBucket(id) == bucket then
            n = n + 1
        end
    end
    return n
end

local function GetLockReason(src)
    local state = Player(src).state
    if not state then return nil end

    if ConfigServerLocations.LockInJail and (state.isJailed or state.inJail or state.comserv) then
        return "In Jail / Community Service"
    end
    if ConfigServerLocations.LockInArena and state.inArena then
        return "Inside Arena Instance"
    end
    return nil
end

local function IsInSafezone(src)
    local state = Player(src).state
    if state then
        if state.inSafeZone == true or state.inSafezone == true then
            return true
        end
        if state.inSafeZone == false or state.inSafezone == false then
            return false
        end
    end
    return true
end

function ServerLocations.GetPlayerId(src)
    return playerLocations[src] or ConfigServerLocations.DefaultId or "server1"
end

function ServerLocations.GetPlayerLocation(src)
    return ConfigServerLocations.GetById(ServerLocations.GetPlayerId(src))
end

function ServerLocations.PlayerHasFunction(src, fn)
    return ConfigServerLocations.CanUseFunction(fn, src)
end

local function BuildLocationPayload(loc, kind, src)
    local isCurrent = loc.id == ServerLocations.GetPlayerId(src)
    local online = CountPlayersInBucket(loc.bucket or 0)
    local maxPlayers = GetLocationMaxPlayers(loc, kind)
    local status = loc.status or "ONLINE"
    if online >= maxPlayers then
        status = "FULL"
    end
    return {
        id = loc.id,
        name = loc.name,
        tag = loc.tag,
        type = loc.type,
        description = loc.description,
        maxPlayers = maxPlayers,
        status = status,
        functions = loc.functions or {},
        isCurrent = isCurrent,
        onlinePlayers = online,
        ping = isCurrent and "16 ms" or "18 ms",
        kind = kind,
    }
end

function ServerLocations.GetServersData(src)
    local publicServers = {}
    local sideJobServers = {}

    for i = 1, #ConfigServerLocations.PublicServers do
        publicServers[#publicServers + 1] = BuildLocationPayload(ConfigServerLocations.PublicServers[i], "public", src)
    end

    for i = 1, #ConfigServerLocations.SideJobServers do
        sideJobServers[#sideJobServers + 1] = BuildLocationPayload(ConfigServerLocations.SideJobServers[i], "job", src)
    end

    local current = ServerLocations.GetPlayerLocation(src)
    local lockReason = GetLockReason(src)
    local inSafezone = IsInSafezone(src)

    return {
        publicServers = publicServers,
        sideJobServers = sideJobServers,
        currentServerId = ServerLocations.GetPlayerId(src),
        currentType = current and current.type or "main",
        maxClients = GetMaxClients(),
        inSafezone = inSafezone,
        isLocked = lockReason ~= nil,
        lockReason = lockReason or (ConfigServerLocations.RequireSafezone and not inSafezone and "Outside Safezone" or nil),
    }
end

local function ApplyRouting(src, loc)
    local bucket = tonumber(loc.bucket) or 0
    SetPlayerRoutingBucket(src, bucket)

    local ped = GetPlayerPed(src)
    if ped and ped ~= 0 then
        local veh = GetVehiclePedIsIn(ped, false)
        if veh and veh ~= 0 then
            SetEntityRoutingBucket(veh, bucket)
        end
    end

    local state = Player(src).state
    state:set("grimServerId", loc.id, true)
    state:set("grimServerType", loc.type or "main", true)
    state:set("inJobInstance", loc.type == "job", true)
end

local function TeleportPlayer(src, loc)
    if not ConfigServerLocations.TeleportOnSwitch then return end
    local spawn = loc.spawn
    if not spawn then return end

    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return end

    if KeydiElectron and KeydiElectron.Allow then
        KeydiElectron.Allow(src, { "AntiTeleport", "Teleport", "Noclip" }, 6000)
    end

    local veh = GetVehiclePedIsIn(ped, false)
    if veh and veh ~= 0 then
        SetEntityCoords(veh, spawn.x, spawn.y, spawn.z, false, false, false, false)
        SetEntityHeading(veh, spawn.w or 0.0)
    else
        SetEntityCoords(ped, spawn.x, spawn.y, spawn.z, false, false, false, false)
        SetEntityHeading(ped, spawn.w or 0.0)
    end
end

local function ApplyLocation(src, loc, opts)
    opts = opts or {}
    playerLocations[src] = loc.id
    ApplyRouting(src, loc)

    if opts.teleport then
        TeleportPlayer(src, loc)
    end

    TriggerClientEvent("cfx-keydi-serverlocations:client:applied", src, {
        id = loc.id,
        name = loc.name,
        tag = loc.tag,
        type = loc.type,
        bucket = loc.bucket,
        functions = loc.functions or {},
    })

    DebugLog(("%s [%s] -> %s (bucket %s)"):format(GetPlayerName(src) or "?", src, loc.id, tostring(loc.bucket)))
end

local function ValidateSwitch(src, locationId, opts)
    opts = opts or {}
    local loc, kind = ConfigServerLocations.GetById(locationId)
    if not loc then
        return false, "Unknown server location."
    end

    local currentId = ServerLocations.GetPlayerId(src)
    if not opts.allowSame and currentId == loc.id then
        return false, "You are already on this server."
    end

    if not opts.skipCooldown then
        local now = os.time()
        if lastSwitchAt[src] and (now - lastSwitchAt[src]) < (ConfigServerLocations.SwitchCooldown or 8) then
            return false, "Please wait a moment before switching again."
        end
    end

    local lockReason = GetLockReason(src)
    if lockReason then
        return false, ("Server switching locked while %s."):format(lockReason)
    end

    if ConfigServerLocations.RequireSafezone and not opts.skipSafezone and not IsInSafezone(src) then
        return false, "Server switching locked! You must be inside a Safezone."
    end

    local online = CountPlayersInBucket(loc.bucket or 0)
    local maxPlayers = GetLocationMaxPlayers(loc, kind)
    if online >= maxPlayers then
        return false, "That server is full."
    end

    return true, loc, kind
end

function ServerLocations.SwitchPlayer(src, locationId, opts)
    local ok, locOrMsg, kind = ValidateSwitch(src, locationId, opts)
    if not ok then
        return false, locOrMsg
    end

    local currentId = ServerLocations.GetPlayerId(src)
    local currentLoc = ConfigServerLocations.GetById(currentId)
    if currentLoc and currentLoc.type ~= "job" and kind == "job" then
        previousPublicId[src] = currentId
    elseif kind == "public" then
        previousPublicId[src] = locOrMsg.id
    end

    lastSwitchAt[src] = os.time()
    return true, locOrMsg
end

exports("GetPlayerId", ServerLocations.GetPlayerId)
exports("GetPlayerLocation", ServerLocations.GetPlayerLocation)
exports("PlayerHasFunction", ServerLocations.PlayerHasFunction)
exports("GetServersData", ServerLocations.GetServersData)
exports("SwitchPlayer", ServerLocations.SwitchPlayer)

ESX.RegisterServerCallback("cfx-keydi-serverlocations:server:getServersData", function(source, cb)
    cb(ServerLocations.GetServersData(source))
end)

RegisterNetEvent("cfx-keydi-serverlocations:server:requestSwitch", function(locationId)
    local src = source
    if type(src) ~= "number" or src < 1 then return end

    local ok, locOrMsg = ValidateSwitch(src, locationId)
    if not ok then
        TriggerClientEvent("cfx-keydi-serverlocations:client:switchFailed", src, locOrMsg)
        return
    end

    TriggerClientEvent("cfx-keydi-serverlocations:client:prepareSwitch", src, {
        id = locOrMsg.id,
        name = locOrMsg.name,
        type = locOrMsg.type,
        bucket = locOrMsg.bucket,
    })
end)

RegisterNetEvent("cfx-keydi-serverlocations:server:finishSwitch", function(locationId)
    local src = source
    if type(src) ~= "number" or src < 1 then return end

    local ok, locOrMsg = ServerLocations.SwitchPlayer(src, locationId)
    if not ok then
        TriggerClientEvent("cfx-keydi-serverlocations:client:switchFailed", src, locOrMsg)
        return
    end

    ApplyLocation(src, locOrMsg, { teleport = ConfigServerLocations.TeleportOnSwitch })
end)

local function AssignDefault(src, teleport)
    local loc = ConfigServerLocations.GetById(ConfigServerLocations.DefaultId)
    if not loc then return end
    playerLocations[src] = loc.id
    previousPublicId[src] = loc.id
    ApplyRouting(src, loc)
    if teleport then
        TeleportPlayer(src, loc)
    end
    TriggerClientEvent("cfx-keydi-serverlocations:client:sync", src, {
        id = loc.id,
        name = loc.name,
        tag = loc.tag,
        type = loc.type,
        bucket = loc.bucket,
        functions = loc.functions or {},
    })
end

AddEventHandler("esx:playerLoaded", function(playerId)
    CreateThread(function()
        Wait(500)
        if GetPlayerName(playerId) then
            AssignDefault(playerId, false)
        end
    end)
end)

AddEventHandler("playerDropped", function()
    local src = source
    playerLocations[src] = nil
    previousPublicId[src] = nil
    lastSwitchAt[src] = nil
end)

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    CreateThread(function()
        Wait(1000)
        local players = GetPlayers()
        for i = 1, #players do
            local id = tonumber(players[i])
            if id then
                AssignDefault(id, false)
            end
        end
    end)
end)
