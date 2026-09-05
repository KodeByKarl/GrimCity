ConfigPlaytimeShop = {}

ConfigPlaytimeShop.Command = 'playtimeshop'
ConfigPlaytimeShop.OpenKey = 'F7'

-- Every 25 minutes online → +5 Grim Coins
ConfigPlaytimeShop.RewardIntervalMinutes = 25
ConfigPlaytimeShop.RewardCoins = 5

-- Server tick interval (seconds) — keep high for 0.00 idle feel
ConfigPlaytimeShop.TickSeconds = 60

ConfigPlaytimeShop.GarageId = 'Legion Square'

-- Catalog — server is source of truth (client never chooses arbitrary item names)
-- type: 'item' | 'car'
ConfigPlaytimeShop.Items = {
    { id = 'bandage', label = 'BANDAGE', item = 'bandage', amount = 5, price = 15, image = 'bandage' },
    { id = 'lockpick', label = 'LOCKPICK', item = 'lockpick', amount = 1, price = 35, image = 'lockpick' },
    { id = 'armor', label = 'ARMOR', item = 'armour', amount = 1, price = 80, image = 'armour' },
    { id = 'repairkit', label = 'REPAIR KIT', item = 'repairkit', amount = 1, price = 45, image = 'repairkit' },
    { id = 'phone', label = 'PHONE', item = 'phone', amount = 1, price = 60, image = 'phone' },
    { id = 'radio', label = 'RADIO', item = 'radio', amount = 1, price = 50, image = 'radio' },
    { id = 'water', label = 'WATER', item = 'water', amount = 5, price = 10, image = 'water' },
    { id = 'burger', label = 'BURGER', item = 'burger', amount = 5, price = 12, image = 'burger' },
}

ConfigPlaytimeShop.Cars = {
    { id = 'panto', label = 'PANTO', model = 'panto', price = 250, image = 'car' },
    { id = 'blista', label = 'BLISTA', model = 'blista', price = 400, image = 'car' },
    { id = 'futo', label = 'FUTO', model = 'futo', price = 550, image = 'car' },
    { id = 'sultan', label = 'SULTAN', model = 'sultan', price = 900, image = 'car' },
    { id = 'elegy', label = 'ELEGY', model = 'elegy2', price = 1200, image = 'car' },
    { id = 'buffalo', label = 'BUFFALO', model = 'buffalo2', price = 1000, image = 'car' },
}

ConfigPlaytimeShop.PageSize = 6
ConfigPlaytimeShop.TopLimit = 10
