local DISCORD_API = 'https://discord.com/api/v10'
local PREFIX = '[kodebykarl-logs]'

local resolved = {}
local resolvedByName = {}
local postQueue = {}
local posting = false
local warnedMissing = {}
local avatarCache = {}

local function botToken()
    if Config.BotToken and Config.BotToken ~= '' and not tostring(Config.BotToken):find('YOUR_', 1, true) then
        return Config.BotToken
    end
    local convar = GetConvar('kodebykarl_discord_bot_token', '')
    if convar ~= '' then
        return convar
    end
    return nil
end

function LogsEnabled()
    if not Config.Enabled then return false end
    if not botToken() then return false end
    if not Config.GuildID or Config.GuildID == '' then return false end
    return true
end

local function botHeaders()
    return {
        ['Authorization'] = ('Bot %s'):format(botToken()),
        ['Content-Type'] = 'application/json',
    }
end

function DiscordRequest(method, path, body, cb)
    PerformHttpRequest(DISCORD_API .. path, function(status, response)
        status = tonumber(status) or 0
        local data = nil
        if response and response ~= '' then
            local ok, decoded = pcall(json.decode, response)
            if ok and type(decoded) == 'table' then
                data = decoded
            end
        end
        cb(status, data)
    end, method, body and json.encode(body) or '', botHeaders())
end

local function processQueue()
    if posting then return end
    posting = true
    CreateThread(function()
        while #postQueue > 0 do
            local item = table.remove(postQueue, 1)
            if item.channelId and item.channelId ~= '' then
                local done, retryAfter = false, nil
                DiscordRequest('POST', ('/channels/%s/messages'):format(item.channelId), item.payload, function(status, data)
                    if status == 429 then
                        retryAfter = tonumber(data and data.retry_after) or 1
                    elseif status ~= 200 and status ~= 201 then
                        print(('^1%s^0 Failed to post (HTTP %s)'):format(PREFIX, status))
                    end
                    done = true
                end)
                local timeout = GetGameTimer() + 10000
                while not done and GetGameTimer() < timeout do
                    Wait(50)
                end
                if retryAfter then
                    table.insert(postQueue, 1, item)
                    Wait(math.floor(retryAfter * 1000) + 150)
                else
                    Wait(tonumber(Config.PostCooldownMs) or 400)
                end
            end
        end
        posting = false
    end)
end

function EnqueueLog(channelKey, payload)
    local channelId = ResolveChannelId(channelKey)
    if not channelId then
        if not warnedMissing[channelKey] then
            warnedMissing[channelKey] = true
            print(('^3%s^0 No Discord channel for `%s`. Create #%s in the guild (bot auto-detects by name).'):format(
                PREFIX, channelKey, channelKey
            ))
        end
        return false
    end
    postQueue[#postQueue + 1] = { channelId = channelId, payload = payload }
    processQueue()
    return true
end

local function mapGuildChannels(channels)
    resolvedByName = {}
    for i = 1, #channels do
        local ch = channels[i]
        -- type 0 = guild text channel
        if ch and ch.id and ch.name and (ch.type == 0 or ch.type == nil) then
            resolvedByName[tostring(ch.name):lower()] = tostring(ch.id)
        end
    end

    local names = Config.Channels or {}
    local ids = Config.ChannelIDs or {}
    local autoDetect = Config.AutoDetectChannels ~= false
    local missing = {}
    local matched = {}

    for key, channelName in pairs(names) do
        local alias = tostring(key):lower()
        local wantName = tostring(channelName or key):lower()
        local override = (not autoDetect) and ids[key] or nil

        if type(override) == 'string' and override ~= '' and not override:find('YOUR_', 1, true) then
            resolved[alias] = override:gsub('%s+', '')
            matched[#matched + 1] = ('%s → %s (manual)'):format(alias, resolved[alias])
        else
            local found = resolvedByName[wantName] or resolvedByName[alias]
            if found then
                resolved[alias] = found
                matched[#matched + 1] = ('#%s → %s'):format(wantName, found)
            else
                missing[#missing + 1] = ('%s (#%s)'):format(key, channelName)
            end
        end
    end

    local ready = 0
    for _ in pairs(resolved) do ready = ready + 1 end
    local guildCount = 0
    for _ in pairs(resolvedByName) do guildCount = guildCount + 1 end

    print(('^2%s^0 Bot auto-detected %s/%s aliases from %s guild text channel(s).'):format(
        PREFIX, ready, (function()
            local n = 0
            for _ in pairs(names) do n = n + 1 end
            return n
        end)(), guildCount
    ))

    table.sort(matched)
    for i = 1, #matched do
        print(('^2%s^0   %s'):format(PREFIX, matched[i]))
    end

    if #missing > 0 then
        print(('^3%s^0 Missing channels (create these names in Discord): %s'):format(
            PREFIX, table.concat(missing, ', ')
        ))
    end
end

function ResolveGuildChannels()
    if not LogsEnabled() then
        print(('^3%s^0 Disabled (token or guild missing).'):format(PREFIX))
        return
    end

    -- Always ask Discord for live channel IDs (bot handles detection).
    print(('^3%s^0 Fetching guild channels for auto-detect…'):format(PREFIX))
    DiscordRequest('GET', ('/guilds/%s/channels'):format(Config.GuildID), nil, function(status, data)
        if status == 200 and type(data) == 'table' then
            mapGuildChannels(data)
        else
            print(('^1%s^0 Failed to list guild channels (HTTP %s). Invite the bot and grant View Channels + Send Messages.'):format(PREFIX, status))
        end
    end)
end

--- Resolve alias or raw Discord channel name → snowflake ID
function ResolveChannelId(key)
    if not key or key == '' then return nil end
    local alias = tostring(key):lower()
    if resolved[alias] and resolved[alias] ~= '' then
        return resolved[alias]
    end
    local byName = resolvedByName[alias]
    if byName then
        resolved[alias] = byName
        return byName
    end
    -- Also try Config.Channels alias → display name
    local mapped = Config.Channels and Config.Channels[key]
    if not mapped then
        for k, v in pairs(Config.Channels or {}) do
            if tostring(k):lower() == alias then
                mapped = v
                break
            end
        end
    end
    if mapped then
        local found = resolvedByName[tostring(mapped):lower()]
        if found then
            resolved[alias] = found
            return found
        end
    end
    return nil
end

function CollectIdentifiers(src)
    local out = { discord = nil, license = nil, steam = nil, fivem = nil }
    src = tonumber(src)
    if not src or src <= 0 then return out end
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
        if id then
            if id:sub(1, 8) == 'discord:' then
                out.discord = id:sub(9)
            elseif id:sub(1, 8) == 'license:' then
                out.license = id
            elseif id:sub(1, 6) == 'steam:' then
                out.steam = id
            elseif id:sub(1, 6) == 'fivem:' then
                out.fivem = id
            end
        end
    end
    return out
end

function PlayerSnapshot(src)
    src = tonumber(src)
    local ids = CollectIdentifiers(src)
    local name = (src and src > 0) and (GetPlayerName(src) or 'Unknown') or 'Unknown'
    local identifier, charName, jobLabel, group
    local ping = (src and src > 0) and GetPlayerPing(src) or nil

    if src and src > 0 and GetResourceState('es_extended') == 'started' then
        local ok, xPlayer = pcall(function()
            return exports['es_extended']:getSharedObject().GetPlayerFromId(src)
        end)
        if ok and xPlayer then
            identifier = xPlayer.identifier or (xPlayer.getIdentifier and xPlayer.getIdentifier())
            charName = (xPlayer.getName and xPlayer.getName()) or xPlayer.name
            if xPlayer.job then
                jobLabel = ('%s (%s)'):format(
                    xPlayer.job.label or xPlayer.job.name or 'Unemployed',
                    xPlayer.job.grade_label or tostring(xPlayer.job.grade or 0)
                )
            end
            group = xPlayer.getGroup and xPlayer.getGroup() or xPlayer.group
        end
    end

    return {
        src = src,
        name = charName or name,
        displayName = name,
        identifier = identifier or ids.license,
        discord = ids.discord,
        license = ids.license,
        steam = ids.steam,
        fivem = ids.fivem,
        job = jobLabel,
        group = group,
        ping = ping,
    }
end

function FormatPlayerBlock(srcOrSnap, extra)
    local snap = type(srcOrSnap) == 'table' and srcOrSnap or PlayerSnapshot(srcOrSnap)
    local lines = {}
    lines[#lines + 1] = ('Name: %s'):format(snap.name or 'Unknown')
    if snap.displayName and snap.displayName ~= snap.name then
        lines[#lines + 1] = ('FiveM: %s'):format(snap.displayName)
    end
    if snap.src and snap.src > 0 then
        lines[#lines + 1] = ('ID: `%s`'):format(snap.src)
    else
        lines[#lines + 1] = 'ID: `offline`'
    end
    if snap.identifier and snap.identifier ~= '' then
        lines[#lines + 1] = ('Identifier: `%s`'):format(snap.identifier)
    end
    if snap.discord then
        lines[#lines + 1] = ('Discord: <@%s> (`%s`)'):format(snap.discord, snap.discord)
    end
    if snap.license then
        lines[#lines + 1] = ('License: `%s`'):format(snap.license)
    end
    if snap.job then
        lines[#lines + 1] = ('Job: %s'):format(snap.job)
    end
    if extra and extra ~= '' then
        lines[#lines + 1] = extra
    end
    return table.concat(lines, '\n')
end

function FormatCoords(coords)
    if not coords then
        return nil
    end
    if type(coords) == 'vector3' or type(coords) == 'vector4' then
        return ('%.2f, %.2f, %.2f'):format(coords.x + 0.0, coords.y + 0.0, coords.z + 0.0)
    end
    if type(coords) == 'table' and coords.x then
        return ('%.2f, %.2f, %.2f'):format(coords.x + 0.0, coords.y + 0.0, coords.z + 0.0)
    end
    return tostring(coords)
end

function PlayerCoords(src)
    src = tonumber(src)
    if not src or src <= 0 then return nil end
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return nil end
    return GetEntityCoords(ped)
end

function FormatDuration(seconds)
    seconds = math.max(0, math.floor(tonumber(seconds) or 0))
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    if h > 0 then
        return ('%dh %dm %ds'):format(h, m, s)
    end
    if m > 0 then
        return ('%dm %ds'):format(m, s)
    end
    return ('%ds'):format(s)
end

function FetchDiscordAvatar(discordId, cb)
    if not discordId then return cb(nil) end
    local cached = avatarCache[discordId]
    if cached and cached.untilTime > GetGameTimer() then
        return cb(cached.url)
    end
    DiscordRequest('GET', ('/users/%s'):format(discordId), nil, function(status, data)
        local url = nil
        if status == 200 and data then
            if data.avatar then
                url = ('https://cdn.discordapp.com/avatars/%s/%s.png'):format(discordId, data.avatar)
            else
                local idx = tonumber(data.discriminator) or 0
                url = ('https://cdn.discordapp.com/embed/avatars/%s.png'):format(idx % 5)
            end
        end
        avatarCache[discordId] = {
            url = url,
            untilTime = GetGameTimer() + (tonumber(Config.AvatarCacheMs) or 600000),
        }
        cb(url)
    end)
end

function DumpResolvedChannels()
    local lines = {}
    for key, id in pairs(resolved) do
        lines[#lines + 1] = ('  %s = %s'):format(key, id)
    end
    table.sort(lines)
    if #lines == 0 then
        print(('^3%s^0 No channels resolved yet.'):format(PREFIX))
        return
    end
    print(('^2%s^0 Resolved channels:\n%s'):format(PREFIX, table.concat(lines, '\n')))
end

CreateThread(function()
    Wait(1500)
    ResolveGuildChannels()
end)
