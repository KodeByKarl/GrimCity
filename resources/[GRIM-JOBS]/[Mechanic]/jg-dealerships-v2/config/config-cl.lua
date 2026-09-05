-- ================================================
-- Client Custom Callback Configuration
-- ================================================
-- Use this file to customize client event behavior (purchase, test drive, and sell flows).
-- Add your own code inside the relevant event handlers.

-- [Triggered after vehicle purchase]
-- Parameters:
--   vehicle      = vehicle entity handle
--   plate        = plate number
--   purchaseType = purchase type ("personal" or "society")
--   amount       = paid amount
--   paymentMethod= payment method ("cash" or "bank")
--   financed     = whether purchase is financed (true/false)
RegisterNetEvent("jg-dealerships:client:purchase-vehicle:config", function(vehicle, plate, purchaseType, amount, paymentMethod, financed)
  -- Add post-purchase custom logic here (e.g. notify, trigger custom events)

end)

-- [Triggered when a test drive starts]
-- Parameters:
--   vehicle = test drive vehicle entity handle
--   plate   = test drive plate
RegisterNetEvent("jg-dealerships:client:start-test-drive:config", function(vehicle, plate)
  -- Add custom logic after test drive starts

end)

-- [Triggered after a vehicle is sold]
-- Parameters:
--   vehicle = sold vehicle entity handle
--   plate   = sold vehicle plate
RegisterNetEvent("jg-dealerships:client:sell-vehicle:config", function(vehicle, plate)
  -- Default behavior: delete the sold vehicle entity
  JGDeleteVehicle(vehicle)
end)

-- [Showroom pre-check]
-- Called before a player enters the showroom. Return true to allow, false to block.
-- Parameters:
--   dealershipId = dealership ID (unique DB ID)
function ShowroomPreCheck(dealershipId)
  -- Ask the server so we use live metadata + user_licenses, not stale client data
  local allowed = lib.callback.await('jg-dealerships:hasDrivingLicense', false)
  if allowed then
    return true
  end

  Framework.Client.Notify(
    'You need a driver\'s license from the Driving School before you can buy a vehicle.',
    'error'
  )
  return false
end
