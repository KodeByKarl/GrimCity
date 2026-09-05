Config = {}

-- =============================================================================
-- GENERAL
-- =============================================================================
Config.Debug = false
Config.WebhookURL = '' -- Discord webhook (optional)

-- Scoreboard World Event name — must match ConfigScoreboard.WorldEvents
Config.ScoreboardEventName = 'Airdrop'

-- Set to a region function string (e.g. 'airdrop') to gate LOOT by kodebykarl-ui regions.
-- false = anyone on the server can loot. Visuals still show for everyone.
Config.RequireFunction = false
Config.GateLootOnly = true

-- =============================================================================
-- AUTO DROP SCHEDULE
-- =============================================================================
Config.AutoDrop = {
    Enable = true,
    IntervalMinutes = 45,       -- Time between drops (from when the last drop ENDS)
    StartupDelayMinutes = 5,    -- First drop delay after resource start / restart
    MinPlayers = 0,             -- Skip drop if fewer players than this (0 = always). Use 8+ on live.
    RetryMinutes = 5,           -- If skipped (not enough players / already active), retry after this
    AvoidLastLocation = true,   -- Don't pick the same location twice in a row when possible
}

-- =============================================================================
-- DROP TIMING (seconds)
-- =============================================================================
Config.WarningSeconds = 30      -- Announce location before the plane spawns (0 = skip warning)
Config.FlightSeconds = 28       -- Plane inbound duration
Config.FallSeconds = 16         -- Crate parachute fall (should be < FlightSeconds)
Config.LockSeconds = 120        -- Crate stays locked after landing (PvP window)
Config.OpenSeconds = 180        -- How long the crate stays lootable after unlock
Config.CleanupDelaySeconds = 8  -- Wait after claim/expire before clearing entities

-- =============================================================================
-- PLANE
-- =============================================================================
Config.Plane = {
    Enable = true,
    Model = `titan`,            -- cargoplane / titan / cuban800
    Altitude = 180.0,
    ApproachDistance = 900.0,   -- Spawn this far from the drop, along heading
    DespawnDistance = 700.0,    -- Fly this far past the drop before delete
}

-- =============================================================================
-- CRATE / PARACHUTE / SMOKE
-- =============================================================================
Config.Crate = {
    Model = `prop_mil_crate_01`,
    ParachuteModel = `p_cargo_chute_s`,
    StartHeight = 160.0,        -- Fall starts this many meters above ground
    FreezeOnLand = true,
    Smoke = {
        Enable = true,
        Dict = 'scr_oddjobtraffickingair',
        Name = 'scr_crate_drop_flare',
        Scale = 1.0,
        Offset = vec3(0.0, 0.0, 0.35),
    },
}

-- =============================================================================
-- BLIPS (visible to ALL players on pause map + minimap)
-- Sprite 423 = airplane, 478 = crate. ShortRange false = shows across the map.
-- Map markers only — no GPS waypoint / route.
-- =============================================================================
Config.Blips = {
    Plane = {
        Enable = true,
        Sprite = 423,
        Color = 1,
        Scale = 1.20,
        Label = 'Airdrop Plane',
        Flash = true,
        Display = 4,            -- pause map + minimap
        ShortRange = false,
        HighDetail = true,
    },
    Drop = {
        Enable = true,
        Sprite = 478,
        Color = 1,
        Scale = 1.15,
        Label = 'Airdrop',      -- becomes "Airdrop: Sandy Shores Airfield"
        Flash = true,
        Display = 4,
        ShortRange = false,
        HighDetail = true,
    },
    Radius = { Enable = true, Color = 1, Alpha = 140, Scale = 120.0 },
}

-- =============================================================================
-- CLAIM / TARGET
-- =============================================================================
Config.Claim = {
    Distance = 2.8,             -- ox_target + server anti-cheat radius
    ProgressMs = 8000,          -- Progress bar to crack the crate
    OneWinner = true,           -- true = first successful loot takes everything
    MaxPlayers = 1,             -- Used when OneWinner = false
    UseOxTarget = true,
    AllowKeyFallback = true,    -- [E] if ox_target is missing
    CancelOnMove = true,
}

-- =============================================================================
-- LOOT
-- Location.rewards overrides this pool when set.
-- chance = 0-100. Rolls until RewardsPerDrop items are picked.
-- =============================================================================
Config.RewardsPerDrop = { min = 3, max = 5 }

Config.GuaranteedRewards = {
    { item = 'black_money', min = 25000, max = 45000, label = 'Dirty Money' },
}

Config.RewardPool = {
    { item = 'black_money',        min = 15000, max = 35000, chance = 70, label = 'Dirty Money' },
    { item = 'oxy',                min = 4,     max = 10,    chance = 45, label = 'Oxy' },
    { item = 'weeds_pills',        min = 2,     max = 6,     chance = 40, label = 'Weed Pills' },
    { item = 'ammo-9',             min = 40,    max = 120,   chance = 50, label = '9mm Ammo' },
    { item = 'ammo-45',            min = 30,    max = 90,    chance = 35, label = '.45 Ammo' },
    { item = 'armor',              min = 1,     max = 2,     chance = 30, label = 'Body Armor' },
    { item = 'WEAPON_HEAVYPISTOL', min = 1,     max = 1,     chance = 12, label = 'Heavy Pistol' },
    { item = 'WEAPON_PISTOL50',    min = 1,     max = 1,     chance = 8,  label = 'Pistol .50' },
}

Config.EmptyFallback = { item = 'black_money', amount = 15000, label = 'Dirty Money' }

-- =============================================================================
-- ADMIN
-- /airdrop              → random location
-- /airdrop <locationId> → force that drop
-- /airdrop cancel       → abort the current drop
-- /airdropnext          → print next timer (chat)
-- =============================================================================
Config.Admin = {
    Command = 'airdrop',
    NextCommand = 'airdropnext',
    AcePermission = 'command.airdrop',
    Groups = {
        admin = true,
        superadmin = true,
    },
    ForceCancelsActive = true, -- Admin start while a drop is live: cancel then start
}

-- =============================================================================
-- ANNOUNCEMENTS
-- =============================================================================
Config.Notify = {
    Enable = true,
    Duration = 8000,
}

Config.ChatAnnounce = true

-- =============================================================================
-- DROP LOCATIONS
-- heading = direction the plane flies toward the crate (degrees)
-- enabled = false to skip without deleting
-- rewards = optional per-location loot pool (same shape as Config.RewardPool)
-- =============================================================================
Config.Locations = {
    sandy_airfield = {
        enabled = true,
        label = 'Sandy Shores Airfield',
        coords = vec3(1723.78, 3302.79, 41.22),
        heading = 148.0,
    },
    grapeseed = {
        enabled = true,
        label = 'Grapeseed Airstrip',
        coords = vec3(2134.12, 4781.44, 40.97),
        heading = 25.0,
    },
    paleto_bay = {
        enabled = true,
        label = 'Paleto Bay',
        coords = vec3(-94.35, 6350.21, 31.49),
        heading = 45.0,
    },
    senora_desert = {
        enabled = true,
        label = 'Grand Senora Desert',
        coords = vec3(2378.41, 3076.02, 48.15),
        heading = 90.0,
    },
    elysian_island = {
        enabled = true,
        label = 'Elysian Island',
        coords = vec3(155.22, -3052.40, 7.04),
        heading = 180.0,
    },
    palomino_highlands = {
        enabled = true,
        label = 'Palomino Highlands',
        coords = vec3(2588.40, 437.15, 108.46),
        heading = 320.0,
    },
}
