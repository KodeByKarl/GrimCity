Config = {}

Config.Enabled = true
Config.ServerName = 'Grim City'
Config.Footer = 'Grim City'

-- Guild from PLAYER / ECONOMY / POLICE log categories. Token is kodebykarl_discord_bot_token in server.cfg.
Config.GuildID = '1537066512739991603'
Config.BotToken = '' -- leave empty to use the shared convar

--[[
    Alias -> Discord channel name (matched case-insensitive).
    The bot lists guild channels and fills IDs automatically.
    Do NOT hardcode ChannelIDs — leave Config.ChannelIDs empty.
]]
Config.Channels = {
    -- PLAYER
    join = 'join',
    leave = 'leave',
    character = 'character',
    death = 'death',
    revive = 'revive',

    -- ECONOMY (banking)
    withdraw = 'withdraw',
    deposit = 'deposit',
    transfer = 'transfer',
    society = 'SOCIETY',
    richest = 'RICHEST-PERSON',

    -- POLICE / SHERIFF
    ['police-license'] = 'police-license',
    ['police-docs'] = 'police-docs',
    ['police-action'] = 'police-action',
    JAIL = 'JAIL',
    ['prison-releas'] = 'prison-releas', -- Discord channel name (as created)
    ['prison-break'] = 'prison-break',
    ['prison-items'] = 'prison-items',

    -- AMBULANCE / EMS
    ['ems-revive'] = 'ems-revive',
    ['ems-money'] = 'ems-money',
    ['ems-bodybag'] = 'ems-bodybag',
    ['ems-bed'] = 'ems-bed',
    ['ems-sentry'] = 'ems-sentry',

    -- MECHANIC
    invoices = 'invoices',
    ['self-service'] = 'self-service',
    orders = 'orders',
    tuning = 'tuning',
    servicing = 'servicing',
    admin = 'admin',
    mechanic = 'mechanic',

    -- INVENTORY (ox_inventory) — exact move-by-move logs
    ['ox-inventory'] = 'OX-INVENTORY',
    drops = 'DROPS',
    trunk = 'TRUNK',
    stash = 'STASH',
    locker = 'LOCKER',
}

-- Always leave empty. Bot detects IDs from Config.Channels names via Discord API.
Config.ChannelIDs = {}
Config.AutoDetectChannels = true


Config.Types = {
    join = true,
    leave = true,
    character = true,
    death = true,
    revive = true,
    withdraw = true,
    deposit = true,
    transfer = true,
    society = true,
    richest = true,
    ['police-license'] = true,
    ['police-docs'] = true,
    ['police-action'] = true,
    jail = true,
    ['prison-releas'] = true,
    ['prison-break'] = true,
    ['prison-items'] = true,
    ['ems-revive'] = true,
    ['ems-money'] = true,
    ['ems-bodybag'] = true,
    ['ems-bed'] = true,
    ['ems-sentry'] = true,
    invoices = true,
    ['self-service'] = true,
    orders = true,
    tuning = true,
    servicing = true,
    admin = true,
    mechanic = true,
    ['ox-inventory'] = true,
    drops = true,
    trunk = true,
    stash = true,
    locker = true,
}

-- Clean palette, no emoji.
Config.Colors = {
    join = 3066993,      -- green
    leave = 15158332,    -- red
    character = 3447003, -- blue
    death = 10038562,    -- dark red
    revive = 1752220,    -- teal
    withdraw = 15158332, -- red
    deposit = 5763719,   -- green
    transfer = 3447003,  -- blue
    society = 15844367,  -- gold
    richest = 10181046,  -- purple
    ['police-license'] = 5763719,
    ['police-docs'] = 3447003,
    ['police-action'] = 9807270,
    jail = 15105570,
    ['prison-releas'] = 5763719,
    ['prison-break'] = 15158332,
    ['prison-items'] = 10181046,
    ['ems-revive'] = 5763719,
    ['ems-money'] = 3447003,
    ['ems-bodybag'] = 10038562,
    ['ems-bed'] = 10181046,
    ['ems-sentry'] = 15158332,
    invoices = 15844367,
    ['self-service'] = 3447003,
    orders = 3066993,
    tuning = 10181046,
    servicing = 1752220,
    admin = 15158332,
    mechanic = 16742400,
    ['ox-inventory'] = 3447003,
    drops = 15105570,
    trunk = 10181046,
    stash = 15844367,
    locker = 10038562,
    default = 5793266,   -- slate
}

--[[
    ox_inventory Discord logging (most important — every successful move).
    Hooks fire after each swap/drop/buy/craft with exact server + UTC timestamps.
]]
Config.Inventory = {
    Enabled = true,
    SkipSameInventory = true, -- ignore rearranging slots in the same bag
    Channels = {
        ['ox-inventory'] = true, -- shops, crafts, player↔player, misc
        drops = true,
        trunk = true,            -- trunk + glovebox
        stash = true,
        locker = true,           -- *locker* stashes + police evidence
    },
}

Config.PostCooldownMs = 250 -- faster queue for high-volume inventory logs
Config.AvatarCacheMs = 600000
