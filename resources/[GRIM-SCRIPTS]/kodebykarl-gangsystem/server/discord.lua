GangDiscord = GangDiscord or {}

local DISCORD_API = 'https://discord.com/api/v10'

local function GetBotToken()
    local token = Config.Discord and Config.Discord.BotToken or ''
    if token == '' then
        token = GetConvar('kodebykarl_discord_bot_token', '')
    end
    return token
end

local function GetGuildId()
    local guild = Config.Discord and Config.Discord.GuildID or ''
    if guild == '' then
        guild = GetConvar('kodebykarl_discord_guild_id', '')
    end
    return guild
end

local function IsConfigured()
    if not Config.Discord or not Config.Discord.Enabled then return false end
    local token = GetBotToken()
    local guild = GetGuildId()
    if token == '' or guild == '' then return false end

    -- At least one gang role filled
    for i = 1, #Config.Gangs do
        local role = Config.Gangs[i].discordRoleId
        if type(role) == 'string' and role ~= '' then
            return true
        end
    end
    return false
end

local function GetDiscordId(src)
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
        if id and id:sub(1, 8) == 'discord:' then
            return id:sub(9)
        end
    end
    if GetPlayerIdentifierByType then
        local discordId = GetPlayerIdentifierByType(src, 'discord')
        if discordId then
            if discordId:sub(1, 8) == 'discord:' then
                return discordId:sub(9)
            end
            return discordId
        end
    end
    return nil
end

local function ResolveGangFromRoles(roleList)
    if type(roleList) ~= 'table' then return nil end
    local set = {}
    for _, r in ipairs(roleList) do
        set[tostring(r)] = true
    end
    for i = 1, #Config.Gangs do
        local g = Config.Gangs[i]
        if g.discordRoleId and g.discordRoleId ~= '' and set[tostring(g.discordRoleId)] then
            return g
        end
    end
    return nil
end

--- Fetch member roles then hire/fire to match Discord.
function GangDiscord.SyncPlayer(src, cb)
    cb = cb or function() end

    if not IsConfigured() then
        return cb(false, 'discord_not_configured')
    end

    local discordId = GetDiscordId(src)
    if not discordId then
        return cb(false, 'no_discord')
    end

    local url = ('%s/guilds/%s/members/%s'):format(DISCORD_API, GetGuildId(), discordId)
    PerformHttpRequest(url, function(status, body)
        status = tonumber(status) or 0
        if status ~= 200 or not body or body == '' then
            -- 404 = not in guild → fire if they had a Discord-synced gang
            if status == 404 then
                local gang = GangMembership.GetPlayerGang(src)
                if gang then
                    GangMembership.Fire(src, 'discord_left_guild')
                end
            end
            return cb(false, 'http_' .. tostring(status))
        end

        local ok, data = pcall(json.decode, body)
        if not ok or type(data) ~= 'table' then
            return cb(false, 'bad_json')
        end

        local matched = ResolveGangFromRoles(data.roles)
        local current = GangMembership.GetPlayerGang(src)

        if matched then
            if not current or current.name ~= matched.id then
                GangMembership.Hire(src, matched.id, 0, 'discord')
            end
            return cb(true, 'synced_' .. matched.id)
        end

        -- Has gang but no matching role anymore
        if current then
            local def = Config.GetGang(current.name)
            -- Only auto-fire if that gang has a discord role configured
            if def and def.discordRoleId and def.discordRoleId ~= '' then
                GangMembership.Fire(src, 'discord_role_removed')
            end
        end

        return cb(true, 'no_gang_role')
    end, 'GET', '', {
        ['Authorization'] = 'Bot ' .. GetBotToken(),
        ['Content-Type'] = 'application/json',
    })
end

function GangDiscord.StartPollLoop()
    CreateThread(function()
        while true do
            local waitMs = math.max(10, tonumber(Config.DiscordPollSeconds) or 25) * 1000
            if IsConfigured() then
                local players = ESX.GetExtendedPlayers and ESX.GetExtendedPlayers() or {}
                for _, xPlayer in pairs(players) do
                    local src = xPlayer.source
                    if src then
                        GangDiscord.SyncPlayer(src)
                        Wait(350) -- gentle rate limit
                    end
                end
            end
            Wait(waitMs)
        end
    end)
end

exports('RefreshPlayerGang', function(src)
    GangDiscord.SyncPlayer(src)
end)
