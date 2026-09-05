--[[
    cfx-cs-police Discord logs
    Same bot pattern as cfx-keydi-utils disconnectlogs / banking / business.
]]

PoliceLogs = PoliceLogs or {}

local DISCORD_API = "https://discord.com/api/v10"
local PREFIX = "[cfx-cs-police:Logs]"

local resolvedChannels = {}
local postQueue = {}
local posting = false

local function cfg()
    return Config and Config.Logs or nil
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
    embed.footer = { text = "Pandora City • Police" }
    embed.timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    enqueuePost(channelKey, { embeds = { embed } })
end

local function playerField(src, name, identifier)
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
    return table.concat(lines, "\n")
end

function PoliceLogs.FromSource(src)
    local xPlayer = ESX and ESX.GetPlayerFromId(src)
    local name = GetPlayerName(src) or "Unknown"
    local identifier = nil
    if xPlayer then
        name = xPlayer.name or (xPlayer.getName and xPlayer.getName()) or name
        identifier = xPlayer.identifier
    end
    return name, identifier
end

function PoliceLogs.License(data)
    data = data or {}
    local c = cfg()
    local granted = data.action == "grant"
    local color = granted
        and ((c and c.EmbedColors and c.EmbedColors.licenseGrant) or 5763719)
        or ((c and c.EmbedColors and c.EmbedColors.licenseRevoke) or 15158332)

    postEmbed("license", {
        title = granted and "License Granted" or "License Revoked",
        color = color,
        fields = {
            { name = "Officer", value = playerField(data.src, data.name, data.identifier), inline = false },
            { name = "Target", value = playerField(data.targetSrc, data.targetName, data.targetIdentifier), inline = false },
            { name = "License", value = ("`%s`"):format(tostring(data.license or "?")), inline = true },
            { name = "Action", value = granted and "`Grant`" or "`Revoke`", inline = true },
        },
    })
end

function PoliceLogs.Document(data)
    data = data or {}
    local c = cfg()
    local color = (c and c.EmbedColors and c.EmbedColors.docs) or 3447003

    postEmbed("docs", {
        title = data.action == "give" and "Document Copy Given" or "Document Created",
        color = color,
        fields = {
            { name = "Officer", value = playerField(data.src, data.name, data.identifier), inline = false },
            { name = "Target", value = data.targetSrc and playerField(data.targetSrc, data.targetName, data.targetIdentifier) or "`self`", inline = false },
            { name = "Document", value = ("`%s`"):format(tostring(data.docName or "Unknown"):sub(1, 100)), inline = true },
            { name = "Action", value = ("`%s`"):format(data.action or "create"), inline = true },
        },
    })
end

function PoliceLogs.Action(data)
    data = data or {}
    local c = cfg()
    local colors = c and c.EmbedColors or {}
    local kind = tostring(data.kind or "action")
    local colorMap = {
        search = colors.search or 10181046,
        id = colors.id or 3066993,
        cuff = colors.cuff or 15105570,
        uncuff = colors.uncuff or 5763719,
        gsr = colors.gsr or 15844367,
        priority = colors.priority or 15105570,
    }
    local titles = {
        search = "Player Search",
        id = "ID Check",
        cuff = "Suspect Cuffed",
        uncuff = "Suspect Uncuffed",
        gsr = "GSR Test",
        priority = "Priority Status",
    }

    local fields = {
        { name = "Officer", value = playerField(data.src, data.name, data.identifier), inline = false },
    }
    if data.targetSrc or data.targetName then
        fields[#fields + 1] = {
            name = "Target",
            value = playerField(data.targetSrc, data.targetName, data.targetIdentifier),
            inline = false,
        }
    end
    if data.detail then
        fields[#fields + 1] = { name = "Detail", value = tostring(data.detail):sub(1, 300), inline = false }
    end

    postEmbed("action", {
        title = titles[kind] or "Police Action",
        color = colorMap[kind] or 9807270,
        fields = fields,
    })
end

CreateThread(function()
    Wait(1500)
    if isEnabled() then
        resolveChannels()
        print(("^2%s^0 ready"):format(PREFIX))
    else
        print(("^3%s^0 Disabled or missing BotToken/GuildID."):format(PREFIX))
    end
end)
