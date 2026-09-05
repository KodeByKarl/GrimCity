local ESX = exports["es_extended"]:getSharedObject()
local MAX_SLOTS = Config.Multicharacter.MaxSlots or 3
local DEFAULT_SLOTS = Config.Multicharacter.DefaultSlots or 1
local tableReady = false

local function NormalizeLicense(id)
    if type(id) ~= "string" or id == "" then return nil end

    id = id:lower():gsub("%s+", "")

    local prev
    repeat
        prev = id
        id = id:gsub("^char%d+:", "")
        id = id:gsub("^license2:", "")
        id = id:gsub("^license:", "")
        id = id:gsub("^discord:", "")
        id = id:gsub("^steam:", "")
        id = id:gsub("^fivem:", "")
        id = id:gsub("^live:", "")
        id = id:gsub("^xbl:", "")
        id = id:gsub("^ip:", "")
    until id == prev

    if id == "" then return nil end
    return "license:" .. id
end

local function GetIdentifier(src)
    for _, v in ipairs(GetPlayerIdentifiers(src)) do
        local normalized = NormalizeLicense(v)
        if normalized then
            return normalized
        end
    end
    return NormalizeLicense(GetPlayerIdentifier(src, 0))
end

local function ClampSlots(slots)
    slots = tonumber(slots) or DEFAULT_SLOTS
    if slots < 1 then slots = 1 end
    if slots > MAX_SLOTS then slots = MAX_SLOTS end
    return math.floor(slots)
end

local function EnsureSlotsTable()
    if tableReady then return true end

    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `multicharacter_slots` (
            `identifier` VARCHAR(72) NOT NULL,
            `slots` INT NOT NULL DEFAULT 1,
            `name` VARCHAR(64) DEFAULT NULL,
            `granted_by` VARCHAR(64) DEFAULT NULL,
            `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`identifier`)
        )
    ]])

    pcall(function()
        MySQL.query.await("ALTER TABLE `multicharacter_slots` ADD COLUMN `name` VARCHAR(64) DEFAULT NULL")
    end)
    pcall(function()
        MySQL.query.await("ALTER TABLE `multicharacter_slots` ADD COLUMN `granted_by` VARCHAR(64) DEFAULT NULL")
    end)
    pcall(function()
        MySQL.query.await("ALTER TABLE `multicharacter_slots` ADD COLUMN `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP")
    end)

    tableReady = true
    return true
end

local function GetPlayerSlots(identifier)
    identifier = NormalizeLicense(identifier)
    if not identifier then return DEFAULT_SLOTS end
    EnsureSlotsTable()

    local dbSlots = MySQL.scalar.await("SELECT slots FROM multicharacter_slots WHERE identifier = ?", { identifier })
    local slots = ClampSlots(dbSlots or DEFAULT_SLOTS)

    -- Active Grim VIP can raise the floor (VIP 2 = 2 slots, VIP 3+ = 3)
    if GetResourceState("kodebykarl-ui") == "started" then
        local ok, vipSlots = pcall(function()
            return exports["kodebykarl-ui"]:GetVipSlotsForIdentifier(identifier)
        end)
        if ok and vipSlots then
            slots = math.max(slots, ClampSlots(vipSlots))
        end
    end

    return slots
end

local function SetPlayerSlots(identifier, slots, playerName, staffName)
    identifier = NormalizeLicense(identifier)
    if not identifier then return nil end
    EnsureSlotsTable()

    slots = ClampSlots(slots)
    MySQL.query.await([[
        INSERT INTO multicharacter_slots (identifier, slots, name, granted_by)
        VALUES (?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            slots = VALUES(slots),
            name = COALESCE(VALUES(name), name),
            granted_by = VALUES(granted_by),
            updated_at = CURRENT_TIMESTAMP
    ]], {
        identifier,
        slots,
        playerName,
        staffName,
    })

    return slots
end

--- Optional export used by kodebykarl-ui VIP grant/revoke sync
exports("SetVipSlots", function(identifier, slots, playerName, staffName)
    return SetPlayerSlots(identifier, slots, playerName, staffName)
end)

local function IsVipStaff(xPlayer)
    if not xPlayer then return false end
    local group = xPlayer.getGroup and xPlayer.getGroup() or "user"
    local allowed = Config.Multicharacter.AllowedVipGroups or {}
    return allowed[group] == true
end

local function GetSavedSlotRows()
    EnsureSlotsTable()
    return MySQL.query.await("SELECT identifier, slots, name, granted_by, updated_at FROM multicharacter_slots") or {}
end

local function GetVipRoster()
    local onlineByLicense = {}
    local list = {}

    for _, src in ipairs(GetPlayers()) do
        local id = tonumber(src)
        local identifier = GetIdentifier(id)
        if identifier then
            local slots = GetPlayerSlots(identifier)
            local row = {
                id = id,
                name = GetPlayerName(id) or ("ID " .. id),
                identifier = identifier,
                slots = slots,
                online = true,
            }
            onlineByLicense[identifier] = true
            list[#list + 1] = row
        end
    end

    for _, saved in ipairs(GetSavedSlotRows()) do
        local identifier = NormalizeLicense(saved.identifier)
        if identifier and not onlineByLicense[identifier] then
            list[#list + 1] = {
                id = 0,
                name = (saved.name and saved.name ~= "") and saved.name or identifier,
                identifier = identifier,
                slots = ClampSlots(saved.slots),
                online = false,
                grantedBy = saved.granted_by,
            }
        end
    end

    table.sort(list, function(a, b)
        if a.online ~= b.online then
            return a.online
        end
        return (a.name or "") < (b.name or "")
    end)

    return list
end

CreateThread(function()
    EnsureSlotsTable()
end)

local function fetchCharacters(source, cb)
    local identifier = GetIdentifier(source)
    if not identifier then return cb({}, DEFAULT_SLOTS) end

    local slots = GetPlayerSlots(identifier)
    local result = MySQL.query.await("SELECT * FROM users WHERE identifier LIKE ?", { ("%%%s"):format(identifier) })

    local characters = {}
    if result then
        for _, char in ipairs(result) do
            local accounts = char.accounts and json.decode(char.accounts) or {}
            local skinData = char.skin

            if not skinData or skinData == "" then
                pcall(function()
                    local pSkin = MySQL.single.await("SELECT skin FROM playerskins WHERE citizenid = ? AND active = 1", { char.identifier })
                    if pSkin and pSkin.skin then
                        skinData = pSkin.skin
                    end
                end)
            end

            if type(skinData) == 'string' and skinData:sub(1,1) == '{' then
                pcall(function() skinData = json.decode(skinData) end)
            end

            table.insert(characters, {
                id = char.id,
                identifier = char.identifier,
                firstname = char.firstname or 'Student',
                lastname = char.lastname or 'User',
                dateofbirth = char.dateofbirth or '2005-01-01',
                sex = char.sex == 'm' and 'Male' or 'Female',
                rawSex = char.sex or 'm',
                height = char.height or 175,
                job = char.job or 'student',
                job_grade = char.job_grade or 0,
                money = accounts.money or Config.Multicharacter.DefaultMoney,
                bank = accounts.bank or Config.Multicharacter.DefaultBank,
                skin = skinData,
            })
        end
    end
    cb(characters, slots)
end

ESX.RegisterServerCallback('esx_multicharacter:SetupCharacters', function(source, cb)
    fetchCharacters(source, cb)
end)

RegisterNetEvent('esx_multicharacter:CharacterChosen', function(charId, isNew)
    local src = source
    local identifier = GetIdentifier(src)
    if not identifier or not charId then return end

    local charData = MySQL.single.await("SELECT identifier, sex FROM users WHERE id = ?", { charId })
    if charData then
        TriggerEvent('esx:onPlayerJoined', src, charData.identifier)
        TriggerClientEvent('esx_multicharacter:characterSelected', src, isNew, charData.sex)
    end
end)

ESX.RegisterServerCallback('esx_multicharacter:createCharacter', function(source, cb, data)
    local license = GetIdentifier(source)
    if not license or not data.firstname or not data.lastname then
        return cb(false)
    end

    local slots = GetPlayerSlots(license)
    local count = MySQL.scalar.await("SELECT COUNT(*) FROM users WHERE identifier LIKE ?", { ("%%%s"):format(license) }) or 0
    if count >= slots then
        return cb(false)
    end

    local charIdentifier = ("char%s:%s"):format(count + 1, license)
    local ssn = ("%03d-%02d-%04d"):format(math.random(100, 999), math.random(10, 99), math.random(1000, 9999))
    local accounts = json.encode({ money = Config.Multicharacter.DefaultMoney, bank = Config.Multicharacter.DefaultBank })

    MySQL.insert('INSERT INTO users (identifier, ssn, firstname, lastname, dateofbirth, sex, height, job, job_grade, accounts) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {
        charIdentifier,
        ssn,
        data.firstname,
        data.lastname,
        data.dateofbirth or '2005-01-01',
        data.sex or 'm',
        data.height or 175,
        Config.Multicharacter.DefaultJob,
        Config.Multicharacter.DefaultGrade,
        accounts
    }, function(id)
        cb(id and id > 0, id)
    end)
end)

ESX.RegisterServerCallback('esx_multicharacter:deleteCharacter', function(source, cb, charId)
    if charId then
        local charData = MySQL.single.await("SELECT identifier FROM users WHERE id = ?", { charId })
        if charData then
            pcall(function() MySQL.query('DELETE FROM playerskins WHERE citizenid = ?', { charData.identifier }) end)
        end
        MySQL.query('DELETE FROM users WHERE id = ?', { charId }, function()
            cb(true)
        end)
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback('esx_multicharacter:openMultivip', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not IsVipStaff(xPlayer) then
        return cb(false)
    end

    cb({
        staffName = xPlayer.getName and xPlayer.getName() or GetPlayerName(source),
        staffGroup = xPlayer.getGroup and xPlayer.getGroup() or "",
        players = GetVipRoster(),
    })
end)

ESX.RegisterServerCallback('esx_multicharacter:setVipSlots', function(source, cb, payload)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not IsVipStaff(xPlayer) then
        return cb({ ok = false, message = "Developer and Owner only." })
    end

    payload = type(payload) == "table" and payload or {}
    local slots = ClampSlots(payload.slots)
    local targetId = tonumber(payload.serverId)
    local identifier = NormalizeLicense(payload.identifier)
    local targetName = payload.name

    if targetId and GetPlayerName(targetId) then
        identifier = GetIdentifier(targetId)
        targetName = GetPlayerName(targetId)
    end

    if not identifier then
        return cb({ ok = false, message = "Could not save that player's license." })
    end

    local staffName = xPlayer.getName and xPlayer.getName() or GetPlayerName(source)
    SetPlayerSlots(identifier, slots, targetName, staffName)

    if targetId and GetPlayerName(targetId) then
        TriggerClientEvent('esx_multicharacter:slotsUpdated', targetId, slots)
        if slots <= 1 then
            TriggerClientEvent('esx:showNotification', targetId, 'Your extra character slots were removed. Slot 1 only.', 'info')
        else
            TriggerClientEvent('esx:showNotification', targetId, ('MultiVIP: you can now use %s character slots.'):format(slots), 'success')
        end
    end

    cb({
        ok = true,
        slots = slots,
        players = GetVipRoster(),
    })
end)

RegisterNetEvent('esx_multicharacter:relog', function()
    TriggerEvent('esx:playerLogout', source)
end)
