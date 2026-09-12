Config = {}

local txAdminLocale = GetConvar("txAdmin-locale", "en")
local esxLocale = GetConvar("esx:locale", "invalid")
Config.Locale = (esxLocale ~= "invalid") and esxLocale or (txAdminLocale ~= "custom" and txAdminLocale) or "en"

-- When a key is missing from the active locale, fall back to the English string
-- instead of returning a placeholder. Set convar "esx:localeFallback" to "false"
-- to keep the placeholder (useful when authoring a new translation).
Config.LocaleFallback = GetConvar("esx:localeFallback", "true") ~= "false"

-- For ox inventory, this will automatically be adjusted, do not change! For other inventories, leave as false unless specifically instructed to change.
Config.CustomInventory = false

Config.Status = {
    -- 100 ticks * 54s = 5400s = 1h 30m from 100 → 0 (rate 1 per tick)
    client_interval = 54000, -- how often the client sends a status update request
    hunger_rate = 1,         -- hunger lost per update interval
    thirst_rate = 1,         -- thirst lost per update interval
}

Config.StatusSecure = {
    enabled = false,          -- rollback-only health/armor check. Electron AC handles bans.
    stressAbsPerMinute = 48,  -- max absolute stress changes allowed per minute
    healthCheckInterval = 1000,
    healthNoise = 4,
    armorNoise = 2,
    minHealthFlag = 15,
    minArmorFlag = 10,
    budgetTtlMs = 8000,
    loadGraceMs = 8000,
    spawnGraceMs = 5000,
    discordWebhook = '',
}

Config.Accounts = {
    bank = {
        label = TranslateCap("account_bank"),
        round = true,
    },
    black_money = {
        label = TranslateCap("account_black_money"),
        round = true,
    },
    money = {
        label = TranslateCap("account_money"),
        round = true,
    },
}

Config.StartingAccountMoney = {
    money = 50000,
    bank = 250000,
}

Config.StartingInventoryItems = false -- table/false

Config.DefaultSpawns = {              -- If you want to have more spawn positions and select them randomly uncomment commented code or add more locations
    { x = -267.7385, y = -957.1590, z = 31.2231, heading = 169.0526 },
    --{x = 224.9865, y = -865.0871, z = 30.2922, heading = 1.0},
    --{x = 227.8436, y = -866.0400, z = 30.2922, heading = 1.0},
    --{x = 230.6051, y = -867.1450, z = 30.2922, heading = 1.0},
    --{x = 233.5459, y = -868.2626, z = 30.2922, heading = 1.0}
}

---@deprecated Use `Config.CommandPermissions` as the single source of truth for command ACLs.
--- Kept temporarily for backwards compatibility with external resources that still read `Config.AdminGroups`.
--- Will be removed in ESX 1.15.
Config.AdminGroups = {
    ["developer"] = true,
    ["owner"] = true,
    ["superadmin"] = true,
    ["admin"] = true,
    ["mod"] = true,
}

Config.CommandPermissions = {
    ["setcoords"]           = { "developer", "owner", "superadmin", "admin" }, -- /setcoords, /tp
    ["setjob"]              = { "developer", "owner", "superadmin", "admin" },
    ["setgang"]             = { "developer", "owner", "superadmin", "admin" },
    ["car"]                 = { "developer", "owner", "superadmin", "admin" },
    ["cardel"]              = { "developer", "owner", "superadmin", "admin" }, -- /cardel, /dv
    ["fix"]                 = { "developer", "owner", "superadmin", "admin" }, -- /fix, /repair
    ["setaccountmoney"]     = { "developer", "owner", "superadmin" },
    ["giveaccountmoney"]    = { "developer", "owner", "superadmin" },
    ["removeaccountmoney"]  = { "developer", "owner", "superadmin" },
    ["giveitem"]            = { "developer", "owner", "superadmin" },
    ["giveweapon"]          = { "developer", "owner", "superadmin" },
    ["giveammo"]            = { "developer", "owner", "superadmin" },
    ["giveweaponcomponent"] = { "developer", "owner", "superadmin" },
    ["clearall"]            = { "developer", "owner", "superadmin", "admin" }, -- /clearall, /clsall
    ["refreshjobs"]         = { "developer", "owner", "superadmin", "admin" },
    ["refreshitems"]        = { "developer", "owner", "superadmin", "admin" },
    ["clearinventory"]      = { "developer", "owner", "superadmin" },
    ["clearloadout"]        = { "developer", "owner", "superadmin" },
    ["setgroup"]            = { "developer", "owner", "superadmin" },
    ["save"]                = { "developer", "owner", "superadmin", "admin" },
    ["saveall"]             = { "developer", "owner", "superadmin", "admin" },
    ["goto"]                = { "developer", "owner", "superadmin", "admin" },
    ["bring"]               = { "developer", "owner", "superadmin", "admin" },
    ["kill"]                = { "developer", "owner", "superadmin", "admin" },
    ["revive"]              = { "developer", "owner", "superadmin", "admin" },
    ["heal"]                = { "developer", "owner", "superadmin", "admin" },
    ["freeze"]              = { "developer", "owner", "superadmin", "admin" },
    ["unfreeze"]            = { "developer", "owner", "superadmin", "admin" },
    ["setdim"]              = { "developer", "owner", "superadmin", "admin" }, -- /setdim, /setbucket
    ["players"]             = { "developer", "owner", "superadmin", "admin" },
    ["noclip"]              = { "developer", "owner", "superadmin", "admin" },
    ["tpm"]                 = { "developer", "owner", "superadmin", "admin" },
    ["coords"]              = { "developer", "owner", "superadmin", "admin" },
    ["clear"]               = { "user", "developer", "owner", "superadmin", "admin" }, -- /clear, /cls
    ["group"]               = { "user", "developer", "owner", "superadmin", "admin" },
    ["job"]                 = { "user", "developer", "owner", "superadmin", "admin" },
    ["info"]                = { "user", "developer", "owner", "superadmin", "admin" },
    ["playtime"]            = { "user", "developer", "owner", "superadmin", "admin" },
}

Config.ValidCharacterSets = { -- Only enable additional charsets if your server is multilingual. By default everything is false.
    ['el'] = false,           -- Greek
    ['sr'] = false,           -- Cyrillic
    ['he'] = false,           -- Hebrew
    ['ar'] = false,           -- Arabic
    ['zh-cn'] = false         -- Chinese, Japanese, Korean
}

Config.EnablePaycheck = true           -- enable paycheck
Config.LogPaycheck = false             -- Logs paychecks to a nominated Discord channel via webhook (default is false)
Config.EnableSocietyPayouts = false    -- pay from the society account that the player is employed at? Requirement: esx_society
Config.MaxWeight = 50                  -- the max inventory weight without a backpack
Config.PaycheckInterval = 30 * 60000   -- how often to receive paychecks in milliseconds (every 30 minutes)
Config.SaveDeathStatus = true          -- Save the death status of a player
Config.EnableDebug = false             -- Use Debug options?

Config.DefaultJobDuty = true           -- A players default duty status when changing jobs
Config.OffDutyPaycheckMultiplier = 0.5 -- The multiplier for off duty paychecks. 0.5 = 50% of the on duty paycheck

-- Single character per license via kodebykarl-identity (no character-select UI).
Config.Multichar = GetResourceState("kodebykarl-identity") ~= "missing"
Config.Identity = true      -- Load firstname/lastname/DOB from users; new players register once on join
Config.DistanceGive = 4.0   -- Max distance when giving items, weapons etc.

Config.AdminLogging = false -- Logs the usage of certain commands by those with group.admin ace permissions (default is false)

-------------------------------------
-- DO NOT CHANGE BELOW THIS LINE !!!
-------------------------------------
if GetResourceState("ox_inventory") ~= "missing" then
    Config.CustomInventory = "ox"
end

Config.EnableDefaultInventory = Config.CustomInventory == false -- Display the default Inventory ( F2 )
Config.Identifier = GetConvar("esx:identifier", "license")
