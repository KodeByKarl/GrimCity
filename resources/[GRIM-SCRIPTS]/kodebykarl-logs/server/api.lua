--[[
    Universal logging API.

    exports['kodebykarl-logs']:Log('join', {
        title = 'Player Joined',
        description = 'optional',
        color = 3066993,
        player = source,                 -- auto-fills a Player field
        fields = { { name = 'Ping', value = '`32 ms`', inline = true } },
        coords = vector3(...),
        thumbnail = false,               -- skip Discord avatar
    })

    Channel can be a Config.Channels alias or a live Discord channel name.
]]

local recent = {}

local function recently(key, ms)
    local now = GetGameTimer()
    if recent[key] and (now - recent[key]) < ms then
        return true
    end
    recent[key] = now
    return false
end

function MarkRecent(src, kind, ms)
    return recently(('%s:%s'):format(tostring(src), kind), ms or 3000)
end

function WasRecent(src, kind, ms)
    local key = ('%s:%s'):format(tostring(src), kind)
    local now = GetGameTimer()
    return recent[key] and (now - recent[key]) < (ms or 3000)
end

local function typeAllowed(channel)
    if Config.Types and Config.Types[channel] == false then
        return false
    end
    return true
end

local function buildFields(payload)
    local fields = {}
    if payload.player then
        fields[#fields + 1] = {
            name = payload.playerLabel or 'Player',
            value = FormatPlayerBlock(payload.player),
            inline = false,
        }
    end
    if type(payload.fields) == 'table' then
        for i = 1, #payload.fields do
            local f = payload.fields[i]
            if type(f) == 'table' and f.name and f.value and tostring(f.value) ~= '' then
                fields[#fields + 1] = {
                    name = tostring(f.name):sub(1, 256),
                    value = tostring(f.value):sub(1, 1024),
                    inline = f.inline == true,
                }
            end
        end
    end
    local coords = payload.coords or (payload.player and type(payload.player) ~= 'table' and PlayerCoords(payload.player))
    if coords then
        fields[#fields + 1] = {
            name = 'Location',
            value = ('`%s`'):format(FormatCoords(coords) or 'n/a'),
            inline = false,
        }
    end
    return fields
end

local function postEmbed(channel, payload, avatarUrl)
    local color = payload.color
        or (Config.Colors and Config.Colors[channel])
        or (Config.Colors and Config.Colors.default)
        or 5793266

    local embed = {
        title = payload.title and tostring(payload.title):sub(1, 256) or nil,
        description = payload.description and tostring(payload.description):sub(1, 4096) or nil,
        color = color,
        fields = buildFields(payload),
        timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
        footer = { text = payload.footer or Config.Footer or Config.ServerName or 'Grim City' },
    }

    if avatarUrl then
        embed.thumbnail = { url = avatarUrl }
    elseif type(payload.thumbnail) == 'string' and payload.thumbnail ~= '' then
        embed.thumbnail = { url = payload.thumbnail }
    end

    return EnqueueLog(channel, { embeds = { embed } })
end

function WriteLog(channel, payload)
    if not LogsEnabled() then return false end
    if type(channel) ~= 'string' or channel == '' then return false end
    payload = type(payload) == 'table' and payload or {}
    channel = channel:lower()
    if not typeAllowed(channel) then return false end

    local src = payload.player
    if type(src) == 'table' then
        src = src.src
    end

    if payload.thumbnail == false or not src or tonumber(src) <= 0 then
        return postEmbed(channel, payload, nil)
    end

    local snap = type(payload.player) == 'table' and payload.player or PlayerSnapshot(src)
    FetchDiscordAvatar(snap.discord, function(url)
        postEmbed(channel, payload, url)
    end)
    return true
end

--- Convenience: fill player + extra fields in one call.
function WritePlayerLog(channel, src, title, fields, color)
    return WriteLog(channel, {
        title = title,
        player = src,
        fields = fields,
        color = color,
    })
end

exports('Log', WriteLog)
exports('Write', WriteLog)
exports('LogPlayer', WritePlayerLog)
exports('RegisterChannel', function(key, channelName)
    if type(key) ~= 'string' or key == '' then return false end
    Config.Channels = Config.Channels or {}
    Config.Channels[key] = channelName or key
    local id = ResolveChannelId(channelName or key)
    return id ~= nil
end)
exports('ResolveChannel', ResolveChannelId)

-- Chat already calls discord-logs if that resource is started.
exports('LogChatMessage', function(src, message)
    WriteLog('chat', {
        title = 'Chat Message',
        player = src,
        fields = {
            { name = 'Message', value = ('```\n%s\n```'):format(tostring(message or ''):sub(1, 900)) },
        },
    })
end)

exports('LogCommandFallback', function(src, command)
    WriteLog('chat', {
        title = 'Unknown Command',
        player = src,
        fields = {
            { name = 'Input', value = ('`/%s`'):format(tostring(command or ''):sub(1, 200)) },
        },
    })
end)

AddEventHandler('kodebykarl-logs:write', function(channel, payload)
    WriteLog(channel, payload)
end)

RegisterCommand('citylogs_status', function(src)
    if src ~= 0 then return end
    DumpResolvedChannels()
end, true)

RegisterCommand('citylogs_test', function(src, args)
    if src ~= 0 then return end
    local channel = (args[1] or 'join'):lower()
    WriteLog(channel, {
        title = 'Test Log',
        description = 'Manual console test from kodebykarl-logs.',
        fields = {
            { name = 'Channel', value = ('`%s`'):format(channel), inline = true },
            { name = 'Time', value = os.date('%Y-%m-%d %H:%M:%S'), inline = true },
        },
        thumbnail = false,
    })
    print(('[kodebykarl-logs] Test sent to `%s`.'):format(channel))
end, true)
