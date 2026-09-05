--[[
    xt-prison Discord logs
    Same bot pattern as cfx-keydi-utils disconnectlogs / banking / police.
]]

PrisonLogs = PrisonLogs or {}

local config = require 'configs.server'

local DISCORD_API = "https://discord.com/api/v10"
local PREFIX = "[xt-prison:Logs]"

local resolvedChannels = {}
local postQueue = {}
local posting = false

local function cfg()
    return config and config.Logs or nil
end

local function isEnabled()
    local c = cfg()
    if not c or not c.Enabled then return false end
    if not c.BotToken or c.BotToken == "" or tostring(c.BotToken):find("YOUR_", 1, true) then
        return false
    end
    if not c.GuildID or c.GuildID == "" or tostring(c.GuildID):find("YOUR_", 1, true) then
        return false
    end
    return true
end

local function botHeaders()
    local c = cfg()
    return {
        ["Authorization"] = ("Bot %s"):format(c.BotToken),
        ["Content-Type"] = "application/json",
    }
end

local function discordRequest(method, path, body, cb)
    PerformHttpRequest(DISCORD_API .. path, function(status, response)
        status = tonumber(status) or 0
        local data = nil
        if response and response ~= "" then
            local ok, decoded = pcall(json.decode, response)
            if ok and type(decoded) == "table" then data = decoded end
        end
        cb(status, data)
    end, method, body and json.encode(body) or "", botHeaders())
end

local function collectIdentifiers(src)
    local out = { discord = nil, license = nil, steam = nil, fivem = nil }
    if not src or src <= 0 then return out end
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
        if id then
            if id:sub(1, 8) == "discord:" then out.discord = id:sub(9)
            elseif id:sub(1, 8) == "license:" then out.license = id
            elseif id:sub(1, 6) == "steam:" then out.steam = id
            elseif id:sub(1, 6) == "fivem:" then out.fivem = id end
        end
    end
    return out
end

local function processQueue()
    if posting then return end
    posting = true
    CreateThread(function()
        local c = cfg()
        while #postQueue > 0 do
            local item = table.remove(postQueue, 1)
            if item.channelId and item.channelId ~= "" then
                local done = false
                discordRequest("POST", ("/channels/%s/messages"):format(item.channelId), item.payload, function(status)
                    if status ~= 200 and status ~= 201 then
                        print(("^1%s^0 Failed to post (HTTP %s)"):format(PREFIX, status))
                    end
                    done = true
                end)
                local timeout = GetGameTimer() + 10000
                while not done and GetGameTimer() < timeout do Wait(50) end
            end
            Wait(tonumber(c and c.PostCooldownMs) or 500)
        end
        posting = false
    end)
end

local function enqueuePost(channelKey, payload)
    local channelId = resolvedChannels[channelKey]
    if not channelId or channelId == "" then
        for _, id in pairs(resolvedChannels) do
            channelId = id
            break
        end
    end
    if not channelId or channelId == "" then return end
    postQueue[#postQueue + 1] = { channelId = channelId, payload = payload }
    processQueue()
end

local function mapGuildChannels(channels)
    local c = cfg()
    local byName = {}
    for i = 1, #channels do
        local ch = channels[i]
        if ch and ch.id and ch.name and (ch.type == 0 or ch.type == nil) then
            byName[ch.name:lower()] = tostring(ch.id)
        end
    end
    local names = c.ChannelNames or {}
    local ids = c.ChannelIDs or {}
    local missing = {}
    for key, channelName in pairs(names) do
        local override = ids[key]
        if type(override) == "string" and override ~= "" and not override:find("YOUR_", 1, true) then
            resolvedChannels[key] = override:gsub("%s+", "")
        else
            local found = byName[tostring(channelName):lower()]
            if found then
                resolvedChannels[key] = found
            else
                missing[#missing + 1] = ("%s (#%s)"):format(key, channelName)
            end
        end
    end
    for key, channelId in pairs(resolvedChannels) do
        print(("^2%s^0 %s → %s"):format(PREFIX, key:upper(), channelId))
    end
    if #missing > 0 then
        print(("^1%s^0 Missing channels: %s"):format(PREFIX, table.concat(missing, ", ")))
    end
end

local function resolveChannels()
    local c = cfg()
    if not isEnabled() then return end
    local names = c.ChannelNames or {}
    local ids = c.ChannelIDs or {}
    local allOverride = true
    for key in pairs(names) do
        local override = ids[key]
        if type(override) ~= "string" or override == "" or override:find("YOUR_", 1, true) then
            allOverride = false
            break
        end
    end
    if allOverride then
        for key, override in pairs(ids) do
            resolvedChannels[key] = tostring(override):gsub("%s+", "")
        end
        for key, channelId in pairs(resolvedChannels) do
            print(("^2%s^0 %s → %s (manual)"):format(PREFIX, key:upper(), channelId))
        end
        return
    end
    discordRequest("GET", ("/guilds/%s/channels"):format(c.GuildID), nil, function(status, data)
        if status == 200 and type(data) == "table" then
            mapGuildChannels(data)
        else
            print(("^1%s^0 Failed to list guild channels (HTTP %s)."):format(PREFIX, status))
        end
    end)
end

local function postEmbed(channelKey, embed)
    if not isEnabled() then return end
    local c = cfg()
    if c.LogTypes and c.LogTypes[channelKey] == false then return end
    embed.footer = { text = "Pandora City • Prison" }
    embed.timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    enqueuePost(channelKey, { embeds = { embed } })
end

local function playerField(src, name, identifier)
    local lines = {}
    if not name and src and getCharName then
        name = getCharName(src)
    end
    if not identifier and src and getCharID then
        identifier = getCharID(src)
    end
    lines[#lines + 1] = ("**Name:** %s"):format(name or GetPlayerName(src or 0) or "Unknown")
    if src and src > 0 then
        lines[#lines + 1] = ("**ID:** `%s`"):format(src)
    else
        lines[#lines + 1] = "**ID:** `offline`"
    end
    if identifier and identifier ~= "" then
        lines[#lines + 1] = ("**Identifier:** `%s`"):format(identifier)
    end
    if src and src > 0 then
        local ids = collectIdentifiers(src)
        if ids.discord then
            lines[#lines + 1] = ("**Discord:** <@%s> (`%s`)"):format(ids.discord, ids.discord)
        end
        if ids.license then
            lines[#lines + 1] = ("**License:** `%s`"):format(ids.license)
        end
    end
    return table.concat(lines, "\n")
end

function PrisonLogs.Jail(data)
    data = data or {}
    local c = cfg()
    local isUpdate = data.updated == true
    local color = isUpdate
        and ((c and c.EmbedColors and c.EmbedColors.timeUpdate) or 3447003)
        or ((c and c.EmbedColors and c.EmbedColors.jail) or 15105570)

    postEmbed("jail", {
        title = isUpdate and "Jail Time Updated" or "Player Jailed",
        color = color,
        fields = {
            { name = "Officer", value = playerField(data.src, data.name, data.identifier), inline = false },
            { name = "Prisoner", value = playerField(data.targetSrc, data.targetName, data.targetIdentifier), inline = false },
            { name = "Months", value = ("`%s`"):format(tostring(data.time or "?")), inline = true },
            { name = "Method", value = ("`%s`"):format(data.method or "jail"), inline = true },
        },
    })
end

function PrisonLogs.Release(data)
    data = data or {}
    local c = cfg()
    local color = (c and c.EmbedColors and c.EmbedColors.release) or 5763719

    postEmbed("release", {
        title = "Player Released / Unjailed",
        color = color,
        fields = {
            { name = "Officer", value = playerField(data.src, data.name, data.identifier), inline = false },
            { name = "Prisoner", value = playerField(data.targetSrc, data.targetName, data.targetIdentifier), inline = false },
            { name = "Method", value = ("`%s`"):format(data.method or "unjail"), inline = true },
        },
    })
end

function PrisonLogs.Breakout(data)
    data = data or {}
    local c = cfg()
    local color = (c and c.EmbedColors and c.EmbedColors.breakout) or 15158332

    postEmbed("breakout", {
        title = "Prison Breakout",
        color = color,
        description = ("**%s** escaped prison."):format(data.name or "Unknown"),
        fields = {
            { name = "Prisoner", value = playerField(data.src, data.name, data.identifier), inline = false },
        },
    })
end

function PrisonLogs.Hack(data)
    data = data or {}
    local c = cfg()
    local color = (c and c.EmbedColors and c.EmbedColors.hack) or 15844367

    postEmbed("breakout", {
        title = data.success and "Prison Terminal Hacked" or "Prison Terminal Hack Attempt",
        color = color,
        fields = {
            { name = "Player", value = playerField(data.src, data.name, data.identifier), inline = false },
            { name = "Terminal", value = ("`%s`"):format(tostring(data.terminal or "?")), inline = true },
            { name = "State", value = data.success and "`Hacked`" or "`Busy / Attempt`", inline = true },
        },
    })
end

function PrisonLogs.Exploit(data)
    data = data or {}
    local c = cfg()
    local color = (c and c.EmbedColors and c.EmbedColors.exploit) or 10038562
    local name = data.name
    if not name and data.src and getCharName then
        name = getCharName(data.src)
    end

    postEmbed("breakout", {
        title = "Prison Exploit Blocked",
        color = color,
        description = ("**%s** was dropped for a prison exploit."):format(name or GetPlayerName(data.src or 0) or "Unknown"),
        fields = {
            { name = "Player", value = playerField(data.src, name, data.identifier), inline = false },
            { name = "Reason", value = ("```%s```"):format(tostring(data.reason or "Unknown"):sub(1, 500)), inline = false },
        },
    })
end

function PrisonLogs.Items(data)
    data = data or {}
    local c = cfg()
    local returning = data.action == "return"
    local color = returning
        and ((c and c.EmbedColors and c.EmbedColors.returnItems) or 3066993)
        or ((c and c.EmbedColors and c.EmbedColors.confiscate) or 10181046)

    postEmbed("items", {
        title = returning and "Prison Items Returned" or "Prison Items Confiscated",
        color = color,
        fields = {
            { name = "Prisoner", value = playerField(data.src, data.name, data.identifier), inline = false },
            { name = "Item Slots", value = ("`%s`"):format(tostring(data.count or "?")), inline = true },
            { name = "Action", value = returning and "`Return`" or "`Confiscate`", inline = true },
        },
    })
end

CreateThread(function()
    Wait(2000)
    if isEnabled() then
        resolveChannels()
        print(("^2%s^0 ready"):format(PREFIX))
    else
        print(("^3%s^0 Disabled or missing BotToken/GuildID."):format(PREFIX))
    end
end)
