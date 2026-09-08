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
ConfigAutofarm.ExtraBlips = {}

ConfigAutofarm.Farms = {
    {
        item = "orange",
        requireTool = "trowel",
        minAmount = 1,
        maxAmount = 5,
        blip = {
            label = "Orange Farm",
            sprite = 478,
            color = 47,
        },
        zone = "Orange Grove",
        rarity = "common",
        locations = {
            vec4(281.1007, 6530.7979, 30.1681, 87.7354),
            vec4(281.1576, 6519.3301, 30.1663, 188.3329),
            vec4(282.0134, 6507.1079, 30.1311, 190.9857),
            vec4(273.8100, 6507.8022, 30.4045, 174.7309),
            vec4(272.3322, 6518.7520, 30.4454, 3.1285),
            vec4(270.6439, 6529.9097, 30.4957, 355.3962),
            vec4(262.0756, 6527.6426, 30.7290, 115.8618),
            vec4(261.9674, 6516.1113, 30.7218, 332.9687),
            vec4(264.0572, 6506.6055, 30.6742, 190.1905),
            vec4(256.5963, 6503.9209, 30.8583, 95.0488),
            vec4(247.7032, 6502.8765, 31.0349, 90.6260),
            vec4(237.3919, 6502.0366, 31.1941, 96.4854),
            vec4(228.5582, 6501.5518, 31.3058, 90.3515),
            vec4(220.5690, 6499.3438, 31.3795, 92.9347),
            vec4(210.4722, 6498.4282, 31.4575, 93.9403),
            vec4(202.0974, 6497.1865, 31.4735, 88.1759),
            vec4(194.2134, 6496.8652, 31.5245, 88.4632),
            vec4(186.0942, 6497.7979, 31.5383, 71.0553),
            vec4(199.0251, 6508.4922, 31.5089, 302.1099),
            vec4(207.3578, 6510.0991, 31.4783, 269.6531),
            vec4(217.3948, 6510.2061, 31.4026, 265.0481),
            vec4(225.3236, 6511.2979, 31.3354, 285.9139),
            vec4(233.9084, 6512.6440, 31.2423, 285.0418),
            vec4(244.3959, 6514.9160, 31.0916, 289.9147),
            vec4(252.9937, 6514.2280, 30.9309, 270.8285),
            vec4(261.7072, 6516.5977, 30.7270, 279.0694),
            vec4(271.9549, 6519.0083, 30.4509, 276.4197),
            vec4(262.0928, 6527.4795, 30.7311, 79.8245),
            vec4(252.9938, 6527.4604, 30.9366, 80.3968),
            vec4(243.4251, 6526.4194, 31.1055, 92.1188),
            vec4(233.8522, 6524.8521, 31.2447, 98.2762),
            vec4(224.3740, 6523.8018, 31.3501, 104.3808),
        },
    },
    {
        item = "wood",
        requireTool = "battleaxe",
        minAmount = 1,
        maxAmount = 5,
        animDict = "melee@large_wpn@streamed_core",
        animName = "ground_attack_on_spot",
        blip = {
            label = "Lumberjack Wood",
            sprite = 79,
            color = 31,
        },
        zone = "Lumberjack Wood Claim",
        rarity = "common",
        locations = {
            vec4(-566.63781738281, 5456.9838867188, 60.924140930176, 0.0),
            vec4(-561.06402587891, 5460.6147460938, 62.28295135498, 0.0),
            vec4(-572.12945556641, 5467.9995117188, 60.282844543457, 0.0),
            vec4(-577.73956298828, 5468.4604492188, 59.387260437012, 0.0),
            vec4(-582.61602783203, 5468.8203125, 58.408874511719, 0.0),
            vec4(-597.7041015625, 5473.890625, 54.611961364746, 0.0),
        },
    },
    {
        item = "money",
        minAmount = 250,
        maxAmount = 500,
        job = "ambulance",
        scenario = "WORLD_HUMAN_JANITOR",
        rewardCoins = { min = 1, max = 2 },
        blip = {
            label = "HP Mopping",
            sprite = 403,
            color = 1,
        },
        zone = "Hospital Mopping",
        rarity = "common",
        locations = {
            vec4(311.9, -599.5, 43.3, 0.0),
            vec4(314.5, -592.5, 43.3, 0.0),
            vec4(319.2, -584.7, 43.3, 0.0),
            vec4(323.8, -575.6, 43.3, 0.0),
            vec4(306.3687, -601.5139, 43.28406, 0.0),
        },
    },
    {
        item = "bandage",
        drops = {
            { item = "bandage", chance = 50 },
            { item = "gauze", chance = 35 },
            { item = "stresstab", chance = 15 },
        },
        minAmount = 1,
        maxAmount = 2,
        job = "ambulance",
        animDict = "missfbi3_party_b",
        animName = "clean_counter_loop",
        rewardCoins = { min = 1, max = 2 },
        blip = {
            label = "HP Wiping & Sanitizing",
            sprite = 403,
            color = 2,
        },
        zone = "Hospital Sanitizing",
        rarity = "uncommon",
        locations = {
            vec4(301.3, -600.23, 43.28, 340.0),
            vec4(313.2, -580.3, 43.3, 180.0),
            vec4(322.4, -588.6, 43.3, 90.0),
            vec4(320.1, -594.2, 43.3, 270.0),
        },
    },
}

-- Controls: 38 = E, 73 = X. See https://fivemdocs.com/game-references/controls
ConfigAutofarm.Controls = {
    start = 38,
    cancel = 73,
}
