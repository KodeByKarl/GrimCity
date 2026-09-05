-- ================================================
-- Trucking Mission Configuration
-- ================================================
-- This config only applies when Config.TruckingMissionForOrderDeliveries = true.
-- When enabled, dealership staff must drive a truck to collect and deliver trailers.

TruckingConfig = {}

-- Truck model (tractor unit), e.g. "hauler", "phantom"
TruckingConfig.TruckModel = "hauler"

-- Trailer model used for small/medium vehicles
TruckingConfig.TrailerSmallVehicle = "tr2"

-- Trailer model used for large vehicles
TruckingConfig.TrailerLargeVehicle = "tr2"

-- Truck properties (leave empty for default appearance)
TruckingConfig.TruckProperties = {

}

-- Cargo trailer properties (leave empty for default appearance)
TruckingConfig.CargoProperties = {

}

-- ================================================
-- Marker Settings
-- ================================================

TruckingConfig.Markers = {

  -- Truck spawn marker
  spawn = {

    type = 0,           -- Marker type (0 = upward arrow)

    size = 0.5,         -- Marker size (meters)

    color = {r = 230, g = 126, b = 34, a = 200},  -- Color (RGBA)

    bobUpAndDown = true,  -- Bob up and down

    faceCamera = false,   -- Face camera

    rotate = false        -- Rotate

  },

  -- Pickup marker
  pickup = {

    type = 0,

    size = 0.5,

    color = {r = 230, g = 126, b = 34, a = 200},

    bobUpAndDown = true,

    faceCamera = false,

    rotate = false

  },

  -- Drop-off marker
  dropoff = {

    type = 1,           -- Marker type (1 = cylinder zone)

    size = 3.0,         -- Marker size

    color = {r = 230, g = 126, b = 34, a = 200},

    bobUpAndDown = false,

    faceCamera = false,

    rotate = false

  }

}

-- ================================================
-- Trailer Attachment Settings
-- ================================================

TruckingConfig.TrailerAttachment = {

  -- Maximum distance to allow trailer attachment (meters)
  maxDistance = 3.0,

  -- Maximum angle difference for attachment (degrees)
  maxAngle = 45.0,

  -- Require approaching trailer from the front of the truck
  requireFront = true

}

-- ================================================
-- Blip Settings
-- ================================================

TruckingConfig.Blips = {

  -- Truck spawn blip
  spawn = {

    sprite = 477,           -- Sprite ID

    color = 47,             -- Color ID

    scale = 1.0,            -- Blip scale

    label = "Truck Spawn Point"    -- Label shown on the map

  },

  -- Cargo pickup blip
  pickup = {

    sprite = 478,

    color = 47,

    scale = 1.0,

    label = "Cargo Pickup Point"

  },

  -- Drop-off / delivery destination blip
  dropoff = {

    sprite = 50,

    color = 47,

    scale = 1.0,

    label = "Delivery Destination"

  }

}

-- ================================================
-- Pickup Location List
-- ================================================
-- Each pickup location contains:
--   name      = display name
--   coords    = coordinates vector4(x, y, z, heading)
--   blipColor = blip color ID

TruckingConfig.PickupLocations = {

  {

    name = "Elysian Island",

    coords = vector4(1200.46, -3238.60, 5.79, 0.00),

    blipColor = 47

  },

  {

    name = "Elysian Island",

    coords = vector4(1054.20, -3154.57, 5.90, 180.00),

    blipColor = 47

  },

  {

    name = "Port Container Yard",

    coords = vector4(863.25, -2927.89, 5.90, 270.00),

    blipColor = 47

  },

  {

    name = "Docks - Cargo Warehouse",

    coords = vector4(804.98, -2911.98, 6.00, 270.00),

    blipColor = 47

  },

  {

    name = "Cypress Flats - RON Storage",

    coords = vec4(630.34, -2748.96, 6.1, 304.89),

    blipColor = 5

  },

  {

    name = "Cypress Flats - Industrial Estate",

    coords = vector4(878.57, -2178.94, 30.52, 175.00),

    blipColor = 5

  },

  {

    name = "La Mesa - Logistics Hub",

    coords = vector4(858.13, -1712.15, 25.14, 352.00),

    blipColor = 5

  },

  {

    name = "El Burro Heights - Storage Facility",

    coords = vector4(1526.53, -2113.84, 76.77, 0.00),

    blipColor = 5

  },

  {

    name = "Los Santos International Airport - Cargo Terminal",

    coords = vector4(-782.29, -2661.93, 13.99, 60.00),

    blipColor = 3

  },

  {

    name = "Grand Senora Desert - Logistics Hub",

    coords = vector4(1777.37, 3309.64, 41.22, 298.00),

    blipColor = 5

  },

  {

    name = "Sandy Shores - Industrial Site",

    coords = vector4(2537.24, 2584.06, 37.94, 12.00),

    blipColor = 5

  },

  {

    name = "Paleto Bay - Freight Yard",

    coords = vector4(-361.33, 6065.99, 31.50, 311.00),

    blipColor = 47

  },

  {

    name = "East Vinewood - Import Facility",

    coords = vector4(875.16, -953.48, 28.06, 2.00),

    blipColor = 5

  },

  {

    name = "Murrieta Heights - Distribution Center",

    coords = vector4(1207.16, -1230.24, 35.23, 270.33),

    blipColor = 5

  },

  {

    name = "Docks - Cargo Warehouse",

    coords = vector4(758.59, -1656.02, 31.38, 354.00),

    blipColor = 5

  },

  {

    name = "Elysian Island",

    coords = vec4(166.6, -3297.93, 5.22, 269.91),

    blipColor = 5

  },

  {

    name = "Elysian Island",

    coords = vec4(130.21, -3337.48, 5.36, 268.56),

    blipColor = 5

  },

  {

    name = "Elysian Island",

    coords = vec4(287.65, -3209.35, 5.16, 269.95),

    blipColor = 5

  },

  {

    name = "Elysian Island",

    coords = vec4(305.19, -3091.21, 5.17, 0.25),

    blipColor = 5

  },

  {

    name = "Elysian Island",

    coords = vec4(244.01, -2791.55, 5.34, 218.72),

    blipColor = 5

  },

  {

    name = "Docks - Cargo Warehouse",

    coords = vec4(607.76, -2997.28, 5.38, 179.53),

    blipColor = 5

  },

  {

    name = "Docks - Cargo Warehouse",

    coords = vec4(600.28, -2930.8, 5.38, 180.67),

    blipColor = 5

  },

  {

    name = "Docks - Cargo Warehouse",

    coords = vec4(892.76, -3155.41, 5.24, 179.6),

    blipColor = 5

  },

  {

    name = "Docks - Cargo Warehouse",

    coords = vec4(896.6, -3155.53, 5.24, 179.14),

    blipColor = 5

  },

  {

    name = "Docks - Cargo Warehouse",

    coords = vec4(900.82, -3155.85, 5.24, 180.41),

    blipColor = 5

  },

  {

    name = "Docks - Cargo Warehouse",

    coords = vec4(928.91, -3184.42, 5.24, 0.88),

    blipColor = 5

  },

  {

    name = "Pirates Cove",

    coords = vec4(594.59, -2767.71, 5.39, 329.99),

    blipColor = 5

  },

  {

    name = "Pirates Cove",

    coords = vec4(631.09, -2748.45, 5.44, 305.14),

    blipColor = 5

  }, 

}
