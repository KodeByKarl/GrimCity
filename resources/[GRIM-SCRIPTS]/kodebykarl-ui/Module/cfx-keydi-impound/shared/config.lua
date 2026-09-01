ConfigImpound = {}

ConfigImpound.Debug = false
ConfigImpound.Interval = 30 * 60 * 1000 -- every 30 minutes
ConfigImpound.WarningDuration = 120 -- 2 minutes warning countdown

-- Integration with jg-advancedgarages / ESX owned_vehicles
ConfigImpound.ReturnToGarage = true -- Set in_garage = 1 and stored = 1 on impound
ConfigImpound.ClearAllOrphanedVehicles = true -- Sweep database for vehicles left out whose entity no longer exists
ConfigImpound.RestoreOnStart = true -- Restore left-out cars to garage on server/resource start
ConfigImpound.DefaultGarage = "Legion Square" -- Default garage name in jg-advancedgarages

-- Protection for Vehicles undergoing Upgrades / In Mechanic Shops
ConfigImpound.ProtectMechanicZones = true -- Protect vehicles inside or near mechanic shops, bays, and car lifts
ConfigImpound.ProtectUpgradingVehicles = true -- Protect vehicles currently in customization menus / servicing / tuning
ConfigImpound.PreviewPlateName = "PREVIEW" -- Plate set by jg-mechanic or tuning scripts during preview

-- Known Mechanic & Custom Shop Zones (coords & protection radius)
ConfigImpound.MechanicExclusionZones = {
    -- Benny's Motorworks / Main Mechanic Hub (all bays)
    { coords = vector3(-337.38, -136.92, 39.01), radius = 60.0, name = "Benny's Motorworks Hub" },
    -- Los Santos Customs (Burton / Center)
    { coords = vector3(-362.59, -132.84, 38.68), radius = 45.0, name = "Benny's Side Bay" },
    { coords = vector3(-1155.53, -2005.44, 13.18), radius = 40.0, name = "LS Customs Airport" },
    { coords = vector3(731.81, -1088.82, 22.17), radius = 40.0, name = "LS Customs Downtown" },
    { coords = vector3(1177.62, 2640.23, 37.75), radius = 40.0, name = "LS Customs Route 68" },
    { coords = vector3(110.85, 6626.39, 31.79), radius = 40.0, name = "LS Customs Paleto" },
}

