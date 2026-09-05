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
            vec4(280.37805175781, 6530.8310546875, 29.120361328125, 0.0),
            vec4(270.48852539062, 6530.556640625, 29.417785644531, 0.0),
            vec4(261.52819824219, 6527.64453125, 29.528991699219, 0.0),
            vec4(263.89831542969, 6506.115234375, 29.633544921875, 0.0),
            vec4(273.49841308594, 6507.4140625, 29.355346679688, 0.0),
            vec4(244.69537353516, 6515.3271484375, 29.951385498047, 0.0),
            vec4(234.40908813477, 6512.65234375, 30.116088867188, 0.0),
            vec4(236.72769165039, 6501.96484375, 30.201293945312, 0.0),
            vec4(209.96496582031, 6498.25390625, 30.256988525391, 0.0),
            vec4(185.11193847656, 6498.119140625, 30.327850341797, 0.0),
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
    {
        item = "money",
        minAmount = 500,
        maxAmount = 1000,
        job = "police",
        animDict = "combat@aim_variations@heavy@standing",
        animName = "aim",
        rewardCoins = { min = 2, max = 5 },
        blip = {
            label = "PD Firing Squad",
            sprite = 313,
            color = 38,
        },
        zone = "PD Firing Squad",
        rarity = "rare",
        locations = {
            vec4(456.2, -1008.1, 28.4, 90.0),
            vec4(456.2, -1010.5, 28.4, 90.0),
            vec4(456.2, -1012.8, 28.4, 90.0),
            vec4(456.2, -1015.1, 28.4, 90.0),
            vec4(456.2, -1017.4, 28.4, 90.0),
        },
    },
}

-- Controls: 38 = E, 73 = X. See https://fivemdocs.com/game-references/controls
ConfigAutofarm.Controls = {
    start = 38,
    cancel = 73,
}
