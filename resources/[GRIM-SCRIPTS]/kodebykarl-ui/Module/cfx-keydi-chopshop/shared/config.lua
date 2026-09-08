Config = Config or {}

--[[
  Illegal Chop (Chop2) — dismantle owned vehicles for dirty cash.
  Starts a police dispatch the moment a chop begins.
]]
Config.ChopShop = {
    Label = "Illegal Chop",
    ProgressDuration = 45000, -- longer risk window while PD is alerted
    Cooldown = 120000, -- 2 min between chops
    InteractionDistance = 3.2,
    ZoneRadius = 8.0,
    DrawDistance = 50.0,
    MaxVehicleSpeed = 1.2,

    -- Police / sheriff alert when a chop starts
    Dispatch = {
        enabled = true,
        jobs = { "police", "sheriff" },
        message = "Illegal vehicle chop in progress",
        duration = 15000,
        blipSprite = 380,
        blipColor = 1,
        blipScale = 1.0,
        blipTime = 180000, -- 3 minutes on map for LEO
    },

    -- Minimum LEO online to start (0 = always allow, still alerts if any are on)
    RequirePolice = 0,

    Marker = {
        enabled = true,
        type = 1,
        size = vector3(5.2, 5.2, 0.55),
        color = { r = 196, g = 30, b = 45, a = 150 },
        zOffset = -0.95,
        carIcon = true,
        carIconZ = 1.15,
        carIconSize = 1.15,
        text = "Illegal Chop — Park vehicle",
        textZ = 1.55,
    },

    Blip = {
        enabled = true,
        sprite = 380,
        color = 1,
        scale = 0.75,
        label = "Illegal Chop Yard",
    },

    Locations = {
        {
            id = "lapuerta",
            label = "La Puerta Illegal Chop",
            coords = vector3(-425.2028, -1687.5762, 19.0291),
            heading = 156.9552,
        },
    },

    AllowedClasses = {
        [0] = true,  -- Compacts
        [1] = true,  -- Sedans
        [2] = true,  -- SUVs
        [3] = true,  -- Coupes
        [4] = true,  -- Muscle
        [5] = true,  -- Sports Classics
        [6] = true,  -- Sports
        [7] = true,  -- Super
        [8] = true,  -- Motorcycles
        [9] = true,  -- Off-road
        [11] = true, -- Utility
        [12] = true, -- Vans
    },

    BlockedPlates = {
        PREVIEW = true,
        TESTDRIVE = true,
        TEST = true,
        ADMINTST = true,
        ADMIN = true,
    },

    BlockJobVehicles = true,

    -- Primary illegal payout
    MoneyReward = {
        item = "black_money",
        amount = 500000,
    },

    -- Optional scrap leftovers (still rolls on top of the 500k)
    Rewards = {
        { item = "scrapmetal", min = 4, max = 10, chance = 70 },
        { item = "car_door", min = 1, max = 1, chance = 35 },
        { item = "car_wheel", min = 1, max = 2, chance = 40 },
        { item = "car_battery", min = 1, max = 1, chance = 25 },
        { item = "spark_plugs", min = 1, max = 2, chance = 30 },
    },
}
