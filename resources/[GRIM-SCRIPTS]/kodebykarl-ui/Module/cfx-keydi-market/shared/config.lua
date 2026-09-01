ConfigMarket = {
    Enabled = true,
    Debug = false,

    -- Ped-only open (ox_target). No /market command.
    OpenCommand = false,

    -- lb-phone app: live prices only (no selling)
    PhoneApp = {
        Enabled = true,
        DefaultApp = true, -- home screen, no App Store download
        Identifier = 'pandora-market',
        Name = 'Pandora Market',
        Description = 'Live sell market prices. View only — sell at the market NPC.',
        Developer = 'Pandora City',
    },

    -- Server rolls a new sell price per item in [minPrice, maxPrice] on this interval
    PriceUpdate = {
        IntervalMinutes = 120, -- every 2 hours
        Announce = true,
        AnnounceMessage = 'Sell Market prices have been updated! Check the market for new rates.',
        AnnounceSender = 'Sell Market',
    },

    -- NPC + blip live in cfx-keydi-utils/configs/peds.lua (server-wide ped system).
    -- Keep coords here so the server can verify the seller is at the stall.
    Locations = {
        {
            coords = vec4(342.9301, -1298.0554, 32.55, 154.4067),
            ped = 'a_m_m_business_01',
            scenario = 'WORLD_HUMAN_CLIPBOARD',
            blip = {
                label = 'Sell Market',
                sprite = 78,
                color = 2,
                scale = 0.85,
                shortRange = true,
            },
        },
    },

    -- Sell prices: each update rolls a random price between minPrice and maxPrice
    Items = {
        -- Farming
        { item = 'mango',        label = 'Mango',         category = 'Farming',  minPrice = 30,  maxPrice = 80 },
        { item = 'apple',        label = 'Apple',         category = 'Farming',  minPrice = 30,  maxPrice = 80 },
        { item = 'pumpkin',      label = 'Pumpkin',       category = 'Farming',  minPrice = 30,  maxPrice = 80 },
        { item = 'arabica',      label = 'Arabica',       category = 'Farming',  minPrice = 30,  maxPrice = 80 },
        { item = 'lettuce',      label = 'Lettuce',       category = 'Farming',  minPrice = 30,  maxPrice = 80 },
        { item = 'tomato',       label = 'Tomato',        category = 'Farming',  minPrice = 30,  maxPrice = 80 },
        { item = 'potato',       label = 'Potato',        category = 'Farming',  minPrice = 30,  maxPrice = 80 },
        { item = 'carrot',       label = 'Carrot',        category = 'Farming',  minPrice = 30,  maxPrice = 80 },
        { item = 'honey',        label = 'Honey',         category = 'Farming',  minPrice = 50,  maxPrice = 100 },
        { item = 'cocoa',        label = 'Cocoa',         category = 'Farming',  minPrice = 30,  maxPrice = 80 },
        { item = 'mushroom',     label = 'Mushroom',      category = 'Farming',  minPrice = 30,  maxPrice = 80 },
        { item = 'onion',        label = 'Onion',         category = 'Farming',  minPrice = 30,  maxPrice = 80 },
        { item = 'crab',         label = 'Crab',          category = 'Farming',  minPrice = 30,  maxPrice = 80 },

        -- Hunting
        { item = 'raw_chicken',  label = 'Chicken',       category = 'Hunting',  minPrice = 50,  maxPrice = 100 },
        { item = 'raw_meat',     label = 'Meat',          category = 'Hunting',  minPrice = 50,  maxPrice = 100 },

        -- Mining / materials
        { item = 'scrapmetal',   label = 'Scrap Metal',   category = 'Mining',   minPrice = 50,  maxPrice = 100 },
        { item = 'stone',        label = 'Stone',         category = 'Mining',   minPrice = 30,  maxPrice = 80 },
        { item = 'washed_rocks', label = 'Wash Stone',    category = 'Mining',   minPrice = 30,  maxPrice = 80 },
        { item = 'copper',       label = 'Copper',        category = 'Mining',   minPrice = 30,  maxPrice = 80 },
        { item = 'iron',         label = 'Iron',          category = 'Mining',   minPrice = 35,  maxPrice = 75 },
        { item = 'aluminum',     label = 'Aluminum',      category = 'Mining',   minPrice = 35,  maxPrice = 80 },
        { item = 'steel',        label = 'Steel',         category = 'Mining',   minPrice = 40,  maxPrice = 80 },
        { item = 'titanium',     label = 'Titanium',      category = 'Mining',   minPrice = 50,  maxPrice = 100 },
        { item = 'cloth',        label = 'Cloth',         category = 'Mining',   minPrice = 25,  maxPrice = 55 },
        { item = 'kevlar',       label = 'Kevlar',        category = 'Mining',   minPrice = 80,  maxPrice = 150 },
        { item = 'emerald',      label = 'Emerald',       category = 'Mining',   minPrice = 200, maxPrice = 400 },
        { item = 'diamond',      label = 'Diamond',       category = 'Mining',   minPrice = 150, maxPrice = 300 },
    },
}
