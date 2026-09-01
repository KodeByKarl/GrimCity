Config = Config or {}

--[[
  Chop Shop — dismantle database-owned vehicles into scrap + car parts.
  Spawn / admin / test / preview cars are rejected (must exist in owned_vehicles).
]]
Config.ChopShop = {
    ProgressDuration = 12000,
    Cooldown = 20000,
    InteractionDistance = 3.2,
    ZoneRadius = 6.5,
    DrawDistance = 50.0,
    MaxVehicleSpeed = 1.2,

    Marker = {
        enabled = true,
        -- Ground pad (type 1 = cylinder)
        type = 1,
        size = vector3(5.2, 5.2, 0.55),
        color = { r = 196, g = 30, b = 45, a = 150 },
        zOffset = -0.95,
        -- Floating car icon (type 36)
        carIcon = true,
        carIconZ = 1.15,
        carIconSize = 1.15,
        -- Help text above the pad
        text = "Park vehicle here",
        textZ = 1.55,
    },

    -- Blip on pause map + minimap so the yard is findable
    Blip = {
        enabled = true,
        sprite = 380,
        color = 1,
        scale = 0.75,
        label = "Chop Shop",
    },

    Locations = {
        {
            id = "lapuerta",
            label = "La Puerta Chop Shop",
            coords = vector3(-425.2028, -1687.5762, 19.0291),
            heading = 156.9552,
        },
    },

    -- Vehicle classes allowed to chop (no air / sea / trains / bikes)
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

    -- Faction / job garage cars stay off the chop list
    BlockJobVehicles = true,

    Rewards = {
        { item = "scrapmetal", min = 8, max = 16, chance = 100 },
        { item = "car_door", min = 1, max = 2, chance = 72 },
        { item = "car_hood", min = 1, max = 1, chance = 55 },
        { item = "car_wheel", min = 1, max = 4, chance = 80 },
        { item = "car_battery", min = 1, max = 1, chance = 58 },
        { item = "car_alternator", min = 1, max = 1, chance = 42 },
        { item = "car_radiator", min = 1, max = 1, chance = 40 },
        { item = "car_engine_part", min = 1, max = 2, chance = 48 },
        { item = "brake_pads", min = 1, max = 2, chance = 50 },
        { item = "spark_plugs", min = 2, max = 4, chance = 52 },
    },
}
