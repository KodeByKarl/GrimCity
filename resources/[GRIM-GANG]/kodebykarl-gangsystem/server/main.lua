local ESX = exports['es_extended']:getSharedObject()

local GangStashAccess = {}
local PersonalStashIds = {}
local stashHookId
local esxGangsReady = false

local function ensureESXGangs()
    if esxGangsReady then return end
    if not ESX.Gangs then ESX.Gangs = {} end

    for gangName, gangConfig in pairs(Config.Gangs) do
        if not ESX.Gangs[gangName] then
            ESX.Gangs[gangName] = {
                name = gangName,
                label = gangConfig.label or gangName,
                grades = {}
            }
        end
        if not ESX.Gangs[gangName].grades then ESX.Gangs[gangName].grades = {} end
        local grades = ESX.Gangs[gangName].grades
        local bossGrade = gangConfig.bossGrade or 1
        for gradeNum = 0, 10 do
            local gStr = tostring(gradeNum)
            if not grades[gStr] then
                local isBossGrade = gradeNum >= bossGrade
                grades[gStr] = {
                    grade = gradeNum,
                    name = isBossGrade and 'boss' or 'member',
                    label = isBossGrade and 'Boss' or ('Rank ' .. gradeNum),
                    salary = 0
                }
            end
        end
    end

    esxGangsReady = true
end

local function setPlayerGang(xPlayer, gangName, grade)
    grade = tonumber(grade) or 0
    ensureESXGangs()

    if xPlayer.setGang then
        xPlayer.setGang(gangName, grade)
        return
    end

    local gangConfig = Config.Gangs[gangName] or {}
    local grades = (ESX.Gangs and ESX.Gangs[gangName] and ESX.Gangs[gangName].grades) or {}
    local gradeData = grades[tostring(grade)] or { grade = grade, name = 'member', label = 'Member' }

    xPlayer.gang = {
        name = gangName,
        label = gangConfig.label or gangName,
        grade = grade,
        grade_name = gradeData.name or 'member',
        grade_label = gradeData.label or 'Member'
    }

    if xPlayer.setMeta then
        xPlayer.setMeta('gang', { name = gangName, grade = grade })
    elseif xPlayer.metadata then
        xPlayer.metadata.gang = { name = gangName, grade = grade }
    end

    TriggerClientEvent('esx:setGang', xPlayer.source, xPlayer.gang)
    Player(xPlayer.source).state:set('gang', xPlayer.gang, true)

    local identifier = (xPlayer.getIdentifier and xPlayer.getIdentifier()) or xPlayer.identifier
    if identifier then
        MySQL.update('UPDATE `users` SET `gang` = ?, `gang_grade` = ? WHERE `identifier` = ?', { gangName, grade, identifier })
    end
end

local function formatDate(dt)
    if not dt then return 'Unknown' end
    if type(dt) == 'number' then
        return os.date('%Y-%m-%d %H:%M', math.floor(dt / 1000))
    end
    return tostring(dt)
end

local function persistOfflineGrade(identifier, gangName, grade)
    MySQL.update('UPDATE `gang_members` SET `grade` = ? WHERE `identifier` = ?', { grade, identifier })
    MySQL.update('UPDATE `users` SET `gang` = ?, `gang_grade` = ? WHERE `identifier` = ?', { gangName, grade, identifier })
end

local function registerGangStashes()
    if GetResourceState('ox_inventory') ~= 'started' then return end

    GangStashAccess = {}
    PersonalStashIds = {}

    for gangName, gang in pairs(Config.Gangs) do
        local stashes = gang.stashes
        if stashes then
            for stashKey, stash in pairs(stashes) do
                local isBossStash = stashKey == 'boss'
                local owner = (stash.owner == true and not isBossStash) and true or false

                -- Do not pass ox_inventory groups/coords. Those block bosses when:
                -- 1) gang is not in player.groups, or 2) they open from boss menu (too far from stash coords).
                -- Access is enforced in the openInventory hook + server:openStash.
                exports.ox_inventory:RegisterStash(stash.id, stash.label, stash.slots, stash.maxWeight, owner)

                GangStashAccess[stash.id] = {
                    gangName = gangName,
                    stashKey = stashKey,
                    personal = owner == true,
                    bossOnly = isBossStash,
                }

                if owner == true then
                    PersonalStashIds[#PersonalStashIds + 1] = stash.id
                end
            end
        end
    end
end

local function findGangStash(inventoryId)
    if type(inventoryId) ~= 'string' then return end

    local meta = GangStashAccess[inventoryId]
    if meta then return inventoryId, meta end

    for i = 1, #PersonalStashIds do
        local stashId = PersonalStashIds[i]
        if inventoryId:sub(1, #stashId + 1) == (stashId .. ':') then
            return stashId, GangStashAccess[stashId]
        end
    end
end

local function registerStashHook()
    if GetResourceState('ox_inventory') ~= 'started' then return end

    if stashHookId then
        pcall(function()
            exports.ox_inventory:removeHooks(stashHookId)
        end)
        stashHookId = nil
    end

    stashHookId = exports.ox_inventory:registerHook('openInventory', function(payload)
        if payload.inventoryType ~= 'stash' then return end

        local stashId, meta = findGangStash(payload.inventoryId)
        if not meta then return end

        local xPlayer = ESX.GetPlayerFromId(payload.source)
        if not xPlayer then return false end

        if not Gang.IsMember(xPlayer, meta.gangName) then
            Gang.LogExploit(payload.source, 'stash_open', ('not a member of %s (inv=%s)'):format(meta.gangName, tostring(payload.inventoryId)))
            return false
        end

        if meta.bossOnly and not Gang.IsBoss(xPlayer, meta.gangName) then
            Gang.LogExploit(payload.source, 'stash_open', ('not boss for %s (inv=%s)'):format(meta.gangName, tostring(payload.inventoryId)))
            return false
        end

        if meta.personal then
            local identifier = (xPlayer.getIdentifier and xPlayer.getIdentifier()) or xPlayer.identifier
            local expected = stashId .. ':' .. tostring(identifier)
            if tostring(payload.inventoryId) ~= expected then
                Gang.LogExploit(payload.source, 'stash_open', ('tried to open another private stash: %s (expected %s)'):format(tostring(payload.inventoryId), expected))
                return false
            end
        end
    end, {
        typeFilter = { stash = true }
    })
end

local function playerNearCoords(src, coords, maxDist)
    if not coords then return false end
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return false end
    local pos = GetEntityCoords(ped)
    return #(pos - vec3(coords.x, coords.y, coords.z)) <= (maxDist or 20.0)
end

RegisterNetEvent('cfx-keydi-gang:server:openStash', function(gangName, stashKey)
    local src = source
    if Gang.IsRateLimited(src, 750) then return end
    if not Gang.RequireTurfRegion(src) then return end
    if type(gangName) ~= 'string' or type(stashKey) ~= 'string' then return end

    local key = Gang.NormalizeName(gangName)
    local gang = Config.Gangs[key]
    if not gang then return end

    local stash = gang.stashes and gang.stashes[stashKey]
    if not stash or not stash.id then return end

    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    if not Gang.IsMember(xPlayer, key) then
        Gang.LogExploit(src, 'stash_open', ('not a member of %s (%s)'):format(key, stashKey))
        return Gang.Notify(src, 'You are not a member of this gang!', 'error')
    end

    if stashKey == 'boss' and not Gang.IsBoss(xPlayer, key) then
        Gang.LogExploit(src, 'stash_open', ('not boss for %s'):format(key))
        return Gang.Notify(src, 'Only gang bosses can open this stash!', 'error')
    end

    local stashCoords = stash.vec or stash.coords
    if not playerNearCoords(src, stashCoords, 20.0) then
        Gang.LogExploit(src, 'stash_open', ('too far from %s stash'):format(stashKey))
        return Gang.Notify(src, 'You must be at the stash!', 'error')
    end

    if GetResourceState('ox_inventory') ~= 'started' then
        return Gang.Notify(src, 'Inventory is not running.', 'error')
    end

    local opened = exports.ox_inventory:forceOpenInventory(src, 'stash', stash.id)
    if not opened then
        Gang.Notify(src, 'Could not open stash. Try again.', 'error')
    end
end)

AddEventHandler('onServerResourceStart', function(resourceName)
    if resourceName == 'ox_inventory' or resourceName == GetCurrentResourceName() then
        registerGangStashes()
        registerStashHook()
    end
end)

MySQL.ready(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `gang_members` (
            `identifier` VARCHAR(100) NOT NULL,
            `gang` VARCHAR(50) NOT NULL,
            `grade` INT NOT NULL DEFAULT 0,
            `name` VARCHAR(100) NOT NULL,
            `joined_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            `last_seen` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `gang_discord_map` (
            `identifier` VARCHAR(100) NOT NULL,
            `discord` VARCHAR(32) NOT NULL,
            `name` VARCHAR(100) NOT NULL,
            `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`identifier`),
            KEY `discord` (`discord`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    pcall(function()
        MySQL.query("ALTER TABLE `users` ADD COLUMN IF NOT EXISTS `gang` VARCHAR(50) NULL DEFAULT 'none'")
        MySQL.query("ALTER TABLE `users` ADD COLUMN IF NOT EXISTS `gang_grade` INT NULL DEFAULT 0")
    end)

    registerGangStashes()
    registerStashHook()
    ensureESXGangs()

    local xPlayers = ESX.GetExtendedPlayers()
    if not xPlayers or #xPlayers == 0 then return end

    local identifiers = {}
    local byIdentifier = {}
    for i = 1, #xPlayers do
        local xPlayer = xPlayers[i]
        local identifier = xPlayer.getIdentifier()
        identifiers[#identifiers + 1] = identifier
        byIdentifier[identifier] = xPlayer
        Gang.TrackDiscordPlayer(xPlayer.source, identifier, xPlayer.getName and xPlayer.getName() or xPlayer.name)
    end

    local rows = MySQL.query.await('SELECT `identifier`, `gang`, `grade` FROM `gang_members` WHERE `identifier` IN (?)', { identifiers }) or {}
    for i = 1, #rows do
        local row = rows[i]
        local xPlayer = byIdentifier[row.identifier]
        if xPlayer then
            setPlayerGang(xPlayer, row.gang, row.grade)
        end
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(source, xPlayer)
    local playerObj = xPlayer or ESX.GetPlayerFromId(source)
    if not playerObj then return end

    local identifier = playerObj.getIdentifier()
    Gang.TrackDiscordPlayer(source, identifier, playerObj.getName and playerObj.getName() or playerObj.name)

    MySQL.single('SELECT `gang`, `grade` FROM `gang_members` WHERE `identifier` = ?', { identifier }, function(row)
        if not row then return end
        setPlayerGang(playerObj, row.gang, row.grade)
        MySQL.update('UPDATE `gang_members` SET `last_seen` = NOW() WHERE `identifier` = ?', { identifier })
    end)
end)

local function logRoster(action, xBoss, key, targetSrc, targetName, targetIdentifier, oldGrade, newGrade)
    if not (GangLogs and GangLogs.Roster) then return end
    local bossGang = Gang.GetPlayerGang(xBoss)
    GangLogs.Roster({
        action = action,
        src = xBoss.source,
        name = xBoss.getName and xBoss.getName() or xBoss.name,
        identifier = xBoss.getIdentifier and xBoss.getIdentifier() or xBoss.identifier,
        gang = key,
        gangLabel = bossGang and bossGang.label,
        grade = bossGang and bossGang.grade,
        targetSrc = targetSrc,
        targetName = targetName,
        targetIdentifier = targetIdentifier,
        oldGrade = oldGrade,
        newGrade = newGrade,
    })
end

ESX.RegisterServerCallback('cfx-keydi-gang:server:getBossData', function(source, cb, gangName)
    if not source or source <= 0 then return cb(nil) end
    if not Gang.RequireTurfRegion(source) then return cb(nil) end
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb(nil) end

    if not Gang.IsBoss(xPlayer, gangName) then
        Gang.LogExploit(source, 'getBossData', 'Non-boss player requested boss data')
        return cb(nil)
    end

    local key = Gang.NormalizeName(gangName)
    local dbMembers = MySQL.query.await(
        'SELECT `identifier`, `name`, `grade`, `joined_at`, `last_seen` FROM `gang_members` WHERE `gang` = ?',
        { key }
    ) or {}

    local xPlayers = ESX.GetExtendedPlayers()
    local onlineById = {}
    for i = 1, #xPlayers do
        local xp = xPlayers[i]
        onlineById[(xp.getIdentifier and xp.getIdentifier()) or xp.identifier] = xp
    end

    local members = {}
    for i = 1, #dbMembers do
        local row = dbMembers[i]
        local onlinePlayer = onlineById[row.identifier]
        members[i] = {
            identifier = row.identifier,
            name = row.name,
            grade = row.grade,
            joinedAt = formatDate(row.joined_at),
            lastSeen = onlinePlayer and 'Online Now' or formatDate(row.last_seen),
            isOnline = onlinePlayer ~= nil,
            source = onlinePlayer and onlinePlayer.source or nil
        }
    end

    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    local candidatePlayers = {}
    for i = 1, #xPlayers do
        local targetPlayer = xPlayers[i]
        if targetPlayer.source ~= source then
            local tGang = Gang.GetPlayerGang(targetPlayer)
            if not tGang or Gang.NormalizeName(tGang.name) ~= key then
                local dist = #(playerCoords - GetEntityCoords(GetPlayerPed(targetPlayer.source)))
                candidatePlayers[#candidatePlayers + 1] = {
                    source = targetPlayer.source,
                    name = targetPlayer.getName(),
                    distance = math.floor(dist + 0.5),
                    nearby = dist <= 15.0,
                }
            end
        end
    end

    table.sort(candidatePlayers, function(a, b)
        return (a.distance or 999999) < (b.distance or 999999)
    end)

    cb({
        members = members,
        candidates = candidatePlayers,
    })
end)

RegisterNetEvent('cfx-keydi-gang:server:hireMember', function(targetSource, gangName)
    local src = source
    local xBoss, key = Gang.AssertBossAtMenu(src, gangName, 'hireMember')
    if not xBoss then return end

    targetSource = tonumber(targetSource)
    if not targetSource or targetSource <= 0 or targetSource == src then
        Gang.LogExploit(src, 'hireMember', 'Invalid target source: ' .. tostring(targetSource))
        return Gang.Notify(src, 'Invalid recruit target!', 'error')
    end

    local xTarget = ESX.GetPlayerFromId(targetSource)
    if not xTarget then
        return Gang.Notify(src, 'Target player is no longer online!', 'error')
    end

    local targetGang = Gang.GetPlayerGang(xTarget)
    if targetGang and Gang.NormalizeName(targetGang.name) == key then
        return Gang.Notify(src, 'Player is already in your gang!', 'warning')
    end

    local allowed, discordMsg = Gang.CanHireViaDiscord(targetSource, key)
    if not allowed then
        Gang.LogExploit(src, 'hireMember', 'Discord role check failed: ' .. tostring(discordMsg))
        return Gang.Notify(src, discordMsg or 'Discord role check failed!', 'error')
    end

    local targetIdentifier = xTarget.getIdentifier()
    local targetName = xTarget.getName()

    setPlayerGang(xTarget, key, 0)

    Gang.Notify(src, 'Hired ' .. targetName .. ' into ' .. key .. '!', 'success')
    Gang.Notify(targetSource, 'You have been hired into ' .. key .. '!', 'success')
    logRoster('hire', xBoss, key, targetSource, targetName, targetIdentifier, nil, 0)
end)

local function hireOfflineMember(identifier, name, gangKey)
    ensureESXGangs()
    MySQL.update('UPDATE `users` SET `gang` = ?, `gang_grade` = ? WHERE `identifier` = ?', { gangKey, 0, identifier })
    MySQL.query([[
        INSERT INTO `gang_members` (`identifier`, `gang`, `grade`, `name`, `joined_at`, `last_seen`)
        VALUES (?, ?, 0, ?, NOW(), NOW())
        ON DUPLICATE KEY UPDATE `gang` = ?, `grade` = 0, `name` = ?, `last_seen` = NOW()
    ]], { identifier, gangKey, name or 'Unknown', gangKey, name or 'Unknown' })
end

local function isAlreadyInGang(identifier, gangKey)
    local row = MySQL.single.await(
        'SELECT `gang` FROM `gang_members` WHERE `identifier` = ?',
        { identifier }
    )
    if row and Gang.NormalizeName(row.gang) == gangKey then
        return true
    end

    local userRow = MySQL.single.await(
        'SELECT `gang` FROM `users` WHERE `identifier` = ?',
        { identifier }
    )
    return userRow and Gang.NormalizeName(userRow.gang) == gangKey
end

---Hire by Discord ID (online anywhere, or offline if they joined the city before).
RegisterNetEvent('cfx-keydi-gang:server:hireByDiscord', function(gangName, discordRaw, preferredIdentifier)
    local src = source
    local cfg = Config.DiscordHire or {}
    local xBoss, key = Gang.AssertBossAtMenu(src, gangName, 'hireByDiscord')
    if not xBoss then return end

    if cfg.AllowOfflineHire == false then
        return Gang.Notify(src, cfg.Messages and cfg.Messages.OfflineDisabled or 'Offline hire disabled.', 'error')
    end

    local discordId = Gang.NormalizeDiscordId(discordRaw)
    if not discordId then
        return Gang.Notify(src, cfg.Messages and cfg.Messages.InvalidDiscordId or 'Invalid Discord ID.', 'error')
    end

    local allowed, discordMsg = Gang.VerifyDiscordRoleById(discordId, key)
    if not allowed then
        Gang.LogExploit(src, 'hireByDiscord', 'Discord role check failed: ' .. tostring(discordMsg))
        return Gang.Notify(src, discordMsg or 'Discord role check failed!', 'error')
    end

    -- Prefer online session if they are in the city right now
    local xOnline = Gang.FindOnlinePlayerByDiscord(discordId)
    if xOnline then
        if xOnline.source == src then
            return Gang.Notify(src, 'You cannot hire yourself!', 'error')
        end

        local targetGang = Gang.GetPlayerGang(xOnline)
        if targetGang and Gang.NormalizeName(targetGang.name) == key then
            return Gang.Notify(src, cfg.Messages and cfg.Messages.AlreadyInGang or 'Already in gang.', 'warning')
        end

        local targetIdentifier = xOnline.getIdentifier()
        local targetName = xOnline.getName and xOnline.getName() or xOnline.name
        setPlayerGang(xOnline, key, 0)
        Gang.TrackDiscordPlayer(xOnline.source, targetIdentifier, targetName)

        Gang.Notify(src, 'Hired ' .. targetName .. ' into ' .. key .. ' (online)!', 'success')
        Gang.Notify(xOnline.source, 'You have been hired into ' .. key .. '!', 'success')
        logRoster('hire', xBoss, key, xOnline.source, targetName, targetIdentifier, nil, 0)
        return
    end

    local characters = Gang.GetCharactersByDiscord(discordId)
    if #characters == 0 then
        return Gang.Notify(src, cfg.Messages and cfg.Messages.NoCharacter or 'No character found.', 'error')
    end

    local chosen = nil
    if preferredIdentifier and type(preferredIdentifier) == 'string' then
        for i = 1, #characters do
            if characters[i].identifier == preferredIdentifier then
                chosen = characters[i]
                break
            end
        end
    end

    if not chosen then
        if #characters == 1 then
            chosen = characters[1]
        else
            -- Client should re-call with preferredIdentifier after picking
            TriggerClientEvent('cfx-keydi-gang:client:pickDiscordCharacter', src, key, discordId, characters)
            return
        end
    end

    if isAlreadyInGang(chosen.identifier, key) then
        return Gang.Notify(src, cfg.Messages and cfg.Messages.AlreadyInGang or 'Already in gang.', 'warning')
    end

    hireOfflineMember(chosen.identifier, chosen.name, key)

    Gang.Notify(src, ('Hired %s into %s (offline — applies next login)!'):format(chosen.name, key), 'success')
    logRoster('hire', xBoss, key, nil, chosen.name, chosen.identifier, nil, 0)
end)

local function changeMemberGrade(src, targetIdentifier, gangName, delta, action)
    local xBoss, key = Gang.AssertBossAtMenu(src, gangName, action)
    if not xBoss then return end
    if type(targetIdentifier) ~= 'string' then return end

    if targetIdentifier == xBoss.getIdentifier() then
        return Gang.Notify(src, 'You cannot ' .. (delta > 0 and 'promote' or 'demote') .. ' yourself!', 'error')
    end

    local row = MySQL.single.await(
        'SELECT `name`, `grade` FROM `gang_members` WHERE `identifier` = ? AND `gang` = ?',
        { targetIdentifier, key }
    )
    if not row then
        return Gang.Notify(src, 'Member not found in your gang!', 'error')
    end

    local newGrade = row.grade + delta
    if delta > 0 and newGrade > 10 then
        return Gang.Notify(src, 'Member is already at maximum rank!', 'warning')
    end
    if delta < 0 and row.grade <= 0 then
        return Gang.Notify(src, 'Member cannot be demoted further!', 'error')
    end

    local xTarget = ESX.GetPlayerFromIdentifier(targetIdentifier)
    if xTarget then
        setPlayerGang(xTarget, key, newGrade)
        Gang.Notify(xTarget.source, (delta > 0 and 'You have been promoted to rank ' or 'You have been demoted to rank ') .. newGrade .. (delta > 0 and '!' or '.'), delta > 0 and 'success' or 'warning')
    else
        persistOfflineGrade(targetIdentifier, key, newGrade)
    end

    Gang.Notify(src, (delta > 0 and 'Promoted ' or 'Demoted ') .. row.name .. ' to rank ' .. newGrade .. '.', delta > 0 and 'success' or 'info')
    logRoster(action == 'promoteMember' and 'promote' or 'demote', xBoss, key, xTarget and xTarget.source or nil, row.name, targetIdentifier, row.grade, newGrade)
end

RegisterNetEvent('cfx-keydi-gang:server:promoteMember', function(targetIdentifier, gangName)
    changeMemberGrade(source, targetIdentifier, gangName, 1, 'promoteMember')
end)

RegisterNetEvent('cfx-keydi-gang:server:demoteMember', function(targetIdentifier, gangName)
    changeMemberGrade(source, targetIdentifier, gangName, -1, 'demoteMember')
end)

RegisterNetEvent('cfx-keydi-gang:server:removeMember', function(targetIdentifier, gangName)
    local src = source
    local xBoss, key = Gang.AssertBossAtMenu(src, gangName, 'removeMember')
    if not xBoss then return end
    if type(targetIdentifier) ~= 'string' then return end

    if targetIdentifier == xBoss.getIdentifier() then
        return Gang.Notify(src, 'You cannot fire yourself!', 'error')
    end

    local row = MySQL.single.await(
        'SELECT `name`, `grade` FROM `gang_members` WHERE `identifier` = ? AND `gang` = ?',
        { targetIdentifier, key }
    )
    if not row then
        return Gang.Notify(src, 'Member not found in your gang!', 'error')
    end

    MySQL.query('DELETE FROM `gang_members` WHERE `identifier` = ?', { targetIdentifier })

    local xTarget = ESX.GetPlayerFromIdentifier(targetIdentifier)
    if xTarget then
        setPlayerGang(xTarget, 'none', 0)
        Gang.Notify(xTarget.source, 'You have been removed from the gang.', 'error')
    else
        MySQL.update("UPDATE `users` SET `gang` = 'none', `gang_grade` = 0 WHERE `identifier` = ?", { targetIdentifier })
    end

    Gang.Notify(src, 'Removed ' .. row.name .. ' from the gang.', 'success')
    logRoster('fire', xBoss, key, xTarget and xTarget.source or nil, row.name, targetIdentifier, row.grade, nil)
end)
