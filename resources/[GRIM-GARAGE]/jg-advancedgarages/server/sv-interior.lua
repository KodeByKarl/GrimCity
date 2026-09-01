-- Store player interior data (garage info, routing buckets)
local playerInteriorData = {}

-- Server callback for entering garage interior
lib.callback.register("jg-advancedgarages:server:enter-interior", function(playerId, garageData, interiorData)
    -- Interior garage feature is disabled.
    return false
end)

-- Server callback for exiting garage interior
lib.callback.register("jg-advancedgarages:server:exit-interior", function(playerId)
    -- Get player identifier
    local playerIdentifier = Framework.Server.GetPlayerIdentifier(playerId)
    if not playerIdentifier then
        return false
    end
    
    -- Get stored interior data for this player
    local interiorData = playerInteriorData[playerIdentifier]
    
    if interiorData then
        -- Return to original bucket if configured
        if Config.ReturnToPreviousRoutingBucket then
            SetPlayerRoutingBucket(playerId, interiorData.originalBucket)
        end
    else
        -- Default to main routing bucket if no data found
        SetPlayerRoutingBucket(playerId, 0)
    end
    
    -- Clean up stored data
    playerInteriorData[playerIdentifier] = nil
    
    return true
end)