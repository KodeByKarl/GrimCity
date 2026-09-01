Config = {}

-- General Settings
Config.AllowMultipleTurfwars = false -- Allow only one active Turf War at a time
Config.MinGangMembersOnline = 0      -- Minimum online members of the same gang required to trigger
Config.GoBackDrainPerSecond = 10     -- HP drain per second when outside active turf boundary
Config.WebhookURL = ''               -- Discord Webhook URL for logs (optional)

-- Ignored Gangs & Jobs from triggering/claiming
Config.IgnoreGangs = {
    ['none'] = true,
    ['unemployed'] = true,
    [''] = true,
}

Config.IgnoreJobs = {
    ['unemployed'] = true,
}

-- Claim Reward Bag Prop Settings (Spawns at trigger location when war timer reaches 0)
Config.RewardBag = {
    model = `prop_cs_heist_bag_02`,
    zOffset = -0.98,
    heading = 0.0,
}

-- Turf Locations Configuration
Config.TurfWars = {
    ['kortz'] = {
        id = 'kortz',
        label = 'Kortz Center Turf War',
        coords = vec3(-2248.41, 269.54, 174.60),
        timer = 10,       -- 15 Minutes War Sequence
        cooldown = 1800,  -- 30 Minutes Cooldown
        claimTime = 8000, -- 8 Seconds Progress Bar to claim rewards
        interactDistance = 2.5,

        -- Boundary Zone
        zone = {
            enable = true,
            radius = 150.0
        },

        -- Weapon Restrictions (Optional)
        weapon = {
            enable = true,
            list = {
                [`WEAPON_PISTOL`] = true,
                [`WEAPON_COMBATPISTOL`] = true,
                [`WEAPON_HEAVYPISTOL`] = true,
                [`WEAPON_PISTOL50`] = true,
                [`WEAPON_PISTOL_MK2`] = true,
                [`WEAPON_VINTAGEPISTOL`] = true,
            }
        },

        -- Rewards Delivered Directly at Trigger Spot upon Claim
        rewards = {
            { item = 'black_money',        min = 50000, max = 100000, label = 'Dirty Money' },
            { item = 'oxy',                min = 15,    max = 30,     label = 'Oxy' },
            { item = 'WEAPON_HEAVYPISTOL', min = 1,     max = 2,      label = 'Heavy Pistol' },
            { item = 'WEAPON_PISTOL50',    min = 1,     max = 1,      label = 'Pistol .50' },
        },

        -- Blip Configuration
        blip = {
            turf = { enable = true, id = 310, color = 1, scale = 0.8 },
            radius = { enable = true, color = 1, alpha = 110, scale = 150.0 }
        }
    },

    ['gov_facility'] = {
        id = 'gov_facility',
        label = 'Government Facility Turf War',
        coords = vec3(2506.01, -383.29, 94.12),
        timer = 900,
        cooldown = 1800,
        claimTime = 8000,
        interactDistance = 2.5,

        zone = {
            enable = true,
            radius = 150.0
        },

        weapon = {
            enable = true,
            list = {
                [`WEAPON_PISTOL`] = true,
                [`WEAPON_COMBATPISTOL`] = true,
                [`WEAPON_HEAVYPISTOL`] = true,
                [`WEAPON_PISTOL50`] = true,
                [`WEAPON_PISTOL_MK2`] = true,
                [`WEAPON_VINTAGEPISTOL`] = true,
            }
        },

        rewards = {
            { item = 'black_money',         min = 60000, max = 120000, label = 'Dirty Money' },
            { item = 'oxy',                 min = 20,    max = 35,     label = 'Oxy' },
            { item = 'WEAPON_COMBATPISTOL', min = 1,     max = 2,      label = 'Combat Pistol' },
            { item = 'WEAPON_PISTOL_MK2',   min = 1,     max = 1,      label = 'Pistol Mk II' },
        },

        blip = {
            turf = { enable = true, id = 310, color = 1, scale = 0.8 },
            radius = { enable = true, color = 1, alpha = 110, scale = 150.0 }
        }
    },

    ['stab_city'] = {
        id = 'stab_city',
        label = 'Stab City Turf War',
        coords = vec3(77.05, 3708.14, 40.69),
        timer = 900,
        cooldown = 1800,
        claimTime = 8000,
        interactDistance = 2.5,

        zone = {
            enable = true,
            radius = 150.0
        },

        weapon = {
            enable = false,
            list = {}
        },

        rewards = {
            { item = 'black_money',        min = 50000, max = 90000, label = 'Dirty Money' },
            { item = 'oxy',                min = 10,    max = 25,    label = 'Oxy' },
            { item = 'WEAPON_HEAVYPISTOL', min = 1,     max = 2,     label = 'Heavy Pistol' },
        },

        blip = {
            turf = { enable = true, id = 310, color = 1, scale = 0.8 },
            radius = { enable = true, color = 1, alpha = 110, scale = 150.0 }
        }
    },

    ['power_station'] = {
        id = 'power_station',
        label = 'Power Station Turf War',
        coords = vec3(2750.02, 1566.61, 24.50),
        timer = 900,
        cooldown = 1800,
        claimTime = 8000,
        interactDistance = 2.5,

        zone = {
            enable = true,
            radius = 150.0
        },

        weapon = {
            enable = false,
            list = {}
        },

        rewards = {
            { item = 'black_money',          min = 55000, max = 110000, label = 'Dirty Money' },
            { item = 'oxy',                  min = 15,    max = 30,     label = 'Oxy' },
            { item = 'WEAPON_VINTAGEPISTOL', min = 1,     max = 2,      label = 'Vintage Pistol' },
        },

        blip = {
            turf = { enable = true, id = 310, color = 1, scale = 0.8 },
            radius = { enable = true, color = 1, alpha = 110, scale = 150.0 }
        }
    }
}
