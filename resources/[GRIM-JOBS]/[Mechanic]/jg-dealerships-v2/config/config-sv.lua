-- ================================================
-- Server Custom Callback Configuration
-- ================================================
-- Use this file to customize server event behavior (purchase logs, finance completion, repossession, etc.).
-- Add your own code inside the relevant functions.

-- [Triggered after vehicle purchase (server)]
-- Parameters:
--   vehNetId      = vehicle network ID
--   plate         = plate number
--   purchaseType  = purchase type ("personal" or "society")
--   amount        = paid amount
--   paymentMethod = payment method ("cash" or "bank")
--   financed      = whether purchase is financed (true/false)
RegisterNetEvent("jg-dealerships:server:purchase-vehicle:config", function(vehNetId, plate, purchaseType, amount, paymentMethod, financed)

  local src = source

  local vehicle = NetworkGetEntityFromNetworkId(vehNetId)

  -- Add post-purchase server logic here (e.g. DB log, Discord webhook, etc.)

end)

-- [Triggered when finance is fully paid]
-- Parameters:
--   playerId = player's server ID
--   plate    = plate that has been paid off
RegisterNetEvent("jg-dealerships:server:vehicle-finance-complete", function(playerId, plate)
  -- Add logic for finance completion here (e.g. notification/logging)

end)

-- [Triggered when finance defaults / vehicle is repossessed]
-- Parameters:
--   playerId   = player's server ID
--   plate      = repossessed vehicle plate
--   amountOwed = remaining debt
RegisterNetEvent("jg-dealerships:server:vehicle-finance-defaulted", function(playerId, plate, amountOwed)
  -- Add logic after repossession here (e.g. notification/default logging)

end)

-- [Sell vehicle pre-check]
-- Called before a player sells a vehicle. Return true to allow, false to block.
-- Parameters:
--   dealershipId = dealership ID
--   plate        = vehicle plate
--   model        = vehicle model name (e.g. "adder")
--   price        = quoted price
function SellVehiclePreCheck(dealershipId, plate, model, price)
  -- Add custom pre-sale checks here
  return true

end

-- Driving license required before buying.
-- Checks ESX metadata (DMV), legacy user_licenses rows, and the physical card.
local LICENSE_DB_TYPES = {
  car = { 'drive', 'car' },
  motorcycle = { 'drive_bike', 'motorcycle' },
}

local LICENSE_META_KEYS = {
  car = { 'car', 'drive', 'driver' },
  motorcycle = { 'motorcycle', 'drive_bike', 'bike' },
}

local function licenseGranted(entry)
  if entry == true or entry == 1 or entry == 'true' then
    return true
  end
  if type(entry) ~= 'table' then
    return false
  end
  local has = entry.has
  return has == true or has == 1 or has == 'true'
end

local function getPlayerLicenses(xPlayer)
  if xPlayer.getMeta then
    return xPlayer.getMeta('licenses') or {}
  end
  if xPlayer.PlayerData and xPlayer.PlayerData.metadata then
    return xPlayer.PlayerData.metadata.licenses or {}
  end
  return {}
end

local function backfillLicenseMeta(xPlayer, licenseKey)
  if not xPlayer.setMeta then return end
  local licenses = getPlayerLicenses(xPlayer)
  if type(licenses) ~= 'table' then
    licenses = {}
  end
  if type(licenses[licenseKey]) ~= 'table' then
    licenses[licenseKey] = {
      has = true,
      label = licenseKey == 'motorcycle' and 'Motorcycle License' or 'Drivers License',
    }
  else
    licenses[licenseKey].has = true
  end
  xPlayer.setMeta('licenses', licenses)
end

local function hasUserLicenseRow(identifier, licenseKey)
  if not identifier or not MySQL then return false end
  local types = LICENSE_DB_TYPES[licenseKey]
  if not types then return false end

  local ok, found = pcall(function()
    for i = 1, #types do
      local row = MySQL.scalar.await(
        'SELECT 1 FROM `user_licenses` WHERE `type` = ? AND `owner` = ? LIMIT 1',
        { types[i], identifier }
      )
      if row then return true end
    end
    return false
  end)

  return ok and found == true
end

local function playerHasDrivingLicense(playerId, licenseKey)
  local xPlayer = ESX and ESX.GetPlayerFromId and ESX.GetPlayerFromId(playerId)
  if not xPlayer then
    xPlayer = Framework.Server.GetPlayer(playerId)
  end
  if not xPlayer then return false end

  local licenses = getPlayerLicenses(xPlayer)
  local metaKeys = LICENSE_META_KEYS[licenseKey] or { licenseKey }
  for i = 1, #metaKeys do
    if licenseGranted(licenses[metaKeys[i]]) then
      return true
    end
  end

  if hasUserLicenseRow(xPlayer.identifier, licenseKey) then
    backfillLicenseMeta(xPlayer, licenseKey)
    return true
  end

  if licenseKey == 'car' and GetResourceState('ox_inventory') == 'started' then
    local ok, count = pcall(function()
      return exports.ox_inventory:Search(playerId, 'count', 'driver_license') or 0
    end)
    if ok and count and count > 0 then
      return true
    end
  end

  return false
end

lib.callback.register('jg-dealerships:hasDrivingLicense', function(source, licenseKey)
  if licenseKey == 'car' or licenseKey == 'motorcycle' then
    return playerHasDrivingLicense(source, licenseKey)
  end
  return playerHasDrivingLicense(source, 'car') or playerHasDrivingLicense(source, 'motorcycle')
end)

local function requiredLicenseForModel(model)
  local hash = type(model) == 'string' and joaat(model) or tonumber(model) or 0
  local ok, class = pcall(GetVehicleClassFromName, hash)
  class = (ok and tonumber(class)) or 0

  -- 8 = Motorcycles
  if class == 8 then
    return 'motorcycle', 'a motorcycle license'
  end

  -- Boats / heli / planes: no DMV car license required
  if class == 14 or class == 15 or class == 16 then
    return nil, nil
  end

  -- Bicycles: no license
  if class == 13 then
    return nil, nil
  end

  return 'car', 'a driver\'s license'
end

-- [Purchase vehicle pre-check]
-- Called before a player purchases a vehicle. Return true to allow, false to block.
-- Parameters:
--   playerId         = buyer's server ID
--   dealershipId     = dealership ID
--   plate            = generated plate
--   model            = vehicle model
--   purchaseType     = purchase type ("personal" or "society")
--   amountToPay      = amount to pay
--   paymentMethod    = payment method
--   society          = society name (nil for personal purchases)
--   societyType      = society type
--   financed         = whether financed
--   noOfPayments     = number of payments
--   downPayment      = down payment amount
--   isDirectSale     = whether it is a staff direct sale
--   sellerPlayerId   = staff seller player ID (for direct sale)
function PurchaseVehiclePreCheck(playerId, dealershipId, plate, model, purchaseType, amountToPay, paymentMethod, society, societyType, financed, noOfPayments, downPayment, isDirectSale, sellerPlayerId)
  -- Society purchases are job-owned; skip civilian DMV check
  if purchaseType == 'society' then
    return true
  end

  local licenseKey, label = requiredLicenseForModel(model)
  if not licenseKey then
    return true
  end

  if playerHasDrivingLicense(playerId, licenseKey) then
    return true
  end

  Framework.Server.Notify(
    playerId,
    ('You need %s from the Driving School before you can buy this vehicle.'):format(label),
    'error'
  )
  return false
end
