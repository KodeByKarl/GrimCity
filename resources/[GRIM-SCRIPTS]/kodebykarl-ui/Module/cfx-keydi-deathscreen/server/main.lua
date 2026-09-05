local ESX = exports["es_extended"]:getSharedObject()

local recentKills = {} -- [killerIdentifier] = { { name, id, at }, ... }
local sessionKills = {} -- [src] = count this session

local function GetLicense(src)
    for _, id in ipairs(GetPlayerIdentifiers(src) or {}) do
        if id:sub(1, 8) == "license:" then
            return id
        end
    end
    return nil
end

local function CharacterName(xPlayer, src)
    if xPlayer then
        local fn = xPlayer.get and xPlayer.get("firstName")
        local ln = xPlayer.get and xPlayer.get("lastName")
        if (not fn or not ln) and xPlayer.getName then
            return xPlayer.getName()
        end
        if fn or ln then
            return (("%s %s"):format(fn or "", ln or "")):gsub("^%s+", ""):gsub("%s+$", "")
        end
    end
    return GetPlayerName(src) or ("ID " .. tostring(src))
end

local function PlayTimeLabel(xPlayer)
    -- Prefer scoreboard / playtime shop if available later
    if xPlayer and xPlayer.getMeta then
        local mins = xPlayer.getMeta("playtime") or xPlayer.getMeta("playTime")
        if mins then
            mins = tonumber(mins) or 0
            if mins >= 60 then
                return ("%dh"):format(math.floor(mins / 60))
            end
            return ("%dm"):format(mins)
        end
    end
    return "—"
end

local function KdaForIdentifier(identifier)
    local kills, deaths, kd = 0, 0, "0.00"
    if identifier then
        local ok, row = pcall(function()
            return exports["kodebykarl-ui"]:GetPlayerKDA(identifier)
        end)
        if ok and row then
            kills = tonumber(row.kills) or 0
            deaths = tonumber(row.deaths) or 0
            kd = row.kd or "0.00"
        end
    end
    return kills, deaths, kd
end

local function PushRecentKill(killerSrc, victimSrc)
    local killer = ESX.GetPlayerFromId(killerSrc)
    local victim = ESX.GetPlayerFromId(victimSrc)
    if not killer then return end

    local key = killer.identifier or GetLicense(killerSrc) or ("src:" .. killerSrc)
    recentKills[key] = recentKills[key] or {}
    table.insert(recentKills[key], 1, {
        name = CharacterName(victim, victimSrc),
        id = victimSrc,
        at = os.time(),
    })
    local limit = ConfigDeathScreen.RecentKillLimit or 5
    while #recentKills[key] > limit do
        table.remove(recentKills[key])
    end

    sessionKills[killerSrc] = (sessionKills[killerSrc] or 0) + 1
end

RegisterNetEvent("cfx-keydi-deathscreen:registerKill", function(victimSrc)
    local src = source
    victimSrc = tonumber(victimSrc)
    if not victimSrc or victimSrc == src then return end
    PushRecentKill(src, victimSrc)
end)

local function BuildKillerPayload(killerSrc, isSuicide, requesterSrc)
    killerSrc = tonumber(killerSrc) or requesterSrc
    local xKiller = ESX.GetPlayerFromId(killerSrc)
    local ped = GetPlayerPed(killerSrc)
    local health, armor = 100, 0
    if ped and ped ~= 0 then
        local h = GetEntityHealth(ped)
        local maxH = GetEntityMaxHealth(ped)
        if maxH > 100 then
            health = math.max(0, math.min(100, math.floor(((h - 100) / (maxH - 100)) * 100)))
        end
        armor = math.max(0, math.min(100, GetPedArmour(ped)))
    end

    local killsDb, _, kd = KdaForIdentifier(xKiller and xKiller.identifier)
    local kills = math.max(sessionKills[killerSrc] or 0, killsDb)

    local key = (xKiller and xKiller.identifier) or GetLicense(killerSrc) or ("src:" .. tostring(killerSrc))
    local recent = recentKills[key] or {}

    return {
        killer = {
            name = CharacterName(xKiller, killerSrc),
            id = killerSrc,
            ping = GetPlayerPing(killerSrc) or 0,
            playTime = PlayTimeLabel(xKiller),
            rank = isSuicide and "Suicide" or "—",
            kills = kills,
            kd = kd,
            health = health,
            armor = armor,
            badges = {},
        },
        recentEliminations = recent,
        killStreak = kills,
    }
end

lib.callback.register("cfx-keydi-deathscreen:getRecap", function(source, payload)
    payload = payload or {}
    local isSuicide = payload.isSuicide == true
    local killerId = tonumber(payload.killerServerId) or source
    if isSuicide then
        killerId = source
    end

    local built = BuildKillerPayload(killerId, isSuicide, source)
    if payload.combat then
        payload.combat.killStreak = built.killStreak or 0
    end
    return {
        killer = built.killer,
        recentEliminations = built.recentEliminations,
        killStreak = built.killStreak,
    }
end)

AddEventHandler("playerDropped", function()
    local src = source
    sessionKills[src] = nil
end)
