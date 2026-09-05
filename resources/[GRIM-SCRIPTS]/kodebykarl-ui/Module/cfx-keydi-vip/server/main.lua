--[[
  VIP membership — Multicharacter slots + ped menu + welcome banner hooks.
  Identifier key = normalized license:xxx (same as kodebykarl-multicharacter).
]]

local function DebugLog(msg)
    if ConfigVip and ConfigVip.Debug then
        print(("[cfx-keydi-vip] %s"):format(msg))
    end
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

local function LicenseFromSource(src)
    for _, v in ipairs(GetPlayerIdentifiers(src)) do
        local normalized = NormalizeLicense(v)
        if normalized then
            return normalized
        end
    end
    return nil
end

local function EnsureTable()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `grim_vip` (
            `identifier` VARCHAR(72) NOT NULL,
            `tier` VARCHAR(16) NOT NULL DEFAULT 'vip1',
            `label` VARCHAR(64) DEFAULT NULL,
            `started_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            `expires_at` TIMESTAMP NOT NULL,
            `auto_renew` TINYINT(1) NOT NULL DEFAULT 0,
            `granted_by` VARCHAR(64) DEFAULT NULL,
            `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ]])
end

CreateThread(function()
    Wait(500)
    pcall(EnsureTable)
end)

local function IsStaff(xPlayer)
    if not xPlayer then return false end
    local group = xPlayer.getGroup and xPlayer.getGroup() or "user"
    local allowed = ConfigVip.StaffGroups or {}
    return allowed[group] == true
end

local function TierMeta(tier)
    local tiers = ConfigVip.Tiers or {}
    return tiers[tier] or {
        label = tier or "VIP",
        perks = {},
        characterSlots = 1,
        pedMenu = false,
        welcomeBanner = false,
    }
end

local function RemainingFromExpires(expiresAt)
    if not expiresAt then
        return 0, 0, false
    end

    local expiresUnix
    if type(expiresAt) == "number" then
        expiresUnix = expiresAt
    else
        local y, m, d, H, M, S = tostring(expiresAt):match("^(%d+)%-(%d+)%-(%d+)[%sT](%d+):(%d+):(%d+)")
        if y then
            expiresUnix = os.time({
                year = tonumber(y),
                month = tonumber(m),
                day = tonumber(d),
                hour = tonumber(H),
                min = tonumber(M),
                sec = tonumber(S),
            })
        else
            return 0, 0, false
        end
    end

    local diff = expiresUnix - os.time()
    if diff <= 0 then
        return 0, 0, false
    end

    return math.floor(diff / 86400), math.floor((diff % 86400) / 3600), true
end

local function IsoFromDb(expiresAt)
    if not expiresAt then return nil end
    if type(expiresAt) == "number" then
        return os.date("!%Y-%m-%dT%H:%M:%SZ", expiresAt)
    end
    local s = tostring(expiresAt):gsub(" ", "T")
    if not s:find("Z") and not s:find("%+") then
        s = s .. "Z"
    end
    return s
end

--- Sync MultiVIP slots into kodebykarl-multicharacter table
local function SyncMulticharSlots(identifier, slots, playerName, grantedBy)
    identifier = NormalizeLicense(identifier)
    if not identifier then return end
    slots = math.max(1, math.min(3, tonumber(slots) or 1))

    pcall(function()
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
            grantedBy or "vip-system",
        })
    end)

    -- Prefer export if multicharacter exposes one later
    pcall(function()
        if GetResourceState("kodebykarl-multicharacter") == "started" then
            local exp = exports["kodebykarl-multicharacter"]
            if exp and exp.SetVipSlots then
                exp:SetVipSlots(identifier, slots, playerName, grantedBy)
            end
        end
    end)

    DebugLog(("synced slots=%s for %s"):format(slots, identifier))
end

local function GetActiveVipRow(identifier)
    identifier = NormalizeLicense(identifier)
    if not identifier then return nil end
    EnsureTable()

    local row = MySQL.single.await(
        "SELECT tier, label, expires_at, auto_renew, started_at FROM grim_vip WHERE identifier = ?",
        { identifier }
    )
    if not row then return nil end

    local days, hours, stillActive = RemainingFromExpires(row.expires_at)
    if not stillActive then
        MySQL.update.await("DELETE FROM grim_vip WHERE identifier = ?", { identifier })
        SyncMulticharSlots(identifier, 1, nil, "vip-expired")
        return nil
    end

    row._days = days
    row._hours = hours
    return row
end

local function BuildStatus(identifier)
    identifier = NormalizeLicense(identifier)
    local empty = {
        active = false,
        tier = "none",
        label = "No VIP",
        daysRemaining = 0,
        hoursRemaining = 0,
        renewsAt = nil,
        expiresAt = nil,
        autoRenew = false,
        perks = {},
        characterSlots = 1,
        pedMenu = false,
        welcomeBanner = false,
    }

    if not identifier then return empty end

    local row = GetActiveVipRow(identifier)
    if not row then return empty end

    local tier = row.tier or "vip1"
    local meta = TierMeta(tier)
    local expiresIso = IsoFromDb(row.expires_at)
    local slots = tonumber(meta.characterSlots) or 1

    return {
        active = true,
        tier = tier,
        label = row.label or meta.label or tier,
        daysRemaining = row._days or 0,
        hoursRemaining = row._hours or 0,
        renewsAt = expiresIso,
        expiresAt = expiresIso,
        autoRenew = tonumber(row.auto_renew) == 1,
        perks = meta.perks or {},
        characterSlots = slots,
        pedMenu = meta.pedMenu == true,
        welcomeBanner = meta.welcomeBanner == true,
    }
end

local function GrantVip(identifier, tier, days, autoRenew, grantedBy, playerName)
    identifier = NormalizeLicense(identifier)
    if not identifier then return false end

    tier = tier or "vip1"
    if not ConfigVip.Tiers[tier] then
        tier = "vip1"
    end
    days = math.max(1, tonumber(days) or 30)
    local meta = TierMeta(tier)
    local expires = os.date("%Y-%m-%d %H:%M:%S", os.time() + (days * 86400))

    EnsureTable()
    MySQL.insert.await([[
        INSERT INTO grim_vip (identifier, tier, label, expires_at, auto_renew, granted_by)
        VALUES (?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            tier = VALUES(tier),
            label = VALUES(label),
            expires_at = VALUES(expires_at),
            auto_renew = VALUES(auto_renew),
            granted_by = VALUES(granted_by)
    ]], {
        identifier,
        tier,
        meta.label,
        expires,
        autoRenew and 1 or 0,
        grantedBy or "system",
    })

    SyncMulticharSlots(identifier, meta.characterSlots or 1, playerName, grantedBy or "vip-system")
    return true
end

local function RevokeVip(identifier)
    identifier = NormalizeLicense(identifier)
    if not identifier then return false end
    EnsureTable()
    MySQL.update.await("DELETE FROM grim_vip WHERE identifier = ?", { identifier })
    SyncMulticharSlots(identifier, 1, nil, "vip-revoked")
    return true
end

--- Public helpers for other resources (illenium / welcomebanner / multichar)
exports("GetVipStatus", function(src)
    local license = LicenseFromSource(src)
    if not license then return nil end
    return BuildStatus(license)
end)

exports("GetVipSlotsForIdentifier", function(identifier)
    local row = GetActiveVipRow(identifier)
    if not row then return 1 end
    local meta = TierMeta(row.tier)
    return tonumber(meta.characterSlots) or 1
end)

exports("CanUsePedMenu", function(src)
    local status = BuildStatus(LicenseFromSource(src))
    return status.active and status.pedMenu == true
end)

exports("CanEditWelcomeBanner", function(src)
    local status = BuildStatus(LicenseFromSource(src))
    return status.active and status.welcomeBanner == true
end)

exports("GetVipLicense", function(src)
    return LicenseFromSource(src)
end)

exports("GrantVip", GrantVip)
exports("RevokeVip", RevokeVip)

lib.callback.register("cfx-keydi-vip:getStatus", function(source)
    return { vip = BuildStatus(LicenseFromSource(source)) }
end)

lib.callback.register("cfx-keydi-vip:canPedMenu", function(source)
    local status = BuildStatus(LicenseFromSource(source))
    return status.active and status.pedMenu == true
end)

lib.callback.register("cfx-keydi-vip:canWelcomeBanner", function(source)
    local status = BuildStatus(LicenseFromSource(source))
    return status.active and status.welcomeBanner == true
end)

RegisterCommand("setvip", function(src, args)
    if src > 0 then
        local xPlayer = ESX.GetPlayerFromId(src)
        if not IsStaff(xPlayer) then
            TriggerClientEvent("esx:showNotification", src, "No permission", "error")
            return
        end
    end

    local targetId = tonumber(args[1])
    local tier = args[2] or "vip3"
    local days = tonumber(args[3]) or 30
    local autoRenew = args[4] == "1" or args[4] == "true"

    if not targetId then
        if src > 0 then
            TriggerClientEvent("esx:showNotification", src, "Usage: /setvip [id] [tier] [days] [autorenew 0/1]", "error")
        end
        return
    end

    local target = ESX.GetPlayerFromId(targetId)
    if not target then
        if src > 0 then
            TriggerClientEvent("esx:showNotification", src, "Player offline", "error")
        end
        return
    end

    local license = LicenseFromSource(targetId)
    local staffName = src > 0 and GetPlayerName(src) or "console"
    local playerName = GetPlayerName(targetId)
    GrantVip(license, tier, days, autoRenew, staffName, playerName)

    local meta = TierMeta(tier)
    TriggerClientEvent(
        "esx:showNotification",
        targetId,
        ("VIP %s · %sd · %s slots"):format(meta.label, days, meta.characterSlots or 1),
        "success"
    )
    if src > 0 then
        TriggerClientEvent("esx:showNotification", src, ("Granted %s to ID %s"):format(tier, targetId), "success")
    end
end, false)

RegisterCommand("revokevip", function(src, args)
    if src > 0 then
        local xPlayer = ESX.GetPlayerFromId(src)
        if not IsStaff(xPlayer) then
            TriggerClientEvent("esx:showNotification", src, "No permission", "error")
            return
        end
    end

    local targetId = tonumber(args[1])
    if not targetId then
        if src > 0 then
            TriggerClientEvent("esx:showNotification", src, "Usage: /revokevip [id]", "error")
        end
        return
    end

    local target = ESX.GetPlayerFromId(targetId)
    if not target then
        if src > 0 then
            TriggerClientEvent("esx:showNotification", src, "Player offline", "error")
        end
        return
    end

    RevokeVip(LicenseFromSource(targetId))
    TriggerClientEvent("esx:showNotification", targetId, "Your VIP was revoked", "error")
    if src > 0 then
        TriggerClientEvent("esx:showNotification", src, ("Revoked VIP for ID %s"):format(targetId), "success")
    end
end, false)
