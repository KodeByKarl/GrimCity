Database = {}

-- ESX identifiers are `char1:license:<40 hex>` (54 chars). The stock
-- player_outfits.citizenid was varchar(50), which truncates and rejects saves.
CreateThread(function()
    MySQL.ready(function()
        pcall(function()
            MySQL.query.await([[
                ALTER TABLE `player_outfits`
                MODIFY COLUMN `citizenid` VARCHAR(64) DEFAULT NULL
            ]])
        end)
    end)
end)
