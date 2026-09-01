ConfigBanking = {}

ConfigBanking.Debug = false
ConfigBanking.OpenCommand = "" -- Leave blank to disable /banking; open only via ATM / bank teller
ConfigBanking.OpenKey = "" -- Default keybind (leave blank; command disabled when OpenCommand is blank)
ConfigBanking.MaxTransactionsStored = 20

ConfigBanking.ATMs = {
    `prop_atm_01`,
    `prop_atm_02`,
    `prop_atm_03`,
    `prop_fleeca_atm`,
}

ConfigBanking.BankPedLocations = {
    { coords = vector3(149.4113, -1042.0449, 29.3680), heading = 342.9182 }, -- Legion Square
    { coords = vector3(-1211.8585, -331.9854, 37.7809), heading = 28.5983 }, -- Rockford Hills
    { coords = vector3(-2961.0720, 483.1107, 15.6970), heading = 88.1986 }, -- Great Ocean Highway
    { coords = vector3(-112.2223, 6471.1128, 31.6267), heading = 132.7517 }, -- Paleto Bay
    { coords = vector3(313.8176, -280.5338, 54.1647), heading = 339.1609 }, -- Pillbox Hill
    { coords = vector3(-351.3247, -51.3466, 49.0365), heading = 339.3305 }, -- Burton
    { coords = vector3(1174.9718, 2708.2034, 38.0879), heading = 178.2974 }, -- Sandy Shores
    { coords = vector3(247.0348, 225.1851, 106.2875), heading = 158.7528 }, -- Vinewood
}

--[[
    Discord logs (same bot pattern as cfx-keydi-utils disconnectlogs / comserv).
    Create text channels named WITHDRAW, DEPOSIT, SOCIETY, TRANSFER, RICHEST
    (or set ChannelIDs manually).
]]
ConfigBanking.Logs = {
    Enabled = true,
    Debug = false,
    BotToken = "MTUzNjM2NDUyMjc5MTUwNjA0Mg.GfAaOT.pXdZcrMv-0yl2Blw9cESfKGSbv56AvD5C6-jTo",
    GuildID = "1536358290777444397",

    ChannelNames = {
        withdraw = "WITHDRAW",
        deposit = "DEPOSIT",
        society = "SOCIETY",
        transfer = "TRANSFER",
        richest = "RICHEST",
    },

    -- Optional manual overrides (leave empty to auto-find by ChannelNames)
    ChannelIDs = {
        withdraw = "1536366505308987452",
        deposit = "1536366509511811122",
        society = "1536366513760641175",
        transfer = "1536366517799624744",
        richest = "1536366501475647488",
    },

    LogTypes = {
        withdraw = true,
        deposit = true,
        society = true,
        transfer = true,
        richest = true,
    },

    EmbedColors = {
        withdraw = 15158332, -- red
        deposit = 5763719,   -- green
        society = 15844367,  -- gold
        transfer = 3447003,  -- blue
        richest = 10181046,  -- purple
    },

    PostCooldownMs = 500,
}

--[[
    Periodic richest-player report (ESX users.accounts: money / bank / black_money).
    Inspired by https://github.com/Edvo1901/mb-GetRichPlayer-ESX
]]
ConfigBanking.Richest = {
    Enabled = true,
    IntervalMinutes = 30,       -- auto-send interval
    Top = 10,                   -- only top N (set OnlyTop = false to log all — not recommended)
    OnlyTop = true,
    IncludeDirtyMoney = true,   -- black_money in total
    AdminCommand = "topmoney",  -- ESX admin command to force-send
    LogMessageType = "standard", -- "short" | "standard" | "full"
}
