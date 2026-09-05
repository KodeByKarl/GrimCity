GangMembership = GangMembership or {}

local cacheBySrc = {} -- [src] = { identifier, gang_id, grade, claimed_car, claimed_plate }

local function Debug(msg)
    if Config.Debug then
        print(('[kodebykarl-gangsystem] %s'):format(msg))
    end
end

function GangMembership.EnsureTable()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `kbk_gang_members` (
            `identifier` VARCHAR(60) NOT NULL,
            `gang_id` VARCHAR(32) NOT NULL,
            `grade` INT NOT NULL DEFAULT 0,
            `claimed_car` TINYINT(1) NOT NULL DEFAULT 0,
            `claimed_plate` VARCHAR(12) DEFAULT NULL,
            `hired_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`identifier`),
            KEY `gang_id` (`gang_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
end

local function BuildGangObject(row)
    if not row or not row.gang_id then return nil end
    local def = Config.GetGang(row.gang_id)
    local grade = tonumber(row.grade) or 0
    local gradeInfo = Config.Grades[grade] or Config.Grades[0]
    return {
        name = row.gang_id,
        label = def and def.label or row.gang_id,
        grade = grade,
        grade_name = gradeInfo.name,
        grade_label = gradeInfo.label,
        claimed_car = row.claimed_car == true or row.claimed_car == 1,
        claimed_plate = row.claimed_plate,
    }
end

function GangMembership.ApplyState(src, row)
    local gang = BuildGangObject(row)
    local state = Player(src).state
    if state then
        state:set('gang', gang, true)
        state:set('kbkGang', gang and gang.name or nil, true)
    end

    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        xPlayer.gang = gang
        if not xPlayer.getGang then
            xPlayer.getGang = function()
                return xPlayer.gang
            end
        end
    end

    TriggerClientEvent('kodebykarl-gangsystem:client:setGang', src, gang)
    TriggerEvent('esx:setGang', src, gang)
    TriggerClientEvent('esx:setGang', src, gang)
end

function GangMembership.ClearState(src)
    local state = Player(src).state
    if state then
        state:set('gang', nil, true)
        state:set('kbkGang', nil, true)
    end
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        xPlayer.gang = nil
    end
    TriggerClientEvent('kodebykarl-gangsystem:client:setGang', src, nil)
    TriggerEvent('esx:setGang', src, nil)
    TriggerClientEvent('esx:setGang', src, nil)
end

function GangMembership.GetCached(src)
    return cacheBySrc[src]
end

function GangMembership.GetByIdentifier(identifier)
    if not identifier then return nil end
    return MySQL.single.await(
        'SELECT identifier, gang_id, grade, claimed_car, claimed_plate FROM kbk_gang_members WHERE identifier = ? LIMIT 1',
        { identifier }
    )
end

function GangMembership.LoadPlayer(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return nil end

    local row = GangMembership.GetByIdentifier(xPlayer.identifier)
    if row then
        cacheBySrc[src] = row
        GangMembership.ApplyState(src, row)
        return row
    end

    cacheBySrc[src] = nil
    GangMembership.ClearState(src)
    return nil
end

function GangMembership.UnloadPlayer(src)
    cacheBySrc[src] = nil
end

--- Hire / set gang. sourceOfTruth: 'discord' | 'admin'
function GangMembership.Hire(src, gangId, grade, reason)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return false, 'Player not loaded' end

    local def = Config.GetGang(gangId)
    if not def then return false, 'Unknown gang' end

    grade = tonumber(grade) or 0
    if not Config.Grades[grade] then grade = 0 end

    local existing = GangMembership.GetByIdentifier(xPlayer.identifier)
    if existing and existing.gang_id == gangId then
        if tonumber(existing.grade) ~= grade then
            MySQL.update.await('UPDATE kbk_gang_members SET grade = ? WHERE identifier = ?', {
                grade, xPlayer.identifier
            })
            local row = GangMembership.GetByIdentifier(xPlayer.identifier)
            cacheBySrc[src] = row
            GangMembership.ApplyState(src, row)
        end
        return true, 'already'
    end

    -- Leaving another gang first (wipe claim car)
    if existing and existing.gang_id ~= gangId then
        GangMembership.Fire(src, 'switched_gang')
    end

    MySQL.insert.await([[
        INSERT INTO kbk_gang_members (identifier, gang_id, grade, claimed_car, claimed_plate)
        VALUES (?, ?, ?, 0, NULL)
        ON DUPLICATE KEY UPDATE gang_id = VALUES(gang_id), grade = VALUES(grade)
    ]], { xPlayer.identifier, gangId, grade })

    local row = GangMembership.GetByIdentifier(xPlayer.identifier)
    cacheBySrc[src] = row
    GangMembership.ApplyState(src, row)

    TriggerClientEvent('ox_lib:notify', src, {
        title = 'GANG',
        description = ('You were hired into %s (%s).'):format(def.label, reason or 'sync'),
        type = 'success',
    })

    Debug(('Hired %s -> %s grade %s (%s)'):format(xPlayer.identifier, gangId, grade, reason or '?'))
    return true, 'hired'
end

function GangMembership.Fire(src, reason)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return false end

    local row = GangMembership.GetByIdentifier(xPlayer.identifier)
    if not row then
        cacheBySrc[src] = nil
        GangMembership.ClearState(src)
        return true
    end

    if GangVehicles and GangVehicles.WipeClaimed then
        GangVehicles.WipeClaimed(xPlayer.identifier, row.claimed_plate)
    end

    MySQL.update.await('DELETE FROM kbk_gang_members WHERE identifier = ?', { xPlayer.identifier })
    cacheBySrc[src] = nil
    GangMembership.ClearState(src)

    TriggerClientEvent('ox_lib:notify', src, {
        title = 'GANG',
        description = ('You left your gang (%s). Claimed gang vehicle removed.'):format(reason or 'left'),
        type = 'error',
    })

    Debug(('Fired %s (%s)'):format(xPlayer.identifier, reason or '?'))
    return true
end

function GangMembership.MarkClaimed(src, plate)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return false end
    MySQL.update.await(
        'UPDATE kbk_gang_members SET claimed_car = 1, claimed_plate = ? WHERE identifier = ?',
        { plate, xPlayer.identifier }
    )
    local row = GangMembership.GetByIdentifier(xPlayer.identifier)
    cacheBySrc[src] = row
    GangMembership.ApplyState(src, row)
    return true
end

function GangMembership.GetPlayerGang(src)
    local row = cacheBySrc[src]
    if not row then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            row = GangMembership.GetByIdentifier(xPlayer.identifier)
            if row then cacheBySrc[src] = row end
        end
    end
    return BuildGangObject(row)
end

exports('GetPlayerGang', GangMembership.GetPlayerGang)
exports('Hire', function(src, gangId, grade)
    return GangMembership.Hire(src, gangId, grade, 'export')
end)
exports('Fire', function(src)
    return GangMembership.Fire(src, 'export')
end)
