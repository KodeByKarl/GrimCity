Config = Config or {}

Config.FreeCar = {
    Command = "freecar",
    NotificationTitle = "FREE CAR",
    SpinDurationMs = 6500,
    -- Default garage where both vehicles are stored (must match jg-advancedgarages name)
    GarageId = "Legion Square",
    -- Fixed bonus vehicle every player also receives (in addition to roulette win)
    BonusVehicle = {
        model = "burrito",
        label = "Declasse Burrito",
    },
    -- chance values are relative weights (total does not need to be 100)
    AllowedVehicles = {
        { model = "sultan",  label = "Karin Sultan",   chance = 32.333, rarity = "common" },
        { model = "kuruma",  label = "Karin Kuruma",   chance = 32.333, rarity = "common" },
        { model = "sugoi",   label = "Dinka Sugoi",    chance = 32.334, rarity = "common" },
        { model = "jugular", label = "Ocelot Jugular", chance = 2.0,    rarity = "rare" },
        { model = "neon",    label = "Pfister Neon",   chance = 1.0,    rarity = "legendary" },
    },
}
