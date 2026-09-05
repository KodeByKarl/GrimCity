-- Auto-seeder for Police Dealership
local function SeedPoliceDealership()
  CreateThread(function()
    Wait(2000) -- Allow tables to initialize

    -- 1. Ensure dealership_locations has police_dealership
    local exists = MySQL.scalar.await("SELECT COUNT(*) FROM dealership_locations WHERE id = ?", {"police_dealership"})
    if not exists or exists == 0 then
      MySQL.insert.await([[
        INSERT INTO dealership_locations (
          id, name, type, disabled, job_name, balance,
          showroom_coords, purchase_vehicle_coords, test_drive_coords,
          categories, camera_data, enable_purchase, enable_finance,
          enable_test_drive, enable_sell_vehicle,
          showroom_job_whitelist, society_purchase_job_whitelist, payment_methods
        ) VALUES (
          'police_dealership',
          'Police Dealership',
          'self-service',
          0,
          'police',
          0,
          ?,
          ?,
          ?,
          ?,
          ?,
          1,
          0,
          1,
          0,
          ?,
          ?,
          ?
        )
      ]], {
        json.encode({ x = 463.9792, y = -1019.6293, z = 28.1011, h = 94.5021, size = 3.0 }),
        json.encode({ x = 435.8250, y = -1022.2808, z = 28.6763, h = 98.7247 }),
        json.encode({ x = 435.8250, y = -1022.2808, z = 28.6763, h = 98.7247 }),
        json.encode({ "emergency", "police" }),
        json.encode({ name = "Car", coords = { x = -146.6166, y = -596.6301, z = 166.0, h = 270.0 }, positions = { 5.0, 8.0, 12.0, 8.0 } }),
        json.encode({ "police" }),
        json.encode({ "police" }),
        json.encode({ "bank", "cash" })
      })
      print("^2[jg-dealerships-v2] Seeded Police Dealership location into database.^7")
    end

    -- 2. Ensure vehicles exist in dealership_vehicles
    local vehicles = {
      { spawn = "oycdefenderp", brand = "Police", model = "Defender PD", cat = "emergency", price = 75000 },
      { spawn = "polgs350", brand = "Police", model = "Lexus GS350 PD", cat = "emergency", price = 60000 },
      { spawn = "pranger", brand = "Police", model = "Police Ranger", cat = "emergency", price = 50000 },
    }

    for _, veh in ipairs(vehicles) do
      MySQL.query.await([[
        INSERT INTO dealership_vehicles (spawn_code, brand, model, category, price, unlimited_stock)
        VALUES (?, ?, ?, ?, ?, 1)
        ON DUPLICATE KEY UPDATE brand = VALUES(brand), model = VALUES(model), category = VALUES(category), price = VALUES(price)
      ]], { veh.spawn, veh.brand, veh.model, veh.cat, veh.price })

      MySQL.query.await([[
        INSERT INTO dealership_stock (dealership, vehicle, stock, price)
        VALUES ('police_dealership', ?, 999, ?)
        ON DUPLICATE KEY UPDATE stock = VALUES(stock), price = VALUES(price)
      ]], { veh.spawn, veh.price })
    end

    Locations.Server.ClearCache()
  end)
end

AddEventHandler("onResourceStart", function(resourceName)
  if GetCurrentResourceName() == resourceName then
    SeedPoliceDealership()
  end
end)
