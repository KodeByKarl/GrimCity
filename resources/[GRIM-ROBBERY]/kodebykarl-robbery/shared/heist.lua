Config.Heist = {
    ['humane'] = {
        label = 'Humane Labs',
        require = {
            ['police'] = 0 --12
        },
        reset = 7200,
        timer = 1500,
        distanceToCancel = 10,
        rewards = {
            {item = 'WEAPON_CERAMICPISTOL', min = 2, max = 2},
            {item = 'WEAPON_PISTOL', min = 5, max = 5},
            {item = 'at_clip_extended_pistol', min = 3, max = 3},
            {item = 'at_suppressor_light', min = 2, max = 2},
            {item = 'ammo-box1', min = 5, max = 5},
            {item = 'black_money', min = 100000, max = 100000},
        },
        ped = {
            entity = 0,
            model = 'g_m_m_chicold_01',
            coords = vec4(3541.647, 3667.723, 28.121, 79.396)
        },
        settings = {
            autoTemplate = true,
            autoPriority = true,
            autoBlip = true,
            autoAnnounce = false,
        },
        dispatch = {
            enable = false, --true,
            jobs = {'police'}
        },
    },
    ['bigbank'] = {
        label = 'Pacific Standard',
        require = {
            ['police'] = 0 --12
        },
        reset = 7200,
        timer = 1000,
        distanceToCancel = 10,
        rewards = {
            {item = 'WEAPON_CERAMICPISTOL', min = 2, max = 2},
            {item = 'WEAPON_PISTOL', min = 5, max = 5},
            {item = 'at_clip_extended_pistol', min = 3, max = 3},
            {item = 'at_suppressor_light', min = 2, max = 2},
            {item = 'ammo-box1', min = 5, max = 5},
            {item = 'black_money', min = 150000, max = 150000},
        },
        ped = {
            entity = 0,
            model = 'g_m_m_chicold_01',
            coords = vec4(252.913, 227.470, 101.683, 252.178)
        },
        settings = {
            autoTemplate = true,
            autoPriority = true,
            autoBlip = true,
            autoAnnounce = false,
        },
        dispatch = {
            enable = false, --true,
            jobs = {'police'}
        },
    },
    ['lifeinvader'] = {
        label = 'Life Invader',
        require = {
            ['police'] = 0 --8
        },
        reset = 7200,
        timer = 800,
        distanceToCancel = 10,
        rewards = {
            {item = 'WEAPON_PISTOL', min = 5, max = 5},
            {item = 'at_clip_extended_pistol', min = 3, max = 3},
            {item = 'at_suppressor_light', min = 2, max = 2},
            {item = 'ammo-box1', min = 5, max = 5},
            {item = 'black_money', min = 50000, max = 50000},
        },
        ped = {
            entity = 0,
            model = 'g_m_m_chicold_01',
            coords = vec4(-1051.417, -231.928, 44.020, 118.716)
        },
        settings = {
            autoTemplate = true,
            autoPriority = true,
            autoBlip = true,
            autoAnnounce = false,
        },
        dispatch = {
            enable = false, --true,
            jobs = {'police'}
        },
    },
    ['warship'] = {
        label = 'USS Ranger',
        require = {
            ['police'] = 0 --12
        },
        reset = 7200,
        timer = 1500,
        distanceToCancel = 10,
        rewards = {
            {item = 'WEAPON_PISTOL50', min = 3, max = 3},
            {item = 'WEAPON_CERAMICPISTOL', min = 3, max = 3},
            {item = 'WEAPON_PISTOL', min = 5, max = 5},
            {item = 'at_clip_extended_pistol', min = 3, max = 3},
            {item = 'at_suppressor_light', min = 2, max = 2},
            {item = 'ammo-box1', min = 5, max = 5},
            {item = 'ammo-box4', min = 2, max = 2},
            {item = 'black_money', min = 200000, max = 200000},
        },
        ped = {
            entity = 0,
            model = 'g_m_m_chicold_01',
            coords = vec4(3082.947, -4686.693, 27.252, 207.313)
        },
        settings = {
            autoTemplate = true,
            autoPriority = true,
            autoBlip = true,
            autoAnnounce = false,
        },
        dispatch = {
            enable = false, --true,
            jobs = {'police'}
        },
    },
    ['yacht'] = {
        label = 'Yacht',
        require = {
            ['police'] = 0 --10
        },
        reset = 7200,
        timer = 1500,
        distanceToCancel = 10,
        rewards = {
            {item = 'WEAPON_CERAMICPISTOL', min = 3, max = 3},
            {item = 'WEAPON_PISTOL', min = 5, max = 5},
            {item = 'at_clip_extended_pistol', min = 2, max = 2},
            {item = 'at_suppressor_light', min = 2, max = 2},
            {item = 'ammo-box1', min = 5, max = 5},
            {item = 'black_money', min = 120000, max = 120000},
        },
        ped = {
            entity = 0,
            model = 'g_m_m_chicold_01',
            coords = vec4(-2085.762, -1017.880, 12.781, 252.985)
        },
        settings = {
            autoTemplate = true,
            autoPriority = true,
            autoBlip = true,
            autoAnnounce = false,
        },
        dispatch = {
            enable = false, --true,
            jobs = {'police'}
        },
    },
    ['jewel'] = {
        label = 'Vangelico Jewelry',
        require = {
            ['police'] = 0 --6
        },
        reset = 7200,
        timer = 500,
        distanceToCancel = 3,
        rewards = {
            {item = 'black_money', min = 20000, max = 20000}
        },
        ped = {
            entity = 0,
            model = 'g_m_m_chicold_01',
            coords = vec4(-632.155, -230.279, 38.057, 307.703)
        },
        settings = {
            autoTemplate = true,
            autoPriority = true,
            autoBlip = true,
            autoAnnounce = false,
        },
        dispatch = {
            enable = false, --true,
            jobs = {'police'}
        },
    },
    ['cluckin_bell'] = {
        label = 'Cluckin Bell',
        require = {
            ['police'] = 0 --4
        },
        reset = 3600,
        timer = 300,
        distanceToCancel = 10,
        rewards = {
            {item = 'black_money', min = 25000, max = 25000}
        },
        ped = {
            entity = 0,
            model = `g_m_m_chicold_01`,
            coords = vec4(-509.900, -700.400, 33.168, 92.05)
        },
        settings = {
            autoTemplate = true,
            autoPriority = true,
            autoBlip = true,
            autoAnnounce = false,
        },
        dispatch = {
            enable = false, --true,
            jobs = {'police'}
        },
    },
    -- Store Robbery --
    ['innocence_blvd'] = {
        label = '24/7 (Strawberry, Innocence Blvd)',
        require = {
            ['police'] = 0 --2
        },
        requireItem = {
            ['lockpick'] = 1
        },
        reset = 1800,
        timer = 200,
        distanceToCancel = 10,
        rewards = {
            {item = 'black_money', min = 5000, max = 10000}
        },
        marker = {
            coords = vec3(24.486, -1344.993, 29.497),
            distance = 10
        },
        settings = {
            autoTemplate = false,
            autoPriority = false,
            autoBlip = true,
            autoAnnounce = true,
        },
        dispatch = {
            enable = false, --true,
            jobs = {'police', 'ambulance'}
        },
    },
    ['ineseno_road'] = {
        label = '24/7 (Banham Canyon, Ineseno Road)',
        require = {
            ['police'] = 0 --2
        },
        requireItem = {
            ['lockpick'] = 1
        },
        reset = 1800,
        timer = 200,
        distanceToCancel = 10,
        rewards = {
            {item = 'black_money', min = 5000, max = 10000}
        },
        marker = {
            coords = vec3(-3041.218, 583.836, 7.908),
            distance = 10
        },
        settings = {
            autoTemplate = false,
            autoPriority = false,
            autoBlip = true,
            autoAnnounce = true,
        },
        dispatch = {
            enable = false, --true,
            jobs = {'police', 'ambulance'}
        },
    },
    ['procopio_paleto'] = {
        label = 'Bayview Store (Procopio Promenade, Paleto Forest)',
        require = {
            ['police'] = 0 --2
        },
        requireItem = {
            ['lockpick'] = 1
        },
        reset = 1800,
        timer = 200,
        distanceToCancel = 10,
        rewards = {
            {item = 'black_money', min = 5000, max = 10000}
        },
        marker = {
            coords = vec3(-676.47198486328, 5840.169921875, 17.440000534058),
            distance = 10
        },
        settings = {
            autoTemplate = false,
            autoPriority = false,
            autoBlip = true,
            autoAnnounce = true,
        },
        dispatch = {
            enable = false, --true,
            jobs = {'police', 'ambulance'}
        },
    },
    ['senora_fwy'] = {
        label = '24/7 (Mount Chiliad, Senora Fwy)',
        require = {
            ['police'] = 0 --2
        },
        requireItem = {
            ['lockpick'] = 1
        },
        reset = 1800,
        timer = 200,
        distanceToCancel = 10,
        rewards = {
            {item = 'black_money', min = 5000, max = 10000}
        },
        marker = {
            coords = vec3(1728.8990478516, 6417.3032226562, 35.036998748779),
            distance = 10
        },
        settings = {
            autoTemplate = false,
            autoPriority = false,
            autoBlip = true,
            autoAnnounce = true,
        },
        dispatch = {
            enable = false, --true,
            jobs = {'police', 'ambulance'}
        },
    },
    ['great_ocean_highway'] = {
        label = 'Robs Liquor (Banham Canyon, Great Ocean Highway)',
        require = {
            ['police'] = 0 --2
        },
        requireItem = {
            ['lockpick'] = 1
        },
        reset = 1800,
        timer = 200,
        distanceToCancel = 10,
        rewards = {
            {item = 'black_money', min = 5000, max = 10000}
        },
        marker = {
            coords = vec3(-2966.458984375, 390.82501220703, 15.043000221252),
            distance = 10
        },
        settings = {
            autoTemplate = false,
            autoPriority = false,
            autoBlip = true,
            autoAnnounce = true,
        },
        dispatch = {
            enable = false, --true,
            jobs = {'police', 'ambulance'}
        },
    },
    ['palomino_ave'] = {
        label = 'LTD Gasoline (Little Seoul, Palomino Avenue)',
        require = {
            ['police'] = 0 --2
        },
        requireItem = {
            ['lockpick'] = 1
        },
        reset = 1800,
        timer = 200,
        distanceToCancel = 10,
        rewards = {
            {item = 'black_money', min = 5000, max = 10000}
        },
        marker = {
            coords = vec3(-706.15899658203, -913.54901123047, 19.215000152588),
            distance = 10
        },
        settings = {
            autoTemplate = false,
            autoPriority = false,
            autoBlip = true,
            autoAnnounce = true,
        },
        dispatch = {
            enable = false, --true,
            jobs = {'police', 'ambulance'}
        },
    },
    ['el_rancho_blvd'] = {
        label = 'Robs Liquor (Murrieta Heights, El Rancho Blvd)',
        require = {
            ['police'] = 0 --2
        },
        requireItem = {
            ['lockpick'] = 1
        },
        reset = 1800,
        timer = 200,
        distanceToCancel = 10,
        rewards = {
            {item = 'black_money', min = 5000, max = 10000}
        },
        marker = {
            coords = vec3(1134.2449951172, -982.44500732422, 46.415000915527),
            distance = 10
        },
        settings = {
            autoTemplate = false,
            autoPriority = false,
            autoBlip = true,
            autoAnnounce = true,
        },
        dispatch = {
            enable = false, --true,
            jobs = {'police', 'ambulance'}
        },
    },
    ['prosperity_st'] = {
        label = 'Robs Liquor (Morningwood, Prosperity St)',
        require = {
            ['police'] = 0 --2
        },
        requireItem = {
            ['lockpick'] = 1
        },
        reset = 1800,
        timer = 200,
        distanceToCancel = 10,
        rewards = {
            {item = 'black_money', min = 5000, max = 10000}
        },
        marker = {
            coords = vec3(-1486.2469482422, -378.04998779297, 40.162998199463),
            distance = 10
        },
        settings = {
            autoTemplate = false,
            autoPriority = false,
            autoBlip = true,
            autoAnnounce = true,
        },
        dispatch = {
            enable = false, --true,
            jobs = {'police', 'ambulance'}
        },
    },
    ['grand_senora_desert'] = {
        label = 'Robs Liquor (Grand Senora Desert, Route 68)',
        require = {
            ['police'] = 0 --2
        },
        requireItem = {
            ['lockpick'] = 1
        },
        reset = 1800,
        timer = 200,
        distanceToCancel = 10,
        rewards = {
            {item = 'black_money', min = 5000, max = 10000}
        },
        marker = {
            coords = vec3(1166.0, 2710.7729492188, 38.157001495361),
            distance = 10
        },
        settings = {
            autoTemplate = false,
            autoPriority = false,
            autoBlip = true,
            autoAnnounce = true,
        },
        dispatch = {
            enable = false, --true,
            jobs = {'police', 'ambulance'}
        },
    },
    ['grapeseed_mainst'] = {
        label = '24/7 (Grapeseed, Grapeseed Main Street)',
        require = {
            ['police'] = 0 --2
        },
        requireItem = {
            ['lockpick'] = 1
        },
        reset = 1800,
        timer = 200,
        distanceToCancel = 10,
        rewards = {
            {item = 'black_money', min = 5000, max = 10000}
        },
        marker = {
            coords = vec3(1698.0620117188, 4922.9599609375, 42.062999725342),
            distance = 10
        },
        settings = {
            autoTemplate = false,
            autoPriority = false,
            autoBlip = true,
            autoAnnounce = true,
        },
        dispatch = {
            enable = false, --true,
            jobs = {'police', 'ambulance'}
        },
    },
    ['palomino_fwy'] = {
        label = '24/7 (Tataviam Mountains, Palomino Fwy)',
        require = {
            ['police'] = 0 --2
        },
        requireItem = {
            ['lockpick'] = 1
        },
        reset = 1800,
        timer = 200,
        distanceToCancel = 10,
        rewards = {
            {item = 'black_money', min = 5000, max = 10000}
        },
        marker = {
            coords = vec3(2554.8439941406, 380.92700195312, 108.62200164795),
            distance = 10
        },
        settings = {
            autoTemplate = false,
            autoPriority = false,
            autoBlip = true,
            autoAnnounce = true,
        },
        dispatch = {
            enable = false, --true,
            jobs = {'police', 'ambulance'}
        },
    },
    ['pryite_ave_paleto'] = {
        label = 'Robs Liquor (Pryite Ave, Paleto Bay)',
        require = {
            ['police'] = 0 --2
        },
        requireItem = {
            ['lockpick'] = 1
        },
        reset = 1800,
        timer = 200,
        distanceToCancel = 10,
        rewards = {
            {item = 'black_money', min = 5000, max = 10000}
        },
        marker = {
            coords = vec3(-161.00300598145, 6321.4047851562, 31.594999313354),
            distance = 10
        },
        settings = {
            autoTemplate = false,
            autoPriority = false,
            autoBlip = true,
            autoAnnounce = true,
        },
        dispatch = {
            enable = false, --true,
            jobs = {'police', 'ambulance'}
        },
    },
    ['route_68'] = {
        label = '24/7 (Harmony, Route 68)',
        require = {
            ['police'] = 0 --2
        },
        requireItem = {
            ['lockpick'] = 1
        },
        reset = 1800,
        timer = 200,
        distanceToCancel = 10,
        rewards = {
            {item = 'black_money', min = 5000, max = 10000}
        },
        marker = {
            coords = vec3(549.35699462891, 2669.0, 42.15599822998),
            distance = 10
        },
        settings = {
            autoTemplate = false,
            autoPriority = false,
            autoBlip = true,
            autoAnnounce = true,
        },
        dispatch = {
            enable = false, --true,
            jobs = {'police', 'ambulance'}
        },
    },
    ['niland_ave'] = {
        label = '24/7 (Sandy Shores, Niland Avenue)',
        require = {
            ['police'] = 0 --2
        },
        requireItem = {
            ['lockpick'] = 1
        },
        reset = 1800,
        timer = 200,
        distanceToCancel = 10,
        rewards = {
            {item = 'black_money', min = 5000, max = 10000}
        },
        marker = {
            coords = vec3(1958.9260253906, 3742.0869140625, 32.342998504639),
            distance = 10
        },
        settings = {
            autoTemplate = false,
            autoPriority = false,
            autoBlip = true,
            autoAnnounce = true,
        },
        dispatch = {
            enable = false, --true,
            jobs = {'police', 'ambulance'}
        },
    },
    ['panorama_dr_gsd'] = {
        label = 'Robs Liquor (Panorama Dr, Grand Senora Desert)',
        require = {
            ['police'] = 0 --2
        },
        requireItem = {
            ['lockpick'] = 1
        },
        reset = 1800,
        timer = 200,
        distanceToCancel = 10,
        rewards = {
            {item = 'black_money', min = 5000, max = 10000}
        },
        marker = {
            coords = vec3(1982.376953125, 3053.4140625, 47.215000152588),
            distance = 10
        },
        settings = {
            autoTemplate = false,
            autoPriority = false,
            autoBlip = true,
            autoAnnounce = true,
        },
        dispatch = {
            enable = false, --true,
            jobs = {'police', 'ambulance'}
        },
    },
    ['san_andreas_ave'] = {
        label = 'Robs Liquor (Vespucci Canais, San Andreas Avenue)',
        require = {
            ['police'] = 0 --2
        },
        requireItem = {
            ['lockpick'] = 1
        },
        reset = 1800,
        timer = 200,
        distanceToCancel = 10,
        rewards = {
            {item = 'black_money', min = 5000, max = 10000}
        },
        marker = {
            coords = vec3(-1222.0140380859, -908.29901123047, 12.326000213623),
            distance = 10
        },
        settings = {
            autoTemplate = false,
            autoPriority = false,
            autoBlip = true,
            autoAnnounce = true,
        },
        dispatch = {
            enable = false, --true,
            jobs = {'police', 'ambulance'}
        },
    },
    ['banham_canyon_dr'] = {
        label = 'LTD Gasoline (Richman Glen, Banham Canyon Dr)',
        require = {
            ['police'] = 0 --2
        },
        requireItem = {
            ['lockpick'] = 1
        },
        reset = 1800,
        timer = 200,
        distanceToCancel = 10,
        rewards = {
            {item = 'black_money', min = 5000, max = 10000}
        },
        marker = {
            coords = vec3(-1820.2270507812, 794.28698730469, 138.0890045166),
            distance = 10
        },
        settings = {
            autoTemplate = false,
            autoPriority = false,
            autoBlip = true,
            autoAnnounce = true,
        },
        dispatch = {
            enable = false, --true,
            jobs = {'police', 'ambulance'}
        },
    },
    ['davis_ave'] = {
        label = 'LTD Gasoline (Davis, Davis Avenue)',
        require = {
            ['police'] = 0 --2
        },
        requireItem = {
            ['lockpick'] = 1
        },
        reset = 1800,
        timer = 200,
        distanceToCancel = 10,
        rewards = {
            {item = 'black_money', min = 5000, max = 10000}
        },
        marker = {
            coords = vec3(-46.77799987793, -1757.9420166016, 29.420999526978),
            distance = 10
        },
        settings = {
            autoTemplate = false,
            autoPriority = false,
            autoBlip = true,
            autoAnnounce = true,
        },
        dispatch = {
            enable = false, --true,
            jobs = {'police', 'ambulance'}
        },
    },
    ['clinton_ave'] = {
        label = '24/7 (Downtown Vinewood, Clinton Avenue)',
        require = {
            ['police'] = 0 --2
        },
        requireItem = {
            ['lockpick'] = 1
        },
        reset = 1800,
        timer = 200,
        distanceToCancel = 10,
        rewards = {
            {item = 'black_money', min = 5000, max = 10000}
        },
        marker = {
            coords = vec3(373.15301513672, 328.67098999023, 103.56600189209),
            distance = 10
        },
        settings = {
            autoTemplate = false,
            autoPriority = false,
            autoBlip = true,
            autoAnnounce = true,
        },
        dispatch = {
            enable = false, --true,
            jobs = {'police', 'ambulance'}
        },
    },
    ['west_mirror_drive'] = {
        label = 'LTD Gasoline (Mirror Park, West Mirror Drive)',
        require = {
            ['police'] = 0 --2
        },
        requireItem = {
            ['lockpick'] = 1
        },
        reset = 1800,
        timer = 200,
        distanceToCancel = 10,
        rewards = {
            {item = 'black_money', min = 5000, max = 10000}
        },
        marker = {
            coords = vec3(1164.6459960938, -322.67001342773, 69.205001831055),
            distance = 10
        },
        settings = {
            autoTemplate = false,
            autoPriority = false,
            autoBlip = true,
            autoAnnounce = true,
        },
        dispatch = {
            enable = false, --true,
            jobs = {'police', 'ambulance'}
        },
    },
    ['barbareno_road'] = {
        label = '24/7 (Chumash, Barbareno Road)',
        require = {
            ['police'] = 0 --2
        },
        requireItem = {
            ['lockpick'] = 1
        },
        reset = 1800,
        timer = 200,
        distanceToCancel = 10,
        rewards = {
            {item = 'black_money', min = 5000, max = 10000}
        },
        marker = {
            coords = vec3(-3244.5749511719, 1000.1920166016, 12.829999923706),
            distance = 10
        },
        settings = {
            autoTemplate = false,
            autoPriority = false,
            autoBlip = true,
            autoAnnounce = true,
        },
        dispatch = {
            enable = false, --true,
            jobs = {'police', 'ambulance'}
        },
    },
    ['grand_senora_fwy'] = {
        label = '24/7 (Grand Senora Desert, Senora Fwy)',
        require = {
            ['police'] = 0 --2
        },
        requireItem = {
            ['lockpick'] = 1
        },
        reset = 1800,
        timer = 200,
        distanceToCancel = 10,
        rewards = {
            {item = 'black_money', min = 5000, max = 10000}
        },
        marker = {
            coords = vec3(2675.9699707031, 3280.5759277344, 55.24100112915),
            distance = 10
        },
        settings = {
            autoTemplate = false,
            autoPriority = false,
            autoBlip = true,
            autoAnnounce = true,
        },
        dispatch = {
            enable = false, --true,
            jobs = {'police', 'ambulance'}
        },
    },

    ['trap1'] = { 
        label = 'ANG BAHAY NG KUYA MO',
        require = {
            ['police'] = 0 --0
        },
        requireItem = {
            ['lockpick'] = 1
        },
        reset = 1800,
        timer = 350,
        distanceToCancel = 150,
        rewards = {
            {item = 'WEAPON_PISTOLXM3', min = 2, max = 2},
            {item = 'ammo-box1', min = 2, max = 2},
            {item = 'black_money', min = 5000, max = 5000}
        },
        marker = {
            coords = vec3(-1918.7911, 355.4158, 93.7814),
            distance = 10
        },
        settings = {
            autoTemplate = false,
            autoPriority = false,
            autoBlip = true,
            autoAnnounce = true,
            disablePCheck = true,
        },
        debug = {
            enable = true,
            blipSize = 150,
            ZoneSize = 150,
        },
        minigame = {
            game = 'lockpick', -- ['lockpick', 'skillCheck']
            lockpickCount = 3,
            skillCheck = {'easy', 'easy', 'hard', 'easy', 'hard'}
        }
    },
    ['trap2'] = {
        label = '8BALLS NI DM',
        require = {
            ['police'] = 0 --0
        },
        requireItem = {
            ['lockpick'] = 1
        },
        reset = 1800,
        timer = 350,
        distanceToCancel = 150,
        rewards = {
            {item = 'WEAPON_PISTOLXM3', min = 2, max = 2},
            {item = 'ammo-box1', min = 2, max = 2},
            {item = 'black_money', min = 5000, max = 5000}
        },
        marker = {
            coords = vec3(-1613.4287, -1028.0566, 13.1529),
            distance = 10
        },
        settings = {
            autoTemplate = false,
            autoPriority = false,
            autoBlip = true,
            autoAnnounce = true,
            disablePCheck = true,
        },
        debug = {
            enable = true,
            blipSize = 150,
            ZoneSize = 150,
        },
        minigame = {
            game = 'lockpick', -- ['lockpick', 'skillCheck']
            lockpickCount = 3,
            skillCheck = {'easy', 'easy', 'hard', 'easy', 'hard'}
        }
    },
    ['trap3'] = {
        label = 'LUPAIN NI OG',
        require = {
            ['police'] = 0 --0
        },
        requireItem = {
            ['lockpick'] = 1
        },
        reset = 1800,
        timer = 350,
        distanceToCancel = 150,
        rewards = {
            {item = 'WEAPON_PISTOLXM3', min = 2, max = 2},
            {item = 'ammo-box1', min = 2, max = 2},
            {item = 'black_money', min = 5000, max = 5000}
        },
        marker = {
            coords = vec3(984.95098876953, -584.55212402344, 59.402599334717),
            distance = 10
        },
        settings = {
            autoTemplate = false,
            autoPriority = false,
            autoBlip = true,
            autoAnnounce = true,
            disablePCheck = true,
        },
        debug = {
            enable = true,
            blipSize = 150,
            ZoneSize = 150,
        },
        minigame = {
            game = 'lockpick', -- ['lockpick', 'skillCheck']
            lockpickCount = 3,
            skillCheck = {'easy', 'easy', 'hard', 'easy', 'hard'}
        }
    },
    ['trap4'] = {
        label = 'Hood ni Pareng Long',
        require = {
            ['police'] = 0 --0
        },
        requireItem = {
            ['lockpick'] = 1
        },
        reset = 1800,
        timer = 350,
        distanceToCancel = 150,
        rewards = {
            {item = 'WEAPON_PISTOLXM3', min = 2, max = 2},
            {item = 'ammo-box1', min = 2, max = 2},
            {item = 'black_money', min = 5000, max = 5000}
        },
        marker = {
            coords = vec3(360.47198486328, -1829.4869384766, 28.890300750732),
            distance = 10
        },
        settings = {
            autoTemplate = false,
            autoPriority = false,
            autoBlip = true,
            autoAnnounce = true,
            disablePCheck = true,
        },
        debug = {
            enable = true,
            blipSize = 150,
            ZoneSize = 150,
        },
        minigame = {
            game = 'lockpick', -- ['lockpick', 'skillCheck']
            lockpickCount = 3,
            skillCheck = {'easy', 'easy', 'hard', 'easy', 'hard'}
        }
    },
    ['trap5'] = {
        label = 'Postal 7055',
        require = {
            ['police'] = 0 --0
        },
        requireItem = {
            ['lockpick'] = 1
        },
        reset = 1800,
        timer = 350,
        distanceToCancel = 150,
        rewards = {
            {item = 'WEAPON_PISTOLXM3', min = 2, max = 2},
            {item = 'ammo-box1', min = 2, max = 2},
            {item = 'black_money', min = 5000, max = 5000}
        },
        marker = {
            coords = vec3(-1142.4305, 365.6900, 71.3185),
            distance = 10
        },
        settings = {
            autoTemplate = false,
            autoPriority = false,
            autoBlip = true,
            autoAnnounce = true,
            disablePCheck = true,
        },
        debug = {
            enable = true,
            blipSize = 150,
            ZoneSize = 150,
        },
        minigame = {
            game = 'lockpick', -- ['lockpick', 'skillCheck']
            lockpickCount = 3,
            skillCheck = {'easy', 'easy', 'hard', 'easy', 'hard'}
        }
    },
    ['trap6'] = {
        label = 'METRO MANILA SUBWAY',
        require = {
            ['police'] = 0 --0
        },
        requireItem = {
            ['lockpick'] = 1
        },
        reset = 1800,
        timer = 350,
        distanceToCancel = 150,
        rewards = {
            {item = 'WEAPON_PISTOLXM3', min = 2, max = 2},
            {item = 'ammo-box1', min = 2, max = 2},
            {item = 'black_money', min = 5000, max = 5000}
        },
        marker = {
            coords = vec3(-272.3971, -334.6682, 18.2881),
            distance = 10
        },
        settings = {
            autoTemplate = false,
            autoPriority = false,
            autoBlip = true,
            autoAnnounce = true,
            disablePCheck = true,
        },
        debug = {
            enable = true,
            blipSize = 150,
            ZoneSize = 150,
        },
        minigame = {
            game = 'lockpick', -- ['lockpick', 'skillCheck']
            lockpickCount = 3,
            skillCheck = {'easy', 'easy', 'hard', 'easy', 'hard'}
        }
    },
    ['trap7'] = {
        label = 'SOGO HOTEL',
        require = {
            ['police'] = 0 --0
        },
        requireItem = {
            ['lockpick'] = 1
        },
        reset = 1800,
        timer = 350,
        distanceToCancel = 150,
        rewards = {
            {item = 'WEAPON_PISTOLXM3', min = 2, max = 2},
            {item = 'ammo-box1', min = 2, max = 2},
            {item = 'black_money', min = 5000, max = 5000}
        },
        marker = {
            coords = vec3(-1857.9263, -347.2064, 49.8377),
            distance = 10
        },
        settings = {
            autoTemplate = false,
            autoPriority = false,
            autoBlip = true,
            autoAnnounce = true,
            disablePCheck = true,
        },
        debug = {
            enable = true,
            blipSize = 150,
            ZoneSize = 150,
        },
        minigame = {
            game = 'lockpick', -- ['lockpick', 'skillCheck']
            lockpickCount = 3,
            skillCheck = {'easy', 'easy', 'hard', 'easy', 'hard'}
        }
    },
    --[[ ['trap8'] = {
        label = 'Hospital ni Nizzy at ni Chow',
        require = {
            ['police'] = 0 --0
        },
        requireItem = {
            ['lockpick'] = 1
        },
        reset = 1800,
        timer = 350,
        distanceToCancel = 150,
        rewards = {
            {item = 'WEAPON_PISTOLXM3', min = 2, max = 2},
            {item = 'ammo-box1', min = 2, max = 2},
            {item = 'black_money', min = 5000, max = 5000}
        },
        marker = {
            coords = vec3(327.1610, -603.7972, 43.2841),
            distance = 10
        },
        settings = {
            autoTemplate = false,
            autoPriority = false,
            autoBlip = true,
            autoAnnounce = true,
            disablePCheck = true,
        },
        debug = {
            enable = true,
            blipSize = 150,
            ZoneSize = 150,
        },
        minigame = {
            game = 'lockpick', -- ['lockpick', 'skillCheck']
            lockpickCount = 3,
            skillCheck = {'easy', 'easy', 'hard', 'easy', 'hard'}
        }
    }, ]]
    ['trap8'] = {
        label = 'BILAT OTEN HOUSES',
        require = {
            ['police'] = 0 --0
        },
        requireItem = {
            ['lockpick'] = 1
        },
        reset = 1800,
        timer = 350,
        distanceToCancel = 150,
        rewards = {
            {item = 'WEAPON_PISTOLXM3', min = 2, max = 2},
            {item = 'ammo-box1', min = 2, max = 2},
            {item = 'black_money', min = 5000, max = 5000}
        },
        marker = {
            coords = vec3(1283.7417, -1699.9020, 55.4758),
            distance = 10
        },
        settings = {
            autoTemplate = false,
            autoPriority = false,
            autoBlip = true,
            autoAnnounce = true,
            disablePCheck = true,
        },
        debug = {
            enable = true,
            blipSize = 150,
            ZoneSize = 150,
        },
        minigame = {
            game = 'lockpick', -- ['lockpick', 'skillCheck']
            lockpickCount = 3,
            skillCheck = {'easy', 'easy', 'hard', 'easy', 'hard'}
        }
    },
    ['trap9'] = {
        label = 'Rigor Dimaguiba PoliceD',
        require = {
            ['police'] = 0 --0
        },
        requireItem = {
            ['lockpick'] = 1
        },
        reset = 1800,
        timer = 350,
        distanceToCancel = 150,
        rewards = {
            {item = 'WEAPON_PISTOLXM3', min = 2, max = 2},
            {item = 'ammo-box1', min = 2, max = 2},
            {item = 'black_money', min = 5000, max = 5000}
        },
        marker = {
            coords = vec3(443.5516, -975.1521, 30.6896),
            distance = 10
        },
        settings = {
            autoTemplate = false,
            autoPriority = false,
            autoBlip = true,
            autoAnnounce = true,
            disablePCheck = true,
        },
        debug = {
            enable = true,
            blipSize = 150,
            ZoneSize = 150,
        },
        minigame = {
            game = 'lockpick', -- ['lockpick', 'skillCheck']
            lockpickCount = 3,
            skillCheck = {'easy', 'easy', 'hard', 'easy', 'hard'}
        }
    },
}