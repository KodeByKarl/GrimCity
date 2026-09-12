local sessions = {}

local WEAPONS = {
    [0] = 'Unknown',
    [-1569615261] = 'Unarmed',
    [-1716189206] = 'Knife',
    [1737195953] = 'Nightstick',
    [1317494643] = 'Hammer',
    [-1786099057] = 'Bat',
    [-2067956739] = 'Crowbar',
    [1141786504] = 'Golf Club',
    [-102323637] = 'Bottle',
    [-1834847097] = 'Dagger',
    [-102973651] = 'Hatchet',
    [-656458692] = 'Knuckle',
    [-581044007] = 'Machete',
    [-1951375401] = 'Flashlight',
    [-538741184] = 'Switchblade',
    [-1810795771] = 'Pool Cue',
    [419712736] = 'Pipe Wrench',
    [-853065399] = 'Battle Axe',
    [940833800] = 'Stone Hatchet',
    [453432689] = 'Pistol',
    [-1075685676] = 'Pistol Mk II',
    [1593441988] = 'Combat Pistol',
    [584646201] = 'AP Pistol',
    [911657153] = 'Stun Gun',
    [-1716589765] = 'Pistol .50',
    [-1076751822] = 'SNS Pistol',
    [-2009644972] = 'SNS Pistol Mk II',
    [-771403250] = 'Heavy Pistol',
    [137902532] = 'Vintage Pistol',
    [1198879012] = 'Flare Gun',
    [-598887786] = 'Marksman Pistol',
    [-1045183535] = 'Revolver',
    [-879347409] = 'Revolver Mk II',
    [-1746263880] = 'Double Action',
    [727643628] = 'Ceramic Pistol',
    [-1853920116] = 'Navy Revolver',
    [1470379660] = 'Perico Pistol',
    [324215364] = 'Micro SMG',
    [736523883] = 'SMG',
    [2024373456] = 'SMG Mk II',
    [-270015777] = 'Assault SMG',
    [171789620] = 'Combat PDW',
    [-619010992] = 'Machine Pistol',
    [-1121678507] = 'Mini SMG',
    [1198256469] = 'Unholy Hellbringer',
    [487013001] = 'Pump Shotgun',
    [1432025498] = 'Pump Shotgun Mk II',
    [2017895192] = 'Sawed-Off Shotgun',
    [-494615257] = 'Assault Shotgun',
    [-1654528753] = 'Bullpup Shotgun',
    [984333226] = 'Heavy Shotgun',
    [-275439685] = 'Double Barrel',
    [317205821] = 'Sweeper Shotgun',
    [-1074790547] = 'Assault Rifle',
    [961495388] = 'Assault Rifle Mk II',
    [-2084633992] = 'Carbine Rifle',
    [-869043547] = 'Carbine Rifle Mk II',
    [-1357824103] = 'Advanced Rifle',
    [-1063057011] = 'Special Carbine',
    [-1768145561] = 'Special Carbine Mk II',
    [2132975508] = 'Bullpup Rifle',
    [-2066285827] = 'Bullpup Rifle Mk II',
    [1649403952] = 'Compact Rifle',
    [-1658906650] = 'Military Rifle',
    [-947031628] = 'Heavy Rifle',
    [2144528907] = 'Combat MG',
    [3686625920] = 'Combat MG Mk II',
    [1627465347] = 'Gusenberg',
    [100416529] = 'Sniper Rifle',
    [205991906] = 'Heavy Sniper',
    [1779596214] = 'Heavy Sniper Mk II',
    [-952879014] = 'Marksman Rifle',
    [1785463520] = 'Marksman Rifle Mk II',
    [-1312131151] = 'RPG',
    [1672152130] = 'Homing Launcher',
    [1119849093] = 'Minigun',
    [2138347493] = 'Firework',
    [1834241177] = 'Railgun',
    [125959754] = 'Compact Launcher',
    [-1568386805] = 'Grenade Launcher',
    [1305664598] = 'Grenade Launcher Smoke',
    [-1813897027] = 'Grenade',
    [741814745] = 'Sticky Bomb',
    [-1420407917] = 'Proximity Mine',
    [-1600701090] = 'BZ Gas',
    [615608432] = 'Molotov',
    [101631238] = 'Fire Extinguisher',
    [883325847] = 'Petrol Can',
    [1233104067] = 'Flare',
    [600439132] = 'Ball',
    [126349499] = 'Snowball',
    [-37975472] = 'Smoke Grenade',
    [-1169823560] = 'Pipe Bomb',
    [-1168940174] = 'Hazard Can',
    [539292904] = 'Explosion',
    [-842959696] = 'Fall',
    [133987706] = 'Rammed',
    [-1553120962] = 'Run Over',
    [341774354] = 'Heli Crash',
    [-10959621] = 'Drowning',
    [1936677264] = 'Drowning (Vehicle)',
    [-544306709] = 'Fire',
    [1223143800] = 'Barbed Wire',
    [-1090446315] = 'Electric Fence',
}

local function weaponLabel(hash)
    hash = tonumber(hash)
    if not hash then return 'Unknown' end
    return WEAPONS[hash] or ('Hash %s'):format(hash)
end

local function playerCount()
    return #GetPlayers(), GetConvarInt('sv_maxclients', 128)
end

local function rememberSession(src)
    src = tonumber(src)
    if not src or src <= 0 then return end
    sessions[src] = {
        at = os.time(),
        name = GetPlayerName(src) or 'Unknown',
        identifiers = CollectIdentifiers(src),
    }
end

-- ── JOIN ──────────────────────────────────────────────────────────────────

AddEventHandler('playerJoining', function()
    local src = source
    rememberSession(src)
    if not LogsEnabled() or Config.Types.join == false then return end

    local online, maxClients = playerCount()
    WriteLog('join', {
        title = 'Player Joined',
        player = src,
        fields = {
            { name = 'Ping', value = ('`%s ms`'):format(GetPlayerPing(src) or 0), inline = true },
            { name = 'Players', value = ('`%s / %s`'):format(online, maxClients), inline = true },
        },
    })
end)

-- ── LEAVE ─────────────────────────────────────────────────────────────────

AddEventHandler('playerDropped', function(reason)
    local src = source
    if not LogsEnabled() or Config.Types.leave == false then
        sessions[src] = nil
        return
    end

    local sess = sessions[src]
    local snap = PlayerSnapshot(src)
    if sess then
        snap.displayName = sess.name or snap.displayName
        snap.discord = snap.discord or (sess.identifiers and sess.identifiers.discord)
        snap.license = snap.license or (sess.identifiers and sess.identifiers.license)
        snap.steam = snap.steam or (sess.identifiers and sess.identifiers.steam)
        snap.fivem = snap.fivem or (sess.identifiers and sess.identifiers.fivem)
    end

    local duration = sess and FormatDuration(os.time() - sess.at) or 'n/a'
    local online, maxClients = playerCount()
    WriteLog('leave', {
        title = 'Player Left',
        player = snap,
        fields = {
            { name = 'Reason', value = tostring(reason or 'Unknown'):sub(1, 200), inline = false },
            { name = 'Session', value = ('`%s`'):format(duration), inline = true },
            { name = 'Players', value = ('`%s / %s`'):format(math.max(0, online - 1), maxClients), inline = true },
        },
    })
    sessions[src] = nil
end)

-- ── CHARACTER ─────────────────────────────────────────────────────────────

local function characterFields(xPlayer, extra)
    local fields = extra or {}
    if not xPlayer then return fields end
    local first = xPlayer.get and xPlayer.get('firstName') or xPlayer.variables and xPlayer.variables.firstName
    local last = xPlayer.get and xPlayer.get('lastName') or xPlayer.variables and xPlayer.variables.lastName
    local dob = xPlayer.get and xPlayer.get('dateofbirth') or xPlayer.variables and xPlayer.variables.dateofbirth
    local sex = xPlayer.get and xPlayer.get('sex') or xPlayer.variables and xPlayer.variables.sex
    local sexLabel = (sex == 'm' or sex == 'male') and 'Male' or (sex == 'f' or sex == 'female') and 'Female' or (sex or 'n/a')
    local lines = {}
    if first or last then
        lines[#lines + 1] = ('Name: %s %s'):format(first or '', last or '')
    end
    if dob then
        lines[#lines + 1] = ('DOB: %s'):format(dob)
    end
    lines[#lines + 1] = ('Sex: %s'):format(sexLabel)
    if xPlayer.job then
        lines[#lines + 1] = ('Job: %s (%s)'):format(
            xPlayer.job.label or xPlayer.job.name or 'Unemployed',
            xPlayer.job.grade_label or tostring(xPlayer.job.grade or 0)
        )
    end
    if xPlayer.identifier then
        lines[#lines + 1] = ('Slot: `%s`'):format(xPlayer.identifier)
    end
    fields[#fields + 1] = { name = 'Character', value = table.concat(lines, '\n'), inline = false }
    return fields
end

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer, isNew)
    local src = playerId or (xPlayer and xPlayer.source)
    if not src then return end
    rememberSession(src)
    if not LogsEnabled() or Config.Types.character == false then return end
    if MarkRecent(src, 'character-load', 4000) then return end

    WriteLog('character', {
        title = isNew and 'Character Created and Loaded' or 'Character Loaded',
        player = src,
        fields = characterFields(xPlayer, {
            { name = 'New Character', value = isNew and '`Yes`' or '`No`', inline = true },
        }),
    })
end)

exports('LogCharacter', function(data)
    data = data or {}
    local src = data.src or data.source
    local action = tostring(data.action or 'update'):lower()
    local titles = {
        create = 'Character Created',
        delete = 'Character Deleted',
        load = 'Character Loaded',
        select = 'Character Selected',
        update = 'Character Updated',
    }
    if action == 'load' or action == 'select' then
        if MarkRecent(src, 'character-load', 4000) then return false end
    else
        MarkRecent(src, 'character-' .. action, 2000)
    end

    local fields = {
        { name = 'Action', value = ('`%s`'):format(action), inline = true },
    }
    if data.firstname or data.lastname then
        local charLines = {
            ('Name: %s %s'):format(data.firstname or '', data.lastname or ''),
        }
        if data.dateofbirth then
            charLines[#charLines + 1] = ('DOB: %s'):format(data.dateofbirth)
        end
        if data.sex then
            charLines[#charLines + 1] = ('Sex: %s'):format(data.sex == 'm' and 'Male' or data.sex == 'f' and 'Female' or data.sex)
        end
        if data.identifier then
            charLines[#charLines + 1] = ('Slot: `%s`'):format(data.identifier)
        end
        fields[#fields + 1] = {
            name = 'Character',
            value = table.concat(charLines, '\n'),
            inline = false,
        }
    elseif data.identifier then
        fields[#fields + 1] = { name = 'Slot', value = ('`%s`'):format(data.identifier), inline = false }
    end

    return WriteLog('character', {
        title = titles[action] or 'Character',
        player = src,
        fields = fields,
    })
end)

-- ── DEATH ─────────────────────────────────────────────────────────────────

exports('LogDeath', function(data)
    data = data or {}
    local src = data.src or data.source
    if MarkRecent(src, 'death', 4000) then return false end

    local fields = {}
    if data.killerSrc and tonumber(data.killerSrc) and tonumber(data.killerSrc) > 0 and tonumber(data.killerSrc) ~= tonumber(src) then
        fields[#fields + 1] = {
            name = 'Killer',
            value = FormatPlayerBlock(data.killerSrc),
            inline = false,
        }
        fields[#fields + 1] = { name = 'Type', value = '`Player`', inline = true }
    else
        fields[#fields + 1] = { name = 'Type', value = data.suicide and '`Suicide`' or '`Environment`', inline = true }
    end
    fields[#fields + 1] = { name = 'Cause', value = ('`%s`'):format(data.cause or weaponLabel(data.deathCause)), inline = true }
    if data.distance then
        fields[#fields + 1] = { name = 'Distance', value = ('`%s m`'):format(data.distance), inline = true }
    end

    return WriteLog('death', {
        title = 'Player Death',
        player = src,
        playerLabel = 'Victim',
        fields = fields,
        coords = data.coords or data.victimCoords,
    })
end)

RegisterNetEvent('esx:onPlayerDeath', function(data)
    local src = source
    if not LogsEnabled() or Config.Types.death == false then return end
    data = type(data) == 'table' and data or {}
    local killer = tonumber(data.killerServerId)
    local suicide = killer and killer == src
    exports['kodebykarl-logs']:LogDeath({
        src = src,
        killerSrc = (killer and killer > 0 and not suicide) and killer or nil,
        suicide = suicide,
        deathCause = data.deathCause,
        distance = data.distance,
        victimCoords = data.victimCoords,
        coords = data.victimCoords,
    })
end)

-- ── REVIVE ────────────────────────────────────────────────────────────────

exports('LogRevive', function(data)
    data = data or {}
    local src = data.src or data.source or data.targetSrc
    if MarkRecent(src, 'revive', 3500) then return false end

    local method = tostring(data.method or 'system')
    local methodLabels = {
        ems = 'EMS',
        admin = 'Admin',
        hospital = 'Hospital',
        txadmin = 'txAdmin',
        pvp = 'PvP Reset',
        system = 'System',
    }

    local fields = {
        { name = 'Method', value = ('`%s`'):format(methodLabels[method] or method), inline = true },
    }
    if data.revivedBy then
        fields[#fields + 1] = {
            name = 'Revived By',
            value = FormatPlayerBlock(data.revivedBy),
            inline = false,
        }
    elseif data.revivedByName then
        fields[#fields + 1] = {
            name = 'Revived By',
            value = tostring(data.revivedByName),
            inline = false,
        }
    end
    if data.item then
        fields[#fields + 1] = {
            name = 'Item',
            value = ('`%sx %s`'):format(tostring(data.itemAmount or 1), data.item),
            inline = true,
        }
    end

    return WriteLog('revive', {
        title = 'Player Revived',
        player = src,
        fields = fields,
        coords = data.coords or data.targetCoords or (src and PlayerCoords(src)),
    })
end)

RegisterNetEvent('cfx-keydi-ambulance:setPlayerDeathStatus', function(isDead, reason)
    if isDead ~= false then return end
    if reason == 'restore' then return end
    local src = source
    if not LogsEnabled() or Config.Types.revive == false then return end
    if WasRecent(src, 'revive', 3500) then return end
    exports['kodebykarl-logs']:LogRevive({
        src = src,
        method = 'system',
    })
end)

AddEventHandler('txAdmin:events:healedPlayer', function(eventData)
    if type(eventData) ~= 'table' or type(eventData.id) ~= 'number' then return end
    if not LogsEnabled() or Config.Types.revive == false then return end
    exports['kodebykarl-logs']:LogRevive({
        src = eventData.id,
        method = 'txadmin',
        revivedByName = 'txAdmin',
    })
end)
