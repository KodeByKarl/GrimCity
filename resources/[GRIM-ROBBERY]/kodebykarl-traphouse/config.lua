Config = {}

-- General Settings
Config.RotationMinutes = 15        -- Active TrapHouse rotates every 15 minutes (1 at a time)
Config.AntiFarmCooldown = 180      -- Cooldown in seconds before same killer can get loot from same victim
Config.DeleteVehiclesInZone = true  -- Auto-remove vehicles left unoccupied inside TrapHouse zones
Config.WebhookURL = ''             -- Discord Webhook URL for logs (optional)

-- TrapHouse / RedZone Locations
Config.TrapZones = {
    {
        id = 'mirror_park',
        label = 'Mirror Park TrapHouse',
        coords = vec3(1204.89, -557.81, 69.62),
        radius = 200.0,
        blip = { enable = true, color = 1, alpha = 110 }
    },
    {
        id = 'golf_course',
        label = 'Golf Course (GWC) TrapHouse',
        coords = vec3(-1116.84, 304.53, 66.52),
        radius = 250.0,
        blip = { enable = true, color = 1, alpha = 110 }
    },
    {
        id = 'playa_hotel',
        label = 'Playa Hotel TrapHouse',
        coords = vec3(-1868.55, -364.87, 49.46),
        radius = 200.0,
        blip = { enable = true, color = 1, alpha = 110 }
    },
    {
        id = 'elysian_docks',
        label = 'Elysian Docks TrapHouse',
        coords = vec3(-48.65, -2508.78, 7.40),
        radius = 200.0,
        blip = { enable = true, color = 1, alpha = 110 }
    }
}

-- Kill Reward Loot Pool (Calculated 100% Server-Side)
Config.RewardPool = {
    { item = 'oxy', label = 'Oxy', min = 1, max = 3, chance = 30 },
    { item = 'weeds_pills', label = 'Weed Pills', min = 1, max = 2, chance = 40 },
    { item = 'ammo-9', label = '9mm Ammo', min = 20, max = 60, chance = 35 },
    { item = 'ammo-45', label = '.45 Ammo', min = 20, max = 50, chance = 25 },
    { item = 'armor', label = 'Body Armor', min = 1, max = 1, chance = 15 },
}

-- Number of distinct reward items granted per kill
Config.RewardsPerKill = { min = 1, max = 2 }
