return {
    Enabled = true,
    NotifyTitle = 'PLAYTIME REWARD',
    DistanceCheck = 5.0,
    PedCoords = vec3(-260.5113, -965.4332, 31.2244),

    -- Claim at the Playtime Reward NPC (Legion).
    -- neon = free on first claim (new players can take it immediately)
    -- sunrise = unlocks after 6 hours total playtime
    Rewards = {
        neon = {
            Label = 'Pfister Neon',
            RequiredSeconds = 0,
            VehicleModel = 'neon',
            GarageId = 'Legion Square',
            NicknamePrefix = 'STARTER-NEON',
            OneTime = true,
        },
        sunrise = {
            Label = 'Sunrise',
            RequiredSeconds = 6 * 60 * 60, -- 6 hours total playtime
            VehicleModel = 'sunrise1',
            GarageId = 'Legion Square',
            NicknamePrefix = 'PLAYTIME-SUNRISE',
            OneTime = true,
        },
    },
}
