Config.HouseRob = {}
Config.HouseRob.LimitTime = false -- Use in-game clock hours to set the time the houses can be robbed
Config.HouseRob.MinimumTime = 0 -- only needed if LimitTime is true
Config.HouseRob.MaximumTime = 24 -- only needed if LimitTime is true
Config.HouseRob.TimeToCloseDoors = 25 -- in minutes (only start counting after one person enters the house)
Config.HouseRob.ChanceToAlertPolice = 100 -- chance in percent to call the police if a house robbery is in progress
Config.HouseRob.MinZOffset = 45

-- Footstep + gunfire sound meter while inside a robbed house.
-- Walking/running always raises the meter (aiming does NOT hide footsteps).
-- Shooting spikes the meter. At 100% the player is force-exited and LEO are alerted.
-- Paleto / Blaine County houses (y >= 2500 or name contains "paleto") alert sheriff.
Config.HouseRob.SoundDetection = {
    enabled = true,
    walkNoise = 7.5,       -- % per second while walking
    runNoise = 18.0,       -- % per second while running
    sprintNoise = 28.0,    -- % per second while sprinting
    shotSpike = 60.0,      -- % added the frame a shot is fired
    shotNoise = 40.0,      -- % per second while holding fire with a gun
    idleDecay = 5.0,       -- % per second decay when still
    moveThreshold = 0.45,  -- GetEntitySpeed must exceed this to count as moving
    alertJobs = { 'police' },
    -- Houses north of this Y (Sandy / Grapeseed / Paleto / Senora) go to sheriff.
    sheriffMinY = 2500.0,
    sheriffJobs = { 'sheriff' },
}

Config.HouseRob.Rewards = {
    -- Full package once per house (first successful search). Only 1 recycling pack per house.
    -- All amounts are rolled/applied server-side only — never trust the client.
    dirtyMoney = { item = 'black_money', amount = 50000 },
    recycling = { item = 'recmats', min = 1, max = 1 },

    -- 5–10 car blueprints for one random lootable project vehicle (same model so they stack toward 25).
    blueprints = { item = 'car_blueprint', min = 5, max = 10 },

    -- Random unique project-vehicle parts (Charger Engine, Civic Tires, etc.).
    projectParts = {
        rolls = { min = 2, max = 3 },
        pool = {
            { item = 'engine', min = 1, max = 1 },
            { item = 'transmission', min = 1, max = 1 },
            { item = 'suspension', min = 1, max = 1 },
            { item = 'bodyframe', min = 1, max = 1 },
            { item = 'tire', min = 1, max = 2 },
            { item = 'door', min = 1, max = 1 },
            { item = 'window', min = 1, max = 2 },
        },
    },
}

-- Legacy rare loot disabled (house robbery uses Rewards above only).
Config.HouseRob.RewardsSpecial = {}


Config.HouseRob.Houses = {
    ["jamestown1"] = {
        ['routingBucket'] = 2800,
        ["coords"] = {
            ["x"] = 385.18,
            ["y"] = -1881.78,
            ["z"] = 26.03,
            ["h"] = 40.83
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["jamestown2"] = {
        ['routingBucket'] = 2801,
        ["coords"] = {
            ["x"] = 412.47,
            ["y"] = -1856.38,
            ["z"] = 27.32,
            ["h"] = 129.24
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["jamestown3"] = {
        ['routingBucket'] = 2802,
        ["coords"] = {
            ["x"] = 427.21,
            ["y"] = -1842.09,
            ["z"] = 28.46,
            ["h"] = 134.19
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["roylow1"] = {
        ['routingBucket'] = 2803,
        ["coords"] = {
            ["x"] = 348.77,
            ["y"] = -1820.95,
            ["z"] = 28.89,
            ["h"] = 135.8
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["roylow2"] = {
        ['routingBucket'] = 2804,
        ["coords"] = {
            ["x"] = 329.42,
            ["y"] = -1845.8,
            ["z"] = 27.75,
            ["h"] = 228.98
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["roylow3"] = {
        ['routingBucket'] = 2805,
        ["coords"] = {
            ["x"] = 320.27,
            ["y"] = -1854.06,
            ["z"] = 27.51,
            ["h"] = 225.09
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["covenant1"] = {
        ['routingBucket'] = 2806,
        ["coords"] = {
            ["x"] = 192.29,
            ["y"] = -1883.23,
            ["z"] = 25.06,
            ["h"] = 326.47
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["covenant2"] = {
        ['routingBucket'] = 2807,
        ["coords"] = {
            ["x"] = 171.52,
            ["y"] = -1871.53,
            ["z"] = 24.4,
            ["h"] = 245.19
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["covenant3"] = {
        ['routingBucket'] = 2808,
        ["coords"] = {
            ["x"] = 128.24,
            ["y"] = -1897.02,
            ["z"] = 23.67,
            ["h"] = 239.54
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["covenant4"] = {
        ['routingBucket'] = 2809,
        ["coords"] = {
            ["x"] = 130.6,
            ["y"] = -1853.22,
            ["z"] = 25.23,
            ["h"] = 329.64
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    --[[ ["grove1"] = {
        ['routingBucket'] = 2810,
        ["coords"] = {
            ["x"] = 76.36,
            ["y"] = -1948.1,
            ["z"] = 21.17,
            ["h"] = 44.97
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["grove2"] = {
        ['routingBucket'] = 2811,
        ["coords"] = {
            ["x"] = 101.03,
            ["y"] = -1912.16,
            ["z"] = 21.41,
            ["h"] = 331.84
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["grove3"] = {
        ['routingBucket'] = 2812,
        ["coords"] = {
            ["x"] = 126.73,
            ["y"] = -1930.12,
            ["z"] = 21.38,
            ["h"] = 210.98
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["grove4"] = {
        ['routingBucket'] = 2813,
        ["coords"] = {
            ["x"] = 114.25,
            ["y"] = -1961.19,
            ["z"] = 21.33,
            ["h"] = 198.18
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["grove5"] = {
        ['routingBucket'] = 2814,
        ["coords"] = {
            ["x"] = 118.41,
            ["y"] = -1921.1,
            ["z"] = 21.32,
            ["h"] = 234.75
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["grove6"] = {
        ['routingBucket'] = 2815,
        ["coords"] = {
            ["x"] = 72.01,
            ["y"] = -1939.04,
            ["z"] = 21.37,
            ["h"] = 134.5
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["grove7"] = {
        ['routingBucket'] = 2816,
        ["coords"] = {
            ["x"] = 56.49,
            ["y"] = -1922.78,
            ["z"] = 21.91,
            ["h"] = 141.75
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["grove8"] = {
        ['routingBucket'] = 2817,
        ["coords"] = {
            ["x"] = 38.96,
            ["y"] = -1911.49,
            ["z"] = 21.95,
            ["h"] = 56.14
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["grove9"] = {
        ['routingBucket'] = 2818,
        ["coords"] = {
            ["x"] = 5.22,
            ["y"] = -1884.34,
            ["z"] = 23.7,
            ["h"] = 231.78
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["grove10"] = {
        ['routingBucket'] = 2819,
        ["coords"] = {
            ["x"] = -4.73,
            ["y"] = -1872.2,
            ["z"] = 24.15,
            ["h"] = 230.43
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ]]--
    ["prosperity1"] = {
        ['routingBucket'] = 2820,
        ["coords"] = {
            ["x"] = -1076.33,
            ["y"] = -1026.96,
            ["z"] = 4.54,
            ["h"] = 118.14
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["prosperity2"] = {
        ['routingBucket'] = 2821,
        ["coords"] = {
            ["x"] = -1064.64,
            ["y"] = -1057.42,
            ["z"] = 6.41,
            ["h"] = 115.35
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["prosperity3"] = {
        ['routingBucket'] = 2822,
        ["coords"] = {
            ["x"] = -1063.77,
            ["y"] = -1054.99,
            ["z"] = 2.15,
            ["h"] = 120.47
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["prosperity4"] = {
        ['routingBucket'] = 2823,
        ["coords"] = {
            ["x"] = -1054.07,
            ["y"] = -1000.2,
            ["z"] = 6.41,
            ["h"] = 296.69
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["prosperity5"] = {
        ['routingBucket'] = 2824,
        ["coords"] = {
            ["x"] = -985.89,
            ["y"] = -1121.74,
            ["z"] = 4.55,
            ["h"] = 297.63
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["prosperity6"] = {
        ['routingBucket'] = 2825,
        ["coords"] = {
            ["x"] = -1024.42,
            ["y"] = -1140.0,
            ["z"] = 2.75,
            ["h"] = 213.84
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["prosperity7"] = {
        ['routingBucket'] = 2826,
        ["coords"] = {
            ["x"] = -1074.13,
            ["y"] = -1152.73,
            ["z"] = 2.16,
            ["h"] = 118.65
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["prosperity8"] = {
        ['routingBucket'] = 2827,
        ["coords"] = {
            ["x"] = -1063.57,
            ["y"] = -1160.35,
            ["z"] = 2.75,
            ["h"] = 210.36
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["prosperity10"] = {
        ['routingBucket'] = 2828,
        ["coords"] = {
            ["x"] = -990.56,
            ["y"] = -975.93,
            ["z"] = 4.22,
            ["h"] = 122.0
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["prosperity11"] = {
        ['routingBucket'] = 2829,
        ["coords"] = {
            ["x"] = -1008.49,
            ["y"] = -1015.42,
            ["z"] = 2.15,
            ["h"] = 210.75
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["paleto1"] = {
        ['routingBucket'] = 2830,
        ["coords"] = {
            ["x"] = -360.24,
            ["y"] = 6260.61,
            ["z"] = 31.9,
            ["h"] = 136.27
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["paleto2"] = {
        ['routingBucket'] = 2831,
        ["coords"] = {
            ["x"] = -366.57,
            ["y"] = 6214.12,
            ["z"] = 31.84,
            ["h"] = 317.03
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["paleto3"] = {
        ['routingBucket'] = 2832,
        ["coords"] = {
            ["x"] = -447.87,
            ["y"] = 6260.25,
            ["z"] = 30.05,
            ["h"] = 338.35
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["paleto4"] = {
        ['routingBucket'] = 2833,
        ["coords"] = {
            ["x"] = -245.99,
            ["y"] = 6414.45,
            ["z"] = 31.46,
            ["h"] = 305.54
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["paleto5"] = {
        ['routingBucket'] = 2834,
        ["coords"] = {
            ["x"] = -9.59,
            ["y"] = 6654.23,
            ["z"] = 31.7,
            ["h"] = 31.66
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["paleto6"] = {
        ['routingBucket'] = 2835,
        ["coords"] = {
            ["x"] = 25.1,
            ["y"] = 6601.76,
            ["z"] = 32.47,
            ["h"] = 133.36
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["paletoHotels1"] = {
        ['routingBucket'] = 2836,
        ["coords"] = {
            ["x"] = -159.84,
            ["y"] = 6432.65,
            ["z"] = 31.93,
            ["h"] = 310.91
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["paletoHotels2"] = {
        ['routingBucket'] = 2837,
        ["coords"] = {
            ["x"] = -149.98,
            ["y"] = 6416.07,
            ["z"] = 31.92,
            ["h"] = 225.27
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    ["emhouseRobbery1"] = { 
        ['routingBucket'] = 2837,
        ["coords"] = {
            ["x"] = 35.4939,
            ["y"] = 6663.1904,
            ["z"] = 32.1905,
            ["h"] = 17.9895
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    
    ["emhouseRobbery2"] = { 
        ['routingBucket'] = 2838,
        ["coords"] = {
            ["x"] = 1.8432,
            ["y"] = 6612.5811,
            ["z"] = 32.0796,
            ["h"] = 122.1069
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    
    ["emhouseRobbery3"] = { 
        ['routingBucket'] = 2839,
        ["coords"] = {
            ["x"] = -41.5201,
            ["y"] = 6637.4160,
            ["z"] = 31.0875,
            ["h"] = 40.5706
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    
    ["emhouseRobbery4"] = { 
        ['routingBucket'] = 2840,
        ["coords"] = {
            ["x"] = -26.4779,
            ["y"] = 6597.2451,
            ["z"] = 31.8608,
            ["h"] = 218.1463
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    
    ["emhouseRobbery5"] = { 
        ['routingBucket'] = 2841,
        ["coords"] = {
            ["x"] = -44.4633,
            ["y"] = 6581.9751,
            ["z"] = 32.1755,
            ["h"] = 226.1913
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    
    ["emhouseRobbery6"] = { 
        ['routingBucket'] = 2842,
        ["coords"] = {
            ["x"] = -130.6622,
            ["y"] = 6551.9751,
            ["z"] = 29.8659,
            ["h"] = 49.8413
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
    
    ["emhouseRobbery7"] = { 
        ['routingBucket'] = 2843,
        ["coords"] = {
            ["x"] = -105.7078,
            ["y"] = 6528.6396,
            ["z"] = 30.1669,
            ["h"] = 86.5748
        },
        ["opened"] = false,
        ["tier"] = 1,
        ["furniture"] = {
            [1] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 4.15, ["y"] = 7.82, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Bedside Cabinet"
            },
            [2] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 5.95, ["y"] = 9.34, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Closet"
            },
            [3] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -1.03, ["y"] = 0.78, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [4] = {
                ["type"] = "chest",
                ["coords"] = {["x"] = 6.904, ["y"] = 3.987, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Chest"
            },
            [5] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 0.933, ["y"] = 1.254, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search Drawers"
            },
            [6] = {
                ["type"] = "cabin",
                ["coords"] = {["x"] = 6.19, ["y"] = 3.35, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Night Stand Cabinet"
            },
            [7] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -2.20, ["y"] = -0.30, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through the kitchen cabinets"
            },
            [8] = {
                ["type"] = "kitchen",
                ["coords"] = {["x"] = -4.35, ["y"] = -0.64, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [9] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.90, ["y"] = 4.42, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
            [10] = {
                ["type"] = "livingroom",
                ["coords"] = {["x"] = -6.98, ["y"] = 7.91, ["z"] = 1.0},
                ["searched"] = false,
                ["isBusy"] = false,
                ["text"] = "Search through shelves"
            },
        }
    },
}