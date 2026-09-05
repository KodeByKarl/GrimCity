ConfigAutofarm = {}

ConfigAutofarm.Debug = false

ConfigAutofarm.Marker = {
    type = 21, -- MarkerTypeChevronUpx2
    drawDistance = 50.0,
    interactionDistance = 1.0,
    scale = vec3(0.35, 0.35, 0.35),
    color = { r = 75, g = 175, b = 255, a = 180 },
    bobUpAndDown = true,
    faceCamera = true,
    rotate = false,
}

ConfigAutofarm.Farming = {
    minAmount = 1,          -- lowest roll per gather cycle (fallback)
    maxAmount = 5,          -- highest roll per gather cycle (fallback)
    cycleTime = 10000,      -- ms per gather cycle (server owns timing)
    animDict = "amb@world_human_gardener_plant@male@base",
    animName = "base",
    toolUses = 100,         -- pickups before required tools break (-1 durability per gather cycle)
}

--[[
  Optional per-farm fields (HUD):
    zone   = "Orange Grove"   -- defaults to blip.label
    rarity = "common"|"uncommon"|"rare"|"epic"  -- auto: rare if drops include diamond/emerald/kevlar/titanium
]]

-- Server security / anti-cheat tolerances
ConfigAutofarm.Security = {
    maxDistanceGrace = 2.0,   -- extra meters beyond interactionDistance for latency
    requestCooldown = 750,    -- ms between accepted start/stop requests
    maxRequestsPerWindow = 8, -- start/stop attempts allowed per window
    requestWindow = 5000,     -- ms window for rate limiting
    schedulerInterval = 250,  -- ms between server session ticks
}

-- Shared defaults applied to every farm blip (coords/label/sprite/color stay per farm)
ConfigAutofarm.BlipDefaults = {
    scale = 0.75,
    shortRange = true,
    display = 3, -- pause map only, never the minimap
}

-- Standalone map blips (not tied to a single farm marker)
ConfigAutofarm.ExtraBlips = {
    {
        label = "AutoFarm Grindings",
        coords = vec4(2004.3286, 4902.1523, 42.7468, 58.4939),
        sprite = 478,
        color = 2,
    },
}

ConfigAutofarm.Farms = {
    {
        item = "mango",
        requireTool = "trowel",
        minAmount = 1,
        maxAmount = 5,
        blip = {
            label = "Mango Farm",
            sprite = 478,
            color = 2,
        },
        zone = "Mango Grove",
        rarity = "common",
        locations = {
            vec4(2326.0691, 4761.2773, 35.9651, 47.1926),
            vec4(2327.6001, 4770.3359, 36.0531, 359.6024),
            vec4(2338.9204, 4767.1621, 35.2035, 253.7354),
            vec4(2343.2339, 4756.0454, 34.8275, 196.9296),
            vec4(2353.2368, 4760.0508, 34.3616, 313.9893),
            vec4(2339.7444, 4741.6909, 35.0741, 133.8657),
            vec4(2324.8701, 4746.3657, 36.0299, 73.5989),
        },
    },
    {
        item = "apple",
        requireTool = "trowel",
        minAmount = 1,
        maxAmount = 5,
        blip = {
            label = "Apple Farm",
            sprite = 478,
            color = 1,
        },
        zone = "Apple Orchard",
        rarity = "common",
        locations = {
            vec4(2350.1160, 4734.4121, 34.8094, 216.4595),
            vec4(2364.3943, 4729.6758, 34.1978, 245.2126),
            vec4(2374.2000, 4735.0234, 33.7387, 283.2375),
            vec4(2386.4980, 4735.9536, 33.2526, 304.9070),
            vec4(2386.8850, 4725.0439, 33.6235, 178.4402),
            vec4(2383.0979, 4713.6362, 33.6499, 170.6313),
            vec4(2401.9819, 4716.7217, 33.1566, 308.6675),
        },
    },
    {
        item = "honey",
        requireTool = "trowel",
        minAmount = 1,
        maxAmount = 5,
        blip = {
            label = "Honey Farm",
            sprite = 478,
            color = 5,
        },
        zone = "Honey Apiary",
        rarity = "common",
        locations = {
            vec4(2404.6506, 4703.5264, 33.3854, 17.1392),
            vec4(2413.1804, 4707.0264, 33.0073, 64.2971),
            vec4(2405.0073, 4704.0786, 33.3615, 89.7611),
            vec4(2390.4385, 4691.0996, 33.9083, 118.2289),
            vec4(2401.1704, 4688.3672, 33.6905, 257.6907),
            vec4(2406.7712, 4677.3530, 33.9625, 211.8408),
            vec4(2419.2136, 4674.2212, 33.8637, 253.4783),
            vec4(2433.8352, 4678.6768, 33.3849, 278.2501),
            vec4(2442.9568, 4672.3843, 33.3346, 263.0943),
        },
    },
    {
        item = "crab",
        requireTool = "fish_trap",
        minAmount = 1,
        maxAmount = 5,
        blip = {
            label = "Crab Farm",
            sprite = 68,
            color = 3,
        },
        zone = "Crab Shore",
        rarity = "uncommon",
        locations = {
            vec4(-284.5971, 6603.2383, 1.0985, 128.3568),
            vec4(-287.0456, 6601.3682, 1.1880, 128.1027),
            vec4(-291.3963, 6597.0337, 1.1360, 138.1688),
            vec4(-295.3122, 6591.7163, 1.0977, 147.1397),
            vec4(-300.9596, 6593.1689, 0.0185, 73.0379),
            vec4(-294.7993, 6598.9629, 0.5086, 38.6048),
            vec4(-294.0473, 6603.1309, 0.2679, 7.7296),
        },
    },
    {
        item = "cocoa",
        requireTool = "trowel",
        minAmount = 1,
        maxAmount = 5,
        prop = "prop_plant_cane_01b",
        interactionDistance = 2.5,
        blip = {
            label = "Cocoa Farm",
            sprite = 478,
            color = 31,
        },
        zone = "Cocoa Fields",
        rarity = "common",
        locations = {
            vec4(2050.5632, 4928.3115, 41.1247, 226.2420),
            vec4(2046.3123, 4932.3276, 41.0930, 43.9851),
            vec4(2042.5524, 4936.3628, 41.0987, 42.3768),
            vec4(2036.9362, 4941.8696, 41.0723, 44.7815),
            vec4(2032.9570, 4945.6938, 41.0656, 46.5814),
            vec4(2029.5319, 4949.1685, 41.1119, 44.4854),
            vec4(2031.7413, 4952.2271, 41.0728, 308.0679),
            vec4(2034.4867, 4949.7637, 41.0825, 222.1368),
            vec4(2037.5516, 4946.4146, 41.1099, 223.2327),
            vec4(2040.5029, 4943.6084, 41.1142, 223.4263),
            vec4(2043.3051, 4940.8535, 41.0986, 224.2684),
            vec4(2046.1466, 4938.0488, 41.0907, 223.8445),
            vec4(2048.8386, 4935.3325, 41.0938, 224.7577),
            vec4(2051.8372, 4932.3599, 41.0773, 225.8304),
        },
    },
    -- Scrap yard: blowtorch grind -> scrap + vest craft mats (cloth / metals / rare kevlar)
    {
        item = "scrapmetal",
        requireTool = "blowtorch",
        minAmount = 1,
        maxAmount = 10,
        blip = {
            label = "Scrap Metal Farm",
            sprite = 318,
            color = 39,
        },
        zone = "Scrap Yard",
        rarity = "rare",
        drops = {
            { item = "scrapmetal", chance = 35 },
            { item = "cloth",      chance = 25 },
            { item = "aluminum",   chance = 18 },
            { item = "iron",       chance = 15 },
            { item = "kevlar",     chance = 7 },
        },
        locations = {
            vec4(2421.2666, 3090.3376, 48.7788, 178.9109),
            vec4(2412.3220, 3088.2563, 48.1532, 177.3567),
            vec4(2399.7146, 3080.2405, 49.2829, 180.2445),
            vec4(2397.2185, 3090.2161, 48.1502, 178.8030),
            vec4(2398.7524, 3093.5376, 48.1530, 341.5334),
            vec4(2405.8015, 3117.9524, 48.1945, 339.1266),
            vec4(2417.2441, 3114.1614, 48.1837, 11.3196),
        },
    },
    -- Step 1: Mine rocks only
    {
        item = "stone",
        requireTool = "pickaxe",
        minAmount = 1,
        maxAmount = 5,
        animDict = "melee@large_wpn@streamed_core",
        animName = "ground_attack_on_spot",
        blip = {
            label = "Mining Area",
            sprite = 618,
            color = 47,
        },
        zone = "Quarry Dig",
        rarity = "uncommon",
        locations = {
            vec4(2997.7546, 2750.3755, 44.4822, 219.3032),
            vec4(3002.8601, 2759.3132, 43.1052, 235.9231),
            vec4(3005.2012, 2767.5173, 42.9921, 267.7477),
            vec4(3005.6785, 2777.7139, 43.1193, 276.3620),
            vec4(3003.2349, 2787.8542, 44.3434, 288.1631),
            vec4(2996.2256, 2799.8101, 43.9164, 309.6740),
        },
    },
    -- Step 2: Wash rocks -> washed_rocks (5 stone -> 5 washed_rocks)
    {
        item = "washed_rocks",
        requireItem = "stone",
        minAmount = 5,
        maxAmount = 5,
        animDict = "amb@world_human_bum_wash@male@high@idle_a",
        animName = "idle_a",
        blip = {
            label = "Wash Rocks",
            sprite = 78,
            color = 3,
        },
        zone = "Rock Wash",
        rarity = "uncommon",
        locations = {
            vec4(-178.5307, 796.4457, 196.7460, 161.8333),
            vec4(-174.1920, 793.7794, 196.6152, 241.5947),
            vec4(-168.7378, 791.7784, 196.6870, 241.7432),
        },
    },
    -- Step 3: Melt washed rocks -> ores / gems (5 washed_rocks -> 5 ore/gem)
    {
        item = "washed_rocks",
        requireItem = "washed_rocks",
        minAmount = 5,
        maxAmount = 5,
        animDict = "amb@world_human_stand_fire@male@idle_a",
        animName = "idle_a",
        blip = {
            label = "Melting Furnace",
            sprite = 436,
            color = 1,
        },
        zone = "Smelter Run",
        rarity = "rare",
        drops = {
            { item = "copper",    chance = 28 },
            { item = "iron",      chance = 22 },
            { item = "aluminum",  chance = 16 },
            { item = "steel",     chance = 14 },
            { item = "titanium",  chance = 10 },
            { item = "diamond",   chance = 6 },
            { item = "emerald",   chance = 4 },
        },
        locations = {
            vec4(1109.9458, -2008.1837, 31.0600, 234.0828),
        },
    },
    -- Veggie grind: target world props (ox_target). Image swaps per random drop like mining.
    {
        item = "potato",
        targetModel = 1770147046,
        requireTool = "trowel",
        minAmount = 1,
        maxAmount = 5,
        interactionDistance = 2.5,
        animDict = "amb@world_human_gardener_plant@male@base",
        animName = "base",
        blip = {
            label = "Vegetable Crate",
            sprite = 478,
            color = 2,
        },
        zone = "Vegetable Crate",
        rarity = "common",
        drops = {
            { item = "potato",   chance = 34 },
            { item = "onion",    chance = 33 },
            { item = "mushroom", chance = 33 },
        },
        -- Optional map hint; interaction is via ox_target on the model, not this marker.
        locations = {},
    },
    {
        item = "lettuce",
        targetModel = -1495113814,
        requireTool = "trowel",
        minAmount = 1,
        maxAmount = 5,
        interactionDistance = 2.5,
        animDict = "amb@world_human_gardener_plant@male@base",
        animName = "base",
        blip = {
            label = "Leafy Greens",
            sprite = 478,
            color = 25,
        },
        zone = "Leafy Greens",
        rarity = "common",
        drops = {
            { item = "lettuce",  chance = 50 },
            { item = "cabbage",  chance = 50 },
        },
        locations = {},
    },
    {
        item = "pumpkin",
        targetModel = -1163697832,
        requireTool = "trowel",
        minAmount = 1,
        maxAmount = 5,
        interactionDistance = 2.5,
        animDict = "amb@world_human_gardener_plant@male@base",
        animName = "base",
        blip = {
            label = "Pumpkin Patch",
            sprite = 478,
            color = 47,
        },
        zone = "Pumpkin Patch",
        rarity = "common",
        locations = {},
    },
    {
        item = "arabica",
        targetModel = 806208808,
        requireTool = "trowel",
        minAmount = 1,
        maxAmount = 5,
        interactionDistance = 2.5,
        animDict = "amb@world_human_gardener_plant@male@base",
        animName = "base",
        blip = {
            label = "Arabica Farm",
            sprite = 478,
            color = 31,
        },
        zone = "Arabica Rows",
        rarity = "uncommon",
        locations = {},
    },
    {
        item = "tomato",
        targetModel = 208011532,
        requireTool = "trowel",
        minAmount = 1,
        maxAmount = 5,
        interactionDistance = 2.5,
        animDict = "amb@world_human_gardener_plant@male@base",
        animName = "base",
        blip = {
            label = "Tomato Farm",
            sprite = 478,
            color = 1,
        },
        zone = "Tomato Vines",
        rarity = "common",
        locations = {},
    },
    {
        item = "carrot",
        targetModel = 1606407593,
        requireTool = "trowel",
        minAmount = 1,
        maxAmount = 5,
        interactionDistance = 2.5,
        animDict = "amb@world_human_gardener_plant@male@base",
        animName = "base",
        blip = {
            label = "Carrot Farm",
            sprite = 478,
            color = 47,
        },
        zone = "Carrot Beds",
        rarity = "common",
        locations = {},
    },
}

-- Controls: 38 = E, 73 = X. See https://fivemdocs.com/game-references/controls
ConfigAutofarm.Controls = {
    start = 38,
    cancel = 73,
}
