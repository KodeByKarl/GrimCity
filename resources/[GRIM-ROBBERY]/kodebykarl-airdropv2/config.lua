Config = {}

-- Scoreboard World Event name — must match ConfigScoreboard.WorldEvents
Config.ScoreboardEventName = 'Airdrop'

Config.Settings = {
    Manual = true, -- true = command only; false = auto cooldown loop
    Command = 'spawn_airdrop',
    AcePermission = 'command.airdrop', -- also allows owner/developer/admin/superadmin groups
    Cooldown = { min = 120, max = 180 }, -- minutes (auto mode)
    FallSpeed = 3,
    SpawnOffline = false,
    DeletePrevious = true,
    UseFlareParticles = true,
    ProgbarTime = 300000, -- ms
}

-- Optional display labels (index matches Locations). Falls back to "Drop Zone #N".
Config.LocationLabels = {
    'Sandy Shores Strip',
    'Sandy Airfield',
    'Stab City',
    'Alamo Sea',
    'Paleto Mill',
    'Grapeseed Hills',
    'Paleto Bay',
    'Little Seoul',
    'Cypress Flats',
    'Elysian Island',
    'Chumash Cliffs',
    'Rockford Hills',
    'Vinewood Hills',
    'Mount Chiliad Trail',
    'Galileo Observatory',
    'Raton Canyon',
    'Mirror Park',
}

Config.Locations = {
    vector3(1713.2340, 3764.3320, 33.2525),
    vector3(1680.8961, 3248.6545, 39.49),
    vector3(785.8970, 3581.5029, 31.1),
    vector3(713.8873, 4174.6230, 40.1),
    vector3(-502.6730, 5281.2212, 79.70),
    vector3(-1124.0453, 4923.5586, 217.90),
    vector3(-307.4090, 6280.3057, 30.55),
    vector3(-635.1737, -657.9460, 30.7256),
    vector3(828.2087, -1748.4891, 28.4861),
    vector3(19.0026, -2486.4241, 5.0068),
    vector3(-2982.5447, 2057.4097, 39.0439),
    vector3(-873.1435, -136.6539, 36.9813),
    vector3(-839.5473, 652.8796, 129.3021),
    vector3(-911.7908, 4113.2163, 157.0834),
    vector3(-408.6240, 1185.1954, 324.5317),
    vector3(2106.6021, 1382.0574, 75.3661),
    vector3(1194.8491, 78.6503, 81.8945),
}

Config.LootTables = {
    [1] = {
        Chance = 100,
        Items = {
            { name = 'black_money', count = 10000, type = 'account' },
            { name = 'bulletproof', count = 20, type = 'item' },
            { name = 'meth', count = 20, type = 'item' },
            { name = 'cocaine', count = 20, type = 'item' },
            { name = 'ammo-box1', count = 20, type = 'item' },
            { name = 'weapon_de', count = 5, type = 'item' },
            { name = 'weapon_glock22', count = 10, type = 'item' },
        },
    },
    [2] = {
        Chance = 75,
        Items = {
            { name = 'black_money', count = 10000, type = 'account' },
            { name = 'bulletproof', count = 20, type = 'item' },
            { name = 'meth', count = 20, type = 'item' },
            { name = 'cocaine', count = 20, type = 'item' },
            { name = 'ammo-box1', count = 20, type = 'item' },
            { name = 'weapon_de', count = 5, type = 'item' },
            { name = 'weapon_glock22', count = 10, type = 'item' },
        },
    },
    [3] = {
        Chance = 50,
        Items = {
            { name = 'black_money', count = 10000, type = 'account' },
            { name = 'bulletproof', count = 20, type = 'item' },
            { name = 'meth', count = 20, type = 'item' },
            { name = 'cocaine', count = 20, type = 'item' },
            { name = 'ammo-box1', count = 20, type = 'item' },
            { name = 'weapon_de', count = 5, type = 'item' },
            { name = 'weapon_glock22', count = 10, type = 'item' },
        },
    },
    [4] = {
        Chance = 25,
        Items = {
            { name = 'black_money', count = 10000, type = 'account' },
            { name = 'bulletproof', count = 20, type = 'item' },
            { name = 'meth', count = 20, type = 'item' },
            { name = 'cocaine', count = 20, type = 'item' },
            { name = 'ammo-box1', count = 20, type = 'item' },
            { name = 'weapon_de', count = 5, type = 'item' },
            { name = 'weapon_glock22', count = 10, type = 'item' },
        },
    },
    [5] = {
        Chance = 10,
        Items = {
            { name = 'black_money', count = 10000, type = 'account' },
            { name = 'bulletproof', count = 20, type = 'item' },
            { name = 'meth', count = 20, type = 'item' },
            { name = 'cocaine', count = 20, type = 'item' },
            { name = 'ammo-box1', count = 20, type = 'item' },
            { name = 'weapon_de', count = 5, type = 'item' },
            { name = 'weapon_glock22', count = 10, type = 'item' },
        },
    },
}

Config.Object = 'prop_mb_cargo_04a'
Config.Blip = {
    Enabled = true,
    Sprite = 306,
    Colour = 1,
    Scale = 0.85,
    ShortRange = false,
    Name = 'Airdrop',
}

-- Backward-compat alias for copied Infinity scripts
Infinity_Airdrop_Config = Config
