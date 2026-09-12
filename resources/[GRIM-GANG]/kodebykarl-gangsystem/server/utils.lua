local ESX = exports['es_extended']:getSharedObject()
local RateLimits = {}

Gang = Gang or {}

function Gang.Notify(src, msg, nType)
    TriggerClientEvent('esx:showNotification', src, msg, nType or 'info')
end

function Gang.IsRateLimited(src, cooldownMs)
    if not src then return true end
    local now = GetGameTimer()
    local last = RateLimits[src]
    if last and (now - last) < (cooldownMs or 1000) then
        return true
    end
    RateLimits[src] = now
    return false
end

AddEventHandler('playerDropped', function()
    RateLimits[source] = nil
end)

function Gang.NormalizeName(name)
    if not name then return '' end
    local cleanName = tostring(name):lower()
    if cleanName:sub(1, 8) == 'society_' then
        return cleanName:sub(9)
    end
    return cleanName
end

function Gang.GetPlayerGang(xPlayer)
    if not xPlayer then return nil end
    local gang = xPlayer.getGang and xPlayer.getGang() or xPlayer.gang
    if type(gang) ~= 'table' or not gang.name then return nil end
    return gang
end

function Gang.RequireTurfRegion(src)
    if GangRegion.Allowed(src) then
        return true
    end
    Gang.Notify(src, 'Gang bases are only available on Region 1. Open Control Center (F5) → Regions.', 'error')
    return false
end

function Gang.IsMember(xPlayer, gangName)
    local gang = Gang.GetPlayerGang(xPlayer)
    if not gang then return false end
    return Gang.NormalizeName(gang.name) == Gang.NormalizeName(gangName), gang
end

function Gang.IsBoss(xPlayer, gangName)
    local isMember, gang = Gang.IsMember(xPlayer, gangName)
    if not isMember then return false, gang end

    local key = Gang.NormalizeName(gangName)
    local gangConfig = Config.Gangs[key] or Config.Gangs[gangName]
    local minGrade = (gangConfig and gangConfig.bossGrade) or 1
    if gang.grade_name then
        local name = string.lower(tostring(gang.grade_name)):gsub('%s+', '_')
        if name == 'boss' or name == 'patron' or name == 'patrona' or name == 'el_patron'
            or name == 'underboss' or name == 'supremo' or name == 'pioneers' or name == 'forensics' or name == 'detective' then
            return true, gang
        end
    end
    return (tonumber(gang.grade) or 0) >= minGrade, gang
end

-- Legacy name kept for callers; boss ops are iPad Organization (no world marker).
function Gang.IsNearBossMenu(_source, _gangName, _maxDist)
    return true
end

function Gang.LogExploit(source, action, details)
    print(('[SECURITY ALERT] [cfx-keydi-gang] Player %s (ID: %s) failed security check on "%s": %s')
        :format(GetPlayerName(source) or 'Unknown', tostring(source), action, tostring(details)))
    if GangLogs and GangLogs.Exploit then
        GangLogs.Exploit({ src = source, action = action, details = details })
    end
end

--- Returns xBoss, gangKey or nil after rate-limit / boss checks (iPad Organization).
function Gang.AssertBossAtMenu(src, gangName, action)
    if not src or src <= 0 then return end
    if not Gang.RequireTurfRegion(src) then return end
    if Gang.IsRateLimited(src) then
        Gang.Notify(src, 'Please wait before trying again!', 'warning')
        return
    end

    local xBoss = ESX.GetPlayerFromId(src)
    if not xBoss then return end

    if not Gang.IsBoss(xBoss, gangName) then
        Gang.LogExploit(src, action, 'unauthorized non-boss attempt')
        Gang.Notify(src, 'Only gang bosses can do this!', 'error')
        return
    end

    return xBoss, Gang.NormalizeName(gangName)
end

--[[
    Discord role gate + offline hire helpers
]]
local DISCORD_API = 'https://discord.com/api/v10'
---@type table<string, { roles: table, expires: number }>
local memberRoleCache = {}

local function getHireConfig()
    return Config.DiscordHire or {}
end

local function getHireGuildId()
    local cfg = getHireConfig()
    if cfg.GuildID and cfg.GuildID ~= '' then
        return tostring(cfg.GuildID)
    end
    if Config.Logs and Config.Logs.GuildID and Config.Logs.GuildID ~= '' then
        return tostring(Config.Logs.GuildID)
    end
    return nil
end

local function getBotToken()
    local cfg = getHireConfig()
    if cfg.BotToken and cfg.BotToken ~= '' then
        return cfg.BotToken
    end
    if Config.Logs and Config.Logs.BotToken and Config.Logs.BotToken ~= '' then
        return Config.Logs.BotToken
    end
    local convar = GetConvar('kodebykarl_discord_bot_token', '')
    if convar ~= '' then
        return convar
    end
    return nil
end

---@param src number
---@return string|nil
function Gang.GetPlayerDiscordId(src)
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
        if id and id:sub(1, 8) == 'discord:' then
            return id:sub(9)
        end
    end
    return nil
end

---@param raw any
---@return string|nil
function Gang.NormalizeDiscordId(raw)
    if raw == nil then return nil end
    local id = tostring(raw):gsub('%s+', '')
    id = id:gsub('^<@!?(%d+)>$', '%1')
    id = id:match('^(%d+)$')
    if not id or #id < 15 or #id > 22 then
        return nil
    end
    return id
end

---@param discordId string
---@param forceRefresh boolean|nil
---@return table|nil, number
local function fetchGuildMember(discordId, forceRefresh)
    local cfg = getHireConfig()
    local token = getBotToken()
    local guildId = getHireGuildId()
    if not token or not guildId then
        return nil, 0
    end

    local cacheMs = tonumber(cfg.RoleCacheMs) or 15000
    local cached = memberRoleCache[discordId]
    if not forceRefresh and cached and cached.expires > GetGameTimer() then
        return { roles = cached.roles }, 200
    end

    local p = promise.new()
    local url = ('%s/guilds/%s/members/%s'):format(DISCORD_API, guildId, discordId)

    PerformHttpRequest(url, function(status, body)
        status = tonumber(status) or 0
        if status == 200 and body and body ~= '' then
            local ok, data = pcall(json.decode, body)
            if ok and type(data) == 'table' then
                memberRoleCache[discordId] = {
                    roles = data.roles or {},
                    expires = GetGameTimer() + cacheMs,
                }
                return p:resolve({ member = data, status = status })
            end
        end
        -- Don't cache failures — role/guild changes should retry live
        p:resolve({ member = nil, status = status })
    end, 'GET', '', {
        ['Authorization'] = ('Bot %s'):format(token),
        ['Content-Type'] = 'application/json',
    })

    local result = Citizen.Await(p)
    return result.member, result.status
end

---@param roles any
---@param roleId string
---@return boolean
local function memberHasRole(roles, roleId)
    if type(roles) ~= 'table' or not roleId or roleId == '' then
        return false
    end
    roleId = tostring(roleId)
    for i = 1, #roles do
        if tostring(roles[i]) == roleId then
            return true
        end
    end
    return false
end

---@param discordId string
---@param gangKey string
---@return boolean ok
---@return string|nil errorMessage
function Gang.VerifyDiscordRoleById(discordId, gangKey)
    local cfg = getHireConfig()
    if not cfg.Enabled then
        return true
    end

    local gang = Config.Gangs[gangKey]
    if not gang then
        return false, cfg.Messages and cfg.Messages.ApiError or 'Invalid gang.'
    end

    local roleId = gang.discordRoleId and tostring(gang.discordRoleId) or ''
    if roleId == '' then
        if cfg.BlockIfRoleNotConfigured then
            return false, cfg.Messages and cfg.Messages.RoleNotConfigured or 'Discord role not configured.'
        end
        return true
    end

    local guildId = getHireGuildId()
    if not getBotToken() or not guildId then
        print('^1[cfx-keydi-gang]^0 DiscordHire: BotToken / GuildID missing — blocking hire.')
        return false, cfg.Messages and cfg.Messages.ApiError or 'Discord not configured.'
    end

    discordId = Gang.NormalizeDiscordId(discordId)
    if not discordId then
        return false, cfg.Messages and cfg.Messages.InvalidDiscordId or 'Invalid Discord ID.'
    end

    -- Always force-refresh on hire so newly added roles are seen immediately
    local member, status = fetchGuildMember(discordId, true)
    if status == 401 or status == 403 then
        print(('^1[cfx-keydi-gang]^0 DiscordHire bot cannot access guild %s (HTTP %s). Invite bot + enable Server Members Intent.'):format(tostring(guildId), tostring(status)))
        return false, cfg.Messages and cfg.Messages.BotCannotAccess or 'Bot cannot access Discord.'
    end

    if status == 404 then
        print(('^3[cfx-keydi-gang]^0 DiscordHire: member %s not found in guild %s (HTTP 404). Either not in Discord, or bot is not in that guild.'):format(discordId, tostring(guildId)))
        if cfg.RequireInGuild ~= false then
            return false, cfg.Messages and cfg.Messages.NotInGuild or 'Not in Discord.'
        end
        return true
    end

    if status ~= 200 or not member then
        print(('^1[cfx-keydi-gang]^0 DiscordHire API error for %s (HTTP %s)'):format(tostring(discordId), tostring(status)))
        return false, cfg.Messages and cfg.Messages.ApiError or 'Discord API error.'
    end

    if not memberHasRole(member.roles, roleId) then
        print(('^3[cfx-keydi-gang]^0 DiscordHire: %s missing role %s for gang %s. Roles: %s'):format(
            discordId, roleId, gangKey, json.encode(member.roles or {})
        ))
        local label = gang.label or gangKey
        local msg = cfg.Messages and cfg.Messages.MissingRole or 'Missing Discord role for %s.'
        return false, msg:format(label)
    end

    return true
end

---@param targetSource number
---@param gangKey string
---@return boolean ok
---@return string|nil errorMessage
function Gang.CanHireViaDiscord(targetSource, gangKey)
    local cfg = getHireConfig()
    if not cfg.Enabled then
        return true
    end

    local discordId = Gang.GetPlayerDiscordId(targetSource)
    if not discordId then
        if cfg.RequireDiscordLinked ~= false then
            return false, cfg.Messages and cfg.Messages.NoDiscord or 'Discord not linked.'
        end
        return true
    end

    return Gang.VerifyDiscordRoleById(discordId, gangKey)
end

---@param src number
---@param identifier string
---@param name string
function Gang.TrackDiscordPlayer(src, identifier, name)
    local discordId = Gang.GetPlayerDiscordId(src)
    if not discordId or not identifier then return end

    MySQL.query([[
        INSERT INTO `gang_discord_map` (`discord`, `identifier`, `name`, `updated_at`)
        VALUES (?, ?, ?, NOW())
        ON DUPLICATE KEY UPDATE `discord` = VALUES(`discord`), `name` = VALUES(`name`), `updated_at` = NOW()
    ]], { discordId, identifier, name or 'Unknown' })
end

---@param discordId string
---@return table[]
function Gang.GetCharactersByDiscord(discordId)
    discordId = Gang.NormalizeDiscordId(discordId)
    if not discordId then return {} end

    return MySQL.query.await(
        'SELECT `identifier`, `name` FROM `gang_discord_map` WHERE `discord` = ? ORDER BY `updated_at` DESC',
        { discordId }
    ) or {}
end

---@param discordId string
---@return table|nil
function Gang.FindOnlinePlayerByDiscord(discordId)
    discordId = Gang.NormalizeDiscordId(discordId)
    if not discordId then return nil end

    local players = GetPlayers()
    for i = 1, #players do
        local playerSrc = tonumber(players[i])
        if playerSrc and Gang.GetPlayerDiscordId(playerSrc) == discordId then
            return ESX.GetPlayerFromId(playerSrc)
        end
    end
    return nil
end

-- Startup: verify bot can see the hire guild (prints clear fix instructions)
CreateThread(function()
    Wait(2500)
    local cfg = getHireConfig()
    if not cfg.Enabled then return end

    local token = getBotToken()
    local guildId = getHireGuildId()
    if not token or not guildId then
        print('^1[cfx-keydi-gang]^0 DiscordHire enabled but BotToken/GuildID missing.')
        return
    end

    PerformHttpRequest(('https://discord.com/api/v10/guilds/%s'):format(guildId), function(status, body)
        status = tonumber(status) or 0
        if status == 200 then
            local name = guildId
            if body and body ~= '' then
                local ok, data = pcall(json.decode, body)
                if ok and data and data.name then name = data.name end
            end
            print(('^2[cfx-keydi-gang]^0 DiscordHire OK — bot can access guild "%s" (%s). Roles checked live on each hire.'):format(tostring(name), tostring(guildId)))
        else
            print(('^1[cfx-keydi-gang]^0 DiscordHire FAILED (HTTP %s). Bot cannot access GuildID %s.'):format(tostring(status), tostring(guildId)))
            print('^3[cfx-keydi-gang]^0 Fix: invite the kodebykarl_discord_bot_token bot into that Discord, enable Server Members Intent, then restart kodebykarl-gangsystem.^0')
        end
    end, 'GET', '', {
        ['Authorization'] = ('Bot %s'):format(token),
        ['Content-Type'] = 'application/json',
    })
end)

_G.Gang = Gang

exports('GetPlayerGang', function(srcOrPlayer)
    local xPlayer = srcOrPlayer
    if type(srcOrPlayer) ~= 'table' then
        xPlayer = ESX.GetPlayerFromId(srcOrPlayer)
    end
    return Gang.GetPlayerGang(xPlayer)
end)
