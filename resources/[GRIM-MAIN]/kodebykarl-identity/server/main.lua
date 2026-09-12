local ESX = exports["es_extended"]:getSharedObject()
local MAX_NAME_LENGTH = Config.Identity.MaxNameLength or 50
local hasPlayerSkins = false
local createBusy = {}

AddEventHandler('playerDropped', function()
    createBusy[source] = nil
end)

local function SanitizeName(value)
    if type(value) ~= "string" then return nil end
    value = value:gsub("^%s*(.-)%s*$", "%1")
    if value == "" or #value > MAX_NAME_LENGTH then
        return nil
    end
    return value
end

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

local function EnsureSchema()
    pcall(function()
        MySQL.query.await([[
            CREATE TABLE IF NOT EXISTS `playerskins` (
                `id` int(11) NOT NULL AUTO_INCREMENT,
                `citizenid` varchar(255) NOT NULL,
                `model` varchar(255) NOT NULL DEFAULT '',
                `skin` text NOT NULL,
                `active` tinyint(4) NOT NULL DEFAULT 1,
                PRIMARY KEY (`id`),
                KEY `citizenid` (`citizenid`),
                KEY `active` (`active`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]])
        hasPlayerSkins = true
    end)

    pcall(function()
        local col = MySQL.single.await([[
            SELECT CHARACTER_MAXIMUM_LENGTH AS len
            FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = 'users'
              AND COLUMN_NAME = 'lastname'
        ]])
        if col and tonumber(col.len) and tonumber(col.len) < MAX_NAME_LENGTH then
            MySQL.query.await(("ALTER TABLE `users` MODIFY `firstname` VARCHAR(%s) DEFAULT NULL, MODIFY `lastname` VARCHAR(%s) DEFAULT NULL"):format(MAX_NAME_LENGTH, MAX_NAME_LENGTH))
        end
    end)
end

MySQL.ready(function()
    EnsureSchema()
end)

local function GetPrimaryUser(license)
    license = NormalizeLicense(license)
    if not license then return nil end

    local hash = license:gsub("^license:", "")
    local charId = ("char1:%s"):format(license)

    local exact = MySQL.single.await("SELECT * FROM users WHERE identifier = ? LIMIT 1", { charId })
    if exact then return exact end

    local result = MySQL.query.await(
        "SELECT * FROM users WHERE identifier = ? OR identifier LIKE ? OR identifier LIKE ? ORDER BY id ASC",
        { charId, ("%%:%s"):format(hash), ("%%%s"):format(license) }
    )
    if not result or #result == 0 then return nil end

    for i = 1, #result do
        local char = result[i]
        if type(char.identifier) == "string" and char.identifier:find("^char1:", 1, false) then
            return char
        end
    end

    return result[1]
end

local function JoinPrimaryCharacter(src, isNew)
    local license = GetIdentifier(src)
    if not license then return false end

    local char = GetPrimaryUser(license)
    if not char then return false end

    TriggerEvent("esx:onPlayerJoined", src, char.identifier, nil, isNew == true)
    TriggerClientEvent("esx_identity:characterSelected", src, isNew == true, char.sex)
    return true
end

ESX.RegisterServerCallback('esx_identity:autoJoin', function(source, cb)
    local src = source
    local license = GetIdentifier(src)
    if not license then
        return cb({ ok = false, hasCharacter = false })
    end

    if JoinPrimaryCharacter(src, false) then
        return cb({ ok = true, hasCharacter = true })
    end

    cb({ ok = true, hasCharacter = false })
end)

RegisterNetEvent('esx_identity:CharacterChosen', function(charId, isNew)
    local src = source
    local identifier = GetIdentifier(src)
    if not identifier or not charId then return end

    local charData = MySQL.single.await("SELECT identifier, sex FROM users WHERE id = ?", { charId })
    if not charData then return end

    if NormalizeLicense(charData.identifier) ~= identifier then return end

    local primary = GetPrimaryUser(identifier)
    if not primary or tonumber(primary.id) ~= tonumber(charId) then return end

    TriggerEvent('esx:onPlayerJoined', src, charData.identifier, nil, isNew == true)
    TriggerClientEvent('esx_identity:characterSelected', src, isNew == true, charData.sex)
end)

ESX.RegisterServerCallback('esx_identity:createCharacter', function(source, cb, data)
    local src = source
    if createBusy[src] then
        return cb(false, "busy")
    end

    local license = GetIdentifier(src)
    local firstname = SanitizeName(data and data.firstname)
    local lastname = SanitizeName(data and data.lastname)
    if not license or not firstname or not lastname then
        return cb(false, "invalid_name")
    end

    createBusy[src] = true

    local function finish(ok, result)
        createBusy[src] = nil
        cb(ok, result)
    end

    local existing = GetPrimaryUser(license)
    if existing then
        return finish(false, "already_exists")
    end

    local charIdentifier = ("char1:%s"):format(license)
    local exact = MySQL.scalar.await("SELECT `id` FROM users WHERE `identifier` = ? LIMIT 1", { charIdentifier })
    if exact then
        return finish(false, "already_exists")
    end

    local ssn = ("%03d-%02d-%04d"):format(math.random(100, 999), math.random(10, 99), math.random(1000, 9999))
    local accounts = json.encode({ money = Config.Identity.DefaultMoney, bank = Config.Identity.DefaultBank })
    local staffGroup = "user"
    pcall(function()
        local saved = MySQL.scalar.await("SELECT `group` FROM user_groups WHERE license = ?", { license })
        if saved and saved ~= "" then
            staffGroup = saved
        end
        local hash = license:gsub("^license:", "")
        if not saved or saved == "" then
            saved = MySQL.scalar.await("SELECT `group` FROM user_groups WHERE license IN (?, ?, ?)", {
                license,
                "license2:" .. hash,
                hash,
            })
            if saved and saved ~= "" then
                staffGroup = saved
            end
        end
    end)

    local spawn = Config.Identity.DefaultSpawn
    local position = json.encode({
        x = spawn.x,
        y = spawn.y,
        z = spawn.z,
        heading = spawn.w or 169.0526,
    })

    local ok, insertIdOrErr = pcall(function()
        return MySQL.insert.await(
            'INSERT INTO users (identifier, ssn, firstname, lastname, dateofbirth, sex, height, job, job_grade, accounts, `group`, position) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            {
                charIdentifier,
                ssn,
                firstname,
                lastname,
                data.dateofbirth or '2005-01-01',
                data.sex or 'm',
                data.height or Config.Identity.DefaultHeight or 175,
                Config.Identity.DefaultJob,
                Config.Identity.DefaultGrade,
                accounts,
                staffGroup,
                position,
            }
        )
    end)

    if not ok then
        local err = tostring(insertIdOrErr or "")
        if err:find("Duplicate", 1, true) or err:find("duplicate", 1, true) then
            return finish(false, "already_exists")
        end
        print(("[kodebykarl-identity] createCharacter insert failed for %s: %s"):format(charIdentifier, err))
        return finish(false, "insert_failed")
    end

    local id = tonumber(insertIdOrErr) or 0
    if id < 1 then
        local row = MySQL.single.await("SELECT `id` FROM users WHERE `identifier` = ? LIMIT 1", { charIdentifier })
        if row and row.id then
            return finish(false, "already_exists")
        end
        return finish(false, "insert_failed")
    end

    if GetResourceState('kodebykarl-logs') == 'started' then
        pcall(function()
            exports['kodebykarl-logs']:LogCharacter({
                src = src,
                action = 'create',
                firstname = firstname,
                lastname = lastname,
                dateofbirth = data.dateofbirth,
                sex = data.sex,
                identifier = charIdentifier,
            })
        end)
    end

    finish(true, id)
end)

RegisterNetEvent('esx_identity:saveNewPlayerSpawn', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local spawn = Config.Identity.DefaultSpawn
    local coords = {
        x = spawn.x,
        y = spawn.y,
        z = spawn.z,
        heading = spawn.w or 169.0526,
    }

    xPlayer.setCoords(vector4(coords.x, coords.y, coords.z, coords.heading))
    MySQL.update('UPDATE users SET position = ? WHERE identifier = ?', {
        json.encode(coords),
        xPlayer.identifier,
    })
end)

RegisterNetEvent('esx_identity:relog', function()
    TriggerEvent('esx:playerLogout', source)
end)
