Config = Config or {}

--[[
  Weed farm / process benches.
]]
Config.WeedFarm = {
    HarvestDuration = 4000,
    ProcessDuration = 5000,
    CollectDuration = 4000,
    CollectCooldown = 15000, -- ms personal cooldown after collect (per player, not shared)

    -- ═══════════════════════════════════════════
    -- WEED
    -- ═══════════════════════════════════════════
    PlantModel = 452618762,
    PlantModelName = "bkr_prop_weed_01_smallb",
    ItemName = "weed_bud",
    ItemLabel = "Weed Bud",
    MinReward = 2,
    MaxReward = 5,
    RegrowDuration = 30000,

    Locations = {
        vector3(2218.5346679688, 5577.3530273438, 52.85710144043),
        vector3(2218.2797851562, 5575.1586914062, 52.72047424316),
        vector3(2218.9174804688, 5579.6567382812, 52.95548248291),
        vector3(2220.5356445312, 5577.2475585938, 52.850387573242),
        vector3(2221.0153808594, 5574.9375, 52.721000671387),
        vector3(2222.6870117188, 5574.8706054688, 52.723663330078),
        vector3(2223.0590820312, 5577.1059570312, 52.842315673828),
        vector3(2223.7900390625, 5579.3271484375, 52.931976318359),
        vector3(2225.4094238281, 5579.1958007812, 52.937934875488),
        vector3(2225.3239746094, 5576.9165039062, 52.859100341797),
        vector3(2227.6826171875, 5576.7734375, 52.875411987305),
        vector3(2230.1701660156, 5576.59375, 52.956756591797),
        vector3(2230.6748046875, 5574.2983398438, 52.91535949707),
        vector3(2230.1079101562, 5578.9145507812, 53.020454406738)
    },

    -- Unused (weed is harvested from plants, not collect stations)
    CollectStations = {},

    ProcessStations = {
        -- ── WEED 2nd: 5 weed_bud + ziplock -> 5 packaged_weed
        {
            id = "weed_package",
            label = "Package Weed",
            progressLabel = "PACKAGING WEED",
            coords = vector4(2221.8430, 5614.8291, 54.9016, 284.0298),
            interactionDistance = 2.0,
            input = { item = "weed_bud", amount = 5, label = "Weed Bud" },
            require = { item = "zipper_bag", amount = 1, label = "Zip-lock Bag" },
            requires = {
                { item = "zipper_bag", amount = 1, label = "Zip-lock Bag" },
            },
            output = { item = "packaged_weed", amount = 5, label = "Packaged Weed" },
        },
        -- ── WEED 3rd: 5 packaged_weed + 5 rolling paper + 5 paper bag + 1K dirty money -> 5 joint
        {
            id = "weed_roll",
            label = "Roll Joint",
            progressLabel = "ROLLING JOINT",
            coords = vector4(2195.8811, 5601.7451, 53.6019, 88.0269),
            interactionDistance = 2.0,
            input = { item = "packaged_weed", amount = 5, label = "Packaged Weed" },
            requires = {
                { item = "rolling_paper", amount = 5, label = "Rolling Paper" },
                { item = "paperbag", amount = 5, label = "Paper Bag" },
                { item = "black_money", amount = 1000, label = "Dirty Money", isMoney = true },
            },
            output = { item = "joint", amount = 5, label = "Joint" },
        },
    },
}
