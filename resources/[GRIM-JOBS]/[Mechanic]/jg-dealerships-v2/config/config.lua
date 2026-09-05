Config = {}

-- ================================================
-- Base Language and Formatting
-- ================================================

-- Language setting (available: cn, en, jp, de, etc.)
Config.Locale = "en"

-- Number and date format ("en-US" = US format, "zh-CN" = CN format)
Config.NumberAndDateFormat = "en-US"

-- Currency display format (%s is the amount placeholder)
Config.Currency = "$%s"

-- Speed unit ("kph" = kilometers/hour, "mph" = miles/hour)
Config.SpeedUnit = "kph"

-- Distance unit ("km" = kilometers, "mi" = miles)
Config.DistanceUnit = "km"

-- ================================================
-- Framework and System Integrations
-- ================================================

-- Game framework ("auto" = auto detect, "esx", "qb", "qbox")
Config.Framework = "auto"

-- Fuel system ("ox_fuel", "LegacyFuel", "ps-fuel", "cdn-fuel", false = disabled)
Config.FuelSystem = "ox_fuel"

-- Vehicle key system ("qb-vehiclekeys", "qs-vehiclekeys", "vehicles_keys", "mk_vehiclekeys", false = disabled)
Config.VehicleKeys = "cfx-keydi-carlock"

-- Notification system ("auto", "ox_lib", "qb", "esx", etc.)
Config.Notifications = "auto"

-- Interaction method ("textui" = text prompt, "target" = target interaction)
Config.InteractionMethod = "textui"

-- Text UI system ("ox_lib", "qtarget", "bt-target", etc.)
Config.DrawText = "ox_lib"

-- Target system ("auto", "ox_target", "qb-target", "bt-target")
Config.Target = "auto"

-- 3D text drawing ("auto", "ox_lib", "native")
Config.DrawText3d = "auto"

-- Radial menu ("ox_lib", "qb-menu", false = disabled)
Config.RadialMenu = "ox_lib"

-- Use framework jobs to manage employees (true = framework jobs, false = built-in employee system)
Config.UseFrameworkJobs = false

-- ================================================
-- Showroom Interaction Prompts
-- ================================================

-- Prompt shown to open the showroom
Config.OpenShowroomPrompt = "[E] Open Showroom"

-- Keybind to open the showroom (38 = E)
Config.OpenShowroomKeyBind = 38

-- Prompt shown to view vehicle in the showroom
Config.ViewInShowroomPrompt = "[E] View in Showroom"

-- Keybind to view vehicle in the showroom (38 = E)
Config.ViewInShowroomKeyBind = 38

-- Prompt shown to open dealership management
Config.OpenManagementPrompt = "[E] Dealership Management"

-- Keybind to open dealership management (38 = E)
Config.OpenManagementKeyBind = 38

-- Prompt shown to sell vehicle
Config.SellVehiclePrompt = "[E] Sell Vehicle"

-- Keybind to sell vehicle (38 = E)
Config.SellVehicleKeyBind = 38

-- ================================================
-- Vehicle Spawning and Performance
-- ================================================

-- Spawn vehicles with server setter (true = better sync/compatibility, slower; false = client spawn)
Config.SpawnVehiclesWithServerSetter = false

-- ================================================
-- Finance Settings
-- ================================================

-- Default number of finance payments (e.g. 12 = 12 payments)
Config.FinancePayments = 12

-- Down payment ratio (0.1 = 10% of vehicle price)
Config.FinanceDownPayment = 0.1

-- Interest rate (0.1 = 10%; total price = vehicle price x (1 + rate))
Config.FinanceInterest = 0.1

-- Payment interval (in-game hours)
Config.FinancePaymentInterval = 12

-- Hours until repossession after missed payment
Config.FinancePaymentFailedHoursUntilRepo = 1

-- Maximum financed vehicles per player
Config.MaxFinancedVehiclesPerPlayer = 5

-- Process finance payments for offline players
Config.FinanceProcessOfflinePlayers = true

-- Show vehicle images in list (requires matching files in `vehicle_images`)
Config.ShowVehicleImages = false

-- ================================================
-- Plate and Test Drive Settings
-- ================================================

-- Plate format ("1AA111AA" = default random pattern)
Config.PlateFormat = "1AA111AA"

-- Hide vehicle stats (speed/torque/etc.)
Config.HideVehicleStats = false

-- Test drive vehicle plate
Config.TestDrivePlate = "ELBORP"

-- Test drive duration in seconds (120 = 2 minutes)
Config.TestDriveTimeSeconds = 120

-- Run test drive outside routing bucket (true = main world, false = isolated bucket)
Config.TestDriveNotInBucket = false

-- Max active test drives per dealership
Config.DealershipMaxActiveTestDrives = 5

-- Display vehicle plate (for static showroom vehicles)
Config.DisplayVehiclesPlate = "DEALER"

-- Hide purchase prompt on display vehicles (showcase only)
Config.DisplayVehiclesHidePurchasePrompt = false

-- ================================================
-- Orders and Inventory
-- ================================================

-- Enable trucking mission delivery for orders (true = employee must deliver by truck)
Config.TruckingMissionForOrderDeliveries = false

-- Dealer purchase price ratio (0.8 = 80% of sale price)
Config.DealerPurchasePrice = 0.8

-- Vehicle order delivery time in minutes
Config.VehicleOrderTime = 1

-- Allow managers to edit vehicle prices
Config.ManagerCanChangePriceOfVehicles = true

-- Blip label format (%s = dealership name)
Config.BlipNameFormat = "Dealership: %s"

-- ================================================
-- Vehicle Categories
-- ================================================

Config.Categories = {

  planes = "Planes",

  sportsclassics = "Sports Classics",

  sedans = "Sedans",

  compacts = "Compacts",

  motorcycles = "Motorcycles",

  super = "Super",

  offroad = "Off-Road",

  helicopters = "Helicopters",

  coupes = "Coupes",

  muscle = "Muscle",

  boats = "Boats",

  vans = "Vans",

  sports = "Sports",

  suvs = "SUV",

  commercial = "Commercial",

  cycles = "Cycles",

  industrial = "Industrial",

  emergency = "Emergency",

  police = "Police"

}

-- ================================================
-- Employee Permission Configuration
-- ================================================
-- Available permissions:
--   ADMIN            = Full management access
--   MANAGE_INVENTORY = Manage stock and ordering
--   VIEW_RECORDS     = View sales records
--   SELL             = Sell vehicles (including direct sale/test drive)
--   DELIVER          = Deliver orders

Config.EmployeePermissions = {

  -- Manager: full access
  ["Manager"] = {

    "ADMIN",

  },

  -- Supervisor: inventory, records, selling, and delivery
  ["Supervisor"] = {

    "MANAGE_INVENTORY",

    "VIEW_RECORDS",

    "SELL",

    "DELIVER",

  },

  -- Sales: selling, records, and delivery
  ["Sales"] = {

    "SELL",

    "VIEW_RECORDS",

    "DELIVER",

  },

}

-- ================================================
-- Chat Commands
-- ================================================

-- Command to view personal finance info (use /myfinance)
Config.MyFinanceCommand = "myfinance"

-- Direct sale command (for sales staff to sell to nearby players)
Config.DirectSaleCommand = "directsale"

-- Dealership admin command (server admins)
Config.DealerAdminCommand = "dealeradmin"

-- ================================================
-- Advanced Settings
-- ================================================

-- Entity streaming distance in meters (higher values increase performance cost)
Config.EntityStreamingDistance = 100.0

-- Remove generator props around dealership to avoid scene conflicts
Config.RemoveGeneratorsAroundDealership = true

-- Auto-run SQL install script (false so it does not re-insert deleted vehicles on server start)
Config.AutoRunSQL = true

-- Return player to previous routing bucket after test drive (false = default world)
Config.ReturnToPreviousRoutingBucket = false

-- Hide bottom-right watermark
Config.HideWatermark = true

-- Enable debug logging (set false for production)
Config.Debug = false
