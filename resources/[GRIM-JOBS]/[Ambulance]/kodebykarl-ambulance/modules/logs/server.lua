--[[
    cfx-keydi-ambulance Discord logs
    Same bot pattern as banking / police / business.
]]

AmbulanceLogs = AmbulanceLogs or {}

local config = require 'shared.config'

local DISCORD_API = "https://discord.com/api/v10"
local PREFIX = "[cfx-keydi-ambulance:Logs]"

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

---@param logTypeKey string|nil  optional LogTypes gate (revive/heal/bleedout/etc)
local function postEmbed(channelKey, embed, logTypeKey)
    if not isEnabled() then return end
    local c = cfg()
    if logTypeKey and c.LogTypes and c.LogTypes[logTypeKey] == false then return end
    if c.LogTypes and c.LogTypes[channelKey] == false then return end
    embed.footer = { text = "Pandora City • EMS" }
    embed.timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    enqueuePost(channelKey, { embeds = { embed } })
end

local function formatMoney(amount)
    amount = math.floor(tonumber(amount) or 0)
    local formatted = tostring(amount)
    local k
    while true do
        formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then break end
    end
    return ("$%s"):format(formatted)
end

local function formatCoords(coords)
    if not coords then return "n/a" end
    if type(coords) == "vector3" or type(coords) == "vector4" then
        return ("%.2f, %.2f, %.2f"):format(coords.x + 0.0, coords.y + 0.0, coords.z + 0.0)
    end
    if type(coords) == "table" and coords.x then
        return ("%.2f, %.2f, %.2f"):format(coords.x + 0.0, coords.y + 0.0, coords.z + 0.0)
    end
    return tostring(coords)
end

local function playerField(src, name, identifier, extra)
    local lines = {}
    lines[#lines + 1] = ("**Name:** %s"):format(name or "Unknown")
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
    if extra and extra ~= "" then
        lines[#lines + 1] = extra
    end
    return table.concat(lines, "\n")
end

function AmbulanceLogs.FromPlayer(xPlayer)
    if not xPlayer then return "Unknown", nil, nil end
    local src = xPlayer.source
    local name = xPlayer.name or (xPlayer.getName and xPlayer.getName()) or GetPlayerName(src) or "Unknown"
    local identifier = xPlayer.identifier
    local job = xPlayer.job and (("%s — %s"):format(xPlayer.job.label or xPlayer.job.name, xPlayer.job.grade_label or tostring(xPlayer.job.grade or 0))) or nil
    return name, identifier, src, job
end

function AmbulanceLogs.Revive(data)
    data = data or {}
    local c = cfg()
    local color = (c and c.EmbedColors and c.EmbedColors.revive) or 5763719

    postEmbed("revive", {
        title = "EMS Revive",
        color = color,
        fields = {
            { name = "Medic", value = playerField(data.src, data.name, data.identifier, data.job and ("**Job:** %s"):format(data.job) or nil), inline = false },
            { name = "Patient", value = playerField(data.targetSrc, data.targetName, data.targetIdentifier), inline = false },
            { name = "Item Used", value = ("`%sx %s`"):format(tostring(data.requireAmount or 1), tostring(data.requireItem or "?")), inline = true },
            { name = "Reward", value = ("`%sx %s`"):format(tostring(data.rewardAmount or 0), tostring(data.rewardItem or "money")), inline = true },
            { name = "Recovery", value = ("`%ss`"):format(tostring(data.recovery or 120)), inline = true },
            { name = "Medic Coords", value = ("`%s`"):format(formatCoords(data.coords)), inline = false },
            { name = "Patient Coords", value = ("`%s`"):format(formatCoords(data.targetCoords)), inline = false },
        },
    }, "revive")
end

function AmbulanceLogs.Heal(data)
    data = data or {}
    local c = cfg()
    local color = (c and c.EmbedColors and c.EmbedColors.heal) or 3066993

    postEmbed("revive", {
        title = "EMS Heal",
        color = color,
        fields = {
            { name = "Medic", value = playerField(data.src, data.name, data.identifier, data.job and ("**Job:** %s"):format(data.job) or nil), inline = false },
            { name = "Patient", value = playerField(data.targetSrc, data.targetName, data.targetIdentifier), inline = false },
            { name = "Item Used", value = ("`%sx %s`"):format(tostring(data.requireAmount or 1), tostring(data.requireItem or "?")), inline = true },
            { name = "Reward", value = ("`%sx %s`"):format(tostring(data.rewardAmount or 0), tostring(data.rewardItem or "money")), inline = true },
            { name = "Medic Coords", value = ("`%s`"):format(formatCoords(data.coords)), inline = false },
            { name = "Patient Coords", value = ("`%s`"):format(formatCoords(data.targetCoords)), inline = false },
        },
    }, "heal")
end

function AmbulanceLogs.CheckIn(data)
    data = data or {}
    local c = cfg()
    local color = (c and c.EmbedColors and c.EmbedColors.checkIn) or 3447003

    postEmbed("money", {
        title = "Hospital Check-In",
        color = color,
        fields = {
            { name = "Patient", value = playerField(data.src, data.name, data.identifier), inline = false },
            { name = "Price", value = ("`%s`"):format(formatMoney(data.price)), inline = true },
            { name = "Society", value = ("`%s`"):format(data.society or "ambulance"), inline = true },
            { name = "Location Index", value = ("`%s`"):format(tostring(data.index or "?")), inline = true },
            { name = "Coords", value = ("`%s`"):format(formatCoords(data.coords)), inline = false },
        },
    }, "money")
end

function AmbulanceLogs.Fine(data)
    data = data or {}
    local c = cfg()
    local color = (c and c.EmbedColors and c.EmbedColors.fine) or 15105570

    postEmbed("money", {
        title = "Respawn / STL Fine",
        color = color,
        fields = {
            { name = "Player", value = playerField(data.src, data.name, data.identifier), inline = false },
            { name = "Fine", value = ("`%s`"):format(formatMoney(data.amount)), inline = true },
            { name = "Society", value = ("`%s`"):format(data.society or "ambulance"), inline = true },
            { name = "Paid", value = data.paid and "`Yes`" or "`No (insufficient funds)`", inline = true },
        },
    }, "money")
end

function AmbulanceLogs.Bodybag(data)
    data = data or {}
    local c = cfg()
    local color = (c and c.EmbedColors and c.EmbedColors.bodybag) or 10038562

    postEmbed("bodybag", {
        title = "Bodybag — Declared Dead",
        color = color,
        description = ("**%s** was placed in a bodybag by EMS."):format(data.targetName or "Unknown"),
        fields = {
            { name = "Medic", value = playerField(data.src, data.name, data.identifier, data.job and ("**Job:** %s"):format(data.job) or nil), inline = false },
            { name = "Deceased", value = playerField(data.targetSrc, data.targetName, data.targetIdentifier), inline = false },
            { name = "Medic Coords", value = ("`%s`"):format(formatCoords(data.coords)), inline = false },
            { name = "Target Coords", value = ("`%s`"):format(formatCoords(data.targetCoords)), inline = false },
            { name = "Distance", value = ("`%sm`"):format(tostring(data.distance or "?")), inline = true },
        },
    }, "bodybag")
end

function AmbulanceLogs.BedAdmit(data)
    data = data or {}
    local c = cfg()
    local color = (c and c.EmbedColors and c.EmbedColors.bedAdmit) or 10181046

    postEmbed("bed", {
        title = "Hospital Bed Admit",
        color = color,
        fields = {
            { name = "Medic", value = playerField(data.src, data.name, data.identifier, data.job and ("**Job:** %s"):format(data.job) or nil), inline = false },
            { name = "Patient", value = playerField(data.targetSrc, data.targetName, data.targetIdentifier), inline = false },
            { name = "Bed #", value = ("`%s`"):format(tostring(data.bedIndex or "?")), inline = true },
            { name = "Hospital", value = ("`%s`"):format(data.hospital or "?"), inline = true },
            { name = "Duration", value = ("`%s`"):format(tostring(data.time or "?")), inline = true },
            { name = "Reason", value = tostring(data.reason or "—"):sub(1, 200), inline = false },
        },
    }, "bed")
end

function AmbulanceLogs.Unbed(data)
    data = data or {}
    local c = cfg()
    local color = (c and c.EmbedColors and c.EmbedColors.unbed) or 15844367

    postEmbed("bed", {
        title = "Hospital Unbed",
        color = color,
        fields = {
            { name = "Medic", value = playerField(data.src, data.name, data.identifier, data.job and ("**Job:** %s"):format(data.job) or nil), inline = false },
            { name = "Patient", value = playerField(data.targetSrc, data.targetName, data.targetIdentifier), inline = false },
            { name = "Bed #", value = ("`%s`"):format(tostring(data.bedIndex or "?")), inline = true },
            { name = "Hospital", value = ("`%s`"):format(data.hospital or "?"), inline = true },
        },
    }, "bed")
end

function AmbulanceLogs.Bleedout(data)
    data = data or {}
    local c = cfg()
    local color = (c and c.EmbedColors and c.EmbedColors.bleedout) or 15158332

    postEmbed("sentry", {
        title = "Bleedout — Inventory Wiped",
        color = color,
        description = ("**%s** bled out. Inventory cleared."):format(data.name or "Unknown"),
        fields = {
            { name = "Player", value = playerField(data.src, data.name, data.identifier), inline = false },
            { name = "Coords", value = ("`%s`"):format(formatCoords(data.coords)), inline = false },
            { name = "Items Cleared", value = ("`%s` slots"):format(tostring(data.itemCount or "?")), inline = true },
        },
    }, "bleedout")
end

function AmbulanceLogs.Sentry(data)
    data = data or {}
    local c = cfg()
    local color = (c and c.EmbedColors and c.EmbedColors.sentry) or 15158332

    postEmbed("sentry", {
        title = ("EMS Validation Failed — %s"):format(tostring(data.system or "Unknown")),
        color = color,
        fields = {
            { name = "Medic", value = playerField(data.src, data.name, data.identifier), inline = false },
            { name = "Target", value = data.targetSrc and playerField(data.targetSrc, data.targetName, data.targetIdentifier) or "`n/a`", inline = false },
            { name = "Reason", value = ("```%s```"):format(tostring(data.reason or "Unknown"):sub(1, 400)), inline = false },
            { name = "Medic Coords", value = ("`%s`"):format(formatCoords(data.coords)), inline = true },
            { name = "Target Coords", value = ("`%s`"):format(formatCoords(data.targetCoords)), inline = true },
        },
    }, "sentry")
end

CreateThread(function()
    Wait(1500)
    if isEnabled() then
        resolveChannels()
    end
end)
