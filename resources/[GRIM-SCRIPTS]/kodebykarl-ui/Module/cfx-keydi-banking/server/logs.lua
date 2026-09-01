--[[
    cfx-keydi-banking Discord logs
    Same bot-token pattern as cfx-keydi-utils disconnectlogs / comserv.
    Also posts periodic richest-player reports (ESX).
]]

BankingLogs = BankingLogs or {}

local ESX = exports["es_extended"]:getSharedObject()

local DISCORD_API = "https://discord.com/api/v10"
local PREFIX = "[cfx-keydi-banking:Logs]"

local resolvedChannels = {}
local channelsReady = false
local postQueue = {}
local posting = false

local function cfg()
    return ConfigBanking and ConfigBanking.Logs or nil
end

local function richestCfg()
    return ConfigBanking and ConfigBanking.Richest or nil
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
            if ok and type(decoded) == "table" then
                data = decoded
            end
        end
        cb(status, data)
    end, method, body and json.encode(body) or "", botHeaders())
end

local function collectIdentifiers(src)
    local out = { discord = nil, license = nil, steam = nil, fivem = nil, ip = nil }
    if not src or src <= 0 then return out end

    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
        if id then
            if id:sub(1, 8) == "discord:" then
                out.discord = id:sub(9)
            elseif id:sub(1, 8) == "license:" then
                out.license = id
            elseif id:sub(1, 6) == "steam:" then
                out.steam = id
            elseif id:sub(1, 6) == "fivem:" then
                out.fivem = id
            elseif id:sub(1, 3) == "ip:" then
                out.ip = id:sub(4)
            end
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
                        print(("^1%s^0 Failed to post (HTTP %s) → %s"):format(PREFIX, status, item.channelId))
                    end
                    done = true
                end)
                local timeout = GetGameTimer() + 10000
                while not done and GetGameTimer() < timeout do
                    Wait(50)
                end
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

    local c = cfg()
    if c and c.Debug then
        for key, channelId in pairs(resolvedChannels) do
            print(("^2%s^0 %s → %s"):format(PREFIX, key:upper(), channelId))
        end

        if #missing > 0 then
            print(("^1%s^0 Missing channels: %s"):format(PREFIX, table.concat(missing, ", ")))
            print(("^3%s^0 Create them in Discord or set ChannelIDs in banking config."):format(PREFIX))
        end
    end

    channelsReady = next(resolvedChannels) ~= nil
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
        channelsReady = true
        if c and c.Debug then
            for key, channelId in pairs(resolvedChannels) do
                print(("^2%s^0 %s → %s (manual)"):format(PREFIX, key:upper(), channelId))
            end
        end
        return
    end

    discordRequest("GET", ("/guilds/%s/channels"):format(c.GuildID), nil, function(status, data)
        if status == 200 and type(data) == "table" then
            mapGuildChannels(data)
            return
        end
        if status == 403 then
            print(("^1%s^0 Bot cannot list guild channels (HTTP 403)."):format(PREFIX))
        elseif status == 404 then
            print(("^1%s^0 GuildID not found (HTTP 404)."):format(PREFIX))
        else
            print(("^1%s^0 Failed to list guild channels (HTTP %s)."):format(PREFIX, status))
        end
    end)
end

local function postEmbed(channelKey, embed)
    if not isEnabled() then return end
    local c = cfg()
    if c.LogTypes and c.LogTypes[channelKey] == false then return end

    embed.footer = { text = "Pandora City • Banking" }
    embed.timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")

    enqueuePost(channelKey, {
        embeds = { embed },
    })
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

---@param data table
function BankingLogs.Withdraw(data)
    data = data or {}
    local c = cfg()
    local color = (c and c.EmbedColors and c.EmbedColors.withdraw) or 15158332

    postEmbed("withdraw", {
        title = "Bank Withdrawal",
        color = color,
        fields = {
            {
                name = "Player",
                value = playerField(data.src, data.name, data.identifier),
                inline = false,
            },
            { name = "Amount", value = ("`%s`"):format(formatMoney(data.amount)), inline = true },
            { name = "New Bank", value = ("`%s`"):format(formatMoney(data.bankBalance)), inline = true },
            { name = "New Cash", value = ("`%s`"):format(formatMoney(data.cashBalance)), inline = true },
        },
    })
end

---@param data table
function BankingLogs.Deposit(data)
    data = data or {}
    local c = cfg()
    local color = (c and c.EmbedColors and c.EmbedColors.deposit) or 5763719

    postEmbed("deposit", {
        title = "Bank Deposit",
        color = color,
        fields = {
            {
                name = "Player",
                value = playerField(data.src, data.name, data.identifier),
                inline = false,
            },
            { name = "Amount", value = ("`%s`"):format(formatMoney(data.amount)), inline = true },
            { name = "New Bank", value = ("`%s`"):format(formatMoney(data.bankBalance)), inline = true },
            { name = "New Cash", value = ("`%s`"):format(formatMoney(data.cashBalance)), inline = true },
        },
    })
end

---@param data table
function BankingLogs.Transfer(data)
    data = data or {}
    local c = cfg()
    local color = (c and c.EmbedColors and c.EmbedColors.transfer) or 3447003

    postEmbed("transfer", {
        title = "Bank Transfer",
        color = color,
        fields = {
            {
                name = "Sender",
                value = playerField(data.src, data.name, data.identifier),
                inline = false,
            },
            {
                name = "Receiver",
                value = playerField(data.targetSrc, data.targetName, data.targetIdentifier),
                inline = false,
            },
            { name = "Amount", value = ("`%s`"):format(formatMoney(data.amount)), inline = true },
            { name = "Method", value = ("`%s`"):format(data.method or "n/a"), inline = true },
            { name = "Offline", value = data.offline and "`Yes`" or "`No`", inline = true },
        },
    })
end

---@param data table
function BankingLogs.Society(data)
    data = data or {}
    local c = cfg()
    local color = (c and c.EmbedColors and c.EmbedColors.society) or 15844367
    local action = tostring(data.action or "deposit"):lower()
    local title = action == "withdraw" and "Society Withdrawal" or "Society Deposit"

    postEmbed("society", {
        title = title,
        color = color,
        fields = {
            {
                name = "Player",
                value = playerField(data.src, data.name, data.identifier),
                inline = false,
            },
            { name = "Society", value = ("`%s`"):format(data.societyLabel or data.society or "n/a"), inline = true },
            { name = "Action", value = ("`%s`"):format(action), inline = true },
            { name = "Amount", value = ("`%s`"):format(formatMoney(data.amount)), inline = true },
            { name = "Society Balance", value = ("`%s`"):format(formatMoney(data.societyBalance)), inline = true },
        },
    })
end

--- Parse ESX users.accounts JSON into cash / bank / dirty
---@param accountsJson string|table|nil
---@return number cash, number bank, number dirty
local function parseAccounts(accountsJson)
    local accounts = accountsJson
    if type(accountsJson) == "string" and accountsJson ~= "" then
        local ok, decoded = pcall(json.decode, accountsJson)
        if ok and type(decoded) == "table" then
            accounts = decoded
        else
            accounts = {}
        end
    elseif type(accountsJson) ~= "table" then
        accounts = {}
    end

    local cash = tonumber(accounts.money) or 0
    local bank = tonumber(accounts.bank) or 0
    local dirty = tonumber(accounts.black_money) or 0
    return cash, bank, dirty
end

--- Live override for online players (DB can be stale)
---@param rows table
local function applyOnlineOverrides(rows)
    if not rows then return end
    local byId = {}
    for i = 1, #rows do
        byId[rows[i].identifier] = rows[i]
    end

    local xPlayers = ESX.GetExtendedPlayers and ESX.GetExtendedPlayers() or {}
    for _, xPlayer in pairs(xPlayers) do
        local id = xPlayer.getIdentifier and xPlayer.getIdentifier() or xPlayer.identifier
        local row = byId[id]
        if row then
            local cash = xPlayer.getMoney and xPlayer.getMoney() or 0
            local bankAcc = xPlayer.getAccount and xPlayer.getAccount("bank")
            local dirtyAcc = xPlayer.getAccount and xPlayer.getAccount("black_money")
            local bank = bankAcc and bankAcc.money or 0
            local dirty = dirtyAcc and dirtyAcc.money or 0
            row.cash = cash
            row.bank = bank
            row.dirty = dirty
            row.total_money = cash + bank + dirty
            if xPlayer.getName then
                row.full_name = xPlayer.getName()
            end
        end
    end
end

--- Fetch richest players from ESX `users` table
---@param limit number|nil
---@return table
function BankingLogs.FetchRichestPlayers(limit)
    local rc = richestCfg() or {}
    local includeDirty = rc.IncludeDirtyMoney ~= false
    local top = tonumber(limit) or tonumber(rc.Top) or 10
    local onlyTop = rc.OnlyTop ~= false

    local sql
    if includeDirty then
        sql = [[
            SELECT
                `identifier`,
                `accounts`,
                TRIM(CONCAT(COALESCE(`firstname`, ''), ' ', COALESCE(`lastname`, ''))) AS `full_name`,
                CAST(COALESCE(JSON_VALUE(`accounts`, '$.money'), 0) AS SIGNED) AS `cash`,
                CAST(COALESCE(JSON_VALUE(`accounts`, '$.bank'), 0) AS SIGNED) AS `bank`,
                CAST(COALESCE(JSON_VALUE(`accounts`, '$.black_money'), 0) AS SIGNED) AS `dirty`,
                (
                    CAST(COALESCE(JSON_VALUE(`accounts`, '$.money'), 0) AS SIGNED)
                    + CAST(COALESCE(JSON_VALUE(`accounts`, '$.bank'), 0) AS SIGNED)
                    + CAST(COALESCE(JSON_VALUE(`accounts`, '$.black_money'), 0) AS SIGNED)
                ) AS `total_money`
            FROM `users`
            ORDER BY `total_money` DESC
        ]]
    else
        sql = [[
            SELECT
                `identifier`,
                `accounts`,
                TRIM(CONCAT(COALESCE(`firstname`, ''), ' ', COALESCE(`lastname`, ''))) AS `full_name`,
                CAST(COALESCE(JSON_VALUE(`accounts`, '$.money'), 0) AS SIGNED) AS `cash`,
                CAST(COALESCE(JSON_VALUE(`accounts`, '$.bank'), 0) AS SIGNED) AS `bank`,
                CAST(COALESCE(JSON_VALUE(`accounts`, '$.black_money'), 0) AS SIGNED) AS `dirty`,
                (
                    CAST(COALESCE(JSON_VALUE(`accounts`, '$.money'), 0) AS SIGNED)
                    + CAST(COALESCE(JSON_VALUE(`accounts`, '$.bank'), 0) AS SIGNED)
                ) AS `total_money`
            FROM `users`
            ORDER BY `total_money` DESC
        ]]
    end

    if onlyTop then
        sql = sql .. " LIMIT ?"
    end

    local rows
    if onlyTop then
        rows = MySQL.query.await(sql, { top })
    else
        rows = MySQL.query.await(sql, {})
    end

    rows = rows or {}

    -- Fallback parse if JSON_VALUE returned nulls on older MySQL
    for i = 1, #rows do
        local row = rows[i]
        if (not row.cash and not row.bank) or (row.cash == nil and row.accounts) then
            local cash, bank, dirty = parseAccounts(row.accounts)
            row.cash = cash
            row.bank = bank
            row.dirty = dirty
            row.total_money = includeDirty and (cash + bank + dirty) or (cash + bank)
        end
        row.cash = tonumber(row.cash) or 0
        row.bank = tonumber(row.bank) or 0
        row.dirty = tonumber(row.dirty) or 0
        row.total_money = tonumber(row.total_money) or (row.cash + row.bank + (includeDirty and row.dirty or 0))
        if not row.full_name or row.full_name == "" then
            row.full_name = "Unknown"
        end
    end

    applyOnlineOverrides(rows)

    table.sort(rows, function(a, b)
        return (a.total_money or 0) > (b.total_money or 0)
    end)

    if onlyTop and #rows > top then
        local trimmed = {}
        for i = 1, top do
            trimmed[i] = rows[i]
        end
        rows = trimmed
    end

    return rows
end

---@param msgType string|nil
---@param rows table|nil
local function buildRichestDescription(msgType, rows)
    rows = rows or {}
    msgType = msgType or "standard"
    local lines = {}

    for i = 1, #rows do
        local row = rows[i]
        local name = row.full_name or "Unknown"
        local total = formatMoney(row.total_money)
        local cash = formatMoney(row.cash)
        local bank = formatMoney(row.bank)
        local dirty = formatMoney(row.dirty)

        if msgType == "full" then
            lines[#lines + 1] = ("`%d.` **%s**\nIdentifier: `%s`\nCash: `%s` · Bank: `%s` · Dirty: `%s` · **Total: %s**")
                :format(i, name, row.identifier or "n/a", cash, bank, dirty, total)
        elseif msgType == "short" then
            lines[#lines + 1] = ("`%d.` %s — **%s**"):format(i, name, total)
        else
            lines[#lines + 1] = ("`%d.` **%s** — Cash `%s` · Bank `%s` · Dirty `%s` · **Total %s**")
                :format(i, name, cash, bank, dirty, total)
        end
    end

    if #lines == 0 then
        return "_No players found in database._"
    end

    local text = table.concat(lines, "\n")
    -- Discord embed description hard limit
    if #text > 4000 then
        text = text:sub(1, 3990) .. "\n…"
    end
    return text
end

---@param msgType string|nil
function BankingLogs.SendRichest(msgType)
    if not isEnabled() then return end
    local c = cfg()
    if c.LogTypes and c.LogTypes.richest == false then return end

    local rc = richestCfg() or {}
    msgType = msgType or rc.LogMessageType or "standard"
    local rows = BankingLogs.FetchRichestPlayers()
    local color = (c.EmbedColors and c.EmbedColors.richest) or 10181046
    local top = tonumber(rc.Top) or 10
    local title = (rc.OnlyTop ~= false)
        and ("Top %d Richest Players"):format(top)
        or "All Players — Wealth Report"

    postEmbed("richest", {
        title = title,
        color = color,
        description = buildRichestDescription(msgType, rows),
        fields = {
            { name = "Players Listed", value = ("`%d`"):format(#rows), inline = true },
            { name = "Includes Dirty", value = (rc.IncludeDirtyMoney ~= false) and "`Yes`" or "`No`", inline = true },
            { name = "Format", value = ("`%s`"):format(msgType), inline = true },
        },
    })
end

-- Society hooks (fired from cfx-keydi-society after successful tx)
AddEventHandler("cfx-keydi-banking:logSociety", function(data)
    BankingLogs.Society(data)
end)

CreateThread(function()
    Wait(1500)
    local c = cfg()
    if isEnabled() then
        resolveChannels()
    else
        if c and c.Debug then
            print(("^3%s^0 Disabled or missing BotToken/GuildID."):format(PREFIX))
        end
        return
    end

    local rc = richestCfg()
    if not rc or not rc.Enabled then
        if c and c.Debug then
            print(("^3%s^0 Richest auto-report disabled."):format(PREFIX))
        end
        return
    end

    local minutes = tonumber(rc.IntervalMinutes) or 30
    local interval = math.max(1, minutes) * 60 * 1000
    if c and c.Debug then
        print(("^2%s^0 Richest report every %d minute(s)."):format(PREFIX, minutes))
    end

    while true do
        Wait(interval)
        BankingLogs.SendRichest(rc.LogMessageType)
    end
end)

-- Admin command to force richest log
CreateThread(function()
    Wait(2000)
    local rc = richestCfg()
    if not rc or not rc.AdminCommand or rc.AdminCommand == "" then return end

    local cmd = rc.AdminCommand
    ESX.RegisterCommand(cmd, "admin", function()
        BankingLogs.SendRichest(rc.LogMessageType)
        print(("^2%s^0 Manual richest report sent via /%s"):format(PREFIX, cmd))
    end, true, { help = "Send top richest players log to Discord" })
end)
