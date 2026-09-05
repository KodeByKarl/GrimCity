--[[
    cfx-keydi-gang Discord logs
    Same bot pattern as banking / EMS / business.
]]

GangLogs = GangLogs or {}

local DISCORD_API = "https://discord.com/api/v10"
local PREFIX = "[cfx-keydi-gang:Logs]"

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
        print(("^3%s^0 Create them in Discord or set ChannelIDs in Config.Logs."):format(PREFIX))
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

local function postEmbed(channelKey, embed, logTypeKey)
    if not isEnabled() then return end
    local c = cfg()
    if logTypeKey and c.LogTypes and c.LogTypes[logTypeKey] == false then return end
    if c.LogTypes and c.LogTypes[channelKey] == false then return end
    embed.footer = { text = "Pandora City • Gang" }
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

local function formatCoords(src)
    if not src or src <= 0 then return "n/a" end
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return "n/a" end
    local c = GetEntityCoords(ped)
    return ("%.2f, %.2f, %.2f"):format(c.x + 0.0, c.y + 0.0, c.z + 0.0)
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

local function fromPlayer(xPlayer)
    if not xPlayer then return "Unknown", nil, nil end
    local src = xPlayer.source
    local name = (xPlayer.getName and xPlayer.getName()) or xPlayer.name or GetPlayerName(src) or "Unknown"
    local identifier = xPlayer.identifier or (xPlayer.getIdentifier and xPlayer.getIdentifier())
    return name, identifier, src
end

local function gangExtra(gangLabel, grade)
    local parts = {}
    if gangLabel and gangLabel ~= "" then
        parts[#parts + 1] = ("**Gang:** %s"):format(gangLabel)
    end
    if grade ~= nil then
        parts[#parts + 1] = ("**Grade:** `%s`"):format(tostring(grade))
    end
    return #parts > 0 and table.concat(parts, "\n") or nil
end

function GangLogs.Money(data)
    data = data or {}
    local c = cfg()
    local action = data.action == "withdraw" and "withdraw" or "deposit"
    local color = (c and c.EmbedColors and c.EmbedColors[action]) or (action == "withdraw" and 15158332 or 5763719)

    postEmbed("money", {
        title = action == "withdraw" and "Gang Society Withdraw" or "Gang Society Deposit",
        color = color,
        fields = {
            { name = "Player", value = playerField(data.src, data.name, data.identifier, gangExtra(data.gangLabel or data.gang, data.grade)), inline = false },
            { name = "Gang", value = ("`%s`"):format(tostring(data.gang or "?")), inline = true },
            { name = "Amount", value = ("`%s`"):format(formatMoney(data.amount)), inline = true },
            { name = "Balance Before", value = ("`%s`"):format(formatMoney(data.before)), inline = true },
            { name = "Balance After", value = ("`%s`"):format(formatMoney(data.after)), inline = true },
            { name = "Coords", value = ("`%s`"):format(formatCoords(data.src)), inline = false },
        },
    }, "money")
end

function GangLogs.Roster(data)
    data = data or {}
    local c = cfg()
    local action = tostring(data.action or "roster"):lower()
    local titles = {
        hire = "Gang Hire",
        promote = "Gang Promote",
        demote = "Gang Demote",
        fire = "Gang Fire / Remove",
    }
    local color = (c and c.EmbedColors and c.EmbedColors[action]) or 3447003
    local fields = {
        { name = "Boss", value = playerField(data.src, data.name, data.identifier, gangExtra(data.gangLabel or data.gang, data.grade)), inline = false },
        { name = "Target", value = playerField(data.targetSrc, data.targetName, data.targetIdentifier), inline = false },
        { name = "Gang", value = ("`%s`"):format(tostring(data.gang or "?")), inline = true },
        { name = "Action", value = ("`%s`"):format(action), inline = true },
    }
    if data.oldGrade ~= nil or data.newGrade ~= nil then
        fields[#fields + 1] = {
            name = "Grade Change",
            value = ("`%s` → `%s`"):format(tostring(data.oldGrade or "?"), tostring(data.newGrade or "?")),
            inline = true,
        }
    end
    fields[#fields + 1] = { name = "Coords", value = ("`%s`"):format(formatCoords(data.src)), inline = false }

    postEmbed("roster", {
        title = titles[action] or "Gang Roster",
        color = color,
        fields = fields,
    }, "roster")
end

function GangLogs.Exploit(data)
    data = data or {}
    local c = cfg()
    local color = (c and c.EmbedColors and c.EmbedColors.exploit) or 15158332
    local src = data.src
    local name = data.name
    local identifier = data.identifier
    if src and src > 0 and (not name or not identifier) then
        name = name or GetPlayerName(src) or "Unknown"
        if not identifier then
            for i = 0, GetNumPlayerIdentifiers(src) - 1 do
                local id = GetPlayerIdentifier(src, i)
                if id and id:sub(1, 8) == "license:" then
                    identifier = id
                    break
                end
            end
        end
    end

    postEmbed("exploit", {
        title = "Gang Security Alert",
        color = color,
        fields = {
            { name = "Player", value = playerField(src, name, identifier), inline = false },
            { name = "Action", value = ("`%s`"):format(tostring(data.action or "?")), inline = true },
            { name = "Details", value = tostring(data.details or "n/a"), inline = false },
            { name = "Coords", value = ("`%s`"):format(formatCoords(src)), inline = false },
        },
    }, "exploit")
end

function GangLogs.ChatTemplate(data)
    data = data or {}
    local c = cfg()
    local color = (c and c.EmbedColors and c.EmbedColors.chat) or 10181046
    local messages = data.messages
    local msgText = "n/a"
    if type(messages) == "table" then
        msgText = table.concat(messages, "\n")
        if #msgText > 1000 then msgText = msgText:sub(1, 997) .. "..." end
    elseif type(messages) == "string" then
        msgText = messages
    end

    postEmbed("chat", {
        title = "Gang Announcement (/gang)",
        color = color,
        fields = {
            { name = "Player", value = playerField(data.src, data.name, data.identifier, gangExtra(data.gangLabel or data.gang, data.grade)), inline = false },
            { name = "Message", value = ("```\n%s\n```"):format(msgText), inline = false },
        },
    }, "chat")
end

function GangLogs.FromPlayer(xPlayer)
    return fromPlayer(xPlayer)
end

CreateThread(function()
    Wait(1500)
    if not isEnabled() then
        print(("^3%s^0 Disabled or missing BotToken/GuildID."):format(PREFIX))
        return
    end
    resolveChannels()
end)
