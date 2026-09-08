--[[
    cfx-keydi-phone — Contacts + Messages (persistent player-to-player)
]]

if ConfigPhone and ConfigPhone.Enabled == false then return end

local ESX = exports['es_extended']:getSharedObject()

local function EnsureTable()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `grim_phone_contacts` (
            `id` INT NOT NULL AUTO_INCREMENT,
            `owner_identifier` VARCHAR(60) NOT NULL,
            `contact_identifier` VARCHAR(60) DEFAULT NULL,
            `name` VARCHAR(80) NOT NULL,
            `number` VARCHAR(32) NOT NULL,
            `note` VARCHAR(120) DEFAULT NULL,
            `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            UNIQUE KEY `owner_number` (`owner_identifier`, `number`),
            KEY `idx_owner` (`owner_identifier`),
            KEY `idx_contact` (`contact_identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `grim_phone_messages` (
            `id` INT NOT NULL AUTO_INCREMENT,
            `sender_identifier` VARCHAR(60) NOT NULL,
            `recipient_identifier` VARCHAR(60) NOT NULL,
            `body` VARCHAR(500) NOT NULL,
            `read_at` TIMESTAMP NULL DEFAULT NULL,
            `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            KEY `idx_sender` (`sender_identifier`, `id`),
            KEY `idx_recipient` (`recipient_identifier`, `id`),
            KEY `idx_unread` (`recipient_identifier`, `read_at`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
end

CreateThread(function()
    EnsureTable()
end)

local function GetIdentifier(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return nil end
    return xPlayer.getIdentifier and xPlayer.getIdentifier() or xPlayer.identifier
end

local function PlayerDisplayName(xPlayer)
    if not xPlayer then return 'Unknown' end
    local first = xPlayer.get and (xPlayer.get('firstName') or xPlayer.get('firstname')) or nil
    local last = xPlayer.get and (xPlayer.get('lastName') or xPlayer.get('lastname')) or nil
    if first or last then
        return (('%s %s'):format(first or '', last or '')):gsub('^%s+', ''):gsub('%s+$', '')
    end
    return xPlayer.getName and xPlayer.getName() or 'Unknown'
end

local function PlayerNumber(xPlayer)
    if not xPlayer then return nil end
    if xPlayer.getSSN then
        local ssn = xPlayer.getSSN()
        if ssn and ssn ~= '' then return tostring(ssn) end
    end
    if xPlayer.ssn and xPlayer.ssn ~= '' then
        return tostring(xPlayer.ssn)
    end
    -- Stable fallback from identifier
    local id = xPlayer.getIdentifier and xPlayer.getIdentifier() or xPlayer.identifier or ''
    local hash = 0
    for i = 1, #id do
        hash = (hash * 31 + string.byte(id, i)) % 100000000
    end
    return ('555-%04d'):format(hash % 10000)
end

local function NormalizeNumber(num)
    if type(num) ~= 'string' then return nil end
    local cleaned = num:gsub('%s+', ''):sub(1, 32)
    if cleaned == '' then return nil end
    return cleaned
end

local function NormalizeName(name)
    if type(name) ~= 'string' then return nil end
    local cleaned = name:gsub('^%s+', ''):gsub('%s+$', ''):sub(1, 80)
    if cleaned == '' then return nil end
    return cleaned
end

local function MapContact(row)
    return {
        id = tonumber(row.id),
        name = row.name,
        number = row.number,
        note = row.note,
        contactIdentifier = row.contact_identifier,
        createdAt = row.created_at,
    }
end

lib.callback.register('cfx-keydi-phone:server:contacts:list', function(source)
    local identifier = GetIdentifier(source)
    if not identifier then return { ok = false, contacts = {} } end

    local rows = MySQL.query.await(
        [[SELECT id, name, number, note, contact_identifier, created_at
          FROM grim_phone_contacts
          WHERE owner_identifier = ?
          ORDER BY name ASC]],
        { identifier }
    ) or {}

    local contacts = {}
    for i = 1, #rows do
        contacts[#contacts + 1] = MapContact(rows[i])
    end
    return { ok = true, contacts = contacts }
end)

lib.callback.register('cfx-keydi-phone:server:contacts:online', function(source)
    local owner = GetIdentifier(source)
    if not owner then return { ok = false, players = {} } end

    local saved = MySQL.query.await(
        'SELECT contact_identifier FROM grim_phone_contacts WHERE owner_identifier = ? AND contact_identifier IS NOT NULL',
        { owner }
    ) or {}
    local savedSet = {}
    for i = 1, #saved do
        savedSet[saved[i].contact_identifier] = true
    end

    local players = {}
    local xPlayers = ESX.GetExtendedPlayers and ESX.GetExtendedPlayers() or {}
    if type(xPlayers) == 'table' then
        for _, xPlayer in pairs(xPlayers) do
            local sid = xPlayer.source
            local ident = xPlayer.getIdentifier and xPlayer.getIdentifier() or xPlayer.identifier
            if sid and sid ~= source and ident and not savedSet[ident] then
                players[#players + 1] = {
                    serverId = sid,
                    identifier = ident,
                    name = PlayerDisplayName(xPlayer),
                    number = PlayerNumber(xPlayer),
                }
            end
        end
    end

    table.sort(players, function(a, b)
        return (a.name or '') < (b.name or '')
    end)

    return { ok = true, players = players }
end)

lib.callback.register('cfx-keydi-phone:server:contacts:search', function(source, query)
    local owner = GetIdentifier(source)
    if not owner then return { ok = false, players = {} } end

    query = type(query) == 'string' and query:gsub('^%s+', ''):gsub('%s+$', '') or ''
    if #query < 2 then return { ok = true, players = {} } end

    local like = '%' .. query:gsub('[%\\%%_]', '') .. '%'
    local rows = MySQL.query.await([[
        SELECT identifier, firstname, lastname, ssn
        FROM users
        WHERE identifier != ?
          AND (
            firstname LIKE ?
            OR lastname LIKE ?
            OR CONCAT(IFNULL(firstname, ''), ' ', IFNULL(lastname, '')) LIKE ?
            OR ssn LIKE ?
          )
        LIMIT 25
    ]], { owner, like, like, like, like }) or {}

    local saved = MySQL.query.await(
        'SELECT contact_identifier FROM grim_phone_contacts WHERE owner_identifier = ? AND contact_identifier IS NOT NULL',
        { owner }
    ) or {}
    local savedSet = {}
    for i = 1, #saved do
        savedSet[saved[i].contact_identifier] = true
    end

    local players = {}
    for i = 1, #rows do
        local row = rows[i]
        if not savedSet[row.identifier] then
            local name = (('%s %s'):format(row.firstname or '', row.lastname or '')):gsub('^%s+', ''):gsub('%s+$', '')
            if name == '' then name = 'Unknown' end
            local number = row.ssn
            if not number or number == '' then
                local hash = 0
                local id = row.identifier or ''
                for j = 1, #id do
                    hash = (hash * 31 + string.byte(id, j)) % 100000000
                end
                number = ('555-%04d'):format(hash % 10000)
            end
            players[#players + 1] = {
                identifier = row.identifier,
                name = name,
                number = tostring(number),
                online = ESX.GetPlayerFromIdentifier(row.identifier) ~= nil,
            }
        end
    end

    return { ok = true, players = players }
end)

lib.callback.register('cfx-keydi-phone:server:contacts:add', function(source, payload)
    local owner = GetIdentifier(source)
    if not owner then return { ok = false, error = 'Not logged in' } end

    payload = type(payload) == 'table' and payload or {}
    local name = NormalizeName(payload.name)
    local number = NormalizeNumber(payload.number)
    local contactIdentifier = type(payload.contactIdentifier) == 'string' and payload.contactIdentifier or nil
    local note = type(payload.note) == 'string' and payload.note:sub(1, 120) or nil

    -- Add by online server id
    if payload.serverId then
        local target = ESX.GetPlayerFromId(tonumber(payload.serverId))
        if not target then return { ok = false, error = 'Player offline' } end
        contactIdentifier = target.getIdentifier and target.getIdentifier() or target.identifier
        name = name or PlayerDisplayName(target)
        number = number or PlayerNumber(target)
    end

    -- Add by contact identifier (DB lookup)
    if contactIdentifier and (not name or not number) then
        local row = MySQL.single.await(
            'SELECT firstname, lastname, ssn FROM users WHERE identifier = ? LIMIT 1',
            { contactIdentifier }
        )
        if row then
            if not name then
                name = (('%s %s'):format(row.firstname or '', row.lastname or '')):gsub('^%s+', ''):gsub('%s+$', '')
            end
            if not number then
                number = row.ssn and tostring(row.ssn) or nil
            end
        end
    end

    if not name then return { ok = false, error = 'Name required' } end
    if not number then return { ok = false, error = 'Number required' } end
    if contactIdentifier == owner then
        return { ok = false, error = 'Cannot add yourself' }
    end

    if contactIdentifier then
        local exists = MySQL.scalar.await(
            'SELECT id FROM grim_phone_contacts WHERE owner_identifier = ? AND contact_identifier = ? LIMIT 1',
            { owner, contactIdentifier }
        )
        if exists then return { ok = false, error = 'Already saved' } end
    end

    local numExists = MySQL.scalar.await(
        'SELECT id FROM grim_phone_contacts WHERE owner_identifier = ? AND number = ? LIMIT 1',
        { owner, number }
    )
    if numExists then return { ok = false, error = 'Number already saved' } end

    local insertId = MySQL.insert.await(
        'INSERT INTO grim_phone_contacts (owner_identifier, contact_identifier, name, number, note) VALUES (?, ?, ?, ?, ?)',
        { owner, contactIdentifier, name, number, note }
    )

    if not insertId then return { ok = false, error = 'Save failed' } end

    return {
        ok = true,
        contact = {
            id = insertId,
            name = name,
            number = number,
            note = note,
            contactIdentifier = contactIdentifier,
        },
    }
end)

lib.callback.register('cfx-keydi-phone:server:contacts:update', function(source, payload)
    local owner = GetIdentifier(source)
    if not owner then return { ok = false, error = 'Not logged in' } end

    payload = type(payload) == 'table' and payload or {}
    local id = tonumber(payload.id)
    if not id then return { ok = false, error = 'Invalid contact' } end

    local name = NormalizeName(payload.name)
    local note = payload.note
    if note ~= nil then
        note = type(note) == 'string' and note:sub(1, 120) or nil
    end

    if not name then return { ok = false, error = 'Name required' } end

    local affected = MySQL.update.await(
        'UPDATE grim_phone_contacts SET name = ?, note = COALESCE(?, note) WHERE id = ? AND owner_identifier = ?',
        { name, note, id, owner }
    )

    if not affected or affected < 1 then
        return { ok = false, error = 'Contact not found' }
    end

    return { ok = true }
end)

lib.callback.register('cfx-keydi-phone:server:contacts:remove', function(source, payload)
    local owner = GetIdentifier(source)
    if not owner then return { ok = false, error = 'Not logged in' } end

    local id = tonumber(type(payload) == 'table' and payload.id or payload)
    if not id then return { ok = false, error = 'Invalid contact' } end

    local affected = MySQL.update.await(
        'DELETE FROM grim_phone_contacts WHERE id = ? AND owner_identifier = ?',
        { id, owner }
    )

    if not affected or affected < 1 then
        return { ok = false, error = 'Contact not found' }
    end

    return { ok = true }
end)

------------------------------------------------------------
-- Messages (persistent DM threads)
------------------------------------------------------------

local MAX_BODY = 500

local function NormalizeBody(body)
    if type(body) ~= 'string' then return nil end
    local cleaned = body:gsub('^%s+', ''):gsub('%s+$', '')
    if cleaned == '' then return nil end
    if #cleaned > MAX_BODY then
        cleaned = cleaned:sub(1, MAX_BODY)
    end
    return cleaned
end

local function LookupNameNumber(identifier)
    if not identifier then
        return 'Unknown', nil
    end

    local online = ESX.GetPlayerFromIdentifier(identifier)
    if online then
        return PlayerDisplayName(online), PlayerNumber(online)
    end

    local row = MySQL.single.await(
        'SELECT firstname, lastname, ssn FROM users WHERE identifier = ? LIMIT 1',
        { identifier }
    )
    if not row then
        return 'Unknown', nil
    end

    local name = (('%s %s'):format(row.firstname or '', row.lastname or '')):gsub('^%s+', ''):gsub('%s+$', '')
    if name == '' then name = 'Unknown' end
    local number = row.ssn and tostring(row.ssn) or nil
    return name, number
end

local function ResolvePeerDisplay(owner, peer)
    local contact = MySQL.single.await(
        [[SELECT name, number FROM grim_phone_contacts
          WHERE owner_identifier = ? AND contact_identifier = ?
          LIMIT 1]],
        { owner, peer }
    )
    if contact then
        return contact.name, contact.number
    end
    return LookupNameNumber(peer)
end

local function ResolvePeerIdentifier(owner, payload)
    payload = type(payload) == 'table' and payload or {}

    if type(payload.peerIdentifier) == 'string' and payload.peerIdentifier ~= '' then
        return payload.peerIdentifier
    end

    if payload.serverId then
        local target = ESX.GetPlayerFromId(tonumber(payload.serverId))
        if target then
            return target.getIdentifier and target.getIdentifier() or target.identifier
        end
    end

    if payload.contactId then
        local row = MySQL.single.await(
            'SELECT contact_identifier, number FROM grim_phone_contacts WHERE id = ? AND owner_identifier = ? LIMIT 1',
            { tonumber(payload.contactId), owner }
        )
        if row then
            if row.contact_identifier and row.contact_identifier ~= '' then
                return row.contact_identifier
            end
            if row.number and row.number ~= '' then
                payload.number = row.number
            end
        end
    end

    local number = NormalizeNumber(payload.number)
    if number then
        local byContact = MySQL.single.await(
            [[SELECT contact_identifier FROM grim_phone_contacts
              WHERE owner_identifier = ? AND number = ? AND contact_identifier IS NOT NULL
              LIMIT 1]],
            { owner, number }
        )
        if byContact and byContact.contact_identifier then
            return byContact.contact_identifier
        end

        local bySsn = MySQL.single.await(
            'SELECT identifier FROM users WHERE ssn = ? LIMIT 1',
            { number }
        )
        if bySsn and bySsn.identifier then
            return bySsn.identifier
        end
    end

    return nil
end

lib.callback.register('cfx-keydi-phone:server:messages:conversations', function(source)
    local me = GetIdentifier(source)
    if not me then return { ok = false, conversations = {}, unreadTotal = 0 } end

    local rows = MySQL.query.await([[
        SELECT id, sender_identifier, recipient_identifier, body, read_at, created_at
        FROM grim_phone_messages
        WHERE sender_identifier = ? OR recipient_identifier = ?
        ORDER BY id DESC
        LIMIT 800
    ]], { me, me }) or {}

    local threads = {}
    local order = {}
    local unreadTotal = 0

    for i = 1, #rows do
        local row = rows[i]
        local peer = row.sender_identifier == me and row.recipient_identifier or row.sender_identifier
        if not threads[peer] then
            local name, number = ResolvePeerDisplay(me, peer)
            threads[peer] = {
                peerIdentifier = peer,
                name = name,
                number = number,
                lastBody = row.body,
                lastAt = row.created_at,
                lastFromMe = row.sender_identifier == me,
                unread = 0,
            }
            order[#order + 1] = peer
        end
        if row.recipient_identifier == me and not row.read_at then
            threads[peer].unread = (threads[peer].unread or 0) + 1
            unreadTotal = unreadTotal + 1
        end
    end

    local conversations = {}
    for i = 1, #order do
        conversations[#conversations + 1] = threads[order[i]]
    end

    return { ok = true, conversations = conversations, unreadTotal = unreadTotal }
end)

lib.callback.register('cfx-keydi-phone:server:messages:thread', function(source, payload)
    local me = GetIdentifier(source)
    if not me then return { ok = false, messages = {} } end

    payload = type(payload) == 'table' and payload or {}
    local peer = ResolvePeerIdentifier(me, payload)
    if not peer then return { ok = false, error = 'Unknown contact', messages = {} } end
    if peer == me then return { ok = false, error = 'Invalid recipient', messages = {} } end

    MySQL.update.await([[
        UPDATE grim_phone_messages
        SET read_at = CURRENT_TIMESTAMP
        WHERE recipient_identifier = ? AND sender_identifier = ? AND read_at IS NULL
    ]], { me, peer })

    local rows = MySQL.query.await([[
        SELECT id, sender_identifier, recipient_identifier, body, read_at, created_at
        FROM grim_phone_messages
        WHERE (sender_identifier = ? AND recipient_identifier = ?)
           OR (sender_identifier = ? AND recipient_identifier = ?)
        ORDER BY id ASC
        LIMIT 200
    ]], { me, peer, peer, me }) or {}

    local name, number = ResolvePeerDisplay(me, peer)
    local messages = {}
    for i = 1, #rows do
        local row = rows[i]
        messages[#messages + 1] = {
            id = tonumber(row.id),
            body = row.body,
            fromMe = row.sender_identifier == me,
            createdAt = row.created_at,
            readAt = row.read_at,
        }
    end

    return {
        ok = true,
        peerIdentifier = peer,
        name = name,
        number = number,
        messages = messages,
    }
end)

lib.callback.register('cfx-keydi-phone:server:messages:send', function(source, payload)
    local me = GetIdentifier(source)
    if not me then return { ok = false, error = 'Not logged in' } end

    payload = type(payload) == 'table' and payload or {}
    local peer = ResolvePeerIdentifier(me, payload)
    local body = NormalizeBody(payload.body)

    if not peer then return { ok = false, error = 'Recipient not found' } end
    if peer == me then return { ok = false, error = 'Cannot message yourself' } end
    if not body then return { ok = false, error = 'Empty message' } end

    local exists = MySQL.scalar.await('SELECT 1 FROM users WHERE identifier = ? LIMIT 1', { peer })
    if not exists then
        return { ok = false, error = 'Player account not found' }
    end

    local insertId = MySQL.insert.await(
        'INSERT INTO grim_phone_messages (sender_identifier, recipient_identifier, body) VALUES (?, ?, ?)',
        { me, peer, body }
    )
    if not insertId then return { ok = false, error = 'Failed to send' } end

    local xMe = ESX.GetPlayerFromId(source)
    local senderName = PlayerDisplayName(xMe)
    local senderNumber = PlayerNumber(xMe)
    local createdAt = os.date('%Y-%m-%d %H:%M:%S')

    local message = {
        id = insertId,
        body = body,
        fromMe = true,
        createdAt = createdAt,
        peerIdentifier = peer,
    }

    local target = ESX.GetPlayerFromIdentifier(peer)
    if target and target.source then
        TriggerClientEvent('cfx-keydi-phone:client:newMessage', target.source, {
            id = insertId,
            body = body,
            fromName = senderName,
            fromNumber = senderNumber,
            fromIdentifier = me,
            createdAt = createdAt,
        })
    end

    return { ok = true, message = message }
end)

lib.callback.register('cfx-keydi-phone:server:messages:unread', function(source)
    local me = GetIdentifier(source)
    if not me then return { ok = false, count = 0 } end

    local count = MySQL.scalar.await(
        'SELECT COUNT(*) FROM grim_phone_messages WHERE recipient_identifier = ? AND read_at IS NULL',
        { me }
    ) or 0

    return { ok = true, count = tonumber(count) or 0 }
end)
